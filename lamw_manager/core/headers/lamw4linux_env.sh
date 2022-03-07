#!/bin/bash
#-------------------------------------------------------------------------------------------------#
#Universidade federal de Mato Grosso (Alma Mater)
#Course: Science Computer
#Version: 0.4.8
#Date: 03/07/2022
#Description: The "lamw_headers" is part of the core of LAMW Manager. This script contains LAMW Manager variables.
#-------------------------------------------------------------------------------------------------#
LAMW4_LINUX_PATH_CFG="$LAMW_USER_HOME/.lamw4linux"
LAMW4LINUX_HOME="$ROOT_LAMW/lamw4linux"
LAMW_INSTALL_LOG="$LAMW4LINUX_HOME/lamw-install.log"
LAMW4LINUX_ETC="$LAMW4LINUX_HOME/etc"
LAMW4LINUX_LOCAL_ENV="$LAMW4LINUX_ETC/environment"
IGNORE_XFCE_LAMW_ERROR_PATH="$LAMW4LINUX_ETC/lamw-xfce-error.conf"
LAMW_WORKSPACE_HOME="$LAMW_USER_HOME/Dev/LAMWProjects"  #path to lamw_workspace
LAMW_MENU_ITEM_PATH="$LAMW_USER_HOME/.local/share/applications/lamw4linux.desktop"
FPPKG_LOCAL_REPOSITORY="$LAMW4LINUX_HOME/.fppkg/config"
FPPKG_LOCAL_REPOSITORY_CFG=$FPPKG_LOCAL_REPOSITORY/default
OLD_ANDROID_SDK=0
LAMW_INSTALL_STATUS=0
LAMW_IMPLICIT_ACTION_MODE=0
FLAG_FORCE_ANDROID_AARCH64=1

INDEX_FOUND_USE_PROXY=-1
CURRENT_OLD_LAMW_INSTALL_INDEX=-1
MAGIC_TRAP_INDEX=-1

USE_PROXY=0
TIME_WAIT=2
NEED_XFCE_MITIGATION=0
LAMW_MINIMAL_INSTALL=0
MIN_LAMW_ARCHS=3