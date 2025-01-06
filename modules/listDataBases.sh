function listDataBases() {
    local dataBaseDir="$HOME/DBMS"

    # Check if the directory exists
    if isAlreadyExists -m; then
        # Check if the directory is empty
        if [ -z "$(ls -1 "$dataBaseDir")" ]; then
            zenity --info --title="No Databases" --text="No databases found in $dataBaseDir." --height=150 --width=400
        else
            # Get the list of databases
            databases=$(ls -1 "$dataBaseDir" | sort)

            # Display databases in Zenity dialog
            zenity --list --title="Databases List" --column="Databases" $databases --height=300 --width=400
        fi
    else
        zenity --error --title="Error" --text="Directory '$dataBaseDir' does not exist." --height=150 --width=400
    fi
}
