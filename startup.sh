#!/bin/bash

#colors
cyanb="\033[01;36m"
nc="\033[0m"

repos=( "dev-utilities" "ingest-service" "regal-voice-api" "regal-voice-ui" )
devRoot=$HOME/dev


# Almost entirely stolen from https://askubuntu.com/questions/1020692/terminal-splash-screen-with-weather-calendar-time-sysinfo
DateColumnOffset=120 # Default is 27 for 80 character line, 34 for 92 character line
DateRowOffset=0
TimeColumn=152
reposOffset=132
blockOffset=14 # Move tput drawn elements up to match height of static image echoed by list-aliases (found 18 to be about good)
maxRepoLen=0
inputRow=0
inputCol=0

echo $repos

max_str_len () {
	# Find greatest string length in an array
	for i in "${repos[@]}"
	do
	   if [ ${#i} -gt $maxRepoLen ]
	   then 
	   		maxRepoLen=${#i}
	   	fi

	   # or do whatever with individual element of the array
	done
}

write_calender () {
	tput sc                 # Save cursor position.
	# Move up 9 lines
	i=$DateRowOffset
	tput cuu $blockOffset            # Move up 20 cols (to top of block)

	while [ $((++i)) -lt 10 ]; do tput cuu1; done

	tput cuf $DateColumnOffset    # Position to column 27 for date display

	# -h needed to turn off formating: https://askubuntu.com/questions/1013954/bash-substring-stringoffsetlength-error/1013960#1013960
	cal > /tmp/terminal1
	# -h not supported in Ubuntu 18.04. Use second answer: https://askubuntu.com/a/1028566/307523
	tr -cd '\11\12\15\40\60-\136\140-\176' < /tmp/terminal1  > /tmp/terminal

	CalLineCnt=1
	Today=$(date +"%e")

	printf "${cyanb}"
	while IFS= read -r Cal; do
	    printf "%s" "$Cal"
	    if [[ $CalLineCnt -gt 2 ]] ; then
	        # See if today is on current line & invert background
	        tput cub 22
	        for (( j=0 ; j <= 18 ; j += 3 )) ; do
	            Test=${Cal:$j:2}            # Current day on calendar line
	            if [[ "$Test" == "$Today" ]] ; then
	                printf "\033[7m"        # Reverse: [ 7 m
	                printf "%s" "$Today"
	                printf "${nc}"  		# Normal: [ 0 m
	                printf "${cyanb}"      
	                tput cuf 1
	            else
	                tput cuf 3
	            fi
	        done
	    fi

	    tput cud1               # Down one line
	    tput cuf $DateColumnOffset    # Move 27 columns right
	    CalLineCnt=$((++CalLineCnt))
	done < /tmp/terminal

	tput rc                     # Restore saved cursor position.
}

write_time () {
	tput sc                 # Save cursor position.
	# Move up 8 lines
	i=0
	while [ $((++i)) -lt 9 ]; do tput cuu1; done
	tput cuf $TimeColumn    # Move 49 columns right
	tput cuu $blockOffset   # Move up 20 cols (to top of block)
	tput cuu1

	# Do we have the toilet package?
	if hash toilet 2>/dev/null; then
	    echo " $(date +"%I:%M %P") " | \
	        toilet -f future --filter border > /tmp/terminal
	# Do we have the figlet package?
	elif hash figlet 2>/dev/null; then
	   # echo $(date +"%I:%M %P") | figlet > /tmp/terminal
	    date +"%I:%M %P" | figlet -f chunky > /tmp/terminal
	# else use standard font
	else
	#    echo $(date +"%I:%M %P") > /tmp/terminal
	    date +"%I:%M %P" > /tmp/terminal
	fi

	while IFS= read -r Time; do
	    printf "${cyanb}"   # color cyan
	    printf "%s" "$Time"
	    tput cud1               # Up one line
	    tput cuf $TimeColumn    # Move 49 columns right
	done < /tmp/terminal

	tput rc                     # Restore saved cursor position.
}

write_repos () {
	max_str_len

	tput sc                 # Save cursor position.

	tput cuf $reposOffset
	tput cuu 13

	reposlen=${#repos[@]}

	printf "${cyanb}/================================\\"
	tput cud1
	tput cuf $reposOffset


	for (( i=1; i<${reposlen} + 1; i++ ));
	do
	  printf "||    [$i] ${repos[$i]}"
	  tput cuf $((7 + $maxRepoLen - ${#repos[$i]}))
	  printf "||"
	  tput cud1
	  tput cuf $reposOffset

	done
	printf "\\================================/"


	tput cud1
	tput cuf $(($reposOffset + 12))
	printf "========="
	tput cud1
	tput cuf $(($reposOffset + 12))
	printf "||     ||"
	tput cud1
	tput cuf $(($reposOffset + 12))
	printf "=========${nc}"
	tput cub 5
	tput cuu1

}


draw_block () {
	write_calender
	write_time
	write_repos
}


main () {
	list-aliases
	draw_block
	tput cup $inputRow $(($inputCol - 5))
	read repo
	if [ ! -z $repo ]
	then
		cd "$devRoot/${repos[$repo]}"
	fi
	tput rc

}

dev-env
main