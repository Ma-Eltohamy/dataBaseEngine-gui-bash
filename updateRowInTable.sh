function updateRowInTable() {
  dataBaseName=$1

  # Use Zenity to prompt for the table name
  tableName=$(zenity --entry --title="Enter Table Name" --text="Enter the table name to update a row in:")

  if ! isAlreadyExists -t "$dataBaseName" "$tableName"; then
    zenity --error --text="Table '$tableName' does not exist."
    return
  fi

  metaFile="$HOME/DBMS/$dataBaseName/$tableName.meta"
  dataFile="$HOME/DBMS/$dataBaseName/$tableName.data"

  # Get the primary key
  primaryKey=$(sed -n '3p' "$metaFile" | xargs)
  zenity --info --text="The primary key is: $primaryKey"

  # Use Zenity to prompt for the primary key value to update
  pkValue=$(zenity --entry --title="Enter Primary Key Value" --text="Enter the value of the primary key to update:")

  # Check if the row exists
  row=$(grep "^$pkValue:" "$dataFile")
  if [[ -z "$row" ]]; then
    zenity --error --text="No row found with primary key '$pkValue'."
    return
  fi

  zenity --info --text="Row found: $row"

  # Get column names and types
  colNames=()
  colTypes=()
  for ((i = 4; i <= $(wc -l < "$metaFile"); i++)); do
    line=$(sed -n "${i}p" "$metaFile")
    colName=$(echo "$line" | cut -d "(" -f 1 | sed 's/^ //;s/ $//')
    colType=$(echo "$line" | cut -d "(" -f 2 | cut -d ")" -f 1 | sed 's/^ //;s/ $//')

    colNames+=("$colName")
    colTypes+=("$colType")
  done

  # Prompt the user for new values using Zenity
  newRow=()
  IFS=':' read -r -a oldRow <<< "$row"
  for ((i = 0; i < ${#colNames[@]}; i++)); do
    colName="${colNames[i]}"
    colType="${colTypes[i]}"
    oldValue="${oldRow[i]}"

    while true; do
      # Use Zenity to prompt for new value
      newValue=$(zenity --entry --title="Update $colName" --text="Enter new value for '$colName' (${colType}) [current: $oldValue]:")
      
      # If the user presses Enter, keep the old value
      if [[ -z "$newValue" ]]; then
        newValue="$oldValue"
        break
      fi

      # Validate the input based on column type
      case "$colType" in
        INT)
          if [[ "$newValue" =~ ^-?[0-9]+$ ]]; then
            break
          else
            zenity --error --text="Value for '$colName' must be an integer."
          fi;;
        FLOAT)
          if [[ "$newValue" =~ ^-?[0-9]*\.?[0-9]+$ ]]; then
            break
          else
            zenity --error --text="Value for '$colName' must be a floating-point number."
          fi;;
        STRING)
          if [[ -n "$newValue" ]]; then
            break
          else
            zenity --error --text="Value for '$colName' cannot be empty."
          fi;;
        *)
          zenity --error --text="Unknown data type '$colType'."
          return;;
      esac
    done

    # Check if the new primary key value already exists
    if [[ "$colName" == "$primaryKey" && "$newValue" != "$oldValue" ]]; then
      if grep -q "^$newValue:" "$dataFile"; then
        zenity --error --text="A row with the primary key '$newValue' already exists. Please enter a unique primary key."
        return
      fi
    fi
    newRow+=("$newValue")
  done

  # Replace the old row with the new row in the data file
  newRowString=$(IFS=':'; echo "${newRow[*]}")
  sed -i "s/^$row\$/$newRowString/" "$dataFile"

  if [[ $? -eq 0 ]]; then
    zenity --info --text="Row updated successfully!"
  else
    zenity --error --text="Failed to update the row."
  fi
}
