#!/bin/bash 


export LAMW_MANAGER_API_URL='https://api.github.com/repos/dosza/lamwmanager-linux/releases/latest'

trimVersion(){
	
	local rv_limit=4
	v1=(${1//\./ })
	v2=(${2//\./ })
	v2=(${v2[@],,})
	v1=(${v1[@],,})
	v1=(${v1[@]//'-r'/ })
	v2=(${v2[@]//'-r'/ })
	v1_str=${1//\./}
	v2_str=${2//\./}
	v1_str=${v1_str,,}
	v2_str=${v2_str,,}
	v1_str=${v1_str//'-r'/}
	v2_str=${v2_str//'-r'/}

	[ ${#v1[@]} -lt $rv_limit ] && [ ${v1[2]}  -lt 10 ] && v1_str+=00
	[ ${#v2[@]} -lt $rv_limit ] && [ ${v2[2]}  -lt 10 ] && v2_str+=00
}
compareVersion(){
	local v1=()
	local v2=()
	local v1_str=""
	local v2_str=""
	local rv_limit=4


	[ "$2" = "" ] && return 1

	trimVersion $1 $2
	
	[ $v1_str -lt $v2_str ]

}
checkLAMWManageUpdates(){
	local lamw_manager_latest=$(
		wget -qO- $LAMW_MANAGER_API_URL | 
		jq .tag_name |
		sed 's/"//g;s/v//g'
	)

	local lamw_manager_current_version=$(
		grep  "^Generate LAMW_INSTALL_VERSION=" $ANDROID_HOME/lamw4linux/lamw-install.log |
		awk -F= '{  print $2 }'
	)


	if compareVersion $lamw_manager_current_version $lamw_manager_latest;then 
		local zenity_message='there is update to Lamw Manager available'
		[ $1 = 0 ] && zenity  --title "${zenity_title}" --notification --width 480 --text "${zenity_message}"
		return 0
	fi
	return 1
}

get-lamw-manager-updates(){
	
	if ! checkLAMWManageUpdates 1; then
		return 
	fi	
	
	lamw_manager_setup=$(
		wget -qO- $LAMW_MANAGER_API_URL | 
		jq .assets[].browser_download_url |
		sed 's/"//g'
	)

	[ "$lamw_manager_setup" = "" ] && return 1

	cd /tmp
	wget -qc --show-progress "$lamw_manager_setup"
	echo -en "Do you want run ./lamw_manager_setup.sh y/n? "

	read -n 1 answer
	[[ "${answer,,}" != 'y' ]] && return 
	
	echo ""
	bash ./lamw_manager_setup.sh 

	cd $OLDPWD

}


case "$1" in 
	"get")
		get-lamw-manager-updates
	;;
	"")
		checkLAMWManageUpdates 0
	;;
	*) 
		false
	;;
esac