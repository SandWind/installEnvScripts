#!/usr/bin/env bash

###################################################################################
# 控制台颜色
BLACK="\033[1;30m"
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
PURPLE="\033[1;35m"
CYAN="\033[1;36m"
RESET="$(tput sgr0)"
##########################################################################cd#########

printf "${BLUE}\n"
cat << EOF
###################################################################################
# 采用编译方式安装 Redis
# @system: 适用于 sandwind
# @author: pengding
###################################################################################
EOF
printf "${RESET}\n"

command -v apt > /dev/null 2>&1 || {
	printf "${RED}Require yum but it's not installed.${RESET}\n";
	exit 1;
}

printf "\n${GREEN}>>>>>>>> install redis begin${RESET}\n"

if [[ $# -lt 1 ]] || [[ $# -lt 2 ]] || [[ $# -lt 3 ]] || [[ $# -lt 4 ]]; then
	printf "${PURPLE}[Hint]\n"
	printf "\t Usage: sh redis-install.sh [version] [port] [password] \n"
	printf "\t Default: sh redis-install.sh 5.0.7 6379 <null> \n"
	printf "\t Example: sh redis-install.sh 5.0.7 6379 123456 \n"
	printf "${RESET}\n"
fi

version=5.0.12
if [[ -n $1 ]]; then
	version=$1
fi

port=6379
if [[ -n $2 ]]; then
	port=$2
fi


password=
if [[ -n $3 ]]; then
	password=$3
fi
read -p "请设置密码: " password

# install info
printf "${PURPLE}[Install Info]\n"
printf "\t version = ${version}\n"
printf "\t port = ${port}\n"
printf "\t password = ${password}\n"
printf "${RESET}\n"

printf "${CYAN}>>>> install required libs${RESET}\n"
sudo apt-get install -y make gcc g++  openssl libssl-dev

# download and decompression
printf "${CYAN}>>>> download redis${RESET}\n"
temp="/tmp/"
path="/opt/"
mkdir -p ${temp}
##curl -o ${temp}/redis-${version}.tar.gz http://download.redis.io/releases/redis-${version}.tar.gz
cp redis-${version}.tar.gz ${temp}
cd ${temp}
tar zxvf  ${temp}redis-${version}.tar.gz -C ${temp}
mv ${temp}redis-${version} ${path}
cd -
# configure and makefile
printf "${CYAN}>>>> compile redis${RESET}\n"
cd ${path}redis-${version}
make && make install 
cd -
cp ${path}redis-${version}/redis.conf /etc/redis.conf.default
rm -rf ${path}redis-${version}

printf "${CYAN}>>>> modify redis config${RESET}\n"
cp redis.conf /etc/redis.conf
chmod +x /etc/redis.conf
sed -i "s/^port 6379/port ${port}/g" /etc/redis.conf

if [[ -n ${password} ]]; then
	sed -i "s/^protected-mode no/protected-mode yes/g" /etc/redis.conf
	sed -i "s/^# requirepass/requirepass ${password}/g" /etc/redis.conf
fi

printf "\n${CYAN}>>>> open redis port in firewall${RESET}\n"
firewall-cmd --zone=public --add-port=${port}/tcp --permanent
firewall-cmd --reload

# setting systemd service
printf "${CYAN}>>>> set redis as a systemd service${RESET}\n"
chmod +x redis.service
cp redis.service /usr/lib/systemd/system/
chmod +x /usr/lib/systemd/system/redis.service
mkdir -p /var/log/redis
touch /var/log/redis/redis-server.log
chmod 777 /var/log/redis/redis-server.log
mkdir -p /run/redis/
chmod 777 /run/redis
mkdir -p  /var/lib/redis
chmod 777 /var/lib/redis
# boot redis
printf "${CYAN}>>>> start redis${RESET}\n"
systemctl enable redis.service
systemctl start redis.service

printf "\n${GREEN}<<<<<<<< install redis end${RESET}\n"
printf "\n${PURPLE}redis service status: ${RESET}\n"
systemctl status redis
systemctl daemon-reload
  
