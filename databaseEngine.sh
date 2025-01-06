#!/usr/bin/bash 
shopt -s extglob

function printMenu() {
  local -a menu=("$@")
  local -i menuLen=${#menu[@]}

  # Zenity option menu
  choice=$(zenity --list --title="Database Engine" --column="Options" "${menu[@]}" --height=250)

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

function run() {
  source ./connectToDataBase.sh
  source ./createDataBase.sh
  source ./createTable.sh
  source ./deleteFromTable.sh
  source ./dropDataBase.sh
  source ./dropTable.sh
  source ./insertIntoTable.sh
  source ./listDataBases.sh
  source ./listTables.sh
  source ./manageDataBase.sh
  source ./selectFromTable.sh
  source ./selectAllData.sh
  source ./selectByCondition.sh
  source ./selectByPrimaryKey.sh
  source ./selectSpecificColumns.sh
  source ./sortData.sh
  source ./updateRowInTable.sh
  source ./validation.sh


  # Make sure the directory exists
  if ! isAlreadyExists -m; then
    mkdir -p "$HOME/DBMS"
  fi

  # Menu elements
  local -a menuElements=(
    "Create Database"
    "List Database"
    "Connect To Database"
    "Drop Database"
    "Exit"
  )

  # Display the menu
  while true; do
    printMenu "${menuElements[@]}"
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
