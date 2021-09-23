#!/bin/bash
# Good color list https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux

cyanb="\033[01;36m"
white="\033[01;37m"
nc="\033[0m"
unb="${n}${cyanb}"
VERBOSE=0
boxWidth=102


print_n () {
    # https://stackoverflow.com/questions/5349718/how-can-i-repeat-a-character-in-bash
    printf "$1"'%.s' $(eval "echo {1.."$(($2))"}")
}


print_alias () {
    str_len=$((${#1} + ${#2}))

    printf "${cyanb}"
    printf "|| "
    printf "${white}$1${cyanb}: $2"
    print_n " " $(($boxWidth - str_len - 3))
    printf "||\n"
    printf "${nc}"

}

blank_line () {
    printf "${cyanb}"
    printf "||"
    print_n " " $(($boxWidth))
    printf "||\n"
    printf "${nc}"
}

print_line () {
    str=$1
    str_len=${#1}
    if [ -z $2 ]
        then alignment=$2
    else alignment=0
    fi

    printf "${cyanb}"
    printf "||"
    printf " %s" $str
    print_n " " $(($boxWidth - str_len - 1))
    printf "||\n"
    printf "${nc}"
}

print_buffer () {
    printf "${cyanb}"
    if [ -z $1 ]
    then 
        printf '||'
        print_n '=' $boxWidth
        printf '||\n'
    elif [ $1 -eq 0 ]
        then 
            printf '/' 
            print_n '=' $(($boxWidth + 2))
            printf '\\\n'
    elif [ $1 -eq 1 ]
        then 
            printf '\\' 
            print_n '=' $(($boxWidth + 2))
            printf '/\n'
    fi
    printf "${nc}"
   
}

finish_line () {
    printf "${cyanb}"
    print_n " " $(($boxWidth - $1))
    printf "||\n"
    printf "${nc}"
}

print_tag () {
    tag=$1
    tagLen=${#1}

    blank_line
    printf "${cyanb}"
    printf "||"
    print_n "=" $(($tagLen + 4))
    finish_line $((tagLen + 4))
    printf "${cyanb}|| ${tag}  |"
    finish_line $((tagLen + 4))
    printf "${cyanb}||"
    print_n "=" $(($tagLen + 4))
    finish_line $((tagLen + 4))
    blank_line
}


print_base_list () {
    print_buffer 0
    blank_line
    print_buffer
    blank_line
    print_alias "lsa" "List Aliases"                                                                               
    print_alias "ual" "Update Alias List"
    print_tag "Git Aliases"
    print_alias "b" "git branch"                                                                            
    print_alias "co" "git checkout"                                                                         
    print_alias "com" "git commit -m"
    print_alias "s" "git status"
}

print_verbose_list () {
    print_tag "Org Systems"
    print_alias "dev-env" "Set ALL env variables to sandbox"
    print_alias "staging-env" "Set ALL env vairbales to okta-staging"
    print_alias "my-ids" "List my different ids so i dont have to keep searching them"
}


while getopts "v" OPTION
do
    case $OPTION in
        v)
            VERBOSE=1
            ;;
        \?)
            echo "flag -v can be given to see full list"
            exit
            ;;
    esac
done

echo
print_base_list
if [ $VERBOSE -eq 1 ]
then
    print_verbose_list
fi
blank_line
print_buffer 1
echo
