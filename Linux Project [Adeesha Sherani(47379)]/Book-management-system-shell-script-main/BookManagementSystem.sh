#!/bin/bash

# Files to store data
BOOK_FILE="./books.txt"
LOG_FILE="./log.txt"

# Define colors
RESET="\033[0m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
CYAN="\033[36m"



# Ensure necessary files exist
[[ ! -f "$BOOK_FILE" ]] && touch "$BOOK_FILE"
[[ ! -f "$LOG_FILE" ]] && touch "$LOG_FILE"

# Function to log actions
log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" >> "$LOG_FILE"
}

# Function to authenticate admin
admin_login() {
    clear
    echo -e "${CYAN}--- Admin Login ---${RESET}"
    echo -n "Enter admin password: "
    read -s entered_password  # Read password in silent mode

    if [[ "$entered_password" == "$ADMIN_PASSWORD" ]]; then
        echo -e "${GREEN}Login successful! Welcome, Admin.${RESET}"
        admin_menu  # Call admin menu function after successful login
    else
        echo -e "${RED}Incorrect password! Access denied.${RESET}"
    fi
    echo -e "${YELLOW}Press Enter to continue...${RESET}"
    read


}




# Admin Functions

# Function to add a book
add_book() {
    clear
    echo -e "${CYAN}--- Add a New Book ---${RESET}"
    echo -n "Book Number: "
    read book_number
    echo -n "Book Name: "
    read book_name
    echo -n "Author Name: "
    read author_name
    echo -n "Number of Copies: "
    read num_copies
    echo -n "Price of the Book: "
    read book_price

    if [[ -n "$book_number" && -n "$book_name" && -n "$author_name" && "$num_copies" =~ ^[0-9]+$ && "$book_price" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        echo "$book_number|$book_name|$author_name|$num_copies|$book_price" >> "$BOOK_FILE"
        echo -e "${GREEN}Book added successfully!${RESET}"
        log_action "Added book: $book_number - $book_name by $author_name ($num_copies copies)"
    else
        echo -e "${RED}Invalid input. Please try again.${RESET}"
    fi
    echo -e "${YELLOW}Press Enter to continue...${RESET}"
    read
}

# Function to modify a book
modify_book() {
    clear
    echo -e "${CYAN}--- Modify a Book ---${RESET}"
    echo -n "Enter the book number to modify: "
    read modify_number
    if grep -q "^$modify_number|" "$BOOK_FILE"; then
        grep -v "^$modify_number|" "$BOOK_FILE" > temp.txt && mv temp.txt "$BOOK_FILE"
        echo "Enter new details for the book:"
        add_book
        log_action "Modified book: $modify_number"
    else
        echo -e "${RED}Book not found!${RESET}"
    fi
    echo -e "${YELLOW}Press Enter to continue...${RESET}"
    read
}

# Function to delete a book
delete_book() {
    clear
    echo -e "${CYAN}--- Delete a Book ---${RESET}"
    echo -n "Enter the book number to delete: "
    read delete_number
    if grep -q "^$delete_number|" "$BOOK_FILE"; then
        grep -v "^$delete_number|" "$BOOK_FILE" > temp.txt && mv temp.txt "$BOOK_FILE"
        echo -e "${GREEN}Book deleted successfully!${RESET}"
        log_action "Deleted book: $delete_number"
    else
        echo -e "${RED}Book not found!${RESET}"
    fi
    echo -e "${YELLOW}Press Enter to continue...${RESET}"
    read
}

# Function to backup data
backup_data() {
    BACKUP_FILE="./backup_books_$(date +%F_%T).txt"
    cp "$BOOK_FILE" "$BACKUP_FILE"
    echo -e "${GREEN}Data backed up to $BACKUP_FILE${RESET}"
    log_action "Backup created: $BACKUP_FILE"
    echo -e "${YELLOW}Press Enter to continue...${RESET}"
    read
}

# Function to restore data
restore_data() {
    clear
    echo -e "${CYAN}--- Restore Data ---${RESET}"
    echo "Available backup files:"
    ls backup_books_*.txt 2>/dev/null
    echo -n "Enter the backup file name to restore: "
    read restore_file
    if [[ -f "$restore_file" ]]; then
        cp "$restore_file" "$BOOK_FILE"
        echo -e "${GREEN}Data restored from $restore_file${RESET}"
        log_action "Data restored from: $restore_file"
    else
        echo -e "${RED}Backup file not found!${RESET}"
    fi
    echo -e "${YELLOW}Press Enter to continue...${RESET}"
    read
}

# Function to count books
count_books() {
    clear
    echo -e "${CYAN}--- Count Books ---${RESET}"
    if [[ -s "$BOOK_FILE" ]]; then
        total_books=$(awk -F"|" '{sum+=$4} END {print sum}' "$BOOK_FILE")
        unique_books=$(wc -l < "$BOOK_FILE")
        echo -e "${YELLOW}Total number of copies:${RESET} $total_books"
        echo -e "${YELLOW}Total unique books:${RESET} $unique_books"
        log_action "Counted books: Total copies=$total_books, Unique books=$unique_books"
    else
        echo -e "${RED}No books found!${RESET}"
    fi
    echo -e "${YELLOW}Press Enter to continue...${RESET}"
    read
}

display_all_books() {
    clear
    echo -e "${CYAN}--- Display All Books ---${RESET}"
    
    if [[ -s "$BOOK_FILE" ]]; then
        # Print the headings with fixed width
        printf "%-15s %-40s %-30s %-10s %-10s\n" "Book Number" "Book Name" "Author Name" "Copies" "Price"
        echo -e "${BLUE}------------------------------------------------------------------------------------------------------------${RESET}"
        
        # Loop through the book list and print each book's details with fixed-width formatting
        while IFS="|" read -r book_number book_name author_name num_copies book_price; do
            printf "%-15s %-40s %-30s %-10s %-10s\n" "$book_number" "$book_name" "$author_name" "$num_copies" "$book_price"
        done < "$BOOK_FILE"
    else
        echo -e "${RED}No books found!${RESET}"
    fi
    
    log_action "Displayed all books"
    echo -e "${YELLOW}Press Enter to continue...${RESET}"
    read
}
# User Functions

# Function to display all books
display_books() {
    clear
    echo -e "${CYAN}--- Display All Books ---${RESET}"
    if [[ -s "$BOOK_FILE" ]]; then
        # Print the headings
        printf "%-15s %-30s %-30s %-10s %-10s\n" "Book Number" "Book Name" "Author Name" "Copies" "Price"
           echo -e "${BLUE}--------------------------------------------------------------------------------------------------${RESET}"

        
        # Loop through the book list and print each book's details
        while IFS="|" read -r book_number book_name author_name num_copies book_price; do
            printf "%-15s %-30s %-30s %-10s %-10s\n" "$book_number" "$book_name" "$author_name" "$num_copies" "$book_price"
        done < "$BOOK_FILE"
    else
        echo -e "${RED}No books found!${RESET}"
    fi
    log_action "Displayed all books"
    echo -e "${YELLOW}Press Enter to continue...${RESET}"
    read
}

# Function to search for a book
search_book() {
    clear
    echo -e "${CYAN}--- Search for a Book ---${RESET}"
    echo -n "Enter the book number to search: "
    read search_number
    if grep -q "^$search_number|" "$BOOK_FILE"; then
        grep "^$search_number|" "$BOOK_FILE" | while IFS="|" read -r book_number book_name author_name num_copies book_price; do
            echo -e "${YELLOW}Book Number:${RESET} $book_number"
            echo -e "${YELLOW}Book Name:${RESET} $book_name"
            echo -e "${YELLOW}Author Name:${RESET} $author_name"
            echo -e "${YELLOW}Number of Copies:${RESET} $num_copies"
            echo -e "${YELLOW}Price:${RESET} $book_price"
        done
        log_action "Searched for book: $search_number"
    else
        echo -e "${RED}Book not found!${RESET}"
    fi
    echo -e "${YELLOW}Press Enter to continue...${RESET}"
    read
}

# Function to purchase a book
purchase_book() {
    clear
    echo "Enter the book number you want to purchase:"
    read book_number

    if grep -q "^$book_number|" "$BOOK_FILE"; then
        echo "Book found!"
        # Get book details from the file
        book_name=$(grep "^$book_number|" "$BOOK_FILE" | cut -d'|' -f2)
        author_name=$(grep "^$book_number|" "$BOOK_FILE" | cut -d'|' -f3)
        remaining_copies=$(grep "^$book_number|" "$BOOK_FILE" | cut -d'|' -f4)
        price=$(grep "^$book_number|" "$BOOK_FILE" | cut -d'|' -f5)

    

        if [[ ! "$price" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    echo -e "${RED}Invalid or missing price for this book.${RESET}"
    return
fi

        declare -i remaining_copies=$remaining_copies
        echo -e "Enter the number of copies to purchase:"
        read purchase_quantity

        if [[ "$purchase_quantity" =~ ^[0-9]+$ ]] && [ "$purchase_quantity" -le "$remaining_copies" ] && [ "$purchase_quantity" -gt 0 ]; then
            # Update the book quantity after purchase
            grep -v "^$book_number|" "$BOOK_FILE" > temp.txt
            echo "$book_number|$book_name|$author_name|$((remaining_copies - purchase_quantity))|$price" >> temp.txt
            mv temp.txt "$BOOK_FILE"

            # Calculate total price
            total_price=$(echo "$price * $purchase_quantity" | bc)

            # Debugging total price
            echo "Total price: $total_price"  # Check total price calculation

            # Create a bill file
            BILL_FILE="./bill_$(date +%F_%T).txt"
            echo -e "------ Purchase Bill ------" > "$BILL_FILE"
            echo -e "Book Number: $book_number" >> "$BILL_FILE"
            echo -e "Book Name: $book_name" >> "$BILL_FILE"
            echo -e "Author Name: $author_name" >> "$BILL_FILE"
            echo -e "Quantity: $purchase_quantity" >> "$BILL_FILE"
            echo -e "Price per copy: $price" >> "$BILL_FILE"
            echo -e "Total Price: $total_price" >> "$BILL_FILE"
            echo -e "---------------------------" >> "$BILL_FILE"
           

            clear
            echo -e "${GREEN}Purchase successful!${RESET}"
            echo -e "Your bill is saved as $BILL_FILE"
            log_action "Purchased $purchase_quantity copies of $book_name, Total Price: $total_price"
        else
            echo -e "${RED}Invalid quantity! Please enter a valid quantity (positive and less than or equal to remaining copies).${RESET}"
        fi
    else
        echo -e "${RED}Book not found!${RESET}"
    fi

    echo -e "${YELLOW}Press Enter to return to main menu...${RESET}"
    read
}



# Main Admin Menu
admin_menu() {
    while true; do
        clear
        echo -e "${CYAN}--- Admin Panel ---${RESET}"
         
        echo -e "${YELLOW}1.${RESET} Add Book"
        echo -e "${YELLOW}2.${RESET} Modify Book"
        echo -e "${YELLOW}3.${RESET} Delete Book"
        echo -e "${YELLOW}4.${RESET} Backup Data"
        echo -e "${YELLOW}5.${RESET} Restore Data"
        echo -e "${YELLOW}6.${RESET} Display All Books"
        echo -e "${YELLOW}7.${RESET} Count Books"
        echo -e "${YELLOW}8.${RESET} Logout"
        echo -n "Enter your choice: "
        read admin_choice
        case $admin_choice in
            1) add_book ;;
            2) modify_book ;;
            3) delete_book ;;
            4) backup_data ;;
            5) restore_data ;;
            6) display_all_books ;;
            7) count_books ;;
            8) log_action "Admin logged out"; break ;;
            *) echo -e "${RED}Invalid choice! Try again.${RESET}";;
        esac
    done
}



# Main User Menu
user_menu() {
    while true; do
        clear
        echo -e "${CYAN}--- User Panel ---${RESET}"
        echo -e "${YELLOW}1.${RESET} Display All Books"
        echo -e "${YELLOW}2.${RESET} Search for a Book"
        echo -e "${YELLOW}3.${RESET} Purchase a Book"
        echo -e "${YELLOW}4.${RESET} Logout"
        echo -n "Enter your choice: "
        read user_choice
        case $user_choice in
            1) display_books ;;
            2) search_book ;;
            3) purchase_book ;;
            4) log_action "User logged out"; break ;;
            *) echo -e "${RED}Invalid choice! Try again.${RESET}";;
        esac
    done
}

# Main Login Menu
main_menu() {
    while true; do
        clear
        echo -e "${CYAN}--- Welcome to Book Shop Management System ---${RESET}"
        echo -e "${YELLOW}1.${RESET} Admin Login"
        echo -e "${YELLOW}2.${RESET} User Login"
        echo -e "${YELLOW}3.${RESET} Exit"
        echo -n "Enter your choice: "
        read main_choice
        case $main_choice in
            1) admin_menu ;;
            2) user_menu ;;
            3) log_action "System exited"; echo -e "${GREEN}Goodbye!${RESET}"; exit 0 ;;
            *) echo -e "${RED}Invalid choice! Try again.${RESET}";;
        esac
    done
}

# Start the system
main_menu