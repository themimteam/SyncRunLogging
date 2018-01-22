# SyncRunLogging
Sync Run Logging

# Author
Carol Wapshere

The StageLogs.ps1 script has been design to produce log files in CSV format for easy uploading to SQL.

The script must be run directly after the run profile operation it is logging has completed. Using FIM Event Broker will ensure that the StageLogs.ps1 script is called at the right time, and that the MA is not run again during the log archiving process (which would mess up the WMI metrics).

The script produces the following CSV files for each run:

* Basic run stats - when, how long, how many updates,
* Errors - all errors produced in the run, and
* Changes - all attribute changes in the import/export file. This part is optional and the file is produced only if a drop file is passed as a script argument.

To use:

1. If uploading to a FIMReporting database, use the "Create Table*" scripts to create the tables,
1. Where you want full import/export logging, ensure all Import and Export run profiles are configured to drop a log file,
1. Modify the StageLogs.ps1 file to specify the correct location of the logToCSV.xsl file and the archive folder,
1. Configure Event Broker or your run scripts to run the following after every import/export:
   To log the run, errors and all changes

     .\StageLogs-RunStats.ps1 -MAName "MAName" -logFile "import.xml|export.xml"

   To log the run and errors only

     .\StageLogs-RunStats.ps1 -MAName "MAName"

Notes:

* The parts of the script that query WMI will retrieve stats for the last run. It is very important that no run profiles are run against this MA while the script is running.
* The changes part of the script can only log what it finds in the drop file. If your MA only does full imports you will get the full connector space in the CSV file.
* There is no logging of Sync changes - only import and export.
