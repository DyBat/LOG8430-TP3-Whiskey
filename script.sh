#Install pre-requisites and setup the env
sudo apt update
sudo apt-get install git -y
sudo apt-get install default-jre -y
sudo apt install default-jdk -y
sudo apt-get install maven -y
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
sudo apt-get install curl -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
apt-cache policy docker-ce
sudo apt install docker-ce -y
sudo usermod -aG docker ${USER}
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
curl -O --location https://github.com/brianfrankcooper/YCSB/releases/download/0.17.0/ycsb-0.17.0.tar.gz

# clone the repo for benchmarking
git clone http://github.com/brianfrankcooper/YCSB.git
cd YCSB
# mvn -pl site.ycsb:redis-binding -am clean package

cd ..

## Run the container for Mongo DB and run the tests
printf "\nRunning Benchmarks on Mongo DB, results can be found in the Mongo folder \n\n"
docker-compose -f Mongo/docker-compose.yml up -d
docker exec -it primary mongosh --eval "rs.initiate({
 _id: \"myReplicaSet\",
 members: [
   {_id: 0, host: \"192.168.5.2:27017\"},
   {_id: 1, host: \"192.168.5.3:27017\"},
   {_id: 2, host: \"192.168.5.4:27017\"},
   {_id: 3, host: \"192.168.5.5:27017\"}
 ]
})"
sleep 120
cd YCSB
for i in {1..3}
do
printf "\n##################################################################################\n" >> ../Mongo/outputLoadAsyncMongo.csv
printf "Loading workoad A try $i\n" >> ../Mongo/outputLoadAsyncMongo.csv
./bin/ycsb load mongodb -s -P workloads/workload_custom_a -p recordcount=1000 -p mongodb.upsert=true -p mongodb.url=mongodb://primary:27017,secondary1:27017,secondary2:27017,secondary3:27017/?replicaSet=myReplicaSett >> ../Mongo/outputLoadAsyncMongo.csv
printf "\n##################################################################################\n" >> ../Mongo/outputRunAsyncMongo.csv
printf "Running test workoad A try $i\n" >> ../Mongo/outputRunAsyncMongo.csv
./bin/ycsb run mongodb -s -P workloads/workload_custom_a -p recordcount=1000 -p mongodb.upsert=true -p mongodb.url=mongodb://primary:27017,secondary1:27017,secondary2:27017,secondary3:27017/?replicaSet=myReplicaSe >> ../Mongo/outputRunAsyncMongo.csv

printf "\n##################################################################################\n" >> ../Mongo/outputLoadAsyncMongo.csv
printf "Loading workoad B try $i\n" >> ../Mongo/outputLoadAsyncMongo.csv
./bin/ycsb load mongodb -s -P workloads/workload_custom_b -p recordcount=1000 -p mongodb.upsert=true -p mongodb.url=mongodb://primary:27017,secondary1:27017,secondary2:27017,secondary3:27017/?replicaSet=myReplicaSett >> ../Mongo/outputLoadAsyncMongo.csv
printf "\n##################################################################################\n" >> ../Mongo/outputRunAsyncMongo.csv
printf "Running test workoad B try $i\n" >> ../Mongo/outputRunAsyncMongo.csv
./bin/ycsb run mongodb -s -P workloads/workload_custom_b -p recordcount=1000 -p mongodb.upsert=true -p mongodb.url=mongodb://primary:27017,secondary1:27017,secondary2:27017,secondary3:27017/?replicaSet=myReplicaSe >> ../Mongo/outputRunAsyncMongo.csv

printf "\n##################################################################################\n" >> ../Mongo/outputLoadAsyncMongo.csv
printf "Loading workoad C try $i\n" >> ../Mongo/outputLoadAsyncMongo.csv
./bin/ycsb load mongodb -s -P workloads/workload_custom_c -p recordcount=1000 -p mongodb.upsert=true -p mongodb.url=mongodb://primary:27017,secondary1:27017,secondary2:27017,secondary3:27017/?replicaSet=myReplicaSett >> ../Mongo/outputLoadAsyncMongo.csv
printf "\n##################################################################################\n" >> ../Mongo/outputRunAsyncMongo.csv
printf "Running test workoad C try $i\n" >> ../Mongo/outputRunAsyncMongo.csv
./bin/ycsb run mongodb -s -P workloads/workload_custom_c -p recordcount=1000 -p mongodb.upsert=true -p mongodb.url=mongodb://primary:27017,secondary1:27017,secondary2:27017,secondary3:27017/?replicaSet=myReplicaSe >> ../Mongo/outputRunAsyncMongo.csv

done
cd ..
docker-compose -f Mongo/docker-compose.yml down -v
printf "\nFinished benchmarking Mongo DB with YCSB \n\n"
#
####========================================================================##
## Cleaning up everything
deactivate
rm -rf YCSB
