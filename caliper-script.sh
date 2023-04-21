# Install pre-requisites and setup the env
sudo apt update
sudo apt-get install git -y
sudo apt install nodejs -y
sudo apt-get install build-essential -y
sudo apt install npm -y

# Clone and configure Caliper
git clone https://github.com/hyperledger/caliper-benchmarks.git
cd caliper-benchmarks/
git checkout d02cc8bbc17afda13a0d3af1122d43bfbfc45b0a
npm init -y
npm install --only=prod @hyperledger/caliper-cli@0.4 -y
cd networks/fabric/config_solo_raft/
./generate.sh
cd
cd caliper-benchmarks/
sudo snap install docker -y
sudo docker pull hyperledger/fabric-ccenv:1.4.4
sudo docker tag hyperledger/fabric-ccenv:1.4.4 hyperledger/fabric-ccenv:latest
npm install --save fabric-client fabric-ca-client
curl https://raw.githubusercontent.com/creationix/nvm/v0.25.0/install.sh | bash
source ~/.profile
nvm install 12
tar -xvf Python-2.7.18.tgz
cd Python-2.7.18/
./configure
make
sudo make install
_2.py ...

# Copy the workloads to correct path
cd
cp Caliper/workloads_custom/workload_custom_a.yaml caliper-benchmarks/benchmarks/samples/fabric/marbles
cp Caliper/workloads_custom/workload_custom_b.yaml caliper-benchmarks/benchmarks/samples/fabric/marbles
cp Caliper/workloads_custom/workload_custom_c.yaml caliper-benchmarks/benchmarks/samples/fabric/marbles

cd caliper-benchmarks/  
# Run the tests
sudo npx caliper launch manager --caliper-workspace . --caliper-benchconfig benchmarks/samples/fabric/marbles/workload_custom_a.yaml --caliper-networkconfig networks/fabric/v1/v1.4.4/2org1peercouchdb_raft/fabric-go-tls-solo.yaml >> ../results/Caliper/Caliper_Workload_A.csv
sleep 3000
sudo npx caliper launch manager --caliper-workspace . --caliper-benchconfig benchmarks/samples/fabric/marbles/workload_custom_b.yaml --caliper-networkconfig networks/fabric/v1/v1.4.4/2org1peercouchdb_raft/fabric-go-tls-solo.yaml >> ../results/Caliper/Caliper_Workload_B.csv
sleep 3000
sudo npx caliper launch manager --caliper-workspace . --caliper-benchconfig benchmarks/samples/fabric/marbles/workload_custom_c.yaml --caliper-networkconfig networks/fabric/v1/v1.4.4/2org1peercouchdb_raft/fabric-go-tls-solo.yaml >> ../results/Caliper/Caliper_Workload_C.csv
sleep 3000

cd ..

## Cleaning up everything
deactivate
rm -rf caliper-benchmarks