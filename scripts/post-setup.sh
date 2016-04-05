#!/usr/bin/env bash

# Pre Setup Scripts.

chown -R vagrant:vagrant /usr/local/bin/composer
chmod g+rwx /usr/local/bin/composer

mkdir -p /home/vagrant/.composer
chown -R vagrant:vagrant /home/vagrant/.composer
chmod -R g+rw /home/vagrant/.composer


#/bin/sed -ie '/.myenvset/ d; $a if [ -f ~/.myenvset ]; then source ~/.myenvset;fi' /home/vagrant/.profile

sudo su - vagrant <<'EOF'
/usr/local/bin/composer global require "laravel/envoy=~1.0"
/usr/local/bin/composer global require "laravel/installer"
/usr/local/bin/composer global require "kherge/box=~2.4" --prefer-source
/usr/local/bin/composer global require psy/psysh:@stable

git clone https://github.com/nickfan/php-vim-setup.git ~/vimset
ln -nfs ~/vimset/.vim ~/.vim && ln -nfs ~/vimset/.vimrc ~/.vimrc && ln -nfs ~/vimset/.gvimrc ~/.gvimrc
ln -nfs ~/vimset/.vimrc_simple ~/.vimrc

sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

chsh -s /bin/zsh

/bin/sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="ys"/g' /home/vagrant/.zshrc
/bin/sed -i 's/plugins=(git)/plugins=(git composer laravel5 docker github httpie history jsontools last-working-dir web-search npm node catimg zsh-autosuggestions zsh-syntax-highlighting)/g' /home/vagrant/.zshrc
/bin/sed -ie '/.myenvlocal/ d; $a if [ -f ~/.myenvlocal ]; then source ~/.myenvlocal;fi' /home/vagrant/.zshrc
/bin/sed -ie '/.myenvset/ d; $a if [ -f ~/.myenvset ]; then source ~/.myenvset;fi' /home/vagrant/.zshrc

EOF
