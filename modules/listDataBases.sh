function listDataBases() {
    # Check if the DB_PATH exists
    if isAlreadyExists -m
    then
        # DATABASES is a global var that holds the current avalible databases
        # declared in databaseEngine.sh
        
        loadDataBases

        if isEmpty "$DATABASES"
        then
            zenity --info --title="No Databases" --text="No databases found at $DB_PATH." --height=150 --width=400
        else
            # Display databases in Zenity dialog
            zenity --list --title="Databases List" --column="Databases" $DATABASES --height=300 --width=400
        fi
    else
        zenity --error --title="Error" --text="Directory '$DB_PATH' does not exist." --height=150 --width=400
    fi
}

function loadDataBases(){
    echo "----------- Data Bases has been loaded successfully. ---------------"
    DATABASES=$(ls -1 "$DB_PATH" | sort)
}
