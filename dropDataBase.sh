function dropDataBase() {
  local dataBaseDir="$HOME/DBMS"

  # Check if there are any databases in the directory
  if [ -z "$(ls -1 "$dataBaseDir")" ]; then
    zenity --error --title="Error" --text="No databases found. Cannot drop a database." --height=150 --width=400
    return
  fi

  # Prompt for the database name to drop using Zenity
  dataBaseName=$(zenity --entry --title="Drop Database" --text="Enter the name of the database you want to drop:" --entry-text="" --height=150 --width=400)

  if [ -z "$dataBaseName" ]; then
    zenity --error --title="Error" --text="Database name cannot be empty.\nTip: A valid database name should contain at least one character." --height=150 --width=400
    return
  fi

  if isStartWithChars "$dataBaseName"; then
    zenity --error --title="Error" --text="Database name cannot start with a number or special character.\nTip: Use alphabetic characters or underscores (_) at the beginning." --height=150 --width=400
    return
  fi

  if ! isAlreadyExists -d "$dataBaseName"; then
    zenity --error --title="Error" --text="Error: Database '$dataBaseName' does not exist." --height=150 --width=400
    return
  fi

  # Confirm the action before proceeding
  confirmation=$(zenity --question --title="Confirm Deletion" --text="Are you sure you want to permanently delete the database '$dataBaseName'?" --height=150 --width=400)

  if [[ $? -eq 0 ]]; then
    rm -rf "$dataBaseDir/$dataBaseName"  # Remove the entire database directory and its contents
    zenity --info --title="Success" --text="Database '$dataBaseName' has been successfully deleted." --height=150 --width=400
  else
    zenity --info --title="Deletion Canceled" --text="Action canceled. Database '$dataBaseName' was not deleted." --height=150 --width=400
  fi
}
