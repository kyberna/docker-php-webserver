#!/bin/bash

if [ ! -f /firstrundone ]; then
    if [ "$RELAY_HOST" != "" ]; then
        echo "relayhost = $RELAY_HOST" >> /etc/postfix/main.cf
    fi
    if [ "$MASQ_DOMAINS" != "" ]; then
        echo "masquerade_domains = $MASQ_DOMAINS" >> /etc/postfix/main.cf
    fi
    echo "smtp_generic_maps = hash:/etc/postfix/generic" >> /etc/postfix/main.cf
    echo "root	no-reply@$MASQ_DOMAINS" >> /etc/postfix/generic
    postmap /etc/postfix/generic
    echo "done" >> /firstrundone
fi

if [ "$START_CRON" != "" ]; then
    service cron start

    if [ "$CRON_FILE" != "" ]; then
        crontab $CRON_FILE
    fi
fi

if [ "$START_MAILDELIVERY" != "" ]; then
    service inetutils-syslogd start
    service postfix start
fi

apache2-foreground
