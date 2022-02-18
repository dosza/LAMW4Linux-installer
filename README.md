# LAMW Manager


[![Version](https://img.shields.io/badge/Release-v0.4.7-blue)](https://github.com/dosza/LAMWManager-linux/blob/v0.4.7/lamw_manager/docs/release_notes.md#v047---feb-19-2022) [![Build-status](https://img.shields.io/badge/build-stable-brightgreen)](https://raw.githubusercontent.com/dosza/LAMWManager-linux/master/lamw_manager/assets/lamw_manager_setup.sh) [![license](https://img.shields.io/github/license/dosza/LAMWManager-linux)](https://github.com/dosza/LAMWManager-linux/LICENSE) [![Stars](https://img.shields.io/github/stars/dosza/LAMWManager-linux?style=default)](https://github.com/dosza/LAMWManager-linux/stargazers)

LAMW Manager is a command line tool,like *APT*, to automate the **installation**, **configuration** and **upgrade**<br/>the framework [LAMW - Lazarus Android Module Wizard](https://github.com/jmpessoa/lazandroidmodulewizard)


What do you get?
---
A [Lazarus IDE](http://www.lazarus-ide.org) ready to develop applications for Android !!

Linux Distro Supported:
---
	
<p>
	<ul>
		<li><img src="https://www.debian.org/logos/openlogo-nd.svg" style="width: 16px;"/> Debian GNU/ Linux 10</li>
		<li><img src="https://assets.ubuntu.com/v1/29985a98-ubuntu-logo32.png" style="width: 16px;"/> Ubuntu 18.04 LTS</li>
		<li><img src="https://upload.wikimedia.org/wikipedia/commons/thumb/3/35/Tux.svg/249px-Tux.svg.png" style="width: 16px;"/> <a href="https://github.com/dosza/LAMWManager-linux/blob/master/lamw_manager/docs/other-distros-info.md">Requirements for other Linux</a></li>
	</ul>
</p>


LAMW Manager install the following [dependencies] tools:
---
+	Gradle
+	Freepascal Compiler
	+	Crosscompile to ARMv7-vFPV3/android
	+ 	Crosscompile to AARCH64/android
	+	**New:** Crosscompile to **i386/android**
	+	**New:** Crosscompile to **amd64/android**
+	Lazarus IDE
+	Android NDK
+	Android SDK
	+	Android Platform API¹
	+	Android Platform Tools¹
	+ 	Android Build Tools
	+	Android Extras
		+	Android M2Repository
		+	Android APK Expansion
		+	Android Market License (Client Library)
		+	Google Play Services
+	OpenJDK
+	LAMW framework
+	Create **<img src="https://gitlab.com/freepascal.org/lazarus/lazarus/-/raw/main/images/icons/lazarus_orange.ico" style="width: 20px"/> LAMW4Linux** menu launcher and **startlamw4linux** command!
+	Register **MIME**


**Notes**
1. The minimum Android API and Build Tools required by LAMW and specified in [*package.json*](https://github.com/jmpessoa/lazandroidmodulewizard/blob/master/package.json) are installed 

Getting Started!!
---
**How to use LAMW Manager:**
+	Click here to download [*LAMW Manager Setup*](https://raw.githubusercontent.com/dosza/LAMWManager-linux/master/lamw_manager/assets/lamw_manager_setup.sh)
+	Go to download directory and right click *Open in Terminal*
+	Run command : *bash lamw_manager_setup.sh*¹


**New: Installing LAMW on custom directory**
Now you  can install LAMW on custom directory using command:


```console 
user@pc:~$ #env LOCAL_ROOT_LAMW=your_dir bash lamw_manager_setup.sh
user@pc:~$ #Sample:
user@pc:~$ env LOCAL_ROOT_LAMW=/opt/LAMW bash lamw_manager_setup.sh
```

**Notes:**
+	See the [*LAMW Manager Setup Guide*](https://drive.google.com/open?id=1B6fvTgJ-W7OS7I4mGCZ4sH0U3GqyAeUg)
+	Read more about new installer procedure in [*LAMW Manager Setup*](https://github.com/dosza/LAMWManager-linux/blob/master/lamw_manager/docs/lamw_manager_setup.md)
+	You can also install from sources read more in [*Classic Install*](https://github.com/dosza/LAMWManager-linux/blob/master/lamw_manager/docs/classic-install.md)
+	Replace *your_dir* with the directory of your choice, eg */opt/LAMW*

Know Issues
---
#### Cannot Build LAMW Demos ####

By default LAMW Manager uses (Android) Crosscompile to **ARMv7+vFPV3**, but [*LAMW Demos*](https://github.com/jmpessoa/lazandroidmodulewizard/tree/master/demos) uses **ARMV6+Cfsoft**, you need apply this configuration:
1.	Open your LAMW Demo with LAMW4Linux
2.	On menu bar go to Project --> Project Options ... --> [LAMW] Android Project Options --> Build --> Chipset --> ARMV7a+FVPv3

#### Errors on Start LAMW4Linux on Xubuntu ####
Recommended: Restart your desktop seassion


Release Notes:
---
For information on new features and bug fixes read the [*Release Notes*](https://github.com/dosza/LAMWManager-linux/blob/v0.4.7/lamw_manager/docs/release_notes.md#v047---feb-19-2022)

Congratulations!!
---
You are now a Lazarus for Android developer!</br>[Building Android application with **LAMW** is **RAD**!](https://drive.google.com/open?id=1CeDDpuDfRwYrKpN7VHbossH6GfZUfqjm)

For more info read [**LAMW Manager v0.4.7 Manual**](https://github.com/dosza/LAMWManager-linux/blob/v0.4.7/lamw_manager/docs/man.md)

