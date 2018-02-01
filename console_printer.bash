__CONSOLE_PRINTER_LINE_LENGTH=60
__CONSOLE_PRINTER_NO_ECHO=false

__console_printer() {
    if [ "$__CONSOLE_PRINTER_NO_ECHO" != true ] ; then
        echo -n "##  $1"
        for ((i=0; i < $[$__CONSOLE_PRINTER_LINE_LENGTH - 8 - ${#1}]; i++)); do
            echo -n " "
        done
        echo "  ##"
    fi
}

__console_centered_printer() {
    if [ "$__CONSOLE_PRINTER_NO_ECHO" != true ] ; then
        echo -n "##"
        FIRST_SPACES_LENGTH=$[($__CONSOLE_PRINTER_LINE_LENGTH - 4 - ${#1}) / 2]
        for ((i=0; i < $FIRST_SPACES_LENGTH; i++)); do
            echo -n " "
        done
        echo -n "$1"
        LAST_SPACES_LENGTH=$[$__CONSOLE_PRINTER_LINE_LENGTH - 4 - ${#1} - $FIRST_SPACES_LENGTH]
        for ((i=0; i < $LAST_SPACES_LENGTH; i++)); do
            echo -n " "
        done
        echo "##"
    fi
}

__console_box_printer() {
    __console_box_line_printer
    __console_centered_printer "$1"
    __console_box_line_printer
}

__console_box_line_printer() {
    for ((i=0; i < $[$__CONSOLE_PRINTER_LINE_LENGTH - ${#1}]; i++)); do
        echo -n "#"
    done
    echo ""
}
