
#!/bin/bash

# regex to fold files: <<\\?EOF((.*\n*)(?!EOF))*

set -e

# Only root.
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root!" 1>&2
   exit 1
fi

# Script dir.
DIR="$( cd "$( dirname "$0" )" && pwd )"

# Global variables.
FILES=$DIR/files
SECRETS=$DIR/secrets
chmod -R 600 $SECRETS

# NFS client
cat <<\EOF > /etc/default/nfs-common
# If you do not set values for the NEED_ options, they will be attempted
# autodetected; this should be sufficient for most people. Valid alternatives
# for the NEED_ options are "yes" and "no".

# Do you want to start the statd daemon? It is not needed for NFSv4.
NEED_STATD=

# Options for rpc.statd.
#   Should rpc.statd listen on a specific port? This is especially useful
#   when you have a port-based firewall. To use a fixed port, set this
#   this variable to a statd argument like: "--port 4000 --outgoing-port 4001".
#   For more information, see rpc.statd(8) or http://wiki.debian.org/SecuringNFS
STATDOPTS=

# Do you want to start the idmapd daemon? It is only needed for NFSv4.
NEED_IDMAPD=yes

# Do you want to start the gssd daemon? It is required for Kerberos mounts.
NEED_GSSD=yes
EOF

cat <<\EOF > /etc/idmapd.conf
[General]
Verbosity = 0
Pipefs-Directory = /run/rpc_pipefs
Domain = linux.ime.usp.br
Local-Realms = LINUX.IME.USP.BR

[Mapping]
Nobody-User = nobody
Nobody-Group = nogroup

[Translation]
Method = nsswitch
EOF
systemctl restart nfs-common.service


# Autofs Client
# @IMPORTANT: affected by minimum-uid of users.conf from lightdm

#rm -rf /home 
mkdir -p /{home,global} 
mkdir -p /etc/autofs 
rm -rf /etc/auto.{master,misc,net,smb}


# Control groups login.
# Only "bcc" can log in 258A.
# everybody except "exaluno" can log in 127A.
rm -rf /etc/login.group.allowed

# From which room is this machine?
# Command not NULL means 258A
# 0 - 258A
# 1 - 127A
if lspci | grep "Radeon HD 4290" > /dev/null
then
        MACHINE=0
else
        MACHINE=1
fi

# Select special configuration for each room.
case "$MACHINE" in
    0)
        #echo "Sala 258A!!!"
        # Drivers.
        wait $APT
		apt-get install -y firmware-linux-nonfree firmware-realtek & APT=$!
        for i in bcc prof
        do
            #Groups
            echo "$i" >> /etc/login.group.allowed
            done
            ;;
    1)
        #echo "Sala 127A!!!"
        for i in bcc bmac bm bma be lic licn prof spec
        do
            #Groups
            echo "$i" >> /etc/login.group.allowed
        done
            ;;
esac

# Apply login rules to PAM.
if ! grep -Fxq "auth required pam_listfile.so onerr=fail item=group sense=allow file=/etc/login.group.allowed" /etc/pam.d/common-auth
then
    echo "auth required pam_listfile.so onerr=fail item=group sense=allow file=/etc/login.group.allowed" | cat - /etc/pam.d/common-auth > /tmp/PAM && mv -f /tmp/PAM /etc/pam.d/common-auth
fi

# NFS home mountpoints via autofs.
for i in bcc bmac bm bma be lic licn prof spec
do
        mkdir -p /home/$i
        echo "* --fstype=nfs4,rw,noatime,hard,intr,rsize=1048576,wsize=1048576,sec=krb5p nfs.linux.ime.usp.br:/home/$i/&" > /etc/autofs/auto.$i
        echo "/home/$i /etc/autofs/auto.$i --timeout 60" >> /etc/auto.master
done

# /global mountpoint.
echo "/global -fstype=nfs4,rw,noatime,hard,intr,rsize=1048576,wsize=1048576,sec=krb5p nfs.linux.ime.usp.br:/global" > /etc/autofs/auto.global
echo "/- /etc/autofs/auto.global --timeout 60" >> /etc/auto.master
echo "+auto.master" >> /etc/auto.master
systemctl restart autofs.service

# Lightdm
cat <<\EOF > /etc/lightdm/lightdm-gtk-greeter.conf
#
# background = Background file to use, either an image path or a color (e.g. #772953)
# theme-name = GTK+ theme to use
# icon-theme-name = Icon theme to use
# font-name = Font to use
# xft-antialias = Whether to antialias Xft fonts (true or false)
# xft-dpi = Resolution for Xft in dots per inch (e.g. 96)
# xft-hintstyle = What degree of hinting to use (none, slight, medium, or hintfull)
# xft-rgba = Type of subpixel antialiasing (none, rgb, bgr, vrgb or vbgr)
# show-indicators = semi-colon ";" separated list of allowed indicator modules. Built-in indicators include "~a11y", "~language", "~session", "~power". Unity indicators can be represented by short name (e.g. "sound", "power"), service file name, or absolute path
# show-clock (true or false)
# clock-format = strftime-format string, e.g. %H:%M
# keyboard = command to launch on-screen keyboard
# position = main window position: x y
# default-user-image = Image used as default user icon, path or #icon-name
# screensaver-timeout = Timeout (in seconds) until the screen blanks when the greeter is called as lockscreen
#
[greeter]
background=/opt/files/login.png
theme-name=Adwaita
#icon-theme-name=
#font-name=
#xft-antialias=true
#xft-dpi=
#xft-hintstyle=hintfull
#xft-rgba=rgb
#show-indicators=~language;~session;~power
show-clock=true
#clock-format=
#keyboard=
#position=
#screensaver-timeout=
EOF

cat <<\EOF > /etc/lightdm/lightdm.conf
#
# General configuration
#
# start-default-seat = True to always start one seat if none are defined in the configuration
# greeter-user = User to run greeter as
# minimum-display-number = Minimum display number to use for X servers
# minimum-vt = First VT to run displays on
# lock-memory = True to prevent memory from being paged to disk
# user-authority-in-system-dir = True if session authority should be in the system location
# guest-account-script = Script to be run to setup guest account
# log-directory = Directory to log information to
# run-directory = Directory to put running state in
# cache-directory = Directory to cache to
# sessions-directory = Directory to find sessions
# remote-sessions-directory = Directory to find remote sessions
# greeters-directory = Directory to find greeters
#
[LightDM]
#start-default-seat=true
#greeter-user=lightdm
#minimum-display-number=0
#minimum-vt=7
lock-memory=true
#user-authority-in-system-dir=false
#guest-account-script=guest-account
log-directory=/var/log/lightdm
run-directory=/var/run/lightdm
cache-directory=/var/cache/lightdm
sessions-directory=/usr/share/lightdm/sessions:/usr/share/xsessions
#remote-sessions-directory=/usr/share/lightdm/remote-sessions
#greeters-directory=/usr/share/lightdm/greeters:/usr/share/xgreeters

#
# Seat defaults
#
# type = Seat type (xlocal, xremote)
# xdg-seat = Seat name to set pam_systemd XDG_SEAT variable and name to pass to X server
# xserver-command = X server command to run (can also contain arguments e.g. X -special-option)
# xserver-layout = Layout to pass to X server
# xserver-config = Config file to pass to X server
# xserver-allow-tcp = True if TCP/IP connections are allowed to this X server
# xserver-share = True if the X server is shared for both greeter and session
# xserver-hostname = Hostname of X server (only for type=xremote)
# xserver-display-number = Display number of X server (only for type=xremote)
# xdmcp-manager = XDMCP manager to connect to (implies xserver-allow-tcp=true)
# xdmcp-port = XDMCP UDP/IP port to communicate on
# xdmcp-key = Authentication key to use for XDM-AUTHENTICATION-1 (stored in keys.conf)
# unity-compositor-command = Unity compositor command to run (can also contain arguments e.g. unity-system-compositor -special-option)
# unity-compositor-timeout = Number of seconds to wait for compositor to start
# greeter-session = Session to load for greeter
# greeter-hide-users = True to hide the user list
# greeter-allow-guest = True if the greeter should show a guest login option
# greeter-show-manual-login = True if the greeter should offer a manual login option
# greeter-show-remote-login = True if the greeter should offer a remote login option
# user-session = Session to load for users
# allow-guest = True if guest login is allowed
# guest-session = Session to load for guests (overrides user-session)
# session-wrapper = Wrapper script to run session with
# greeter-wrapper = Wrapper script to run greeter with
# guest-wrapper = Wrapper script to run guest sessions with
# display-setup-script = Script to run when starting a greeter session (runs as root)
# display-stopped-script = Script to run after stopping the display server (runs as root)
# greeter-setup-script = Script to run when starting a greeter (runs as root)
# session-setup-script = Script to run when starting a user session (runs as root)
# session-cleanup-script = Script to run when quitting a user session (runs as root)
# autologin-guest = True to log in as guest by default
# autologin-user = User to log in with by default (overrides autologin-guest)
# autologin-user-timeout = Number of seconds to wait before loading default user
# autologin-session = Session to load for automatic login (overrides user-session)
# autologin-in-background = True if autologin session should not be immediately activated
# exit-on-failure = True if the daemon should exit if this seat fails
#
[SeatDefaults]
#type=xlocal
#xdg-seat=seat0
#xserver-command=X
#xserver-layout=
#xserver-config=
#xserver-allow-tcp=false
xserver-share=true
#xserver-hostname=
#xserver-display-number=
#xdmcp-manager=
#xdmcp-port=177
#xdmcp-key=
#unity-compositor-command=unity-system-compositor
unity-compositor-timeout=60
#greeter-session=example-gtk-gnome
greeter-hide-users=true
#greeter-allow-guest=false
#greeter-show-manual-login=false
#greeter-show-remote-login=true
#user-session=default
allow-guest=false
#guest-session=
#session-wrapper=lightdm-session
#greeter-wrapper=
#guest-wrapper=
#display-setup-script=
#display-stopped-script=
#greeter-setup-script=
#session-setup-script=
#session-cleanup-script=
#autologin-guest=false
#autologin-user=
#autologin-user-timeout=0
#autologin-in-background=false
#autologin-session=UNIMPLEMENTED
#exit-on-failure=false

#
# Seat configuration
#
# Each seat must start with "Seat:".
# Uses settings from [SeatDefaults], any of these can be overriden by setting them in this section.
#
#[Seat:0]

#
# XDMCP Server configuration
#
# enabled = True if XDMCP connections should be allowed
# port = UDP/IP port to listen for connections on
# key = Authentication key to use for XDM-AUTHENTICATION-1 or blank to not use authentication (stored in keys.conf)
#
# The authentication key is a 56 bit DES key specified in hex as 0xnnnnnnnnnnnnnn.  Alternatively
# it can be a word and the first 7 characters are used as the key.
#
[XDMCPServer]
enabled=false
#port=177
#key=

#
# VNC Server configuration
#
# enabled = True if VNC connections should be allowed
# command = Command to run Xvnc server with
# port = TCP/IP port to listen for connections on
# width = Width of display to use
# height = Height of display to use
# depth = Color depth of display to use
#
[VNCServer]
enabled=false
#command=Xvnc
#port=5900
#width=1024
#height=768
#depth=8
EOF

cat <<\EOF > /etc/lightdm/users.conf
#
# User accounts configuration
#
# NOTE: If you have AccountsService installed on your system, then LightDM will
# use this instead and these settings will be ignored
#
# minimum-uid = Minimum UID required to be shown in greeter
# hidden-users = Users that are not shown to the user
# hidden-shells = Shells that indicate a user cannot login
#
[UserList]
minimum-uid=10000000
hidden-users=nobody nobody4 noaccess
hidden-shells=/bin/false /usr/sbin/nologin
EOF

chown -R lightdm:lightdm /etc/lightdm
systemctl restart lightdm.service

# USB mounts correct
sed -i -e '/usb0/d' -e '/usb1/d' -e '/usb2/d' -e '/usb3/d' -e '/usb4/d' /etc/fstab
systemctl restart udisks2.service