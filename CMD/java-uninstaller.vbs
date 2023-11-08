On Error Resume Next
 Set WshShell = WScript.CreateObject("WScript.Shell")
 Dim fso, MyFile
 Set fso = CreateObject("Scripting.FileSystemObject")
 Const ForReading = 1, ForWriting = 2
 TempDir = "c:\temp"
 TempISS = "c:\temp\iss"
 LogFile = "uninst.log"
 UnString = " -s -a /s /f1"
 Set MyFile = fso.OpenTextFile(TempDir & "\uninstall.tmp", ForReading)
 Set ts = fso.CreateTextFile(LogFile)
 Set f = fso.CreateFolder(TempISS)
 
 Do While MyFile.AtEndOfStream <> True
 ReadLineTextFile = MyFile.ReadLine
 Uninstall = ReadLineTextFile
 CLSID = Mid(Uninstall, 73, 38)
 search5 = Instr(Uninstall, "JRE 1")
 search6 = Instr(Uninstall, "]")
 If search5 > 0 AND search6 > 0 Then
 JRE1 = Replace(Mid(Uninstall, search5, search6),"]","") 
 End If
 
 'DisplayName
 DisplayName=WshShell.RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & CLSID & "\DisplayName")
 'Publisher
 Publisher=WshShell.RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & CLSID & "\Publisher")
 
 'UninstallString
 UninstallString=WshShell.RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & CLSID & "\UninstallString")
 
 'JREUninstallString
 JREUninstallString=WshShell.RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" & JRE1 & "\UninstallString")
 
 If JREUninstallString <> "" Then
 JREUN = Replace(JREUninstallString," -f"," -s -a /s /f")
 ts.writeline JREUN
 Return = WshShell.Run(JREUN , 1, TRUE)
 End If
 
 
 'Search for presence of Java and Sun in DisplayName and Publisher
 search1 = Instr(1, DisplayName, "Java", 1)
 search2 = Instr(1, Publisher, "Sun", 1)
 search3 = Instr(1, DisplayName, "J2SE", 1)
 search4 = Instr(1, UninstallString, "setup.exe", 1)
 'Execute removal if there is a match
 Uninstaller="MsiExec.exe /X"&CLSID+" /QN"
 if search1 > 0 or search3 > 0 and search2 > 0 Then 
 ts.writeline Uninstaller
 
 Set iss = fso.CreateTextFile(TempISS & "\" & CLSID & ".iss")
 
 'Create Response file for any Java Version
 iss.writeline "[InstallShield Silent]"
 iss.writeline "Version=v6.00.000"
 iss.writeline "File=Response File"
 iss.writeline "[File Transfer]"
 iss.writeline "OverwrittenReadOnly=NoToAll"
 iss.writeline "[" & CLSID & "-DlgOrder]"
 iss.writeline "Dlg0=" & CLSID & "-SprintfBox-0"
 iss.writeline "Count=2"
 iss.writeline "Dlg1=" & CLSID & "-File Transfer"
 iss.writeline "[" & CLSID & "-SprintfBox-0]"
 iss.writeline "Result=1"
 iss.writeline "[Application]"
 iss.writeline "Name=Java 2 Runtime Environment, SE v1.4.0_01"
 iss.writeline "Version=1.4.0_01"
 iss.writeline "Company=JavaSoft"
 iss.writeline "Lang=0009"
 iss.writeline "[" & CLSID & "-File Transfer]"
 iss.writeline "SharedFile=YesToAll"
 
 If search4 > 0 Then
 ss = Left(UninstallString,search4 + 9)
 setupuninstal = ss & UnString & Chr(34) & TempISS & "\" & CLSID & ".iss" & Chr(34)
 ts.writeline setupuninstal
 Return = WshShell.Run(setupuninstal , 1, TRUE)
 End If
 Return = WshShell.Run(Uninstaller , 1, TRUE)
 End If
 Loop
 MyFile.Close
 fso.DeleteFolder(TempDir)