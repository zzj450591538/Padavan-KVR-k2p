#!/bin/sh
upanPath="`df -m | grep /dev/mmcb | grep -E "$(echo $(/usr/bin/find /dev/ -name 'mmcb*') | sed -e 's@/dev/ /dev/@/dev/@g' | sed -e 's@ @|@g')" | grep "/media" | awk '{print $NF}' | sort -u | awk 'NR==1' `"
[ -z "$upanPath" ] && upanPath="`df -m | grep /dev/sd | grep -E "$(echo $(/usr/bin/find /dev/ -name 'sd*') | sed -e 's@/dev/ /dev/@/dev/@g' | sed -e 's@ @|@g')" | grep "/media" | awk '{print $NF}' | sort -u | awk 'NR==1' `"
alist="$upanPath/alist/alist"
[ -z "$upanPath" ] && alist="/tmp/alist/alist"
alist_upanPath=""
etcsize=`expr $(df -k | grep "% /etc" | awk 'NR==1' | awk -F' ' '{print $4}' | tr -d "M" ) + 0`
D="/etc/storage/cron/crontabs"
F="$D/`nvram get http_username`"


alist_restart () {
    
    logger -t "【AList】" "重新启动"
    kill_ald
   start_ald
    
}
alist_keep () {
logger -t "【AList】" "守护进程启动"
sed -Ei '/alist守护进程|^$/d' "$F"
cat >> "$F" <<-OSC
*/1 * * * * test -z "\`pidof alist\`"  && aliyundrive-webdav.sh restart #alist守护进程"
OSC
sed -Ei '/alist配置备份|^$/d' "$F"
cat >> "$F" <<-OSC
22 */8 * * * aliyundrive-webdav.sh save #alist配置备份"
OSC
}
start_ald() {
   logger -t "Alist" "正在启动..."
   NAME=alist
   enable=$(nvram get aliyundrive_enable)
   case "$enable" in
    1|on|true|yes|enabled)
      cdn=$(nvram get ald_refresh_token)
      db_file=$(nvram get ald_auth_user)
      temp_dir=$(nvram get ald_auth_password)
      bleve_dir=$(nvram get ald_read_buffer_size)
      enable=$(nvram get ald_cache_size)
      name=$(nvram get ald_cache_ttl)
      https_port=$(nvram get ald_host)
      http_port=$(nvram get ald_port)
      token_expires_in=$(nvram get ald_root)
      address=$(nvram get ald_domain_id)
          

	  
     ;;
    *)
      kill_ald ;;
  esac

}
kill_ald() {
	aliyundrive_process=$(pidof alist)
	if [ -n "$aliyundrive_process" ]; then
		logger -t "Alist" "关闭进程..."
  $alist stop 
		killall alist >/dev/null 2>&1
		kill -9 "$aliyundrive_process" >/dev/null 2>&1
	fi
}
stop_ald() {
	kill_ald
	}



case $1 in
start)
	start_ald
	;;
stop)
	stop_ald
	;;
save)
	alist_restart
	;;
save)
	alist_save
	;;
admin)
    cd /tmp/alist
    [ ! -d /tmp/alist/data ] && mkdir -p /tmp/alist/data
    "$alist" --data /tmp/alist/data admin >/tmp/alist/data/admin.account 2>&1
    user=$(cat /tmp/alist/data/admin.account | grep -E "^username" | awk '{print $2}')
    pass=$(cat /tmp/alist/data/admin.account | grep -E "^password" | awk '{print $2}')
    echo "用户名: $user  密码: $pass"
    [ -n "$user" ] && logger -t "alist" "用户名: $user  密码: $pass"
	;;
*)
	echo "check"
	#exit 0
	;;
esac
