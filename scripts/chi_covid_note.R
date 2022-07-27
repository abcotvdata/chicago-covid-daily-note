library(readr)
library(lubridate)
library(dplyr)
library(htmlwidgets)

ILcases <- read_csv("https://idph.illinois.gov/DPHPublicInformation/api/COVIDExport/GetIllinoisCases?format=csv", skip=1)
head(ILcases)
ILcases$testDate <- mdy_hms(ILcases$testDate)
ILcases <- ILcases %>% arrange(desc(ILcases$testDate))

todayCases <- prettyNum(ILcases$cases_change[1], big.mark=",")
ydayCases <- prettyNum(ILcases$cases_change[2], big.mark=",")
todayDeaths <- prettyNum(ILcases$deaths_change[1], big.mark=",")
ydayDeaths <- prettyNum(ILcases$deaths_change[2], big.mark=",")

ILhosp <- read_csv("https://idph.illinois.gov/DPHPublicInformation/api/COVIDExport/GetHospitalUtilizationResults?format=csv", skip=1)
ILhosp$ReportDate <-mdy_hms(ILhosp$ReportDate)
ILhosp <- ILhosp %>% arrange(desc(ILhosp$ReportDate))

todayHosp <- prettyNum(ILhosp$TotalInUseBedsCOVID[1], big.mark=",")
ydayHosp <- prettyNum(ILhosp$TotalInUseBedsCOVID[2], big.mark=",")
todayICU <- prettyNum(ILhosp$ICUInUseBedsCOVID[1], big.mark=",")
ydayICU <- prettyNum(ILhosp$ICUInUseBedsCOVID[2], big.mark=",")
todayVent <- prettyNum(ILhosp$VentilatorInUseCOVID[1], big.mark=",")
ydayVent <- prettyNum(ILhosp$VentilatorInUseCOVID[2], big.mark=",")

ChiCases <- read_csv("https://idph.illinois.gov/DPHPublicInformation/api/COVIDExport/GetCountyTestResultsTimeSeries?format=csv&CountyName=Chicago", skip=1)
ChiCases$ReportDate <- mdy_hms(ChiCases$ReportDate)
ChiCases <- ChiCases %>% arrange(desc(ChiCases$ReportDate))

ChiCaseT <- prettyNum(ChiCases$CasesChange[1], big.mark=",")
ChiCaseY <- prettyNum(ChiCases$CasesChange[2], big.mark=",")
ChiDeathT <- prettyNum(ChiCases$DeathsChange[1], big.mark=",")
ChiDeathY <- prettyNum(ChiCases$DeathsChange[2], big.mark=",")

ILVacc <- read_csv("https://idph.illinois.gov/DPHPublicInformation/api/COVIDExport/GetVaccineAdministration?format=csv&countyName=Illinois", skip=1)
ILVacc$Report_Date <- mdy_hms(ILVacc$Report_Date)
ILVacc <- ILVacc %>% arrange(desc(ILVacc$Report_Date))

TodayDoses <- prettyNum(ILVacc$AdministeredCountChange[1], big.mark=",")
ydayDoses <- prettyNum(ILVacc$AdministeredCountChange[2], big.mark=",")
TodayAvg <- prettyNum(ILVacc$AdministeredCountRollAvg[1], big.mark=",")
ydayAvg <- prettyNum(ILVacc$AdministeredCountRollAvg[2], big.mark=",")
todayFV <- prettyNum((ILVacc$PersonsFullyVaccinated[1] - ILVacc$PersonsFullyVaccinated[2]), big.mark=",")
ydayFV <- prettyNum((ILVacc$PersonsFullyVaccinated[2] - ILVacc$PersonsFullyVaccinated[3]), big.mark=",")
todayVperc <- round(ILVacc$PctFullyVaccinatedPopulation[1],4)
TotalVaxxed <- prettyNum(ILVacc$PersonsFullyVaccinated[1], big.mark=",")

if (TodayDoses > ydayDoses) {print("up")} else if (TodayDoses < ydayDoses){print("down")} else {print("unchanged")}

stringtest <- "Test,
next line
-point 1
-point2"

ILCaseCon <- paste(todayCases, "new confirmed and probable cases (compared to",ydayCases, "yesterday)",sep=" ")
ILDeathCon <- paste(todayDeaths, "new confirmed deaths (compared to", ydayDeaths,"yesterday)",sep=" " )
ILHospCon <- paste("As of last night, there are", todayHosp,"COVID patients in Illinois hospital beds (compared to",ydayHosp, "yesterday).", todayICU, "are in ICU beds (compared to",ydayICU, "yesterday).", todayVent, "are on ventilators (compared to",ydayVent, "yesterday).",sep=" ")

ChiCCon <- paste(ChiCaseT,"new confirmed and probable cases (compared to",ChiCaseY, "yesterday)",sep=" ")
ChiDCon <- paste(ChiDeathT, "new confirmed deaths (compared to", ChiDeathY,"yesterday)",sep=" " )

FVCon <- paste(todayFV,"more people in Illinois are fully vaccinated (compared to",ydayFV, "yesterday). 
               That brings the total to",TotalVaxxed,"- or about ",todayVperc*100,"% of the state's population.",sep=" " )
print(FVCon)

dosesCon <- paste(TodayDoses, "more doses have been administered (compared to", ydayDoses,"yesterday).",sep=" ")
print(dosesCon)
avgCon <- paste("The seven-day daily administration average is at",TodayAvg,"(compared to",ydayAvg,"yesterday).")
print(avgCon)

signoff <- "- Jonathan Fagg, Data Journalist, ABC7 Chicago"

as_of_date <- paste(as.character(as.POSIXct(ILcases$testDate[1]), format = "%b %d, %Y"))

covidnote <- paste(sep = "</br>",
                   "<b>Daily COVID Stats",
                   paste("As of ",as_of_date,"</b>"),
                   paste(" "),
                   paste("<b>Statewide, IDPH report: </b>"),
                   ILCaseCon,
                   ILDeathCon,
                   ILHospCon,
                   paste(" "),
                   paste("<b>For Chicago, IDPH report: </b>"),
                   ChiCCon,
                   ChiDCon,
                   paste(" "),
                   paste("<b>Daily Vaccination Stats: </b>"),
                   FVCon, 
                   dosesCon, 
                   avgCon, 
                   paste(" "),
                   signoff,
                   paste(" "),
                   paste("* Important note: this data is provisional, and may include revisions up and down. Remember that weekend and holiday figures can sometimes be inconsistent because of reporting irregularities on days government offices are not open. If you have questions, reach out to John Kelly at john.l.kelly@abc.com."),    
)

write_file(covidnote,"covidnote.html")