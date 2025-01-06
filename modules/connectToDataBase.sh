function connectToDataBase() {
  # First load the avilable databases
  loadDataBases

  local dataBase=$(zenity --entry --title="Connect to Database" --text="Enter the name of the database you want to connect to:" --entry-text="" --height=150 --width=400)

  # Check if the input is empty
  if isEmpty "$dataBase"
  then
    zenity --error --title="Error" --text="Database name cannot be empty.\nTip: A valid database name should contain at least one character." --height=150 --width=400
    return
  fi

  # Check if the database name starts with a special character or number
  if isStartWithChars "$dataBase"
  then
    zenity --error --title="Error" --text="Database name cannot start with a number or special character.\nTip: Use alphabetic characters or underscores (_) at the beginning." --height=150 --width=400
    return
  fi

  # Check if the database exists
  if ! isAlreadyExists -d "$dataBase"
  then
    zenity --error --title="Error" --text="Error: Database '$dataBase' does not exist." --height=150 --width=400
    return
  fi

  # If all checks pass, connect to the database
  zenity --info --title="Connecting" --text="Connecting to database '$dataBase'..." --height=150 --width=400

  # Show a success message
  zenity --info --title="Success" --text="Successfully connected to '$dataBase'." --height=150 --width=400

  CONNECTED_DB="$dataBase"
  # call manageDataBase function
  manageDataBase

  # echo "-------------- debugging --------------"
  # echo "dataBase $CONNECTED_DB has been disconnectd successfully."
  # echo "-------------- debugging --------------"
  # DisconnectDB
  CONNECTED_DB=""
}
