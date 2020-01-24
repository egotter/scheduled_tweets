yum update -y

# https://dev.mysql.com/downloads/repo/yum/
rpm -ivh https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm
yum remove -y mariadb-libs
yum install -y mysql-community-server mysql-community-devel
sudo mysqld --initialize-insecure
sudo mysql_secure_installation
# systemctl start mysqld

rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
yum --enablerepo=remi install -y redis
# systemctl start redis

cat << EOS >>/etc/yum.repos.d/nginx.repo
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/7/\$basearch/
gpgcheck=0
enabled=1
EOS
yum install -y nginx
cp ./setup/nginx.conf /etc/nginx/conf.d/scheduled_tweets.conf
# systemctl start nginx

yum groupinstall -y "Development Tools"
yum install -y git tmux dstat htop monit tree nginx
yum install -y openssl-devel libyaml-devel libffi-devel readline-devel zlib-devel gdbm-devel ncurses-devel

# Install ruby2.7.0
# https://github.com/egotter/egotter/wiki/Install-Ruby

yum install -y ruby-devel

cat << EOS >>/etc/security/limits.conf
root soft nofile 65536
root hard nofile 65536
* soft nofile 65536
* hard nofile 65536
EOS

echo "net.ipv4.tcp_max_syn_backlog = 512" >>/etc/sysctl.conf
echo "net.core.somaxconn = 512" >>/etc/sysctl.conf
echo "vm.overcommit_memory = 1" >>/etc/sysctl.conf
sysctl -p

echo "echo never > /sys/kernel/mm/transparent_hugepage/enabled" >>/etc/rc.local

git clone https://github.com/egotter/scheduled_tweets.git
chown -R ec2-user:ec2-user scheduled_tweets
# cd scheduled_tweets

bundle config set path '.bundle'
bundle config set without 'test development'
bundle install

amazon-linux-extras install -y epel

curl --silent --location https://rpm.nodesource.com/setup_10.x | bash -
wget https://dl.yarnpkg.com/rpm/yarn.repo -O /etc/yum.repos.d/yarn.repo
yum install -y nodejs yarn

yarn install --check-files
# Copy config/master.key and .env
RAILS_ENV=production bundle exec rails db:create db:migrate assets:precompile

bundle exec rails s -e production

