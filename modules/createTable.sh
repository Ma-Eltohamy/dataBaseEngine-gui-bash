function createTable {
    # Prompt for the table name
    local tableName=$(zenity --entry --title="Create Table" --text="Enter table name:")

    if isEmpty "$tableName"
    then
        zenity --error --title="Error" --text="Table name cannot be empty.\nTip: A valid table name should contain at least one character."
        return
    fi

    if isStartWithChars "$tableName"
    then
        zenity --error --title="Error" --text="Table name cannot start with a number or special character.\nTip: Use alphabetic characters or underscores (_) at the beginning."
        return
    fi

    if isAlreadyExists -t "$CONNECTED_DB" "$tableName"; then
        zenity --warning --title="Warning" --text="The table name '$tableName' already exists.\nTip: Use a different name or proceed to modify the existing table name."
        return
    fi

    local dataFile="$DB_PATH/$CONNECTED_DB/$tableName.data"
    local metaFile="$DB_PATH/$CONNECTED_DB/$tableName.meta"

    touch "$dataFile" "$metaFile"

    if [[ $? -ne 0 ]]; then
        zenity --error --title="Error" --text="Failed to create table files."
        return
    fi

    zenity --info --title="Success" --text="Table $tableName created successfully in the database."

    # Prompt for the number of columns
    colsNum=$(zenity --entry --title="Columns" --text="Enter the number of columns:")

    if ! [[ "$colsNum" =~ ^[0-9]+$ ]]; then
        zenity --error --title="Error" --text="Invalid number of columns. Must be a positive integer."
        return
    fi

    declare -a colNames
    declare -a colTypes

    # Collect column names and types
    for ((i = 1; i <= colsNum; i++))
    do
        colName=$(zenity --entry --title="Column $i" --text="Enter the name of column $i:")

        if isEmpty "$colName"
        then
            zenity --error --title="Error" --text="Column name cannot be empty."
            i=$((i - 1)) # Retry this column
            continue
        fi

        if isStartWithChars "$colName"
        then
            zenity --error --title="Error" --text="Column name cannot start with a number or special character."
            i=$((i - 1)) 
            continue
        fi

        # Check if column name already exists
        if [[ " ${colNames[*]} " == *" $colName "* ]]
        then
            zenity --error --title="Error" --text="Column name '$colName' already exists."
            i=$((i - 1))
            continue
        fi

        colType=$(zenity --list --title="Column Data Type" --text="Select data type for column '$colName':" --radiolist \
            --column="Select" --column="Type" \
            FALSE "INT" FALSE "STRING" FALSE "FLOAT")

        if isEmpty "$colType" 
        then
            zenity --error --title="Error" --text="Invalid selection. Please choose a valid data type."
            i=$((i - 1)) # Retry this column
            continue
        fi

        colNames+=("$colName")
        colTypes+=("$colType")
    done


    primaryKey=$(zenity --list --title="Primary Key" --text="Select the primary key from the columns:" --column="Cadnidate keys" "${colNames[@]}")

    if isEmpty "$primaryKey"
    then
        zenity --error --title="Error" --text="Invalid selection. Please choose a valid column as the primary key."
        return
    fi

    zenity --info --title="Primary Key" --text="Primary key set to '$primaryKey'."

    # Write metadata to the meta file
    {
        echo "$tableName"
        echo "${#colNames[@]}"
        echo "$primaryKey"
        for ((i = 0; i < colsNum; i++)); do
            echo "${colNames[i]} (${colTypes[i]})"
        done
    } > "$metaFile"

    zenity --info --title="Success" --text="Table $tableName metadata saved to $metaFile."
}
