######## PROCESSES ########

# Return all processes 
Get-Process

# Return process by name 
Get-Process process_name

# Retrieve all properties for specific process
Get-Process process_name | Select-Object -Property *

# Return certain properties of process by name
Get-Process process_name | Select-Object -Property Path, Name, Id
Get-Process | Select-Object -Property Path, Name, Id | Where-Object -Property Name -eq process_name

# Return processes that are running from a temp directory, i.e. "temp" exists in the Path 
Get-Process | Select-Object -Property Path, Name, Id | Where-Object -Property Path -Like "*temp*"

## STOP THE PROCESS ##
Get-Process | Select-Object -Property Path, Name, Id | Where-Object -Property Id -eq process_id | Stop-Process



######## NETWORK ENUMERATION ########

# Return a list of network connections for the host
Get-NetTCPConnection

# Return a list of network connection for the host and all or specific properties
Get-NetTCPConnection | Select-Object -Property *
Get-NetTCPConnection | Select-Object -Property LocalAddress, LocalPort, State, OwningProcess



######## Registry Startup Keys ########

# Most common Autostart Extensibility Points (ASEPS)

	    HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run
	    HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\RunOnce
	    HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run
	    HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\RunOnce

Get-ItemProperty "HKLM:Software\Microsoft\Windows\CurrentVersion\Run"
Get-ItemProperty "HKLM:Software\Microsoft\Windows\CurrentVersion\RunOnce"
Get-ItemProperty "HKCU:Software\Microsoft\Windows\CurrentVersion\Run"
Get-ItemProperty "HKCU:Software\Microsoft\Windows\CurrentVersion\RunOnce"

# Remove the value from the Run key using Remove-ItemProperty
Remove-ItemProperty -Path "HKCU:Software\Microsoft\Windows\CurrentVersion\Run" -Name "Run_Key_Name"
# Confirm the ASEP value has been removed by running Get-ItemProperty again, should return an error because it does not exist
Get-ItemProperty "HKCU:Software\Microsoft\Windows\CurrentVersion\Run\Run_Key_Name"

# Remove the program
Remove-Item \Path\to\program\program.exe
# Confirm it has been removed by rerunning same command, should return an error because it does not exist
Remove-Item \Path\to\program\program.exe



######## Scheduled Tasks ########

# Return a list of scheduled tasks
Get-ScheduledTask

# Return a scheduled task by name
Get-ScheduledTask task_name

# Return a scheduled task by name and all of its properties
Get-ScheduledTask task_name | Select-Object -Property *

# Return additional content of the task using the task name and the Export-ScheduledTask cmdlet
Export-ScheduledTask -TaskName "task_name"



######## Differential Analysis ########

# This assumes that there is a baseline present for services, users, scheduled tasks, and listening TCP ports. If there is no baseline available, spin up a golden image of the system and grab the baseline from that

# Capture running services, users, scheduledtasks, and listening TCP ports and then save to files
Get-Service | Select-Object -ExpandProperty Name | Out-File services.txt
Get-LocalUser | Select-Object -ExpandProperty Name | Out-File localusers.txt
Get-ScheduledTask | Select-Object -ExpandProperty TaskName | Out-File scheduledtasks.txt
Get-NetTCPConnection -State Listen | Out-File tcpports.txt


# Assign the files to variables respectively to compare with baselines
$services_current = Get-Content services.txt
$services_baseline = Get-Content services_baseline.txt

# Compare the current running services with the services from the baseline file, repeat this step for localusers, scheduledtasks, and listening TCP ports
# The output will show the difference between the two files, i.e. service running currently that were not in the baseline
Compare-Object $services_baseline $services_current



######## Remove the IOCs ########

# Stop service
Stop-Service -Name service_name

# Remove service (Alternatively, you can run "sc.exe delete service_name" to delete the service)
(Get-WmiObject -Class Win32_Service -Filter "Name='service_name'").delete()

# Stop process
Get-Process process_name | Stop-Process

# Delete program
Remove-Item \Path\To\Program\program_name.exe

# Delete scheduled task
Unregister-ScheduledTask -TaskName "task_name"

# Remove user
Remove-LocalUser -Name user_name

