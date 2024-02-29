#!/bin/sh


# If the html directory is mounted, it means user has mounted some content in it.
# In that case, we must not over-write the index.html file.

WEB_ROOT=/usr/share/nginx/html
MOUNT_CHECK=$(mount | grep ${WEB_ROOT})
HOSTNAME=$(hostname)

if [ -z "${MOUNT_CHECK}" ] ; then
  echo "The directory ${WEB_ROOT} is not mounted."
  echo "Therefore, over-writing the default index.html file with some useful information:"

  # CONTAINER_IP=$(ip addr show eth0 | grep -w inet| awk '{print $2}')
  # Note:
  #   CONTAINER IP cannot always be on device 'eth0'.
  #     It could be something else too, as pointed by @arnaudveron .
  #   The 'ip -j route' shows JSON output,
  #     and always shows the default route as the first entry.
  #     It also shows the correct device name as 'prefsrc', with correct IP address.
  CONTAINER_IP=$(ip -j route get 1 | jq -r '.[0] .prefsrc')

  # Reduced the information in just one line. It overwrites the default text.
  echo -e "Inetsix Network MultiTool (with NGINX) - ${HOSTNAME} - ${CONTAINER_IP} - HTTP: ${HTTP_PORT:-80} , HTTPS: ${HTTPS_PORT:-443}" | tee  ${WEB_ROOT}/index.html
else
  echo "The directory ${WEB_ROOT} is a volume mount."
  echo "Therefore, will not over-write index.html"
  echo "Only logging the container characteristics:"
  echo -e "Inetsix Network MultiTool (with NGINX) - ${HOSTNAME} - ${CONTAINER_IP} - HTTP: ${HTTP_PORT:-80} , HTTPS: ${HTTPS_PORT:-443}"

fi

# Custom/user-defined ports:
# -------------------------
# If the env variables HTTP_PORT and HTTPS_PORT are set, then
#   modify/Replace default listening ports 80 and 443 to whatever the user wants.
# If these variables are not defined, then the default ports 80 and 443 are used.

if [ -n "${HTTP_PORT}" ]; then
  echo "Replacing default HTTP port (80) with the value specified by the user - (HTTP_PORT: ${HTTP_PORT})."
  sed -i "s/80/${HTTP_PORT}/g"  /etc/nginx/nginx.conf
fi

if [ -n "${HTTPS_PORT}" ]; then
  echo "Replacing default HTTPS port (443) with the value specified by the user - (HTTPS_PORT: ${HTTPS_PORT})."
  sed -i "s/443/${HTTPS_PORT}/g"  /etc/nginx/nginx.conf
fi

#######################
# TEAMING configuration
#######################

UPLINK='eth'

# TMODE is expected to be set via the containerlab topology file prior to deployment
# Expected values are "lacp" or "static" or "active-backup" which will bond eth1 and eth2
if [ -z "$TMODE" ]; then
  TMODE='none'
fi

# TACTIVE and TBACKUP to be set via the containerlab topology file for active-backup runner
# expected values are "eth1" or "eth2" default is "eth1" active and "eth2" backup
if [ -z "$TACTIVE" ]; then
  TACTIVE='eth1'
  TBACKUP='eth2'
elif [ "$TACTIVE" == 'eth1' ]; then
  TBACKUP='eth2'
elif [ "$TACTIVE" == 'eth2' ]; then
  TBACKUP='eth1'
fi

echo "teaming mode is " $TMODE

#######################
# Re-run script as sudo
#######################

if [ "$(id -u)" != "0" ]; then
  exec sudo --preserve-env=TMODE,TACTIVE,TBACKUP "$0" "$@"
fi

##########################
# Check operation status
##########################

check=$( cat /sys/class/net/eth1/operstate 2>/dev/null )

while [ "up" != "$check" ] ; do
    echo "waiting for interface to come up"
    check=$( cat /sys/class/net/eth1/operstate 2>/dev/null )
done

check=$( cat /sys/class/net/eth2/operstate 2>/dev/null )

while [ "up" != "$check" ] ; do
    echo "waiting for interface to come up"
    check=$( cat /sys/class/net/eth1/operstate 2>/dev/null )
done

cat /sys/class/net/eth1/operstate
cat /sys/class/net/eth1/operstate

################
# Teaming setup
################

cat << EOF > /var/tmp/teamd-lacp.conf
{
   "device": "team0",
   "runner": {
       "name": "lacp",
       "active": true,
       "fast_rate": true,
       "tx_hash": ["eth", "ipv4", "ipv6"]
   },
     "link_watch": {"name": "ethtool"},
     "ports": {"eth1": {}, "eth2": {}}
}
EOF

cat << EOF > /var/tmp/teamd-static.conf
{
 "device": "team0",
 "runner": {"name": "roundrobin"},
 "ports": {"eth1": {}, "eth2": {}}
}
EOF

cat << EOF > /var/tmp/teamd-active-backup.conf
{
  "device": "team0",
  "runner": {"name": "activebackup"},
  "link_watch": {"name": "ethtool"},
  "ports": {
    "$TACTIVE": {
      "prio": 100
    },
    "$TBACKUP": {
      "prio": -10
    }
  }
}
EOF

if [ "$TMODE" == 'lacp' ]; then
  TARG='/var/tmp/teamd-lacp.conf'
elif [ "$TMODE" == 'static' ]; then
  TARG='/var/tmp/teamd-static.conf'
elif [ "$TMODE" == 'active-backup' ]; then
  TARG='/var/tmp/teamd-active-backup.conf'
fi

if [ "$TMODE" == 'lacp' ] || [ "$TMODE" == 'static' ] || [ "$TMODE" == 'active-backup' ]; then
  teamd -v
  teamd -k -f $TARG
  ip link set eth1 down
  ip link set eth2 down
  teamd -d -r -f $TARG

  ip link set team0 up
  UPLINK="team"
fi

######################
# Enabling SSH server
######################

/usr/sbin/sshd -D

###############
# Enabling LLDP
###############

lldpad -d
for i in `ls /sys/class/net/ | grep 'eth\|ens\|eno'`
do
    lldptool set-lldp -i $i adminStatus=rxtx
    lldptool -T -i $i -V sysName enableTx=yes
    lldptool -T -i $i -V portDesc enableTx=yes
    lldptool -T -i $i -V sysDesc enableTx=yes
done

##########################
# Continue to execute CMD
##########################

# Execute the command specified as CMD in Dockerfile:
exec "$@"
