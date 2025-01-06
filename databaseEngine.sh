#!/usr/bin/bash 
shopt -s extglob

function printMenu() {
  # local -a menu=("$@")
  # local -i menuLen=${#menu[@]}

  local -a menuElements=(
    "Create Database"
    "List Database"
    "Connect To Database"
    "Drop Database"
    "Exit"
  )
  
  # Zenity option menu
  choice=$(zenity --list --title="Database Engine" --column="Options" "${menuElements[@]}" --height=250)

  case $choice in 
    "Create Database") 
      createDataBase 
      break ;;
    "List Database") 
      listDataBases 
      break ;;
    "Connect To Database") 
      connectToDataBase
      break ;;
    "Drop Database") 
      dropDataBase 
      break ;;
    "Exit") 
      zenity --info --text="Exiting..."
      exit 0 ;;
    *) zenity --error --text="Invalid option. Please try again." ;;
  esac
}

# Now modulesArray is well known variable in your current running shell
function loadModules(){
  echo "loadModules was called successfully."
  readarray -t modulesArray <<< $(ls ./modules)

  for mod in "${modulesArray[@]}"
  do
    echo "$mod has been loaded successfully."
    source "./modules/$mod"
  done
}


function run() {
  # Load the required modules
  loadModules

  # Make sure the directory exists
  if ! isAlreadyExists -m; then
    mkdir -p "$HOME/DBMS"
  fi

  # Setting the database variable path
  DB_PATH="$HOME/DBMS"

  # Load current existing databases at "$DATABASES"
  loadDataBases

  # Current connected database
  CONNECTED_DB=""

  # Display the menu
  while true; do
    printMenu
  done
}

# Help message
function showHelp() {
  zenity --info --text="Usage: $0 [OPTIONS]

This script provides a menu-driven interface for database operations.

Options:
  --help          Show this help message.
  start           Starts and display the menu, and allow user to select an option.

Database Operations:
  1) Create Database
  2) List Database
  3) Connect To Database
  4) Drop Database
  5) Exit

After selecting an option, the appropriate action will be performed."
}

# Handle command-line options
if [ "$1" == "--help" ]; then
  showHelp
  exit 0
elif [ "$1" == "start" ]; then
  figlet "DataBase Engine"
  run
else
  zenity --error --text="Error: No arguments provided.
Usage: ./databaseEngine.sh [start|--help]"
  exit 1
fi
