#!/bin/bash

# jm33_m0

echo '
[+] Welcome!
I will guide you through the installation of Shadowsocks-Plus on your Linux server
Also, if you wanna add some users later, I will download another script called ss_add_api.sh, you might wanna use it in the future
'

grep 'CentOS Linux' /etc/os-release > /dev/null
if [ $? -eq 0 ]; then
    echo '
[!] Warning: This script has been tested on CentOS and proved not working, if you insist to use Shadowsocks-Plus on this server, you can search for a docker image that contains ssp or go ahead and fix this issue yourself (if you fixed that, please lemme know)
'
fi

echo '[*] Installing Shadowsocks-Plus...
'
if test -e /usr/bin/ssp-server; then
    echo '[*] Shadowsocks-Plus has already been installed
    '
    exit 0
fi

# Download user manager
if ! test -e /usr/bin/loadUserDatabase; then
    curl -s -k -o /usr/bin/loadUserDatabase "https://github.com/jm33-m0/gfw_scripts/raw/master/ssplus/loadUserDatabase" && chmod 755 /usr/bin/loadUserDatabase
fi

# Download ssp-server and install it to /usr/bin
curl -s -k -o ssp-server https://raw.githubusercontent.com/shadowsocks-plus/shadowsocks-plus/master/builds/server && chmod 755 ssp-server && cp ssp-server /usr/bin/

if test -e /usr/bin/ssp-server; then
    echo '[+] Installation succeeded
    '
else
    echo '[-] Failed to install
    '
    exit 1
fi

# Download ss_add_api.sh to add first Shadowsocks-Plus user and launch a base ssp instance with HTTP API
echo '[*] Lets create our first Shadowsocks user account
'
url="https://raw.githubusercontent.com/jm33-m0/gfw_scripts/master/ssplus/ss_add_api.sh"
if ! test -e ./ss_add_api.sh; then
    curl -s -k -o ss_add_api.sh $url && chmod 755 ss_add_api.sh
fi

if ! test -e ~/ss; then
    echo "
[*] Creating Shadowsocks folder at $HOME/ss ...
"
    mkdir -p ~/ss
fi
path=~/ss

echo -n "[*] Setup an API key for further user management with ss_add_api.sh: "
read api_key


echo '
[*] Writing config.json...
'
cat << EOF > $path/config.json
{
    "server":"0.0.0.0",
    "method":"aes-256-cfb",
    "server_port":54320,
    "password":"doNotTouch"
}
EOF

# start instance
if [ $? -eq 0 ]; then
	echo 'nohup ssp-server -c '$path'/config.json -api 127.0.0.1:5333 -hkey '$api_key' > /dev/null &' > $path/ss-run.sh
	chmod 755 $path/ss-run.sh
	bash $path/ss-run.sh
else
    echo "[!] Yea I am bored..."
fi

# Run ss_add to add a user
./ss_add_api.sh -i
