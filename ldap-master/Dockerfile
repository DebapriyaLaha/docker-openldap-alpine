FROM library/alpine:latest

MAINTAINER Debapriya Laha

ENV ORGANISATION_NAME "My Test Org!"
ENV SUFFIX "dc=example,dc=com"
ENV OPENLDAP_ALPINE_CNCONFIG_PW "password"

ENV USER_UID "debapriya"
ENV USER_PW "password"
ENV USER_GIVEN_NAME "Debapriya"
ENV USER_SURNAME "Laha"
ENV USER_EMAIL "debapriyalaha@example.com"

ENV REPLICATION_PASSWOD "replication"

RUN apk add --update openldap openldap-clients openldap-back-mdb openldap-back-monitor openldap-overlay-accesslog openldap-overlay-syncprov openldap-overlay-auditlog openldap-overlay-ppolicy && \
    mkdir -p /run/openldap /var/lib/openldap/openldap-data && \
    rm -rf /var/cache/apk/*

RUN mkdir /custom-config
RUN mkdir /etc/openldap/slapd.d/
RUN mkdir /var/openldap
RUN mkdir /data
RUN mkdir /data/accesslog
RUN mkdir /data/orgdata

COPY config/* /custom-config/
COPY docker-entry.sh /

RUN chmod 777 /docker-entry.sh

EXPOSE 389
EXPOSE 636

ENTRYPOINT ["/docker-entry.sh"]

