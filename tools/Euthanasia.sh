
# FUNCS

GET_POWER_SETTINGS(){
check=$( plutil -p /Library/Preferences/com.apple.PowerManagement.plist | tr -d '>"}{' )
display=$( echo "$check" | grep -m 1 "Display Sleep Timer" | cut -f2 -d '=' | xargs )
system=$( echo "$check" | grep -m 1 "System Sleep Timer" | cut -f2 -d '=' | xargs )
let "system=((system-display)*60)"
if [[ ! ${timeout_limit_old} = ${system} ]]; then timeout_limit_old=${system}; fi
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
timeout_limit=${system}
while true
    do
       sleep 29
                let "timeout_limit=timeout_limit-60"
                if [[ ${timeout_limit} -lt 28 ]]; then
                    timeout_limit=${system};
                    if [[ $( echo "${mypassword}" | sudo -S ioreg -n IODisplayWrangler | grep -i IOPower | tr -d '"{|}' | rev | cut -f1 -d',' | rev | cut -f2 -d= ) = 4 ]]; then break
                                 else 
                                    echo "${mypassword}" | sudo -S pmset sleepnow; break
                    fi  
               
                fi
       GET_POWER_SETTINGS
        sleep 29
    done

}

# INIT
cd "$(dirname "$0")"; ROOT="$(dirname "$0")"
GET_APP_ICON
#loc=`defaults read -g AppleLocale | cut -d "_" -f1`
loc=$( cat .SleeperLang.txt)
if [[ ! $loc = "ru" ]]; then loc="en"; fi 
GET_USER_PASSWORD
timeout_limit_old=1
GET_POWER_SETTINGS


#GET_POWER_SETTINGS 
if [[ $loc = "ru" ]]; then
echo "${mypassword}" | sudo -S osascript -e 'Tell application "System Events" to display dialog "       Сервис усыпления компа запущен " '"${icon_string}"' buttons "OK" giving up after 3'  2>/dev/null
else
echo "${mypassword}" | sudo -S osascript -e 'Tell application "System Events" to display dialog "       Eutanasia service started " '"${icon_string}"' buttons "OK" giving up after 3'  2>/dev/null
fi
# MAIN
while true
    do  
        GET_POWER_SETTINGS
        
         if [[ ${system} = ${display} ]] && [[ ! $( echo "${mypassword}" | sudo -S ioreg -n IODisplayWrangler | grep -i IOPower | tr -d '"{|}' | rev | cut -f1 -d',' | rev | cut -f2 -d= ) = 4 ]]; then
                 echo "${mypassword}" | sudo -S pmset sleepnow; sleep 15
         else
            if [[ ! $( echo "${mypassword}" | sudo -S ioreg -n IODisplayWrangler | grep -i IOPower | tr -d '"{|}' | rev | cut -f1 -d',' | rev | cut -f2 -d= ) = 4 ]]; then GO_TO_BED; fi 2>/dev/null
         fi
        sleep 29
    done

