#=====begin of copyright notice=====
copyright()
{
	echo -e "
	
	THE AULIX_UTILS FOR DEBIAN AND CENTOS \n
	The AUTHOR of this file is Alexander Borisovich Prokopyev, Kurgan, Russia \n
	More info can be found at the AUTHOR's website: http://www.aulix.com/resume \n
	Contact: alexander.prokopyev at aulix dot com \n
	 
	Copyright (c) Alexander Prokopyev, 2006-2014 \n
 
	All materials contained in this file are protected by copyright law. \n
	Nobody except the AUTHOR may alter or remove this copyright notice from copies of the content. \n
	 
	The AUTHOR allows to use this content under AGPL v3 license:
	http://opensource.org/licenses/agpl-v3.html
	
	";
}

copyright;
#=====end of copyright notice=====

# Compare package management syntax:
# 	https://wiki.archlinux.org/index.php/Pacman/Rosetta
# 	https://wiki.alpinelinux.org/wiki/Comparison_with_other_distros

Action=$1;

echo "Start the proxy on the workstation!";
echo;echo;echo;

#source /utils/custom/use_proxy.sh;
#set -x;

#Distro=`lsb_release -i | awk '{print $3}'`;
#case $Distro in
#	( Debian | Ubuntu | Devuan )
		PkgType="deb";
#	;;
#	( CentOS )
#		PkgType="rpm";
#	;;
#	( * )
#		echo "Error: unknown distro: $Distro !";
#		exit 1;
#	;;
#esac;

info_deb()
{
	wajig describe $1; # -vv # wajig what-is
	wajig detail $1; #apt-cache showpkg $1;
	echo "--- DPKG Status -------------------------"
	dpkg --status $1;
	echo "--- Contains files ----------------------"
	wajig list-files $1;
	scripts_deb $1;
	echo "--- Other dependands --------------------"
	wajig dependents $1;
}

info_rpm()
{
	rpm -qi $1;
	rpm -ql $1; # list files
}

sections_deb()
{
	wajig list-sections;
}
                                                                                               

purge_deb()
{
	apt-get --yes autoremove;
	dpkg --get-selections | awk '/deinstall/ {print $1}' | xargs dpkg --purge;
	sync;
}

purge2_deb()
{
	wajig remove-orphans;
}



remove_deb()
{
	apt-get remove $@;
}

remove_rpm()
{
	yum remove $@;
}

file_deb()
{
	wajig whichpkg $1;
	wajig find-file $1;
	dpkg --search $1;
}

file_rpm()
{
	rpm -qf | grep $1;
}

search_deb()
{
	dpkg -al | grep -i $1;
	wajig status-search $1;
}

large_deb()
{
	wajig size | tail -n 100;
}

best_deb()
{
	wajig search-apt squeeze;
}

verify_deb()
{
	apt-get --reinstall -d install `debsums -l`;
	wajig integrity  2>&1;
}

restore_deb()
{
	FromFile=$1;
	wajig fileinstall $FromFile;
}

fix_bash_deb()
{
#	rm /bin/sh;
#	ln -s /bin/bash /bin/sh;
# use alter instead!
	echo ""; # not blank body
}

upgrade_deb()
{
#	set -x;

#	DirName="/boot/kernel.bak/"$(date +\%Y_\%m_\%d__\%H_\%M_\%S);
#	mkdir $DirName;
#	cp /boot/*-2.6.* $DirName/;
	apt-get update;
	apt-get dist-upgrade -t ascii-backports;
#	fix_bash_deb;
}

extract_deb()
{
	ar x $1;
	/utils/pkg/untar/gz.sh data.tar.gz;
	rm -f control.tar.gz data.tar.gz debian-binary;
#	chown -R alex:alex /download/lib64;
}

tar() # outputs in tar format to console; can redirect to file.tar
{
	dpkg --fsys-tarfile $1;
}	

extract_rpm()
{
	rpm2cpio $1 | cpio -idmv;
}

create_repo_rpm()
{
	createrepo /var/cache/yum/core/packages;
	createrepo /var/cache/yum/updates/packages;
	createrepo /var/cache/yum/extras/packages;
	createrepo /var/cache/yum/livna/packages;
	createrepo /var/cache/yum/openoffice/packages;
}

scripts_deb()
{
	echo "Listing SCRIPTS in: /var/lib/dpkg/info/";
	ls -al /var/lib/dpkg/info/ | grep $1;
}

config_deb()
{
	apt-config dump;
}

list_installed_rpm()
{
	rpm -qa | grep -i "$1";
	# show architecture # rpm -qa --qf "%{name}-%{version}-%{release}.%{arch}\n"
}

#list_installed_deb()
#{
#	ToFile=$1;
#	wajig listinstalled > $ToFile;
#}


list_installed_deb()
{
#	dpkg --get-selections | cut -f1 | sort;
#	dpkg --get-selections;
	apt-mark showmanual;
}

install_listed_deb()
{
	set -x;
	ListFile=$@;
	#dpkg --set-selections < $ListFile;
	apt-get install $(cat $ListFile);
}

install_deb()
{
	apt-get install $@;
}

install_rpm()
{
	yum install $@;
}

install_backport_deb()
{
	echo "Uncomment following line in the /etc/apt/source.list: deb http://ftp.debian.org/debian experimental main";
	apt-get update;
#	apt-get -t sid install $@; #experimental
	apt-get -t ascii-backports $@;
}

reinstall_deb()
{
#	wajig reinstall $@;
	apt-get -o Dpkg::Options::="--force-confask" --reinstall -d install $@; 
	#--force-reinstall true
	#--yes
}

add_key_helper()
{
	KeyHost=$1;
	Key=$2;
	apt-key adv --keyserver $KeyHost --recv $Key;
	return $?;
}

add_key_helper2()
{
	KeyHost=$1;
        Key=$2;
#	apt-key adv --keyserver $KeyHost --recv $Key;

	if gpg  --keyserver $KeyHost --recv-keys $Key; then
	{
		gpg --export -a $Key  |  apt-key add -;
		return $?;
	}
	else
	{
		return 1;
	} fi;
}


add_key_deb()
{
	set -x;

#	if ! add_key_helper keyring.debian.org $1; then
#	{
#		add_key_helper keyserver.ubuntu.com $1;
#	} fi;

	add_key_helper1 keyserver.ubuntu.com $1;
	add_key_helper2 keyserver.ubuntu.com $1;	
#	http://keys.gnupg.net/	
#	pool.sks-keyservers.net 	
	
	return $?;

# apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF

#	apt-key add --recv-keys --keyserver keyring.debian.org  key-fingerprint $1;
#	apt-key adv --keyserver keyserver.ubuntu.com --recv
#	gpg --keyserver subkeys.pgp.net --recv 85A3D26506C4AE2A
#	gpg -a --output pub.asc --export 85A3D26506C4AE2A
#	apt-key add pub.asc


#	apt-key adv –keyserver subkeys.pgp.net –recv-keys 4BD9A338
	
}

waste_deb()  
{
	deborphan --guess-all | sort;
#       debfoster;
}

purge_waste_deb()
{
	for i in {1..5}
	do
		apt-get remove $(waste_deb);

	done;
	purge_deb;
	purge2_deb;
}

diff_config_deb()
{
	File=$1;
	/utils/pkg/debdiffconf.sh $File;
}

#gen_deb()
#{
#
#}

reconfigure_deb()
{
	dpkg-reconfigure --all -u;
}

upgrade_remote_deb()
{
	set -x;
	Host=$1;
	DebDir="/var/cache/apt/archives";
	/utils/rsync.sh data $DebDir/ $Host:$DebDir/;
}

hold_deb()
{
	echo $Package" hold" | dpkg --set-selections;
#        echo "$1 install" | dpkg --set-selections;
}

get_home_debs()
{
	/utils/rsync.sh data home:/var/cache/apt/archives/*.deb /var/cache/apt/archives/;
}	

convert_from_rpm_deb()
{
	for f in *.rpm; do
        	fakeroot alien --to-deb --scripts --keep $f;
	done;
}

remote_install_deb()
{
	HostName=$1;
	RPMName=$2;
	cat $RPMName | ssh $HostName "rpm -Uvh -";
}

edit_deb()
{

# edit the control data of a deb file,
# usually to get round a dependency problem
# adapted from http://ubuntuforums.org/showthread.php?t=636724
# needs libnotify-bin for notifications if used without a terminal

# choose your editor:
	EDITOR=joe


	[[ "$1" ]] ||  { echo "Syntax: $0 debfile" >&2; exit 1; }

	DEBFILE="$1"
	TMPDIR=$(mktemp -d /tmp/deb.XXXXXXXXXX) || exit 1
	OUTPUT="${DEBFILE%.deb}".modfied-$( date +%FT%T ).deb

	if [[ -e "$OUTPUT" ]]; then
  		echo "$0: $OUTPUT exists." >&2
    		rm -r "$TMPDIR"
      		exit 1
   	fi
      
      	dpkg-deb -x "$DEBFILE" "$TMPDIR"
      	dpkg-deb --control "$DEBFILE" "$TMPDIR"/DEBIAN
      	CONTROL="$TMPDIR"/DEBIAN/control
      	[[ -e "$CONTROL" ]] || {
        	echo "$0: DEBIAN/control not found in $1." >&2
  	    	[ -t 1 ] || notify-send "$1: DEBIAN/control not found."
        	rm -r "$TMPDIR"
        	exit 1
        }
             
        MOD=$(md5sum "$CONTROL")
        $EDITOR "$CONTROL"
              
        if [[ $MOD = $(md5sum "$CONTROL") ]]; then
        	[ -t 1 ] && echo "Not modfied."
        else
                [ -t 1 ] && echo "Building new deb..." || notify-send "Building new deb..." "Please wait a moment."
                dpkg -b "$TMPDIR" "$OUTPUT"
                [ -t 1 ] && echo "Built new debfile: $OUTPUT" || notify-send "Built new debfile:" "$OUTPUT"
        fi
                     
        rm -r "$TMPDIR"
        exit
}

list_video_deb()
{
	/utils/apm.sh list_installed | sort | grep -e glx -e mesa -e drm -e nvidia -e radeon -e xserver -e xorg;
}


#show_url()
#{
#	--print-uris
#}


case $Action in
( info | search | large | install | install_listed | install_backport | remove | purge | purge2 | sections | file | best | installed | reinstall | verify | save | restore | search | deps | upgrade | extract | 2tar | scripts | config | hold | list_installed | add_key | waste | purge_waste | reconfigure | upgrade_remote | get_debs | edit | remote_install | list_video | diff_config )
	$Action"_"$PkgType ${@:2};
;;

#( install )
#	$Action ${@:2};
#;;
#
#( install_sid )
#	$Action"_"$PkgType ${@:2};
#;;

( * )
	echo "Unknown action: $Action !";
;;
esac;

# Devuan redirections:
# https://pkgmaster.devuan.org/merged/pool/DEVUAN/main/s/sysvinit/sysvinit_2.88dsf-59.9+devuan2_amd64.deb
# https://pkgmaster.devuan.org/merged/pool/DEBIAN/main/libc/libcurses-perl/libcurses-perl_1.36-1+b1_amd64.deb
# https://pkgmaster.devuan.org/devuan
# https://pkgmaster.devuan.org/

#Actual Debian package locations:
#https://cdn-aws.deb.debian.org/debian/pool/

#file: /etc/apt/sources.list
#deb http://http.us.debian.org/debian/ squeeze main contrib non-free
#deb http://http.us.debian.org/debian/ sid main contrib non-free

#file /etc/apt/preferences:
#Package: *
#Pin: release n=squeeze
#Pin-Priority: 1000
#Package: *
#Pin: release n=sid
#Pin-Priority: 100

#Action	Alpine (apk)	Arch Linux (pacman)	Gentoo (emerge)	Debian/Ubuntu (aptitute)	Fedora/RHEL/SL/Centos (yum)
#Update package database	
# apk update
# pacman -Sy
# emerge --sync
# aptitude update
# yum update
#Showing available updates	
# apk version -l '<'

# pacman -Qu
# emerge --deep --update --pretend @world
# aptitude upgrade --simulate
# yum list updates
#Installing packages	
#apk add [package name]

#pacman -S [package name]
# emerge [package name]
# aptitude install [package name]
# yum install [package name]
#Update all installed packages	
# apk upgrade -U -a

# pacman -Su
# emerge --update --deep @world
# aptitude upgrade
# yum update
#Searching package database	
# apk search -v '[string]*'

# pacman -Ss [string]
# emerge --search [string]
# aptitude search [string]
# yum search [string]
#Removing packages	
# apk del [package name]

# pacman -R [package name]
# emerge --depclean [package name]
# aptitude remove [package name]
# yum remove [package name]


# Repo mirroring
#aptly -architectures="amd64" mirror create devuan-amd64-ascii https://pkgmaster.devuan.org/merged/  		ascii 		main contrib non-free
#aptly -architectures="amd64" mirror create devuan-amd64-ascii-updates https://pkgmaster.devuan.org/merged/  	ascii-updates 	main contrib non-free
#aptly -architectures="amd64" mirror create devuan-amd64-ascii-security https://pkgmaster.devuan.org/merged/  	ascii-security 	main contrib non-free
#aptly -architectures="amd64" mirror create devuan-amd64-ascii-backports https://pkgmaster.devuan.org/merged/  	ascii-backports main contrib non-free
#aptly mirror update devuan-amd64-ascii;
#aptly mirror update devuan-amd64-ascii-updates;                                                                                                                                                                                                                                
#aptly mirror update devuan-amd64-ascii-security;                                                                                                                                                                                                                               
#aptly mirror update devuan-amd64-ascii-backports;                                                                                                                                                                                                                              
#
#https://pkgmaster.devuan.org/merged/pool/DEVUAN/
#https://pkgmaster.devuan.org/merged/pool/DEBIAN/

#list of backported packages
#aptitude search '?narrow(?installed, ?archive(oldstable-backports))'

#apt-mark hold some package at backported level and then do an emergency downgrading?

#apt-get download
#apt-get install --download-only
