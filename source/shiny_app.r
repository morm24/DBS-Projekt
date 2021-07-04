#-------------------------------#
# Author: Moritz Berger         #
# Date: 25.06.2021              #
# Complete shiny app for        #
# DBS-project                   #
#-------------------------------#

# Load R packages
library(shiny)
library(shinythemes)
library(RMySQL)
library(dplyr)
library(ggplot2)


#Fething and preprocessing data befor the UI is rendered, so we have all tables
#set when the "real" programm starts


#Establish Dataabaase connection. 

#-----------------------------------------------------------------------------#
  
#here you can set cennection deteils, if you want to use the program
user<-'root'
password<-'word'
dbname<-'db_name'
host<-'localhost'
port<-3306
#-----------------------------------------------------------------------------#



mydb = dbConnect(MySQL(),
                 user=user,
                 password=password,
                 dbname=dbname,
                 host=host,
                 port=port
                 )


#dbListTables(mydb)



#get all the tables from the Database
country <- dbGetQuery(mydb, 'SELECT * FROM country') 
emission  <- dbGetQuery(mydb, 'SELECT * FROM co2_emission')
gdp  <- dbGetQuery(mydb, 'SELECT * FROM gdp') 
pop_t  <- dbGetQuery(mydb, 'SELECT * FROM population_total')
pop_g  <- dbGetQuery(mydb, 'SELECT * FROM population_growth')
energy  <- dbGetQuery(mydb, 'SELECT * FROM energy')


#change the 3rd collum name in each dataabase to value, for easier processing
colnames(emission)[3] <- "value"
colnames(gdp)[3] <- "value"
colnames(pop_t)[3] <- "value"
colnames(pop_g)[3] <- "value"
colnames(energy)[3] <- "value"


#change the year column to an numeric type, to have a better scaled X-Axis
emission$year = as.numeric(as.character(emission$year))
gdp$year = as.numeric(as.character(gdp$year))
pop_t$year = as.numeric(as.character(pop_t$year))
pop_g$year = as.numeric(as.character(pop_g$year))
energy$year = as.numeric(as.character(energy$year))


#disconnect all database connections
lapply( dbListConnections( dbDriver( drv = "MySQL")), dbDisconnect)


#store the coutry dataa in new formats to have easier access 
#in the multiselect choiclist
countryN <- country$code
names(countryN) <- country$name


#create a list Units, to easily add un to the Y-Axis of the Plot
unit <- c("tons CO2" = "emission",
          "US$" ="gdp",
          "annual %" = "population growth",
          "count" = "population total",
          "TWh" = "energy"
)



#Here the User-Interface is defined for the shiny app.
ui <- fluidPage(theme = shinytheme("sandstone"),
                titlePanel("DBS-Project | Comparison of country-specific key figurs"),
                
                navbarPage(
                  # theme = "cerulean",  # <--- To use a theme, uncomment this
                  
                  
                  
                  #this is the tab panel to give an interactive 
                  #data overvierview to the user
                  tabPanel("Overview",
                           sidebarPanel(
                             tags$h3("table selectrion"),
                             
                             
                             #Building a box where you can select multiple countries 
                             #out of the country table and store them in the
                             #input Object "inSelect"
                             selectizeInput(inputId = 'inSelect',
                                            label = "countries",
                                            choices = countryN,
                                            multiple = TRUE,
                                            selected = subset(countryN,countryN %in% c("DEU","JPN","FRA","ZAF")),
                                            options = list(maxItems = 4, 
                                            placeholder = 'select up to 4 countries')
                             ),
                             
                             
                             #Box to select the first Table on the side
                             selectInput(
                               inputId = "selectT1",
                               label = h4("Select 1st Table"),
                               choices = list("emission" = "emission",
                                              "gdp" = "gdp",
                                              "population growth" = "population growth",
                                              "population total" = "population total",
                                              "energy" = "energy"
                               )
                             ),
                             
                             
                             #Box to select the second Table on the side.
                             selectInput(
                               inputId = "selectT2",
                               label = h4("Select 2nd Table"),
                               choices = list("none" = 7,
                                              "emission" = "emission",
                                              "gdp" = "gdp",
                                              "population growth" = "population growth",
                                              "population total" = "population total",
                                              "energy" = "energy"
                                 )
                              ),
                             
                             
                             #added submitbutton on the site, so there are no
                             #error messagtes when picking tables and stuff
                             actionButton("submitbutton", "Submit", class = "btn btn-primary")
                          ), 
                           
                          
                          #Here we are aon the "main Page" of the Site 
                          #where the plots are shown
                           mainPanel(
                             
                             
                             #plotting Plot nr.1
                             plotOutput("line1"),
                            
                            
                             #plotting plot nr.2
                             plotOutput("line2")
                            
                             
                           )#end of maain Panel 
                           
                  )#End of main tab
                  , 
                  
                  # wanted to add more panels like an connection panel. 
                  #sadly this wasent possible with the Time and 
                  #knowledge we had.
                  
                  
                  tabPanel("Table display", 
                           
                                    sidebarPanel(
                                      
                                      selectInput("select1", label = h3("Select Table 1"),
                                                  choices = c("energy", 
                                                              "co2_emission", 
                                                              "gdp", 
                                                              "population_total", 
                                                              "population_growth"),
                                                  #selected = 1
                                      ),
                                      
                                      selectInput("select2", label = h3("Select Table 2"),
                                                  choices = c("energy", 
                                                              "co2_emission", 
                                                              "gdp", 
                                                              "population_total", 
                                                              "population_growth"),
                                                  #selected = 1
                                      ),
                                      
                                      
                                      
                                      
                                      actionButton("mitbutton", "Submit")
                                    ),
                           mainPanel(
                             dataTableOutput("data1"),
                             
                             
                             
                           )
                           ),
                  #hier soll eine vergleichsseite mit tests (t-tests) entstehen
                  
                # tabPanel("DBS-Access", "This panel is intentionally left blank"),
                # #ich sollen spezielle abfragen an die Datenbank ermoeglicht werden
                # 
                # 
                # tabPanel("Connection", 
                #          tags$h4("you can change the connection to the database here"),
                #          tags$h5("IP:")#,
                #         # textInput()
                #       )
                ) #end navbar
) # end fluidPage



#in this part the reactive server is 
#all data processing is done in this block of code
server <- function(input, output) {

  
  output$data1 <- renderDataTable({
    input$mitbutton
    
    if(input$mitbutton == 0)
      return()
    else
    mydb <- dbConnect(MySQL(),     
                        user=user,
                        password=password,
                        dbname=dbname,
                        host=host,
                        port=port)
    
    if(input$select2 == "none")
      table <- dbGetQuery(mydb, paste0('SELECT * FROM ', input$select1))
    else
      table <- dbGetQuery(mydb, paste0('SELECT * FROM ', input$select1, ' A, ', input$select2, ' B WHERE A.code = B.code AND A.year = B.year'))
    
    lapply( dbListConnections( dbDriver( drv = "MySQL")), dbDisconnect)
    
    isolate(table)
    
  })
  
  
  
  
  
  #getting the table to use out of the Select 1st table field 
  table_plot1 <- reactive({
    if(input$submitbutton>0){
    
      
    #adding the right table to an variable, selected by the string out of the 
    #select 1st table
    switch((input$'selectT1'),
           "emission"=(table <- emission),
           "gdp"=(table <- gdp),
           'population growth'=(table <- pop_g),
           'population total'=(table <- pop_t),
           'energy'=(table <- energy))        
    
    #short the Table, that only the rows with the country codes, 
    #selected by the user are left
    table_sub <- filter(table, code == input$'inSelect')
   
    }
  })
  
  
  #getting the table to use out of the Select 2nd table field 
  table_plot2 <- reactive({
    if(input$submitbutton>0){
      if(input$selectT2 != 7){
      
        switch((input$'selectT2'),
             "emission"=(table2 <- emission),
             "gdp"=(table2 <- gdp),
             'population growth'=(table2 <- pop_g),
             'population total'=(table2 <- pop_t),
             'energy'=(table2 <- energy))
      
      
      #short the Table, that only the rows with the country codes, 
      #selected by the user are left
        table_sub2 <- filter(table2, code == input$'inSelect')
      
        }#if ende
      }#if ende
    })#reactive ende
 
  
  #render the first plot 
  output$line1 <- renderPlot({
    if(input$submitbutton>0){
   
    #build the Plot as a ggplot
    ggplot(data=table_plot1(), aes(x=year, y=value, group=code)) +
      geom_line( aes(color=code)) +
        scale_y_continuous(labels = scales::comma)+
        labs(
          x = 'year',
          y = names(unit[which(unit == input$selectT1)]),
          title = input$"selectT1"
        ) +
        scale_x_continuous(limits = c(1960, 2020),breaks = seq(1960,2020,10))
      
    }#if ende
  })#render plot ende
  
  
  output$line2 <- renderPlot({
    if(input$submitbutton>0){
      if(input$selectT2 != 7){
       
        #build the Plot as a ggplot
        ggplot(data=table_plot2(), aes(x=year, y=value, group=code)) +
          geom_line( aes(color=code)) +
          scale_y_continuous(labels = scales::comma)+
          labs(
            x = 'year',
            y = names(unit[which(unit == input$selectT2)]),
            title = input$"selectT2"
          )+
          scale_x_continuous(limits = c(1960, 2020),breaks = seq(1960, 2020, by = 10))
     
      }#if ende
    }#if ende
  })#render plot ende
  
} # server ende



# Create Shiny object
shinyApp(ui = ui, server = server)
