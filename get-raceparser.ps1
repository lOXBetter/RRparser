﻿
$path = "C:\RFRC\rr\Results\beginning of time\" 
cd $path
$files = (ls).Name
foreach ($file in $files) {
    $info = Get-Content $file | ConvertFrom-Json
    $races = $info.sessions.type
    $players = $info.sessions.players
    $Series = "allSeries","csv" -join "."

    # basic details
    $Server = $info.Server
    $Track = $info.Track + " " + $info.TrackLayout

    $DayEvents = $info.sessions.type
    $AllPlayers = $info.Sessions.players

    $Eventdetails = [pscustomobject]@{
        Server = $Server
        Track = $Track
        Qualify = $info.sessions | Where-Object {$_.Type -contains "Qualify"}
        Race1 = $info.sessions | Where-Object {$_.TYpe -contains "Race"}
        Race2 = $info.sessions | Where-Object {$_.Type -contains "Race2"}

    }

    $QualyRace = $Eventdetails.Qualify.Players
    $QualyIncPts = ($QualyRace.racesessionlaps.incidents.Points | Measure-Object -Sum).sum
    $Race1Race = $Eventdetails.Race1.Players
    $Race1IncPts = ($Eventdetails.Race1.players.racesessionlaps.incidents.points | Measure-Object -Sum).sum
    $Race2Race = $Eventdetails.Race2.Players

    $Qualydetails = [pscustomobject]@{
        Server = $Eventdetails.Server
        Track = $Eventdetails.Track
        Driver = $QualyRace.FullName# + " " + $QualyRace.userid
        TotalIncidents = $QualyIncPts
        Car = $QualyRace.car
   
    }

    $QualyLaps =  $QualyRace.RaceSessionLaps
    $report = @()
    $blame = @()
    foreach ($qracer in $Qualyrace) {
        $QIncidentstotal = ($qracer.RaceSessionLaps.incidents.Points | Measure-Object -Sum).sum
        $SessionLaps = $qracer.RaceSessionLaps.time
        $qracerinc = $qracer.RaceSessionLaps.Incidents
        $QBestlap = $qracer.BestLapTime
        $lapstimetotal = $qracer.totaltime

        foreach ($entry in $qracerinc) {
            $incUserId = $entry.otherUserID
            if ($incuserid -in $Qualyrace.Userid) {
                #$blame =+ $qracer.FullName
        }
        }
        #$QLapavg = ($lapstimetotal % $Sessionlaps.Count)
        #foreach ($lap in $SessionLaps) {
                    $details = [pscustomobject]@{
                        Server = $Qualydetails.Server
                        Event = $Eventdetails.Qualify.Type
                        Track = $Qualydetails.track
                        Racer = $qracer.fullname
                        FinPosition = $qracer.position
                        StartPosition = $qracer.Startposition
                        Laps = $SessionLaps.count
                        BestLap = $QBestlap
                        Incidents = $QIncidentstotal
                        Totaltime = $lapstimetotal
                        #LapAvg = $QLapavg
                        #Totallaptime = $lapstimetotal
                    
                        }
                    
                    $report += $details
                    }

    #$report = $Null


    $report | Export-Csv -path .\$series -Append
    #$report 

    #$report # = $Null

    $report1 = @()
    #$x=0
    foreach ($r1racer in $Race1Race) {

        $rLaps = $r1racer.RaceSessionLaps.time.Count
        $Bestlap = $r1racer.BestLapTime
        $rtotaltime = $r1racer.TotalTime
        $rIncidents = ($r1racer.RaceSessionLaps.incidents.points | Measure-Object -Sum).sum
    
        
        if ($r1racer.RaceSessionLaps.incidents.OtherUserId -eq 0 -or $r1racer.RaceSessionLaps.incidents.OtherUserId -eq -1) {
            Write-Verbose (" no foul")
        } else {
            $incUserId = $r1racer.RaceSessionLaps.Incidents.OtherUserId
            $incuser = $Race1Race | Where-Object {$_.UserId -contains $incuserid}
            $blame = $incUser.fullname
    
    }       
        
            $details = [pscustomobject]@{
                Server = $Server
                Event = $Eventdetails.Race1.Type
                Track = $Track
                Racer = $r1racer.fullname
                Status = $r1racer.FinishStatus
                FinPosition = $r1racer.position
                StartPosition = $r1racer.Startposition
                #AvgTime = $lap % 60000 % $SessionLaps
                BestLap = $Bestlap
                Totaltime = $rtotaltime
                Incidents = $rIncidents
                Laps = $rLaps
            
                #LapAvg = $rtotaltime % $SessionLaps.Count
        } 
        $report1 += $details  
    }              
             
    $report1 | Export-Csv -path .\$Series -Append
    ##$test = 1, 2, 3, 4
    #$test | Measure-Object -Average

    $report2 = @()
    #$x=0
    foreach ($r2racer in $Race2Race) {
        $Incidents = $r2racer.RaceSessionLaps.incidents.Points
        $rLaps = $r2racer.RaceSessionLaps.time.Count
        $SessionSectors = $r2racer.RaceSessionLaps.sectortimes
        $Bestlap = $r2racer.BestLapTime
        #$Lapavg = ($SessionLaps | Measure-Object -Average).Average
        $rtotaltime = $r2racer.TotalTime
        $rIncidents = ($r2racer.RaceSessionLaps.incidents.points | Measure-Object -Sum).sum
        #$SessionSectors
            $details = [pscustomobject]@{
                Server = $Server
                Event = $Eventdetails.Race2.Type
                Track = $Track
                Racer = $r2racer.fullname
                Status = $r2racer.FinishStatus
                FinPosition = $r2racer.position
                StartPosition = $r2racer.Startposition
                #AvgTime = $lap % 60000 % $SessionLaps
                BestLap = $Bestlap
                Totaltime = $rtotaltime
                Incidents = $rIncidents
                Laps = $rLaps
                #LapAvg = $rtotaltime % $SessionLaps.Count
        } 
        $report2 += $details  
    }              
             
    #$report2

    $report2 | Export-Csv -Path .\$Series -Append
}
