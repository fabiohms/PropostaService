#!/bin/sh
set -e

# Function to read secrets (sanitize CR/LF)
read_secret() {
    secret_name="$1"
    secret_file="/run/secrets/$secret_name"

    if [ -f "$secret_file" ]; then
        # Strip CR and LF to avoid invalid credentials caused by Windows EOL
        value=$(tr -d '\r\n' < "$secret_file")
        printf '%s' "$value"
    else
        echo ""
    fi
}

# Read secrets if they exist
RABBITMQ_USER=$(read_secret "rabbitmq_user")
RABBITMQ_PASS=$(read_secret "rabbitmq_password")

# Set default values if secrets are not available
if [ -n "$RABBITMQ_USER" ] && [ -n "$RABBITMQ_PASS" ]; then
    export RABBITMQ_DEFAULT_USER="$RABBITMQ_USER"
    export RABBITMQ_DEFAULT_PASS="$RABBITMQ_PASS"
    echo "Using credentials from Docker secrets"
else
    export RABBITMQ_DEFAULT_USER="${RABBITMQ_DEFAULT_USER:-guest}"
    export RABBITMQ_DEFAULT_PASS="${RABBITMQ_DEFAULT_PASS:-guest}"
    echo "Using default credentials"
fi

echo "Starting RabbitMQ with user: $RABBITMQ_DEFAULT_USER"

# Execute the original entrypoint explicitly by path
exec /usr/local/bin/docker-entrypoint.sh "$@"
