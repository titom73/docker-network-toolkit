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
    echo "waiting for eth1 interface to come up"
    sleep 1
    check=$( cat /sys/class/net/eth1/operstate 2>/dev/null )
done

check=$( cat /sys/class/net/eth2/operstate 2>/dev/null )

while [ "up" != "$check" ] ; do
    echo "waiting for eth2 interface to come up"
    sleep 1
    check=$( cat /sys/class/net/eth2/operstate 2>/dev/null )
done

echo "eth1 state: $(cat /sys/class/net/eth1/operstate)"
echo "eth2 state: $(cat /sys/class/net/eth2/operstate)"

################
# Bonding setup (using kernel bonding instead of teamd for better compatibility)
################

# Load bonding module if not already loaded
modprobe bonding 2>/dev/null || true

if [ "$TMODE" == 'lacp' ] || [ "$TMODE" == 'static' ] || [ "$TMODE" == 'active-backup' ]; then
  echo "Setting up bond0 interface with mode: $TMODE"

  # Remove any existing bond0
  if [ -d /sys/class/net/bond0 ]; then
    echo "Removing existing bond0"
    echo "-bond0" > /sys/class/net/bonding_masters 2>/dev/null || true
  fi

  # Create bond0 interface
  echo "+bond0" > /sys/class/net/bonding_masters

  # Configure bonding mode
  case "$TMODE" in
    "lacp")
      echo "4" > /sys/class/net/bond0/bonding/mode  # 802.3ad (LACP)
      echo "fast" > /sys/class/net/bond0/bonding/lacp_rate
      echo "layer3+4" > /sys/class/net/bond0/bonding/xmit_hash_policy
      echo "100" > /sys/class/net/bond0/bonding/miimon
      ;;
    "static")
      echo "balance-rr" > /sys/class/net/bond0/bonding/mode  # round-robin
      echo "100" > /sys/class/net/bond0/bonding/miimon
      ;;
    "active-backup")
      echo "active-backup" > /sys/class/net/bond0/bonding/mode
      echo "100" > /sys/class/net/bond0/bonding/miimon
      # Set primary slave
      echo "$TACTIVE" > /sys/class/net/bond0/bonding/primary
      ;;
  esac

  # Bring down slave interfaces
  ip link set eth1 down
  ip link set eth2 down

  # Add slaves to bond
  echo "+eth1" > /sys/class/net/bond0/bonding/slaves
  echo "+eth2" > /sys/class/net/bond0/bonding/slaves

  # Bring up bond interface
  ip link set bond0 up

  echo "Bond0 successfully configured with slaves: $(cat /sys/class/net/bond0/bonding/slaves)"
  echo "Bond0 mode: $(cat /sys/class/net/bond0/bonding/mode)"
  echo "Bond0 status: $(cat /sys/class/net/bond0/bonding/mii_status)"

  UPLINK="bond"
else
  echo "No bonding configured (TMODE=$TMODE)"
fi

######################
# Enabling SSH server
######################

echo "Starting SSH daemon..."
/usr/sbin/sshd

###############
# Enabling LLDP
###############

echo "Starting LLDP daemon..."
lldpad -d

# Wait a bit for lldpad to initialize
sleep 2

echo "Configuring LLDP on network interfaces..."
for i in `ls /sys/class/net/ | grep -E '^(eth|ens|eno|bond)'`
do
    echo "Configuring LLDP on interface: $i"
    lldptool set-lldp -i $i adminStatus=rxtx 2>/dev/null || echo "Warning: Could not configure LLDP on $i"
    lldptool -T -i $i -V sysName enableTx=yes 2>/dev/null || true
    lldptool -T -i $i -V portDesc enableTx=yes 2>/dev/null || true
    lldptool -T -i $i -V sysDesc enableTx=yes 2>/dev/null || true
done

#########################
# Network status summary
#########################

echo "=== Network Configuration Summary ==="
echo "Hostname: $(hostname)"
echo "Container IP: ${CONTAINER_IP}"
echo "Uplink type: ${UPLINK}"

if [ "$UPLINK" == "bond" ]; then
    echo "Bond status:"
    echo "  Mode: $(cat /sys/class/net/bond0/bonding/mode 2>/dev/null || echo 'N/A')"
    echo "  Slaves: $(cat /sys/class/net/bond0/bonding/slaves 2>/dev/null || echo 'N/A')"
    echo "  MII Status: $(cat /sys/class/net/bond0/bonding/mii_status 2>/dev/null || echo 'N/A')"
fi

echo "Active network interfaces:"
ip link show | grep -E '^[0-9]+:' | awk '{print "  " $2}' | sed 's/:$//'

echo "=== End Network Summary ==="

##########################
# Continue to execute CMD
##########################

# Execute the command specified as CMD in Dockerfile:
exec "$@"
