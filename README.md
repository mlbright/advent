# Advent Calendar Application

A multi-tenant Rails 8.1 application for creating and sharing personalized advent calendars.

Inspired by Helen Bright.

## Features

- **User Authentication**: Secure login system with user management scripts
- **Multi-tenant Architecture**: Each user can create calendars for other users
- **24-Day Advent Calendars**: December 1-24 with rich content
- **Content Types**:
  - Images (uploaded or via URL)
  - Videos (uploaded or via URL with YouTube/Vimeo support)
  - Title and description text for each day
- **Flexible Content Sources**: Upload files directly or provide URLs for external content
- **Smart Unlocking**: Days unlock only in December based on the current date
- **Creator Preview Mode**: Calendar creators can view and edit all days year-round
- **View Tracking**: Track which days recipients have viewed
- **Year Scoping**: Create calendars for any year starting from 2025
- **One Calendar Per User-Year**: Each creator can only make one calendar per recipient per year
- **Calendar Shuffling**: Randomize the visual display order (position) of days (available until November 30th)
- **Day Swapping**: Exchange content between any two days in a calendar
- **File Management**: Upload images (max 10MB) and videos (max 100MB) with support for multiple formats

## Technology Stack

- **Rails 8.1.1** with Hotwire (Turbo + Stimulus)
- **SQLite3** database with Active Storage for file uploads
- **Eastern Time** zone
- **bcrypt** for authentication
- **Content Security Policy** configured for YouTube/Vimeo embeds

## Getting Started

### Prerequisites

- Ruby 3.x
- Rails 8.1.1
- SQLite3

### Installation

1. Install dependencies:
```bash
bundle install
```

2. Setup database:
```bash
bin/rails db:migrate
bin/rails db:seed
```

3. Start the server:
```bash
bin/rails server
```

4. Visit `http://localhost:3000`

### Sample Users

After running `db:seed`, you can log in with:

- **Admin**: `admin@example.com` / `password`
- **Alice**: `alice@example.com` / `password`
- **Bob**: `bob@example.com` / `password`

## Usage

### Managing Your Account

**Change Your Password:**

1. Log in to your account
2. Click "Change Password" in the navigation bar
3. Enter your current password
4. Enter your new password (minimum 6 characters)
5. Confirm your new password
6. Click "Update Password"

### Managing Users

The application includes convenient shell scripts for user management:

**Add a new user:**
```bash
./script/add-user.sh
```

**Change a user's password:**
```bash
./script/change-password.sh
```

**Delete a user:**
```bash
./script/delete-user.sh
```

Alternatively, you can manage users via Rails console:

```ruby
bin/rails console

# Create user
User.create!(
  email: 'user@example.com',
  password: 'secure_password',
  password_confirmation: 'secure_password'
)

# Change password
user = User.find_by(email: 'user@example.com')
user.password = 'new_password'
user.password_confirmation = 'new_password'
user.save!

# Delete user
user = User.find_by(email: 'user@example.com')
user.destroy
```

### Creating a Calendar

1. Log in as any user
2. Click "Create New Calendar"
3. Fill in:
   - Title (e.g., "My Christmas Adventure 2025")
   - Description/tagline (optional)
   - Select a recipient
   - Choose the year (2025+)
4. Submit to create calendar with 24 empty days

### Adding Content to Days

1. View your created calendar (as creator)
2. Click "Edit" on any day card
3. Select content type (Image or Video)
4. Choose one of two options:
   - **URL**: Paste a URL for YouTube, Vimeo, or direct image/video links
   - **Upload**: Upload an image or video file from your device
5. Add an optional title and description
6. Save the day

**Supported Formats:**
- **Images**: JPEG, PNG, GIF, WEBP (max 10MB)
- **Videos**: MP4, MOV, AVI, WEBM, OGG (max 100MB)
- **URLs**: YouTube, Vimeo, or direct links to media files

### Managing Calendar Days

**Shuffle Calendar** (Available until November 30th):
- Click "Shuffle All Days" button on calendar view
- Randomizes the visual position of days in the grid
- Each day keeps its original number and content
- Useful for surprising recipients with a non-sequential layout

**Swap Days**:
1. Click "Swap" button on a day card
2. Select which day to swap with
3. Preview both days' content
4. Confirm to exchange all content between the two days

**Delete Attachments**:
- Use "Delete Uploaded Image/Video" button on edit page
- Removes uploaded files while keeping other day data

### Viewing Calendars

**As Recipient:**
- Days unlock automatically in December when the date matches
- Click unlocked days to view content
- Locked days show a 🔒 icon
- Viewed days show a ✓ checkmark

**As Creator:**
- All days are unlocked year-round in "Creator Preview Mode"
- See which days have content vs. empty
- Edit any day at any time
- Shuffle calendar layout (until November 30th)
- Swap content between days
- Delete uploaded files

## URL Embedding and File Handling

The application supports both URL-based content and file uploads:

**Automatic URL Detection:**
- **YouTube**: `youtube.com/watch?v=...` or `youtu.be/...`
- **Vimeo**: `vimeo.com/123456`
- **Direct Media URLs**: URLs ending in supported image/video formats

**File Uploads:**
- **Images**: JPEG, JPG, PNG, GIF, WEBP (max 10MB)
- **Videos**: MP4, MOV, AVI, WEBM, OGG (max 100MB)
- Files stored using Active Storage with SQLite backend
- Automatic content type validation

**Content Rules:**
- Each day can have only one content source (URL or upload, not both)
- You can switch between URL and upload by editing the day
- Files can be deleted independently via the edit page

## Architecture

### Models

- **User**: Authentication with has_secure_password
- **Calendar**: Belongs to creator and recipient, has many calendar_days
- **CalendarDay**: 24 days per calendar (auto-generated on creation)
  - `day_number`: The actual day (1-24)
  - `display_position`: Visual position in grid (for shuffling)
  - `content_type`: 'image' or 'video'
  - `title`, `description`, `url`: Content metadata
  - Attachments: `image_file` and `video_file` via Active Storage
- **CalendarView**: Tracks which days recipients have viewed

### Key Business Logic

- `Calendar#day_unlocked_for?(day_number, user)`: Determines if a day is accessible
  - Creators: Always unlocked
  - Recipients: Only in December when `current_day >= day_number`

- `Calendar#can_shuffle?`: Checks if shuffling is allowed (until November 30th)

- `Calendar#shuffle_days`: Randomizes display_position of all days without changing content

- `CalendarDay#swap_with(other_day)`: Exchanges all content between two days
  - Swaps title, description, URL, content_type
  - Properly handles file attachment transfers
  - Uses transaction for atomicity

- `UrlEmbedder.embed(url, element_type)`: Converts URLs to embedded HTML
  - Extracts YouTube/Vimeo IDs
  - Generates responsive iframes
  - Handles images with proper sizing

### Security

- All routes require authentication except login
- Authorization checks on calendars (creator/recipient only)
- Content Security Policy allows YouTube/Vimeo iframes
- URL validation with HEAD requests to verify accessibility
- File upload validation (type and size limits)
- CSRF protection enabled
- Secure password hashing with bcrypt

## Customization

### Time Zone

The app uses Eastern Time. To change, edit `config/application.rb`:

```ruby
config.time_zone = "Your/Timezone"
```

### December-Only Unlocking

To allow testing year-round, modify `Calendar#day_unlocked_for?` in `app/models/calendar.rb`:

```ruby
def day_unlocked_for?(day_number, user)
  return true if creator == user
  # Remove month check for testing:
  Time.zone.now.day >= day_number
end
```

### Shuffle Deadline

The November 30th shuffle deadline is enforced in `Calendar#can_shuffle?`. To change or remove this deadline:

```ruby
def can_shuffle?
  # Option 1: Allow shuffling anytime
  true
  
  # Option 2: Use a different deadline
  current_date = Time.zone.now.to_date
  deadline = Date.new(year, 12, 15)  # Change to December 15
  current_date <= deadline
end
```

### File Upload Limits

To adjust file size limits, update `app/models/calendar_day.rb`:

```ruby
# For images (currently 10MB)
if image_file.byte_size > 20.megabytes  # Change to 20MB
  errors.add(:image_file, "must be less than 20MB")
end

# For videos (currently 100MB)  
if video_file.byte_size > 200.megabytes  # Change to 200MB
  errors.add(:video_file, "must be less than 200MB")
end
```

## Testing

Run the test suite:

```bash
bin/rails test
bin/rails test:system
```

## Deployment

### Systemd Service (Linux)

The application includes a systemd service unit for production deployment. The service runs the Rails app with Puma and listens on all network interfaces.

**Installation:**

1. **Generate a secret key:**
```bash
bin/rails secret
```

2. **Create environment file:**
```bash
sudo cp advent-calendar.env.example /etc/advent-calendar.env
sudo chmod 600 /etc/advent-calendar.env
sudo chown root:root /etc/advent-calendar.env
```

3. **Edit the environment file:**
```bash
sudo nano /etc/advent-calendar.env
```
Update `SECRET_KEY_BASE` with the secret generated in step 1.

4. **Prepare the application:**
```bash
RAILS_ENV=production bin/rails db:migrate
RAILS_ENV=production bin/rails db:seed  # Optional: create sample users
RAILS_ENV=production bin/rails assets:precompile  # If needed
```

5. **Install and start the service:**
```bash
# Copy service file to systemd directory
sudo cp advent-calendar.service /etc/systemd/system/

# Reload systemd configuration
sudo systemctl daemon-reload

# Enable service to start on boot
sudo systemctl enable advent-calendar

# Start the service
sudo systemctl start advent-calendar
```

**Service Management:**

```bash
# Check service status
sudo systemctl status advent-calendar

# View logs
sudo journalctl -u advent-calendar -f

# Restart the service (e.g., after code changes)
sudo systemctl restart advent-calendar

# Stop the service
sudo systemctl stop advent-calendar

# Disable service from starting on boot
sudo systemctl disable advent-calendar
```

**Updating the Application:**

After pulling new code or making changes:

```bash
# Navigate to application directory
cd /home/mbright/advent

# Pull latest changes
git pull

# Install dependencies
bundle install

# Run migrations
RAILS_ENV=production bin/rails db:migrate

# Precompile assets if needed
RAILS_ENV=production bin/rails assets:precompile

# Restart the service
sudo systemctl restart advent-calendar
```

**Network Access:**

The service listens on `0.0.0.0:3000` by default, making it accessible on all network interfaces. You can:

- Access locally: `http://localhost:3000`
- Access from other machines: `http://your-server-ip:3000`
- Use a reverse proxy (nginx/Apache) for HTTPS and domain names

**Troubleshooting:**

If the service fails to start:

```bash
# Check detailed logs
sudo journalctl -u advent-calendar -n 50 --no-pager

# Verify environment file exists and has correct permissions
ls -la /etc/advent-calendar.env

# Test the application manually
cd /home/mbright/advent
RAILS_ENV=production bundle exec puma -C config/puma.rb -b tcp://0.0.0.0:3000
```

### Docker/Kamal

The application also includes Kamal configuration for Docker deployment. See `config/deploy.yml` for details.

## License

This is a custom application for managing advent calendars.
