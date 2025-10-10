# NaviGo Database Documentation

## Overview
This directory contains the complete database schema and setup files for the NaviGo travel planning application.

## Files

### 📄 `navigo_database.sql`
Complete SQL schema file containing:
- Database creation
- All table definitions
- Indexes for performance
- Sample data
- Views and stored procedures
- Triggers for data integrity

### 🔧 `install.php`
Web-based installation script that:
- Checks if database exists
- Installs or updates the schema
- Tests database connection
- Shows sample data
- Provides reinstall options

### 📖 `README.md`
This documentation file

## Quick Setup

### Method 1: Using the Web Installer (Recommended)
1. Start your XAMPP/WAMP server
2. Navigate to `http://localhost/NaviGo0.0.2/Database/install.php`
3. Click "Install Database"
4. Verify the installation was successful

### Method 2: Using phpMyAdmin
1. Open phpMyAdmin
2. Create a new database named `navigo_db`
3. Import the `navigo_database.sql` file
4. Verify tables were created successfully

### Method 3: Using Command Line
```bash
mysql -u root -p < navigo_database.sql
```

## Database Structure

### Core Tables

#### 👤 Users Table
- Personal account information
- Authentication data
- Profile details
- Preferences and settings

#### 🏢 Businesses Table
- Business partner accounts
- Company information
- Contact details
- Verification status

#### 🗺️ Itineraries Table
- Travel plans and trips
- Destination information
- Budget and dates
- Sharing and privacy settings

#### 📅 Itinerary Items Table
- Individual activities/events
- Day-by-day planning
- Location and timing
- Booking references

#### 👥 Group Travels Table
- Collaborative trip planning
- Group management
- Join codes and permissions

#### 💾 Saved Places Table
- User's favorite locations
- Personal notes and ratings
- Categorization and tags

#### 🛍️ Business Services Table
- Services offered by businesses
- Pricing and availability
- Location and amenities

#### 📋 Bookings Table
- User reservations
- Payment tracking
- Status management
- Booking references

#### ⭐ Reviews Table
- User feedback
- Ratings and comments
- Verification status

#### 📊 Analytics Table
- Business performance metrics
- Usage statistics
- Revenue tracking

#### 🔔 Notifications Table
- System messages
- User alerts
- Action tracking

#### 🔐 Sessions Table
- User session management
- Security tracking
- Activity monitoring

## Sample Data

The database includes sample data for testing:
- **3 Sample Users**: John Doe, Jane Smith, Mike Johnson
- **3 Sample Businesses**: Grand Hotel Paris, Tokyo Sushi Bar, Adventure Tours NYC
- **3 Sample Itineraries**: Paris Adventure, Tokyo Food Tour, NYC Weekend
- **4 Sample Services**: Hotel rooms, spa packages, dining, tours
- **3 Sample Saved Places**: Eiffel Tower, Tsukiji Market, Central Park

## Configuration

### Database Connection
Update `Config/Database.php` with your database credentials:

```php
private $host = "localhost";
private $db_name = "navigo_db";
private $username = "root";
private $password = "";
```

### Security Considerations
- Change default passwords
- Use environment variables for credentials
- Enable SSL for production
- Regular backups
- User permissions

## Features

### 🔍 Advanced Queries
- Optimized indexes for performance
- Views for common queries
- Stored procedures for complex operations

### 🔒 Security
- Password hashing with PHP's `password_hash()`
- CSRF protection
- Rate limiting
- Input sanitization

### 📈 Performance
- Strategic indexing
- Query optimization
- Connection pooling ready

### 🔄 Data Integrity
- Foreign key constraints
- Triggers for automatic updates
- Validation functions
- Error handling

## Maintenance

### Regular Tasks
- Monitor database performance
- Update statistics
- Clean old sessions
- Backup data regularly

### Backup Commands
```bash
# Full backup
mysqldump -u root -p navigo_db > backup_$(date +%Y%m%d).sql

# Structure only
mysqldump -u root -p --no-data navigo_db > structure.sql

# Data only
mysqldump -u root -p --no-create-info navigo_db > data.sql
```

### Restore Commands
```bash
# Restore from backup
mysql -u root -p navigo_db < backup_20240101.sql
```

## Troubleshooting

### Common Issues

#### Connection Errors
- Check MySQL service is running
- Verify credentials in `Config/Database.php`
- Ensure database exists

#### Permission Errors
- Grant proper permissions to database user
- Check file permissions on PHP files

#### Import Errors
- Verify SQL file is not corrupted
- Check MySQL version compatibility
- Review error logs

### Debug Mode
Enable debug mode in `Config/functions.php`:
```php
define('DEBUG', true);
```

## Support

For database-related issues:
1. Check the error logs
2. Verify configuration
3. Test with sample data
4. Review this documentation

## Version History

- **v1.0**: Initial database schema
- Complete user and business management
- Itinerary and booking system
- Review and analytics features
- Notification system
- Security and performance optimizations
