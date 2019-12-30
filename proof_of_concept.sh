#!/bin/bash

# Proof of concept that uses WSL on Windows 10, and depends on python3 within WSL, and calls out to Powershell for a few Windows items.

ls -1 appmanifest_*acf | tr '_' '.' | cut -d '.' -f 2 | sort -n | \
    while read appid
    do
        # References:
        # - https://www.reddit.com/r/Steam/comments/27xpts/script_windows_automated_verification_of_steam/
        explorer.exe "steam://validate/$appid"
        sleep 1
        while [ true ]
        do
            # References:
            # - https://superuser.com/questions/378790/how-to-get-window-title-in-windows-from-shell
            progress=$(powershell.exe 'tasklist /v /FI "IMAGENAME eq Steam.exe" /FO:CSV' | grep "Validating" | python3 -c 'import csv, sys;
for r in list(csv.reader(sys.stdin)):
    print(r[-1])' | cut -d ' ' -f5)
            echo "`date +%FT%T` $appid $progress"
            if [ "$progress" == "100%" ] || [ "$progress" == "" ]
            then
                # References:
                # - https://devblogs.microsoft.com/scripting/provide-input-to-applications-with-powershell/
                # - https://stackoverflow.com/questions/17849522/how-to-perform-keystroke-inside-powershell
                powershell.exe '$wshell = New-Object -ComObject wscript.shell;  $wshell.AppActivate("Validating Steam files - 100% complete"); Sleep 1; $wshell.SendKeys("%{F4}");'
                break
            else
                sleep 5
            fi
        done
    done
