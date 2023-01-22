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
# a good choice. `tmp` is cleaned upon an `lxc stop/start`. So let's go with
# a filename under `/var/tmp`.

echo "kernel.core_pattern = /var/tmp/core.%e.%p.%h.%t" | sudo tee /etc/sysctl.d/firebuild-coredump.conf
sudo systemctl restart procps.service
echo "Active /proc/sys/kernel/core_pattern setting:"
cat /proc/sys/kernel/core_pattern

# install and configure lxd
sudo apt-get install -y lxd || sudo apt-get install -y lxd-installer

# Choose default 'dir' storage backend, or anything other than 'zfs', see bug #311.
sudo lxd init --auto

LXD_ADDRESS=$(ip -br -4 address show lxdbr0 | awk '{print $3}' | cut -d/ -f1)
echo "LXD address: $LXD_ADDRESS"

groups $USER | grep -q lxd || sudo adduser $USER lxd && LXD_GROUP_FIXUP_PREFIX="sudo -u $USER"

$LXD_GROUP_FIXUP_PREFIX lxc profile copy default firebuild-perftest

printf "#cloud-config\napt:\n  proxy: http://$LXD_ADDRESS:8000\n" | $LXD_GROUP_FIXUP_PREFIX lxc profile set firebuild-perftest user.user-data -
echo "New LXC profile:"
$LXD_GROUP_FIXUP_PREFIX lxc profile show firebuild-perftest

$LXD_GROUP_FIXUP_PREFIX ./create_template_image

# Disable snap updates
#
# Disable automatically updating the `lxd` snap. Not only does it interfere
# with the timing measurements, but also the `lxc` command does not
# function during such an update, leading to tons of failing tests. Based
# on https://github.com/wekan/wekan/issues/2120 add this to `/etc/hosts`:
# (Other solutions, e.g. snap's `refresh.hold` seem to be more cumbersome,
# need to be repeated over and over again, ask for sudo password, etc.)
grep -q api.snapcraft.io /etc/hosts || echo "127.0.0.1 api.snapcraft.io" | sudo tee -a /etc/hosts

# Disable CPU frequency scaling
#
# Frequency scaling is not supported on every computer. If it's not
# supported then the corresponding files under /sys are missing. In that
# case there's nothing to do (still disabling the "ondemand" service might
# not hurt, though).
for f in $(find /sys/devices/system/cpu/ -name scaling_governor); do
    sudo sh -c "echo performance > $f"
done

# Disable after reboot. The kernel's default value is "performance" but
# the "ondemand" service changes it. So let's disable the "ondemand"
# service:
sudo systemctl disable ondemand.service
