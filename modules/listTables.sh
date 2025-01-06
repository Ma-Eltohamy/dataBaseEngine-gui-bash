function listTables() {
    if ! isAlreadyExists -d "$CONNECTED_DB"
    then
        zenity --error --title="Error" --text="Database '$CONNECTED_DB' does not exist or was not provided." --height=150 --width=400
        return
    fi

    # Calling loadTables
    loadTables

    if isEmpty "$TABLES"
    then
        zenity --info --title="No Tables" --text="No tables found in the database '$CONNECTED_DB'." --height=150 --width=400
    else
        # If not empty then just list the tables list
        zenity --list --title="Tables in Database: $CONNECTED_DB" --column="Tables" $TABLES --height=300 --width=400
    fi
}

function loadTables(){
    # Find and list unique table names
    # s/pattern/replacement/ && -E enable Extended Regex && -u uniqe
    TABLES=$(ls -1 "$DB_PATH/$CONNECTED_DB" 2>/dev/null | sed -E 's/\.(data|meta)$//' | sort -u)
}
