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
wget -q -P $DIR/ https://download.sublimetext.com/sublime-text_build-3126_amd64.deb || echo ""
dpkg -i sublime-text_build-3126_amd64.deb

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
