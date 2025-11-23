#!/bin/bash
# Script to delete a user from the Advent Calendar application
# Usage: ./scripts/delete-user.sh

set -e # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== Advent Calendar - Delete User ==="
echo ""

# Prompt for email address
read -p "Enter email address of user to delete: " EMAIL
if [ -z "$EMAIL" ]; then
  echo "Error: Email cannot be empty"
  exit 1
fi

# Validate email format (basic check)
if ! echo "$EMAIL" | grep -qE '^[^@]+@[^@]+\.[^@]+$'; then
  echo "Error: Invalid email format"
  exit 1
fi

echo ""
echo "⚠️  WARNING: This will permanently delete the user and all associated data."
echo "  Email: $EMAIL"
echo ""

# Confirm deletion
read -p "Are you sure you want to delete this user? (yes/NO): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
  echo "Deletion cancelled."
  exit 0
fi

echo ""

# Delete the user using Rails console
../bin/rails runner "
begin
  user = User.find_by(email: '$EMAIL')
  
  if user.nil?
    puts \"✗ User not found with email: $EMAIL\"
    exit 1
  end
  
  puts \"Found user:\"
  puts \"  ID: #{user.id}\"
  puts \"  Email: #{user.email}\"
  puts \"  Admin: #{user.admin}\"
  puts \"\"
  
  user.destroy!
  puts \"✓ User deleted successfully!\"
rescue ActiveRecord::RecordNotDestroyed => e
  puts \"✗ Error deleting user:\"
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
  echo "User has been deleted from the system."
else
  echo ""
  echo "Failed to delete user. Please check the error above."
  exit 1
fi
