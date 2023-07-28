#!/bin/bash
#copyright by hiboy

wxsend_appid=$(cat /etc/storage/post_wan_script.sh | grep "wx_appid=" | awk '{print $2}')
wxsend_appsecret=$(cat /etc/storage/post_wan_script.sh | grep "wx_appsecret=" | awk '{print $2}')
wxsend_touser=$(cat /etc/storage/post_wan_script.sh | grep "wxsend_touser=" | awk '{print $2}')
wxsend_template_id=$(cat /etc/storage/post_wan_script.sh | grep "wxsend_template_id=" | awk '{print $2}')
wxsend_notify_1=$(cat /etc/storage/post_wan_script.sh | grep "wxsend_notify_1=" | awk '{print $2}')
wxsend_notify_2=$(cat /etc/storage/post_wan_script.sh | grep "wxsend_notify_2=" | awk '{print $2}')
wxsend_notify_3=$(cat /etc/storage/post_wan_script.sh | grep "wxsend_notify_3=" | awk '{print $2}')
wxsend_notify_4=$(cat /etc/storage/post_wan_script.sh | grep "wxsend_notify_4=" | awk '{print $2}')
wxtime=$(cat /etc/storage/post_wan_script.sh | grep "wxsend_time=" | awk '{print $2}')
[ -z "$wxtime" ] && wxtime=60

D="/etc/storage/cron/crontabs"
F="$D/`nvram get http_username`"
data="$(date "+%G-%m-%d_%H:%M:%S")"
get_token () {
touch /tmp/wx_access_token
access_token="$(cat /tmp/wx_access_token)"
http_type="$(curl -L -k "https://api.weixin.qq.com/cgi-bin/get_api_domain_ip?access_token=$access_token")"
get_api_domain="$(echo $http_type | grep ip_list)"
if [ ! -z "$get_api_domain" ] ; then
echo "Access token 有效"
else
http_type="$(curl -L -k "https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=$wxsend_appid&secret=$wxsend_appsecret")"
access_token="$(echo $http_type | grep -o "\"access_token\":\"[^\,\"\}]*" | awk -F 'access_token":"' '{print $2}')"
if [ ! -z "$access_token" ] ; then
expires_in="$(echo $http_type | grep -o "\"expires_in\":[^\,\"\}]*" | awk -F 'expires_in":' '{print $2}')"
logger -t "【微信推送】" "获取 Access token 成功，凭证有效时间，单位： $expires_in 秒"
echo -n "$access_token" > /tmp/wx_access_token
else
errcode="$(echo $http_type | grep -o "\"errcode\":[^\,\"\}]*" | awk -F ':' '{print $2}')"
if [ ! -z "$errcode" ] ; then
errmsg="$(echo $http_type | grep -o "\"errmsg\":\"[^\,\"\}]*" | awk -F 'errmsg":"' '{print $2}')"
logger -t "【微信推送】" "获取 Access token 返回错误码: $errcode"
logger -t "【微信推送】" "错误信息: $errmsg"
access_token=""
echo -n "" > /tmp/wx_access_token
fi
fi
fi
}

send_message () {
get_token
access_token="$(cat /tmp/wx_access_token)"
if [ ! -z "$access_token" ] ; then
curl -k -H "Content-type: application/json;charset=UTF-8" -H "Accept: application/json" -H "Cache-Control: no-cache" -H "Pragma: no-cache" -X POST -d '{"touser":"'"$wxsend_touser"'","template_id":"'"$wxsend_template_id"'","data":{"1":{"value":"'"$1 $data "'"},"2":{"value":"'"$data  "'"},"3":{"value":"'"$1"'"},"4":{"value":"'"$2"'"},"5":{"value":"'"$3"'"}}}' "https://api.weixin.qq.com/cgi-bin/message/template/send?access_token=$access_token"
logger -t "【微信推送】" "推送成功》》$1 $2 $3"
else
logger -t "【微信推送】" "推送失败，获取 Access token 错误，请看看哪里问题？"
fi
}

wxsend_keep  () {
[ ! -z "`pidof wxsendfile.sh`" ] && logger -t "【微信推送】" "启动成功"
logger -t "【微信推送】" "守护进程启动"
sed -Ei '/微信推送守护进程|^$/d' "$F"
cat >> "$F" <<-OSC
*/1 * * * * test -z "\`pidof wxsendfile.sh\`"  && /etc/storage/wxsend.sh start #微信推送守护进程
OSC
}

wxsend_close () {
  sed -Ei '/微信推送守护进程|^$/d' "$F"
  killall wxsendfile.sh
  killall -9 wxsendfile.sh
  
  sleep 3
[ -z "`pidof wxsendfile.sh`" ] && logger -t "【微信推送】" "进程已关闭"
}

wxsend_start () {
 killall wxsendfile.sh
 killall -9 wxsendfile.sh
 
 if [ ! -f "/etc/storage/wxsendfile.sh" ] || [ ! -s "/etc/storage/wxsendfile.sh" ] ; then
         cat > "/etc/storage/wxsendfile.sh" <<-\EEE
#!/bin/bash

wxsend_appid=$(cat /etc/storage/post_wan_script.sh | grep "wx_appid=" | awk '{print $2}')
wxsend_appsecret=$(cat /etc/storage/post_wan_script.sh | grep "wx_appsecret=" | awk '{print $2}')
wxsend_touser=$(cat /etc/storage/post_wan_script.sh | grep "wxsend_touser=" | awk '{print $2}')
wxsend_template_id=$(cat /etc/storage/post_wan_script.sh | grep "wxsend_template_id=" | awk '{print $2}')
wxsend_notify_1=$(cat /etc/storage/post_wan_script.sh | grep "wxsend_notify_1=" | awk '{print $2}')
wxsend_notify_2=$(cat /etc/storage/post_wan_script.sh | grep "wxsend_notify_2=" | awk '{print $2}')
wxsend_notify_3=$(cat /etc/storage/post_wan_script.sh | grep "wxsend_notify_3=" | awk '{print $2}')
wxsend_notify_4=$(cat /etc/storage/post_wan_script.sh | grep "wxsend_notify_4=" | awk '{print $2}')
wxtime=$(cat /etc/storage/post_wan_script.sh | grep "wxsend_time=" | awk '{print $2}')
[ -z "$wxtime" ] && wxtime=60

mkdir -p /tmp/var
resub=1
# 获得外网地址v4
    arIpAddress4() {
    curltest=`which curl`
    if [ -z "$curltest" ] || [ ! -s "`which curl`" ] ; then
	wget -qO- http://ipecho.net/plain | xargs echo
    else
	curl -4 -k https://ifconfig.co/ip
    fi
    }
# 读取最近外网地址v4
    lastIPAddress4() {
        [ ! -e "/etc/storage/wxsend_lastIPAddress4" ] && touch /etc/storage/wxsend_lastIPAddress4
        inter4="/etc/storage/wxsend_lastIPAddress4"
        cat $inter4
    }
 # 获得外网地址v6
    arIpAddress6() {
    curltest=`which curl`
    if [ -z "$curltest" ] || [ ! -s "`which curl`" ] ; then
        wget -T 5 -t 3 --user-agent "$user_agent" --quiet --output-document=- "https://ipv6.icanhazip.com"
    else
        curl -L -k --user-agent "$user_agent" -s "https://ipv6.icanhazip.com"
    fi
    }
# 读取最近外网地址v6
    lastIPAddress6() {
        [ ! -e "/etc/storage/wxsend_lastIPAddress6" ] && touch /etc/storage/wxsend_lastIPAddress6
        inter6="/etc/storage/wxsend_lastIPAddress6"
        cat $inter6
    }

while [ "1" = "1" ];
do

curltest=`which curl`
ping_text=`ping -4 223.5.5.5 -c 1 -w 2 -q`
ping_time=`echo $ping_text | awk -F '/' '{print $4}'| awk -F '.' '{print $1}'`
ping_loss=`echo $ping_text | awk -F ', ' '{print $3}' | awk '{print $1}'`
if [ ! -z "$ping_time" ] ; then
    echo "ping：$ping_time ms 丢包率：$ping_loss"
 else
    echo "ping：失效"
fi
if [ ! -z "$ping_time" ] ; then
echo "online"
if [ "$wxsend_notify_1" = "1" ] ; then
    hostIP4=$(arIpAddress4)
    hostIP6=$(arIpAddress6)
    #hostIP=`echo $hostIP | head -n1 | cut -d' ' -f1`
    if [ "$hostIP4"x = "x"  ] ; then
        curltest=`which curl`
        if [ -z "$curltest" ] || [ ! -s "`which curl`" ] ; then
            [ "$hostIP4"x = "x"  ] && hostIP4=`wget -qO- http://ipecho.net/plain | xargs echo`
        else
            [ "$hostIP4"x = "x"  ] && hostIP4=`curl -4 -k https://ifconfig.co/ip`
        fi
    fi
    if [ "$hostIP6"x = "x"  ] ; then
        curltest=`which curl`
        if [ -z "$curltest" ] || [ ! -s "`which curl`" ] ; then
            [ "$hostIP6"x = "x"  ] && hostIP6=` wget -T 5 -t 3 --user-agent "$user_agent" --quiet --output-document=- "https://ipv6.icanhazip.com"`
        else
            [ "$hostIP6"x = "x"  ] && hostIP6=`curl -L -k --user-agent "$user_agent" -s "https://ipv6.icanhazip.com"`
        fi
    fi
    lastIP4=$(lastIPAddress4)
    lastIP6=$(lastIPAddress6)
    if [ "$lastIP4" != "$hostIP4" ] && [ ! -z "$hostIP4" ] ; then
    sleep 60
        hostIP4=$(arIpAddress4)
        #hostIP4=`echo $hostIP4 | head -n1 | cut -d' ' -f1`
        lastIP4=$(lastIPAddress4)
    fi
    if [ "$lastIP4" != "$hostIP4" ] && [ ! -z "$hostIP4" ] ; then
       wx_send.sh send_message "【WAN口IPV4变动】" "目前`nvram get computer_name` IP: ${hostIP4}" "上次 IP: ${lastIP4} " &
        echo -n $hostIP4 > /etc/storage/wxsend_lastIPAddress4
    fi
    if [ "$lastIP6" != "$hostIP6" ] && [ ! -z "$hostIP6" ] ; then
    sleep 60
        hostIP6=$(arIpAddress6)
        #hostIP6=`echo $hostIP6 | head -n1 | cut -d' ' -f1`
        lastIP6=$(lastIPAddress6)
    fi
    if [ "$lastIP6" != "$hostIP6" ] && [ ! -z "$hostIP6" ] ; then
       wx_send.sh send_message "【WAN口IPV6变动】" "目前`nvram get computer_name` IP: ${hostIP6}" "上次 IP: ${lastIP6}" &
        echo -n $hostIP6 > /etc/storage/wxsend_lastIPAddress6
    fi
fi
if [ "$wxsend_notify_2" = "1" ] ; then
    # 获取接入设备名称
    touch /tmp/var/wxsend_newhostname.txt
    echo "接入设备名称" > /tmp/var/wxsend_newhostname.txt
    #cat /tmp/syslog.log | grep 'Found new hostname' | awk '{print $7" "$8}' >> /tmp/var/wxsend_newhostname.txt
    cat /tmp/static_ip.inf | grep -v "^$" | awk -F "," '{ if ( $6 == 0 ) print "【内网IP："$1"，ＭＡＣ：\n"$2"，名称："$3"】  "}' >> /tmp/var/wxsend_newhostname.txt
    # 读取以往接入设备名称
    touch /etc/storage/wxsend_hostname.txt
    [ ! -s /etc/storage/wxsend_hostname.txt ] && echo "接入设备名称" > /etc/storage/wxsend_hostname.txt
    # 获取新接入设备名称
    awk 'NR==FNR{a[$0]++} NR>FNR&&a[$0]' /etc/storage/wxsend_hostname.txt /tmp/var/wxsend_newhostname.txt > /tmp/var/wxsend_newhostname相同行.txt
    awk 'NR==FNR{a[$0]++} NR>FNR&&!a[$0]' /tmp/var/wxsend_newhostname相同行.txt /tmp/var/wxsend_newhostname.txt > /tmp/var/wxsend_newhostname不重复.txt
    if [ -s "/tmp/var/wxsend_newhostname不重复.txt" ] ; then
        content=`cat /tmp/var/wxsend_newhostname不重复.txt | grep -v "^$" | sed "s#[^^]\([0-9]\.\) #\n\1 #g" | awk 'NR==1 {print $1}')"`
	content2=`cat /tmp/var/wxsend_newhostname不重复.txt | grep -v "^$" | sed "s#[^^]\([0-9]\.\) #\n\1 #g" | awk 'NR==2 {print $1}')"`
        wx_send.sh send_message "【`nvram get computer_name`新设备加入】" "${content}" "${content2}" &
         cat /tmp/var/wxsend_newhostname不重复.txt | grep -v "^$" >> /etc/storage/wxsend_hostname.txt
    fi
fi
if [ "$wxsend_notify_3" = "1" ] ; then
    # 设备上、下线提醒
    # 获取接入设备名称
    touch /tmp/var/wxsend_newhostname.txt
    echo "接入设备名称" > /tmp/var/wxsend_newhostname.txt
    #cat /tmp/syslog.log | grep 'Found new hostname' | awk '{print $7" "$8}' >> /tmp/var/wxsend_newhostname.txt
    cat /tmp/static_ip.inf | grep -v "^$" | awk -F "," '{ if ( $6 == 0 ) print "【内网IP："$1"，ＭＡＣ：\n"$2"，名称："$3"】  "}' >> /tmp/var/wxsend_newhostname.txt
    # 读取以往上线设备名称
    touch /etc/storage/wxsend_hostname_上线.txt
    [ ! -s /etc/storage/wxsend_hostname_上线.txt ] && echo "接入设备名称" > /etc/storage/wxsend_hostname_上线.txt
    # 上线
    awk 'NR==FNR{a[$0]++} NR>FNR&&a[$0]' /etc/storage/wxsend_hostname_上线.txt /tmp/var/wxsend_newhostname.txt > /tmp/var/wxsend_newhostname相同行_上线.txt
    awk 'NR==FNR{a[$0]++} NR>FNR&&!a[$0]' /tmp/var/wxsend_newhostname相同行_上线.txt /tmp/var/wxsend_newhostname.txt > /tmp/var/wxsend_newhostname不重复_上线.txt
    if [ -s "/tmp/var/wxsend_newhostname不重复_上线.txt" ] ; then
        content=`cat /tmp/var/wxsend_newhostname不重复_上线.txt | grep -v "^$" | sed "s#[^^]\([0-9]\.\) #\n\1 #g" | awk 'NR==1 {print $1}')"`
	content2=`cat /tmp/var/wxsend_newhostname不重复_上线.txt | grep -v "^$" | sed "s#[^^]\([0-9]\.\) #\n\1 #g" | awk 'NR==2 {print $1}')"`
       wx_send.sh send_message "【`nvram get computer_name`设备上线提醒】" "${content}" "${content2}" &
        cat /tmp/var/wxsend_newhostname不重复_上线.txt | grep -v "^$" >> /etc/storage/wxsend_hostname_上线.txt
    fi
    # 下线
    awk 'NR==FNR{a[$0]++} NR>FNR&&!a[$0]' /tmp/var/wxsend_newhostname.txt /etc/storage/wxsend_hostname_上线.txt > /tmp/var/wxsend_newhostname不重复_下线.txt
    if [ -s "/tmp/var/wxsend_newhostname不重复_下线.txt" ] ; then
        content=`cat /tmp/var/wxsend_newhostname不重复_下线.txt | grep -v "^$" | sed "s#[^^]\([0-9]\.\) #\n\1 #g" | awk 'NR==1 {print $1}')"`
	content2=`cat /tmp/var/wxsend_newhostname不重复_下线.txt | grep -v "^$" | sed "s#[^^]\([0-9]\.\) #\n\1 #g" | awk 'NR==2 {print $1}')"`
       wx_send.sh send_message "【`nvram get computer_name`设备下线提醒】" "${content}" "${content2}" &
        cat /tmp/var/wxsend_newhostname.txt | grep -v "^$" > /etc/storage/wxsend_hostname_上线.txt
    fi
fi
if [ "$wxsend_notify_4" = "1" ] ; then
  # 进程守护推送
  #自定义添加推送内容 下面的内容 内容2 是每段不能超过20个字 所以内容只能20个字 多的填在内容2里 
  #微信推送命令格式： wx_send.sh send_message "【标题】" "内容" "内容2" & 
  #例如检测zerotier进程是否掉了 如下
  #if [ -z "`pidof zerotier-one`" ]  ; then
  #killall -9 zerotier-one
  #  zerotier.sh start
  # wx_send.sh send_message "【`nvram get computer_name`进程掉线】" "zerotier掉线，重新启动" &
  # fi

  echo 测试




fi
    resub=`expr $resub + 1`
    [ "$resub" -gt 360 ] && resub=1
else
echo "Internet down 互联网断线"
resub=1
fi

sleep $wxtime
continue
done

EEE
	chmod 755 /etc/storage/wxsendfile.sh
fi

sleep 4
logger -t "【微信推送】" "运行 /etc/storage/wxsendfile.sh"
/etc/storage/wxsendfile.sh &
wxsend_keep
exit 0
}

case $1 in
send_message)
	send_message "$2" "$3" "$4"
	;;
start)
	wxsend_start
	;;
stop)
	wxsend_close
	;;
restart)
        wxsend_close
	wxsend_start
	;;
*)
	wxsend_start
	;;
esac

