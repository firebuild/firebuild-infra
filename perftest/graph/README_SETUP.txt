One-time setup in order to explore the performance test results
===============================================================


Set up MySQL server
-------------------

Install:

    sudo apt install mysql-server

Server configuration:

    sudo mysql_secure_installation

- Validate password compoonent: No.
- Root password: `fb`.
- Remove anonymous users? Yes.
- Disallow root login remotely? Yes.
- Remove test database and access to it? Yes.
- Reload privilege tables now? Yes.

Configure a user `fb` with password `fb`, then create a database called
`fb`:

    mysql -u root -p

    create user 'fb' identified by 'fb';
    create database fb;
    grant all privileges on fb.* to 'fb';

If you choose a different username, password or database name, you need
to update these in `upload_csv_to_mysql`.

Follow the steps "Update MySQL contents" from README.txt, they should
work now.


Set up Grafana
--------------

Install:

Temporarily disable the fake entry in `/etc/hosts` if necessary, then:

    sudo snap install grafana

At the time of writing this documentation, it's at version 6.7.4.

Install the "separator" plugin:

    sudo grafana.grafana-cli plugins install mxswat-separator-panel
    sudo systemctl restart snap.grafana.grafana

Configure Grafana:

Visit

    http://localhost:3000/

Log in as `admin`, pw `admin`. Change password as prompted.

"Add data source" -> "MySQL", tell it the previously chosen database
name, user and password (`fb`, `fb`, `fb`).

Continue with the "Update Grafana config" section.


Update Grafana config
---------------------

Run `./generate_grafana_dashboard_config`, this creates the config file
`grafana_dashboard.json` from a simple jinja template.

During the initial setup, click on "Home" near the upper left corner.
During a subsequent config update, click on "FireBuild Dashboard" near
the upper left corner.

Click on "Import dashboard" in the right column. Upload
`grafana_dashboard.json`.


Maintaining the Grafana config template
---------------------------------------

After doing some changes to the dashboard, save it (one of the buttons
in the upper right toolbar) and open the settings (another button here).
Switch to "JSON Model" in the second column. Copy-paste the contents to
a file.

Manually compare it to the config generated from the template. Locate
the differences, and merge them back to the template.

Verify by regenerating the config and reuploading, as per "Update
Grafana config".

This is cumbersome, but still much better than having to manually
maintain plenty of similar graphs.


Light theme
-----------

I (egmont) hate dark themes. Grafana -> left navbar -> Configuration ->
Preferences -> UI Theme: Light.
