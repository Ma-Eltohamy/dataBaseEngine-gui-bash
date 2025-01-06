function selectFromTable() {
  # Use Zenity to prompt for the table name
  local tableName=$(zenity --entry --title="Enter Table Name" --text="Enter the table name to select data from:")

  if ! isAlreadyExists -t "$CONNECTED_DB" "$tableName"
  then
    zenity --error --text="Table '$tableName' does not exist."
    return
  fi

  local dataFile="$DB_PATH/$CONNECTED_DB/$tableName.data"
  local metaFile="$DB_PATH/$CONNECTED_DB/$tableName.meta"

  # Get the primary key (from the 3rd line in the metadata file)
  local primaryKey=$(sed -n '3p' "$metaFile" | xargs)
  zenity --info --text="The primary key is: $primaryKey"

  local headers=$(sed -n '4,$p' "$metaFile" | cut -d '(' -f1)
  # readarray works fine with headers because the output of headers is \n seperated
  # unlike passing "$headers" --> to any other selecting function as parameters not seperated
  local headersArray
  readarray -t headersArray <<< "$headers"
  # local columnsNumber=${#headersArray[@]} # Count the number of headers
  # local headersString=$(IFS=":"; echo "${headersArray[*]}") # headers but seperated by :

  local primaryKeyIndex=-1 
  for i in "${!headersArray[@]}"
  do
    if [[ "${headersArray[$i]}" == "$primaryKey " ]]
    then
      primaryKeyIndex=$((i + 1)) 
      break
    fi
  done

  local columns=()
  for header in "${headersArray[@]}"
  do
    columns+=(--column="$header")
  done

  while true; do
    # Display a Zenity menu for options
    choice=$(zenity --list --title="Select an Option" --column="Options" \
    "Select all data" \
    "Select specific columns" \
    "Select by primary key" \
    "Select by condition" \
    "Sort data" \
    "Exit" --width=400 --height=300)

    case $choice in
      "Select all data")
        selectAllData 
        ;;
      "Select specific columns")
        selectSpecificColumns
        ;;
      "Select by primary key")
        selectByPrimaryKey
        ;;
      "Select by condition")
        selectByCondition
        ;;
      "Sort data")
        sortData
        ;;
      "Exit")
        zenity --info --text="Exiting selection menu."
        break
        ;;
      *)
        zenity --error --text="Invalid choice! Please select a valid option."
        ;;
    esac
  done
}
