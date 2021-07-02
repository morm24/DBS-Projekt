library(shiny)
library(shinythemes)
library(RMySQL)

# Create database connection
mydb <- dbConnect(MySQL(),
                 user='root',
                 password='word',
                 dbname='db_name',
                 port=3306)


# country$name wird als country$code eingelesen                                          
c_tib = dbGetQuery(mydb, "SELECT * FROM country")
country_name <- c_tib$code
names(country_name ) <- c_tib$name

lapply( dbListConnections( dbDriver( drv = "MySQL")), dbDisconnect)

# Define UI
ui <- fluidPage(theme = shinytheme("slate"),
                navbarPage(
                  #theme = "cerulean",  # <--- To use a theme, uncomment this
                  "DBS-Projekt",
                  tabPanel("Plot",
                           sidebarPanel(
                             tags$h3("Select your data"),
                             
                             
                             selectInput("select", label = h3("Select Table"),
                                         c("value", "emission")), #width = 4,
                             
                             selectizeInput(inputId = 'selectIn', label = "Select country", 
                                            choices= c_tib$name,
                                            multiple = TRUE,
                                            options = list(maxItems=4,
                                                           placeholder = 'Select 4 countries')
                             ),
                             
                             
                             
                             selectInput("country_id", label = h3("Select Country"),
                                         c(country_name)),
                             
                             actionButton("submitbutton", "Submit", class = "btn btn_primary")
                             
                           ), # sidebarPanel
                           
                           mainPanel(
                             h1("Header 1"),
                             
                             h4("Output 1"),
                             verbatimTextOutput("txtout"),
                             
                             plotOutput("test_plot"), width = 8,
                             
                             textOutput("selected_country_id")
                             
                           ) # mainPanel
                           
                  ) # Navbar 1, tabPanel
                  # tabPanel("Navbar 2", "This panel is intentionally left blank"),
                  # ("Navbar 3", "This panel is intentionally left blank")
                  
                ) # navbarPage
) # fluidPage

server <- function(input, output) {
  
  
  output$test_plot <- renderPlot({
    
    mydb <- dbConnect(MySQL(),
                     user='root',
                     password='word',
                     dbname='db_name',
                     port=3306)
    
    big <- dbGetQuery(mydb, paste0('SELECT * FROM gdp G, co2_emission C WHERE G.code = C.code             
                                                                  AND G.year = C.year AND c.code = "', input$country_id, '"')) # Umwandlung von DECIMAL zu numeric rundet Zahlen 
    plot(big$year, big[[input$select]],     # wählt zwischen verschiedenen y-Achsen        
         xlab = "Year", ylab =  "Value")
    
    
    lapply( dbListConnections( dbDriver( drv = "MySQL")), dbDisconnect)
  })
  
} # server


# Create Shiny object
shinyApp(ui = ui, server = server)

