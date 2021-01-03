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
