function selectByPrimaryKey() {
  primaryKeyIndex=$1
  
  pkValue=$(zenity --entry --title="Enter Primary Key" --text="Enter the value of the primary key ($primaryKey):")

  if [ -z "$pkValue" ]; then
    zenity --error --text="Primary key value cannot be empty."
    return
  fi

  echo "---------------- debuggin -----------------"
  echo "the primaryKey value: $pkValue"
  echo "the primaryKey idx: $primaryKeyIndex"
  echo "---------------- debuggin -----------------"

  # result=$(awk -F ":" "\$$primaryKeyIndex == \"$pkValue\"" "$dataFile")
  result=$(awk -F: -v pk="$pkValue" -v col="$primaryKeyIndex" '$col == pk' "$dataFile")
  data=()
  while IFS= read -r line; do
    IFS=':' read -r -a row <<< "$line"
    data+=("${row[@]}")
  done <<< "$result"
  echo "---------------- debuggin -----------------"
  echo $result
  echo "---------------- debuggin -----------------"

  readarray -t headersArray <<< "$headers"

  columns=()
  for header in "${headersArray[@]}"; do
    columns+=(--column="$header")
  done

  echo "----------- debugging ----------------"
  echo "${columns[@]}"
  echo "----------- debugging ----------------"

  if [ -z "$result" ]; then
    zenity --error --text="No rows found with the primary key value: $pkValue"
  else
    zenity --list \
    --title="Table Data" \
    --height=400 --width=600 \
    "${columns[@]}" \
    "${data[@]}"
  fi
}
