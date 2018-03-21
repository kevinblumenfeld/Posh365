
function Add-ToCaseReport {
    Param(
        [string]$casename,
        
        [String]$casestatus,
        
        [datetime]$casecreatedtime,
        
        [string]$casemembers,
        
        [datetime]$caseClosedDateTime,
        
        [string]$caseclosedby,
        
        [string]$holdname,
        
        [String]$Holdenabled,
        
        [string]$holdcreatedby,
        
        [string]$holdlastmodifiedby,
        
        [string]$ExchangeLocation,
        
        [string]$sharePointlocation,
        
        [string]$ContentMatchQuery,
        
        [datetime]$holdcreatedtime,
        
        [datetime]$holdchangedtime,

        [string]$outputpath
    )
    $addRow = New-Object PSObject 
    Add-Member -InputObject $addRow -MemberType NoteProperty -Name "Case name" -Value $casename
    Add-Member -InputObject $addRow -MemberType NoteProperty -Name "Case status" -Value $casestatus
    Add-Member -InputObject $addRow -MemberType NoteProperty -Name "Case members" -Value $casemembers
    Add-Member -InputObject $addRow -MemberType NoteProperty -Name "Case created time" -Value $casecreatedtime
    Add-Member -InputObject $addRow -MemberType NoteProperty -Name "Case closed time" -Value $caseClosedDateTime
    Add-Member -InputObject $addRow -MemberType NoteProperty -Name "Case closed by" -Value $caseclosedby
    Add-Member -InputObject $addRow -MemberType NoteProperty -Name "Hold name" -Value $holdname
    Add-Member -InputObject $addRow -MemberType NoteProperty -Name "Hold enabled" -Value $Holdenabled
    Add-Member -InputObject $addRow -MemberType NoteProperty -Name "Hold created by" -Value $holdcreatedby
    Add-Member -InputObject $addRow -MemberType NoteProperty -Name "Hold last changed by" -Value $holdlastmodifiedby
    Add-Member -InputObject $addRow -MemberType NoteProperty -Name "Exchange locations" -Value  $ExchangeLocation
    Add-Member -InputObject $addRow -MemberType NoteProperty -Name "SharePoint locations" -Value $sharePointlocation
    Add-Member -InputObject $addRow -MemberType NoteProperty -Name "Hold query" -Value $ContentMatchQuery
    Add-Member -InputObject $addRow -MemberType NoteProperty -Name "Hold created time (UTC)" -Value $holdcreatedtime
    Add-Member -InputObject $addRow -MemberType NoteProperty -Name "Hold changed time (UTC)" -Value $holdchangedtime
    
    $allholdreport = $addRow | Select-Object "Case name", "Case status", "Hold name", "Hold enabled", "Case members", "Case created time", "Case closed time", "Case closed by", "Exchange locations", "SharePoint locations", "Hold query", "Hold created by", "Hold created time (UTC)", "Hold last changed by", "Hold changed time (UTC)"
    
    $allholdreport | export-csv -path $outputPath -NoTypeInformation -append -Encoding ascii 
}
