#!/usr/bin/env bash
# Based on "aws-ssm-ssh-proxy-command" https://github.com/qoomon/aws-ssm-ssh-proxy-command
# MIT License
# Copyright (c) 2020 Bengt Brodersen
# Copyright (c) 2026 Victor Bouvier-Deleau

set -euo pipefail

AWS_PAGER=""
export AWS_PAGER

PROFILE_SEPARATOR='--'
INSTANCE_ID_PATTERN='^m?i-[0-9a-f]{8,17}$'

instance_name="${1}"
ssh_user="${2}"
ssh_port="${3}"
ssh_public_key_path="${4}"

if [[ ${instance_name} =~ ${PROFILE_SEPARATOR} ]]; then
  aws_profile="${instance_name%%"$PROFILE_SEPARATOR"*}"
  instance_name="${instance_name##*"${PROFILE_SEPARATOR}"}"
else
  echo "❌ No AWS profile specified, exiting" >&2
  exit 1
fi

echo "⌛ Checking AWS session status" >&2
if aws --profile "${aws_profile}" sts get-caller-identity &>/dev/null; then
  echo "✅ Already logged in" >&2
else
  aws_sso_session="$(cut -d '-' -f1-2 <<< ${aws_profile})"
  echo "🌐 Logging in to AWS with sso-session "${aws_sso_session}" using ${BROWSER}" >&2
  if aws sso login --sso-session "${aws_sso_session}" &>/dev/null; then
    echo "✅ Login successful" >&2
  else
    echo "❌ Login error, exiting" >&2
    exit 1
  fi
fi

aws_region="$(aws configure get region --profile "${aws_profile}")"

if [[ ${instance_name} =~ ${INSTANCE_ID_PATTERN} ]]; then
  instance_id="${instance_name}"
else
  instance_id="$(aws ec2 describe-instances --profile "${aws_profile}" --region "${aws_region}" --filters "Name=tag:Name,Values=${instance_name}" --query "Reservations[].Instances[?State.Name == 'running'].InstanceId" --output text)"

  if [[ -z "${instance_id}" || "${instance_id}" == "None" ]]; then
    echo "❌ Found no running instances with name \"${instance_name}\", exiting." >&2
    exit 1
  else
    echo "ℹ️ Resolved \"${instance_name}\" -> \"${instance_id}\"" >&2
  fi
fi

instance_availability_zone="$(aws ec2 describe-instances \
  --profile "${aws_profile}" \
  --region "${aws_region}" \
  --instance-id "$instance_id" \
  --query "Reservations[0].Instances[0].Placement.AvailabilityZone" \
  --output text)"

echo "⌛ Add public key ${ssh_public_key_path} for ${ssh_user} at instance ${instance_id} for 60 seconds" >&2
aws ec2-instance-connect send-ssh-public-key \
  --profile "${aws_profile}" \
  --region "${aws_region}" \
  --instance-id "${instance_id}" \
  --instance-os-user "${ssh_user}" \
  --ssh-public-key "file://${ssh_public_key_path}" \
  --availability-zone "${instance_availability_zone}" &>/dev/null

echo "🚀 Start ssm session to instance ${instance_id}" >&2
exec aws ssm start-session \
  --profile "${aws_profile}" \
  --region "${aws_region}" \
  --target "${instance_id}" \
  --document-name 'AWS-StartSSHSession' \
  --parameters "portNumber=${ssh_port}"
