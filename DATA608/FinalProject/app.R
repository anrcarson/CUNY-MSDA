#############################
# DATA 608 Final Project
# by Andy Carson
###############################

##############
#references:
##############
#https://moderndata.plot.ly/interactive-r-visualizations-with-d3-ggplot2-rstudio/
#https://plot.ly/r/reference/
#https://stackoverflow.com/questions/23233497/outputting-multiple-lines-of-text-with-rendertext-in-r-shiny
#https://plot.ly/r/multiple-axes/
#https://shiny.rstudio.com/gallery/including-html-text-and-markdown-files.html

#############
#packages
#############
library(shiny)
library(plotly)
library(tidyr)
library(dplyr)
library(stringr)
library(MASS)

#################
#data: global
#################
# read in global data

#carbon emissions
carbonEmissions <- read.csv("https://raw.githubusercontent.com/anrcarson/CUNY-MSDA/master/DATA608/FinalProject/epa_carbonemissions.csv")
names(carbonEmissions) <- c("Year", "CarbonEmissions_Total", "CarbonEmissions_GasFuel",
                            "CarbonEmissions_LiquidFuel", "CarbonEmissions_SolidFuel",
                            "CarbonEmissions_CementProd","CarbonEmissions_GasFlaring", 
                            "CarbonEmissions_PerCapita")

#energy usage
energyUsage<- read.csv("https://raw.githubusercontent.com/anrcarson/CUNY-MSDA/master/DATA608/FinalProject/eia_primaryEnergyOverview.csv")
energyUsage <- dplyr::select(energyUsage, Year, Month, Value, Description)
energyUsage_pivot <- spread(energyUsage, Description, Value)
energyUsage_filtered <-energyUsage_pivot %>% filter(Month == 13) 
energyUsage_filtered$Month <- NULL
names(energyUsage_filtered) <-c("Year", "EnergyConsumption_Nuclear","EnergyProd_Nuclear", 
                                "EnergyExports", "EnergyImports", "EnergyNetImports", 
                                "EnergyStockChangeOther", "EnergyConsumption_Fuels","EnergyProd_Fuels", 
                                "EnergyConsumption_Total", "EnergyProd_Total", 
                                "EnergyConsumption_Renewable", "EnergyProd_Renewable")

#temperature
temperature<- read.csv("https://raw.githubusercontent.com/anrcarson/CUNY-MSDA/master/DATA608/FinalProject/nasa_globalYearlyAvgTemp.csv")
names(temperature) <- c("Year","Temp_MeanRelativeChange", "Temp_LowessSmoothing")

#joined data
global <- full_join(carbonEmissions, temperature, by = "Year") %>% full_join(energyUsage_filtered, by = "Year")

#####################
####global - lm
######################
#used for analysis in writeup, not for visualization

# global_model <- lm(data = global, Temp_MeanRelativeChange ~ 
#                    #  CarbonEmissions_Total #+         
#                   #CarbonEmissions_GasFuel        +
#                   # CarbonEmissions_LiquidFuel    +
#                   # CarbonEmissions_SolidFuel      +
#                   #CarbonEmissions_CementProd    +
#                   # CarbonEmissions_GasFlaring     
#                    #CarbonEmissions_PerCapita     +
#                    #EnergyConsumption_Nuclear      + #missing values
#                    #EnergyProd_Nuclear            +
#                    #EnergyExports                  +
#                    #EnergyImports                 +
#                    #EnergyNetImports               +
#                    #EnergyStockChangeOther        + #missing values
#                    #EnergyConsumption_Fuels +       #missing values
#                    #EnergyProd_Fuels              +
#                    EnergyConsumption_Total        +
#                    EnergyProd_Total              
#                    #EnergyConsumption_Renewable    +
#                    #EnergyProd_Renewable               
#                      )
# global_model_AIC<-stepAIC(global_model, trace = 0)
# summary(global_model_AIC)
# summary(global_model)


##################
#data: home
#################
# read in home data

#seattle temperatures
seattleTemp <- read.csv("https://raw.githubusercontent.com/anrcarson/CUNY-MSDA/master/DATA608/FinalProject/seattleTemp_201708_201809.csv", stringsAsFactors = FALSE)
seattleTemp$Date <-strftime(strptime(seattleTemp$Date, format = "%m/%d/%Y", tz=""))
seattleTemp$Temp_Avg_AbsDiff65 <-abs(seattleTemp$Temp_Avg - 65)

#home energy usage: read, clean up, create variables
homeEnergyUsage <- read.csv("https://raw.githubusercontent.com/anrcarson/CUNY-MSDA/master/DATA608/FinalProject/HomeEnergy_All.csv", stringsAsFactors = FALSE)
homeEnergyUsage$Date <- str_sub(homeEnergyUsage$Date.America.Los_Angeles.,1,
                                  str_locate(homeEnergyUsage$Date.America.Los_Angeles., " ")[,1]-1)
homeEnergyUsage$Date <-strftime(strptime(homeEnergyUsage$Date, format = "%m/%d/%Y", tz=""))
homeEnergyUsage$Hour <-as.integer(str_sub(homeEnergyUsage$Date.America.Los_Angeles.,
                               str_locate(homeEnergyUsage$Date.America.Los_Angeles., " ")[,1] + 1,
                               str_locate(homeEnergyUsage$Date.America.Los_Angeles., ":")[,1] - 1))
homeEnergyUsage$HourMin <-str_sub(homeEnergyUsage$Date.America.Los_Angeles.,
                                  str_locate(homeEnergyUsage$Date.America.Los_Angeles., " ")[,1] + 1,
                                  1000)
homeEnergyUsage$HourMin[nchar(homeEnergyUsage$HourMin)==4] <-
  str_c("0",homeEnergyUsage$HourMin[nchar(homeEnergyUsage$HourMin)==4])

homeEnergyUsage$DayOfWeek <- weekdays(as.Date(homeEnergyUsage$Date))
homeEnergyUsage$DayOfWeek_Order <- sapply(homeEnergyUsage$DayOfWeek, switch, 
                                          Sunday = 1, 
                                          Monday = 2,
                                          Tuesday = 3,
                                          Wednesday = 4, 
                                          Thursday = 5,
                                          Friday = 6,
                                          Saturday = 7)
homeEnergyUsage$Month <- substr(homeEnergyUsage$Date,6,7)
homeEnergyUsage <- homeEnergyUsage[homeEnergyUsage$Date>="2017-09-01",] #remove August 2017, incomplete month

#group for usage
homeEnergyUsage_grouped <- homeEnergyUsage %>%
  dplyr::select(Date, Hour, Month, Eyedro.Electricity.Monitor.Port.A...Energy..Wh., Eyedro.Electricity.Monitor.Port.B...Energy..Wh., Total) %>%
  group_by(Date, Hour, Month) %>%
  summarise_all(sum) %>%
  ungroup()
names(homeEnergyUsage_grouped)<-c("Date","Hour", "Month_Chr", "Wh_PortA", "Wh_PortB", "Wh_Total")

homeEnergyUsage_Day <- homeEnergyUsage_grouped %>%
  dplyr::select(Date, Month_Chr, Wh_PortA, Wh_PortB, Wh_Total)%>%
  group_by(Date, Month_Chr) %>%
  summarise_all(sum) %>%
  ungroup()
homeEnergyUsage_Day$DayOfWeek <- weekdays(as.Date(homeEnergyUsage_Day$Date))
homeEnergyUsage_Day$DayOfWeek_Order <- sapply(homeEnergyUsage_Day$DayOfWeek, switch, 
                                              Sunday = 1, 
                                              Monday = 2,
                                              Tuesday = 3,
                                              Wednesday = 4, 
                                              Thursday = 5,
                                              Friday = 6,
                                              Saturday = 7)
#joined
home <- full_join(homeEnergyUsage_Day, seattleTemp, by="Date")

################
#home lm
#####################
#used for analysis in writeup, not for visualization

# home_model <- lm(data = home, Wh_Total ~ 
#                    DayOfWeek + 
#                    Month + 
#                    Temp_Max +
#                    Temp_Min +
#                    Temp_Avg +
#                    Temp_Avg_AbsDiff65 + 
#                    DewPoint_Avg + 
#                    DewPoint_Max +
#                    DewPoint_Min +
#                    Humidity_Min +
#                    Humidty_Max + 
#                    WindSpeed_Max +
#                    WindSpeed_Min +
#                    Pressure_Max + 
#                    Pressure_Min +
#                    Precip_Avg
#                  )
# 
# summary(home_model)

################
#home binarize lm
################
#make character columns into multiple binary columns
#used for analysis in writeup, not for visualization

# home_binarize <- home
# home_binarize$Date <- NULL
# home_binarize$Month_Chr <- NULL
# home_binarize <- data.frame(home_binarize, stringsAsFactors = FALSE)
# 
# data <-home_binarize
# 
# for(i in 1:length(data)){
#   #i<-1
#   if(is.character(data[,i])){
#     #get distinct values
#     distinct<-unique(data[,i])
#     for(j in 1:length(distinct)){
#       #j<-1
#       data$temp <- data[,i]
#       index<-which(data$temp == distinct[j])
#       notIndex <-which(data$temp != distinct[j])
#       data$temp[index] <-1
#       data$temp[notIndex] <-0
#       data$temp<-as.numeric(data$temp)
#       names(data)[length(data)] <- paste0(names(data[i]),"_",distinct[j])
#       #View(cbind(train[i],train[length(train)]))
#     }#for
#   }#if
# }#for
# 
# home_binarize <- data
# home_binarize$Month_Chr<-NULL
# home_binarize$DayOfWeek<-NULL
# home_binarize$DayOfWeek_Order<-NULL
# home_binarize$Month<-NULL
# home_binarize$Hour<-NULL
# home_binarize$Wh_PortA<-NULL
# home_binarize$Wh_PortB<-NULL
# home_binarize$Year<-NULL
# home_binarize$Day<-NULL
# home_binarize$MonthNum<-NULL
# home_binarize$DayOfWeek_NA <- NULL
# home_binarize$Month_Chr_NA <- NULL
# home_binarize$Month_NA <- NULL
# 
# home_model_AIC <- lm(data = home_binarize, Wh_Total ~ Temp_Avg_AbsDiff65) 
# summary(home_model_AIC)
# 
# home_model_AIC <- update(home_model_AIC, .~. - Temp_Max
#                          - Temp_Min
#                          -Temp_Avg
#                          #-DewPoint_Avg
#                          -DewPoint_Min
#                          -Precip_Avg
#                          -Month_Dec
#                          #-Humidty_Max
#                          )
# 
# home_model_AIC<-stepAIC(home_model_AIC, trace = 0)
# summary(home_model_AIC)

########
## home minute model
#########
#used for analysis in writeup, not for visualization

# home_minute <- full_join(homeEnergyUsage, seattleTemp, by="Date")
# home_minute$Hour_Chr <- as.character(home_minute$Hour)
# 
# home_minute_model <-lm(Total ~Hour_Chr
#                        + DayOfWeek
#                        + Month.y
#                        + DewPoint_Avg
#                        + Humidity_Max
#                        + Temp_Avg_AbsDiff65
#                        , data = home_minute)
# 
# summary(home_minute_model)

###########################
# shiny app: Define UI for application
#############################
ui <- fluidPage(
  
  # Application title
  #titlePanel("title"),
  
  #navigation bar
  navbarPage(
    title = 'Energy Usage: Global and Home',
    tabPanel('Introduction',
             includeMarkdown("https://raw.githubusercontent.com/anrcarson/CUNY-MSDA/master/DATA608/FinalProject/FinalProjectWriteup_Intro.Rmd")
             ),
    tabPanel('Analysis',
             includeMarkdown("https://raw.githubusercontent.com/anrcarson/CUNY-MSDA/master/DATA608/FinalProject/FinalProjectWriteup_Analysis.Rmd")
    ),
    tabPanel('Global Energy Visuals',     
               # Sidebar with a slider input for number of bins 
               sidebarLayout(
                 sidebarPanel(
                   selectInput(inputId = "Xaxis", label = strong("X-Axis"),
                               choices = sort(unique(names(global))),
                               selected = "EnergyConsumption_Total"),
                   selectInput(inputId = "Yaxis", label = strong("Y-Axis"),
                              choices = sort(unique(names(global))),
                              selected = "Temp_MeanRelativeChange"),
                   #add text
                   HTML("<b>Instructions:</b><br>
                        Use the X-Axis and Y-Axis dropdowns to select which variables show up in the top chart.<br><br>
                        Both the X-Axis and Y-Axis variables will be plotted against Year in the bottom chart. <br>
                        <br>
                        
                        <b>Data:</b><br>
                        See \"Introduction\" tab for more details. <br><br>
                        
                        <i>Global Carbon Emissions</i>: <br>
                        Gas fuel, liquid fuel, solid fuel, cement production, gas flaring, per capita, and total.<br><br>
                        
                        <i>Global Energy Production (Prod) and Consumption</i>: <br>
                        Nuclear, fuels, renewable, and totals. <br> Also, exports, imports, net imports, and stock change/other.<br><br>
                        
                        <i>Global Temperature (Temp)</i>: <br>
                        Mean relative temperature change, and Lowess smoothed mean relative temperature.<br><br>                       
                        ")
                 ),
                 
                 # Show plots
                 mainPanel(
                    strong("Y vs. X Plot"),
                    fluidRow(plotlyOutput("globalPlot")),
                    strong("Y and X vs. Year Plot"),
                    fluidRow(plotlyOutput("globalPlot2"))
                 )
               )
             ),
    tabPanel('Home Energy Visuals',
               # Sidebar with a slider input for number of bins 
               sidebarLayout(
                 sidebarPanel(
                   selectInput(inputId = "Xaxis_home", label = strong("X-Axis"),
                               choices = sort(unique(names(home))),
                               selected = "Temp_Avg"),
                   selectInput(inputId = "Yaxis_home", label = strong("Y-Axis"),
                               choices = sort(unique(names(home))),
                               selected = "Wh_Total"),
                   selectInput(inputId = "DayOfWeek_home", label = strong("Filter: Day of Week"),
                               choices = c("No Filter","Sunday", "Monday", "Tuesday", "Wednesday",
                                           "Thursday", "Friday", "Saturday"),
                               selected = "No Filter"),
                   selectInput(inputId = "Month_home", label = strong("Filter: Month"),
                               choices = c("No Filter","01","02","03","04","05","06","07","08","09","10","11","12"),
                               selected = "No Filter"),
                   #add text
                   HTML("<b>Instructions:</b><br>
                        Use the X-Axis and Y-Axis dropdowns to select which variables show up in the top chart.<br><br>
                        Use the \"Day of Week\" and \"Month\" filters to filter all three charts. <br>
                        <br>
                        <b>Data:</b><br>
                        See \"Introduction\" tab for more details. <br><br>
                        <i>Home Energy</i>: <br>
                        Watt Hours (Port A, Port B, and total), Year, Month, Date, Hour, Day of the Week, and Day (of the month). <br><br>
                        <i>Seattle Weather</i>: <br>
                        Temperature (Temp: average, maximum, minimum, absolute difference to 65 degrees), Dewpoint (average, maximum, minimum), Humidity (maximum, minimum), Windspeed (maximum, minimum), Pressure (maximum, minimum), and Precipitation (Precip).
                        ")
                          
                 ),
                 
                 # Show plots  
                 mainPanel(
                   strong("Y vs. X Plot"),
                   fluidRow(title = "Y vs. X", plotlyOutput("HomePlot")),
                   strong("Wh vs. Hour:Minute"),
                   fluidRow(title = "Wh vs. Hour:Minute by Port",
                            column(6,plotlyOutput("HomePlot2")),
                            column(6,plotlyOutput("HomePlot3"))
                            )
                 )
               )
             )
  )
)

# Define server logic required to draw visualizations
server <- function(input, output) {
  
  #global output
   output$globalPlot <- renderPlotly({
     xaxis <- input$Xaxis
     #xaxis <- "EnergyConsumption_Total"
     yaxis <- input$Yaxis
     #yaxis <- "Temp_MeanRelativeChange"
     
     #reduce and get complete cases
     temp <- dplyr::select(global, xaxis, yaxis)
     temp <- temp[complete.cases(temp),]
     
     #get lm
     l <- lm(formula(paste(yaxis, "~",xaxis)), data=temp)
     temp$Fitted <- fitted.values(l)
     r2 <-round(summary(l)$r.squared, digits = 2)
     
     #visual
     plot_ly(data = temp, x =formula(paste("~",xaxis)), y =formula(paste("~",yaxis)),
             mode = "markers", type = "scatter", name = paste(yaxis,"~
                                                              ", xaxis)) %>%
     add_lines(data = temp, x=formula(paste("~",xaxis)), y = ~Fitted, name = paste("linear model;
                                                                                   R^2 = ", r2)) %>%
       layout(title = paste0(yaxis, " vs. ", xaxis))

     })
   
   #global2 output
   output$globalPlot2 <- renderPlotly({
     xaxis <- input$Xaxis
     yaxis <- input$Yaxis
     
     #reduce and complete cases
     temp <- dplyr::select(global, xaxis, yaxis, Year)
     temp <- temp[complete.cases(temp),]
     
     #layouts
     y <- list(
       tickfont = list(color = "blue"),
      # overlaying = "y",
       side = "left",
       title = yaxis
     )
  
     ay <- list(
       tickfont = list(color = "orange"),
       overlaying = "y",
       side = "right",
       title = xaxis
     )
     
     #visuals
     plot_ly(data = temp, x =~Year, y =formula(paste("~",yaxis)),
             mode = "lines", type = "scatter", name = yaxis) %>%
      add_trace(data = temp, x = ~Year, y =formula(paste("~",xaxis)) ,
                mode = "lines", type = "scatter", line = list(dash="dash"), name=xaxis, yaxis = "y2") %>%
       layout(
         yaxis = y,
          yaxis2 = ay,
          title = paste0(yaxis, " and ", xaxis, " vs. Year")
       )
     
     
     
   })
   
   #home output
   output$HomePlot <- renderPlotly({
     xaxis <- input$Xaxis_home
     yaxis <- input$Yaxis_home
     DayOfWeek <- input$DayOfWeek_home
     Month_Chr <- input$Month_home
     
     #apply filters
     temp <- dplyr::select(home, xaxis, yaxis, DayOfWeek, Month_Chr)
     temp <- temp[complete.cases(temp),]
     if(DayOfWeek != "No Filter"){
       temp <- temp[temp$DayOfWeek == DayOfWeek,]
     }
     if(Month_Chr != "No Filter"){
       temp <- temp[temp$Month_Chr == Month_Chr,]
     }
     
     #linear model
     l <- lm(formula(paste(yaxis, "~",xaxis)), data=temp)
     temp$Fitted <- fitted.values(l)
     r2 <-round(summary(l)$r.squared, digits = 2)
     
     #visual
     plot_ly(data = temp, x =formula(paste("~",xaxis)), y =formula(paste("~",yaxis)),
             mode = "markers", type = "scatter", name = paste(yaxis,"~", xaxis)) %>%
       add_lines(data = temp, x=formula(paste("~",xaxis)), y = ~Fitted, name = paste("linear model; 
                                                                                     R^2 = ", r2)) %>%
       layout(title = paste0(yaxis, " vs. ", xaxis)) #y = f(x), so y vs. x
     
   })
   
   
   #home 2 output
   output$HomePlot2 <- renderPlotly({
     
     DayOfWeek <- input$DayOfWeek_home
     Month_Chr <- input$Month_home
     
     #filter
     temp <- homeEnergyUsage
     if(DayOfWeek != "No Filter"){
       temp <- temp[temp$DayOfWeek == DayOfWeek,]
     }
     if(Month_Chr != "No Filter"){
       temp <- temp[temp$Month == Month_Chr,]
     }
     
     #grouping
     temp <- temp %>%
       dplyr::select(HourMin, Eyedro.Electricity.Monitor.Port.A...Energy..Wh., Eyedro.Electricity.Monitor.Port.B...Energy..Wh., Total) %>%
       group_by(HourMin) %>%
       summarise_all(mean)
     names(temp)<-c("HourMin", "Wh_PortA", "Wh_PortB", "Wh_Total")
     
     #complete cases
     temp <- temp[complete.cases(temp),]
  
     
     #visual by port A vs. Port B
     plot_ly(data = temp, x = ~HourMin, y =~Wh_Total, 
             mode = "lines", type = "scatter", name="Total") %>%
       add_trace(data = temp, x = ~HourMin, y =~Wh_PortA ,
                 mode = "lines", type = "scatter", line = list(dash="dash"), name="PortA") %>%
       add_trace(data = temp, x = ~HourMin, y =~Wh_PortB ,
                 mode = "lines", type = "scatter", line = list(dash="dot"), name="PortB") %>%
       layout(title = "Mean Wh vs. Hour:Minute by Source", xaxis=list(title="Hour and Minute"),
              yaxis = list(title = "Mean Total Wh"))
     
     
   })
   
   #home 3 output
   output$HomePlot3 <- renderPlotly({
     
     DayOfWeek <- input$DayOfWeek_home
     Month_Chr <- input$Month_home
     
     #filter
     temp <- homeEnergyUsage
     if(DayOfWeek != "No Filter"){
       temp <- temp[temp$DayOfWeek == DayOfWeek,]
     }
     if(Month_Chr != "No Filter"){
       temp <- temp[temp$Month == Month_Chr,]
     }
     
     #grouping
     temp <- temp %>%
       dplyr::select(HourMin, DayOfWeek, Eyedro.Electricity.Monitor.Port.A...Energy..Wh., Eyedro.Electricity.Monitor.Port.B...Energy..Wh., Total) %>%
       group_by(HourMin, DayOfWeek) %>%
       summarise_all(median) %>%
       ungroup()
     names(temp)<-c("HourMin", "DayOfWeek", "Wh_PortA", "Wh_PortB", "Wh_Total")
     
     
    #visual by day
     plot_ly(data = temp, x = ~HourMin, y =~Wh_Total , color = ~DayOfWeek, colors = "Set2",
             mode = "lines", type = "scatter", name="Total") %>%
       layout(title = "Median Wh vs. Hour:Minute by Day of Week", xaxis=list(title="Hour and Minute"),
              yaxis = list(title = "Median Total Wh"))
     
     
   })
   
   
}

# Run the application 
shinyApp(ui = ui, server = server)

