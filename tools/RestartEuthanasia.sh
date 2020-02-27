#!/bin/bash

mypassword="0"
if (security find-generic-password -a ${USER} -s euthanasia -w) >/dev/null 2>&1; then
                mypassword=$(security find-generic-password -a ${USER} -s euthanasia -w)
fi

cd "$(dirname "$0")"

while true; do

sleep 10801

if [[ ! -f timer.txt ]]; then

    if [[ $( echo "${mypassword}" | sudo -Sk launchctl list | grep "Euthanasia.job" | cut -f3 | grep -x "Euthanasia.job" ) ]]; then
            echo "${mypassword}" | sudo -Sk launchctl unload -w /System/Library/LaunchDaemons/Euthanasia.plist 2>/dev/null
            sleep 0.5
            echo "${mypassword}" | sudo -Sk launchctl load -w /System/Library/LaunchDaemons/Euthanasia.plist 2>/dev/null
    fi

fi

done   

exit 1