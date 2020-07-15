#!/bin/bash
#-------------------------------------------------------------------------------------------------#
#Universidade federal de Mato Grosso (Alma Mater)
#Course: Science Computer
##Version: 0.3.5
#Date: 07/14/2020
#Description: The "lamw-install.sh" is part of the core of LAMW Manager. This script configures the development environment for LAMW
#-------------------------------------------------------------------------------------------------#

# Verifica condicoes de inicializacao

LAMW_MANAGER_MODULES_PATH=$0
LAMW_MANAGER_MODULES_PATH=${LAMW_MANAGER_MODULES_PATH%/lamw-install.sh*}

source "$LAMW_MANAGER_MODULES_PATH/.init_lamw_manager.sh"
source "$LAMW_MANAGER_MODULES_PATH/common-shell.sh"
source "$LAMW_MANAGER_MODULES_PATH/lamw_headers"
source "$LAMW_MANAGER_MODULES_PATH/installer.sh"
source "$LAMW_MANAGER_MODULES_PATH/lamw-settings-editor.sh"
source "$LAMW_MANAGER_MODULES_PATH/cross-builder.sh"

#chattr +i /tmp/lamw-overrides.conf
#chown root:root /tmp/lamw-overrides.conf
#_------------ OS function t

TrapActions(){
	local sdk_tools_zip=$ANDROID_SDK
	#echo "MAGIC_TRAP_INDEX=$MAGIC_TRAP_INDEX";read
	local magic_trap=(
		"$ANT_TAR_FILE" #0 
		"$ANT_HOME"		#1
		"$GRADLE_ZIP_FILE" #2
		"$GRADLE_HOME"   #3
		"$sdk_tools_zip" #4
		"$ANDROID_SDK" #5
		"$NDK_ZIP" #6
		"$NDK_DIR_UNZIP" #7
	)
	
	if [ "$MAGIC_TRAP_INDEX" != "-1" ]; then
		local file_deleted="${magic_trap[MAGIC_TRAP_INDEX]}"
		if [ -e "$file_deleted" ]; then
			echo "deleting... $file_deleted"	
			rm  -rv $file_deleted
		fi
	fi
#	chattr -i /tmp/lamw-overrides.conf
	#exit 2
	rm '/tmp/lamw-overrides.conf'
}

TrapTermProcess(){
	TrapActions
	exit 15
}
TrapControlC(){
	TrapActions
	exit 2
}


checkForceLAMW4LinuxInstall(){
	local args=($*)
	for((i=0;i<${#args[*]};i++))
	do
		#printf "${VERMELHO} ${args[i]} ${NORMAL}\n"
		if [ "${args[i]}" = "--force" ]; then
			export FORCE_LAWM4INSTALL=1
			break
		fi
	done
}


#Build lazarus ide
BuildLazarusIDE(){
	
	local make_opts=()

	if [ $FLAG_FORCE_ANDROID_AARCH64 = 1 ]; then
		wrapperParseFPC
		if [ -e "$FPC_TRUNK_EXEC_PATH/fpc" ]; then
			export PATH=$FPC_TRUNK_LIB_PATH:$FPC_TRUNK_EXEC_PATH/fpc:$PATH
			make_opts=(
				"PP=${FPC_TRUNK_LIB_PATH}/ppcx64"
				"FPC_VERSION=$_FPC_TRUNK_VERSION"
			)
		fi
	fi


	if [ ! -e "$LAMW_IDE_HOME" ]; then  
		ln -sf $LAMW4LINUX_HOME/$LAZARUS_STABLE $LAMW_IDE_HOME # link to lamw4_home directory 
	fi  

	if [ ! -e "$LAMW4LINUX_EXE_PATH" ]; then 
		ln -sf $LAMW_IDE_HOME/lazarus $LAMW4LINUX_EXE_PATH  #link  to lazarus executable
	fi


	changeDirectory $LAMW_IDE_HOME
	if [ $# = 0 ]; then 
		make clean all  ${make_opts[*]}
	fi
	
	initLAMw4LinuxConfig
		#build ide  with lamw framework 
	for((i=0;i< ${#LAMW_PACKAGES[@]};i++))
	do
		./lazbuild --build-ide= --add-package ${LAMW_PACKAGES[i]} --primary-config-path=$LAMW4_LINUX_PATH_CFG  --lazarusdir=$LAMW_IDE_HOME
		if [ $? != 0 ]; then
			./lazbuild --build-ide= --add-package  ${LAMW_PACKAGES[i]} --primary-config-path=$LAMW4_LINUX_PATH_CFG  --lazarusdir=$LAMW_IDE_HOME
		fi
	done

	if [ -e /root/.fpc.cfg ]; then
		rm  -rf /root/.fpc.cfg
	fi
}

#this code add support a proxy 
checkProxyStatus(){
	if [ $USE_PROXY = 1 ] ; then
		ActiveProxy 1
	else
		ActiveProxy 0
	fi
}

testImplicitInstall(){
	getImplicitInstall
	if [ $LAMW_IMPLICIT_ACTION_MODE = 0 ]; then
		echo "Please wait..."
		printf "${NEGRITO}Implicit installation of LAMW starting in $TIME_WAIT seconds  ... ${NORMAL}\n"
		printf "Press control+c to exit ...\n"
		sleep $TIME_WAIT
		mainInstall
		changeOwnerAllLAMW;
	else
		echo "Please wait ..."
		printf "${NEGRITO}Implicit LAMW Framework update starting in $TIME_WAIT seconds ... ${NORMAL}...\n"
		printf "Press control+c to exit ...\n"
		sleep $TIME_WAIT 
		wrapperRepair
		checkProxyStatus;
		echo "Updating LAMW";
		getLAMWFramework;
		BuildLazarusIDE "1";
		changeOwnerAllLAMW "1";
	fi				
}

#trap TrapTermProcess 15
trap TrapControlC 2 
checkForceLAMW4LinuxInstall $*
	# echo "----------------------------------------------------------------------"
	#printf "${LAMW_INSTALL_WELCOME[*]}"
	# echo "----------------------------------------------------------------------"

if [ $# = 6 ] || [ $# = 7 ]; then
	if [ "$2" = "--use_proxy" ] ;then 
		if [ "$3" = "--server" ]; then
			if [ "$5" = "--port" ] ;then
				initParameters $2 $4 $6
			fi
		fi
	fi
else
	initParameters
fi
 

#instalando tratadores de sinal	


#Parameters are useful for understanding script operation
case "$1" in
	"version")
		printf "${LAMW_INSTALL_WELCOME[*]}"
		printf "Linux supported\n${LAMW_LINUX_SPP[*]}"
	;;

	"uninstall")
		CleanOldConfig;
		changeOwnerAllLAMW
	;;

	"--sdkmanager")
	getStatusInstalation;
	if [ $LAMW_INSTALL_STATUS = 1 ];then
		$ANDROID_SDK/tools/android update sdk
		changeOwnerAllLAMW 

	else
		mainInstall
		$ANDROID_SDK/tools/android update sdk
		changeOwnerAllLAMW
	fi 	
	;;
	"--update-lamw")
		getStatusInstalation
		if [ $LAMW_INSTALL_STATUS  = 0 ]; then
			mainInstall
			changeOwnerAllLAMW

		else
			wrapperRepair
			checkProxyStatus;
			echo "Updating LAMW";
			getLAMWFramework;
			sleep 1;
			BuildLazarusIDE "1"
			changeOwnerAllLAMW "1";
		fi
	;;
	"install")
		export OLD_ANDROID_SDK=1
		export NO_GUI_OLD_SDK=1
		mainInstall
		changeOwnerAllLAMW
	;;

	"--reset")
		printf "Please wait ...\n"
		CleanOldConfig
	#	printf "Mode SDKTOOLS=24 with ant support "
		export OLD_ANDROID_SDK=1
		export NO_GUI_OLD_SDK=1
		mainInstall
		changeOwnerAllLAMW
	;;
	"--reset-aapis")
		export OLD_ANDROID_SDK=1
		export NO_GUI_OLD_SDK=1
		getStatusInstalation
		if [ $LAMW_INSTALL_STATUS = 1 ]; then
			RepairOldSDKAndroid
		else
			mainInstall
		fi
	;;
	"")
		testImplicitInstall	
	;;
	"--use_proxy")
		testImplicitInstall
	;;
	"--help") 
		printf "${LAMW_OPTS[*]}" 
	;;

	*)
		printf "${VERMELHO}Invalid argument!${NORMAL}\n${LAMW_OPTS[*]}" >&2
		exit 1
	;;
esac
#chattr -i /tmp/lamw-overrides.conf