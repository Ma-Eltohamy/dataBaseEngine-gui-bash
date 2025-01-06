function selectAllData(){
  # Prepare column arguments for Zenity
  local columns=()
  for header in "${headersArray[@]}"
  do
    columns+=(--column="$header")
  done

  local data=()
  # -r to treat \ as special cahr not as a esacpe char
  while IFS= read -r line # While you can read lines from "$dataFile"
  do
    IFS=':' read -r -a row <<< "$line"
    data+=("${row[@]}")
  done < "$dataFile"

  zenity --list \
    --title="Table Data" \
    --height=400 --width=600 \
    "${columns[@]}" \
    "${data[@]}"
}
