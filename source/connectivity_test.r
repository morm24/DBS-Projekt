#AUthor: Moritz Berger
#Date: 30.06.2021
#verbindungstest auf die datenbank

install.packages("RMySQL")
library(RMySQL)
library(DBI)












mydb = dbConnect(MySQL(),
                 user='root',
                 password='5142',
                 dbname='dbs_project',
                 host='127.0.0.1')


dbListTables(mydb)


#to get Tables use dbGetQuerry(*dataObject*, 'statement')

gdp <- dbGetQuery(mydb, 'SELECT * FROM gdp')








##Warning!!!   dbSendQuery is better to change the database
rs = dbSendQuery(mydb, 'SELECT * FROM gdp')

test_querry <- fetch (rs , n=1)

#use dbReadTable to get a whole table from the database
gdp_tibble <- dbReadTable(mydb, "gdp ")





mean(gdp_tibble$value)
max(gdp_tibble$value)










alusdb = dbConnect(MySQL(),
                 user='alus',
                 password='word',
                 dbname='SQLtest',
                 host='192.168.0.191',
                 port= 3306)
