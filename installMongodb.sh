#!/bin/bash
sudo apt-get install gnupg -y
wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -
verstr=$(lsb_release -dc)
codename=""
echo $verstr    
if [[ $verstr =~ "focal" ]]
then
    codename="focal"  
elif [[ $verstr =~ "bionic" ]]
then
   codename="bionic" 
elif [[ $verstr =~ "xenial" ]]
then
    codename="xenial" 
fi
echo "执行$codename 安装"
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu $codename/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list
sudo apt-get update
sudo apt-get install -y mongodb-org=4.4.4 mongodb-org-server=4.4.4 mongodb-org-shell=4.4.4 mongodb-org-mongos=4.4.4 mongodb-org-tools=4.4.4
systemctl start  mongod
sleep 3
systemctl enable mongod
result=$(systemctl|grep mongo)
echo $result
result=$(ps aux|grep mongo)
echo $result
if [[ $result =~ "mongod" ]] 
then
   mongo initMongodb.js
fi

sed -i 's/#security:/security:\n  authorization: enabled/g' /etc/mongod.conf

systemctl restart mongod