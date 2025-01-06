function dropTable() {
    dataBaseName=$1

    # Prompt for the table name using Zenity
    tableName=$(zenity --entry --title="Drop Table" --text="Enter the table name to drop:" --entry-text="" --height=150 --width=400)

    if [ -z "$tableName" ]; then
        zenity --error --title="Error" --text="Table name cannot be empty.\nTip: A valid table name should contain at least one character." --height=150 --width=400
        return
    fi

    if isStartWithChars "$tableName"; then
        zenity --error --title="Error" --text="Table name cannot start with a number or special character.\nTip: Use alphabetic characters or underscores (_) at the beginning." --height=150 --width=400
        return
    fi

    if ! isAlreadyExists -t "$dataBaseName" "$tableName"; then
        zenity --error --title="Error" --text="Table '$tableName' does not exist." --height=150 --width=400
        return
    fi

    dataFile="$HOME/DBMS/$dataBaseName/$tableName.data"
    metaFile="$HOME/DBMS/$dataBaseName/$tableName.meta"

    # Confirm the deletion action before proceeding
    zenity --question --title="Confirm Deletion" --text="Are you sure you want to permanently delete the table '$tableName'?" --height=150 --width=400

    if [[ $? -eq 0 ]]; then
        rm "$dataFile" "$metaFile"  # Remove the table data and metadata files
        zenity --info --title="Success" --text="Table '$tableName' has been successfully deleted." --height=150 --width=400
    else
        zenity --info --title="Deletion Canceled" --text="Action canceled. Table '$tableName' was not deleted." --height=150 --width=400
    fi
}
