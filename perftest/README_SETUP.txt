One-time setup in order to run performance tests
================================================


Set up squid-deb-proxy
----------------------

It's highly recommended to set up a local apt caching proxy:
Somewhat based on https://tribaal.io/making-lxd-fly-on-ubuntu-as-well.html

    sudo apt install squid-deb-proxy

Configure the max cache side (defaults to 40GB). Edit
`/etc/squid-deb-proxy/squid-deb-proxy.conf` to contain

    cache_dir aufs /var/cache/squid-deb-proxy [size_in_MB] 16 256

Restart:

    sudo systemctl restart squid-deb-proxy  # be patient


Enable core dumps
-----------------

If a test fails due to segfault or similar, we want to have core a dump.

Unfortunately the location of core files is global in the kernel (not
local to containers) (although the filename is interpreted according to
the container's root). Ubuntu's default of piping to apport isn't really
a good choice. `tmp` is cleaned upon an `lxc stop/start`. So let's go with
a filename under `/var/tmp`.

    sudo sh -c 'echo "kernel.core_pattern = /var/tmp/core.%e.%p.%h.%t" > /etc/sysctl.d/firebuild-coredump.conf'
    sudo deb-systemd-invoke restart procps.service
    cat /proc/sys/kernel/core_pattern  # verify


Install and configure lxd
-------------------------

    sudo snap install lxd

At the time of writing this documentation, it's at version 4.7.

Make sure you (who are going to run the perftests) are a member of the
`lxd` group.


    lxd init  # Choose 'dir' storage backend, or anything other than 'zfs', see bug #311.
              # For the rest, go with the defaults.


Create an lxc profile called `firebuild-perftest`, by copying the
default profile:

    lxc profile copy default firebuild-perftest


Point this profile to the apt caching proxy:

    LXD_ADDRESS=$(ip -br -4 address show lxdbr0 | awk '{print $3}' | cut -d/ -f1)
    echo $LXD_ADDRESS  # check if it's okay
    echo -e "#cloud-config\napt:\n  proxy: http://$LXD_ADDRESS:8000" | lxc profile set firebuild-perftest user.user-data -
    lxc profile show firebuild-perftest  # to verify


Create a template instance, do some basic setup there (to speed up the
creation of subsequent instances), and save this instance as an image:

    ./create_template_image


Now you're ready to run perftests using `./outer`.


Disable snap updating
---------------------

Disable automatically updating the `lxd` snap. Not only does it interfere
with the timing measurements, but also the `lxc` command does not
function during such an update, leading to tons of failing tests. Based
on https://github.com/wekan/wekan/issues/2120 add this to `/etc/hosts`:

    127.0.0.1 api.snapcraft.io

(Other solutions, e.g. snap's `refresh.hold` seem to be more cumbersome,
need to be repeated over and over again, ask for sudo password, etc.)


Disable CPU frequency scaling
-----------------------------

Frequency scaling is not supported on every computer. If it's not
supported then the corresponding files under /sys are missing. In that
case there's nothing to do (still disabling the "ondemand" service might
not hurt, though).

Disable now. Either

    sudo cpupower frequency-set -g performance

or

    for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
      sudo sh -c "echo performance > $f"
    done

Disable after reboot. The kernel's default value is "performance" but
the "ondemand" service changes it. So let's disable the "ondemand"
service:

    sudo systemctl disable ondemand.service


Start over configuring lxd
--------------------------

Unfortunately there's no `lxd uninit` or such, and `lxd init` can only
be run (with the defaults) only once. It's extremely cumbersome to start
everything over. What I tend to do:

    lxc list
    lxc delete [all the existing instances]

    sudo snap remove lxd  # this takes a long time, eventually times out or fails otherwise
    sudo rm -rf /var/snap/lxd

Clean up snapshots. Either

    sudo snap saved
    sudo snap forget [the lxd related ones]

or

    sudo rm /var/lib/snapd/snapshots/*lxd*

maybe remove every `*lxc*` and `*lxd*` under `/var`?

    sudo snap remove lxd  # again, this time it succeeds

To remove the leftover network bridge, if any:

    sudo ip link delete lxdbr0

To entirely delete the zfs pool: ???
