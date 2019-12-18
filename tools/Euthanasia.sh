
# FUNCS

MESSAGE_START(){
if [[ $loc = "ru" ]]; then
if result=$( osascript -e 'Tell application "System Events" to display dialog "       Сервис усыпления компа запущен " '"${icon_string}"' buttons "OK" giving up after 3'  2>/dev/null ); then cancel="OK"; else cancel="NOT OK"; fi
else
if result=$( osascript -e 'Tell application "System Events" to display dialog "       Eutanasia service started " '"${icon_string}"' buttons "OK" giving up after 3'  2>/dev/null ); then cancel="OK"; else cancel="NOT OK"; fi
fi
}

KILL_HAZARDS(){
if [[ "${gpu}" = "AMD" ]] && [[ "$macos" = "1015" ]]; then 
    if [[ ! "${danger_applet}" = "no" ]]; then
        AMDAccel=$( ioreg -c AMDRadeonX4000_AMDAccelDevice  -r | grep IOUserClientCreator )
        TV_pid=$( echo "${AMDAccel}" | grep TV -m 1 | cut -f2 -d= | cut -c 7- | cut -f1 -d ',' )
        Safari_pid=$( echo "${AMDAccel}" | grep Safari -m 1 | cut -f2 -d= | cut -c 7- | cut -f1 -d ',' )
        if [[ ! ${TV_pid} = "" ]]; then echo "${mypassword}" | sudo -S osascript -e 'quit app "TV.app"'; fi
        if [[ "${danger_applet}" = "safari" ]]; then
            if [[ ! ${Safari_pid} = "" ]]; then echo "${mypassword}" | sudo -S osascript -e 'quit app "Safari.app"'; fi
        fi
    fi
fi
}

GET_POWER_SETTINGS(){
if [[ "$( pmset -g batt | grep -o "AC Power" )" = "" ]]; then power="Battery"; else power="AC"; fi
check=$( plutil -p /Library/Preferences/com.apple.PowerManagement.plist | tr -d '>"}{' | grep ${power} -A7)
    display=$( echo "$check" | grep -m 1 "Display Sleep Timer" | cut -f2 -d '=' | xargs )
    system=$( echo "$check" | grep -m 1 "System Sleep Timer" | cut -f2 -d '=' | xargs )
    if [[ ! ${system} = 0 ]]; then 
    if [[ ${display} -gt ${system} ]]; then display=${system}; fi
    let "timer=(system-display)*60"
    fi
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
echo "${mypassword}" | sudo -S pmset sleepnow
}

CHECK_DISPLAY(){ 
echo "${mypassword}" | sudo -S ioreg -n IODisplayWrangler | grep -i IOPower | tr -d '"{|}' | rev | cut -f1 -d',' | rev | cut -f2 -d= 
}

SLEEP_TIMER(){
if [[ ! ${timer} = ${display} ]]; then 
    for ((i=0;i<(( ($system-$display)*4));i++))
    do
    sleep 15
    if [[ $( CHECK_DISPLAY ) = 4 ]]; then break; fi
    done
fi
}


# INIT
cd "$(dirname "$0")"; ROOT="$(dirname "$0")"
GET_APP_ICON
loc=$( cat .SleeperLang.txt)
if [[ ! $loc = "ru" ]]; then loc="en"; fi 
GET_USER_PASSWORD

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

MESSAGE_START

if [[ "${cancel}" = "NOT OK" ]]; then sleep 1; MESSAGE_START; fi

osascript -e 'tell application "Terminal" to activate'

# MAIN
while true
    do  
        sleep 14
        GET_POWER_SETTINGS
         if [[ ! ${system} = 0 ]]; then        
            if [[ ! $( CHECK_DISPLAY ) = 4 ]]; then KILL_HAZARDS; SLEEP_TIMER; if [[ ! $( CHECK_DISPLAY ) = 4 ]]; then GO_TO_BED; fi; fi
        fi
    done

