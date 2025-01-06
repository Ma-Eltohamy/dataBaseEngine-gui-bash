function deleteFromTable {
  # Prompt for the table name to delete from using Zenity
  local tableName=$(zenity --entry --title="Delete from Table" --text="Enter the table name to delete from:" --entry-text="" --height=150 --width=400)

  if isEmpty "$tableName"
  then
    zenity --error --title="Error" --text="Table name cannot be empty.\nTip: Please enter a valid table name." --height=150 --width=400
    return
  fi

  if ! isAlreadyExists -t "$CONNECTED_DB" "$tableName"
  then
    zenity --error --title="Error" --text="Table '$tableName' does not exist." --height=150 --width=400
    return
  fi


  local dataFile="$DB_PATH/$CONNECTED_DB/$tableName.data"
  local metaFile="$DB_PATH/$CONNECTED_DB/$tableName.meta"

  local headersString=$(sed -n '4,$p' "$metaFile" | cut -d '(' -f1)
  local headersArray
  readarray -t headersArray <<< "$headersString"

  local headers=()
  for header in "${headersArray[@]}"
  do
    headers+=(FALSE "$header")
  done

  selectedColumn=$(zenity --list --radiolist --title="Table Columns" --text="Choose a column to filter rows for deletion:" --column="check" --column="Column name" "${headers[@]}" --height=250 --width=400)

  matchValue=$(zenity --entry --title="Match Value" --text="Enter the value to match in column '$selectedColumn':" --entry-text="" --height=150 --width=400)

  colIndex=-1
  for ((i = 0; i < ${#headersArray[@]}; ++i))
  do
    if [[ "$selectedColumn" == "${headersArray[$i]}" ]]
    then
      colIndex=$i
    fi
  done

  matchingRows=$(awk -F ":" -v col="$colIndex" -v val="$matchValue" '$(col + 1) == val' "$dataFile")
  if [[ -z "$matchingRows" ]]; then
    zenity --info --title="No Matching Rows" --text="No matching rows found for '$selectedColumn = $matchValue'." --height=150 --width=400
    return
  fi

  local columns=()
  for header in "${headersArray[@]}"; do
    columns+=(--column="$header")
  done

  local data=()
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
  local confirmation=$(zenity --question --title="Confirm Deletion" --text="Do you want to proceed with deletion?" --height=150 --width=400)
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
