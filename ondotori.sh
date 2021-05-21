#!/usr/bin/env bash
#
# Monitor temperature in the server room and send messages to Slack.
#
# Created by Daiki HAYASHI (hayashi.daiki@g.sp.m.is.nagoya-u.ac.jp)
#
set -x
set -e

. ./common.sh

[[ -z "${ONDOTORI_API_KEY}" ]] && echo "ONDOTORI_API_KEY must be set" >&2 && exit 1
[[ -z "${ONDOTORI_LOGIN_ID}" ]] && echo "ONDOTORI_LOGIN_ID must be set" >&2 && exit 1
[[ -z "${ONDOTORI_LOGIN_PASS}" ]] && echo "ONDOTORI_LOGIN_PASS must be set" >&2 && exit 1
[[ -z "${SLACK_WEBHOOK_URL}" ]] && echo "SLACK_WEBHOOK_URL must be set" >&2 && exit 1

threshold_temperature=${ONDOTORI_ALERT_THRESHOLD_TEMPERATURE:-40}
threshold_humidity=${ONDOTORI_ALERT_THRESHOLD_HUMIDITY:-80}

# Create temporal file to store API response
response=$(mktemp)

# Get current temperature
curl --request POST 'https://api.webstorage.jp/v1/devices/current' \
  --header 'Content-Type: application/json' \
  --header 'X-HTTP-Method-Override: GET' \
  --header 'Host: api.webstorage.jp:443' \
  --data-raw "{
      \"api-key\": \"${ONDOTORI_API_KEY}\",
      \"login-id\": \"${ONDOTORI_LOGIN_ID}\",
      \"login-pass\": \"${ONDOTORI_LOGIN_PASS}\"
  }" \
  > ${response}

cat ${response}

# Get the maximum temperature
max_temp=$(cat ${response} | jq -r '.devices[].channel | map(select(.unit == "C")) | .[] | .value' | max)
max_humid=$(cat ${response} | jq -r '.devices[].channel | map(select(.unit == "%")) | .[] | .value' | max)
[[ ! -n "${max_temp}" ]] && echo "Failed to get temperature" >&2 && exit 1
[[ ! -n "${max_humid}" ]] && echo "Failed to get humidity" >&2 && exit 1

# Alert
if (( $(echo "$max_temp > $threshold_temperature" | bc -l) )); then
  echo "Too hot!"
  curl --request POST "${SLACK_WEBHOOK_URL}" \
    -d "{
      \"text\": \"サーバー室がアチアチです :fire:\n温度: ${max_temp}℃\n湿度: ${max_humid}%\"
    }"

elif (( $(echo "$max_humid > $threshold_humidity" | bc -l) )); then
  echo "Too humid!"
  curl --request POST "${SLACK_WEBHOOK_URL}" \
    -d "{
      \"text\": \"サーバー室がモワモワです :fire:\n温度: ${max_temp}℃\n湿度: ${max_humid}%\"
    }"
fi
