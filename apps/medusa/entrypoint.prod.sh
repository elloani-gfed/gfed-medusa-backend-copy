#!/bin/sh

set -e

CMD_TO_RUN="pnpm run predeploy && pnpm run start:prod"

if [ -n "${INFISICAL_SERVICE_TOKEN:-}" ] && [ -z "${INFISICAL_TOKEN:-}" ]; then
  export INFISICAL_TOKEN="$INFISICAL_SERVICE_TOKEN"
fi

if [ -n "${INFISICAL_TOKEN:-}" ]; then
  echo "Loading secrets from Infisical..."

  EXTRA_ARGS=""
  if [ -n "${INFISICAL_PROJECT_ID:-}" ]; then
    EXTRA_ARGS="$EXTRA_ARGS --projectId $INFISICAL_PROJECT_ID"
  fi
  if [ -n "${INFISICAL_ENVIRONMENT:-}" ]; then
    EXTRA_ARGS="$EXTRA_ARGS --env $INFISICAL_ENVIRONMENT"
  fi
  if [ -n "${INFISICAL_PATH:-}" ]; then
    EXTRA_ARGS="$EXTRA_ARGS --path $INFISICAL_PATH"
  fi

  exec infisical run $EXTRA_ARGS -- sh -c "$CMD_TO_RUN"
fi

echo "Infisical token not set; running without Infisical secrets."
exec sh -c "$CMD_TO_RUN"
