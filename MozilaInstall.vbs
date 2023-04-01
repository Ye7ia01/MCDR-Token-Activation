Option Explicit

On error resume next

Const DEBUGGING              = true
const SCRIPT_VERSION        = 1.0
Const EVENTLOG_WARNING      = 2
Const CERTUTIL_EXCUTABLE    = "certutil.exe"
Const ForReading = 1


Dim strCertDirPath, strCertutil, files, slashPosition, dotPosition, strCmd, message
Dim file, filename, filePath, fileExtension

Dim WshShell            : Set WshShell            = WScript.CreateObject("WScript.Shell")
Dim objFilesystem      : Set objFilesystem    = CreateObject("Scripting.FileSystemObject") 
Dim certificates        : Set certificates      = CreateObject("Scripting.Dictionary")
Dim objCertDir
Dim UserFirefoxDBDir
Dim UserFirefoxDir
Dim vAPPDATA
Dim objINIFile
Dim strNextLine,Tmppath,intLineFinder, NickName

vAPPDATA = WshShell.ExpandEnvironmentStrings("%APPDATA%") 
strCertDirPath    = WshShell.CurrentDirectory
strCertutil      = strCertDirPath & "\" & CERTUTIL_EXCUTABLE
UserFirefoxDir = vAPPDATA & "\Mozilla\Firefox"
NickName = "Websense Proxy Cert"


Set objINIFile = objFilesystem.OpenTextFile( UserFireFoxDir & "\profiles.ini", ForReading)

Do Until objINIFile.AtEndOfStream
    strNextLine = objINIFile.Readline

    intLineFinder = InStr(strNextLine, "Path=")
    If intLineFinder <> 0 Then
        Tmppath = Split(strNextLine,"=")
        UserFirefoxDBDir = UserFirefoxDir & "\" & replace(Tmppath(1),"/","\") & "\cert8.db"

    End If  
Loop
objINIFile.Close

output UserFirefoxDBDir

If objFilesystem.FolderExists(strCertDirPath) And objFilesystem.FileExists(strCertutil) Then
    Set objCertDir = objFilesystem.GetFolder(strCertDirPath)
    Set files = objCertDir.Files

    For each file in files
        slashPosition = InStrRev(file, "\")
        dotPosition  = InStrRev(file, ".")
        fileExtension = Mid(file, dotPosition + 1)
        filename      = Mid(file, slashPosition + 1, dotPosition - slashPosition - 1)

        If LCase(fileExtension) = "cer" Then        
            strCmd = chr(34) & strCertutil & chr(34) &" -A -a -n " & chr(34) & NickName & chr(34) & " -i " & chr(34) & file & chr(34) & " -t " & chr(34) & "TCu,TCu,TCu" & chr(34) & " -d " & chr(34) & UserFirefoxDBDir & chr(34)
            output(strCmd)
            WshShell.Exec(strCmd)
        End If        
    Next        
    WshShell.LogEvent EVENTLOG_WARNING, "Script: " & WScript.ScriptFullName & " - version:" & SCRIPT_VERSION & vbCrLf & vbCrLf & message
End If

function output(message)
    If DEBUGGING Then
        Wscript.echo message
    End if
End function

Set WshShell  = Nothing
Set objFilesystem = Nothing