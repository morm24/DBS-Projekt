#-------------------------------#
# AUthor: Moritz Berger         #
# Date: 25.06.2021              #
# Versuch einer Shiny App       #
#-------------------------------#

# Load R packages
library(shiny)
library(shinythemes)


# Define UI
ui <- fluidPage(theme = shinytheme("sandstone"),
                navbarPage(
                  # theme = "cerulean",  # <--- To use a theme, uncomment this
                  "DBS-Projekt",
                  tabPanel("Plot",
                           sidebarPanel(
                             tags$h3("Select your data"),
                             
                             
                             selectInput("select", label = h3("Select Table"),
                                         choices = list("emission" = 1,
                                                        "gdp" = 2,
                                                        "population growth" = 3,
                                                        "population total" = 4,
                                                        "energy" = 5,
                                                        "country" = 6),
                                         selected = 6
                                         ),
                             
                             radioButtons(
                               inputId = "test",
                               label = h4("Select Table"),
                               choices = list("emission" = 1,
                                              "gdp" = 2,
                                              "population growth" = 3,
                                              "population total" = 4,
                                              "energy" = 5,
                                              "country" = 6)
                             )
                             #textInput("txt1", "Given Name:", ""),
                             #textInput("txt2", "Surname:", ""),
                             
                           ), # sidebarPanel
                           mainPanel(
                             h1("Header 1"),
                             
                             h4("Output 1"),
                     verbatimTextOutput("txtout"),
                             
                           ) # mainPanel
                           
                  ) # Navbar 1, tabPanel
                  #tabPanel("Navbar 2", "This panel is intentionally left blank"),
                  #("Navbar 3", "This panel is intentionally left blank")
                  
                ) # navbarPage
) # fluidPage

server <- function(input, output) {
  
  output$txtout <- renderText({
    paste( input$txt1, input$txt2, sep = " " )
  })
} # server



# Create Shiny object
shinyApp(ui = ui, server = server)