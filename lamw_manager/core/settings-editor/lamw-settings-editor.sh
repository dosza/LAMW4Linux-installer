#!/bin/bash
#-------------------------------------------------------------------------------------------------#
#Universidade federal de Mato Grosso (mater-alma)
#Course: Science Computer
#Version: 0.4.4
#Date: 12/13/2021
#Description: The "lamw-manager-settings-editor.sh" is part of the core of LAMW Manager. Responsible for managing LAMW Manager / LAMW configuration files..
#-----------------------------------------------------------------------f--------------------------#
#this function builds initial struct directory of LAMW env Development !
initROOT_LAMW(){

	local init_root_lamw_dirs=(
		$ANDROID_SDK_ROOT
		"$(dirname $JAVA_HOME)"
		"$LAMW4LINUX_ETC"
		$LAMW_USER_HOME/.android
		$HOME/.android
		$FPPKG_LOCAL_REPOSITORY
		$LAMW4_LINUX_PATH_CFG
	)


	for lamw_dir in ${init_root_lamw_dirs[@]}; do
		[ ! -e "$lamw_dir" ] && mkdir -p "$lamw_dir"
	done

	[ ! -e $LAMW_USER_HOME/.android/repositories.cfg ] && touch $LAMW_USER_HOME/.android/repositories.cfg  
	[ ! $HOME/.android/repositories.cfg ] && echo "" > $HOME/.android/repositories.cfg 
}

enableADBtoUdev(){
	  printf 'SUBSYSTEM=="usb", ATTR{idVendor}=="<VENDOR>", MODE="0666", GROUP="plugdev"\n' > /etc/udev/rules.d/51-android.rules
	  systemctl restart udev.service
}


AddSDKPathstoProfile(){
	local profile_file=$LAMW_USER_HOME/.bashrc
	local flag_profile_paths=0
	local profile_line_path='export PATH=$PATH:$GRADLE_HOME/bin'

	InsertUniqueBlankLine "$LAMW_USER_HOME/.profile"
	InsertUniqueBlankLine "$LAMW_USER_HOME/.bashrc"
	cleanPATHS
	searchLineinFile "$profile_file" "$profile_line_path"
	flag_profile_paths=$?

	if [ $flag_profile_paths = 0 ] ; then 
		echo "export ANDROID_HOME=$ANDROID_HOME" >>  $LAMW_USER_HOME/.bashrc
		echo "export GRADLE_HOME=$GRADLE_HOME" >> $LAMW_USER_HOME/.bashrc
		echo 'export PATH=$PATH:$ANDROID_HOME/ndk-toolchain' >> $LAMW_USER_HOME/.bashrc
		echo 'export PATH=$PATH:$GRADLE_HOME/bin' >> $LAMW_USER_HOME/.bashrc
	fi

	export PATH=$PATH:$ROOT_LAMW/ndk-toolchain
	export PATH=$PATH:$GRADLE_HOME/bin
}

#Esta funcao altera todos o dono de todos arquivos e  pastas do ambiente LAMW de root para o $LAMW_USER_HOME
#Ou seja para o usuario que invocou o lamw_manager (bootstrap)
changeOwnerAllLAMW(){
	#case only update-lamw
	if [ $# = 1 ]; then
		local files_chown=(
			"$LAMW4_LINUX_PATH_CFG"
			"$ROOT_LAMW/lazandroidmodulewizard"
			"$LAMW_IDE_HOME"
		)
	else

		local files_chown=(
			"$LAMW_USER_HOME/Dev"
			"$ROOT_LAMW"
			"$FPC_CFG_PATH"
			"$LAMW_USER_HOME/.profile"
			"$LAMW_USER_HOME/.bashrc"
			"$LAMW_USER_HOME/.android"
			"$LAMW_USER_HOME/.local/share"
			"$LAMW4_LINUX_PATH_CFG"
			"$LAMW_MANAGER_LOCAL_CONFIG_DIR"
				
		#	
		)

		if [ "$NO_EXISTENT_ROOT_LAMW_PARENT" != "" ]; then
			files_chown+=($NO_EXISTENT_ROOT_LAMW_PARENT)
		fi		
	fi
	echo "Restoring directories ..."
	for ((i=0;i<${#files_chown[*]};i++))
	do
		if [ -e ${files_chown[i]} ] ; then
			if [ $i = 0 ] && [ $# = 0 ] ; then 
				# caso $LAMW_USER não seja dono do diretório LAMW_USER_HOME/Dev ou $LAMW_WORKSPACE_HOME
				if  [ $UID = 0 ] && ( [ -O ${files_chown[i]} ] || [ -O  "$LAMW_WORKSPACE_HOME" ] ); then 
					chown $LAMW_USER:$LAMW_USER -R ${files_chown[i]}
				fi
			else 
				chown $LAMW_USER:$LAMW_USER -R ${files_chown[i]}
			fi
		fi
	done
}
#write log lamw install 
writeLAMWLogInstall(){
	local fpc_version=$FPC_VERSION
	if [ $FLAG_FORCE_ANDROID_AARCH64 = 1 ]; then
		fpc_version=$FPC_TRUNK_VERSION

	fi

	local lamw_log_str=(
		"Generate LAMW_INSTALL_VERSION=$LAMW_INSTALL_VERSION" 
		"Info:"
		"LAMW4Linux:$LAMW4LINUX_HOME"
		"LAMW workspace:$LAMW_WORKSPACE_HOME"
		"Android SDK:$ROOT_LAMW/sdk" 
		"Android NDK:$ROOT_LAMW/ndk"
		"Gradle:$GRADLE_HOME"
		"LAMW_MANAGER PATH:$LAMW_MANAGER_PATH"
		"OLD_ANDROID_SDK=$OLD_ANDROID_SDK"
		"ANT_VERSION=$ANT_VERSION_STABLE"
		"GRADLE_VERSION=$GRADLE_VERSION"
		"SDK_TOOLS_VERSION=$SDK_TOOLS_VERSION"
		"FPC_VERSION=$fpc_version"
		"LAZARUS_VERSION=$LAZARUS_STABLE_VERSION"
		"AARCH64_SUPPORT=$FLAG_FORCE_ANDROID_AARCH64"
		"Install-date:$(date)"
	)

	WriterFileln "$LAMW4LINUX_HOME/lamw-install.log" "lamw_log_str"	
}

#Add LAMW4Linux to menu 
AddLAMWtoStartMenu(){
	[ ! -e $LAMW_USER_HOME/.local/share/applications ] && mkdir -p $LAMW_USER_HOME/.local/share/applications  #create a directory of local apps launcher, if not exists 	
	[ ! -e $LAMW_USER_HOME/.local/share/mime/packages ] && mkdir -p $LAMW_USER_HOME/.local/share/mime/packages
	local lamw_desktop_file_str=(
		"[Desktop Entry]"  
		"Name=LAMW4Linux"
		"Comment=A Lazarus IDE [and all equirements!] ready to develop for Android!" 
		"GenericName=LAMW4Linux"   
		"Exec=$LAMW_IDE_HOME/startlamw4linux"
		"Icon=$LAMW_IDE_HOME/images/icons/lazarus_orange.ico"
		"Terminal=false"
		"Type=Application"  
		"Categories=Development;IDE;"  
		"Categories=Application;IDE;Development;GTK;GUIDesigner;"
		"StartupWMClass=LAMW4Linux"
		"MimeType=text/x-pascal;text/lazarus-project-source;text/lazarus-project-information;text/lazarus-form;text/lazarus-resource;text/lazarus-package;text/lazarus-package-link;text/lazarus-code-inlay;"
		"Keywords=editor;Pascal;IDE;FreePascal;fpc;Design;Designer;"
		"[Property::X-KDE-NativeExtension]"
		"Type=QString"
		"Value=.pas"
		"X-Ubuntu-Gettext-Domain=desktop_kdelibs"
	)

	WriterFileln "$LAMW_MENU_ITEM_PATH" "lamw_desktop_file_str"
	chmod +x $LAMW_MENU_ITEM_PATH
	#mime association: ref https://help.gnome.org/admin/system-admin-guide/stable/mime-types-custom-user.html.en
	cp $LAMW_IDE_HOME/install/lazarus-mime.xml $LAMW_USER_HOME/.local/share/mime/packages
	update-mime-database   $LAMW_USER_HOME/.local/share/mime/
	update-desktop-database $LAMW_USER_HOME/.local/share/applications
	update-menus
}

#this  fuction create a INI file to config  all paths used in lamw framework 
LAMW4LinuxPostConfig(){
	local old_lamw_workspace="$LAMW_USER_HOME/Dev/lamw_workspace"
	[ ! -e $LAMW4_LINUX_PATH_CFG ] && mkdir $LAMW4_LINUX_PATH_CFG
	[ -e $old_lamw_workspace ] && mv $old_lamw_workspace $LAMW_WORKSPACE_HOME
	[ ! -e $LAMW_WORKSPACE_HOME ] && mkdir -p $LAMW_WORKSPACE_HOME

	local ant_path=$ANT_HOME/bin
	local breakline='\\'n
	ant_path=${ant_path%/ant*} #

	#testa modificação de workspace
	if [ -e "$LAMW4_LINUX_PATH_CFG/LAMW.ini" ]; then 
		local current_lamw_workspace=$(grep '^PathToWorkspace=' $LAMW4_LINUX_PATH_CFG/LAMW.ini  | sed 's/PathToWorkspace=//g')
		[ "$current_lamw_workspace" != "$LAMW_WORKSPACE_HOME" ] && LAMW_WORKSPACE_HOME=$current_lamw_workspace	
	fi
# contem o arquivo de configuração do lamw
	local LAMW_init_str=(
		"[NewProject]"
		"PathToWorkspace=$LAMW_WORKSPACE_HOME"
		"PathToSmartDesigner=$ROOT_LAMW/lazandroidmodulewizard/android_wizard/smartdesigner"
		"PathToJavaTemplates=$ROOT_LAMW/lazandroidmodulewizard/android_wizard/smartdesigner/java"
		"PathToJavaJDK=$JAVA_HOME"
		"PathToAndroidNDK=$ROOT_LAMW/ndk"
		"PathToAndroidSDK=$ANDROID_SDK_ROOT"
		"PathToAntBin=$ant_path"
		"PathToGradle=$GRADLE_HOME"
		"PrebuildOSYS=linux-x86_64"
		"MainActivity=App"
		"FullProjectName="
		"InstructionSet=2"
		"AntPackageName=org.lamw"
		"AndroidPlatform=0"
		"AntBuildMode=debug"
		"NDK=6"
	)

	local lamw4linux_env_str=(
		"#!/bin/bash"
		"export PPC_CONFIG_PATH=$PPC_CONFIG_PATH"
		"export JAVA_HOME=$JAVA_HOME"
		"export ANDROID_HOME=$ANDROID_HOME"
		"export ANDROID_SDK_ROOT=$ANDROID_SDK_ROOT"
		"export PATH=$ROOT_LAMW/lamw4linux/usr/bin:\$PPC_CONFIG_PATH:\$JAVA_HOME/bin:\$PATH"
		"LAMW4_LINUX_PATH_CFG=$LAMW4_LINUX_PATH_CFG"
		"LAMW_MANAGER_PATH=$LAMW_MANAGER_PATH"
		"LAMW4LINUX_EXE_PATH=$LAMW4LINUX_EXE_PATH"
		"OLD_LAMW4LINUX_EXE_PATH=${LAMW4LINUX_EXE_PATH}.old"
	)

	local startlamw4linux_str=(
		'#!/bin/bash'
		'#-------------------------------------------------------------------------------------------------#'
		'### THIS FILE IS AUTOMATICALLY CONFIGURED by LAMW Manager'
		'###ou may comment out this entry, but any other modifications may be lost.'
		'#Description: This script is script configure LAMW environment and startLAMW4Linux'
		'#-------------------------------------------------------------------------------------------------#'
		"source $LAMW4LINUX_LOCAL_ENV"
		""
		"if [ ! -e \$LAMW4_LINUX_PATH_CFG ]; then"
		"	zenity_exec=\$(which zenity)"
		"	zenity_message=\"Primary Config Path ( \$LAMW4_LINUX_PATH_CFG ) doesn't exists!!${breakline}Run: './lamw_manager' to fix that! \""
		"	zenity_title=\"Error on start LAMW4Linux\""
		"	[ \"\$zenity_exec\" != \"\" ] &&"
		"		\$zenity_exec --title \"\$zenity_title\" --error --width 480 --text \"\$zenity_message\" &&"
		"		exit 1"
		"fi"
		"if [ ! -e \"\${LAMW4LINUX_EXE_PATH}\" ] && [  -e \"\${OLD_LAMW4LINUX_EXE_PATH}\" ]; then"
		"	zenity_exec=\$(which zenity)"
		"	zenity_message=\"lazarus not found, starting from lazarus.old...\""
		"	zenity_title=\"Missing Lazarus\""
		"	\${zenity_exec} --title \"\${zenity_title}\" --notification --width 480 --text \"\${zenity_message}\""
		"	cp \${OLD_LAMW4LINUX_EXE_PATH} \${LAMW4LINUX_EXE_PATH}" 
		"fi"
		"exec \$LAMW4LINUX_EXE_PATH --pcp=\$LAMW4_LINUX_PATH_CFG \$*"
	)

	WriterFileln "$LAMW4_LINUX_PATH_CFG/LAMW.ini" "LAMW_init_str"
	WriterFileln "$LAMW_IDE_HOME/startlamw4linux" "startlamw4linux_str"
	WriterFileln "$LAMW4LINUX_LOCAL_ENV" lamw4linux_env_str

	if [ -e  $LAMW_IDE_HOME/startlamw4linux ]; then
		chmod +x $LAMW_IDE_HOME/startlamw4linux
		[ ! -e "/usr/bin/startlamw4linux" ] && ln -s "$LAMW_IDE_HOME/startlamw4linux" "/usr/bin/startlamw4linux"
	fi

	AddLAMWtoStartMenu
}

ActiveProxy(){
	svn --help > /dev/null
	if  [ $1 = 1 ]; then
		if [ -e ~/.subversion/servers ] ; then
			aux=$(tail -1 ~/.subversion/servers)       #tail -1 mostra a última linha do arquivo 
			if [ "$aux" != "" ] ; then   # verifica se a última linha é vazia
				sed  -i '$a\' ~/.subversion/servers #adiciona uma linha ao fim do arquivo
			fi
			#echo "write proxy with svn"
			echo "http-proxy-host=$PROXY_SERVER" >> ~/.subversion/servers
			echo "http-proxy-port=$PORT_SERVER" >> ~/.subversion/servers
			git config --global core.gitproxy $PROXY_URL #"http://$HOST:$PORTA"
			git config --global http.gitproxy $PROXY_URL #"http://$HOST:$PORTA"
		fi

	else
		sed -i "/http-proxy-host=$HOST/d" ~/.subversion/servers
		sed -i "/http-proxy-port=$PORTA/d" ~/.subversion/servers
		git config --global --unset core.gitproxy
		git config --global --unset http.gitproxy
		if [ -e ~/.gitconfig ] ;then
		#cat ~/.gitconfig
			sed -i '/\[core\]/d' ~/.gitconfig
			#cat ~/.gitconfig
			sed -i '/\[http\]/d' ~/.gitconfig
		fi
	fi
}
CleanOldCrossCompileBins(){
	wrapperParseFPC
	local lamw_manager_v031=0.3.1
	local clean_files=(
		"$FPC_LIB_PATH/ppcrossarm"
		"/usr/lib/fpc/$FPC_VERSION/fpmkinst/arm-android"
		"/usr/local/lib/fpc/3.3.1"
	)

	local list_deleted_files=(	
		"/usr/bin/ppcarm"
		"/usr/bin/ppcrossarm"
		"/usr/bin/arm-linux-androideabi-ld"
		"/usr/bin/arm-linux-as"
		"/usr/bin/arm-linux-androideabi-as"
		"/usr/bin/arm-linux-ld"
		"/usr/bin/aarch64-linux-android-as"
		"/usr/bin/aarch64-linux-android-ld"
		"/usr/bin/ppca64"
		"/usr/bin/ppcrossa64"
	)


	local index_clean_files_v031=${#clean_files[*]}
	local current_old_lamw_manager=${OLD_LAMW_INSTALL_VERSION[$CURRENT_OLD_LAMW_INSTALL_INDEX]}
	((index_clean_files_v031-=1))

	[ $CURRENT_OLD_LAMW_INSTALL_INDEX -lt  0 ] && return 1



	for((i=0;i<${#list_deleted_files[*]};i++)); do 
		if [ -e ${list_deleted_files[i]} ]; then 
			validate_is_file_create_by_lamw_manager $i ${list_deleted_files[i]}
			[ $? = 0 ] && rm ${list_deleted_files[i]}
		fi
	done

	for((i=0;i<${#clean_files[*]};i++)); do
		if [  -e ${clean_files[i]} ] && [ $i -lt  $index_clean_files_v031 ]  ; then 
			rm -rf ${clean_files[i]}
		else 
			[ -e ${clean_files[i]} ]  && [ $current_old_lamw_manager  = $lamw_manager_v031 ] && rm -rf ${clean_files[i]}
		fi
	done

	if [  -e /usr/local/bin/fpc ] &&  [ $current_old_lamw_manager = $lamw_manager_v031 ]; then
		local fpc_tmp_files=("bin2obj" "chmcmd" "chmls" "cldrparser" "compileserver" "cvsco.tdf" "cvsdiff.tdf" "cvsup.tdf" "data2inc" "delp" "fd2pascal" "fp" "fp.ans" "fpc" "fpcjres" "fpclasschart" "fpclasschart.rsj" "fpcmake" "fpcmkcfg" "fpcmkcfg.rsj" "fpcres" "fpcsubst" "fpcsubst.rsj" "fpdoc" "fppkg" "fprcp" "fp.rsj" "gplprog.pt" "gplunit.pt" "grab_vcsa" "grep.tdf" "h2pas" "h2paspp" "instantfpc" "json2pas" "makeskel" "makeskel.rsj" "mka64ins" "mkarmins" "mkinsadd" "mkx86ins" "pas2fpm" "pas2jni" "pas2js" "pas2ut" "pas2ut.rsj" "plex" "postw32" "ppdep" "ppudump" "ppufiles" "ppumove" "program.pt" "ptop" "ptop.rsj" "pyacc" "rmcvsdir" "rstconv" "rstconv.rsj" "tpgrep.tdf" "unihelper" "unitdiff" "unitdiff.rsj" "unit.pt" "webidl2pas")
		for((i=0;i<${#fpc_tmp_files[*]};i++)); do
			local aux="/usr/local/bin/${fpc_tmp_files[i]}"
			[ -e $aux ] &&  rm $aux
		done
	fi
	
}

	

cleanPATHS(){
	sed -i "/export ANDROID_HOME=*/d"  $LAMW_USER_HOME/.bashrc
	sed -i "/export GRADLE_HOME=*/d" $LAMW_USER_HOME/.bashrc
	sed -i '/export PATH=$PATH:$ANDROID_HOME\/android\/ndk-toolchain/d'  $LAMW_USER_HOME/.bashrc #\/ is scape of /
	sed -i '/export PATH=$PATH:$ANDROID_HOME\/android\/gradle-4.1\/bin/d' $LAMW_USER_HOME/.bashrc
	sed -i '/export PATH=$PATH:$ANDROID_HOME\/android\/ndk-toolchain/d'  $LAMW_USER_HOME/.profile
	sed -i '/export PATH=$PATH:$ANDROID_HOME\/android\/gradle-4.1\/bin/d' $LAMW_USER_HOME/.profile	
	sed -i '/export PATH=$PATH:$ANDROID_HOME\/ndk-toolchain/d'  $LAMW_USER_HOME/.bashrc
	sed -i '/export PATH=$PATH:$GRADLE_HOME/d'  $LAMW_USER_HOME/.bashrc
}


#adiciona criterios de validação para a desinstalação de arquivos criados pelo lamw_manager
validate_last_files_created_by_lamw_manager(){
	if [ $1 = $last_index_deleted_files  ] || [ $1 = $last_but_one_index_deleted_files ]; then
		grep "$ROOT_LAMW" "$2"
	else
		return 0;
	fi

}
#adiciona criterios de validação para a desinstalação de arquivos criados pelo lamw_manager
validate_is_file_create_by_lamw_manager(){
	local very_old_lamw_manager_index=${#OLD_LAMW_INSTALL_VERSION[*]}
	((very_old_lamw_manager_index-=2))

	local size_list_deleted_files=${#list_deleted_files[*]}
	local system_index_deleted_files=11 #index de arquivos criados em /usr
	local last_index_deleted_files=$((size_list_deleted_files - 1))
	local last_but_one_index_deleted_files=$((last_index_deleted_files-1))

	[ $CURRENT_OLD_LAMW_INSTALL_INDEX -lt 0 ] && [  $1 -lt $system_index_deleted_files ] && return 1 #ignora binarios fpc/arm  se o ambiente de desenvolvimento lamw não estiver instalado
		
	 #verifica se o arquivo é um arquivo do criado pelo lamw_manager
	if [ $CURRENT_OLD_LAMW_INSTALL_INDEX -lt $very_old_lamw_manager_index ]; then 
		if [ $1 -lt $system_index_deleted_files ] ; then
			ls -lah "$2" | grep "\->\s$ROOT_LAMW" > /dev/null
		else 
			validate_last_files_created_by_lamw_manager "$1" "$2"
		fi
	else
		validate_last_files_created_by_lamw_manager "$1" "$2"
	fi
}
CleanOldConfig(){
	getStatusInstalation
	[ $LAMW_INSTALL_STATUS = 1 ] && checkLAMWManagerVersion > /dev/null
	wrapperParseFPC
	local list_deleted_files=(
		"/usr/bin/ppcarm"
		"/usr/bin/ppcrossarm"
		"/usr/bin/arm-linux-androideabi-ld"
		"/usr/bin/arm-linux-as"
		"/usr/bin/arm-linux-androideabi-as"
		"/usr/bin/arm-linux-ld"
		"/usr/bin/aarch64-linux-android-as"
		"/usr/bin/aarch64-linux-android-ld"
		"/usr/bin/ppca64"
		"/usr/bin/ppcrossa64"
		"/usr/lib/fpc/$FPC_VERSION/fpmkinst/arm-android"
		"/usr/bin/startlamw4linux"
		"$FPC_CFG_PATH"
		"$LAMW4_LINUX_PATH_CFG"
		"$ROOT_LAMW"
		"$LAMW_MENU_ITEM_PATH"
		"$WORK_HOME_DESKTOP/lamw4linux.desktop"
		"$LAMW_USER_HOME/.local/share/mime/packages/lazarus-mime.xml"
		"$FPC_TRUNK_LIB_PATH"
		"/root/.fpc.cfg"
		"$OLD_FPC_CFG_PATH"
	)

	echo "Uninstalling LAMW4Linux IDE ..."

	for((i=0;i<${#list_deleted_files[*]};i++))
	do
		if [ -e "${list_deleted_files[i]}" ]; then 
			[ -d  "${list_deleted_files[i]}" ] && local rm_opts="-rf"
			validate_is_file_create_by_lamw_manager $i "${list_deleted_files[i]}"
			[ $? = 0 ] && rm  "${list_deleted_files[i]}" $rm_opts
		fi
	done

	CleanOldCrossCompileBins
	update-mime-database   $LAMW_USER_HOME/.local/share/mime/
	update-desktop-database $LAMW_USER_HOME/.local/share/applications
	cleanPATHS
	unsetLocalRootLAMW
}

#Create SDK simbolic links
CreateSDKSimbolicLinks(){

	local real_ppcarm="$FPC_TRUNK_LIB_PATH/ppcrossarm"	
	local tools_chains_orig=(
		"$ROOT_LAMW/sdk/ndk-bundle"
		"$LLVM_ANDROID_TOOLCHAINS"
		"$ARM_ANDROID_TOOLS/arm-linux-androideabi-as"
		"$ARM_ANDROID_TOOLS/arm-linux-androideabi-ld"
		"$ARM_ANDROID_TOOLS/arm-linux-androideabi-as"
		"$ARM_ANDROID_TOOLS/arm-linux-androideabi-ld"
		"$ARM_ANDROID_TOOLS/arm-linux-androideabi-as"
		"$ROOT_LAMW/sdk/ndk-bundle/toolchains/arm-linux-androideabi-4.9"
		"$ROOT_LAMW/sdk/ndk-bundle/toolchains/arm-linux-androideabi-4.9"
		"$real_ppcarm"
		"$real_ppcarm"
		"$FPC_TRUNK_LIB_PATH/ppcx64"

	)


	local tools_chains_s_links=(
		"$ROOT_LAMW/ndk"
		"$ROOT_LAMW/ndk-toolchain"
		"$ROOT_LAMW/ndk-toolchain/arm-linux-as"
		"$ROOT_LAMW/ndk-toolchain/arm-linux-ld"
		"$ROOT_LAMW/lamw4linux/usr/bin/arm-linux-androideabi-as"
		"$ROOT_LAMW/lamw4linux/usr/bin/arm-linux-androideabi-ld"
		"$ROOT_LAMW/lamw4linux/usr/bin/arm-linux-androideabi-as"
		"$ROOT_LAMW/sdk/ndk-bundle/toolchains/mips64el-linux-android-4.9"
		"$ROOT_LAMW/sdk/ndk-bundle/toolchains/mipsel-linux-android-4.9"
		"$ROOT_LAMW/lamw4linux/usr/bin/ppcrossarm"
		"$ROOT_LAMW/lamw4linux/usr/bin/ppcarm"
		"$ROOT_LAMW/lamw4linux/usr/bin/ppcx64"
	)


	for ((i=0;i<${#tools_chains_orig[*]};i++))
	do
		if [  -e "${tools_chains_s_links[i]}" ]; then  
			rm "${tools_chains_s_links[i]}"
		fi		
		ln -sf "${tools_chains_orig[i]}" "${tools_chains_s_links[i]}"	
	done 

}
#--------------------------AARCH64 SETTINGS--------------------------

configureFPCTrunk(){
	# parte do arquivo de configuração do fpc, 
	#	if [ ! -e $FPC_CFG_PATH ]; then
	parseFPCTrunk
	$FPC_MKCFG_EXE -d basepath="$FPC_TRUNK_LIB_PATH" -o "$FPC_CFG_PATH"
	local fpc_trunk_parent="$(dirname "$FPC_TRUNK_LIB_PATH")"

	#this config enable to crosscompile in fpc 
	local fpc_cfg_str=(
		"#IFDEF ANDROID"
		"#IFDEF CPUARM"
		"-CpARMV7A"
		"-CfVFPV3"
		"-Xd"
		"-XParm-linux-androideabi-"
		"-Fl$ROOT_LAMW/ndk/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/arm-linux-androideabi/$ANDROID_SDK_TARGET"
		"-FLlibdl.so"
		"-FD${ARM_ANDROID_TOOLS}"
		"#ENDIF"
		"#IFDEF CPUAARCH64"
		"-Xd"
		"-XPaarch64-linux-android-"
		"-Fl$ROOT_LAMW/ndk/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/aarch64-linux-android/$ANDROID_SDK_TARGET"
		"-FLlibdl.so"
		"-FD${AARCH64_ANDROID_TOOLS}"
		"#ENDIF"
		"#IFDEF CPUI386"
		"-Cfsse3"
		"-Xd"
		"-XPi686-linux-android-"
		"-FLlibdl.so"
		"-FD${I386_ANDROID_TOOLS}"
		"-Fl$ROOT_LAMW/ndk/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/i686-linux-android/$ANDROID_SDK_TARGET"
		"#ENDIF"
		"#IFDEF CPUX86_64"
		"-Cfsse3"
		"-Xd"
		"-XPx86_64-linux-android-"
		"-FD${AMD64_ANDROID_TOOLS}"
		"-FLlibdl.so"
		"-Fl$ROOT_LAMW/ndk/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/x86_64-linux-android/$ANDROID_SDK_TARGET"
		"#ENDIF"
		"#ENDIF"
	)

	local fppkg_local_cfg=(
		'[Defaults]'
		'ConfigVersion=5'
		"Compiler=$FPC_TRUNK_EXEC_PATH/fpc"
		'OS=Linux'
	)
	local fpcpkg_cfg_str=(
			"[Defaults]"
			"ConfigVersion=5"
			"LocalRepository=$(dirname $FPPKG_LOCAL_REPOSITORY)/"
			"BuildDir={LocalRepository}build/"
			"ArchivesDir={LocalRepository}archives/"
			"CompilerConfigDir={LocalRepository}config/"
			"RemoteMirrors=https://www.freepascal.org/repository/mirrors.xml"
			"RemoteRepository=auto"
			"CompilerConfig=default"
			"FPMakeCompilerConfig=default"
			"Downloader=FPC"
			"InstallRepository=user"
			""
			"[Repository]"
			"Name=fpc"
			"Description=Packages which are installed along with the Free Pascal Compiler"
			"Path=${fpc_trunk_parent}/{CompilerVersion}/"
			"Prefix=$LAMW4LINUX_HOME/usr"
			""
			"[IncludeFiles]"
			"FileMask={LocalRepository}config/conf.d/*.conf"
			""
			"[Repository]"
			"Name=user"
			"Description=User-installed packages"
			"Path={LocalRepository}lib/fpc/{CompilerVersion}"
			"Prefix={LocalRepository}"
		)
	
	WriterFileln "$FPPKG_TRUNK_CFG_PATH" fpcpkg_cfg_str
	WriterFileln "$FPPKG_LOCAL_REPOSITORY_CFG" fppkg_local_cfg

	if [ -e $FPC_CFG_PATH ] ; then  # se exiir /etc/fpc.cfg
		searchLineinFile $FPC_CFG_PATH  "${fpc_cfg_str[0]}"
		flag_fpc_cfg=$?
		[ $flag_fpc_cfg != 1 ] && AppendFileln "$FPC_CFG_PATH" "fpc_cfg_str" # caso o arquvo ainda não esteja configurado
	fi
}



CreateSimbolicLinksAndroidAARCH64(){
	ln -sf "$AARCH64_ANDROID_TOOLS/aarch64-linux-android-as" "$LLVM_ANDROID_TOOLCHAINS/aarch64-linux-as"
	ln -sf "$AARCH64_ANDROID_TOOLS/aarch64-linux-android-ld" "$LLVM_ANDROID_TOOLCHAINS/aarch64-linux-ld"
	ln -sf "$AARCH64_ANDROID_TOOLS/aarch64-linux-android-as" "$ROOT_LAMW/lamw4linux/usr/bin/aarch64-linux-android-as"
	ln -sf "$AARCH64_ANDROID_TOOLS/aarch64-linux-android-ld" "$ROOT_LAMW/lamw4linux/usr/bin/aarch64-linux-android-ld"
	ln -sf "${FPC_TRUNK_LIB_PATH}/ppcrossa64" $ROOT_LAMW/lamw4linux/usr/bin/ppcrossa64
	ln -sf "${FPC_TRUNK_LIB_PATH}/ppcrossa64" $ROOT_LAMW/lamw4linux/usr/bin/ppca64
}

CreateBinutilsSimbolicLinks(){
	if [ ! -e "$ROOT_LAMW/lamw4linux/usr/bin" ]; then 
		mkdir -p "$ROOT_LAMW/lamw4linux/usr/bin"
	fi
	CreateSDKSimbolicLinks
	if [ $FLAG_FORCE_ANDROID_AARCH64 = 1 ]; then
		CreateSimbolicLinksAndroidAARCH64
	fi
}

#echo "importei lamw-settings-editor.sh";read

createLazarusEnvCfgFile(){
	local lazarus_env_cfg_str=(
		'<?xml version="1.0" encoding="UTF-8"?>'
		'<CONFIG>'
		'	<EnvironmentOptions>'
		"		<Version Value=\"110\" Lazarus=\"${lazarus_version_str}\"/>"
		"		<LazarusDirectory Value=\"${LAMW_IDE_HOME}/\"/>"
		"		<LastCalledByLazarusFullPath Value=\"${LAMW_IDE_HOME}/lazarus\"/>"
		"		<CompilerFilename Value=\"$FPC_TRUNK_EXEC_PATH/fpc\"/>"
		"		<FPCSourceDirectory Value=\"${FPC_TRUNK_SOURCE_PATH}/${FPC_TRUNK_SVNTAG}\">" 
		"		</FPCSourceDirectory>"
		"		<MakeFilename Value=\"$(which make)\">"
		"		</MakeFilename>"
		"		<TestBuildDirectory Value=\"/tmp\">"
		"		</TestBuildDirectory>"
		"		<FppkgConfigFile Value=\"${FPPKG_TRUNK_CFG_PATH}\"/>"
		'    	<Debugger Class="TGDBMIDebugger">'
		'			<Configs>'
		'				<Config ConfigName="FpDebug" ConfigClass="TFpDebugDebugger" Active="True"/>'
		"				<Config ConfigName=\"Gdb\" ConfigClass=\"TGDBMIDebugger\" DebuggerFilename=\"$(which gdb)\"/>"
		'			</Configs>'
		"		</Debugger>"
		"	</EnvironmentOptions>"
		"</CONFIG>"
	)

	if [  ! -e "$lazarus_env_cfg_path" ]; then 
		WriterFileln  "$lazarus_env_cfg_path" "lazarus_env_cfg_str"
	fi
}


getNodeAttrXML(){
	xmlstarlet sel -t -v "$1" "$2"
}


updateNodeAttrXML(){
	newPtr xml_node_attr_ref=$1
	newPtr xml_new_node_attr_values=$2
	local xml_file_path="$3"
	
	for key in ${!xml_node_attr_ref[*]}; do 
		local node_attr="${xml_node_attr_ref[$key]}"
		local current_node_attr_value="$(getNodeAttrXML $node_attr $xml_file_path )"
		local expected_node_attr_value=${xml_new_node_attr_values[$key]}
			
		[ "$current_node_attr_value" != "$expected_node_attr_value" ] &&  #update attribute ref:#ref: https://stackoverflow.com/questions/7837879/xmlstarlet-update-an-attribute
			xmlstarlet edit  --inplace  -u "$node_attr" -v "$expected_node_attr_value" "$xml_file_path"
		
	done

}

initLAMw4LinuxConfig(){
	local lazarus_version_str="`$LAMW_IDE_HOME/tools/install/get_lazarus_version.sh`"	
	local lazarus_env_cfg_path="$LAMW4_LINUX_PATH_CFG/environmentoptions.xml"
	local fppkg_cfg_node_attr="//CONFIG/EnvironmentOptions/FppkgConfigFile/@Value"	
	local env_opts_node="//CONFIG/EnvironmentOptions"
	local fppkg_cfg_node_attr="$env_opts_node/FppkgConfigFile/@Value"
	local fppkg_cfg_node="$env_opts_node/FppkgConfigFile"

	local -A lazarus_env_xml_nodes_attr=(
		['lazarus_version']="$env_opts_node/Version/@Lazarus"
		['lazarus_dir']="$env_opts_node/LazarusDirectory/@Value"
		['compiler_file']="$env_opts_node/CompilerFilename/@Value"
		['fpc_src']="$env_opts_node/FPCSourceDirectory/@Value"
	)

	local -A expected_env_xml_nodes_attr=(
		['lazarus_version']=$lazarus_version_str
		['lazarus_dir']=$LAMW_IDE_HOME
		['compiler_file']=$FPC_TRUNK_EXEC_PATH/fpc
		['fpc_src']=${FPC_TRUNK_SOURCE_PATH}/${FPC_TRUNK_SVNTAG}
	)

	if [ ! -e "$lazarus_env_cfg_path" ]; then
		createLazarusEnvCfgFile
	else
		grep 'LastCalledByLazarusFullPath' $lazarus_env_cfg_path > /dev/null
		if [ $? = 0 ]; then 
			local lazarus_env_xml_nodes_attr['last_laz_full_path']="${env_opts_node}/LastCalledByLazarusFullPath/@Value"
			local expected_env_xml_nodes_attr['last_laz_full_path']=$LAMW4LINUX_EXE_PATH
		fi

		[ -e  "${lazarus_env_cfg_path}.bak" ] && 
			rm "${lazarus_env_cfg_path}.bak" 
		cp $lazarus_env_cfg_path "${lazarus_env_cfg_path}.bak" 

		updateNodeAttrXML lazarus_env_xml_nodes_attr expected_env_xml_nodes_attr "$lazarus_env_cfg_path"

		grep 'FppkgConfigFile' $lazarus_env_cfg_path > /dev/null 

		if [ $? != 0 ]; then #insert fppkg_config ref: https://stackoverflow.com/questions/7837879/xmlstarlet-update-an-attribute
			xmlstarlet ed  --inplace -s "$env_opts_node" -t elem -n "FppkgConfigFile" -v "" -i $fppkg_cfg_node -t attr -n "Value" -v "$FPPKG_TRUNK_CFG_PATH" $lazarus_env_cfg_path
		else # update fppkg_config
			local current_fppkg_config_value=$(getNodeAttrXML "$fppkg_cfg_node_attr" $lazarus_env_cfg_path )
			[ "$current_fppkg_config_value" != "${FPPKG_TRUNK_CFG_PATH}" ] && 
				xmlstarlet edit  --inplace  -u "$fppkg_cfg_node_attr" -v "$FPPKG_TRUNK_CFG_PATH" "$lazarus_env_cfg_path"	
		fi 
	fi
}