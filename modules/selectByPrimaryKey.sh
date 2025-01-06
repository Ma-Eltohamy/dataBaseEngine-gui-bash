function selectByPrimaryKey() {
  pkValue=$(zenity --entry --title="Enter Primary Key" --text="Enter the value of the primary key ($primaryKey):")

  if isEmpty "$pkValue"
  then
    zenity --error --text="Primary key value cannot be empty."
    return
  fi

  result=$(awk -F: -v pk="$pkValue" -v col="$primaryKeyIndex" '$col == pk' "$dataFile")

  IFS=':' read -r -a row <<< "$result"

  if isEmpty "$result"
  then
    zenity --error --text="No rows found with the primary key value: $pkValue"
  else
    zenity --list \
    --title="Table Data" \
    --height=400 --width=600 \
    "${columns[@]}" \
    "${row[@]}"
  fi
}
