function sortData() {
  headersString=$1

  IFS=':' read -r -a headersArray <<< "$headersString"

  echo "-------------- debugging --------------"
  echo "${headersArray[@]}"
  echo "-------------- debugging --------------"

  optinos=()
  columns=()
  for header in "${headersArray[@]}"
  do
    optinos+=(FALSE "$header")
    columns+=(--column="$header")
  done

  selectedOption=$(zenity --list --radiolist --column="Select" --column="Option" "${optinos[@]}")

  echo "-------------- debugging --------------"
  echo "$selectedOption"
  echo "-------------- debugging --------------"

  columnNumber=-1

  for ((i = 0; i < ${#headersArray[@]}; i++))
  do
    if [[ "${headersArray[$i]}" == "$selectedOption" ]]
    then
      columnNumber=$((i + 1))
    fi
  done

  echo "-------------- debugging --------------"
  echo "The column number is: ${columnNumber} sed -n \${$columnNumber}p"
  echo "-------------- debugging --------------"
  

  if [ -z "$selectedOption" ]; then
    zenity --error --text="Column number cannot be empty."
    return
  fi

  lineNumber=$((columnNumber + 3))
  echo "-------------- debugging --------------"
  echo "The line number is: ${columnNumber} sed -n \${$columnNumber}p"
  echo "-------------- debugging --------------"
  colDataType=$(sed -n "${lineNumber}p" "$metaFile" | cut -d"(" -f2 | cut -d")" -f1)
  echo "-------------- debugging --------------"
  echo "$colDataType"
  echo "-------------- debugging --------------"

  data=()
  if [[ "$colDataType" == "INT" || "$colDataType" == "FLOAT" ]]
  then 
    echo "---------------- yes yes --------------"
    while IFS= read -r line
    do
      IFS=':' read -r -a row <<< "$line"
      data+=("${row[@]}")
    done <<< $(sort -t":" -n -k"$columnNumber" "$dataFile")
  else
    echo "---------------- hop hop --------------"
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
