#!/bin/bash -x
set -o errexit

certbot_binary="/opt/certbot/certbot-auto"

jobber_configfile="/root/.jobber"

letsencrypt_testcert=""

if [ "${LETSENCRYPT_TESTCERT}" = "true" ]; then
  letsencrypt_testcert="--test-cert"
fi

letsencrypt_email=""

if [ -n "${LETSENCRYPT_EMAIL}" ]; then
  letsencrypt_email=${LETSENCRYPT_EMAIL}
fi

letsencrypt_domains=""

for (( i = 1; ; i++ ))
do
  VAR_LETSENCRYPT_DOMAIN="LETSENCRYPT_DOMAIN$i"

  if [ ! -n "${!VAR_LETSENCRYPT_DOMAIN}" ]; then
    break
  fi

  letsencrypt_domains=$letsencrypt_domains" -d "${!VAR_LETSENCRYPT_DOMAIN}
done

letsencrypt_challenge_mode="--standalone"

if  [ "${LETSENCRYPT_WEBROOT_MODE}" = "true" ]; then
  letsencrypt_challenge_mode="--webroot --webroot-path=/var/www/letsencrypt"
fi

letsencrypt_http_enabled="true"
letsencrypt_https_enabled="true"

if [ -n "${LETSENCRYP_HTTP_ENABLED}" ]; then
  letsencrypt_http_enabled=${LETSENCRYP_HTTP_ENABLED}
fi

if [ -n "${LETSENCRYPT_HTTPS_ENABLED}" ]; then
  letsencrypt_https_enabled=${LETSENCRYPT_HTTPS_ENABLED}
fi

letsencrypt_account_id=""

if [ -n "${LETSENCRYPT_ACCOUNT_ID}" ]; then
  letsencrypt_account_id="--account "${LETSENCRYPT_ACCOUNT_ID}
fi

protocoll_command=""

if  [ "${letsencrypt_http_enabled}" = "false" ]; then
  protocoll_command="--standalone-supported-challenges tls-sni-01"
fi

if  [ "${letsencrypt_https_enabled}" = "false" ]; then
  protocoll_command="--standalone-supported-challenges http-01"
fi

letsencrypt_debug=""

if  [ "${LETSENCRYPT_DEBUG}" = "true" ]; then
  letsencrypt_debug="--debug"
fi

if [ -n "${LETSENCRYPT_CERTIFICATES_UID}" ] && [ -n "${LETSENCRYPT_CERTIFICATES_GID}" ]; then
	cat > /etc/letsencrypt/renewal-hooks/deploy/change_permissions.sh <<_EOF_
#!/bin/sh
set -e
chown -R ${LETSENCRYPT_CERTIFICATES_UID}.${LETSENCRYPT_CERTIFICATES_GID} /etc/letsencrypt
chmod 400 /etc/letsencrypt/archive/*/privkey*.pem
_EOF_
	chmod a+x /etc/letsencrypt/renewal-hooks/deploy/change_permissions.sh
else
	if [ -f /etc/letsencrypt/renewal-hooks/deploy/change_permissions.sh ]; then
		rm -f /etc/letsencrypt/renewal-hooks/deploy/change_permissions.sh
	fi
fi

if [ ! -f "${jobber_configfile}" ]; then
  touch ${jobber_configfile}
fi

cat > ${jobber_configfile} <<_EOF_
---
_EOF_

job_on_error="Continue"

if [ -n "${LETSENCRYPT_JOB_ON_ERROR}" ]; then
  job_on_error=${LETSENCRYPT_JOB_ON_ERROR}
fi

job_time="0 0 1 15 * *"

if [ -n "${LETSENCRYPT_JOB_TIME}" ]; then
  job_time=${LETSENCRYPT_JOB_TIME}
fi

if [ "$1" = 'jobberd' ]; then
  cat >> ${jobber_configfile} <<_EOF_
- name: letsencryt_renewal
  cmd: bash -c "${certbot_binary} --text --non-interactive --no-bootstrap --no-self-upgrade certonly ${letsencrypt_challenge_mode} ${protocoll_command} ${letsencrypt_testcert} ${letsencrypt_debug} --renew-by-default ${letsencrypt_account_id} ${letsencrypt_domains} ${@:2}"
  time: ${job_time}
  onError: ${job_on_error}
  notifyOnError: false
  notifyOnFailure: false
_EOF_

  cat ${jobber_configfile}
  exec jobberd
fi

case "$1" in

  install)
    bash -c "${certbot_binary} --text --non-interactive --no-bootstrap --no-self-upgrade certonly ${letsencrypt_challenge_mode} ${protocoll_command} ${letsencrypt_testcert} ${letsencrypt_debug} --email ${letsencrypt_email} --agree-tos ${letsencrypt_domains} ${@:2}"
    ;;

  newcert)
    bash -c "${certbot_binary} --text --non-interactive --no-bootstrap --no-self-upgrade certonly ${letsencrypt_challenge_mode} ${protocoll_command} ${letsencrypt_testcert} ${letsencrypt_debug} ${letsencrypt_account_id} ${letsencrypt_domains} ${@:2}"
    ;;

  renewal)
    bash -c "${certbot_binary} --text --non-interactive --no-bootstrap --no-self-upgrade certonly ${letsencrypt_challenge_mode} ${protocoll_command} ${letsencrypt_testcert} ${letsencrypt_debug} --renew-by-default ${letsencrypt_account_id} ${letsencrypt_domains} ${@:2}"
    ;;

  *)
    exec "$@"

esac
