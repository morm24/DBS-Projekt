#-------------------------------#
# AUthor: Moritz Berger         #
# Date: 25.06.2021              #
# Versuch einer Shiny App       #
#-------------------------------#

# Load R packages
library(shiny)
library(shinythemes)
library(RMySQL)

#COnnect to the Database
mydb = dbConnect(MySQL(),
                 user='root',
                 password='5142',
                 dbname='dbs_project',
                 host='127.0.0.1')


dbListTables(mydb)

country <- dbGetQuery(mydb, 'SELECT * FROM country')



dbDisconnect( dbListConnections( dbDriver( drv = "MySQL"))[[1]])






# Define UI
ui <- fluidPage(theme = shinytheme("sandstone"),
                titlePanel("DBS-Projekt | Vergleich Laenderspezifischer Kennzahlen"),
                navbarPage(
                  # theme = "cerulean",  # <--- To use a theme, uncomment this
                  "",
                  tabPanel("Uebersicht",
                           sidebarPanel(
                             tags$h3("Laenderauswahl"),
                             
                             selectizeInput(inputId = 'inSelect',
                                            label = "Laender",
                                            choices = country$name,
                                            multiple = TRUE,
                                            options = list(maxItems = 4, 
                                                           placeholder = 'waehle bis 4 Laender')
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
                               inputId = "selectC2",
                               label = h4("Select Table"),
                               choices = list("emission" = 1,
                                              "gdp" = 2,
                                              "population growth" = 3,
                                              "population total" = 4,
                                              "energy" = 5,
                                              "none" = 6)#,
                               #options = list(maxitems =2)
                             ),
                            
                            selectInput(
                              inputId = "selectC1",
                              label = h4("Select 2nd. Table"),
                              choices = list("emission" = 1,
                                             "gdp" = 2,
                                             "population growth" = 3,
                                             "population total" = 4,
                                             "energy" = 5,
                                             "none" = 6)#,
                              #options = list(maxitems =2)
                            )
                            
                             #textInput("txt1", "Given Name:", ""),
                             #textInput("txt2", "Surname:", ""),
                             
                           ), # sidebarPanel
                           mainPanel(
                             h1("Header 1"),
                             
                             h4("Output 1"),
                     verbatimTextOutput("txtout"),
                     h4("Output 2"),
                     verbatimTextOutput("text")
                             
                           ) # mainPanel
                           
                  ) # Navbar 1, tabPanel
                  #tabPanel("Navbar 2", "This panel is intentionally left blank"),
                  #("Navbar 3", "This panel is intentionally left blank")
                  
                ) # navbarPage
) # fluidPage

server <- function(input, output) {
  
  output$txtout <- renderText({
    paste(input$inSelect )
  })
  
  output$text <- renderPrint({
    req(input$inSelect)
    country$code[match(input$inSelect,country$name)]
  })
  
  
} # server



# Create Shiny object
shinyApp(ui = ui, server = server)