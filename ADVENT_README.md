# Advent Calendar Application

A multi-tenant Rails 8.1 application for creating and sharing personalized advent calendars.

## Features

- **User Authentication**: Secure login system (users created by admins via console)
- **Multi-tenant Architecture**: Each user can create calendars for other users
- **24-Day Advent Calendars**: December 1-24 with rich content
- **Content Types**:
  - Text entries
  - Embedded images
  - Embedded videos (YouTube, Vimeo)
- **Smart Unlocking**: Days unlock only in December based on the current date
- **Creator Preview Mode**: Calendar creators can view and edit all days year-round
- **View Tracking**: Track which days recipients have viewed
- **Year Scoping**: Create calendars for any year starting from 2025
- **One Calendar Per User-Year**: Each creator can only make one calendar per recipient per year

## Technology Stack

- **Rails 8.1.1** with Hotwire (Turbo + Stimulus)
- **SQLite3** database
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

### Creating Users (Admin Only)

Since there's no public signup, admins create users via Rails console:

```ruby
bin/rails console

User.create!(
  email: 'user@example.com',
  password: 'secure_password',
  password_confirmation: 'secure_password',
  admin: false
)
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

1. View your created calendar
2. Click "Edit" on any day card
3. Add content elements:
   - **Text**: Write messages, stories, poems
   - **Image**: Paste image URLs (JPG, PNG, GIF, WEBP)
   - **Video**: Paste YouTube or Vimeo URLs
4. Each day can have multiple elements
5. Elements display in the order they're added

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

## URL Embedding

The application automatically detects and embeds:

- **YouTube**: `youtube.com/watch?v=...` or `youtu.be/...`
- **Vimeo**: `vimeo.com/123456`
- **Images**: URLs ending in `.jpg`, `.png`, `.gif`, `.webp`
- **Other URLs**: Display as clickable links

## Architecture

### Models

- **User**: Authentication with has_secure_password
- **Calendar**: Belongs to creator and recipient
- **CalendarDay**: 24 days per calendar (auto-generated)
- **ContentElement**: Multiple elements per day (text/image/video)
- **CalendarView**: Tracks which days users have viewed

### Key Business Logic

- `Calendar#day_unlocked_for?(day_number, user)`: Determines if a day is accessible
  - Creators: Always unlocked
  - Recipients: Only in December when `current_day >= day_number`
  
- `UrlEmbedder.embed(url, element_type)`: Converts URLs to embedded HTML
  - Extracts YouTube/Vimeo IDs
  - Generates responsive iframes
  - Handles images with proper sizing

### Security

- All routes require authentication except login
- Authorization checks on calendars (creator/recipient only)
- Content Security Policy allows YouTube/Vimeo iframes
- URL validation with HEAD requests to verify accessibility
- CSRF protection enabled

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

### Content Element Types

To add new element types, update `ContentElement` model:

1. Add to enum: `enum element_type: { text: 'text', image: 'image', video: 'video', audio: 'audio' }`
2. Update form in `calendar_days/edit.html.erb`
3. Update display logic in `calendar_days/show.html.erb`
4. Extend `UrlEmbedder` service

## Testing

Run the test suite:

```bash
bin/rails test
bin/rails test:system
```

## Deployment

The application includes Kamal configuration for Docker deployment. See `config/deploy.yml` for details.

## License

This is a custom application for managing advent calendars.
