#!/bin/bash
trap 'printf "\n";stop' 2
dependencies() {
command -v php > /dev/null 2>&1 || { echo >&2 "I require php but it's not installed. Install it. Aborting."; exit 1; } 
}

stop() {
checkcf=$(ps aux | grep -o "cloudflared" | head -n1)
checkphp=$(ps aux | grep -o "php" | head -n1)
checkssh=$(ps aux | grep -o "ssh" | head -n1)
if [[ $checkcf == *'cloudflared'* ]]; then
pkill -f -2 cloudflared > /dev/null 2>&1
killall -2 cloudflared > /dev/null 2>&1
fi
if [[ $checkphp == *'php'* ]]; then
killall -2 php > /dev/null 2>&1
fi
if [[ $checkssh == *'ssh'* ]]; then
killall -2 ssh > /dev/null 2>&1
fi
exit 1
}

cf_server() {

if [[ -e cloudflared ]]; then
echo "Cloudflared already installed."
else
command -v wget > /dev/null 2>&1 || { echo >&2 "I require wget but it's not installed. Install it. Aborting."; exit 1; }
printf "\e[1;92m[\e[0m+\e[1;92m] Downloading Cloudflared...\n"
arch=$(uname -m)
arch2=$(uname -a | grep -o 'Android' | head -n1)
if [[ $arch == *'arm'* ]] || [[ $arch2 == *'Android'* ]] ; then
wget --no-check-certificate https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm -O cloudflared > /dev/null 2>&1
elif [[ "$arch" == *'aarch64'* ]]; then
wget --no-check-certificate https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 -O cloudflared > /dev/null 2>&1
elif [[ "$arch" == *'x86_64'* ]]; then
wget --no-check-certificate https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cloudflared > /dev/null 2>&1
else
wget --no-check-certificate https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-386 -O cloudflared > /dev/null 2>&1
fi
fi
chmod +x cloudflared
printf "\e[1;92m[\e[0m+\e[1;92m] Starting php server...\n"
php -S 127.0.0.1:3333 index.php> /dev/null 2>&1 &
sleep 2
printf "\e[1;92m[\e[0m+\e[1;92m] Starting cloudflared tunnel...\n"
rm cf.log > /dev/null 2>&1 &
./cloudflared tunnel -url 127.0.0.1:3333 --logfile cf.log > /dev/null 2>&1 &
sleep 10
link=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' "cf.log")
if [[ -z "$link" ]]; then
printf "\e[1;31m[!] Direct link is not generating \e[0m\n"
exit 1
else
printf "\e[1;92m[\e[0m*\e[1;92m] Direct link:\e[0m\e[1;77m %s\e[0m\n" $link
fi
}

hound() {
default_option_server="Y"
read -p $'\n\e[1;93m Do you want to Upload file?\n \e[1;92motherwise it will be forward the port[Default is Y] [Y/N]: \e[0m' option_server
option_server="${option_server:-${default_option_server}}"
if [[ $option_server == "Y" || $option_server == "y" || $option_server == "Yes" || $option_server == "yes" ]]; then
cf_server
sleep 1
else
default_port=8080
read -p $'\n\e[1;93m Enter the port[Default 8080]: \e[0m' port
port="${port:-${default_port}}"
echo $port
sleep 2
printf "\e[1;92m[\e[0m+\e[1;92m] Starting cloudflared tunnel...\n"
rm cf.log > /dev/null 2>&1 &
./cloudflared tunnel -url 127.0.0.1:$port --logfile cf.log > /dev/null 2>&1 &
sleep 10
link=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' "cf.log")
if [[ -z "$link" ]]; then
printf "\e[1;31m[!] Direct link is not generating \e[0m\n"
exit 1
else
printf "\e[1;92m[\e[0m*\e[1;92m] Direct link:\e[0m\e[1;77m %s\e[0m\n" $link
fi

sleep 1
fi
}
dependencies
#cf_server
hound
