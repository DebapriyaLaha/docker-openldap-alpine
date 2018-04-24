# docker-openldap-alpine


**A docker image to run OpenLDAP on Alpine Linux.**

> OpenLDAP website : [www.openldap.org](http://www.openldap.org/)

This is an experimental openldap project runnig on Alpine Linux image having master-slave replication enabled.


## Features

 - Openldap slap.d configuration
 - Master-Slave Replication
 - Ldap TLS setup
 - Custom Password Policy
 - Custom Organisation Schema
 - Backup

## Why slap.d / online configuration?

This gives developers option to configure Ldap while it's running. No downtime required.

> well, not fully. Configuration DB has to be define as minimum. 

### Development

Want to contribute? Great!