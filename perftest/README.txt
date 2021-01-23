For initial setup, follow the steps from README_SETUP.txt.


For running tests locally (without bringing up a VM), use ./inner.
Normally you shouldn't do this, except for debugging.

For running tests in their dedicated VM, use ./outer. This is what
you should normally run.

Refer to these scripts for usage instructions.


These scripts append records to ~/buildtimes.csv. See the "graph"
subdirectory for visualizing this data.

In case of failure, these scripts leave the following artifacts:
- a script log file ~/firebuild-perftest-*-FAILED-*
- a container named fireuild-perftest-*-FAILED-*, use:
  - lxc list
  - lxc start <containername>
  - lxc shell <containername>
  - lxc exec <containername> --user 1000 --group 1000 --env HOME=/home/ubuntu /bin/bash
  - lxc stop <containername>
  - lxc delete <containername>
- possibly a core dump inside the container, under /var/tmp

The lxc containers take up much space, so examine and delete them
regularly.
