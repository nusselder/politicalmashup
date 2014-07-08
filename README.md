# PoliticalMashup eXist Packages

Within the context of the [Political Mashup](http://www.politicalmashup.nl/) project, a set of [eXist](http://www.exist-db.org)-1.4.x tools were programmed, by quite a few different people.
Documentation on the original project tools can be found at [documentation.politicamashup.nl](http://documentation.politicalmashup.nl/).

Additional functionality, as well as eXist-2.x compatibility, was required and created for the [ODE-II](http://ode.politicalmashup.nl/) project.

This repository contains rewrites and repackaging of the original and new tools+modules for eXist-2.x.

**TODO** finish package/exist install tools; explain difference with original


## app\_src/

Contains all eXist app code.
Apps, when packaged (i.e. put it in a zip file with extension .xar) can be added to a running eXist instance using the Package Manager on the Dashboard.
Alternatively, they can be placed in the `autodeploy` folder on disk before starting the database.
Note that all apps required the `pm-modules` package to be installed first.

**TODO** add short description of each app..

   * pm-modules
   * pm-backend
   * pm-documentation
   * pm-oai
   * pm-resolver
   * pm-search
   * ode-tools


## scripts/

   * `appsrc2packagexar.sh`: Create package file from code, that can be added through the eXist package manager.
   * `datafolder2collection.sh`: **todo** example of how to add data from commandline folder to collection


## exist/

Contains scripts to install eXist, with packages and data added, on linux machines.
It is not required to use these scripts (and advised against unless you know why you want to use them because they have a quite specific use-case).
Tested on CentOS 6.5.

**TODO** finalise scripts, test and use


## Strange eXist things

When trying to synchronise the `documentation` app in eXide (to the pm-documentation folder for instance), eXist will instead synchronise what appears to be its own `doc` app.
This behaviour is repeatable, but not understood.
The solution is to not, ever, use the eXide synchronise option with the documentation app.
This is not a problem since it is deprecated documentation, but remember to never name the documentation documentation in eXist.

When adding `source` to the GET arguments, eXist will always output plain text.
This behaviour is repeatable and probably hardcoded.
Solution, do not use source as parameter.

