function manageDataBase() {
    dataBaseName=$1

    local options=(
        "Create Table"
        "List Tables"
        "Drop Table"
        "Insert into Table"
        "Select From Table"
        "Delete From Table"
        "Update Row"
        "Exit"
    )

    while true
    do
        # Zenity dialog to show options
        selectedOption=$(zenity --list --title="Manage Database: $dataBaseName" --column="Operations" "${options[@]}" --height=300 --width=400)

        if [[ -z "$selectedOption" ]]; then
            echo "No operation selected, exiting."
            return 0
        fi

        case "$selectedOption" in
            "Create Table")
                createTable "$dataBaseName"
                break ;;

            "List Tables")
                listTables "$dataBaseName"
                break ;;

            "Drop Table")
                dropTable "$dataBaseName"
                break ;;

            "Insert into Table")
                insertIntoTable "$dataBaseName"
                break ;;

            "Select From Table")
                selectFromTable "$dataBaseName"
                break ;;

            "Delete From Table")
                deleteFromTable "$dataBaseName"
                break ;;

            "Update Row")
                updateRowInTable "$dataBaseName"
                break ;;

            "Exit")
                echo "Exiting table operations."
                return 0
                ;;

            *)
                echo "Invalid option, please try again."
                ;;
        esac
    done
}
