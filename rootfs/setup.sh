#!/usr/bin/with-contenv bash

#For Worker
if [[ $API == false || $API == "" ]]
then
rm -r /etc/s6-overlay/s6-rc.d/svc-nginx /etc/s6-overlay/s6-rc.d/svc-php7-fpm /etc/s6-overlay/s6-rc.d/svc-stdout/dependencies.d
rm /etc/s6-overlay/s6-rc.d/user/contents.d/svc-nginx /etc/s6-overlay/s6-rc.d/user/contents.d/svc-php7-fpm
fi
