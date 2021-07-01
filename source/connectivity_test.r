#AUthor: Moritz Berger
#Date: 30.06.2021
#verbindungstest auf die datenbank

#install.packages("RMySQL")
library(RMySQL)
library(DBI)












mydb = dbConnect(MySQL(),
                 user='test',
                 password='test',
                 dbname='dbs_project',
                 host='192.168.0.17',
                 port=3306)


dbListTables(mydb)


#to get Tables use dbGetQuerry(*dataObject*, 'statement')

gdp <- dbGetQuery(mydb, 'SELECT * FROM gdp')

country <- dbGetQuery(mydb, 'SELECT * FROM country')



gdp$code


##Warning!!!   dbSendQuery is better to change the database
rs = dbSendQuery(mydb, 'SELECT * FROM gdp')

test_querry <- fetch (rs , n=1)

#use dbReadTable to get a whole table from the database
gdp_tibble <- dbReadTable(mydb, "gdp ")





mean(gdp_tibble$value)
max(gdp_tibble$value)



#list all connections with a database:
dbListConnections( dbDriver( drv = "MySQL"))
#close the specific connecion
x <-1     #index of MySQLConnection you want to close

dbDisconnect( dbListConnections( dbDriver( drv = "MySQL"))[[x]])

#or close all at once
lapply( dbListConnections( dbDriver( drv = "MySQL")), dbDisconnect)




