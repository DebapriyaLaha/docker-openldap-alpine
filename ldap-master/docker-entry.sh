#!/bin/sh


: ${OPENLDAP_ALPINE_CNCONFIG_PW:?"missing variable OPENLDAP_ALPINE_CNCONFIG_PW"}
CNCONFIG_PW_HASH="$(/usr/sbin/slappasswd -h '{SSHA}' -s $OPENLDAP_ALPINE_CNCONFIG_PW)"
: ${OPENLDAP_ALPINE_LISTEN_URI:="ldap:// ldaps://"}
: ${OPENLDAP_ALPINE_LOGLEVEL:="stats"}

: ${REPLICATION_PASSWOD:?"missing variable REPLICATION_PASSWOD -- Replication Password"}
REPLICATION_PWD_HASH="$(/usr/sbin/slappasswd -h '{SSHA}' -s $REPLICATION_PASSWOD)"

CONFIG="/custom-config/common-config.ldif"
sed -i "s~%SUFFIX%~$SUFFIX~g" "$CONFIG"
sed -i "s~%CNCONFIG_PW_HASH%~$CNCONFIG_PW_HASH~g" "$CONFIG"
sed -i "s~%CA_FILE%~$CA_FILE~g" "$CONFIG"
sed -i "s~%KEY_FILE%~$KEY_FILE~g" "$CONFIG"
sed -i "s~%CERT_FILE%~$CERT_FILE~g" "$CONFIG"

PMDBCONFIG="/custom-config/ppolicy-mdb-config.ldif"
sed -i "s~%SUFFIX%~$SUFFIX~g" "$PMDBCONFIG"

PCONFIG="/custom-config/ppolicy-config.ldif"
sed -i "s~%SUFFIX%~$SUFFIX~g" "$PCONFIG"


MCONFIG="/custom-config/master-node-config.ldif"
sed -i "s~%SUFFIX%~$SUFFIX~g" "$MCONFIG"
sed -i "s~%CNCONFIG_PW_HASH%~$CNCONFIG_PW_HASH~g" "$MCONFIG"
sed -i "s~%CA_FILE%~$CA_FILE~g" "$MCONFIG"
sed -i "s~%KEY_FILE%~$KEY_FILE~g" "$MCONFIG"
sed -i "s~%CERT_FILE%~$CERT_FILE~g" "$MCONFIG"

ORG="/custom-config/organisation.ldif"
sed -i "s~%SUFFIX%~$SUFFIX~g" "$ORG"
sed -i "s~%ORGANISATION_NAME%~$ORGANISATION_NAME~g" "$ORG"
sed -i "s~%REPLICATION_PWD_HASH%~$REPLICATION_PWD_HASH~g" "$ORG"
sed -i "s~%CNCONFIG_PW_HASH%~$CNCONFIG_PW_HASH~g" "$ORG"

USER_CONF="/custom-config/users.ldif"
sed -i "s~%SUFFIX%~$SUFFIX~g" "$USER_CONF"
sed -i "s~%ORGANISATION_NAME%~$ORGANISATION_NAME~g" "$USER_CONF"
sed -i "s~%USER_UID%~$USER_UID~g" "$USER_CONF"
sed -i "s~%USER_GIVEN_NAME%~$USER_GIVEN_NAME~g" "$USER_CONF"
sed -i "s~%USER_SURNAME%~$USER_SURNAME~g" "$USER_CONF"
if [ -z "$USER_PW" ]; then USER_PW="password"; fi
sed -i "s~%USER_PW%~$USER_PW~g" "$USER_CONF"
sed -i "s~%USER_EMAIL%~$USER_EMAIL~g" "$USER_CONF"

REPLICATION_USR="/custom-config/replication-user.ldif"
sed -i "s~%SUFFIX%~$SUFFIX~g" "$REPLICATION_USR"
sed -i "s~%REPLICATION_PWD_HASH%~$REPLICATION_PWD_HASH~g" "$REPLICATION_USR"

REPLICATION_SLAVE="/custom-config/replication-slave.ldif"
sed -i "s~%SUFFIX%~$SUFFIX~g" "$REPLICATION_SLAVE"
sed -i "s~%REPLICATION_PWD_HASH%~$REPLICATION_PWD_HASH~g" "$REPLICATION_SALVE"
sed -i "s~%CA_FILE%~$CA_FILE~g" "$REPLICATION_SLAVE"
sed -i "s~%KEY_FILE%~$KEY_FILE~g" "$REPLICATION_SLAVE"
sed -i "s~%CERT_FILE%~$CERT_FILE~g" "$REPLICATION_SLAVE"

rm -rf /ldap-config/*
cp -r /custom-config/* /ldap-config

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


echo "Loading Master Node Config:"
/usr/bin/ldapadd -h localhost -D "cn=Manager,cn=config" -w "$OPENLDAP_ALPINE_CNCONFIG_PW" -f /ldap-config/master-node-config.ldif
/usr/bin/ldapadd -h localhost -D "cn=Manager,dc=example,dc=com" -w "$OPENLDAP_ALPINE_CNCONFIG_PW" -f /ldap-config/organisation.ldif
/usr/bin/ldapadd -h localhost -D "cn=Manager,cn=config" -w "$OPENLDAP_ALPINE_CNCONFIG_PW" -f /ldap-config/ppolicy-mdb-config.ldif
/usr/bin/ldapadd -h localhost -D "cn=Manager,dc=example,dc=com" -w "$OPENLDAP_ALPINE_CNCONFIG_PW" -f /ldap-config/ppolicy-config.ldif
/usr/bin/ldapadd -h localhost -D "cn=Manager,cn=config" -w "$OPENLDAP_ALPINE_CNCONFIG_PW" -f /ldap-config/custom-schema.ldif
/usr/bin/ldapadd -h localhost -D "cn=Manager,dc=example,dc=com" -w "$OPENLDAP_ALPINE_CNCONFIG_PW" -f /ldap-config/users.ldif
/usr/bin/ldapadd -h localhost -D "cn=Manager,dc=example,dc=com" -w "$OPENLDAP_ALPINE_CNCONFIG_PW" -f /ldap-config/replication-user.ldif

tail -f /data/slapd.log

exec "$@"