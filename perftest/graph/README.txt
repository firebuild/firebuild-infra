How to explore the performance test results
===========================================


Make sure everything is set up according to README_SETUP.txt.


Update MySQL contents
---------------------

Run

    ./generate_commits_csv firebuilddir

whereas `firebuilddir` points to a checked out firebuild tree. This
generates `commits.csv` which is used by Grafana for the vertical bar
annotations.

Copy `~/buildtimes.csv` (from whichever computer that ran the tests) to
this directory.

Run `./upload_csv_to_mysql`. This empties the `fb` database in MySQL,
creates the tables from scratch, and uploads the two `*.csv` files as
contents.

You can now explore these data in Grafana, by visiting

    http://localhost:3000/

If it's already opened, click on the Refresh icon at the top right
corner.
