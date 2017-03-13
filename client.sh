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

# HTTPS repository & Keyrings for Debian repository.
apt-get install -y --force-yes apt-transport-https debian-keyring debian-archive-keyring

# Sources.
cat <<\EOF > /etc/apt/sources.list
# Default
deb http://sft.if.usp.br/debian/ jessie main contrib non-free
deb-src http://sft.if.usp.br/debian/ jessie main contrib non-free

# Security
deb http://security.debian.org/ jessie/updates main
deb-src http://security.debian.org/ jessie/updates main

# Updates
deb http://sft.if.usp.br/debian/ jessie-updates main
deb-src http://sft.if.usp.br/debian/ jessie-updates main

# Backports
deb http://sft.if.usp.br/debian/ jessie-backports main
deb-src http://sft.if.usp.br/debian/ jessie-backports main
EOF

# Codeblocks Repository.
cat <<\EOF > /etc/apt/sources.list.d/codeblocks.list
# Codeblocks
deb https://apt.jenslody.de/stable jessie main
deb-src https://apt.jenslody.de/stable jessie main
EOF

apt-get update && apt-get install -y --force-yes jens-lody-debian-keyring

# Pd-extended repository. !!! ABANDONED PROJECT !!!
#apt-key adv --keyserver keyserver.ubuntu.com --recv-key 9f0fe587374bbe81
#apt-key adv --keyserver keyserver.ubuntu.com --recv-key D63D3D09C39F5EEB
#cat <<\EOF > /etc/apt/sources.list.d/pd-extended.list
# Pd-extended repository.
#deb http://apt.puredata.info/releases jessie main
#deb-src http://apt.puredata.info/releases jessie main
#EOF

# R CRAN repository.
apt-key adv --keyserver keys.gnupg.net --recv-key 381BA480
cat <<\EOF > /etc/apt/sources.list.d/r_cran_mirrors.list
# R CRAN Mirrors.
deb http://vps.fmvz.usp.br/CRAN/bin/linux/debian jessie-cran3/
EOF

# Backports issue
apt install -y -t jessie-backports  openjdk-8-jre-headless ca-certificates-java

########################################################################
# Updates!
apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y && apt-get autoremove -y & APT=$!

# Non-interactive installation of packages.
DEBIAN_FRONTEND=noninteractive
export DEBIAN_FRONTEND
DEBIAN_PRIORITY=critical
export DEBIAN_PRIORITY

# DNS client.
cat <<\EOF > /etc/resolv.conf
domain linux.ime.usp.br
search linux.ime.usp.br
nameserver 192.168.240.213
nameserver 192.168.240.214
EOF
chmod 644 /etc/resolv.conf

# Locales.
cat <<\EOF > /etc/default/locale
LANG="pt_BR.UTF-8"
LANGUAGE="pt_BR.UTF-8"
EOF
cat <<\EOF > /etc/locale.gen
en_US.UTF-8 UTF-8
pt_BR.UTF-8 UTF-8
EOF
locale-gen > /dev/null

wait $APT
apt-get install -y wget

# Download Sublime
wget -q -P $DIR/ https://download.sublimetext.com/sublime-text_build-3103_amd64.deb || echo "" & DOWN=$!
# Netbeans
wget -q -P $DIR/ http://download.netbeans.org/netbeans/8.1/final/bundles/netbeans-8.1-linux.sh & DOWN="$! $DOWN"
# Receitanet
wget -q -P $DIR/ http://www.receita.fazenda.gov.br/publico/programas/receitanet/receitanet-1.07.deb & DOWN="$! $DOWN"
# Rstudio
wget -q -P $DIR/ https://download1.rstudio.org/rstudio-0.99.903-amd64.deb & DOWN="$! $DOWN"
# Greenfoot
wget -q -P $DIR/ http://www.greenfoot.org/download/files/old/Greenfoot-linux-304.deb & DOWN="$! $DOWN"

apt-get install -y $(grep ^[^#] $FILES/packages | tr "\n" ' ')

########################################################################
# NTP client.
cat <<\EOF > /etc/ntp.conf
# ARQUIVO MODIFICADO PELO PUPPET!
# NÃO EDITAR!!!

driftfile /var/lib/ntp/ntp.drift

server ntp.linux.ime.usp.br key 19
restrict ntp.linux.ime.usp.br

restrict default ignore
restrict -6 default ignore
restrict 127.0.0.1
restrict -6 ::1

enable auth
keys /etc/ntp.keys
trustedkey 19
EOF
chmod 640 /etc/ntp.conf

cat <<\EOF > /etc/ntp.keys
# ntpkey_MD5key_dota.3665265069
# Tue Feb 23 22:11:09 2016

 1 MD5 wG2ZiqOL%3jiOQ.UbzM4  # MD5 key
 2 MD5 -ZoHO?HY"ZBry!@F?`06  # MD5 key
 3 MD5 qqM[|XTTdE(hl4|6K0*b  # MD5 key
 4 MD5 PRr6lM$+reaJhFj;\dF"  # MD5 key
 5 MD5 %[5d:Ia1/}Lp|DE21Aea  # MD5 key
 6 MD5 BO8a^WPZp3-vGOS5]Nu`  # MD5 key
 7 MD5 %~I/q8<&.PE_[jhuul8I  # MD5 key
 8 MD5 MhB:3k!-lnhZ!}j;S%@M  # MD5 key
 9 MD5 ue8!zl+)6TE,xn)iVPk!  # MD5 key
10 MD5 s^_F'0i]M*?mbmi4/=uU  # MD5 key
11 SHA1 7d83254702be37a6f545b7e6e4ce2421f3f1f254  # SHA1 key
12 SHA1 7a2b34c24deb973f4eb5c9cdf2139a90ff4b72fd  # SHA1 key
13 SHA1 6892564fbe002cc4adeb7e3cf746ca7fa77c45a4  # SHA1 key
14 SHA1 967dfed53b38786f4344ae29d2db8acb22c4d2d8  # SHA1 key
15 SHA1 842dd97f0293372eee8869e1e3bdc94fe9b51267  # SHA1 key
16 SHA1 f5cfb5e2bc325d6f814d4110cf7c3f395bab7d36  # SHA1 key
17 SHA1 3eab692748705fe5be462f84bc0cf952b30d8ca9  # SHA1 key
18 SHA1 def49d9643a868008753fff0bacb6df7a0fcd108  # SHA1 key
19 SHA1 2c8f389cd6424a80dec41ed7f8fa35f087deb923  # SHA1 key
20 SHA1 541bb2fb6a293430150afef97db5fa3a8172466e  # SHA1 key
EOF
chmod 400 /etc/ntp.keys

systemctl restart ntp.service &
timedatectl set-ntp true

########################################################################

########################################################################
# CUPS client
mkdir -m 755 -p /etc/cups
cat <<\EOF > /etc/cups/client.conf
ServerName cups.linux.ime.usp.br:631
Encryption IfRequested
EOF
chmod 755 /etc/cups/client.conf
########################################################################

# Install LDAP Certificate.
mkdir -p /etc/ldap/tls
cat <<\EOF > /etc/ldap/tls/redelinuxCA.crt
-----BEGIN CERTIFICATE-----
MIIE9DCCA9ygAwIBAgIIVcKLQhWceb0wDQYJKoZIhvcNAQELBQAwggECMTEwLwYD
VQQDEyhSZWRlIExpbnV4IElNRS1VU1AgQ2VydGlmaWNhdGUgQXV0aG9yaXR5MRMw
EQYDVQQLEwpSZWRlIExpbnV4MTAwLgYDVQQKDCdJbnN0aXR1dG8gZGUgTWF0ZW3D
oXRpY2EgZSBFc3RhdMOtc3RpY2ExDzANBgNVBAcTBkJyYXppbDETMBEGA1UECAwK
U8OjbyBQYXVsbzELMAkGA1UEBhMCQlIxFTATBgoJkiaJk/IsZAEZFgVsaW51eDET
MBEGCgmSJomT8ixkARkWA2ltZTETMBEGCgmSJomT8ixkARkWA3VzcDESMBAGCgmS
JomT8ixkARkWAmJyMCIYDzIwMTUwODA1MjIxNjM1WhgPMjAyNTA4MDIyMjE2Mzla
MIIBAjExMC8GA1UEAxMoUmVkZSBMaW51eCBJTUUtVVNQIENlcnRpZmljYXRlIEF1
dGhvcml0eTETMBEGA1UECxMKUmVkZSBMaW51eDEwMC4GA1UECgwnSW5zdGl0dXRv
IGRlIE1hdGVtw6F0aWNhIGUgRXN0YXTDrXN0aWNhMQ8wDQYDVQQHEwZCcmF6aWwx
EzARBgNVBAgMClPDo28gUGF1bG8xCzAJBgNVBAYTAkJSMRUwEwYKCZImiZPyLGQB
GRYFbGludXgxEzARBgoJkiaJk/IsZAEZFgNpbWUxEzARBgoJkiaJk/IsZAEZFgN1
c3AxEjAQBgoJkiaJk/IsZAEZFgJicjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCC
AQoCggEBAMhNTl4JpdTO0/X51ofpwA2PLSX4hsVvx5oCuigMlHEwzWZHQJTuclER
H01c3Sla+FoP/gCCC5McllW3p+KShjCvNU30oZkTNVNKSf1aVvOpKMUXzMLRtZ/S
RnM+IQOTmqwRrA2rlK9YorHImY+GgehKRKLzu5aVzB7NxYea0J2dYuJb28yX9CcC
G7KhqwtRG9tnZE+VuRFQP5fpt/Qk0tqYwb8KBP8zNNDdaMxj83lUhqN4yztHApCB
c4/dHaCa9gOD4Tqm96VWMpMDqUo+RnFreYFfeqLX2TsBf6aYmau9XGSzKT8SgQHF
f6cW8qzxQyhWF84OSUpI4UF8LUGPCMECAwEAAaNmMGQwDwYDVR0TAQH/BAUwAwEB
/zAhBgNVHREEGjAYgRZhZG1pbkBsaW51eC5pbWUudXNwLmJyMA8GA1UdDwEB/wQF
AwMHBAAwHQYDVR0OBBYEFD+796f2H335n7yrtH3cC79XlPOeMA0GCSqGSIb3DQEB
CwUAA4IBAQDHL75RPccm7IxHGHhRN1Zo2pHTu5HWSMtPLuPLRg2fS4+2npLDYzTs
WWP7wDYsignb699V1gZOKSfJrrxwvbg8lUa1GnnMM7Ra1ImHv2SbfVSWkGt4lVgb
zvCEwpBs3GFlid+K9w7wlrWzkG0yolIa8+iR6XXCJhtr0im5kwev85m+QLnWWiu2
/2YDtuprPP+vAnhbzw2p/1ad/4C+Yl7iv1I5aldVuQ84EDo6LUcpm7O5eanzjxUL
xDu/WxPLKS77I9lf0E7X2OjpL8PRJIc3yf+l8Om9WJSnu/SN5A2yarnKXSkuuinU
6r/ifs+7xmsiOrMZnDmZ1Ssd5lV3vyyr
-----END CERTIFICATE-----
EOF
cp /etc/ldap/tls/redelinuxCA.crt /usr/local/share/ca-certificates/
update-ca-certificates

# LDAP client
# nscd e libnss-ldap substituidos pelo sssd
cat <<\EOF > /etc/sssd/sssd.conf
[sssd]
config_file_version = 2
services = nss, pam
sbus_timeout = 30
domains = linux.ime.usp.br

[nss]
filter_users = root
filter_groups = root

[pam]
offline_credentials_expiration = 7

[domain/linux.ime.usp.br]
enumerate = true
cache_credentials = true

id_provider = ldap
chpass_provider = krb5
ldap_uri = ldaps://ldap.linux.ime.usp.br
ldap_search_base = dc=linux,dc=ime,dc=usp,dc=br
ldap_tls_reqcert = demand
ldap_tls_cacert = /etc/ldap/tls/redelinuxCA.crt
ldap_sasl_mech = GSSAPI

auth_provider = krb5
krb5_server = kdc.linux.ime.usp.br
krb5_backup_server = kerberos.linux.ime.usp.br
krb5_realm = LINUX.IME.USP.BR
krb5_changepw_principal = kadmin/changepw
krb5_ccachedir = /tmp
krb5_ccname_template = FILE:%d/krb5cc_sss_%U_XXXXXX
krb5_auth_timeout = 15
krb5_kpasswd = kdc.linux.ime.usp.br
EOF
chmod 600 /etc/sssd/sssd.conf
systemctl restart sssd.service

# Kerberos client
# libpam-krb5 substituido pelo sssd
cat <<\EOF > /etc/krb5.conf
[libdefaults]
    default_realm = LINUX.IME.USP.BR
    forwardable = true
    proxiable = true

[realms]
    LINUX.IME.USP.BR = {
        kdc = kdc.linux.ime.usp.br
        kdc = kerberos.linux.ime.usp.br
        admin_server = kerberos.linux.ime.usp.br
    }

[domain_realm]
    .linux.ime.usp.br = LINUX.IME.USP.BR
    linux.ime.usp.br = LINUX.IME.USP.BR
EOF

cat <<\EOF > /root/.k5login
denisfa/admin@LINUX.IME.USP.BR
carybe/admin@LINUX.IME.USP.BR
duilioelias/admin@LINUX.IME.USP.BR
nanda/admin@LINUX.IME.USP.BR
andreluizas/admin@LINUX.IME.USP.BR
renatobispo/admin@LINUX.IME.USP.BR
kazuyuki/admin@LINUX.IME.USP.BR
EOF

# Kerberos Principals (create & export)
rm -rf /etc/krb5.keytab
for princ in nfs ipp host
do
        kadmin -p megazord/admin -k -t $SECRETS/megazord.keytab -q "add_principal -policy host -randkey $princ/$(hostname -f)"
done
kadmin -p megazord/admin -k -t $SECRETS/megazord.keytab -q "ktadd -glob */$(hostname -f)" &

# SSSD part 2
aptitude purge -y nscd libnss-ldap libpam-krb5 libpam-ldap && aptitude reinstall libpam-sss & APT=$!

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
systemctl restart nfs-common.service &

# Autofs Client
# @IMPORTANT: affected by minimum-uid of users.conf from lightdm
rm -rf /home && mkdir -p /{home,global} && mkdir -p /etc/autofs &
rm -rf /etc/auto.{master,misc,net,smb} &

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
systemctl restart autofs.service &

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
systemctl restart lightdm.service &

# USB mounts correct
sed -i -e '/usb0/d' -e '/usb1/d' -e '/usb2/d' -e '/usb3/d' -e '/usb4/d' /etc/fstab
systemctl restart udisks2.service &

########################################################################
cat <<\EOF > /etc/unburden-home-dir.list
# Generic cache locations
m D .cache cache
m D .thumbnails thumbnails
m D .ccache ccache

# Common browser caches
m f .config/google-chrome/*/Thumbnails google-chrome-thumbnails-%1
m f .config/google-chrome/*/Thumbnails-journal google-chrome-thumbnails-journal-%1
m f .config/chromium/*/Thumbnails google-chrome-thumbnails-%1
m f .config/chromium/*/Thumbnails-journal google-chrome-thumbnails-journal-%1
m d .mozilla/default/*/Cache mozilla-default-cache-%1
m d .mozilla/default/*/startupCache mozilla-default-startup-cache-%1
m d .mozilla/firefox/*/Cache firefox-cache-%1
m d .mozilla/firefox/*/startupCache firefox-startup-cache-%1
m d .mozilla/firefox/*/Cache.Trash firefox-cache-trash-%1
m d .conkeror.mozdev.org/conkeror/*/Cache conkeror-cache-%1
m d .conkeror.mozdev.org/conkeror/*/startupCache conkeror-startup-cache-%1
m d .conkeror.mozdev.org/conkeror/*/Cache.Trash conkeror-cache-trash-%1
m d .kazehakase/mozilla/kazehakase/Cache kazehakase-cache
m d .galeon/mozilla/galeon/Cache galeon-cache
m d .gnome2/epiphany/mozilla/epiphany/Cache epiphany-cache
m d .xxxterm/cache xxxterm-cache
m d .forg/cache forg-cache
m d .opera/cache opera-cache
m d .opera/cache4 opera-cache4
m d .opera/opcache opera-opcache
m d .opera/cacheOp opera-cacheOp
m d .config/qupzilla/profiles/*/networkcache qupzilla-cache-%1

# Mail- and microblogging clients, may affect offline caches
m d .thunderbird/*/Cache thunderbird-cache-%1
m d .mozilla-thunderbird/*/Cache debian-thunderbird-cache-%1
m d .icedove/*/Cache icedove-cache-%1
m d .buzzbird/*/Cache buzzbird-cache

# Other applications' caches
m f .aptitude/cache aptitude-cache
m d .wesnoth*/cache wesnoth%1-cache
m d .gaia/cache gaia-cache
m d .googleearth/Cache google-earth-cache
m d .java/deployment/cache java-deployment-cache
m d .adobe/Acrobat/*/Cache adobe-acrobat-%1-cache
m d .shotwell/thumbs shotwell-thumbs
# sxiv caches thumbnails if a .sxiv directory exists, so create it if nonexistent
m D .sxiv sxiv-thumbs
m D .devscripts_cache devscripts_cache

# Trash locations
r D .Trash trash
r D .local/Trash local-trash
EOF

cat <<\EOF > /etc/default/unburden-home-dir
# Defaults for unburden-home-dir Xsession hook
# sourced by /etc/X11/Xsession.d/95unburden-home-dir
# installed at /etc/default/unburden-home-dir by the maintainer scripts

#
# This is a POSIX shell fragment
#

# Uncomment to activate automatic unburdening of home directories
UNBURDEN_HOME=true
EOF
########################################################################
# SSH
cat <<\EOF > /etc/ssh/sshd_config
# Package generated configuration file
# See the sshd_config(5) manpage for details

# What ports, IPs and protocols we listen for.
Port 22

# Use these options to restrict which interfaces/protocols sshd will bind to.
Protocol 2

# HostKeys for protocol version 2.
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_dsa_key

# Files with authorized keys.
AuthorizedKeysFile      %h/.ssh/authorized_keys

# Privilege Separation is turned on for security reasons.
UsePrivilegeSeparation yes

# Lifetime and size of ephemeral version 1 server key.
KeyRegenerationInterval 3600
ServerKeyBits 1024

# Logging.
SyslogFacility AUTH
LogLevel INFO

# how long in seconds will wait before disconnecting
# if the user has not successfully logged in
LoginGraceTime 20

# Do not allow root login using password.
PermitRootLogin without-password

# Check user's permissions in their home directory before accepting login.
StrictModes yes

# Do not try rhosts authentication in concert with RSA host authentication.
RSAAuthentication no

# Allow login with ssh keys.
PubkeyAuthentication yes

# Don't read the user's ~/.rhosts and ~/.shosts files.
IgnoreRhosts yes

# For this to work you will also need host keys in /etc/ssh_known_hosts.
RhostsRSAAuthentication no

# Similar for protocol version 2.
HostbasedAuthentication no

# Disable empty passwords.
PermitEmptyPasswords no

# Change to yes to enable challenge-response passwords (beware issues with
# some PAM modules and threads).
ChallengeResponseAuthentication no

# Allow tunnelled clear text passwords.
PasswordAuthentication yes

# GSSAPI options.
GSSAPIAuthentication yes
GSSAPICleanupCredentials yes

# Allow to use display from machine to remote connection.
X11Forwarding yes

# Security if *more* than one X11 client will be started.
X11DisplayOffset 20

# Do not print /etc/motd on login.
PrintMotd no

# Print last login information.
PrintLastLog yes

# Send TCP packages to keep connection alive.
TCPKeepAlive yes

# Max number of unauthenticated connections;
# : percentage chance of dropping once we reach 10;
# : after 30 connections, drop every other try.
MaxStartups 10:30:30

# Allow sshfs from outside.
Subsystem sftp /usr/lib/sftp-server

# Allow client to pass locale environment variables.
AcceptEnv LANG LC_*

# Set this to 'yes' to enable PAM authentication, account processing,
# and session processing. If this is enabled, PAM authentication will
# be allowed through the ChallengeResponseAuthentication and
# PasswordAuthentication.  Depending on your PAM configuration,
# PAM authentication via ChallengeResponseAuthentication may bypass
# the setting of "PermitRootLogin without-password".
# If you just want the PAM account and session checks to run without
# PAM authentication, then enable this but set PasswordAuthentication
# and ChallengeResponseAuthentication to 'no'.
UsePAM yes

# Deny access of unwanted users.
DenyGroups exaluno
EOF
chmod 644 /etc/ssh/sshd_config

cat <<\EOF > /etc/ssh/ssh_config
# This is the ssh client system-wide configuration file.  See
# ssh_config(5) for more information.  This file provides defaults for
# users, and the values can be changed in per-user configuration files
# or on the command line.

# Configuration data is parsed as follows:
#  1. command line options
#  2. user-specific file
#  3. system-wide file
# Any configuration value is only changed the first time it is set.
# Thus, host-specific definitions should be at the beginning of the
# configuration file, and defaults at the end.

Host *
ServerAliveInterval 30
#   ForwardAgent no
#   ForwardX11 no
#   ForwardX11Trusted yes
#   RhostsRSAAuthentication no
#   RSAAuthentication yes
#   PasswordAuthentication yes
#   HostbasedAuthentication no
#   BatchMode no
#   CheckHostIP yes
#   AddressFamily any
#   ConnectTimeout 0
    IdentityFile ~/.ssh/identity
    IdentityFile ~/.ssh/id_rsa
    IdentityFile ~/.ssh/id_dsa
    Port 22
    Protocol 2
#   Cipher 3des
#   Ciphers aes128-ctr,aes192-ctr,aes256-ctr,arcfour256,arcfour128,aes128-cbc,3des-cbc
#   MACs hmac-md5,hmac-sha1,umac-64@openssh.com,hmac-ripemd160
#   EscapeChar ~
#   Tunnel no
#   TunnelDevice any:any
#   PermitLocalCommand no
#   VisualHostKey no
#   ProxyCommand ssh -q -W %h:%p gateway.example.com
    SendEnv LANG LC_*
    HashKnownHosts yes
    GSSAPIAuthentication yes
    GSSAPIDelegateCredentials yes
EOF
chmod 644 /etc/ssh/ssh_config

# Special key for root login.
mkdir -m 700 -p /root/.ssh
cat <<\EOF > /root/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD2Oedtpn1VrHsDf0Jh0SqN1lLkiZfE4hKV74W+x8lha7LykEykOKKoaPPh3C3ca0gINVsiDidBI5/MSnml7MKg8BTX3Zr+RbnD1WBL51SEMpemEFDAKP6EOMqpFn4t87t/W07pFcDNx5upKfXOKblVL0XLbaQDSBn1j1c5RtJWIH5h2IzE0MoOq+/1ZKkaEoIh2x61ze96z+TCygylrq9AQQhOYWAstH+Z+Z8I1my1OhUgfhfs8t/ioxTL5ofTOQwcNMMEIVrDFpz0WrTdVrVe+DB8yZY8sGHH8Qbh1tkccv3hvQPdcbUdUZIOj651yUT3BTSV8xeVWoHPtYWJTqY9 rootKey
EOF
chmod 644 /root/.ssh/authorized_keys

########################################################################
# Bashrc & /etc/profile
cat <<\EOF > /root/.bashrc
### Rede Linux Clients

# Essa linha é o que garante a mudança de PATH do usuário para o root!
source /etc/profile
# ###################################################################

#Prompt
function colored_prompt
{
    local pret="\[\033[1;30m\]"
    local verm="\[\033[1;31m\]"
    local verd="\[\033[1;32m\]"
    local amar="\[\033[1;33m\]"
    local azul="\[\033[1;34m\]"
    local roxo="\[\033[1;35m\]"
    local cian="\[\033[1;36m\]"
    local bran="\[\033[1;37m\]"
    local cinz="\[\033[2;37m\]"
    local norm="\[\033[0m\]"
    PS1="${verm}ROOT@\h:${cinz}\w ${verm}>${norm} "
}
colored_prompt

if [ -f /etc/bash_completion ]; then
    source /etc/bash_completion
fi

alias ls='ls --color=auto -h'
alias ll='ls --color=auto -lh'
alias la='ls --color=auto -a'
alias lf='ls --color=auto -lah'

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
EOF

cat <<\EOF > /etc/profile
# /etc/profile: system-wide .profile file for the Bourne shell (sh(1))
# and Bourne compatible shells (bash(1), ksh(1), ash(1), ...).

if [ "`id -u`" -eq 0 ]; then
  PATH="~/bin:~/.bin:/opt/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/global/bin"
else
  PATH="~/bin:~/.bin:/global/bin:/opt/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games"
fi
export PATH

if [ "$PS1" ]; then
  if [ "$BASH" ] && [ "$BASH" != "/bin/sh" ]; then
    # The file bash.bashrc already sets the default PS1.
    # PS1='\h:\w\$ '
    if [ -f /etc/bash.bashrc ]; then
      . /etc/bash.bashrc
    fi
  else
    if [ "`id -u`" -eq 0 ]; then
      PS1='# '
    else
      PS1='$ '
    fi
  fi
fi

# The default umask is now handled by pam_umask.
# See pam_umask(8) and /etc/login.defs.

if [ -d /etc/profile.d ]; then
  for i in /etc/profile.d/*.sh; do
    if [ -r $i ]; then
      . $i
    fi
  done
  unset i
fi

export TMOUT=3600
cd
EOF
########################################################################

# Rwho daemon && Login image
mkdir -p /opt/{bin,files}
cp $FILES/login.png /opt/files/
#cp $FILES/rlstatsd /opt/bin/
#cp $FILES/rlstats-manager /opt/bin/
#chmod +x /opt/bin/rlstatsd && chmod +x /opt/bin/rlstats-manager
# Systemd daemon style for rwho
#cp $FILES/rlstatsd.service /etc/systemd/system/
#chmod +x /etc/systemd/system/rlstatsd.service
#systemctl enable rlstatsd.service

# Protection from forkbomb ":(){ :|:& };:"
# Limit number of processes (nproc) of all users.
cat <<\EOF > /etc/security/limits.conf
*    soft     nproc     1500
*    hard     nproc     1600
EOF
chmod 644 /etc/security/limits.conf

# Prohibited buttons in menu.
# using polkit (avoid hibernate, shutdown, reboot, suspension)
cp $FILES/disable-{hibernate,suspend,reboot,shutdown}.pkla /etc/polkit-1/localauthority/90-mandatory.d/

########################################################################
# No grub menu for users!
cat <<\EOF > /etc/default/grub
# If you change this file, run 'update-grub' afterwards to update
# /boot/grub/grub.cfg.
# For full documentation of the options in this file, see:
#   info -f grub -n 'Simple configuration'

GRUB_DEFAULT=0
GRUB_HIDDEN_TIMEOUT=0
GRUB_TIMEOUT=0
GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`
GRUB_CMDLINE_LINUX_DEFAULT="quiet"
GRUB_CMDLINE_LINUX=""

# Uncomment to enable BadRAM filtering, modify to suit your needs
# This works with Linux (no patch required) and with any kernel that obtains
# the memory map information from GRUB (GNU Mach, kernel of FreeBSD ...)
#GRUB_BADRAM="0x01234567,0xfefefefe,0x89abcdef,0xefefefef"

# Uncomment to disable graphical terminal (grub-pc only)
#GRUB_TERMINAL=console

# The resolution used on graphical terminal
# note that you can use only modes which your graphic card supports via VBE
# you can see them in real GRUB with the command `vbeinfo'
#GRUB_GFXMODE=640x480

# Uncomment if you don't want GRUB to pass "root=UUID=xxx" parameter to Linux
#GRUB_DISABLE_LINUX_UUID=true

# Uncomment to disable generation of recovery mode menu entries
#GRUB_DISABLE_RECOVERY="true"

# Uncomment to get a beep at grub start
#GRUB_INIT_TUNE="480 440 1"
EOF

########################################################################

# Desactivate ctrl-alt-del from terminal.
if [[ ! -L /etc/systemd/system/ctrl-alt-del.target ]]
then
    ln -s /dev/null /etc/systemd/system/ctrl-alt-del.target
fi

######## Users packages

cat <<\EOF > /etc/Muttrc
#
# System configuration file for Mutt
#

# Default list of header fields to weed when displaying.
# Ignore all lines by default...
ignore *

# ... then allow these through.
unignore from: subject to cc date x-mailer x-url user-agent

# Display the fields in this order
hdr_order date from to cc subject

# emacs-like bindings
bind editor    "\e<delete>"    kill-word
bind editor    "\e<backspace>" kill-word

# map delete-char to a sane value
bind editor     <delete>  delete-char

# some people actually like these settings
#set pager_stop
#bind pager <up> previous-line
#bind pager <down> next-line

# Specifies how to sort messages in the index menu.
set sort=threads

# The behavior of this option on the Debian mutt package is
# not the original one because exim4, the default SMTP on Debian
# does not strip bcc headers so this can cause privacy problems;
# see man muttrc for more info
#unset write_bcc
# Postfix and qmail use Delivered-To for detecting loops
unset bounce_delivered

set mixmaster="mixmaster-filter"

# System-wide CA file managed by the ca-certificates package
set ssl_ca_certificates_file="/etc/ssl/certs/ca-certificates.crt"

# imitate the old search-body function
macro index \eb "<search>~b " "search in message bodies"

# simulate the old url menu
macro index,pager,attach,compose \cb "\
<enter-command> set my_pipe_decode=\$pipe_decode pipe_decode<Enter>\
<pipe-message> urlview<Enter>\
<enter-command> set pipe_decode=\$my_pipe_decode; unset my_pipe_decode<Enter>" \
"call urlview to extract URLs out of a message"

# Show documentation when pressing F1
macro generic,pager <F1> "<shell-escape> zcat /usr/share/doc/mutt/manual.txt.gz | sensible-pager<enter>" "show Mutt documentation"

# show the incoming mailboxes list (just like "mutt -y") and back when pressing "y"
macro index,pager y "<change-folder>?<toggle-mailboxes>" "show incoming mailboxes list"
bind browser y exit

# If Mutt is unable to determine your site's domain name correctly, you can
# set the default here. (better: fix /etc/mailname)
#
# set hostname=cs.hmc.edu

# If your sendmail supports the -B8BITMIME flag, enable the following
#
# set use_8bitmime

# Use mime.types to look up handlers for application/octet-stream. Can
# be undone with unmime_lookup.
mime_lookup application/octet-stream

# Upgrade the progress counter every 250ms, good for mutt over SSH
# see http://bugs.debian.org/537746
set time_inc=250

##
## *** DEFAULT SETTINGS FOR THE ATTACHMENTS PATCH ***
##

##
## Please see the manual (section "attachments")  for detailed
## documentation of the "attachments" command.
##
## Removing a pattern from a list removes that pattern literally. It
## does not remove any type matching the pattern.
##
##  attachments   +A */.*
##  attachments   +A image/jpeg
##  unattachments +A */.*
##
## This leaves "attached" image/jpeg files on the allowed attachments
## list. It does not remove all items, as you might expect, because the
## second */.* is not a matching expression at this time.
##
## Remember: "unattachments" only undoes what "attachments" has done!
## It does not trigger any matching on actual messages.

## Qualify any MIME part with an "attachment" disposition, EXCEPT for
## text/x-vcard and application/pgp parts. (PGP parts are already known
## to mutt, and can be searched for with ~g, ~G, and ~k.)
##
## I've added x-pkcs7 to this, since it functions (for S/MIME)
## analogously to PGP signature attachments. S/MIME isn't supported
## in a stock mutt build, but we can still treat it specially here.
##
attachments   +A */.*
attachments   -A text/x-vcard application/pgp.*
attachments   -A application/x-pkcs7-.*

## Discount all MIME parts with an "inline" disposition, unless they're
## text/plain. (Why inline a text/plain part unless it's external to the
## message flow?)
##
attachments   +I text/plain

## These two lines make Mutt qualify MIME containers.  (So, for example,
## a message/rfc822 forward will count as an attachment.)  The first
## line is unnecessary if you already have "attach-allow */.*", of
## course.  These are off by default!  The MIME elements contained
## within a message/* or multipart/* are still examined, even if the
## containers themselves don't qualify.
##
#attachments  +A message/.* multipart/.*
#attachments  +I message/.* multipart/.*

## You probably don't really care to know about deleted attachments.
attachments   -A message/external-body
attachments   -I message/external-body

##
# See /usr/share/doc/mutt/README.Debian for details.
source /usr/lib/mutt/source-muttrc.d|

##
# Automatically log in to this mailbox at startup
set spoolfile="imaps://imap.linux.ime.usp.br/"
# Define the = shortcut, and the entry point for the folder browser (c?)
set folder="imaps://imap.linux.ime.usp.br/INBOX"
set record="=Sent"
set postponed="=Drafts"
set trash="=Trash"
# activate TLS if available on the server
set ssl_starttls=yes
# always use SSL when connecting to a server
set ssl_force_tls=yes
# Don't wait to enter mailbox manually
unset imap_passive
# Automatically poll subscribed mailboxes for new mail (new in 1.5.11)
set imap_check_subscribed
# Reduce polling frequency to a sane level
set mail_check=60
# And poll the current mailbox more often (not needed with IDLE in post 1.5.11)
set timeout=10
# keep a cache of headers for faster loading (1.5.9+?)
set header_cache=~/.hcache
# Display download progress every 5K
set net_inc=5
EOF

chmod -R 644 $DIR/squeak
cp $DIR/squeak/* /usr/share/squeak/

echo "a4" > /etc/papersize

update-grub2 &

systemctl restart ssh.service &

wait $DOWN
echo "Running NetBeans script, it takes some time..." && bash $DIR/netbeans-8.1-linux.sh --silent

wait $APT
apt-get install -y libnetbeans-cvsclient-java
update-java-alternatives -s java-1.7.0-openjdk-amd64
dpkg -i $DIR/*.deb $FILES/*.deb || echo "" & APT=$!

# Kill ghosts users (depends on Lightdm)
cat <<\EOF > /usr/local/bin/ghostkiller.sh
#!/bin/bash
KILLTIME=2400000
LOGFILE="/var/log/ghostkiller.log"
KILLUSER=$(w | awk -F" " '/xdm/ {print $1}')
export DISPLAY=":0"
export XAUTHORITY="/var/run/lightdm/root/:0"
IDLETIME=$(xprintidle)

for i in $KILLUSER
do
    if [ $IDLETIME -gt $KILLTIME ]
    then
        echo "$(date +'%Y/%m/%d %H:%M') deslogando $KILLUSER ausente há ${IDLETIME}ms" >> $LOGFILE
        service lightdm restart > /dev/null
    fi
done
EOF

# Puppet
cat <<\EOF > /etc/puppet/puppet.conf
[main]
logdir   = /var/log/puppet
vardir   = /var/lib/puppet
ssldir   = /var/lib/puppet/ssl
rundir   = /var/run/puppet
factpath = /lib/facter

[master]
ssl_client_header = SSL_CLIENT_S_DN
ssl_client_verify_header = SSL_CLIENT_VERIFY

[agent]
server = puppet.linux.ime.usp.br
environment = production
EOF
chmod 644 /etc/puppet/puppet.conf

puppet agent --enable

# Allow to mount encrypted partitions.
cat <<\EOF > /etc/polkit-1/localauthority/50-local.d/50-udisks.rules
polkit.addRule(function(action, subject) {
  var YES = polkit.Result.YES;
  var permission = {
    // only required for udisks1:
    "org.freedesktop.udisks.filesystem-mount": YES,
    "org.freedesktop.udisks.filesystem-mount-system-internal": YES,
    "org.freedesktop.udisks.luks-unlock": YES,
    "org.freedesktop.udisks.drive-eject": YES,
    "org.freedesktop.udisks.drive-detach": YES,
    // only required for udisks2:
    "org.freedesktop.udisks2.filesystem-mount": YES,
    "org.freedesktop.udisks2.filesystem-mount-system": YES,
    "org.freedesktop.udisks2.encrypted-unlock": YES,
    "org.freedesktop.udisks2.eject-media": YES,
    "org.freedesktop.udisks2.power-off-drive": YES,
    // required for udisks2 if using udiskie from another seat (e.g. systemd):
    "org.freedesktop.udisks2.filesystem-mount-other-seat": YES,
    "org.freedesktop.udisks2.encrypted-unlock-other-seat": YES,
    "org.freedesktop.udisks2.eject-media-other-seat": YES,
    "org.freedesktop.udisks2.power-off-drive-other-seat": YES
  };
  if (subject.isInGroup("storage")) {
    return permission[action.id];
  }
});
EOF

# Browsers:
# Firefox HTML5 support.
# Yes, both flashes are necessary!
mkdir -p /etc/adobe
cat <<\EOF > /etc/adobe/mms.cfg
# Adobe player settings
AVHardwareDisable = 0
FullScreenDisable = 0
LocalFileReadDisable = 1
FileDownloadDisable = 1
FileUploadDisable = 1
LocalStorageLimit = 5
ThirdPartyStorage = 1
AssetCacheSize = 50
AutoUpdateDisable = 1
LegacyDomainMatching = 0
LocalFileLegacyAction = 0
AllowUserLocalTrust = 0
# DisableSockets = 1
OverrideGPUValidation = 1
EOF
chmod 644 /etc/adobe/mms.cfg

# Kerberos authentication for iceweasel
mkdir -p /etc/firefox-esr/pref
cp $FILES/iceweasel.js /etc/firefox-esr/pref/

# Kerberos authentication for chromium
mkdir -p /etc/chromium/policies/{managed,recommended}
chmod -R 755 /etc/chromium

cat <<\EOF > /etc/chromium/policies/managed/kerberos.json
{
        "AuthServerWhitelist": "*",
        "AuthNegotiateDelegateWhitelist": "*",
        "GSSAPILibraryName": "libgssapi_krb5.so.2"
}
EOF
chmod 755 /etc/chromium/policies/managed/kerberos.json

# Final update & upgrade.
wait $APT
apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y & APT=$!

systemctl enable irqbalance.service &

# Boot time.
systemctl enable upower &
systemctl enable systemd-readahead-collect systemd-readahead-replay &

# Responiveness of system.
cat <<\EOF > /etc/sysctl.d/99-sysctl.conf
vm.dirty_ratio = 3
vm.dirty_background_ratio = 2
vm.dirty_writeback_centisecs = 6000
vm.swappiness = 10
# NFSv4 fix.
kernel.keys.maxbytes = 1300000
kernel.keys.root_maxbytes = 1300000
kernel.keys.maxkeys = 65000
kernel.keys.root_maxkeys = 65000
EOF
chmod 640 /etc/sysctl.d/99-sysctl.conf

cat <<\EOF > /etc/default/cpufrequtils
# valid values: userspace conservative powersave ondemand performance
# get them from 'cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors'
GOVERNOR="ondemand"
EOF

# Disable root password.
sed -i -e 's/root:\([^:]*\):\([^:]*\)/root:*:\2/' /etc/shadow

# Trash packages and corrections...
UNINSTALL='network-manager libpam-ldap libpam-krb5 nscd libnss-ldap consolekit modemmanager exim4 exim4-base exim4-config libjim0.75 usb-modeswitch usb-modeswitch-data mate-media-pulse'

# Uninstalling trash!
wait $APT && apt-get purge -y $UNINSTALL
apt-get install --reinstall libpam-sss
rm -rf /etc/NetworkManager

# Adjusting network interface.
ETH=$(/sbin/ifconfig | awk '{ print $1 }' | grep ^eth | head -n 1)
cat <<EOF > /etc/network/interfaces
# The loopback network interface
auto lo
iface lo inet loopback

auto $ETH
iface $ETH inet dhcp
EOF

# Remove unnecessary packages.
apt-get autoremove -y

# Force the configuration of /etc/network/interfaces instead of systemd
ifdown $ETH && ifup $ETH

wait

# Finished!
# Puppet will run, but it is unecessary after this script.
COMPLETE_HOSTNAME=$(hostname -A)
ssh -o StrictHostKeyChecking=no -i $SECRETS/id_rsa puppet "puppet cert clean $COMPLETE_HOSTNAME" || echo "host doesn\'t have a certificate; creating one..."

find /var/lib/puppet/ssl -name "$(echo -e $COMPLETE_HOSTNAME\* | tr -d ' ')" -delete
puppet agent -t --waitforcert 25 || echo "" & sleep 30

ssh -o StrictHostKeyChecking=no -i $SECRETS/id_rsa puppet "puppet cert sign $COMPLETE_HOSTNAME"
wait

# Should I?
rm -rf $DIR
rm -rf /root/{Desktop,.bash_history,.aptitude,.nbi}

# Finally...
echo "Installation complete"
shutdown -r now
