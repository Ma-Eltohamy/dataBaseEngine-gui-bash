function insertIntoTable {
    # Prompt for the table name using Zenity
    tableName=$(zenity --entry --title="Insert Data" --text="Enter the table name to insert data into:" --entry-text="" --height=150 --width=400)

    if ! isAlreadyExists -t "$CONNECTED_DB" "$tableName"
    then
        zenity --error --title="Error" --text="Table '$tableName' does not exist." --height=150 --width=400
        return
    fi

    local dataFile="$DB_PATH/$CONNECTED_DB/$tableName.data"
    local metaFile="$DB_PATH/$CONNECTED_DB/$tableName.meta"

    # Get the primary key (from the 3rd line in the metadata file)
    primaryKey=$(sed -n '3p' "$metaFile" | xargs)
    zenity --info --title="Primary Key" --text="The primary key is: $primaryKey" --height=150 --width=400

    # Get the column names (from lines starting from 4th to the last column definition)
    colNames=()
    colTypes=()
    for ((i = 4; i <= $(wc -l < "$metaFile"); i++))
    do
        line=$(sed -n "${i}p" "$metaFile")
        # 's/^ //;s/ $//' applying two regex first replaces from the begging
        # and the second replaces from the ending
        colName=$(echo "$line" | cut -d "(" -f 1 | sed 's/^ //;s/ $//')
        colType=$(echo "$line" | cut -d "(" -f 2 | cut -d ")" -f 1 | sed 's/^ //;s/ $//')

        colNames+=("$colName")
        colTypes+=("$colType")
    done

    # Collect and validate data
    rowData=()
    for ((i = 0; i < ${#colNames[@]}; i++))
    do
        colName="${colNames[i]}"
        colType="${colTypes[i]}"

        while true
        do
            value=$(zenity --entry --title="Enter Data" --text="Enter value for '$colName' (${colType}):" --entry-text="" --height=150 --width=400)

            if isEmpty "$value" && "$colType" == "STRING"
            then
                break
            fi

            # Validate data type
            case "$colType" in
                INT)
                    if [[ "$value" =~ ^-?[0-9]+$ ]]; then
                        break
                    else
                        zenity --error --title="Error" --text="Value for '$colName' must be an integer." --height=150 --width=400
                    fi;;
                FLOAT)
                    if [[ "$value" =~ ^-?[0-9]*\.?[0-9]+$ ]]; then
                        break
                    else
                        zenity --error --title="Error" --text="Value for '$colName' must be a floating-point number." --height=150 --width=400
                    fi;;
                STRING)
                    if isEmpty "$value"
                    then
                        break
                    else
                        zenity --error --title="Error" --text="Value for '$colName' cannot be empty." --height=150 --width=400
                    fi;;
                *)
                    zenity --error --title="Error" --text="Unknown data type '$colType'." --height=150 --width=400
                    return;;
            esac
        done

        # Check for primary key uniqueness
        if [[ "$colName" == "$primaryKey" ]]
        then
            if grep -q "^$value:" "$dataFile"
            then
                zenity --error --title="Error" --text="Duplicate value for primary key '$primaryKey': $value." --height=150 --width=400
                return
            fi
        fi

        rowData+=("$value")
    done

    # Write data to the file
    echo "${rowData[*]}" | tr ' ' ':' >> "$dataFile"
    if [[ $? -eq 0 ]]; then
        zenity --info --title="Success" --text="Data inserted successfully into table '$tableName'." --height=150 --width=400
    else
        zenity --error --title="Error" --text="Failed to insert data into table '$tableName'." --height=150 --width=400
    fi
}
