#!/bin/bash

# FUNCS
SLEEP_TIMER(){ sleep 30; }
GO_TO_BED(){ pmset sleepnow; SLEEP_TIMER; }
CHECK_DISPLAY(){ pmset -g powerstate | grep -w IODisplayWrangler | xargs | cut -f2 -d' ' ; }
GET_DISPLAY_SLEEP(){ pmset -g | grep displaysleep | awk '{print $2}' ; }
GET_IDLE_TIMER(){ echo $(ioreg -c IOHIDSystem | grep HIDIdleTime | cut -f2 -d=)/1000000000 | bc ; }
GET_ASSERTIONS(){  
	assert=$(pmset -g assertions )
    echo $(($(echo "${assert}" | grep -m1 PreventUserIdleSystemSleep | awk '{print $NF}')+$(echo "${assert}" | grep -m1 PreventUserIdleDisplaySleep  | awk '{print $NF}')))
	}

# INIT
cd "$(dirname "$0")"; ROOT="$(dirname "$0")"
echo "init" >> $HOME/Desktop/test.txt

# MAIN
while true
    do  
    echo "wait" >> $HOME/Desktop/test.txt
        sleep 20
        if [[ ! $( CHECK_DISPLAY ) = 4 ]]; then 
				SLEEP_TIMER
					if [[ ! $( CHECK_DISPLAY ) = 4 ]]; then 
					echo "sleep" >> $HOME/Desktop/test.txt
					sleep 3
					GO_TO_BED
					fi
		fi
				  echo "check timer" >> $HOME/Desktop/test.txt
				  echo "get display sleep = '"$(($(GET_DISPLAY_SLEEP)*60))"'" >> $HOME/Desktop/test.txt
				  echo "get idle timer = '"$(GET_IDLE_TIMER)"'" >> $HOME/Desktop/test.txt
				  if [[ $(($(GET_DISPLAY_SLEEP)*60)) -le $(GET_IDLE_TIMER) ]]; then 
					echo "check assertions" >> $HOME/Desktop/test.txt
					echo "assertions = '"$(GET_ASSERTIONS)"'" >> $HOME/Desktop/test.txt
					if [[ $(GET_ASSERTIONS) = 0 ]]; then 
						echo "sleep2" >> $HOME/Desktop/test.txt
						sleep 3
						GO_TO_BED
					fi
				  fi
				  echo "end pass" >> $HOME/Desktop/test.txt

    done

