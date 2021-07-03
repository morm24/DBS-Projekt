#-------------------------------#
# AUthor: Moritz Berger         #
# Date: 25.06.2021              #
# Versuch einer Shiny App       #
#-------------------------------#

# Load R packages
library(shiny)
library(shinythemes)
library(RMySQL)
library(dplyr)
library(ggplot2)



#COnnect to the Database
mydb = dbConnect(MySQL(),
                 user='root',
                 password='5142',
                 dbname='dbs_project',
                 host='127.0.0.1')


dbListTables(mydb)




country <- dbGetQuery(mydb, 'SELECT * FROM country') 
emission  <- dbGetQuery(mydb, 'SELECT * FROM co2_emission')
gdp  <- dbGetQuery(mydb, 'SELECT * FROM gdp') 
pop_t  <- dbGetQuery(mydb, 'SELECT * FROM population_total')
pop_g  <- dbGetQuery(mydb, 'SELECT * FROM population_growth')
energy  <- dbGetQuery(mydb, 'SELECT * FROM energy')

colnames(emission)[3] <- "value"
colnames(gdp)[3] <- "value"
colnames(pop_t)[3] <- "value"
colnames(pop_g)[3] <- "value"
colnames(energy)[3] <- "value"

emission$year = as.numeric(as.character(emission$year))
gdp$year = as.numeric(as.character(gdp$year))
pop_t$year = as.numeric(as.character(pop_t$year))
pop_g$year = as.numeric(as.character(pop_g$year))
energy$year = as.numeric(as.character(energy$year))




lapply( dbListConnections( dbDriver( drv = "MySQL")), dbDisconnect)


countryN <- country$code
names(countryN) <- country$name


unit <- c("tons CO2" = "emission",
          "US$" ="gdp",
          "annual %" = "population growth",
          "count" = "population total",
          "TWh" = "energy"
)



# Define UI
ui <- fluidPage(theme = shinytheme("sandstone"),
                titlePanel("DBS-Project | Comparison of country-specific key figurs"),
                navbarPage(
                  # theme = "cerulean",  # <--- To use a theme, uncomment this
                  "",
                  tabPanel("Overview",
                           sidebarPanel(
                             tags$h3("table selectrion"),
                             
                             selectizeInput(inputId = 'inSelect',
                                            label = "countries",
                                            choices = countryN,
                                            multiple = TRUE,
                                            options = list(maxItems = 4, 
                                                           placeholder = 'select up to 4 countries')
                             ),
                             
                             
                             ##selectInput("select", label = h3("Select Table"),
                             ##             choices = list("emission" = 1,
                             ##                            "gdp" = 2,
                             ##                            "population growth" = 3,
                             ##                            "population total" = 4,
                             ##                            "energy" = 5,
                             ##                            "country" = 6),
                             ##             selected = 6
                             ##             ),
                             
                             selectInput(
                               inputId = "selectT1",
                               label = h4("Select 1st Table"),
                               choices = list("emission" = "emission",
                                              "gdp" = "gdp",
                                              "population growth" = "population growth",
                                              "population total" = "population total",
                                              "energy" = "energy"
                                 #"emission" = emission,
                                  #            "gdp" ='gdp' ,
                                   #           "population growth" = 'pop_g',
                                    #          "population total" = 'pop_t',
                                     #         "energy" = 'energy')#,
                               #options = list(maxitems =2
                               )
                             ),
                             
                             selectInput(
                               inputId = "selectT2",
                               label = h4("Select 2nd Table"),
                               choices = list(
                                              "none" = 7,
                                              "emission" = "emission",
                                              "gdp" = "gdp",
                                              "population growth" = "population growth",
                                              "population total" = "population total",
                                              "energy" = "energy"),
                               selected = 
                             ),
                             
                             actionButton("submitbutton", "Submit", class = "btn btn-primary")
                             
                             #textInput("txt1", "Given Name:", ""),
                             #textInput("txt2", "Surname:", ""),
                             
                           ), # sidebarPanel
                           mainPanel(
                             
                             plotOutput("line1"),
                            
                            
                            plotOutput("line2")
                            
                             
                           ) # mainPanel
                           
                  ), # Navbar 1, tabPanel
                  tabPanel("Navbar 2", "This panel is intentionally left blank"),
                  
                  
                  tabPanel("Navbar 3", "This panel is intentionally left blank")
                  
                ) # navbarPage
) # fluidPage

server <- function(input, output) {
  
  output$name1 <- renderText({
    paste(input$input$"selectT1" )
  })
  
  output$text <- renderPrint({
    paste(input$inSelect)
  })
  
  
  
  #halte das reaktive verhalten von shiny auf
  table_plot1 <- reactive({
    if(input$submitbutton>0){
    
    
    switch((input$'selectT1'),
           "emission"=(table <- emission),
           "gdp"=(table <- gdp),
           'population growth'=(table <- pop_g),
           'population total'=(table <- pop_t),
           'energy'=(table <- energy))        
   
    
    #table <- tables[input$'selectT1']
    
    table_sub <- filter(table, code == input$'inSelect')
   
    }
  })
  
  table_plot2 <- reactive({
    if(input$submitbutton>0){
    if(input$selectT2 != 7){
      
      switch((input$'selectT2'),
             "emission"=(table2 <- emission),
             "gdp"=(table2 <- gdp),
             'population growth'=(table2 <- pop_g),
             'population total'=(table2 <- pop_t),
             'energy'=(table2 <- energy))
      
      table_sub2 <- filter(table2, code == input$'inSelect')
      
      #konkadiiere die letzt zeile der tabelle2 an tabelle 1 an. 
      
    }
    }
    })
 
  
  output$line1 <- renderPlot({
    if(input$submitbutton>0){
   
      
      
    ggplot(data=table_plot1(), aes(x=year, y=value, group=code)) +
      geom_line( aes(color=code)
                   
                   
                 
                 ) +
        scale_y_continuous(labels = scales::comma)+
        labs(
          x = 'year',
          y = names(unit[which(unit == input$selectT1)]),
          title = input$"selectT1"
        ) +
        scale_x_continuous(limits = c(1960, 2020))
      
      
    }#if ende
  })#render plot ende
  
  
  output$line2 <- renderPlot({
    if(input$submitbutton>0){
      if(input$selectT2 != 7){
       
        ggplot(data=table_plot2(), aes(x=year, y=value, group=code)) +
          geom_line( aes(color=code)
          ) +
          scale_y_continuous(labels = scales::comma)+
          labs(
            x = 'year',
            y = names(unit[which(unit == input$selectT2)]),
            title = input$"selectT2"
          )+
          scale_x_continuous(limits = c(1960, 2020))
        
        
      }
    }
    
    
  })
  
  
  
  
} # server



# Create Shiny object
shinyApp(ui = ui, server = server)
