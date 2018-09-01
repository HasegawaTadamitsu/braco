#!/bin/sh

URI="http://bracon/?"

WGET=/usr/bin/wget
JQ=/usr/bin/jq
TMP_FILE=/tmp/foo.$$
BUSY_LOOP_COUNT=10

value2temp(){
    local val=$1
    ret=`echo "scale=3; $val / 6 " | /usr/bin/bc`
    printf "%.1f" $ret
}
value2brightness(){
    local val=$1
    ret=`echo "scale=3; (1023- $val) / 1023 * 100" | /usr/bin/bc`
    printf "%.0f" $ret
}

execute_command(){
    local command=$1
    request_str="$URI$command"
#    echo  resuqst string $request_str
    $WGET -q -O $TMP_FILE $request_str 
    ret=$?
    if [ $ret -ne 0 ]; then
	echo error status $ret
        rm -rf $TMP_FILE
        exit 1
    fi
    status=`cat $TMP_FILE | $JQ  .status |tr -d \"`
    if [ $status != "ok" ]; then
	echo status error
	cat $TMP_FILE
	exit 1
    fi
}
wait_command(){
    # busy となる可能性があるコマンドに対し　温度取得を行い
    # busy が解消されるまでまつ
    local TMP_FILE_BUSY=/tmp/foo_busy.$$
    local command=T
    request_str="$URI$command"
    loop=`seq 1 $BUSY_LOOP_COUNT`
    for i in $loop
    do
	sleep 1
	$WGET -q -O $TMP_FILE_BUSY $request_str 
	ret=$?
	if [ $ret -ne 0 ]; then
	    echo error status $ret
	    rm -rf $TMP_FILE_BUSY
	    exit 1
	fi
	status=`cat $TMP_FILE_BUSY | $JQ  .status |tr -d "\"" `
	if [ $status = "ok" ]; then
	    rm -rf $TMP_FILE_BUSY
	    return
	fi
	rm -rf $TMP_FILE_BUSY
    done
    echo loop max. but busy. $BUSY_LOOP_COUNT
    exit 1
}


show_network_infomation(){
  local command="O"
  execute_command $command
  echo -n mode
  cat $TMP_FILE | $JQ .m
  echo -n "ip "
  cat $TMP_FILE | $JQ .ip
  echo -n gateway
  cat $TMP_FILE | $JQ .gw
  echo -n nameserver
  cat $TMP_FILE | $JQ .ns
  echo -n mask
  cat $TMP_FILE | $JQ .mk
  echo -n mac_address
  cat $TMP_FILE | $JQ .mac
  rm -rf $TMP_FILE
}
get_temp(){
    execute_command "T"
    temp=`cat $TMP_FILE| $JQ .val | tr -d "\""`
    value2temp $temp
    echo 
    rm -rf $TMP_FILE
}
get_brightness(){
    execute_command "L"
    temp=`cat $TMP_FILE| $JQ .val | tr -d "\""`
    value2brightness $temp
    echo 
    rm -rf $TMP_FILE
}

set_beep(){
    local  switch=$1
    local command=""
    case  $switch in
	     "true"  | "on"  |"1" )  command="B1";;
             "false" | "off" |"0" ) command="B0";;
             * ) echo unknown switch. $switch
		 exit 1
    esac
    execute_command $command
    rm -rf $TMP_FILE
}

get_remocon_data_count(){
    execute_command "X"
    count=`cat $TMP_FILE | $JQ .val | tr -d "\""`
    echo $count
    rm -rf  $TMP_FILE
}
delete_remocon_data(){
    # 削除が行われると番号が一つ詰まる。
    # 存在しない番号をしているするとerr になる
    local num=$1
    execute_command "D$num"
    rm -rf  $TMP_FILE
}

recode_remocon_data_to_buffer(){
    execute_command "C"
    rm -rf  $TMP_FILE
    wait_command
}
write_remocon_data_from_buffer(){
    execute_command "W"
    rm -rf  $TMP_FILE
    wait_command
}
send_buffer_remocon_data(){
    execute_command "Y"
    rm -rf  $TMP_FILE
    wait_command
}

send_remocon_data(){
    local num=$1
    execute_command "P$num"
    rm -rf  $TMP_FILE
    wait_command
}  

delete_all_remocon_data(){
    count=`get_remocon_data_count`
    for i in `seq 1 $count`
    do
	delete_remocon_data 0
    done   
}    
list="1:点灯 2:消灯 3:光色切替(active) 4:光色切替(relax) 5:光色切替(natural) 6:明 7:暗 8:保安球"
echo $list
send_remocon_data $1
