#!/bin/sh

sleep 15

: ${OPENLDAP_ALPINE_CNCONFIG_PW:?"missing variable OPENLDAP_ALPINE_CNCONFIG_PW"}
CNCONFIG_PW_HASH="$(/usr/sbin/slappasswd -h '{SSHA}' -s $OPENLDAP_ALPINE_CNCONFIG_PW)"
: ${OPENLDAP_ALPINE_LISTEN_URI:="ldap:// ldaps://"}
: ${OPENLDAP_ALPINE_LOGLEVEL:="stats"}

: ${REPLICATION_PASSWOD:?"missing variable REPLICATION_PASSWOD -- Replication Password"}
REPLICATION_PWD_HASH="$(/usr/sbin/slappasswd -h '{SSHA}' -s $REPLICATION_PASSWOD)"

echo "Removing Folder Location: /etc/openldap/slapd.d/*"
rm -rf /etc/openldap/slapd.d/*

echo "Loading common config file: common-config.ldif"
/usr/sbin/slapadd -n0 -F "/etc/openldap/slapd.d" -l /ldap-config/common-config.ldif

echo "chown to ldap group"
chown -R ldap:ldap \
    /etc/openldap/slapd.d/ \
    /var/openldap/ \
    /data

echo "Starting OpenLdap:"
/usr/sbin/slapd \
  -u ldap -g ldap \
  -h "$OPENLDAP_ALPINE_LISTEN_URI" \
  -d "$OPENLDAP_ALPINE_LOGLEVEL" \
  -F /etc/openldap/slapd.d/ > /data/slapd.log &


sleep 5
echo "Complete 5sec wait to start...."

echo "Loading Slave Node Config:"
/usr/bin/ldapadd -h localhost -D "cn=Manager,cn=config" -w "$OPENLDAP_ALPINE_CNCONFIG_PW" -f /ldap-config/replication-slave.ldif
/usr/bin/ldapadd -h localhost -D "cn=Manager,dc=example,dc=com" -w "$OPENLDAP_ALPINE_CNCONFIG_PW" -f /ldap-config/organisation.ldif
/usr/bin/ldapadd -h localhost -D "cn=Manager,cn=config" -w "$OPENLDAP_ALPINE_CNCONFIG_PW" -f /ldap-config/custom-schema.ldif
/usr/bin/ldapadd -h localhost -D "cn=Manager,cn=config" -w "$OPENLDAP_ALPINE_CNCONFIG_PW" -f /ldap-config/ppolicy-mdb-config.ldif
/usr/bin/ldapadd -h localhost -D "cn=Manager,dc=example,dc=com" -w "$OPENLDAP_ALPINE_CNCONFIG_PW" -f /ldap-config/ppolicy-config.ldif
/usr/bin/ldapadd -h localhost -D "cn=Manager,dc=example,dc=com" -w "$OPENLDAP_ALPINE_CNCONFIG_PW" -f /ldap-config/replication-user.ldif

tail -f /data/slapd.log

exec "$@"