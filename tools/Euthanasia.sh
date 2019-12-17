
# FUNCS

KILL_HAZARDS(){
if [[ "${gpu}" = "AMD" ]] && [[ "$macos" = "1015" ]]; then 
    if [[ ! "${danger_applet}" = "no" ]]; then
        AMDAccel=$( ioreg -c AMDRadeonX4000_AMDAccelDevice  -r | grep IOUserClientCreator )
        TV_pid=$( echo "${AMDAccel}" | grep TV -m 1 | cut -f2 -d= | cut -c 7- | cut -f1 -d ',' )
        Safari_pid=$( echo "${AMDAccel}" | grep Safari -m 1 | cut -f2 -d= | cut -c 7- | cut -f1 -d ',' )
        #if [[ ! ${TV_pid} = "" ]]; then echo "${mypassword}" | sudo -S kill ${TV_pid}; fi
        #if [[ ! ${Safari_pid} = "" ]]; then echo "${mypassword}" | sudo -S kill ${Safari_pid}; fi
        if [[ ! ${TV_pid} = "" ]]; then echo "${mypassword}" | sudo -S osascript -e 'quit app "TV.app"'; fi
        if [[ "${danger_applet}" = "safari" ]]; then
            if [[ ! ${Safari_pid} = "" ]]; then echo "${mypassword}" | sudo -S osascript -e 'quit app "Safari.app"'; fi
        fi
    fi
fi
}

DBG(){
echo "" >>  /Users/andrej/Desktop/test.txt
date +%T >>  /Users/andrej/Desktop/test.txt
echo "LOG = "$1  >>  /Users/andrej/Desktop/test.txt
echo "GET_POWER_SETTING timeout_limit     = "${timeout_limit} >>  /Users/andrej/Desktop/test.txt
echo "GET_POWER_SETTING system            = "${system} >>  /Users/andrej/Desktop/test.txt
echo "" >>  /Users/andrej/Desktop/test.txt
echo "danger_applet = ""${danger_applet}"  >>  /Users/andrej/Desktop/test.txt
}

GET_POWER_SETTINGS(){
if [[ "$( pmset -g batt | grep -o "AC Power" )" = "" ]]; then power="Battery"; else power="AC"; fi
check=$( plutil -p /Library/Preferences/com.apple.PowerManagement.plist | tr -d '>"}{' | grep ${power} -A7)
    display=$( echo "$check" | grep -m 1 "Display Sleep Timer" | cut -f2 -d '=' | xargs )
    system=$( echo "$check" | grep -m 1 "System Sleep Timer" | cut -f2 -d '=' | xargs )
    if [[ ${display} -gt ${system} ]]; then display=${system}; fi
    let "system=(system-display)*60"
#DBG "первый"
}

GET_USER_PASSWORD(){
mypassword="0"
if (security find-generic-password -a ${USER} -s euthanasia -w) >/dev/null 2>&1; then
                mypassword=$(security find-generic-password -a ${USER} -s euthanasia -w)
fi
}

GET_APP_ICON(){
icon_string=""
if [[ -f .EuthIcon.icns ]]; then 
   icon_string=' with icon file "'"$(echo "$(diskutil info $(df / | tail -1 | cut -d' ' -f 1 ) |  grep "Volume Name:" | cut -d':'  -f 2 | xargs)")"''"$(echo "${ROOT}" | tr "/" ":" | xargs)"':.EuthIcon.icns"'
fi 
}

GO_TO_BED(){
#DBG "второй"
KILL_HAZARDS
echo "${mypassword}" | sudo -S pmset sleepnow
}


# INIT
cd "$(dirname "$0")"; ROOT="$(dirname "$0")"
GET_APP_ICON
loc=$( cat .SleeperLang.txt)
if [[ ! $loc = "ru" ]]; then loc="en"; fi 
GET_USER_PASSWORD

if [[ $loc = "ru" ]]; then
echo "${mypassword}" | sudo -S osascript -e 'Tell application "System Events" to display dialog "       Сервис усыпления компа запущен " '"${icon_string}"' buttons "OK" giving up after 3'  2>/dev/null
else
echo "${mypassword}" | sudo -S osascript -e 'Tell application "System Events" to display dialog "       Eutanasia service started " '"${icon_string}"' buttons "OK" giving up after 3'  2>/dev/null
fi

if [[ ! $( system_profiler SPDisplaysDataType | grep Vendor | grep AMD ) = "" ]]; then gpu="AMD"; else gpu="Other"; fi

macos=$( sw_vers -productVersion ); macos=$( echo ${macos//[^0-9]/} ); macos=${macos:0:4}

shikigva=$( sysctl -a | grep -o shikigva=[0-9]* | cut -f2 -d= )

case ${shikigva} in
16 )   danger_applet="no_safari" ;;
80 )   danger_applet="safari" ;;
144 )  danger_applet="no_safari" ;;
208 )  danger_applet="safari" ;;
*   )  danger_applet="no"
esac

DBG "второй"

# MAIN
while true
    do  
        sleep 14
        GET_POWER_SETTINGS
        
         if [[ ${system} = ${display} ]] && [[ ! $( echo "${mypassword}" | sudo -S ioreg -n IODisplayWrangler | grep -i IOPower | tr -d '"{|}' | rev | cut -f1 -d',' | rev | cut -f2 -d= ) = 4 ]]; then
                GO_TO_BED 
         else
            if [[ ! $( echo "${mypassword}" | sudo -S ioreg -n IODisplayWrangler | grep -i IOPower | tr -d '"{|}' | rev | cut -f1 -d',' | rev | cut -f2 -d= ) = 4 ]]; then KILL_HAZARDS; fi
            sleep ${system}
            if [[ ! $( echo "${mypassword}" | sudo -S ioreg -n IODisplayWrangler | grep -i IOPower | tr -d '"{|}' | rev | cut -f1 -d',' | rev | cut -f2 -d= ) = 4 ]]; then GO_TO_BED; fi 2>/dev/null
         fi
    done

