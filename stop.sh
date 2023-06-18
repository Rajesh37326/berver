#!/bin/bash
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

stop
