# Advent Calendar Application

A multi-tenant Rails 8.1 application for creating and sharing personalized advent calendars.

Inspired by Helen Bright.

## Features

- **Admin & User Roles**: Admin users can manage all users; regular users can create calendars
- **Multi-tenant Architecture**: Each user can create calendars for other users
- **24-Day Advent Calendars**: December 1-24 with rich content
- **Content Types**:
  - Images (uploaded or via URL)
  - Videos (uploaded or via URL with YouTube/Vimeo support)
  - Title and description text for each day
- **Flexible Content Sources**: Upload files directly or provide URLs for external content
- **Smart Unlocking**: Days unlock only in December based on the current date
- **Creator Preview Mode**: Calendar creators can view and edit all days year-round
- **View Tracking**: Track which days recipients have viewed with timestamps
- **Year Scoping**: Create calendars for any year starting from 2025
- **One Calendar Per User-Year**: Each creator can only make one calendar per recipient per year
- **Calendar Shuffling**: Randomize the visual display order (position) of days (available until November 30th)
- **Day Swapping**: Exchange content between any two days in a calendar
- **File Management**: Upload images (max 10MB) and videos (max 100MB) with support for multiple formats
- **Request Logging**: Track user requests with IP address, user agent, and timestamp

## Technology Stack

- **Rails 8.1.1** with Hotwire (Turbo + Stimulus)
- **SQLite3** database (primary, cache, queue, and cable databases in production)
- **Solid Cache, Solid Queue, Solid Cable** for database-backed cache, jobs, and WebSockets
- **image_processing** gem with libvips for image transformations
- **Content Security Policy** configured for YouTube/Vimeo embeds
- **Puma** web server
- **Propshaft** for asset pipeline

## Getting Started

### Prerequisites

- Ruby 3.x
- Rails 8.1.1
- SQLite3
- libvips (for image processing)

### Installation

1. Install system dependencies:

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install -y libvips libvips-dev libvips-tools
```

**macOS:**
```bash
brew install vips
```

2. Install Ruby dependencies:
```bash
bundle install
```

3. Setup database:
```bash
bin/rails db:migrate
bin/rails db:seed
```

4. Start the server:
```bash
bin/rails server
```

5. Visit `http://localhost:3000`

### Sample Users

After running `db:seed`, you can log in with:

- **Admin**: `admin@example.com` / `password`
- **Alice**: `alice@example.com` / `password`
- **Bob**: `bob@example.com` / `password`

The admin user has access to user management features including creating, editing, and deleting users.

## Usage

### Managing Your Account

**Change Your Password:**

1. Log in to your account
2. Click "Change Password" in the navigation bar
3. Enter your current password
4. Enter your new password (minimum 6 characters)
5. Confirm your new password
6. Click "Update Password"

### Admin Features

Admin users have access to additional features:

**User Management:**
- View all users (`/users`)
- Create new users with optional admin privileges
- Edit user passwords
- Delete users (except themselves and users who are recipients of calendars)

**Request Logs:**
- View all HTTP requests (`/request_logs`)
- Track user activity with IP addresses and user agents
- Monitor access patterns

### Managing Users (Shell Scripts)

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

# Create admin user
User.create!(
  email: 'admin@example.com',
  password: 'secure_password',
  password_confirmation: 'secure_password',
  admin: true
)

# Change password
user = User.find_by(email: 'user@example.com')
user.password = 'new_password'
user.password_confirmation = 'new_password'
user.save!

# Delete user (only if not a recipient of any calendars)
user = User.find_by(email: 'user@example.com')
user.destroy if user.can_be_deleted?
```

### Creating a Calendar

1. Log in as any user
2. Click "Create New Calendar"
3. Fill in:
   - Title (e.g., "My Christmas Adventure 2025")
   - Description/tagline (optional)
   - Select a recipient (any user except yourself)
   - Choose the year (2025+)
4. Submit to create calendar with 24 empty days
5. The calendar days are automatically shuffled upon creation

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

**Content Rules:**
- Each day can have only one content source (URL or upload, not both)
- You can switch between URL and upload by editing the day
- Previous content is replaced when you add new content

### Managing Calendar Days

**Shuffle Calendar** (Available until November 30th):
- Click "Shuffle All Days" button on calendar view
- Randomizes the visual position of days in the grid
- Each day keeps its original number and content
- Useful for surprising recipients with a non-sequential layout
- Cannot shuffle after November 30th of the calendar year

**Swap Days**:
1. Click "Swap" button on a day card
2. Select which day to swap with
3. Preview both days' content
4. Confirm to exchange all content between the two days
5. Swapping exchanges: title, description, URL, content type, and attached files

**Delete Attachments**:
- Use "Delete Uploaded Image/Video" button on edit page
- Removes uploaded files while keeping other day data
- Allows you to switch from uploaded file to URL or vice versa

### Viewing Calendars

**As Recipient:**
- Days unlock automatically in December when the date matches the day number
- Click unlocked days to view content
- Locked days show a 🔒 icon
- Viewed days show a ✓ checkmark
- Your views are tracked with timestamps

**As Creator:**
- All days are unlocked year-round in "Creator Preview Mode"
- See which days have content vs. empty
- Edit any day at any time
- Shuffle calendar layout (until November 30th)
- Swap content between days
- Delete uploaded files
- View tracking shows which days the recipient has viewed

## URL Embedding and File Handling

The application supports both URL-based content and file uploads:

**Automatic URL Detection:**
- **YouTube**: `youtube.com/watch?v=...` or `youtu.be/...`
  - Supports time parameters (e.g., `?t=30s`, `?t=1m30s`)
  - Uses YouTube's privacy-enhanced mode (youtube-nocookie.com)
- **Vimeo**: `vimeo.com/123456`
- **Direct Media URLs**: URLs ending in supported image/video formats

**YouTube Time Parameters:**
- Preserves timestamp from YouTube share links
- Supports formats: `30s`, `1m30s`, `1h2m3s`, or plain seconds
- Automatically converts to YouTube embed format

**File Uploads:**
- **Images**: JPEG, JPG, PNG, GIF, WEBP (max 10MB)
- **Videos**: MP4, MOV, AVI, WEBM, OGG (max 100MB)
- Files stored using Active Storage with SQLite backend
- Automatic content type validation
- URL accessibility validation (HEAD request)

**Content Rules:**
- Each day can have only one content source (URL or upload, not both)
- You can switch between URL and upload by editing the day
- Files can be deleted independently via the edit page

## Architecture

### Models

- **User**: 
  - Authentication with `has_secure_password`
  - Admin flag for privileged operations
  - Email uniqueness (case-insensitive)
  - Has many created calendars, received calendars, calendar views, and request logs
  - Cannot be deleted if they are a recipient of any calendars

- **Calendar**: 
  - Belongs to creator (User) and recipient (User)
  - Has many calendar_days (24 days auto-generated on creation)
  - Has many calendar_views for tracking
  - Validates uniqueness of creator + recipient + year
  - Year must be >= 2025
  - Days auto-shuffled on creation

- **CalendarDay**: 
  - Belongs to calendar
  - 24 days per calendar (day_number 1-24)
  - `day_number`: The actual day (1-24)
  - `display_position`: Visual position in grid (for shuffling)
  - `content_type`: 'image' or 'video'
  - `title`, `description`, `url`: Content metadata
  - Attachments: `image_file` and `video_file` via Active Storage
  - Validates only one content source (URL or file)
  - URL accessibility validation

- **CalendarView**: 
  - Tracks when recipients view specific days
  - Belongs to calendar and user
  - Records `viewed_at` timestamp
  - Unique constraint on calendar + user + day_number

- **RequestLog**: 
  - Tracks HTTP requests
  - Records user_id, IP address, user agent, path, and method
  - Indexed on created_at, ip_address, and user_id

### Key Business Logic

- `Calendar#day_unlocked_for?(day_number, user)`: Determines if a day is accessible
  - Creators: Always unlocked
  - Recipients: Only in December of the calendar year when `current_day >= day_number`

- `Calendar#can_shuffle?`: Checks if shuffling is allowed
  - Returns true until November 30th (inclusive) of the calendar year
  - After November 30th, shuffling is locked

- `Calendar#shuffle_days`: Randomizes display_position of all days
  - Generates shuffled positions (1-24)
  - Updates display_position without changing content
  - Uses transaction for atomicity

- `CalendarDay#swap_with(other_day)`: Exchanges all content between two days
  - Swaps title, description, URL, content_type
  - Properly handles file attachment transfers using blob references
  - Uses transaction for atomicity
  - Validates both days belong to same calendar

- `CalendarDay.detect_content_type_from_url(url)`: Auto-detects content type
  - Checks for video platforms (YouTube, Vimeo, etc.)
  - Checks file extensions
  - Returns 'image' or 'video'

- `UrlEmbedder.embed(url, element_type)`: Converts URLs to embedded HTML
  - Extracts YouTube/Vimeo IDs
  - Generates responsive iframes
  - Handles images with proper sizing
  - Preserves YouTube time parameters
  - Uses privacy-enhanced YouTube embeds

### Controllers

- **ApplicationController**: Base controller with authentication
  - `current_user`: Returns logged-in user
  - `logged_in?`: Checks if user is authenticated
  - `viewing_as_creator?`: Checks if current user is calendar creator
  - `require_login`: Before action for authentication

- **SessionsController**: Handles login/logout
  - Creates and destroys user sessions
  - Request logging on login

- **UsersController**: User management
  - Admin-only: index, new, create, edit, update, destroy
  - All users: edit_password, update_password
  - Password change requires current password verification
  - Cannot delete self or users who are recipients

- **CalendarsController**: Calendar CRUD
  - Lists calendars (created and received separately)
  - Create, update, delete calendars
  - Shuffle action (POST /calendars/:id/shuffle)

- **CalendarDaysController**: Day management
  - Show, edit, update individual days
  - Swap actions (swap_initiate, swap_complete)
  - Delete attachment action
  - Nested under calendars

- **CalendarViewsController**: View tracking
  - Create action to record when recipient views a day

- **RequestLogsController**: Admin request monitoring
  - Admin-only index action

### Security

- All routes require authentication except login and health check
- Authorization checks on calendars (creator/recipient only)
- Admin-only routes for user management and request logs
- Content Security Policy allows YouTube/Vimeo iframes
- URL validation with HEAD requests to verify accessibility
- File upload validation (type and size limits)
- CSRF protection enabled
- Secure password hashing with bcrypt
- Users cannot delete themselves
- Users who are recipients of calendars cannot be deleted

### Database Schema

**Primary Database:**
- `users`: email, password_digest, admin flag
- `calendars`: title, description, year, creator_id, recipient_id
- `calendar_days`: day_number, display_position, content_type, title, description, url
- `calendar_views`: calendar_id, user_id, day_number, viewed_at
- `request_logs`: user_id, ip_address, user_agent, path, request_method
- Active Storage tables for file attachments

**Production Additional Databases:**
- `cache`: Solid Cache for Rails.cache
- `queue`: Solid Queue for Active Job
- `cable`: Solid Cable for Action Cable

## Customization

### Time Zone

The app uses Eastern Time (US & Canada). To change, edit `config/application.rb`:

```ruby
config.time_zone = "Your/Timezone"
config.active_record.default_timezone = :local
```

### December-Only Unlocking

To allow testing year-round, modify `Calendar#day_unlocked_for?` in `app/models/calendar.rb`:

```ruby
def day_unlocked_for?(day_number, user)
  return true if creator == user
  # Remove month and year checks for testing:
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

### Password Requirements

Password minimum length is validated by Rails' `has_secure_password` (default 6 characters). To change it, add to `app/models/user.rb`:

```ruby
validates :password, length: { minimum: 8 }, if: -> { password.present? }
```

## Testing

Run the test suite:

```bash
bin/rails test
bin/rails test:system
```

Additional development tools:

```bash
# Run security audit
bin/bundler-audit

# Run static analysis
bin/brakeman

# Run linter
bin/rubocop
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
cd /path/to/advent

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
cd /path/to/advent
RAILS_ENV=production bundle exec puma -C config/puma.rb -b tcp://0.0.0.0:3000
```

### Docker/Kamal

The application also includes Kamal configuration for Docker deployment. See `config/deploy.yml` for details.

## Project Structure

```
advent/
├── app/
│   ├── controllers/      # Request handling
│   ├── models/           # Business logic and database models
│   ├── views/            # HTML templates
│   ├── helpers/          # View helpers
│   ├── services/         # Service objects (UrlEmbedder)
│   ├── javascript/       # Stimulus controllers
│   └── assets/           # Images and stylesheets
├── bin/                  # Executables and scripts
│   ├── rails, rake       # Rails commands
│   ├── bundler-audit     # Security audit
│   ├── brakeman          # Static analysis
│   └── rubocop           # Linting
├── config/               # Application configuration
│   ├── routes.rb         # URL routing
│   ├── database.yml      # Database configuration
│   ├── application.rb    # Rails configuration
│   └── environments/     # Environment-specific config
├── db/                   # Database files
│   ├── migrate/          # Database migrations
│   ├── seeds.rb          # Sample data
│   └── schema.rb         # Current database schema
├── script/               # Shell scripts for user management
│   ├── add-user.sh
│   ├── change-password.sh
│   └── delete-user.sh
├── storage/              # SQLite databases and uploaded files
├── test/                 # Test suite
├── Gemfile               # Ruby dependencies
└── README.md             # This file
```

## License

This is a custom application for managing advent calendars.
