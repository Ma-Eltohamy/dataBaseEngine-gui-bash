function selectFromTable() {
  dataBaseName=$1

  # Use Zenity to prompt for the table name
  tableName=$(zenity --entry --title="Enter Table Name" --text="Enter the table name to select data from:")

  if ! isAlreadyExists -t "$dataBaseName" "$tableName"; then
    zenity --error --text="Table '$tableName' does not exist."
    return
  fi

  dataFile="$HOME/DBMS/$dataBaseName/$tableName.data"
  metaFile="$HOME/DBMS/$dataBaseName/$tableName.meta"

  # Get the primary key (from the 3rd line in the metadata file)
  primaryKey=$(sed -n '3p' "$metaFile" | xargs)
  zenity --info --text="The primary key is: $primaryKey"

  headers=$(sed -n '4,$p' "$metaFile" | cut -d '(' -f1)
  # readarray works fine with headers because the output of headers is \n seperated
  # unlike passing "$headers" --> to any other selecting function as parameters not seperated
  readarray -t headersArray <<< "$headers"
  # echo "------------------ debugging -----------------"
  # echo "${headersArray[@]}"
  # echo "------------------ debugging -----------------"
  # maxColumns=${#headersArray[@]} # Count the number of headers
  headersString=$(IFS=":"; echo "${headersArray[*]}") # headers but seperated by :

  primaryKeyIndex=-1 
  for i in "${!headersArray[@]}"
  do
    echo "-------------- debugging ---------------"
    echo "${headersArray[$i]}----------"
    echo "$primaryKey----------"
    echo "-------------- debugging ---------------"

    if [[ "${headersArray[$i]}" == "$primaryKey " ]]
    then
      primaryKeyIndex=$((i + 1)) 
      break
    fi
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
        selectAllData "$dataFile" "$headersString"
        break ;;
      "Select specific columns")
        selectSpecificColumns "$headersString"
        break ;;
      "Select by primary key")
        selectByPrimaryKey "$primaryKeyIndex"
        break ;;
      "Select by condition")
        selectByCondition "$headersString"
        break ;;
      "Sort data")
        sortData "$headersString"
        break ;;
      "Exit")
        zenity --info --text="Exiting selection menu."
        return
        ;;
      *)
        zenity --error --text="Invalid choice! Please select a valid option."
        ;;
    esac
  done
}
