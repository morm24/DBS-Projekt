README File for DBS-project programmed in R.
To use this app, you need the following programs:
    
    1. The R environment 
	Download: https://cran.r-project.org/bin/windows/base/
    2. An R programming environment. We recommend R-Studio.
        Download: https://www.rstudio.com/products/rstudio/download/
    3. The MySQL server and if you want workstation v.8
        Download: https://dev.mysql.com/downloads/installer/

If you have R and MySQL already installed and know how to use it, you can skip the following point.


1. Install the programs

    1.1 Basic Installations
    To install the programs, you have to open the Installer of each one. You should get guided through the installation pretty easily.
    Start with the R environment, after that install R-Studio. At last, you can install MySQL.

    1.2 Setting up R-Studio
    If you have R-Studio installed, you can open shiny_app.r with R-Studio.
    Now you have to download and install all the dependent libraries from the CRAN server.
    You can do this by executing the following command in the console (without parentheses):
    "install.packages(c("dplyr", "shiny, "shinythemes", "RMySQL", "ggplot2))"

    1.3 Installing MySQL
    Now you have to install MySQL. This can take a bit longer.
    I recommend installing the Full version. So you have a nice workbench GUI to work with MySQL.

2. Set up the database
    
    To set up the database, you can use two ways:

    2.1 Lodi the Database with MySQL Workbench
        -In the interface, you should have one tab in the top row, named "Server".
        -Click it, then click "Data import"
        -select: Import from Self-Contained File
        -Add/Browse the path to .../Projekt/data/database/DBS_Project.sql
        -Select "New..." At default schema... ! This is your database Name
        -click "Start Import" on the bottom of the Site
        -Now you have set up the database


    2.2Load the Database with the MySQL console
        -navigate your console toe the folder .../Projekt/data/database/
        -type in the command line: mysql -u root -p dbs_project < DBS_Project.sql
        -change dbs_project to your name for the database.

3. Start the application
    
    To start the application, you have to open the File .../Projekt/source/shiny_app.r in your R environment.
    In Lines 24 - 29 you can change the connection details to your Database Server.
    Now you can run the R script (in R-Studio, u can use CLRT + SHIFT + ENTER)
    Have fun with the app!
