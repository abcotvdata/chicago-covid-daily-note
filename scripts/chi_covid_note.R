
#install.packages("readr")
#install.packages("lubridate")
#install.packages("dplyr")
library(readr)
library(lubridate)
library(dplyr)

ILcases <- read_csv("https://idph.illinois.gov/DPHPublicInformation/api/COVIDExport/GetIllinoisCases?format=csv", skip=1)
head(ILcases)
ILcases$testDate <- mdy_hms(ILcases$testDate)
ILcases <- ILcases %>% arrange(desc(ILcases$testDate))

todayCases <- ILcases$cases_change[1]
ydayCases <- ILcases$cases_change[2]
todayDeaths <- ILcases$deaths_change[1]
ydayDeaths <- ILcases$deaths_change[2]

ILhosp <- read_csv("https://idph.illinois.gov/DPHPublicInformation/api/COVIDExport/GetHospitalUtilizationResults?format=csv", skip=1)
ILhosp$ReportDate <-mdy_hms(ILhosp$ReportDate)
ILhosp <- ILhosp %>% arrange(desc(ILhosp$ReportDate))

todayHosp <- ILhosp$TotalInUseBedsCOVID[1]
ydayHosp <- ILhosp$TotalInUseBedsCOVID[2]
todayICU <- ILhosp$ICUInUseBedsCOVID[1]
ydayICU <- ILhosp$ICUInUseBedsCOVID[2]
todayVent <- ILhosp$VentilatorInUseCOVID[1]
ydayVent <- ILhosp$VentilatorInUseCOVID[2]

ChiCases <- read_csv("https://idph.illinois.gov/DPHPublicInformation/api/COVIDExport/GetCountyTestResultsTimeSeries?format=csv&CountyName=Chicago", skip=1)
ChiCases$ReportDate <-mdy_hms(ChiCases$ReportDate)
ChiCases <- ChiCases %>% arrange(desc(ChiCases$ReportDate))

ChiCaseT <- ChiCases$CasesChange[1]
ChiCaseY <- ChiCases$CasesChange[2]
ChiDeathT <- ChiCases$DeathsChange[1]
ChiDeathY <- ChiCases$DeathsChange[2]

ILVacc <- read_csv("https://idph.illinois.gov/DPHPublicInformation/api/COVIDExport/GetVaccineAdministration?format=csv&countyName=Illinois", skip=1)
ILVacc$Report_Date <- mdy_hms(ILVacc$Report_Date)
ILVacc <- ILVacc %>% arrange(desc(ILVacc$Report_Date))

TodayDoses <- ILVacc$AdministeredCountChange[1]
ydayDoses <- ILVacc$AdministeredCountChange[2]
TodayAvg <- ILVacc$AdministeredCountRollAvg[1]
ydayAvg <- ILVacc$AdministeredCountRollAvg[2]
todayFV <- ILVacc$PersonsFullyVaccinated[1] - ILVacc$PersonsFullyVaccinated[2]
ydayFV <- ILVacc$PersonsFullyVaccinated[2] - ILVacc$PersonsFullyVaccinated[3]
todayVperc <- round(ILVacc$PctFullyVaccinatedPopulation[1],4)

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

FVCon <- paste(todayFV,"more people in Illinois are fully vaccinated (compared to",ydayFV, "yesterday). That brings the total to",ILVacc$PersonsFullyVaccinated[1],"which is",todayVperc*100,"% of the state's population.",sep=" " )
print(FVCon)

dosesCon <- paste(TodayDoses, "more doses have been administered (compared to", ydayDoses,"yesterday).",sep=" ")
print(dosesCon)
avgCon <- paste("The seven-day daily administration average is at",TodayAvg,"(compared to",ydayAvg,"yesterday).")
print(avgCon)

signoff <- "Jonathan Fagg
Data Journalist
ABC7 Chicago"

autoNote <- paste("As of: ",ILcases$testDate[1],"Daily COVID Stats:","Statewide, IDPH report —",ILCaseCon,ILDeathCon,ILHospCon,
                  "For Chicago, IDPH report—",ChiCCon,ChiDCon,
                  "Daily Vaccination Stats:", FVCon, dosesCon, avgCon, signoff,
                  sep="     ")
print(autoNote)

write_file(autoNote,"note.txt")
