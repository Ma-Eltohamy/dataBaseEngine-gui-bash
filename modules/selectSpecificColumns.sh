function selectSpecificColumns() {
  headersString=$1
  # readarray -t headersArray <<< "$headersString"

  IFS=':' read -r -a headersArray <<< "$headersString"
  echo "------------------ debugging -----------------"
  echo "${headersArray[@]}"
  echo "------------------ debugging -----------------"

  # Create the --checklist options dynamically
  checklist_options=()
  for header in "${headersArray[@]}"; do
    checklist_options+=(FALSE "$header")
  done

  echo "------------------ after debugging -----------------"
  echo "$headersString"
  echo "------------------ debugging -----------------"

  specifiedColumns=$(zenity --list --width=300 --height=250  \
    --title="Columns" \
    --text="Choose the Columns you want to select :" \
    --checklist \
    --column="Check" \
    --column="Column" \
    "${checklist_options[@]}")

  echo "------------------ debugging -----------------"
  echo "$specifiedColumns"
  echo "------------------ debugging -----------------"


  if [ -z "$specifiedColumns" ]; then
    zenity --error --text="No columns selected. Exiting function."
    return
  fi

  IFS='|' read -r -a selectedColumnsArray <<< "$specifiedColumns"
  
  awkCommand=""
  selectedHeaders=""
  columns=()


  echo "------------------ debugging -----------------"
  echo "${selectedColumnsArray[@]}" # id last name salary
  echo "------------------ debugging -----------------"

  for ((i = 0; i < ${#headersArray[@]}; ++i)); do
      for selectedHeader in "${selectedColumnsArray[@]}"; do
          if [[ "${headersArray[i]}" == "$selectedHeader" ]]; then
              columns+=(--column="$selectedHeader")
              columnNumber=$((i + 1)) 
              if [ -z "$awkCommand" ]; then
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
  done < <(awk -F ":" "{print $awkCommand}" "$dataFile")

  echo "------------------ debugging -----------------"
  echo "${result[@]}" 
  echo "------------------ debugging -----------------"

  if [ -z "$result" ]; then
    zenity --error --text="No data found for the selected columns."
  else
    zenity --list \
    --title="Table Data" \
    --height=400 --width=600 \
    "${columns[@]}" \
    "${result[@]}"
  fi
}
