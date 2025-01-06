function selectByCondition(){
  title="Enter the column number to filter by (from 1 to ${#headersArray[@]}):"

  # we should make a radioOptions function that takes options as array then returns the valid radioColumns array
  local columns=()
  for header in "${headersArray[@]}"
  do
    columns+=(FALSE "$header")
  done
  # we can make it as a radio list
  local spcifiedColumn=$(zenity --list --radiolist --title="$title" --column="check" --column="Columns" "${radioColumns[@]}" --width=400 --height=300)

  if isEmpty "$spcifiedColumn"
  then
    zenity --error --text="No column selected. Exiting function."
    return
  fi

  # first you will need to get the column idx (iterate on the headersArray)
  
  local columnIdx=-1
  for i in ${!headersArray[@]}
  do
    if [[ "${headersArray[$i]}" == "$spcifiedColumn" ]]
    then
      columnIdx=$i
    fi
  done
  
  # show a radio list to choose the wanted operation (by operator)
  local avaliableOperators=("==" "!=" ">" "<" ">=" "<=")
  local options=()
  for operator in "${avaliableOperators[@]}"
  do
    options+=(FALSE "$operator")
  done

  local spcifiedOperator=$(zenity --list --radiolist --title="Choose an operator" --column="check" --column="operators" "${options[@]}" --width=400 --height=300)

  
  # get the value to make the operation
  local value=$(zenity --entry \
    --title="Value Entry" \
    --text="Enter the value to compare (e.g., Manager, 5000):" \
    --width=400)

  local columnNumber=$((columnIdx + 1))
  local condition="\$$columnNumber $spcifiedOperator \"$value\""
  local result=$(awk -F ":" "$condition" "$dataFile")

  local selectedColumns=()
  for header in "${headersArray[@]}"
  do
    selectedColumns+=(--column="$header")
  done

  local selectedData=()
  while IFS= read -r line; do
    IFS=':' read -r -a row <<< "$line"
    selectedData+=("${row[@]}")
  done <<< "$result"

  if isEmpty "$result"
  then
    zenity --error --text="No rows found where $columnName $operator $value."
  else
    zenity --list \
      --title="Table Data" \
      --height=400 --width=600 \
      "${selectedColumns[@]}" \
      "${selectedData[@]}"
  fi
}
