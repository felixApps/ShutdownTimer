Set WshShell = CreateObject("WScript.Shell") 
WshShell.Run chr(34) & "C:/ProgramData/ShutdownTimer/cmd.cmd" & Chr(34), 0
Set WshShell = Nothing