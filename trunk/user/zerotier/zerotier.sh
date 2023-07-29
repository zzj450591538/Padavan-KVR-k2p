#!/bin/sh
#20200426 chongshengB
#20210410 xumng123
PROG=/etc/storage/bin/zerotier-one
PROGCLI=/etc/storage/bin/zerotier-cli
PROGIDT=/etc/storage/bin/zerotier-idtool
config_path="/etc/storage/zerotier-one"
PLANET="/etc/storage/zerotier-one/planet"
D="/etc/storage/cron/crontabs"
F="$D/`nvram get http_username`"
zerenb=`nvram get zerotier_enable`
zerotier_restart () {
[ "$zerenb" != "1" ] && stop_zero
if [ -z "`pidof zerotier-one`" ] && [ "$zerenb" = "1" ] ; then
    logger -t "ZeroTier" "重新启动"
    stop_zero
    start_zero
fi
}
zerotier_keep  () {
[ ! -z "`pidof zerotier-one`" ] && logger -t "ZeroTier" "启动成功"
logger -t "ZeroTier" "守护进程启动"
sed -Ei '/ZeroTier守护进程|^$/d' "$F"
cat >> "$F" <<-OSC
*/1 * * * * test -z "\`pidof zerotier-one\`" && /etc/storage/zerotier.sh restart #ZeroTier守护进程
OSC
zero_ping &
}
zero_ping() {
while [ "$(ifconfig | grep zt | awk '{print $1}')" = "" ]; do
		sleep 1
done
zt0=$(ifconfig | grep zt | awk '{print $1}')
while [ "$(ip route | grep "dev $zt0  proto static" | awk '{print $1}' | awk -F '/' '{print $1}')" = "" ]; do
sleep 1
done
ip00=$(ip route | grep "dev "$zt0"  proto static" | awk '{print $1}' | awk -F '/' '{print $1}')
[ -n "$ip00" ] && logger -t "ZeroTier" "zerotier局域网内设备$ip00 "
ip11=$(ip route | grep "dev "$zt0"  proto static" | awk '{print $1}' | awk -F '/' '{print $1}'| awk 'NR==1 {print $1}'|cut -d. -f1,2,3)
ip22=$(ip route | grep "dev "$zt0"  proto static" | awk '{print $1}' | awk -F '/' '{print $1}'| awk 'NR==2 {print $1}'|cut -d. -f1,2,3)
ip33=$(ip route | grep "dev "$zt0"  proto static" | awk '{print $1}' | awk -F '/' '{print $1}'| awk 'NR==3 {print $1}'|cut -d. -f1,2,3)
ip44=$(ip route | grep "dev "$zt0"  proto static" | awk '{print $1}' | awk -F '/' '{print $1}'| awk 'NR==4 {print $1}'|cut -d. -f1,2,3)
ip55=$(ip route | grep "dev "$zt0"  proto static" | awk '{print $1}' | awk -F '/' '{print $1}'| awk 'NR==5 {print $1}'|cut -d. -f1,2,3)
sleep 20
[ -n "$ip11" ] && ping_zero1=$(ping -4 $ip11.1 -c 2 -w 4 -q)
[ -n "$ip22" ] && ping_zero2=$(ping -4 $ip22.1 -c 2 -w 4 -q)
[ -n "$ip33" ] && ping_zero3=$(ping -4 $ip33.1 -c 2 -w 4 -q)
[ -n "$ip44" ] && ping_zero4=$(ping -4 $ip44.1 -c 2 -w 4 -q)
[ -n "$ip55" ] && ping_zero5=$(ping -4 $ip55.1 -c 2 -w 4 -q)
[ -n "$ip11" ] && ping_time1=`echo $ping_zero1 | awk -F '/' '{print $4}'`
[ -n "$ip22" ] && ping_time2=`echo $ping_zero2 | awk -F '/' '{print $4}'`
[ -n "$ip33" ] && ping_time3=`echo $ping_zero3 | awk -F '/' '{print $4}'`
[ -n "$ip44" ] && ping_time4=`echo $ping_zero4 | awk -F '/' '{print $4}'`
[ -n "$ip55" ] && ping_time5=`echo $ping_zero5 | awk -F '/' '{print $4}'`
[ -n "$ip11" ] && ping_loss1=`echo $ping_zero1 | awk -F ', ' '{print $3}' | awk '{print $1}'`
[ -n "$ip22" ] && ping_loss2=`echo $ping_zero2 | awk -F ', ' '{print $3}' | awk '{print $1}'`
[ -n "$ip33" ] && ping_loss3=`echo $ping_zero3 | awk -F ', ' '{print $3}' | awk '{print $1}'`
[ -n "$ip44" ] && ping_loss4=`echo $ping_zero4 | awk -F ', ' '{print $3}' | awk '{print $1}'`
[ -n "$ip55" ] && ping_loss5=`echo $ping_zero5 | awk -F ', ' '{print $3}' | awk '{print $1}'`
[ ! -z "$ping_time1" ] && logger -t "ZeroTier" "节点"$ip11".1，延迟:$ping_time1 ms 丢包率:$ping_loss1 "
[ ! -z "$ping_time2" ] && logger -t "ZeroTier" "节点"$ip22".1，延迟:$ping_time2 ms 丢包率:$ping_loss2 "
[ ! -z "$ping_time3" ] && logger -t "ZeroTier" "节点"$ip33".1，延迟:$ping_time3 ms 丢包率:$ping_loss3 "
[ ! -z "$ping_time4" ] && logger -t "ZeroTier" "节点"$ip44".1，延迟:$ping_time4 ms 丢包率:$ping_loss4 "
[ ! -z "$ping_time5" ] && logger -t "ZeroTier" "节点"$ip55".1，延迟:$ping_time5 ms 丢包率:$ping_loss5 "

}
zero_dl() {
start_zero
}
start_zero() {
sed -Ei '/ZeroTier守护进程|^$/d' "$F"
zero_enable=`nvram get zerotier_enable`
if [ "$zero_enable" = "1" ] ; then
logger -t "zerotier" "正在启动zerotier"
 killall -9 zerotier-one
SVC_PATH="/etc/storage/bin/zerotier-one"
tag="$( curl -k --connect-timeout 20 -s https://api.github.com/repos/lmq8267/ZeroTierOne/releases/latest  | grep 'tag_name' | cut -d\" -f4 )"
[ -z "$tag" ] && tag="$( curl -k -L --connect-timeout 20 --silent https://api.github.com/repos/lmq8267/ZeroTierOne/releases/latest | grep 'tag_name' | cut -d\" -f4 )"
[ -z "$tag" ] && tag="$(curl -k --silent "https://api.github.com/repos/lmq8267/ZeroTierOne/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')"
if [ ! -s "$SVC_PATH" ] ; then
   rm -rf /etc/storage/zerotier-one/MD5.txt
   logger -t "ZeroTier" "找不到$SVC_PATH,开始下载"
      if [ ! -z "$tag" ] ; then
      curl -L -k -S -o "/etc/storage/bin/zerotier-one" --connect-timeout 10 --retry 3 "https://fastly.jsdelivr.net/gh/lmq8267/ZeroTierOne@master/install/$tag/zerotier-one"
      curl -L -k -S -o "/etc/storage/zerotier-one/MD5.txt" --connect-timeout 10 --retry 3 "https://fastly.jsdelivr.net/gh/lmq8267/ZeroTierOne@master/install/$tag/MD5.txt"
      else
      curl -L -k -S -o "/etc/storage/bin/zerotier-one" --connect-timeout 10 --retry 3 "https://fastly.jsdelivr.net/gh/lmq8267/ZeroTierOne@master/install/1.10.6/zerotier-one"
      curl -L -k -S -o "/etc/storage/zerotier-one/MD5.txt" --connect-timeout 10 --retry 3 "https://fastly.jsdelivr.net/gh/lmq8267/ZeroTierOne@master/install/1.10.6/MD5.txt"
      fi
if [ ! -s "/etc/storage/bin/zerotier-one" ] ; then
   logger -t "【ZeroTier】" "下载失败，重新下载"
   rm -rf /tmp/var/zMD5.txt
   if [ ! -z "$tag" ] ; then
       curl -L -k -S -o "/tmp/var/zMD5.txt" --connect-timeout 10 --retry 3 "https://github.com/lmq8267/ZeroTierOne/releases/download/$tag/MD5.txt"
      curl -L -k -S -o "/tmp/var/zerotier.tar.gz" --connect-timeout 10 --retry 3 "https://github.com/lmq8267/ZeroTierOne/releases/download/$tag/zerotier.tar.gz"
      else
       curl -L -k -S -o "/tmp/var/zMD5.txt" --connect-timeout 10 --retry 3 "https://github.com/lmq8267/ZeroTierOne/releases/download/1.10.6/MD5.txt"
      curl -L -k -S -o "/tmp/var/zerotier.tar.gz" --connect-timeout 10 --retry 3 "https://github.com/lmq8267/ZeroTierOne/releases/download/1.10.6/zerotier.tar.gz"
      fi
fi
if [ -s "/etc/storage/zerotier-one/MD5.txt" ] && [ -s "/etc/storage/bin/zerotier-one" ] ; then
   zeroMD5="$(cat /etc/storage/zerotier-one/MD5.txt)"
   eval $(md5sum "/etc/storage/bin/zerotier-one" | awk '{print "MD5_down="$1;}') && echo "$MD5_down"
   if [ "$zeroMD5"x = "$MD5_down"x ] ; then
       logger -t "【ZeroTier】" "程序下载完成，MD5匹配，开始安装..."
   else
       logger -t "【ZeroTier】" "程序下载完成，MD5不匹配，删除重新下载..."
       rm -rf /etc/storage/bin/zerotier-one 
   fi
fi
if [ -s "/tmp/var/zMD5.txt" ] && [ -s "/tmp/var/zerotier.tar.gz" ] ; then
   zeroMD5="$(cat /tmp/var/zMD5.txt)"
   eval $(md5sum "/tmp/var/zerotier.tar.gz" | awk '{print "MD5_down="$1;}') && echo "$MD5_down"
   if [ "$zeroMD5"x = "$MD5_down"x ] ; then
       logger -t "【ZeroTier】" "安装包下载完成，MD5匹配，开始安装..."
       tar -xzvf /tmp/var/zerotier.tar.gz -C /tmp/var
       mv -f /tmp/var/zerotier-one/zerotier-one /etc/storage/bin/zerotier-one
   else
       logger -t "【ZeroTier】" "安装包下载完成，MD5不匹配，删除重新下载..."
       rm -rf /tmp/var/zerotier.tar.gz
   fi
fi
if [ ! -s "$SVC_PATH" ] ; then
   logger -t "【ZeroTier】" "下载失败，10秒后尝试重新下载"
   sleep 10
   zero_dl
fi
fi
   [ -f /etc/storage/bin/zerotier-one ] &&  chmod 777 /etc/storage/bin/zerotier-one && rm -rf /etc/storage/bin/zerotier-cli && rm -rf /etc/storage/bin/zerotier-idtool && ln -sf /etc/storage/bin/zerotier-one /etc/storage/bin/zerotier-cli && ln -sf /etc/storage/bin/zerotier-one /etc/storage/bin/zerotier-idtool
       zerotier_v=$($SVC_PATH -version | sed -n '1p')
       echo "$tag"
       echo "$zerotier_v"
      [ ! -z "$zerotier_v" ] && logger -t "ZeroTier" " $SVC_PATH 版本号:v$zerotier_v ，准备启动"
      [ -z "$zerotier_v" ] && logger -t "ZeroTier" "程序不完整，重新下载" && rm -rf rm -rf /etc/storage/bin/zerotier-one && zero_dl
       if [ ! -z "$tag" ] && [ ! -z "$zerotier_v" ] ; then
          if [ "$tag"x != "$zerotier_v"x ] ; then
               logger -t "ZeroTier" "检测到最新版本zerotier_v$tag,当前安装版本zerotier_v$zerotier_v,开始更新"
	        rm -rf /etc/storage/bin/zerotier-one
                zero_dl
           fi
       fi
 start_instance
 zerotier_keep 
 fi
} 
start_instance() {
	port=""
	args=""
	moonid="$(nvram get zerotier_moonid)"
	secret="$(cat /etc/storage/zerotier-one/identity.secret)"
        [ ! -s "/etc/storage/zerotier-one/identity.secret" ] && secret="$(nvram get zerotier_secret)"
	enablemoonserv="$(nvram get zerotiermoon_enable)"
	planet="$(nvram get zerotier_planet)"
	if [ ! -d "$config_path" ]; then
		mkdir -p $config_path
	fi
	mkdir -p $config_path/networks.d
	if [ -n "$port" ]; then
		args="$args -p$port"
	fi
	if [ -z "$secret" ]; then
		logger -t "zerotier" "设备密匙为空,正在生成密匙,请稍后..."
		sf="$config_path/identity.secret"
		pf="$config_path/identity.public"
		$PROGIDT generate "$sf" "$pf"  >/dev/null
		[ $? -ne 0 ] && return 1
		secret="$(cat $sf)"
		#rm "$sf"
		nvram set zerotier_secret="$secret"
		nvram commit
	fi
	if [ -n "$secret" ]; then
		logger -t "zerotier" "找到密匙,正在写入文件,请稍后..."
		echo "$secret" >$config_path/identity.secret
		$PROGIDT getpublic $config_path/identity.secret >$config_path/identity.public
	fi

	if [ -n "$planet"]; then
		logger -t "zerotier" "找到planet,正在写入文件,请稍后..."
		echo "$planet" >$config_path/planet.tmp
		base64 -d $config_path/planet.tmp >$config_path/planet
	fi

	if [ -f "$PLANET" ]; then
		if [ ! -s "$PLANET" ]; then
			logger -t "zerotier" "自定义planet文件为空,删除..."
			rm -f $config_path/planet
			rm -f $PLANET
			nvram set zerotier_planet=""
			nvram commit
		else
			logger -t "zerotier" "自定义planet文件不为空,创建..."
			planet="$(base64 $PLANET)"
			cp -f $PLANET $config_path/planet
			rm -f $PLANET
			nvram set zerotier_planet="$planet"
			nvram commit
		fi
	fi

	add_join $(nvram get zerotier_id)

	$PROG $args $config_path >/dev/null 2>&1 &

	rules

	if [ -n "$moonid" ]; then
		$PROGCLI -D$config_path orbit $moonid $moonid
		logger -t "zerotier" "orbit moonid $moonid ok!"
	fi


	if [ -n "$enablemoonserv" ]; then
		if [ "$enablemoonserv" -eq "1" ]; then
			logger -t "zerotier" "creat moon start"
			creat_moon
		else
			logger -t "zerotier" "remove moon start"
			remove_moon
		fi
	fi
}

add_join() {
		touch $config_path/networks.d/$1.conf
}


rules() {
	while [ "$(ifconfig | grep zt | awk '{print $1}')" = "" ]; do
		sleep 1
	done
	zt0=$(ifconfig | grep zt | awk '{print $1}')
	logger -t "ZeroTier" "已创建虚拟网卡 $zt0 "
	ip44=$(ifconfig $zt0  | grep "inet addr:" | awk '{print $2}' | awk -F '/' '{print $1}'| tr -d 'addr:' | tr -d ' ')
        ip66=$(ifconfig $zt0  | grep "inet6 addr:" | awk '{print $3}' | awk '{print $1,$2}'| tr -d 'addr' | tr -d ' ')
        [ -n "$ip66" ] && logger -t "ZeroTier" ""$zt0"_ipv6:$ip66"
        [ -n "$ip44" ] && logger -t "ZeroTier" ""$zt0"_ipv4:$ip44"
        [ -z "$ip44" ] && [ -z "$ip66" ] && logger -t "ZeroTier" "未获取到zerotier ip请前往官网检查是否勾选此路由加入网络并分配IP"
	del_rules
	iptables -A INPUT -i $zt0 -j ACCEPT
	iptables -A FORWARD -i $zt0 -o $zt0 -j ACCEPT
	iptables -A FORWARD -i $zt0 -j ACCEPT
	if [ $nat_enable -eq 1 ]; then
		iptables -t nat -A POSTROUTING -o $zt0 -j MASQUERADE
		ip_segment="$(ip route | grep "dev $zt0  proto kernel" | awk '{print $1}')"
		iptables -t nat -A POSTROUTING -s $ip_segment -j MASQUERADE
		zero_route "add"
	fi

}


del_rules() {
	zt0=$(ifconfig | grep zt | awk '{print $1}')
	ip_segment=`ip route | grep "dev $zt0  proto" | awk '{print $1}'`
	iptables -D FORWARD -i $zt0 -j ACCEPT 2>/dev/null
	iptables -D FORWARD -o $zt0 -j ACCEPT 2>/dev/null
	iptables -D FORWARD -i $zt0 -o $zt0 -j ACCEPT 2>/dev/null
	iptables -D INPUT -i $zt0 -j ACCEPT 2>/dev/null
	iptables -t nat -D POSTROUTING -o $zt0 -j MASQUERADE 2>/dev/null
	iptables -t nat -D POSTROUTING -s $ip_segment -j MASQUERADE 2>/dev/null
}

zero_route(){
	rulesnum=`nvram get zero_staticnum_x`
	for i in $(seq 1 $rulesnum)
	do
		j=`expr $i - 1`
		route_enable=`nvram get zero_enable_x$j`
		zero_ip=`nvram get zero_ip_x$j`
		zero_route=`nvram get zero_route_x$j`
		if [ "$1" = "add" ]; then
			if [ $route_enable -ne 0 ]; then
				ip route add $zero_ip via $zero_route dev $zt0
				echo "$zt0"
			fi
		else
			ip route del $zero_ip via $zero_route dev $zt0
		fi
	done
}

kill_z() {
sed -Ei '/ZeroTier守护进程|^$/d' "$F"
killall zerotier-one
killall -9 zerotier-one
[ -z "`pidof zerotier-one`" ] && logger -t "ZeroTier" "已关闭"
}
stop_zero() {
	del_rules
	zero_route "del"
	kill_z
}

#创建moon节点
creat_moon(){
	moonip="$(nvram get zerotiermoon_ip)"
	logger -t "zerotier" "moonip $moonip"
	#检查是否合法ip
	regex="\b(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[1-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[1-9])\b"
	ckStep2=`echo $moonip | egrep $regex | wc -l`

	logger -t "zerotier" "搭建ZeroTier的Moon中转服务器，生成moon配置文件"
	if [ -z "$moonip" ]; then
		#自动获取wanip
		ip_addr=`ifconfig -a ppp0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
	#elif [ $ckStep2 -eq 0 ]; then
		#不是ip
	#	ip_addr = `curl $moonip`
	else
		ip_addr=$moonip
	fi
	logger -t "zerotier" "moonip $ip_addr"
	if [ -e $config_path/identity.public ]; then

		$PROGIDT initmoon $config_path/identity.public > $config_path/moon.json
		if `sed -i "s/\[\]/\[ \"$ip_addr\/9993\" \]/" $config_path/moon.json >/dev/null 2>/dev/null`; then
			logger -t "zerotier" "生成moon配置文件成功"
		else
			logger -t "zerotier" "生成moon配置文件失败"
		fi

		logger -t "zerotier" "生成签名文件"
		cd $config_path
		pwd
		$PROGIDT genmoon $config_path/moon.json
		[ $? -ne 0 ] && return 1
		logger -t "zerotier" "创建moons.d文件夹，并把签名文件移动到文件夹内"
		if [ ! -d "$config_path/moons.d" ]; then
			mkdir -p $config_path/moons.d
		fi

		#服务器加入moon server
		mv $config_path/*.moon $config_path/moons.d/ >/dev/null 2>&1
		logger -t "zerotier" "moon节点创建完成"

		zmoonid=`cat moon.json | awk -F "[id]" '/"id"/{print$0}'` >/dev/null 2>&1
		zmoonid=`echo $zmoonid | awk -F "[:]" '/"id"/{print$2}'` >/dev/null 2>&1
		zmoonid=`echo $zmoonid | tr -d '"|,'`

		nvram set zerotiermoon_id="$zmoonid"
		nvram commit
	else
		logger -t "zerotier" "identity.public不存在"
	fi
}

remove_moon(){
	zmoonid="$(nvram get zerotiermoon_id)"

	if [ ! -n "$zmoonid"]; then
		rm -f $config_path/moons.d/000000$zmoonid.moon
		rm -f $config_path/moon.json
		nvram set zerotiermoon_id=""
		nvram commit
	fi
}

case $1 in
start)
	start_zero &
	;;
stop)
	stop_zero &
	;;
restart)
	zerotier_restart &
	;;
*)
	zerotier_restart
	;;
esac
