#!/bin/sh -e

# squid-deb-proxy's cache size in MB
SQUID_CACHE_SIZE=60000

# It's highly recommended to set up a local apt caching proxy:
# Somewhat based on https://tribaal.io/making-lxd-fly-on-ubuntu-as-well.html
sudo apt-get -y install squid-deb-proxy

sudo sed -i 's|cache_dir aufs /var/cache/squid-deb-proxy \([^ ]*\) 16 256|cache_dir aufs /var/cache/squid-deb-proxy '${SQUID_CACHE_SIZE}' 16 256|' /etc/squid-deb-proxy/squid-deb-proxy.conf

sudo systemctl restart squid-deb-proxy.service

# Enable core dumps
#
# If a test fails due to segfault or similar, we want to have core a dump.
#
# Unfortunately the location of core files is global in the kernel (not
# local to containers) (although the filename is interpreted according to
# the container's root). Ubuntu's default of piping to apport isn't really
# a good choice. `tmp` is cleaned upon an container stop/start, so let's go with
# a filename under `/var/tmp`.

echo "kernel.core_pattern = /var/tmp/core.%e.%p.%h.%t" | sudo tee /etc/sysctl.d/firebuild-coredump.conf
sudo systemctl restart procps.service
echo "Active /proc/sys/kernel/core_pattern setting:"
cat /proc/sys/kernel/core_pattern

if apt-cache show incus 2>&1 | grep -q "Package: incus"; then
    CONTAINER_MGR="incus"
    sudo apt-get install -y incus
    # Choose default 'dir' storage backend, or anything other than 'zfs', see bug #311.
    sudo incus admin init --auto
else
    CONTAINER_MGR="lxc"
    sudo apt-get install -y lxd || sudo apt-get install -y lxd-installer
    # Choose default 'dir' storage backend, or anything other than 'zfs', see bug #311.
    sudo lxd init --auto
fi

if ip -br -4 address show incusbr0 > /dev/null 2>&1; then
    BRIDGE_DEV="incusbr0"
else
    BRIDGE_DEV="lxdbr0"
fi

BRIDGE_ADDRESS=$(ip -br -4 address show $BRIDGE_DEV | awk '{print $3}' | cut -d/ -f1)
echo "Bridge address: $BRIDGE_ADDRESS"

case $CONTAINER_MGR in
    "lxc")
        groups $USER | grep -q lxd || sudo adduser $USER lxd && GROUP_FIXUP_PREFIX="sudo -u $USER"
        ;;
    "incus")
        groups $USER | grep -q incus-admin || sudo adduser $USER incus-admin && GROUP_FIXUP_PREFIX="sudo -u $USER"
        ;;
esac


$GROUP_FIXUP_PREFIX $CONTAINER_MGR profile copy default firebuild-perftest

printf "#cloud-config\napt:\n  proxy: http://$BRIDGE_ADDRESS:8000\n" | $GROUP_FIXUP_PREFIX $CONTAINER_MGR profile set firebuild-perftest user.user-data -
echo "New $CONTAINER_MGR profile:"
$GROUP_FIXUP_PREFIX $CONTAINER_MGR profile show firebuild-perftest

$GROUP_FIXUP_PREFIX ./create_template_image

if [ $CONTAINER_MGR = "lxc" ]; then
    # Disable snap updates
    #
    # Disable automatically updating the `lxd` snap. Not only does it interfere
    # with the timing measurements, but also the `lxc` command does not
    # function during such an update, leading to tons of failing tests. Based
    # on https://github.com/wekan/wekan/issues/2120 add this to `/etc/hosts`:
    # (Other solutions, e.g. snap's `refresh.hold` seem to be more cumbersome,
    # need to be repeated over and over again, ask for sudo password, etc.)
    grep -q api.snapcraft.io /etc/hosts || echo "127.0.0.1 api.snapcraft.io" | sudo tee -a /etc/hosts
fi

# Disable CPU frequency scaling
#
# Frequency scaling is not supported on every computer. If it's not
# supported then the corresponding files under /sys are missing. In that
# case there's nothing to do (still disabling the "ondemand" service might
# not hurt, though).
for f in $(find /sys/devices/system/cpu/ -name scaling_governor); do
    sudo sh -c "echo performance > $f"
done
