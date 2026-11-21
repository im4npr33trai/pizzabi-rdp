
#!/usr/bin/env bash
set -Eeuo pipefail

: "${SSH_PUBLIC_KEY:?SSH_PUBLIC_KEY is required}"

if [[ "$SSH_PUBLIC_KEY" == *$'\n'* ]]; then
    echo "Only one SSH public key is allowed."
    exit 1
fi

KEY_FILE="$(mktemp)"
trap 'rm -f "$KEY_FILE"' EXIT

printf '%s\n' "$SSH_PUBLIC_KEY" > "$KEY_FILE"

if ! ssh-keygen -l -f "$KEY_FILE" >/dev/null 2>&1; then
    echo "Invalid SSH public key."
    exit 1
fi

# Create runtime directories.
install -d -m 0755 /run/sshd
install -d -o remote -g remote -m 0755 \
    /home/remote/workspace

# Configure SSH access.
install -d -o remote -g remote -m 0700 \
    /home/remote/.ssh

install -o remote -g remote -m 0600 \
    "$KEY_FILE" \
    /home/remote/.ssh/authorized_keys

# The workspace is mounted from the GitHub runner.
chown -R remote:remote /home/remote/workspace

# Generate temporary SSH server identity.
ssh-keygen -A

cat > /etc/ssh/sshd_config <<'EOF'
Port 2222
AddressFamily inet
ListenAddress 0.0.0.0

HostKey /etc/ssh/ssh_host_ed25519_key

PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication no
KbdInteractiveAuthentication no
AuthenticationMethods publickey

AllowUsers remote
MaxAuthTries 3
LoginGraceTime 30
MaxSessions 5

StrictModes yes

X11Forwarding no
AllowTcpForwarding no
AllowAgentForwarding no
PermitTunnel no
PermitUserEnvironment no

PermitTTY yes
PermitUserRC no

ClientAliveInterval 300
ClientAliveCountMax 2

UsePAM no
PrintMotd no

Subsystem sftp internal-sftp
EOF

# Validate SSH configuration.
sshd -t

echo "=================================="
echo " Linux Remote Environment Ready"
echo "=================================="
echo "User: remote"
echo "Port: 2222"
echo "Workspace: /home/remote/workspace"
echo "Authentication: Ed25519/public key"
echo "Password login: Disabled"
echo "=================================="

exec /usr/sbin/sshd -D -e
