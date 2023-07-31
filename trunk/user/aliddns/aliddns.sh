#!/bin/sh
#copyright by hiboy
D="/etc/storage/cron/crontabs"
F="$D/`nvram get http_username`"
aliddns_enable=`nvram get aliddns_enable`
[ -z $aliddns_enable ] && aliddns_enable=0 && nvram set aliddns_enable=0
aliddns_ttl=`nvram get aliddns_ttl`
daji=`nvram get aliddns_interval`
[ -z $daji ] && daji="0" && nvram set aliddns_interval="$daji"
[ ! -d /etc/storage/lucky ] && mkdir -p /etc/storage/lucky
[ -z $aliddns_ttl ] && aliddns_ttl="-c /etc/storage/lucky/lucky.conf" && nvram set aliddns_ttl="$aliddns_ttl"
lucky="/tmp/lucky/lucky"
[ ! -d /tmp/lucky ] && mkdir -p /tmp/lucky

aliddns_check () {
if [ "$aliddns_enable" = "1" ] && [ -z "`pidof lucky`" ] ; then
	logger -t "lucky" "重新启动"
 aliddns_close
 aliddns_start
fi
if [ "$aliddns_enable" = "0" ] ; then	
aliddns_close				
fi
}

aliddns_keep () {
logger -t "lucky" "守护进程启动"
sed -Ei '/lucky守护进程|^$/d' "$F"
cat >> "$F" <<-OSC
*/1 * * * * test -z "\`pidof lucky\`"  && aliddns.sh check & #lucky守护进程
OSC
}

kill_ps () {
sleep 20
aliddns_start
}

aliddns_close () {
sed -Ei '/lucky守护进程|^$/d' "$F"
killall lucky
killall -9 lucky
sleep 5
[ -z "`pidof lucky`" ] && logger -t "lucky" "进程已关闭"
}

aliddns_start () {
if [ "$aliddns_enable" = "0" ] ; then	
aliddns_close				
fi
logger -t "lucky" "正在启动"
sed -Ei '/lucky守护进程|^$/d' "$F"
killall lucky
killall -9 lucky
[ -f /etc/storage/bin/lucky ] && lucky="/etc/storage/bin/lucky"
if [ ! -s "$lucky" ] ; then
logger -t "luckyo" "未找到$lucky ，开始下载"
[ "$daji" = "0" ]  && curl -L -k -S -o  "$lucky" --connect-timeout 10 --retry 3 "https://fastly.jsdelivr.net/gh/lmq8267/Padavan-KVR-k2p@releases/download/lucky/lucky"
[ "$daji" = "1" ]  && curl -L -k -S -o  "$lucky" --connect-timeout 10 --retry 3 "https://fastly.jsdelivr.net/gh/lmq8267/Padavan-KVR-k2p@releases/download/lucky/luckydaji"
chmod 777 "$lucky"
[[ "$($lucky -h 2>&1 | wc -l)" -lt 2 ]] && rm -rf $lucky
fi
if [ ! -s "$lucky" ] ; then
logger -t "luckyo" "下载失败，重新下载"
[ "$daji" = "0" ]  && curl -L -k -S -o  "$lucky" --connect-timeout 10 --retry 3 "https://github.com/lmq8267/Padavan-KVR-k2p/releases/download/lucky/lucky"
[ "$daji" = "1" ]  && curl -L -k -S -o  "$lucky" --connect-timeout 10 --retry 3 "https://github.com/lmq8267/Padavan-KVR-k2p/releases/download/lucky/luckydaji"
fi
chmod 777 "$lucky"
luckyver=$($lucky -info | grep "Version" | awk -F 'Version' '{print $2}'| tr -d 'A-Z' | tr -d 'a-z' | tr -d ":" | tr -d "," | tr -d '"')
[[ "$($lucky -h 2>&1 | wc -l)" -lt 2 ]] && logger -t "lucky" "程序不完整，重新下载" && rm -rf $lucky && kill_ps
 $lucky $aliddns_ttl >/tmp/lucky/lucky.log &
sleep 8
[ ! -z "`pidof lucky`" ] && logger -t "lucky" "lucky_$luckyver 启动成功"
[ -z "`pidof lucky`" ] && logger -t "lucky" "启动失败，看看哪里的问题，20秒后尝试重新启动" && kill_ps
port=$(cat /tmp/lucky/lucky.log | grep "后台登录网址:" | awk '{print$4}' | tr -d " " | awk -F ':' '{print $3}' )
ipaddr=`nvram get lan_ipaddr`
if [ ! -z "$port" ] ; then
nvram set luckyip="http://${ipaddr}:${port}"
else
nvram set luckyip=""
fi
aliddns_keep
exit 0
}


case $1 in
start)
	aliddns_start
	;;
check)
	aliddns_check
	;;
stop)
	aliddns_close
	;;
keep)
	aliddns_keep
	;;
*)
	aliddns_check
	;;
esac
