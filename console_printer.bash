__CONSOLE_PRINTER_LINE_LENGTH=110
__CONSOLE_PRINTER_NO_ECHO=false

function __console_printer() {
    if [ "$__CONSOLE_PRINTER_NO_ECHO" != true ] ; then
        echo -e -n "**  $1"
        COUNTER=0
        SPACES=$(($__CONSOLE_PRINTER_LINE_LENGTH - 8 - ${#1}))
        while [[ $COUNTER -lt $SPACES ]]; do
            echo -e -n " "
            let "COUNTER++"
        done
        echo -e "  **"
    fi
}

function __console_centered_printer() {
    if [ "$__CONSOLE_PRINTER_NO_ECHO" != true ] ; then
        echo -e -n "**"
        FIRST_SPACES_LENGTH=$[($__CONSOLE_PRINTER_LINE_LENGTH - 4 - ${#1}) / 2]
        for ((i=0; i < $FIRST_SPACES_LENGTH; i++)); do
            echo -e -n " "
        done
        echo -e -n "$1"
        LAST_SPACES_LENGTH=$[$__CONSOLE_PRINTER_LINE_LENGTH - 4 - ${#1} - $FIRST_SPACES_LENGTH]
        for ((i=0; i < $LAST_SPACES_LENGTH; i++)); do
            echo -e -n " "
        done
        echo -e "**"
    fi
}

function __console_box_printer() {
    __console_box_line_printer
    __console_centered_printer "$*"
    __console_box_line_printer
}

function __console_box_line_printer() {
    COUNTER=0
    while [[ $COUNTER -lt $__CONSOLE_PRINTER_LINE_LENGTH ]]; do
        echo -n "*"
        let "COUNTER++"
    done
    echo -e ""
}
