#!/bin/bash

region="ap-southeast-2"
table_name="notification-table"
json_file="$1"

# Check if a JSON file is provided
if [ -z "$json_file" ]; then
    echo "Error: JSON file path is required."
    exit 1
fi

# Check if the JSON file exists
if [ ! -f "$json_file" ]; then
    echo "Error: JSON file not found."
    exit 1
fi

# Read payload from JSON file
notification=$(cat "$json_file")

# Function to put notification entry
put_notification_entry() {
    local item="{"

    # Generate a random ID
    random_id=$((RANDOM % 10000 + 1))

    # Append the ID to the JSON object
    item+="\"id\": {\"S\": \"$random_id\"},"

    while IFS=":" read -r key value; do
        key=$(echo "$key" | tr -d '"' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
        value=$(echo "$value" | tr -d '"' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
        item+="\"$key\": {\"S\": \"$value\"},"
    done <<< "$(echo "$notification" | jq -r 'to_entries | .[] | "\(.key):\(.value)"')"

    item="${item%,}"
    item+="}"

    aws dynamodb put-item \
        --region "$1" \
        --table-name "$2" \
        --item "$item"
}

# Call the function
put_notification_entry "$region" "$table_name"
