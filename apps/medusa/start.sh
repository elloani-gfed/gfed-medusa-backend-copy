#!/bin/sh

set -e

if [ -n "${INFISICAL_TOKEN:-}" ] && [ -z "${INFISICAL_WRAPPED:-}" ]; then
  if ! command -v infisical >/dev/null 2>&1; then
    echo "Infisical CLI not found. Install it in the image or disable INFISICAL_TOKEN."
    exit 1
  fi

  echo "Starting via Infisical..."
  export INFISICAL_WRAPPED=1

  set -- infisical run
  if [ -n "${INFISICAL_PROJECT_ID:-}" ]; then
    set -- "$@" --projectId "$INFISICAL_PROJECT_ID"
  fi
  if [ -n "${INFISICAL_ENV:-}" ]; then
    set -- "$@" --env "$INFISICAL_ENV"
  fi

  exec "$@" --command "chmod +x ./start.sh && ./start.sh"
fi

# Ensure paths referenced by admin build exist inside the container
mkdir -p /apps
ln -sfn /app/apps/medusa /apps/medusa

echo "Publishing medusa-plugin-shopify..."
(
  cd ../../packages/medusa-plugin-shopify
  npx medusa plugin:publish
)

echo "Running database migrations..."
npx medusa db:migrate

echo "Starting Medusa development server..."
pnpm run dev
