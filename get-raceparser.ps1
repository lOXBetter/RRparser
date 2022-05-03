$path = pwd
$gotopath = $path.path + "\samplefiles\"
#$path = "C:\RFRC\rr\Results\beginning of time\" 
cd $gotopath
$files = (ls).Name
foreach ($file in $files) {
    $info = Get-Content $file | ConvertFrom-Json
    $races = $info.sessions.type
    $players = $info.sessions.players
    $Series = "allSeries","xlsx" -join "."

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
        $QBestlap = [timespan]::FromMilliSeconds($qracer.BestLapTime) 
        $QBLmincalc = ("{0:mm\:ss\:fff}" -f $QBestlap)
        $lapstimetotal = [timespan]::FromMilliSeconds($qracer.totaltime)
        $lapstimetotalcalc = ("{0:mm\:ss\:fff}" -f $lapstimetotal)

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
                        BestLap = $QBLmincalc
                        Incidents = $QIncidentstotal
                        Totaltime = $lapstimetotalcalc
                        #LapAvg = $QLapavg
                        #Totallaptime = $lapstimetotal
                    
                        }
                    
                    $report += $details
                    }

    #$report = $Null

    $test = New-ConditionalFormattingIconSet -Range "J:J" -Conditionalformat ThreeIconSet -icontype symbols
    $report | Export-Excel -Path .\$Series -Append -AutoSize -Conditionalformat $test -TableName processes -FreezeTopRow
    #$report 

    #$report # = $Null

    $report1 = @()
    #$x=0
    foreach ($r1racer in $Race1Race) {

        $rLaps = $r1racer.RaceSessionLaps.time.Count
        
        $R1Bestlap = [timespan]::FromMilliSeconds($r1racer.BestLapTime) 
        $R1BLmincalc = ("{0:mm\:ss\:fff}" -f $R1Bestlap)
        $lapstimetotal = [timespan]::FromMilliSeconds($r1racer.totaltime)
        $lapstimetotalcalc = ("{0:mm\:ss\:fff}" -f $lapstimetotal)
        
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
                BestLap = $R1BLmincalc
                Totaltime = $lapstimetotalcalc
                Incidents = $rIncidents
                Laps = $rLaps
            
                #LapAvg = $rtotaltime % $SessionLaps.Count
        } 
        $report1 += $details  
    }              
             
    $report1 | Export-Excel -Path .\$Series -Append 
    ##$test = 1, 2, 3, 4
    #$test | Measure-Object -Average

    $report2 = @()
    #$x=0
    foreach ($r2racer in $Race2Race) {
        $Incidents = $r2racer.RaceSessionLaps.incidents.Points
        $rLaps = $r2racer.RaceSessionLaps.time.Count
        $SessionSectors = $r2racer.RaceSessionLaps.sectortimes
        $R2Bestlap = [timespan]::FromMilliSeconds($r2racer.BestLapTime)
        $R2BLmincalc = ("{0:mm\:ss\:fff}" -f $R2Bestlap)
        $lapstimetotal = [timespan]::FromMilliSeconds($R2racer.totaltime)
        $lapstimetotalcalc = ("{0:mm\:ss\:fff}" -f $lapstimetotal)
        #$Lapavg = ($SessionLaps | Measure-Object -Average).Average
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
                BestLap = $R2BLmincalc
                Totaltime = $lapstimetotalcalc
                Incidents = $rIncidents
                Laps = $rLaps
                #LapAvg = $rtotaltime % $SessionLaps.Count
        } 
        $report2 += $details  
    }              
             
    #$report2

    $report2 | Export-Excel -Path .\$Series -Append
}
