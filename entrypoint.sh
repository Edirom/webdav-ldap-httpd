#!/bin/sh

# Add our dav location to the httpd config
cat <<EOF > /usr/local/apache2/conf/extra/vife.conf
LoadModule	dav_module           modules/mod_dav.so
LoadModule  dav_fs_module        modules/mod_dav_fs.so
LoadModule	ldap_module          modules/mod_ldap.so
LoadModule	authnz_ldap_module   modules/mod_authnz_ldap.so
DocumentRoot "/var/webdav"
DavLockDB "/run/lock/apache/DavLock.db"
<Directory "/var/webdav">
    DAV on
    Options +Indexes
    IndexOptions Charset=UTF-8 FancyIndexing FoldersFirst
    IndexIgnore .??* :2*
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

# Set the user running httpd
# if parameter $RUNAS_USER is set.
# Otherwise defaults to user daemon
if [ -n "$RUNAS_USER" ]; then
    sed -i -e "s@User daemon@User $RUNAS_USER@" ${HTTPD_PREFIX}/conf/httpd.conf
fi

# Run the command given in the Dockerfile at CMD 
exec "$@"