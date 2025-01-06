function createDataBase() {
  # Prompt for the database name using Zenity
  local dataBaseName=$(zenity --entry --title="Create Database" --text="Enter the database name:" --entry-text="" --height=150 --width=400)

  # Check if the input is empty
  if isEmpty "$dataBaseName"
  then
    zenity --error --title="Error" --text="Database name cannot be empty.\nTip: A valid database name should contain at least one character." --height=150 --width=400
    return
  fi

  # Check if the database name starts with a special character or number
  if isStartWithChars "$dataBaseName"
  then
    zenity --error --title="Error" --text="Database name cannot start with a number or special character.\nTip: Use alphabetic characters or underscores (_) at the beginning." --height=150 --width=400
    return
  fi

  # Check if the database already exists
  if isAlreadyExists -d "$dataBaseName"; then
    zenity --warning --title="Warning" --text="The database '$dataBaseName' already exists.\nTip: Use a different name or proceed to modify the existing database." --height=150 --width=400
    return
  fi

  # Create the database directory
  mkdir -p "$DB_PATH/$dataBaseName"
  
  # Show success message
  zenity --info --title="Success" --text="Database '$dataBaseName' has been created successfully!" --height=150 --width=400
}
