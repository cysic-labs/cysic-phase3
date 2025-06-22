#!/bin/bash

# 检查是否传入了参数
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <claim_reward_address>"
  exit 1
fi

CLAIM_REWARD_ADDRESS=$1

# 第一段命令：删除旧的cysic-verifier目录，创建新的目录，并下载必要的文件
rm -rf ~/cysic-verifier
cd ~
mkdir cysic-verifier
if [[ $(uname -m) == "x86_64" ]]; then
  # Intel chip
  # M series chip
  curl -L https://github.com/cysic-labs/cysic-phase3/releases/download/v1.0.0/verifier_mac_intel >~/cysic-verifier/verifier_mac
else
  # M series chip
  curl -L https://github.com/cysic-labs/cysic-phase3/releases/download/v1.0.0/verifier_mac >~/cysic-verifier/verifier_mac
fi

# 第二段命令：创建配置文件
cat <<EOF >~/cysic-verifier/config.yaml
# Not Change
chain:
  # Not Change
  # endpoint: "node-pre.prover.xyz:80"
  endpoint: "grpc-testnet.prover.xyz:80"
  # Not Change
  chain_id: "cysicmint_9001-1"
  # Not Change
  gas_coin: "CYS"
  # Not Change
  gas_price: 10
  # Modify Here：! Your Address (EVM) submitted to claim rewards
claim_reward_address: "$CLAIM_REWARD_ADDRESS"

server:
  # don't modify this
  cysic_endpoint: "https://ws-pre.prover.xyz"
  verify_endpoint: "http://verifier-rpc.prover.xyz:50052"
EOF

# 第三段命令：设置执行权限并启动verifier
cd ~/cysic-verifier/
chmod +x ~/cysic-verifier/verifier_mac
echo "DYLD_LIBRARY_PATH=. CHAIN_ID=534352 ./verifier_mac" >~/cysic-verifier/start.sh
chmod +x ~/cysic-verifier/start.sh
