#!/bin/bash

set -o nounset

action=$1
java_home=$2

function detect_linux() {  
  [ -f "/etc/SuSE-release" ] && { echo -ne "suse"; return; }
  [ -f "/etc/lsb-release"  ] && { echo -ne "ubuntu"; return; }
  echo -ne "unknown"
}

function alternatives_manager() {
 local action linux java_home
 
 action=$1
 linux=$2
 java_home=$3

 case "$action" in
  activate)
	echo "Activating on $linux"
	case "$linux" in
	  ubuntu)
		manage_on_ubuntu activate $java_home
          ;;
          suse)
		manage_on_suse activate $java_home
	  ;;
        esac
  ;;
  deactivate)
    echo "Deactivating on $linux"
	case "$linux" in
	  ubuntu)
		manage_on_ubuntu deactivate $java_home
          ;;
          suse)
		manage_on_suse deactivate $java_home
	  ;;
        esac
  ;;
  *)
    echo "Unknown action : $action"
    exit 2
  ;;
 esac

}

function manage_on_ubuntu() {
 local action java_home

 action=$1
 java_home=$2

 local prio=10000
 local progs="java appletviewer extcheck idlj jar \
jarsigner javac javadoc javah \
javap jcmd jconsole jdb jhat \
jinfo jmap jps jrunscript jsadebugd \
jstack jstat jstatd native2ascii rmic \
schemagen serialver wsgen wsimport xjc"

 case "$action" in
  activate)
	for bin in $progs
	 do
	  link=/usr/bin/$bin
	  bin_path=$java_home/bin/$bin
	  man_path=$java_home/man/man1/${bin}.1.gz

	  if [ -f $man_path  ]
	  then
	   update-alternatives --install /usr/bin/$bin $bin $bin_path $prio \
	       --slave /usr/share/man/man1/${bin}.1.gz ${bin}.1.gz $man_path
	  else
	    update-alternatives --install /usr/bin/$bin $bin $bin_path $prio
	  fi
	 done
  ;;
  deactivate)
	for bin in $progs
	 do
	  link=/usr/bin/$bin
	  bin_path=$java_home/bin/$bin
	  update-alternatives --remove $bin $bin_path
	 done
  ;;
 esac
}


linux=$(detect_linux)
[ $linux == "unknown" ] && { echo "Unknown linux"; exit 2; }

[ ! -d $java_home ] && { echo "Not a directory : $java_home"; exit 3;  }
java_home_full_path=$(readlink -f $java_home)

alternatives_manager $action $linux $java_home_full_path
