function selectByCondition(){
  title="Enter the column number to filter by (from 1 to ${#headersArray[@]}):"

  columns=()
  for header in "${headersArray[@]}"
  do
    echo "------------- debugging -------------"
    echo "$header"
    echo "------------- debugging -------------"
    columns+=(FALSE "$header")
  done

  # we can make it as a radio list
  spcifiedColumn=$(zenity --list --radiolist --title="$title" --column="check" --column="Columns" "${columns[@]}" --width=400 --height=300)

  if [ -z "$spcifiedColumn" ]; then
    zenity --error --text="No column selected. Exiting function."
    return
  fi

  echo "------------- debugging -------------"
  echo "$spcifiedColumn"
  echo "------------- debugging -------------"

  # first you will need to get the column idx (iterate on the headersArray)
  
  columnIdx=-1
  for i in ${!headersArray[@]}
  do
    # echo "------------- debugging -------------"
    # echo "$headersArray[$i]"
    # echo "columnIDX-->> $columnIdx"
    # echo "------------- debugging -------------"
    if [[ "${headersArray[$i]}" == "$spcifiedColumn" ]]
    then
      columnIdx=$i
    fi
  done
  echo "------------- debugging -------------"
  echo "$spcifiedColumn"
  echo "columnIDX-->> $columnIdx"
  echo "------------- debugging -------------"
  
  # show a radio list to choose the wanted operation (by operator)
  avaliableOperators=("==" "!=" ">" "<" ">=" "<=")
  options=()
  for operator in "${avaliableOperators[@]}"
  do
    options+=(FALSE "$operator")
  done

  spcifiedOperator=$(zenity --list --radiolist --title="Choose an operator" --column="check" --column="operators" "${options[@]}" --width=400 --height=300)

  
  # get the value to make the operation
  value=$(zenity --entry \
    --title="Value Entry" \
    --text="Enter the value to compare (e.g., Manager, 5000):" \
    --width=400)

  columnNumber=$((columnIdx + 1))
  echo "------------- debugging -------------"
  echo "the columnNumber is:-->> $columnNumber"
  echo "the spcifiedOperator is:-->> $spcifiedOperator"
  echo "the value is: -->> $value"
  echo "------------- debugging -------------"

  condition="\$$columnNumber $spcifiedOperator \"$value\""
  echo "------------- debugging -------------"
  echo "The condition is: -->>> $condition"
  echo "------------- debugging -------------"

  result=$(awk -F ":" "$condition" "$dataFile")

  selectedColumns=()
  for header in "${headersArray[@]}"; do
    selectedColumns+=(--column="$header")
  done

  selectedData=()
  while IFS= read -r line; do
    IFS=':' read -r -a row <<< "$line"
    selectedData+=("${row[@]}")
  done <<< "$result"

  if [ -z "$result" ]; then
    zenity --error --text="No rows found where $columnName $operator $value."
  else
    zenity --list \
      --title="Table Data" \
      --height=400 --width=600 \
      "${selectedColumns[@]}" \
      "${selectedData[@]}"
  fi
}
