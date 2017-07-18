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
hugom/admin@LINUX.IME.USP.BR
renantiago/admin@LINUX.IME.USP.BR
seijihariki/admin@LINUX.IME.USP.BR
andrei/admin@LINUX.IME.USP.BR
brunobbs/admin@LINUX.IME.USP.BR
robotenique/admin@LINUX.IME.USP.BR
pauloaraujo/admin@LINUX.IME.USP.BR
EOF

# Kerberos Principals (create & export)
rm -rf /etc/krb5.keytab
for princ in nfs ipp host
do
        kadmin -p megazord/admin -k -t $SECRETS/mega.keytab -q "add_principal -policy host -randkey $princ/$(hostname -f)"
done
kadmin -p megazord/admin -k -t $SECRETS/mega.keytab -q "ktadd -glob */$(hostname -f)" &
