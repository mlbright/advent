#!/bin/bash
# Script to add a user to the Advent Calendar application
# Usage: ./scripts/add-user.sh

set -e # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== Advent Calendar - Add User ==="
echo ""

# Prompt for user details
read -p "Enter email address: " EMAIL
if [ -z "$EMAIL" ]; then
  echo "Error: Email cannot be empty"
  exit 1
fi

# Validate email format (basic check)
if ! echo "$EMAIL" | grep -qE '^[^@]+@[^@]+\.[^@]+$'; then
  echo "Error: Invalid email format"
  exit 1
fi

# Prompt for password
while true; do
  read -sp "Enter password: " PASSWORD
  echo ""
  if [ -z "$PASSWORD" ]; then
    echo "Error: Password cannot be empty"
    continue
  fi

  read -sp "Confirm password: " PASSWORD_CONFIRM
  echo ""

  if [ "$PASSWORD" = "$PASSWORD_CONFIRM" ]; then
    break
  else
    echo "Error: Passwords do not match. Please try again."
  fi
done

# Prompt for admin status
read -p "Make this user an admin? (y/N): " IS_ADMIN
if [[ "$IS_ADMIN" =~ ^[Yy]$ ]]; then
  ADMIN="true"
else
  ADMIN="false"
fi

echo ""
echo "Creating user with:"
echo "  Email: $EMAIL"
echo "  Admin: $ADMIN"
echo ""

# Create the user using Rails console
../bin/rails runner "
begin
  user = User.create!(
    email: '$EMAIL',
    password: '$PASSWORD',
    password_confirmation: '$PASSWORD',
    admin: $ADMIN
  )
  puts \"✓ User created successfully!\"
  puts \"  ID: #{user.id}\"
  puts \"  Email: #{user.email}\"
  puts \"  Admin: #{user.admin}\"
rescue ActiveRecord::RecordInvalid => e
  puts \"✗ Error creating user:\"
  puts \"  #{e.message}\"
  exit 1
rescue => e
  puts \"✗ Unexpected error:\"
  puts \"  #{e.message}\"
  exit 1
end
"

if [ $? -eq 0 ]; then
  echo ""
  echo "User can now log in at http://localhost:3000/login"
else
  echo ""
  echo "Failed to create user. Please check the error above."
  exit 1
fi
