#!/bin/bash

# This is the group project shell script for Group 21.
# Authors:
# Kacper Manachiewicz, Abdul Kareem, Hanzalah Mohd Farid, Muhammad Rauf
# The purpose of this script is to generate a new password for an account based on desired complexity and save it securely to a file.
# And to show already generated passwords and confirm if they are still secure or if they have been compromised.

# Ask user to select between generating new password or viewing already created password
echo "Select option:"
echo "1. Generate new password"
echo "2. View saved password"

read mode

# Error case
while [[ "$mode" != "1" &&
         "$mode" != "2" ]]
do
    echo "Invalid mode. Please enter 1 or 2."
    read mode
done

# Password generation mode
if [[ "$mode" -eq 1 ]]
then
    # Ask user for password name 
    echo "Type password name: (no spaces or special characters)"
    read passwordname

    # Error case
    while [[ ! "$passwordname" =~ ^[a-zA-Z0-9._-]+$ ]] ||
          [[ -f "$passwordname".txt ]]
    do
        echo "Invalid password name. Password already exists or avoid spaces and special characters."
        echo "Type password name: (no spaces or special characters)"
        read passwordname
    done

    # Ask user for password length
    echo "Enter the password length (8-64):"
    read password_length

    # Validate password length
    while   [[ ! "$password_length" =~ ^[0-9]+$ ]] ||
            [[ "$password_length" -lt 8 ]] ||
            [[ "$password_length" -gt 64 ]]
    do
        echo "Invalid length. Please enter a number between 8 and 64:"
        echo "Enter the password length:"
        read password_length
    done

    # Ask user for complexity
    echo "Choose password complexity:"
    echo "1. Low - Lowercase letters"
    echo "2. Medium - Uppercase, lowercase and numbers"
    echo "3. High - Uppercase, lowercase, numbers and symbols"

    read complexity
    
    # Validate complexity choice
    while [[    "$complexity" != "1" &&
                "$complexity" != "2" &&
                "$complexity" != "3" ]]
    do
        echo "Invalid choice. Please select 1, 2 or 3:"
        read complexity
    done

    # Set character options
    if [[ "$complexity" -eq 1 ]]
    then
        use_lower=1
        use_upper=0
        use_numbers=0
        use_symbols=0

    elif [[ "$complexity" -eq 2 ]]
    then
        use_lower=1
        use_upper=1
        use_numbers=1
        use_symbols=0

    elif [[ "$complexity" -eq 3 ]]
    then
        use_lower=1
        use_upper=1
        use_numbers=1
        use_symbols=1
    fi


    # Set allowed characters
    allowed_characters=""

    if [[ "$use_lower" -eq 1 ]]
    then
        allowed_characters="${allowed_characters}abcdefghijklmnopqrstuvwxyz"
    fi

    if [[ "$use_upper" -eq 1 ]]
    then
        allowed_characters="${allowed_characters}ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    fi

    if [[ "$use_numbers" -eq 1 ]]
    then
        allowed_characters="${allowed_characters}0123456789"
    fi

    if [[ "$use_symbols" -eq 1 ]]
    then
        allowed_characters="${allowed_characters}!@#$%^&*"
    fi

    # Generate the password
    password=""

    while [ "${#password}" -lt "$password_length" ]
    do
        random_number=$((RANDOM % ${#allowed_characters}))
        selected_character=${allowed_characters:"$random_number":1}
        password="$password$selected_character"
    done

    # Create file based on password name
    touch "$passwordname".txt
    # Save password to password name file
    printf "%s\n" "$password" > "$passwordname".txt
    # Create hash file for generated password file
    sha256sum "$passwordname".txt > "$passwordname"hash.txt

    # Display the generated password
    echo "Generated password: $password"
    exit 0
fi

# Password viewing mode
if [[ "$mode" -eq 2 ]]
then
    echo "Enter what password you wish to view"
    read savedpassword

    # Error case
    while [[ ! -f "$savedpassword".txt ]]
    do
        echo "Error: File does not exist"
        echo "Please enter valid file name"
        read savedpassword
    done

    # Check if password is secure and display password    
    if sha256sum -c "$savedpassword"hash.txt | grep -q -w "OK"
    then
        echo "Password is secure"
        cat "$savedpassword".txt
        exit 1
    else
        echo "Password is compromised!"
        cat "$savedpassword".txt
        exit 2
    fi
fi
