function connectToDataBase() {
  # Prompt for the database name using Zenity
  DATABASENAME=$(zenity --entry --title="Connect to Database" --text="Enter the name of the database you want to connect to:" --entry-text="" --height=150 --width=400)

  # Check if the input is empty
  if [ -z "$DATABASENAME" ]; then
    zenity --error --title="Error" --text="Database name cannot be empty.\nTip: A valid database name should contain at least one character." --height=150 --width=400
    return
  fi

  # Check if the database name starts with a special character or number
  if [[ "$DATABASENAME" =~ ^[^a-zA-Z_] ]]; then
    zenity --error --title="Error" --text="Database name cannot start with a number or special character.\nTip: Use alphabetic characters or underscores (_) at the beginning." --height=150 --width=400
    return
  fi

  # Check if the database exists
  if ! isAlreadyExists -d "$DATABASENAME"; then
    zenity --error --title="Error" --text="Error: Database '$DATABASENAME' does not exist." --height=150 --width=400
    return
  fi

  # If all checks pass, connect to the database
  zenity --info --title="Connecting" --text="Connecting to database '$DATABASENAME'..." --height=150 --width=400
  cd "$HOME/DBMS/$DATABASENAME"

  # Show a success message
  zenity --info --title="Success" --text="Successfully connected to '$DATABASENAME'." --height=150 --width=400

  # Call manageDataBase function
  manageDataBase "$DATABASENAME"
}
