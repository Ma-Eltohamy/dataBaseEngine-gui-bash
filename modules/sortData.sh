function sortData() {
  local optinos=()
  local columns=()
  for header in "${headersArray[@]}"
  do
    optinos+=(FALSE "$header")
    columns+=(--column="$header")
  done

  local selectedOption=$(zenity --list --radiolist --column="Select" --column="Option" "${optinos[@]}")

  columnNumber=-1

  for ((i = 0; i < ${#headersArray[@]}; i++))
  do
    if [[ "${headersArray[$i]}" == "$selectedOption" ]]
    then
      columnNumber=$((i + 1))
    fi
  done


  if [ -z "$selectedOption" ]; then
    zenity --error --text="Column number cannot be empty."
    return
  fi

  lineNumber=$((columnNumber + 3))
  colDataType=$(sed -n "${lineNumber}p" "$metaFile" | cut -d"(" -f2 | cut -d")" -f1)

  data=()
  if [[ "$colDataType" == "INT" || "$colDataType" == "FLOAT" ]]
  then 
    while IFS= read -r line
    do
      IFS=':' read -r -a row <<< "$line"
      data+=("${row[@]}")
    done <<< $(sort -t":" -n -k"$columnNumber" "$dataFile")
  else
    while IFS= read -r line
    do
      IFS=':' read -r -a row <<< "$line"
      data+=("${row[@]}")
    done <<< $(sort -t":" -k"$columnNumber" "$dataFile")
  fi

  zenity --list \
    --title="Table Data" \
    --height=400 --width=600 \
    "${columns[@]}" \
    "${data[@]}"
}
