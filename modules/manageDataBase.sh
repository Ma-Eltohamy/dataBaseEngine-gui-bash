function manageDataBase() {
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
        selectedOption=$(zenity --list --title="Manage Database: $CONNECTED_DB" --column="Operations" "${options[@]}" --height=300 --width=400)

        if isEmpty "$selectedOption"
        then
            echo "No operation selected, exiting."
            return 0
        fi

        case "$selectedOption" in
            "Create Table")
                createTable
                ;;

            "List Tables")
                listTables
                ;;

            "Drop Table")
                dropTable
                ;;

            "Insert into Table")
                insertIntoTable
                ;;

            "Select From Table")
                selectFromTable
                ;;

            "Delete From Table")
                deleteFromTable
                ;;

            "Update Row")
                updateRowInTable
                ;;

            "Exit")
                echo "Exiting table operations."
                break ;;
            *)
                echo "Invalid option, please try again."
                ;;
        esac
    done
}
