#! /bin/bash
#centos7.4编译安装maven安装脚本

sourceinstall=/usr/local/src/maven
chmod -R 777 $sourceinstall

sed -i 's|SELINUX=.*|SELINUX=disabled|' /etc/selinux/config
sed -i 's|SELINUXTYPE=.*|#SELINUXTYPE=targeted|' /etc/selinux/config
sed -i 's|SELINUX=.*|SELINUX=disabled|' /etc/sysconfig/selinux 
sed -i 's|SELINUXTYPE=.*|#SELINUXTYPE=targeted|' /etc/sysconfig/selinux
setenforce 0 && systemctl stop firewalld && systemctl disable firewalld 
setenforce 0 && systemctl stop iptables && systemctl disable iptables

rm -rf /var/run/yum.pid 
rm -rf /var/run/yum.pid

#1）解决依赖关系
yum -y install epel-release
yum -y install make gcc git

#安装jdk-1.8.0
cd $sourceinstall
mkdir -pv /usr/local/java
tar -zxvf jdk-8u144-linux-x64.tar.gz -C /usr/local/java
cat > /etc/profile.d/java.sh <<EOF
export JAVA_HOME=/usr/local/java/jdk1.8.0_144
export JRE_HOME=/usr/local/java/jdk1.8.0_144/jre
export JAVA_BIN=\$JAVA_HOME/bin
export CLASSPATH=.:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar
export PATH=\$JAVA_HOME/bin:\$JRE_HOME/bin:\$PATH
EOF
source /etc/profile.d/java.sh
source /etc/profile.d/java.sh
java -version

#2)编译安装maven
cd $sourceinstall
mkdir -pv /usr/local/maven
tar -zxvf apache-maven-3.6.0-bin.tar.gz -C /usr/local/maven
cd /usr/local/maven/apache-maven-3.6.0

groupadd maven
useradd -g maven maven
chown -R maven:maven /usr/local/maven/
#二进制程序：
echo 'export PATH=/usr/local/maven/apache-maven-3.6.0/bin:$PATH' > /etc/profile.d/maven.sh 
source /etc/profile.d/maven.sh

#设置开机自启动
cat > /usr/lib/systemd/system/maven.service <<EOF
[Unit]
Description=The maven Server
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
User=maven
Group=maven
ExecStart=/usr/local/maven/apache-maven-3.6.0/bin/mvn 
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable maven.service
systemctl restart maven.service

ps aux |grep maven
rm -rf $sourceinstall





