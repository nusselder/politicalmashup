# eXist installation scripts

The scripts are part mental-note of how to install eXist servers with data,
and part automation.

## scripts

   * `settings.sh`: set database port here, read by all

   * `prepare_ode.sh`: download the data used for ODE
   * `prepare_resolver.sh`: idem for PoliticalMashup resolver
   * `prepare_search.sh`: idem for PoliticalMashup search

   * `initial_install.sh`: download and install bare eXist database
   * `set_global_references.sh`: edit installed settings file (req. restart)
   * `setup_apps.sh`: install all apps after `initial_install.sh`
   * `setup_data_xml.sh`: add additional data after `setup_apps.sh`

   * `start_jetty_bound.sh`: start database bound to terminal
   * `start_jetty.sh`: start database in background and then tail on the log
   * `stop_jetty.sh`: stop the database, requires db password

   * `install_ode.sh`: calls installations scripts in order for ODE
   * `install_resolver.sh`: idem for PoliticalMashup resolver
   * `install_search.sh`: idem for PoliticalMashup search

## folders

Some data folders are created when running the installation scripts.

   * `app_packages`: apps packaged from the code in this repo in ../app_src
   * `app_data`: downloaded apps containing xml data
   * `folder_data`: downloaded + extracted .tar.gz containing data
   * `install`: installation files of the eXist database
   * `eXist-db-setup-2.1-rev18721.jar`: eXist installation file

