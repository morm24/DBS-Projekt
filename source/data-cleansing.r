#Author: Moritz Berger
#Date: 24.06.2021
#Daten ansicht,bereinigung und zusamenstellung für das DBS Projekt

#Laden der Pakete fürFuntionen
pacman::p_load(shiny,janitor, tidyverse, broom, reshape2,dplyr)

#Einlesen der Daten nd speichern in Tibbels
emission <- read_csv("C:/Users/Moritz/Desktop/projects/DBS-Projekt/data/original_data/co2_emission.csv")
gdp_w <- read_csv("C:/Users/Moritz/Desktop/projects/DBS-Projekt/data/original_data/gdp.csv")
p_growth_w <- read_csv("C:/Users/Moritz/Desktop/projects/DBS-Projekt/data/original_data/population_growth.csv")
p_total <- read_csv("C:/Users/Moritz/Desktop/projects/DBS-Projekt/data/original_data/population_total.csv")
energy <- read_csv("C:/Users/Moritz/Desktop/projects/DBS-Projekt/data/original_data/total-energy-consumption.csv")


energy
#Verändern der Daten von WIde zuLong format

gdp <- melt( gdp_w, id.vars = c("Country Name","Country Code","Indicator Name","Indicator Code"), variable.name = "year") %>% as_tibble()
p_growth <- melt(p_growth_w, id.vars = c("Country Name","Country Code","Indicator Name","Indicator Code"), variable.name = "year") %>% as_tibble()
rm(p_growth_w,gdp_w)
#was noch zu tun ist: 
#country codes aus der Tabelle energy vervollständigen.
#unnötige "countries" entfernen:
#- Africa; Asia Pacific;  Burma; CIS; Central America; Eastern Africa; Europe; Europe (other)
#  Ivory Coast; Macau; Middle Africa; Middle East; North America; OPEC; Other Asia & Pacific; Other CIS
# Other Caribbean; Other Middle East;Other Northern Africa; Other South America; Other Southern Africa;
# South & Central America; United States Pacific Islands; Western Africa; 

energy <- rename(energy, "Country Name" = Entity)
energy <- rename(energy, "Country Code" = Code)

emission <- rename(emission, "Country Name" = Entity)
emission <- rename(emission, "Country Code" = Code)

#speichernder Country names in einerm seperaten Tibbel
country <- tibble("Country Name" = energy$"Country Name", 
                  "Country Code" = energy$"Country Code") %>%
  unique() %>%
  drop_na()



#alte rename funktion
#country <- rename(country, "Country Name" = "energy$Entity")
#country <- rename(country, code = "energy$Code")



country <- unique(country)

country <- country %>% drop_na()



#erstelen einer zweiten country TAbelle
country2 <- tibble("Country Name" = gdp$`Country Name`,
                   "Country Code" = gdp$`Country Code`) %>% 
  unique() %>% 
  drop_na()



# <- rename(country2, "Country Name" = "gdp$`Country Name`")
# country2 <- rename(country2, code = "gdp$`Country Code`")




#versuch einer Funktion:
eq_names <- function(table1, table2){
  #ich möchte dass alle Zeilen aus der ersten Tabelle, 
  #die nicht in der zweiten TAbelle vorkommen herausgenommen werden
  # w-(w-r)
  #Entspricht dfer schnittmenge von t1 und t2
  
  #schmeiße alle Werte aus taable W (wrong) heraus, die nicht in tableR (right) vorkommen
  tableTemp <- table1[!(table1$"Country Name" %in% table2$"Country Name"),] 
  table1 <- table1[!(table1$"Country Name" %in% tableTemp$"Country Name"),]
  
  missing1 <- tableTemp
  
  tableTemp <- table2[!(table2$"Country Name" %in% table1$"Country Name"),] 
  table2 <- table2[!(table2$"Country Name" %in% tableTemp$"Country Name"),]  
  
  missing2 <- tableTemp
  
  return(table1)
  
  rm(tableTemp,table1,table2,missing2,missing1)
}

#countries hat nun alle Länder, die beide Tabellen gemeinsam haben.
country <- eq_names(country,country2)
rm(country2)
#nun schmeißen wir alle EInträge in den Tabellen raus, die nicht zu unseren Ländern in countries passen
emission <- eq_names(emission, country) %>% select(-"Country Name") 
gdp <- eq_names(gdp, country) %>% select(-"Country Name") %>% drop_na()
p_growth <- eq_names(p_growth, country) %>% select(-"Country Name") %>% drop_na()
energy <- eq_names(energy, country) %>% select(-"Country Name")

#bevor wir in p_total die Namen entfernen müssen wir erst noch jeder Reihe dien passenden
#code zu seinem Namen zuweisen. 

p_total <- merge(p_total,country, by="Country Name" ) 
p_total <- eq_names(p_total, country) %>% select(-"Country Name") %>% select("Country Code", everything())

gdp$`Indicator Name` <- NULL
gdp$`Indicator Code` <- NULL

p_growth$`Indicator Name` <- NULL
p_growth$`Indicator Code` <- NULL



#spechern der DAten in .csv dateinen
write.csv(gdp,"C:/Users/Moritz/Desktop/projects/DBS-Projekt/data/new_data/gdp.csv")
write.csv(p_growth,"C:/Users/Moritz/Desktop/projects/DBS-Projekt/data/new_data/population_growth.csv")
write.csv(country,"C:/Users/Moritz/Desktop/projects/DBS-Projekt/data/new_data/country.csv")
write.csv(emission,"C:/Users/Moritz/Desktop/projects/DBS-Projekt/data/new_data/emission.csv")
write.csv(p_total,"C:/Users/Moritz/Desktop/projects/DBS-Projekt/data/new_data/population_total.csv")
write.csv(energy,"C:/Users/Moritz/Desktop/projects/DBS-Projekt/data/new_data/energy.csv")

