#initSShConfig
read -p "请输入端口号: " port
sed -i 's/#Port 22/Port '$port'/' /etc/ssh/sshd_config
read -p "session保持时间间隔: " keeptime
sed -i 's/#ClientAliveInterval 0/ClientAliveInterval '$keeptime'/' /etc/ssh/sshd_config
read -p "最大连接数: " maxline
sed -i 's/#ClientAliveCountMax 3/ClientAliveCountMax '$maxline'/' /etc/ssh/sshd_config
systemctl restart sshd