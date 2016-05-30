#!/usr/bin/env bash

# Pre Setup Scripts.

echo "vagrant    ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/80-webservice-init-users

/bin/sed -ie '/LANG=/c LANG="zh_CN.UTF-8"' /etc/default/locale
/bin/sed -ie '/LANGUAGE=/c LANGUAGE="zh_CN:zh"' /etc/default/locale

locale-gen zh_CN.UTF-8 en_US.UTF-8

cp -af /etc/apt/sources.list /etc/apt/sources.list.orig_bak
/bin/sed -i 's/us.archive/cn.archive/g' /etc/apt/sources.list
cp -af /etc/apt/sources.list /etc/apt/sources.list.cn_offical

cat >/etc/apt/sources.list.cn_163 <<'EOF'

deb http://mirrors.163.com/ubuntu/ trusty main restricted universe multiverse
deb http://mirrors.163.com/ubuntu/ trusty-security main restricted universe multiverse
deb http://mirrors.163.com/ubuntu/ trusty-updates main restricted universe multiverse
deb http://mirrors.163.com/ubuntu/ trusty-proposed main restricted universe multiverse
deb http://mirrors.163.com/ubuntu/ trusty-backports main restricted universe multiverse
deb-src http://mirrors.163.com/ubuntu/ trusty main restricted universe multiverse
deb-src http://mirrors.163.com/ubuntu/ trusty-security main restricted universe multiverse
deb-src http://mirrors.163.com/ubuntu/ trusty-updates main restricted universe multiverse
deb-src http://mirrors.163.com/ubuntu/ trusty-proposed main restricted universe multiverse
deb-src http://mirrors.163.com/ubuntu/ trusty-backports main restricted universe multiverse

EOF

cp -af /etc/apt/sources.list.cn_163 /etc/apt/sources.list

apt-get update -y

/bin/sed -i 's/^zend_extension/;zend_extension/g' /etc/php/7.0/mods-available/xdebug.ini
/bin/sed -i 's/^zend_extension/;zend_extension/g' /etc/php/5.6/mods-available/xdebug.ini

apt-get install -y zsh

cat >/home/vagrant/.myenvset <<'EOF'
# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias vi='vim'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

alias cnpm="npm --registry=https://registry.npm.taobao.org"

export LANG="zh_CN.UTF-8"
export LC_ALL="zh_CN.UTF-8"
export EDITOR="vim"
export PATH="$PATH:$HOME/.composer/vendor/bin:$HOME/bin"

export PYTHONPATH=$PYTHONPATH

proxy_enable() {
    export http_proxy="127.0.0.1:1984"
    export https_proxy="127.0.0.1:1984"
    export ftp_proxy="127.0.0.1:1984"
    export no_proxy="localhost,127.0.0.1,.example.com"
}

proxy_disable() {
    unset http_proxy
    unset https_proxy
    unset ftp_proxy
    unset no_proxy
}
EOF

apt-get install -y privoxy proxychains supervisor

/bin/sed -ie '$a forward-socks5 / 127.0.0.1:1080 .' /etc/privoxy/config
/bin/sed -ie '$a listen-address  0.0.0.0:1984' /etc/privoxy/config
/bin/sed -i 's/^socks4/#socks4/g' /etc/proxychains.conf
/bin/sed -ie '$a socks5    127.0.0.1 1080' /etc/proxychains.conf
service privoxy restart

apt-get install -y python-pip
pip install shadowsocks

mkdir -p /home/vagrant/etc/supervisor/conf.d
mkdir -p /home/vagrant/bin
mkdir -p /home/vagrant/var/log
mkdir -p /home/vagrant/var/run
mkdir -p /home/vagrant/var/tmp
chown -R vagrant:vagrant /home/vagrant/bin
chmod -R g+rwx /home/vagrant/bin
chown -R vagrant:vagrant /home/vagrant/etc
chmod -R g+rw /home/vagrant/etc
chown -R vagrant:vagrant /home/vagrant/var
chmod -R g+rw /home/vagrant/var


cat >/home/vagrant/etc/shadowsocks.json <<'EOF'
{
    "server":"HK2.ISS.TF",
    "server_port":8989,
    "local_address":"0.0.0.0",
    "local_port":1080,
    "password":"lastpasswd",
    "timeout":600,
    "method":"aes-256-cfb"
}
EOF
chown -R vagrant:vagrant /home/vagrant/etc/shadowsocks.json
chmod -R g+rw /home/vagrant/etc/shadowsocks.json

cat >/home/vagrant/bin/upssinfo.sh <<'EOF'
#!/usr/bin/env bash

sscontent_subdata=`curl -sL http://www.ishadowsocks.net/ |tr '\n' ' ' | grep -Eo '<h4>A服务器地址:[^状态]+<h4>状态'`;
if [ ${#sscontent_subdata} -gt 0 ]; then

    sscontent_server=`echo "$sscontent_subdata" |grep -Eo '<h4>A服务器地址:[^<]+</h4>' |grep -Eo ':[^<]+'`;
    last_ssserver=`expr substr "$sscontent_server" 2 ${#sscontent_server}`;

    sscontent_port=`echo "$sscontent_subdata" |grep -Eo '<h4>端口:[^<]+</h4>' |grep -Eo ':[^<]+'`;
    last_ssport=`expr substr "$sscontent_port" 2 ${#sscontent_port}`;

    sscontent_passwd=`echo "$sscontent_subdata" |grep -Eo '<h4>B密码:[^<]+</h4>' |grep -Eo ':[^<]+'`;
    last_sspasswd=`expr substr "$sscontent_passwd" 2 ${#sscontent_passwd}`;

    sscontent_method=`echo "$sscontent_subdata" |grep -Eo '<h4>加密方式:[^<]+</h4>' |grep -Eo ':[^<]+'`;
    last_ssmethod=`expr substr "$sscontent_method" 2 ${#sscontent_method}`;


    #echo "got ss server: $last_ssserver";
    #echo "got ss server_port: $last_ssport";
    #echo "got ss passwd: $last_sspasswd";
    #echo "got ss method: $last_ssmethod";

    sed -ie "/\"server\":/c \"server\":\"${last_ssserver}\"\," /home/vagrant/etc/shadowsocks.json;
    sed -ie "/\"server_port\":/c \"server_port\":\"${last_ssport}\"\," /home/vagrant/etc/shadowsocks.json;
    sed -ie "/\"password\":/c \"password\":\"${last_sspasswd}\"\," /home/vagrant/etc/shadowsocks.json;
    sed -ie "/\"method\":/c \"method\":\"${last_ssmethod}\"" /home/vagrant/etc/shadowsocks.json;
else
    echo "match subdata content length: ${#sscontent_subdata} ";
fi
EOF
chown -R vagrant:vagrant /home/vagrant/bin/upssinfo.sh
chmod -R g+rwx /home/vagrant/bin/upssinfo.sh
mkdir -p /etc/cron.d 2>/dev/null
ssupdateinfocron="#0 */2 * * * vagrant /bin/bash /home/vagrant/bin/upssinfo.sh >> /dev/null 2>&1"
echo "$ssupdateinfocron" > "/etc/cron.d/ssupdateinfo"
service cron restart

sudo su - vagrant <<'EOF'
chmod +x /home/vagrant/bin/upssinfo.sh
/bin/bash /home/vagrant/bin/upssinfo.sh
EOF


cat >/home/vagrant/etc/supervisor/conf.d/sslocal.conf <<'EOF'
[program:sslocal]
command=/usr/local/bin/sslocal -c /home/vagrant/etc/shadowsocks.json --pid-file /home/vagrant/var/run/shadowsocks.pid --log-file /home/vagrant/var/log/shadowsocks.log
directory=/home/vagrant/var/log/
process_name=%(program_name)s_%(process_num)02d
numprocs=1
startsecs=5
exitcodes=2
autostart=true
autorestart=true
stopsignal=KILL
killasgroup=true
stopasgroup=true
user=vagrant
;redirect_stderr=true
stdout_logfile=/home/vagrant/var/log/supervisor-shadowsocks-out.log
stdout_logfile_maxbytes = 10MB
stderr_logfile=/home/vagrant/var/log/supervisor-shadowsocks-err.log
stderr_logfile_maxbytes = 10MB
environment=HOME="/home/vagrant"
EOF
chown -R vagrant:vagrant /home/vagrant/etc/supervisor/conf.d/sslocal.conf
chmod -R g+rw /home/vagrant/etc/supervisor/conf.d/sslocal.conf

/bin/sed -i 's/files = /;files = /g' /etc/supervisor/supervisord.conf
/bin/sed -ie '$a files = /home/vagrant/etc/supervisor/conf.d/*.conf' /etc/supervisor/supervisord.conf

service supervisor restart
