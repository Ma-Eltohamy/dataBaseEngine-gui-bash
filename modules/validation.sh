function isAlreadyExists(){
  local flag="$1"
  local dataBaseName="$2"
  local tableName="$3"

  case "$flag" in
    -m)
      if [[ -d "$DB_PATH" ]]
      then
        return 0  # Success
      fi;;
    -d)
      if [[ -d "$DB_PATH/$dataBaseName" ]]
      then
        return 0  # Success
      fi;;
    -t)
      local dataFile="$DB_PATH/$dataBaseName/$tableName.data"
      local metaFile="$DB_PATH/$dataBaseName/$tableName.meta"

      if [[ -f "$dataFile" || -f "$metaFile" ]]
      then
        return 0  # Success
      fi;;
    *)
      echo "Error: Invalid flag provided. Use -m, -d, or -t."
      return 1  # Failure
  esac

  return 1  # Failure
}

function isEmpty(){
  local userInput="$@"  # Treat all given parameters as a single string

  # Check if the input is empty
  if [[ -z "$userInput" ]]
  then
    return 0  # Success
  fi
  return 1  # Failure
}

function isStartWithChars() {
  local userInput="$@"  # Treat the given parameters as one entity

  if [[ "$userInput" =~ ^[^a-zA-Z] ]]
  then
    return 0  # Success: Starts with a number or special character
  fi
  return 1  # Failure: Does not start with a number or special character
}
