function deleteFromTable {
  dataBaseName=$1

  # Prompt for the table name to delete from using Zenity
  tableName=$(zenity --entry --title="Delete from Table" --text="Enter the table name to delete from:" --entry-text="" --height=150 --width=400)

  if [ -z "$tableName" ]; then
    zenity --error --title="Error" --text="Table name cannot be empty.\nTip: Please enter a valid table name." --height=150 --width=400
    return
  fi

  dataFile="$HOME/DBMS/$dataBaseName/$tableName.data"
  metaFile="$HOME/DBMS/$dataBaseName/$tableName.meta"

  if ! isAlreadyExists -t "$dataBaseName" "$tableName"; then
    zenity --error --title="Error" --text="Table '$tableName' does not exist." --height=150 --width=400
    return
  fi


  headers=$(sed -n '4,$p' "$metaFile" | cut -d '(' -f1)
  readarray -t headersArray <<< "$headers"

  headers=()
  for header in "${headersArray[@]}"
  do
    echo "---------------- debugging -----------------"
    echo "$header"
    echo "---------------- debugging -----------------"
    headers+=(FALSE "$header")
  done
  echo "---------------- debugging -----------------"
  echo "${headers[@]}"
  echo "---------------- debugging -----------------"

  selectedColumn=$(zenity --list --radiolist --title="Table Columns" --text="Choose a column to filter rows for deletion:" --column="check" --column="Column name" "${headers[@]}" --height=250 --width=400)
  echo "---------------- debugging -----------------"
  echo "selected col -->>  ${selectedColumn[@]}"
  echo "---------------- debugging -----------------"

  matchValue=$(zenity --entry --title="Match Value" --text="Enter the value to match in column '$selectedColumn':" --entry-text="" --height=150 --width=400)

  echo "----------------- debugging -------------------"
  echo "${#headersArray[@]}"
  echo "----------------- debugging -------------------"
  colIndex=-1
  for ((i = 0; i < ${#headersArray[@]}; ++i))
  do
    if [[ "$selectedColumn" == "${headersArray[$i]}" ]]
    then
      echo "----------------- debugging -------------------"
      echo "the matchValue is: ${headersArray[$i]}----------"
      echo "the selectedColumn is: $selectedColumn----------"
      echo "----------------- debugging -------------------"
      colIndex=$i
    fi
  done

  matchingRows=$(awk -F ":" -v col="$colIndex" -v val="$matchValue" '$(col + 1) == val' "$dataFile")
  if [[ -z "$matchingRows" ]]; then
    zenity --info --title="No Matching Rows" --text="No matching rows found for '$selectedColumn = $matchValue'." --height=150 --width=400
    return
  fi

  columns=()
  for header in "${headersArray[@]}"; do
    columns+=(--column="$header")
  done

  data=()
  while IFS= read -r line; do
    IFS=':' read -r -a row <<< "$line"
    data+=("${row[@]}")
  done <<< "$matchingRows"

  zenity --list \
    --title="Table Data" \
    --height=400 --width=600 \
    "${columns[@]}" \
    "${data[@]}"

  # Confirm deletion
  confirmation=$(zenity --question --title="Confirm Deletion" --text="Do you want to proceed with deletion?" --height=150 --width=400)
  if [[ $? -eq 0 ]]; then
    # Delete rows matching the condition
    awk -F ":" -v col="$colIndex" -v val="$matchValue" '$(col + 1) != val' "$dataFile" > "tmp.data" && mv "tmp.data" "$dataFile"

    if [[ $? -eq 0 ]]; then
      zenity --info --title="Success" --text="Rows matching '$selectedColumn = $matchValue' have been successfully deleted from table '$tableName'." --height=150 --width=400
    else
      zenity --error --title="Error" --text="An error occurred while deleting rows." --height=150 --width=400
    fi
  else
    zenity --info --title="Deletion Canceled" --text="Deletion was canceled." --height=150 --width=400
  fi
}
