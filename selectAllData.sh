function selectAllData(){
  dataFile=$1
  headersString=$2

  echo "-------------- debuggin ----------------"
  echo "$headersString"
  echo "-------------- debuggin ----------------"
  # Split headers into individual columns for Zenity
  # readarray -t headersArray <<< "$headersString" # we won't use this 
  
  IFS=':' read -r -a headersArray <<< "$headersString"

  echo "-------------- debuggin ----------------"
  echo "${headersArray[@]}"
  echo "-------------- debuggin ----------------"
  # Prepare column arguments for Zenity
  columns=()
  for header in "${headersArray[@]}"; do
    columns+=(--column="$header")
  done

  echo "-------------- debuggin ----------------"
  echo "${columns[@]}"
  echo "-------------- debuggin ----------------"

  # Prepare data array dynamically from the table rows
  data=()
  while IFS= read -r line; do
    IFS=':' read -r -a row <<< "$line"
    data+=("${row[@]}")
    echo "-------------- debuggin ----------------"
    echo "${data[@]}"
    echo "-------------- debuggin ----------------"
  done < "$dataFile"

  zenity --list \
    --title="Table Data" \
    --height=400 --width=600 \
    "${columns[@]}" \
    "${data[@]}"
}
