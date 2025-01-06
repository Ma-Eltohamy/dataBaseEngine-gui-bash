function selectSpecificColumns() {
  echo "------------ debugging -------------"
  # Create the --checklist options dynamically
  local checklist_options=()
  for header in "${headersArray[@]}"; do
    checklist_options+=(FALSE "$header")
  done

  local specifiedColumns=$(zenity --list --width=300 --height=250  \
    --title="Columns" \
    --text="Choose the Columns you want to select :" \
    --checklist \
    --column="Check" \
    --column="Column" \
    "${checklist_options[@]}")

  if isEmpty "$specifiedColumns"
  then
    zenity --error --text="No columns selected. Exiting function."
    return
  fi

  local selectedColumnsArray
  IFS='|' read -r -a selectedColumnsArray <<< "$specifiedColumns"
  
  local awkCommand=""
  local selectedHeaders=""
  local selectedColumns=()

  for ((i = 0; i < ${#headersArray[@]}; ++i))
  do
      for selectedHeader in "${selectedColumnsArray[@]}"
      do
          if [[ "${headersArray[$i]}" == "$selectedHeader" ]]
          then
              selectedColumns+=(--column="$selectedHeader")
              columnNumber=$((i + 1)) 
              if isEmpty "$awkCommand"
              then
                  awkCommand="\$$columnNumber"
                  selectedHeaders="$selectedHeader"
              else
                  awkCommand="$awkCommand \":\" \$$columnNumber"
                  selectedHeaders="$selectedHeaders:$selectedHeader"
              fi
              break
          fi
      done
  done

  # Print the selected headers and data using Zenity
  data=()
  while IFS= read -r line; do
    IFS=':' read -r -a row <<< "$line"
    result+=("${row[@]}")
  done <<< "$(awk -F ":" "{print $awkCommand}" "$dataFile")"

  if isEmpty "$result"
  then
    zenity --error --text="No data found for the selected columns."
  else
    zenity --list \
    --title="Table Data" \
    --height=400 --width=600 \
    "${selectedColumns[@]}" \
    "${result[@]}"
  fi
}
