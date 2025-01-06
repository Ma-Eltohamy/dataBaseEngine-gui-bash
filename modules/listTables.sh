function listTables() {
    dataBaseName=$1

    if ! isAlreadyExists -d "$dataBaseName"
    then
        zenity --error --title="Error" --text="Database '$dataBaseName' does not exist or was not provided." --height=150 --width=400
        return
    fi

    echo "Listing Tables in Database: $dataBaseName"
    echo "---------------------------------"

    # Change to the database directory
    cd "$HOME/DBMS/$dataBaseName" || { echo "[Error] Failed to access the database directory."; return; }

    # Find and list unique table names
    tableList=$(ls -1 *.data *.meta 2>/dev/null | sed -E 's/\.(data|meta)$//' | sort -u)

    if [[ -z "$tableList" ]]; then
        zenity --info --title="No Tables" --text="No tables found in the database '$dataBaseName'." --height=150 --width=400
    else
        # Create Zenity list dialog with tables
        tableChoice=$(zenity --list --title="Tables in Database: $dataBaseName" --column="Tables" $tableList --height=300 --width=400)

        if [[ -n "$tableChoice" ]]; then
            echo "You selected table: $tableChoice"
        fi
    fi

    echo "---------------------------------"
    # Return to the original directory
    cd - >/dev/null
}
