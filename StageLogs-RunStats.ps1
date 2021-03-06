PARAM($MAName,$logFile,$logStagingFolder="E:\FIM\Logs\ForUploadToSQL")

#Copyright (c) 2014, Unify Solutions Pty Ltd
#All rights reserved.
#
#Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
#* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
#* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
#
#THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
#IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; 
#OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
## 
## StageLogs-RunStats.ps1
## Written by Carol Wapshere, UNIFY Solutions
##
## Use with Event Broker to run after every MA Import and Export step to log stats about the run.
## Stages CSV files to a folder from where they could be uploaded to a reporting database or log archive system.
##
## Usage: Log the run, errors and all changes
##   .\StageLogs-RunStats.ps1 -MAName "FIM MA" -logFile "DeltaIMport.xml"
##
## Usage: Log the run and errors
##   .\StageLogs-RunStats.ps1 -MAName "IdB ViewDS"
##
##

$XSLTFile = "E:\FIM\Scripts\Sync\ArchiveLogs\logToCSV.xsl"

### Run profile type and status ###

$MA = get-wmiobject -Namespace "root\MicrosoftIdentityIntegrationServer" -class "MIIS_ManagementAgent" | where {$_.name -eq $MAName}
$RPName = $MA.RunProfile().ReturnValue
$StartTime = get-date (get-date ($MA.RunStartTime().ReturnValue)).ToLocalTime()  -format "MM/dd/yyyy HH:mm:ss"
$LogTime = get-date (get-date ($MA.RunStartTime().ReturnValue)).ToLocalTime()  -format "yyyyMMddHHmmss"
$EndTime = get-date (get-date ($MA.RunEndTime().ReturnValue)).ToLocalTime() -format "MM/dd/yyyy HH:mm:ss"
$RunStatus = $MA.RunStatus().ReturnValue
$Updates = $MA.NumExportUpdate().ReturnValue
$Adds = $MA.NumExportAdd().ReturnValue
$Deletes = $MA.NumExportDelete().ReturnValue

$RunsStagingFile = $logStagingFolder + "\sync_runs." + $MAName + "." + $LogTime + ".csv"
$TmpFile = $RunsStagingFile + ".tmp"
"StartTime;EndTime;MAName;RPName;RunStatus;Updates;Adds;Deletes" | out-file $TmpFile -encoding "Default"
"$StartTime;$EndTime;$MAName;$RPName;$RunStatus;$Updates;$Adds;$Deletes" | add-content $TmpFile
Move-Item -Path $TmpFile -Destination $RunsStagingFile


### Errors ###

$ErrorsStagingFile = $logStagingFolder + "\sync_runs_errors." + $MAName + "." + $LogTime + ".csv"
$TmpFile = $ErrorsStagingFile + ".tmp"

if ($RunStatus -ne "success") 
{
    [xml]$rd = $MA.RunDetails().ReturnValue

    if ($rd.InnerXml.contains("export-error"))
    {
        "StartTime;MAName;DN;Error;FirstTime" | out-file $TmpFile -encoding "Default"
        foreach ($node in $rd.SelectNodes("//export-error"))
        {
            "$StartTime;$MAName;" + $node.dn.Replace("'","''") + ";" + $node."error-type" + ";" + $node."first-occurred" | add-content $TmpFile
        } 
    }
      
    if ($rd.InnerXml.contains("import-error"))
    {
        "StartTime;MAName;DN;Error;FirstTime" | out-file $TmpFile -encoding "Default"
        foreach ($node in $rd.SelectNodes("//import-error"))
        {
            "$StartTime;$MAName;" + $node.dn.Replace("'","''") + ";" + $node."error-type" + ";" + $node."first-occurred" | add-content $TmpFile
        } 
    }  
}
if (Test-Path $TmpFile) {Move-Item -Path $TmpFile -Destination $ErrorsStagingFile}



### Archive log file for later import into the DB ###

$MaData = "C:\Program Files\Microsoft Forefront Identity Manager\2010\Synchronization Service\MaData"

if ($logFile) 
{
    $LogType = $logFile.split(".")[0]
    $ChangesStagingFile = $logStagingFolder + "\sync_runs_changes." + $MAName + "." + $LogTime + "." + $LogType + ".csv"
    $TmpFile = $ChangesStagingFile + ".tmp"
    
    ## Convert XML to CSV using XSLT stylesheet
    [xml]$xmlDoc = Get-Content ($MaData + "\" + $MAName + "\" + $logFile)
    
    if  ($xmlDoc.mmsml."directory-entries".HasChildNodes)
    {
        $xslt = New-Object System.Xml.Xsl.XslCompiledTransform
        $xslt.Load($XSLTFile)
        $memStream = New-Object System.IO.MemoryStream
        $argList = New-Object System.Xml.Xsl.XsltArgumentList
        $argList.AddParam("starttime","", $StartTime)
        $argList.AddParam("maname","", $MAName)
        $xslt.Transform($xmlDoc,$argList,$memStream)

        $memStream.Position = 0
        $reader = New-Object System.IO.StreamReader $memStream
        $reader.ReadToEnd() | out-file -FilePath FileSystem::$TmpFile -Encoding "Default"
    }
}
if (Test-Path $TmpFile) {Move-Item -Path $TmpFile -Destination $ChangesStagingFile}
