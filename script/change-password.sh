#!/bin/bash
# Script to change a user's password in the Advent Calendar application
# Usage: ./script/change-password.sh

set -e # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

echo "=== Advent Calendar - Change Password ==="
echo ""

# Prompt for user email
read -p "Enter email address: " EMAIL
if [ -z "$EMAIL" ]; then
  echo "Error: Email cannot be empty"
  exit 1
fi

# Validate email format (basic check)
if ! echo "$EMAIL" | grep -qE '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'; then
  echo "Error: Invalid email format"
  exit 1
fi

# Prompt for new password
read -sp "Enter new password: " PASSWORD
echo ""
if [ -z "$PASSWORD" ]; then
  echo "Error: Password cannot be empty"
  exit 1
fi

# Prompt for password confirmation
read -sp "Confirm new password: " PASSWORD_CONFIRM
echo ""
if [ "$PASSWORD" != "$PASSWORD_CONFIRM" ]; then
  echo "Error: Passwords do not match"
  exit 1
fi

# Check password length
if [ ${#PASSWORD} -lt 8 ]; then
  echo "Error: Password must be at least 8 characters long"
  exit 1
fi

echo ""
echo "Checking if user exists..."

# Check if user exists and change password
bin/rails runner "
user = User.find_by(email: '$EMAIL')
if user.nil?
  puts 'Error: User not found with email: $EMAIL'
  exit 1
end

user.password = '$PASSWORD'
user.password_confirmation = '$PASSWORD'

if user.save
  puts 'Success! Password changed for user: $EMAIL'
  exit 0
else
  puts 'Error: Failed to change password'
  user.errors.full_messages.each { |msg| puts \"  - #{msg}\" }
  exit 1
end
"
