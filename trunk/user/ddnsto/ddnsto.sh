#!/bin/sh

start_zero() {
	logger -t "【ddnsto】" "正在启动DDNSTO"
	killall ddnsto >/dev/null 2>&1
	kill -9 "$ddnsto_process" >/dev/null 2>&1
 ddnsto_route_id=$(ddnsto -w | awk '{print $2}')
nvram set ddnsto_route_id="$ddnsto_route_id"
[ ! -z $ddnsto_route_id ] && logger -t "【ddnsto】" "路由器ID：【$ddnsto_route_id】；管理控制台 https://www.ddnsto.com/"
ddnsto_version=$(ddnsto -v)
nvram set ddnsto_version="$ddnsto_version"
[ -z $ddnsto_token ] && logger -t "【ddnsto】" "【ddnsto_token】不能为空,启动失败, 10 秒后自动尝试重新启动" && sleep 10 && ddnsto_restart x
logger -t "【ddnsto】" "运行 ddnsto 版本：$ddnsto_version"

	SSL_CERT_FILE=/usr/bin/cacert.pem /usr/bin/ddnsto -u "$(nvram get ddnsto_id)" >/dev/null 2>&1 &
sleep 3
[ -z "`pidof ddnsto`" ] && logger -t "【ddnsto】" "启动失败"
[ ! -z "`pidof ddnsto`" ] && logger -t "【ddnsto】" "启动成功" 

}
kill_z() {
	ddnsto_process=$(pidof ddnsto)
	if [ -n "$ddnsto_process" ]; then
		logger -t "【ddnsto】" "关闭进程..."
		killall ddnsto >/dev/null 2>&1
		kill -9 "$ddnsto_process" >/dev/null 2>&1
	fi
}
stop_zero() {
	kill_z
	}



case $1 in
start)
	start_zero
	;;
stop)
	stop_zero
	;;
*)
	echo "check"
	#exit 0
	;;
esac
