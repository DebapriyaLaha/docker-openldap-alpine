FROM library/alpine:latest

MAINTAINER Debapriya Laha

ENV OPENLDAP_ALPINE_CNCONFIG_PW "password"
ENV REPLICATION_PASSWOD "replication"

RUN apk add --update openldap openldap-clients openldap-back-mdb openldap-back-monitor openldap-overlay-accesslog openldap-overlay-syncprov openldap-overlay-auditlog openldap-overlay-ppolicy && \
    mkdir -p /run/openldap /var/lib/openldap/openldap-data && \
    rm -rf /var/cache/apk/*

RUN mkdir /etc/openldap/slapd.d/
RUN mkdir /var/openldap
RUN mkdir /data
RUN mkdir /data/accesslog
RUN mkdir /data/orgdata

COPY docker-entry-slave.sh /

RUN chmod 777 /docker-entry-slave.sh

EXPOSE 389
EXPOSE 636

ENTRYPOINT ["/docker-entry-slave.sh"]

