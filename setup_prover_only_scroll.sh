#!/bin/bash

# 检查是否传入了参数
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <claim_reward_address>"
  exit 1
fi

CLAIM_REWARD_ADDRESS=$1

# 第一段命令：删除旧的cysic-prover目录，创建新的目录，并下载必要的文件
rm -rf ~/cysic-prover
cd ~
mkdir cysic-prover
curl -L https://github.com/cysic-labs/cysic-phase3/releases/download/v1.0.0/prover_linux >~/cysic-prover/prover
curl -L https://github.com/cysic-labs/cysic-phase3/releases/download/v1.0.0/libdarwin_prover.so >~/cysic-prover/libzkp.so
curl -L https://github.com/cysic-labs/cysic-phase3/releases/download/v1.0.0/libcysnet_monitor.so >~/cysic-prover/libcysnet_monitor.so
curl -L https://github.com/cysic-labs/cysic-phase3/releases/download/v1.0.0/librsp.so >~/cysic-prover/librsp.so
curl -L https://github.com/cysic-labs/cysic-phase3/releases/download/v1.0.0/eth_dependency.sh >~/cysic-prover/eth_dependency.sh

# 第二段命令：创建配置文件
cat <<EOF >~/cysic-prover/config.yaml
# Not Change
chain:
  # Not Change
  endpoint: "grpc-testnet.prover.xyz:80"
  # Not Change
  chain_id: "cysicmint_9001-1"
  # Not Change
  gas_coin: "CYS"
  # Not Change
  gas_price: 10
  # Modify Here：! Your Address (EVM) submitted to claim rewards

######################
#   chain  setting   #
######################
asset_path: ~/.cysic/assets
claim_reward_address: "$CLAIM_REWARD_ADDRESS"

server:
  # don't modify this
  cysic_endpoint: "https://ws-pre.prover.xyz"
available_task_type:
  - scroll

EOF

# 第三段命令：设置执行权限并启动verifier
cd ~/cysic-prover/
chmod +x ~/cysic-prover/prover
echo "SP1_PROVER=cuda LD_LIBRARY_PATH=. CHAIN_ID=534352 ./prover" >~/cysic-prover/start.sh
chmod +x ~/cysic-prover/start.sh

# 询问用户是否运行 eth_dependency.sh
read -p "do you want to setup the software env for eth proof, this will install sp1, cuda driver and docker for you. (y/n): " choice
case "$choice" in
    y|Y )
        bash eth_dependency.sh
        ;;
    n|N )
        echo "skip to run the eth_dependency.sh"
        ;;
    * )
        echo "invalid choice input eth_dependency.sh"
        ;;
esac

echo "Cysic prover setup is complete. Run ./start.sh to start the prover."
