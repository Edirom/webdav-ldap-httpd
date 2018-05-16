#!/bin/sh

# add our dav location to the httpd config
cat <<EOF > /usr/local/apache2/conf/extra/vife.conf
LoadModule	dav_module           modules/mod_dav.so
LoadModule  dav_fs_module        modules/mod_dav_fs.so
LoadModule	ldap_module          modules/mod_ldap.so
LoadModule	authnz_ldap_module   modules/mod_authnz_ldap.so
DocumentRoot "/var/webdav"
DavLockDB "/run/lock/DavLock"
<Directory "/var/webdav">
    DAV on
    Options +Indexes
    AllowOverride None
    AuthName "ViFE WebDAV: Login mit Nutzernamen und Passwort" 
    AuthBasicProvider ldap
    AuthType Basic
    AuthLDAPGroupAttribute member
    AuthLDAPGroupAttributeIsDN on
    AuthLDAPURL ${AuthLDAPURL}
    AuthLDAPBindDN "${AuthLDAPBindDN}" 
    AuthLDAPBindPassword "${AuthLDAPBindPassword}" 
    Require ldap-group CN=${RequireLDAPGroup},CN=Users,DC=muwi,DC=hfm-detmold,DC=de
</Directory>
EOF

# run the command given in the Dockerfile at CMD 
exec "$@"