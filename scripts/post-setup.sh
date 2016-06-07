#!/usr/bin/env bash

# Post Setup Scripts.

#export http_proxy="127.0.0.1:1984"
#export https_proxy="127.0.0.1:1984"
#export ftp_proxy="127.0.0.1:1984"
#export no_proxy="localhost,127.0.0.1,.example.com"

#npm install -g cnpm --registry=https://registry.npm.taobao.org

chown -R vagrant:vagrant /usr/local/bin
chmod g+rwx /usr/local/bin

/usr/local/bin/composer config -g secure-http false

#unset http_proxy
#unset https_proxy
#unset ftp_proxy
#unset no_proxy

mkdir -p /home/vagrant/.composer
chown -R vagrant:vagrant /home/vagrant/.composer
chmod -R g+rw /home/vagrant/.composer



sudo su - vagrant <<'EOF'

git clone https://github.com/nickfan/php-vim-setup.git ~/vimset
ln -nfs ~/vimset/.vim ~/.vim && ln -nfs ~/vimset/.vimrc ~/.vimrc && ln -nfs ~/vimset/.gvimrc ~/.gvimrc
ln -nfs ~/vimset/.vimrc_simple ~/.vimrc

sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

#chsh -s /bin/zsh

/bin/sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="ys"/g' /home/vagrant/.zshrc
/bin/sed -i 's/plugins=(git)/plugins=(git composer laravel5 docker github httpie history jsontools last-working-dir web-search npm node catimg zsh-autosuggestions zsh-syntax-highlighting)/g' /home/vagrant/.zshrc
/bin/sed -i -e '/.myenvset/ d; $a if [ -f ~/.myenvset ]; then source ~/.myenvset;fi' /home/vagrant/.zshrc
/bin/sed -i -e '/.myenvlocal/ d; $a if [ -f ~/.myenvlocal ]; then source ~/.myenvlocal;fi' /home/vagrant/.zshrc

EOF
cp -rf /home/vagrant/vimset /root/
ln -nfs /root/vimset/.vim /root/.vim
ln -nfs /root/vimset/.gvimrc /root/.gvimrc
ln -nfs /root/vimset/.vimrc_simple /root/.vimrc

sudo chsh vagrant -s $(which zsh)

/bin/sed -i -e '/.myenvset/ d; $a if [ -f ~/.myenvset ]; then source ~/.myenvset;fi' /home/vagrant/.profile
/bin/sed -i -e '/.myenvlocal/ d; $a if [ -f ~/.myenvlocal ]; then source ~/.myenvlocal;fi' /home/vagrant/.profile

sudo su - vagrant <<'EOF'

wget https://phar.phpunit.de/phpunit.phar -O /home/vagrant/var/tmp/phpunit.phar
chmod +x /home/vagrant/var/tmp/phpunit.phar

EOF
mv /home/vagrant/var/tmp/phpunit.phar /usr/local/bin/phpunit
chmod +x /usr/local/bin/phpunit
chown -R vagrant:vagrant /usr/local/bin/phpunit
chmod g+rwx /usr/local/bin/phpunit

sudo su - vagrant <<'EOF'
/usr/local/bin/composer config -g secure-http false
/usr/local/bin/composer config -g repo.packagist composer https://packagist.phpcomposer.com
/usr/local/bin/composer self-update

/usr/local/bin/composer global require "kherge/box=~2.4" --prefer-source
/usr/local/bin/composer global require "laravel/envoy=~1.0"
/usr/local/bin/composer global require "laravel/installer"
/usr/local/bin/composer global require psy/psysh:@stable


EOF