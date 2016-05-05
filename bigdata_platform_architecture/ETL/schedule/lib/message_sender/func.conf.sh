# some bash functions 
function GetLocalServerNo() {
	local server_no=""
	server_no=$(hostname | sed -e 's/[[:alpha:]-]*\([[:digit:]]*\).*/\1/' | sed 's/^0//')
	echo -n "${server_no}"
}

function GetLogDate() {
	local time_now=$(date +%F" "%T)
	echo -n "[${time_now}]"
}

function WriteLog() {
	local message=$1
	local log_file=$2
	local log_message="$(GetLogDate) ${message}"
	echo ${log_message} >> ${log_file}
}

function WriteErrorLog() {
	local message=$1
	local error_log_file=$2
	local error_log_message="$(GetLogDate) ${message}"
	echo ${error_log_message} >> ${error_log_file}
}

function SendMail() {
  local title=$1
  local message=$2
  local mail_list=$3
  local mail_message="${message}"
  echo "${mail_message}" | mail -s "${title}" "${mail_list}"
}

function SendMailEx() {
	local from=${1}
	local to=${2}
	local subject=${3}
 	local body=${4}
	local content_type="Content-type:text/plain;charset=gb2312"
 	local mail_content="to:${to}\nfrom:${from}\nsubject:${subject}\n${content_type}\n${body}"
	echo -e ${mail_content} | /usr/sbin/sendmail -t
}

function SendMessage() {
	local local_host_name=$(hostname | sed 's/.mathandcs.com//')
	local message=$1
	local mobile_list=$2
	local mobile_message="${message} $(GetLogDate)"

	for mobile in ${mobile_list}
	do
    		gsmsend -s "sms.mathandcs.com:9988" ${mobile}@"${mobile_message}"
	done
}

##-------------------------------------------
##
## 以文件的方式创建进程互斥锁,创建锁不是原子操作
##
##-------------------------------------------
function CreateLockFile() {

    local SCRIPT_NAME=$(basename $0)
    local LOCK_FILE_DIR=${1}
    local LOCK_FILE="${LOCK_FILE_DIR}/${SCRIPT_NAME}.LCK"
    local PID=$$
    local FAILURE=1
    local SUCCESS=0
    local LOG_FILE=$2
    local ERROR_LOG_FILE=$3
    local MAIL_LIST=$4
    local MOBILE_LIST=$5

    ## 检测参数数目
    if [ "$#" != 5 ] ; then
	local message="FATAL: [${SCRIPT_NAME}] Fail to be Called with Invalid Parameter! [$@]"
	WriteErrorLog "${message}" "${ERROR_LOG_FILE}"
        SendMail "${message}" "${MAIL_LIST}"
        SendMessage "${message}" "${MOBILE_LIST}"
	return ${FAILURE}
    fi

    ## 创建锁文件目录
    if [ ! -d ${LOCK_FILE_DIR} ] ; then
        mkdir ${LOCK_FILE_DIR} || {
            local message="FATAL: [${SCRIPT_NAME}] Can not Create Lock File Dir, Exiting."
	    WriteErrorLog "${message}" "${ERROR_LOG_FILE}"
            SendMail "${message}" "${MAIL_LIST}"
            SendMessage "${message}" "${MOBILE_LIST}"
	    return ${FAILURE}
	    }
    fi


    if [[ -r ${LOCK_FILE} && -f ${LOCK_FILE} ]] ; then
	    local OLD_PID=$(cat ${LOCK_FILE}) 2> /dev/null
	
	    ## lock file exist , but no content , exit
            ## Make Sure OPID contains a value
	    if [ -z ${OLD_PID} ] ; then
		local message="FATAL: [${SCRIPT_NAME}] $(basename ${LOCK_FILE}) exists but contains no Process ID"
	        WriteErrorLog "${message}" "${ERROR_LOG_FILE}"
            	SendMail "${message}" "${MAIL_LIST}"
            	SendMessage "${message}" "${MOBILE_LIST}"
		return ${FAILURE}
	    else
		    ## if the PID in lock file is running, exit.
		    ## PROCESS_ID is a var used to test the process whether runing or not.
		    local PROCESS_ID=`ps -p ${OLD_PID} -o %p%a | grep ${SCRIPT_NAME} | awk '{print $1}'  2> /dev/null`

            	    ## Lock File is there, check if process is actually running
		    if [ ${PROCESS_ID} ] ; then 
			    local message="WARNING: [${SCRIPT_NAME}] Script Is Currently Running [PID=${OLD_PID}], Exiting."
	                    WriteErrorLog "${message}" "${ERROR_LOG_FILE}"
			    return ${FAILURE}
		    else
			    ## if lock file exist , but the old_PID is not run now , write the PID to the lock file
			    local message="WARNING: [${SCRIPT_NAME}] Old Lock File with PID= [ ${OLD_PID} ] Exists But Process Is Not Running."
	                    WriteErrorLog "${message}" "${ERROR_LOG_FILE}"
			
	     		    local message="WARNING: [${SCRIPT_NAME}] Overwriting Old PID with New PID Value of [ ${PID} ] "
	                    WriteErrorLog "${message}" "${ERROR_LOG_FILE}"
             	            echo "${PID}" > ${LOCK_FILE}
         	    fi 
     	    fi
    else
	    ## if lock file not exist,write the process PID to the lock file
  	    echo "${PID}" > ${LOCK_FILE}
    
        ## can not write the PID to the LOCK FILE
        if [ $? -ne 0 ] ; then 
        	local message="FATAL: [${SCRIPT_NAME}] Could Not Create Lock File - Exiting. "
	        WriteErrorLog "${message}" "${ERROR_LOG_FILE}"
                SendMail "${message}" "${MAIL_LIST}"
                SendMessage "${message}" "${MOBILE_LIST}"
		return ${FAILURE}
    	fi
    fi
}

##-------------------------------------------
##
## 以链接的方式创建进程互斥锁
## ProcessMutexLock action=lock name=bdindex.lock wait=60
##
##-------------------------------------------
function ProcessMutexLock {
 
    typeset PATH=$(PATH=/bin:/usr/bin getconf PATH)
    typeset action id iden inode name pid time abba 
    typeset wait=99999999 my_pid=$(perl -e 'print getppid')
 
    ## 从命令行获取变量定义
    eval "$@"
  
    function epoch { perl -e 'print time'; }

    ## 用于选择不同的shell的函数内信号捕捉实现细节
    abba=$(function t { trap 'printf "%s" a' EXIT; }; t; printf "%s" b)
 
    ## 获取 lock link 的状态,此函数会返回pid的值
    function lock_stat {
        typeset inode lsout name=$1
        [[ -L ${name} ]] || { printf "%s\n" "inode=" && return 0; }
        set -- $(ls -il ${name})
        printf "%s\n" "inode=${1} ${12} ${13} ${14} ${15}"
    }
 
    ## 生成进程标识信息
    function ps_iden {
        set -- $(ps -o user= -o group= -o ppid= -o pgid= -p $1 2>/dev/null)
        echo $1.$2.$3.$4
        return 0
    }
 
    ## 主流程
    case ${action} in
        lock)
            (( SECONDS = 0 ))
            while (( SECONDS <= wait )); do
                ln -s "pid=${my_pid} time=$(epoch) id=$(ps_iden ${my_pid})" ${name} && {
                    case $abba in
                        ab) trap "trap \"rm -f ${name}\" EXIT" EXIT;;
                        *) trap "rm -f ${name}" EXIT;;
                    esac
                    return 0
                }
 
                eval $(lock_stat ${name})
 
                [[ -n ${inode} ]] && {
                    ps -p ${pid} 2>/dev/null         &&
                    [[ $(ps_iden ${pid}) = "$id" ]]  ||
                    find ${name} -inum ${inode} -exec rm -f {} \;
                }
 
                sleep 3
            done ;;
        unlock)
            eval $(lock_stat ${name})
 
            [[ -n ${inode} ]]                             &&
            find ${name} -inum ${inode} -exec rm -f {} \; &&
            case $abba in
                ab) trap "trap - EXIT" EXIT;;
                *) trap - EXIT;;
            esac                                          &&
            return 0 ;;
    esac
    return 1
}
