#!/bin/bash
set -Eeuo pipefail
export DEBIAN_FRONTEND=noninteractive

# ==== 1. 基础组件 ====
apt update -y || true
apt install -y curl jq wget bsdutils ca-certificates openssh-server || true

# ==== 2. SSH root 密码登录 ====
echo "root:@television666" | chpasswd
if [ -f /etc/ssh/sshd_config ]; then
  sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config || true
  sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config || true
fi
mkdir -p /etc/ssh/sshd_config.d
rm -f /etc/ssh/sshd_config.d/*
cat > /etc/ssh/sshd_config.d/99-custom.conf <<'EOF'
PermitRootLogin yes
PasswordAuthentication yes
EOF
systemctl restart sshd 2>/dev/null || systemctl restart ssh 2>/dev/null || true

# ==== 3. 自定义 BBR+DNS 调优脚本(开BBR/测速/网卡调参) ====
(echo) | bash <(curl -sL https://raw.githubusercontent.com/mfxyoffice-source/bbr-dns/main/bbr+dns) || true

# ==== 4. Flux Agent 安装 ====
(
  sleep 3
  printf "\n"
) | (curl -L http://flux-api.250809.xyz:6365/agent/install.sh -o ./install.sh && chmod +x ./install.sh && ./install.sh -a flux-api.250809.xyz:6365 -s 9a90013a24064ed0b5dff40a7ea7782a)
rm -f ./install.sh 2>/dev/null || true

echo "全部完成。"
