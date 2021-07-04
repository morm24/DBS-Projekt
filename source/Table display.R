
library(shiny)
library(shinythemes)
library(RMySQL)
library(dplyr)
library(ggplot2)







# Define UI
ui <- fluidPage(theme = shinytheme("cerulean"),
                navbarPage(
                  # theme = "cerulean",  # <--- To use a theme, uncomment this
                  "My first app",

                  tabPanel("Navbar 1",
                           sidebarPanel(
                             
                             selectInput("select1", label = h3("Select Table"),
                                         choices = c("energy", 
                                                     "co2_emission", 
                                                     "gdp", 
                                                     "population_total", 
                                                     "population_growth"),
                                         #selected = 1
                                         ),
                             
                             selectInput("select2", label = h3("Select Table"),
                                         choices = c("none",
                                                     "energy", 
                                                     "co2_emission", 
                                                     "gdp", 
                                                     "population_total", 
                                                     "population_growth"),
                                         #selected = 1
                             ),
                             
                             radioButtons(
                               "join",
                               "Select",
                               c("Yes", "No")
                             ),
                                          
                             
                            actionButton("mitbutton", "Submit")
                           ),
                           
                           
                           
                           mainPanel(
                             dataTableOutput("data1"),
                             
                             
                             
                           )
                           )
                  
                ) # navbarPage
) # fluidPage


# Define server function  
server <- function(input, output) {

  
  output$data1 <- renderDataTable({
    input$mitbutton
    
    if(input$mitbutton == 0)
      return()
    else
      mydb <- dbConnect(MySQL(),     
                        user='root',    
                        password='word',     
                        dbname='db_name',     
                        port=3306)
              
    if(input$select2 == "none")
      table <- dbGetQuery(mydb, paste0('SELECT * FROM ', input$select1))
    else
      table <- dbGetQuery(mydb, paste0('SELECT * FROM ', input$select1, ' A, ', input$select2, ' B WHERE A.code = B.code AND A.year = B.year'))

    lapply( dbListConnections( dbDriver( drv = "MySQL")), dbDisconnect)
      
    isolate(table)

  })
  
    


  
} # server


# Create Shiny object
shinyApp(ui = ui, server = server)
