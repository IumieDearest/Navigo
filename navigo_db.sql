-- NaviGo Database Schema
-- Created for NaviGo Travel Planning Application
-- Version: 0.0.5
-- Updated: 2025-10-14

-- Create database
CREATE DATABASE IF NOT EXISTS navigo_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE navigo_db;

-- =============================================
-- USERS TABLE (Personal Accounts)
-- =============================================
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    date_of_birth DATE,
    profile_picture VARCHAR(255),
    bio TEXT,
    preferences JSON,
    is_active BOOLEAN DEFAULT TRUE,
    email_verified BOOLEAN DEFAULT FALSE,
    verification_token VARCHAR(100),
    reset_token VARCHAR(100),
    reset_token_expires DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    INDEX idx_email (email),
    INDEX idx_active (is_active),
    INDEX idx_created_at (created_at)
);

-- =============================================
-- BUSINESSES TABLE (Business Partner Accounts)
-- =============================================
CREATE TABLE businesses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    business_name VARCHAR(100) NOT NULL,
    business_type ENUM('hotel', 'restaurant', 'tour', 'transport', 'other') NOT NULL,
    contact_first_name VARCHAR(50) NOT NULL,
    contact_last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    business_phone VARCHAR(20),
    website VARCHAR(255),
    business_address TEXT,
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50),
    postal_code VARCHAR(20),
    business_description TEXT,
    business_hours JSON,
    amenities JSON,
    social_media JSON,
    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    verification_documents JSON,
    email_verified BOOLEAN DEFAULT FALSE,
    verification_token VARCHAR(100),
    reset_token VARCHAR(100),
    reset_token_expires DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    INDEX idx_email (email),
    INDEX idx_business_type (business_type),
    INDEX idx_active (is_active),
    INDEX idx_verified (is_verified),
    INDEX idx_created_at (created_at)
);

-- =============================================
-- ITINERARIES TABLE (Travel Plans)
-- =============================================
CREATE TABLE itineraries (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    destination VARCHAR(100) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    budget DECIMAL(10,2),
    currency VARCHAR(3) DEFAULT 'USD',
    status ENUM('planning', 'confirmed', 'in_progress', 'completed', 'cancelled') DEFAULT 'planning',
    is_public BOOLEAN DEFAULT FALSE,
    is_shared BOOLEAN DEFAULT FALSE,
    share_token VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_destination (destination),
    INDEX idx_dates (start_date, end_date),
    INDEX idx_status (status),
    INDEX idx_public (is_public)
);

-- =============================================
-- ITINERARY_ITEMS TABLE (Activities/Events in Itinerary)
-- =============================================
CREATE TABLE itinerary_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    itinerary_id INT NOT NULL,
    day_number INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    activity_type ENUM('accommodation', 'transportation', 'attraction', 'restaurant', 'activity', 'other') NOT NULL,
    start_time TIME,
    end_time TIME,
    location VARCHAR(200),
    address TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    cost DECIMAL(10,2),
    currency VARCHAR(3) DEFAULT 'USD',
    booking_reference VARCHAR(100),
    notes TEXT,
    is_confirmed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (itinerary_id) REFERENCES itineraries(id) ON DELETE CASCADE,
    INDEX idx_itinerary_id (itinerary_id),
    INDEX idx_day_number (day_number),
    INDEX idx_activity_type (activity_type),
    INDEX idx_location (location)
);

-- =============================================
-- GROUP_TRAVELS TABLE (Group Travel Sessions)
-- =============================================
CREATE TABLE group_travels (
    id INT AUTO_INCREMENT PRIMARY KEY,
    creator_id INT NOT NULL,
    itinerary_id INT,
    group_name VARCHAR(100) NOT NULL,
    description TEXT,
    max_members INT DEFAULT 10,
    current_members INT DEFAULT 1,
    is_active BOOLEAN DEFAULT TRUE,
    join_code VARCHAR(20) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (creator_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (itinerary_id) REFERENCES itineraries(id) ON DELETE SET NULL,
    INDEX idx_creator_id (creator_id),
    INDEX idx_join_code (join_code),
    INDEX idx_active (is_active)
);

-- =============================================
-- GROUP_MEMBERS TABLE (Group Travel Participants)
-- =============================================
CREATE TABLE group_members (
    id INT AUTO_INCREMENT PRIMARY KEY,
    group_id INT NOT NULL,
    user_id INT NOT NULL,
    role ENUM('creator', 'admin', 'member') DEFAULT 'member',
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (group_id) REFERENCES group_travels(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_group_user (group_id, user_id),
    INDEX idx_group_id (group_id),
    INDEX idx_user_id (user_id),
    INDEX idx_role (role)
);

-- =============================================
-- SAVED_PLACES TABLE (User's Saved Locations)
-- =============================================
CREATE TABLE saved_places (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    location VARCHAR(200) NOT NULL,
    address TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    place_type ENUM('restaurant', 'attraction', 'hotel', 'activity', 'other') NOT NULL,
    rating DECIMAL(3,2),
    price_level INT,
    website VARCHAR(255),
    phone VARCHAR(20),
    notes TEXT,
    tags JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_place_type (place_type),
    INDEX idx_location (location)
);

-- =============================================
-- BUSINESS_SERVICES TABLE (Services Offered by Businesses)
-- =============================================
CREATE TABLE business_services (
    id INT AUTO_INCREMENT PRIMARY KEY,
    business_id INT NOT NULL,
    service_name VARCHAR(200) NOT NULL,
    service_type ENUM('accommodation', 'restaurant', 'tour', 'transport', 'activity', 'other') NOT NULL,
    description TEXT,
    price DECIMAL(10,2),
    currency VARCHAR(3) DEFAULT 'USD',
    duration_hours DECIMAL(5,2),
    capacity INT,
    location VARCHAR(200),
    address TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    amenities JSON,
    availability_schedule JSON,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
    INDEX idx_business_id (business_id),
    INDEX idx_service_type (service_type),
    INDEX idx_active (is_active),
    INDEX idx_location (location)
);

-- =============================================
-- BOOKINGS TABLE (User Bookings with Businesses)
-- =============================================
CREATE TABLE bookings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    business_id INT NOT NULL,
    service_id INT,
    itinerary_id INT,
    booking_reference VARCHAR(50) UNIQUE NOT NULL,
    service_name VARCHAR(200) NOT NULL,
    booking_date DATE NOT NULL,
    check_in_date DATE,
    check_out_date DATE,
    quantity INT DEFAULT 1,
    total_amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    status ENUM('pending', 'confirmed', 'cancelled', 'completed', 'refunded') DEFAULT 'pending',
    payment_status ENUM('pending', 'paid', 'failed', 'refunded') DEFAULT 'pending',
    payment_method VARCHAR(50),
    payment_reference VARCHAR(100),
    special_requests TEXT,
    cancellation_policy TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
    FOREIGN KEY (service_id) REFERENCES business_services(id) ON DELETE SET NULL,
    FOREIGN KEY (itinerary_id) REFERENCES itineraries(id) ON DELETE SET NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_business_id (business_id),
    INDEX idx_booking_reference (booking_reference),
    INDEX idx_booking_date (booking_date),
    INDEX idx_status (status),
    INDEX idx_payment_status (payment_status)
);

-- =============================================
-- REVIEWS TABLE (User Reviews for Businesses)
-- =============================================
CREATE TABLE reviews (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    business_id INT NOT NULL,
    booking_id INT,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    title VARCHAR(200),
    comment TEXT,
    is_verified BOOLEAN DEFAULT FALSE,
    is_public BOOLEAN DEFAULT TRUE,
    helpful_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
    FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE SET NULL,
    UNIQUE KEY unique_user_business_booking (user_id, business_id, booking_id),
    INDEX idx_user_id (user_id),
    INDEX idx_business_id (business_id),
    INDEX idx_rating (rating),
    INDEX idx_created_at (created_at)
);

-- =============================================
-- ANALYTICS TABLE (Business Performance Data)
-- =============================================
CREATE TABLE analytics (
    id INT AUTO_INCREMENT PRIMARY KEY,
    business_id INT NOT NULL,
    metric_type ENUM('views', 'bookings', 'revenue', 'reviews', 'rating') NOT NULL,
    metric_value DECIMAL(15,2) NOT NULL,
    date_recorded DATE NOT NULL,
    additional_data JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
    INDEX idx_business_id (business_id),
    INDEX idx_metric_type (metric_type),
    INDEX idx_date_recorded (date_recorded)
);

-- =============================================
-- NOTIFICATIONS TABLE (System Notifications)
-- =============================================
CREATE TABLE notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    business_id INT,
    type ENUM('booking', 'payment', 'review', 'system', 'promotion') NOT NULL,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    action_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_business_id (business_id),
    INDEX idx_type (type),
    INDEX idx_is_read (is_read),
    INDEX idx_created_at (created_at)
);

-- =============================================
-- SESSIONS TABLE (User Sessions)
-- =============================================
CREATE TABLE sessions (
    id VARCHAR(128) PRIMARY KEY,
    user_id INT,
    business_id INT,
    user_type ENUM('personal', 'business') NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_business_id (business_id),
    INDEX idx_last_activity (last_activity)
);

-- =============================================
-- INSERT SAMPLE DATA
-- =============================================

-- Insert sample users
INSERT INTO users (first_name, last_name, email, password, phone, is_active, email_verified) VALUES
('John', 'Doe', 'john.doe@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+1234567890', TRUE, TRUE),
('Jane', 'Smith', 'jane.smith@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+1234567891', TRUE, TRUE),
('Mike', 'Johnson', 'mike.johnson@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+1234567892', TRUE, TRUE);

-- Insert sample businesses
INSERT INTO businesses (business_name, business_type, contact_first_name, contact_last_name, email, password, phone, city, country, is_active, is_verified, email_verified) VALUES
('Grand Hotel Paris', 'hotel', 'Marie', 'Dubois', 'contact@grandhotelparis.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+33123456789', 'Paris', 'France', TRUE, TRUE, TRUE),
('Tokyo Sushi Bar', 'restaurant', 'Hiroshi', 'Tanaka', 'info@tokyosushibar.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+81312345678', 'Tokyo', 'Japan', TRUE, TRUE, TRUE),
('Adventure Tours NYC', 'tour', 'Sarah', 'Wilson', 'bookings@adventuretoursnyc.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+12125551234', 'New York', 'USA', TRUE, TRUE, TRUE);

-- Insert sample itineraries
INSERT INTO itineraries (user_id, title, description, destination, start_date, end_date, budget, status) VALUES
(1, 'Paris Adventure', 'A romantic getaway to the City of Light', 'Paris, France', '2024-06-01', '2024-06-07', 2500.00, 'planning'),
(2, 'Tokyo Food Tour', 'Exploring the culinary delights of Tokyo', 'Tokyo, Japan', '2024-07-15', '2024-07-22', 3000.00, 'confirmed'),
(3, 'NYC Weekend', 'Quick weekend trip to New York', 'New York, USA', '2024-05-10', '2024-05-12', 800.00, 'completed');

-- Insert sample business services
INSERT INTO business_services (business_id, service_name, service_type, description, price, duration_hours, location, is_active) VALUES
(1, 'Deluxe Room', 'accommodation', 'Spacious room with city view', 200.00, 24.00, 'Paris, France', TRUE),
(1, 'Spa Package', 'activity', 'Relaxing spa treatment', 150.00, 2.00, 'Paris, France', TRUE),
(2, 'Omakase Dinner', 'restaurant', 'Chef\'s choice sushi experience', 120.00, 2.00, 'Tokyo, Japan', TRUE),
(3, 'City Walking Tour', 'tour', 'Guided walking tour of Manhattan', 50.00, 3.00, 'New York, USA', TRUE);

-- Insert sample saved places
INSERT INTO saved_places (user_id, name, description, location, place_type, rating, notes) VALUES
(1, 'Eiffel Tower', 'Iconic iron lattice tower', 'Paris, France', 'attraction', 4.8, 'Must visit at sunset'),
(2, 'Tsukiji Fish Market', 'Famous fish market', 'Tokyo, Japan', 'attraction', 4.5, 'Best sushi in the world'),
(3, 'Central Park', 'Large public park', 'New York, USA', 'attraction', 4.7, 'Great for morning runs');

-- =============================================
-- CREATE VIEWS FOR COMMON QUERIES
-- =============================================

-- View for user dashboard data
CREATE VIEW user_dashboard_data AS
SELECT 
    u.id,
    u.first_name,
    u.last_name,
    u.email,
    COUNT(DISTINCT i.id) as total_itineraries,
    COUNT(DISTINCT sp.id) as total_saved_places,
    COUNT(DISTINCT gt.id) as total_group_travels,
    u.last_login
FROM users u
LEFT JOIN itineraries i ON u.id = i.user_id
LEFT JOIN saved_places sp ON u.id = sp.user_id
LEFT JOIN group_travels gt ON u.id = gt.creator_id
WHERE u.is_active = TRUE
GROUP BY u.id;

-- View for business dashboard data
CREATE VIEW business_dashboard_data AS
SELECT 
    b.id,
    b.business_name,
    b.business_type,
    b.email,
    COUNT(DISTINCT bs.id) as total_services,
    COUNT(DISTINCT bk.id) as total_bookings,
    AVG(r.rating) as average_rating,
    COUNT(DISTINCT r.id) as total_reviews,
    b.last_login
FROM businesses b
LEFT JOIN business_services bs ON b.id = bs.business_id AND bs.is_active = TRUE
LEFT JOIN bookings bk ON b.id = bk.business_id
LEFT JOIN reviews r ON b.id = r.business_id
WHERE b.is_active = TRUE
GROUP BY b.id;

-- =============================================
-- CREATE STORED PROCEDURES
-- =============================================

-- Procedure to get user statistics
DELIMITER //
CREATE PROCEDURE GetUserStats(IN user_id INT)
BEGIN
    SELECT 
        (SELECT COUNT(*) FROM itineraries WHERE user_id = user_id) as itinerary_count,
        (SELECT COUNT(*) FROM saved_places WHERE user_id = user_id) as saved_places_count,
        (SELECT COUNT(*) FROM group_travels WHERE creator_id = user_id) as group_travels_count,
        (SELECT COUNT(*) FROM bookings WHERE user_id = user_id) as booking_count;
END //
DELIMITER ;

-- Procedure to get business statistics
DELIMITER //
CREATE PROCEDURE GetBusinessStats(IN business_id INT)
BEGIN
    SELECT 
        (SELECT COUNT(*) FROM business_services WHERE business_id = business_id AND is_active = TRUE) as services_count,
        (SELECT COUNT(*) FROM bookings WHERE business_id = business_id) as bookings_count,
        (SELECT AVG(rating) FROM reviews WHERE business_id = business_id) as average_rating,
        (SELECT COUNT(*) FROM reviews WHERE business_id = business_id) as reviews_count;
END //
DELIMITER ;

-- =============================================
-- CREATE TRIGGERS
-- =============================================

-- Trigger to update group member count
DELIMITER //
CREATE TRIGGER update_group_member_count
AFTER INSERT ON group_members
FOR EACH ROW
BEGIN
    UPDATE group_travels 
    SET current_members = current_members + 1 
    WHERE id = NEW.group_id;
END //
DELIMITER ;

-- Trigger to decrease group member count
DELIMITER //
CREATE TRIGGER decrease_group_member_count
AFTER DELETE ON group_members
FOR EACH ROW
BEGIN
    UPDATE group_travels 
    SET current_members = current_members - 1 
    WHERE id = OLD.group_id;
END //
DELIMITER ;

-- =============================================
-- CREATE INDEXES FOR PERFORMANCE
-- =============================================

-- Additional indexes for better performance
CREATE INDEX idx_itineraries_user_dates ON itineraries(user_id, start_date, end_date);
CREATE INDEX idx_bookings_user_date ON bookings(user_id, booking_date);
CREATE INDEX idx_reviews_business_rating ON reviews(business_id, rating);
CREATE INDEX idx_notifications_user_read ON notifications(user_id, is_read, created_at);

-- =============================================
-- GRANT PERMISSIONS (Adjust as needed)
-- =============================================

-- Create application user (uncomment and modify as needed)
-- CREATE USER 'navigo_user'@'localhost' IDENTIFIED BY 'secure_password';
-- GRANT SELECT, INSERT, UPDATE, DELETE ON navigo_db.* TO 'navigo_user'@'localhost';
-- FLUSH PRIVILEGES;

-- =============================================
-- ADDITIONAL TABLES FOR ENHANCED FUNCTIONALITY
-- =============================================

-- =============================================
-- SUBSCRIPTION_PLANS TABLE (User Subscription Plans)
-- =============================================
CREATE TABLE subscription_plans (
    id INT AUTO_INCREMENT PRIMARY KEY,
    plan_name VARCHAR(50) NOT NULL,
    plan_type ENUM('free', 'traveler', 'premium') NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    billing_cycle ENUM('monthly', 'yearly') DEFAULT 'monthly',
    features JSON,
    max_itineraries INT DEFAULT NULL,
    max_group_members INT DEFAULT NULL,
    priority_support BOOLEAN DEFAULT FALSE,
    concierge_service BOOLEAN DEFAULT FALSE,
    travel_insurance BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_plan_type (plan_type),
    INDEX idx_active (is_active)
);

-- =============================================
-- USER_SUBSCRIPTIONS TABLE (User Subscription History)
-- =============================================
CREATE TABLE user_subscriptions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    plan_id INT NOT NULL,
    status ENUM('active', 'cancelled', 'expired', 'pending') DEFAULT 'pending',
    start_date DATE NOT NULL,
    end_date DATE,
    auto_renew BOOLEAN DEFAULT TRUE,
    payment_method VARCHAR(50),
    payment_reference VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (plan_id) REFERENCES subscription_plans(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_plan_id (plan_id),
    INDEX idx_status (status),
    INDEX idx_dates (start_date, end_date)
);

-- =============================================
-- TRIP_CATEGORIES TABLE (Trip Categories and Tags)
-- =============================================
CREATE TABLE trip_categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    category_type ENUM('destination', 'activity', 'budget', 'duration', 'season') NOT NULL,
    description TEXT,
    icon VARCHAR(50),
    color VARCHAR(7),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_category_type (category_type),
    INDEX idx_active (is_active)
);

-- =============================================
-- ITINERARY_CATEGORIES TABLE (Itinerary-Category Relationships)
-- =============================================
CREATE TABLE itinerary_categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    itinerary_id INT NOT NULL,
    category_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (itinerary_id) REFERENCES itineraries(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES trip_categories(id) ON DELETE CASCADE,
    UNIQUE KEY unique_itinerary_category (itinerary_id, category_id),
    INDEX idx_itinerary_id (itinerary_id),
    INDEX idx_category_id (category_id)
);

-- =============================================
-- DESTINATIONS TABLE (Popular Destinations)
-- =============================================
CREATE TABLE destinations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    country VARCHAR(100) NOT NULL,
    city VARCHAR(100),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    description TEXT,
    best_time_to_visit VARCHAR(100),
    average_budget_per_day DECIMAL(10,2),
    currency VARCHAR(3) DEFAULT 'USD',
    rating DECIMAL(3,2),
    review_count INT DEFAULT 0,
    image_url VARCHAR(500),
    highlights JSON,
    is_featured BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_country (country),
    INDEX idx_city (city),
    INDEX idx_featured (is_featured),
    INDEX idx_active (is_active),
    INDEX idx_rating (rating)
);

-- =============================================
-- USER_PREFERENCES TABLE (User Travel Preferences)
-- =============================================
CREATE TABLE user_preferences (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    travel_style ENUM('budget', 'mid_range', 'luxury') DEFAULT 'mid_range',
    accommodation_preference ENUM('hotel', 'hostel', 'airbnb', 'resort') DEFAULT 'hotel',
    transportation_preference ENUM('flight', 'train', 'bus', 'car', 'mixed') DEFAULT 'mixed',
    activity_interests JSON,
    dietary_restrictions JSON,
    accessibility_needs JSON,
    language_preferences JSON,
    notification_preferences JSON,
    privacy_settings JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_preferences (user_id),
    INDEX idx_user_id (user_id)
);

-- =============================================
-- TRIP_PHOTOS TABLE (Trip Photos and Media)
-- =============================================
CREATE TABLE trip_photos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    itinerary_id INT NOT NULL,
    user_id INT NOT NULL,
    photo_url VARCHAR(500) NOT NULL,
    caption TEXT,
    photo_type ENUM('itinerary', 'activity', 'accommodation', 'food', 'landmark', 'other') DEFAULT 'itinerary',
    is_public BOOLEAN DEFAULT FALSE,
    is_featured BOOLEAN DEFAULT FALSE,
    file_size INT,
    file_type VARCHAR(50),
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (itinerary_id) REFERENCES itineraries(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_itinerary_id (itinerary_id),
    INDEX idx_user_id (user_id),
    INDEX idx_public (is_public),
    INDEX idx_featured (is_featured)
);

-- =============================================
-- EXPENSE_TRACKING TABLE (Trip Expense Tracking)
-- =============================================
CREATE TABLE expense_tracking (
    id INT AUTO_INCREMENT PRIMARY KEY,
    itinerary_id INT NOT NULL,
    user_id INT NOT NULL,
    expense_category ENUM('accommodation', 'transportation', 'food', 'activities', 'shopping', 'other') NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    description VARCHAR(200),
    expense_date DATE NOT NULL,
    payment_method VARCHAR(50),
    receipt_url VARCHAR(500),
    is_reimbursable BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (itinerary_id) REFERENCES itineraries(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_itinerary_id (itinerary_id),
    INDEX idx_user_id (user_id),
    INDEX idx_category (expense_category),
    INDEX idx_expense_date (expense_date)
);

-- =============================================
-- INSERT ADDITIONAL SAMPLE DATA
-- =============================================

-- Insert subscription plans
INSERT INTO subscription_plans (plan_name, plan_type, price, currency, billing_cycle, features, max_itineraries, max_group_members, priority_support, concierge_service, travel_insurance) VALUES
('Free', 'free', 0.00, 'USD', 'monthly', '["Basic trip planning", "Limited destinations", "Basic support"]', 3, 1, FALSE, FALSE, FALSE),
('Traveler', 'traveler', 250.00, 'USD', 'monthly', '["AI recommendations", "Cloud storage", "Multi-calendar", "Offline access", "Priority support"]', NULL, 5, TRUE, FALSE, FALSE),
('Premium', 'premium', 499.00, 'USD', 'monthly', '["All Traveler features", "24/7 concierge", "Group travel up to 10", "Travel insurance", "Premium support"]', NULL, 10, TRUE, TRUE, TRUE);

-- Insert trip categories
INSERT INTO trip_categories (category_name, category_type, description, icon, color) VALUES
('Beach & Islands', 'destination', 'Tropical beach destinations', 'fas fa-umbrella-beach', '#0891b2'),
('Culture & History', 'destination', 'Historical and cultural sites', 'fas fa-building', '#7c3aed'),
('Adventure', 'activity', 'Adventure and outdoor activities', 'fas fa-mountain', '#10b981'),
('Romantic', 'activity', 'Romantic getaways and couples trips', 'fas fa-heart', '#ef4444'),
('Luxury', 'budget', 'High-end luxury travel', 'fas fa-star', '#f59e0b'),
('Nature', 'destination', 'Natural landscapes and wildlife', 'fas fa-leaf', '#22c55e'),
('Budget', 'budget', 'Affordable travel options', 'fas fa-dollar-sign', '#84cc16'),
('Family', 'activity', 'Family-friendly destinations', 'fas fa-users', '#8b5cf6');

-- Insert popular destinations
INSERT INTO destinations (name, country, city, latitude, longitude, description, best_time_to_visit, average_budget_per_day, currency, rating, review_count, image_url, highlights, is_featured) VALUES
('Santorini', 'Greece', 'Santorini', 36.3932, 25.4615, 'Stunning Greek island with white-washed buildings and blue domes', 'Apr - Oct', 200.00, 'EUR', 4.8, 2420, 'https://images.unsplash.com/photo-1570077188660-9787c0a69d96', '["Sunset Views", "White Architecture", "Volcanic Beaches"]', TRUE),
('Kyoto', 'Japan', 'Kyoto', 35.0116, 135.7681, 'Ancient capital with temples, gardens, and traditional culture', 'Mar - May, Sep - Nov', 150.00, 'JPY', 4.9, 3150, 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e', '["Ancient Temples", "Cherry Blossoms", "Traditional Gardens"]', TRUE),
('Dubai', 'UAE', 'Dubai', 25.2048, 55.2708, 'Modern metropolis with luxury shopping and iconic architecture', 'Nov - Mar', 300.00, 'AED', 4.6, 1820, 'https://images.unsplash.com/photo-1512453979798-5ea266f8880c', '["Modern Architecture", "Luxury Shopping", "Desert Safaris"]', TRUE),
('Paris', 'France', 'Paris', 48.8566, 2.3522, 'City of Light with world-class museums and cuisine', 'Apr - Oct', 250.00, 'EUR', 4.7, 4500, 'https://images.unsplash.com/photo-1502602898536-47ad22581b52', '["Eiffel Tower", "Louvre Museum", "Seine River"]', TRUE),
('Tokyo', 'Japan', 'Tokyo', 35.6762, 139.6503, 'Bustling metropolis blending tradition and modernity', 'Mar - May, Sep - Nov', 200.00, 'JPY', 4.8, 5200, 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf', '["Sushi", "Temples", "Technology"]', TRUE),
('New York', 'USA', 'New York', 40.7128, -74.0060, 'The Big Apple with iconic landmarks and diverse culture', 'Apr - Jun, Sep - Nov', 300.00, 'USD', 4.5, 6800, 'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9', '["Statue of Liberty", "Central Park", "Broadway"]', TRUE);

-- Insert sample user preferences
INSERT INTO user_preferences (user_id, travel_style, accommodation_preference, transportation_preference, activity_interests, dietary_restrictions, notification_preferences) VALUES
(1, 'luxury', 'hotel', 'flight', '["culture", "food", "photography"]', '["vegetarian"]', '{"email": true, "push": true, "sms": false}'),
(2, 'mid_range', 'airbnb', 'mixed', '["adventure", "nature", "hiking"]', '[]', '{"email": true, "push": false, "sms": true}'),
(3, 'budget', 'hostel', 'bus', '["culture", "history", "art"]', '["vegan"]', '{"email": false, "push": true, "sms": false}');

-- =============================================
-- UPDATE EXISTING TABLES WITH NEW FIELDS
-- =============================================

-- Add new fields to users table
ALTER TABLE users 
ADD COLUMN subscription_plan_id INT DEFAULT 1,
ADD COLUMN subscription_status ENUM('active', 'cancelled', 'expired', 'pending') DEFAULT 'active',
ADD COLUMN subscription_start_date DATE,
ADD COLUMN subscription_end_date DATE,
ADD COLUMN dark_mode_preference BOOLEAN DEFAULT FALSE,
ADD COLUMN language_preference VARCHAR(10) DEFAULT 'en',
ADD COLUMN timezone VARCHAR(50) DEFAULT 'UTC',
ADD FOREIGN KEY (subscription_plan_id) REFERENCES subscription_plans(id);

-- Add new fields to itineraries table
ALTER TABLE itineraries 
ADD COLUMN trip_type ENUM('leisure', 'business', 'adventure', 'romantic', 'family', 'solo') DEFAULT 'leisure',
ADD COLUMN travel_style ENUM('budget', 'mid_range', 'luxury') DEFAULT 'mid_range',
ADD COLUMN total_cost DECIMAL(10,2) DEFAULT 0.00,
ADD COLUMN spent_amount DECIMAL(10,2) DEFAULT 0.00,
ADD COLUMN currency VARCHAR(3) DEFAULT 'USD',
ADD COLUMN rating DECIMAL(3,2),
ADD COLUMN review_count INT DEFAULT 0,
ADD COLUMN photos_count INT DEFAULT 0,
ADD COLUMN is_favorite BOOLEAN DEFAULT FALSE,
ADD COLUMN highlights JSON,
ADD COLUMN activities JSON,
ADD COLUMN cover_image VARCHAR(500);

-- Add new fields to businesses table
ALTER TABLE businesses 
ADD COLUMN subscription_plan_id INT DEFAULT 1,
ADD COLUMN subscription_status ENUM('active', 'cancelled', 'expired', 'pending') DEFAULT 'active',
ADD COLUMN subscription_start_date DATE,
ADD COLUMN subscription_end_date DATE,
ADD FOREIGN KEY (subscription_plan_id) REFERENCES subscription_plans(id);

-- =============================================
-- CREATE ADDITIONAL VIEWS
-- =============================================

-- View for trip statistics
CREATE VIEW trip_statistics AS
SELECT 
    i.id,
    i.title,
    i.destination,
    i.start_date,
    i.end_date,
    i.budget,
    i.total_cost,
    i.spent_amount,
    i.rating,
    i.review_count,
    i.photos_count,
    i.trip_type,
    i.travel_style,
    u.first_name,
    u.last_name,
    DATEDIFF(i.end_date, i.start_date) as duration_days,
    CASE 
        WHEN i.total_cost > 0 THEN ROUND((i.spent_amount / i.total_cost) * 100, 2)
        ELSE 0 
    END as budget_utilization_percentage
FROM itineraries i
JOIN users u ON i.user_id = u.id
WHERE u.is_active = TRUE;

-- View for destination popularity
CREATE VIEW destination_popularity AS
SELECT 
    d.name,
    d.country,
    d.city,
    d.rating,
    d.review_count,
    COUNT(i.id) as trip_count,
    AVG(i.budget) as average_budget,
    AVG(i.rating) as average_trip_rating
FROM destinations d
LEFT JOIN itineraries i ON d.name = i.destination
WHERE d.is_active = TRUE
GROUP BY d.id, d.name, d.country, d.city, d.rating, d.review_count
ORDER BY trip_count DESC, d.rating DESC;

-- =============================================
-- CREATE ADDITIONAL STORED PROCEDURES
-- =============================================

-- Procedure to get user trip history
DELIMITER //
CREATE PROCEDURE GetUserTripHistory(IN user_id INT, IN limit_count INT)
BEGIN
    SELECT 
        i.id,
        i.title,
        i.destination,
        i.start_date,
        i.end_date,
        i.status,
        i.trip_type,
        i.total_cost,
        i.rating,
        i.photos_count,
        i.is_favorite,
        DATEDIFF(i.end_date, i.start_date) as duration_days
    FROM itineraries i
    WHERE i.user_id = user_id
    ORDER BY i.start_date DESC
    LIMIT limit_count;
END //
DELIMITER ;

-- Procedure to get popular destinations
DELIMITER //
CREATE PROCEDURE GetPopularDestinations(IN limit_count INT)
BEGIN
    SELECT 
        d.name,
        d.country,
        d.city,
        d.rating,
        d.review_count,
        d.average_budget_per_day,
        d.currency,
        d.image_url,
        d.highlights,
        COUNT(i.id) as trip_count
    FROM destinations d
    LEFT JOIN itineraries i ON d.name = i.destination
    WHERE d.is_featured = TRUE AND d.is_active = TRUE
    GROUP BY d.id
    ORDER BY d.rating DESC, trip_count DESC
    LIMIT limit_count;
END //
DELIMITER ;

-- =============================================
-- CREATE ADDITIONAL TRIGGERS
-- =============================================

-- Trigger to update itinerary statistics
DELIMITER //
CREATE TRIGGER update_itinerary_stats
AFTER INSERT ON trip_photos
FOR EACH ROW
BEGIN
    UPDATE itineraries 
    SET photos_count = photos_count + 1 
    WHERE id = NEW.itinerary_id;
END //
DELIMITER ;

-- Trigger to update destination review count
DELIMITER //
CREATE TRIGGER update_destination_reviews
AFTER INSERT ON reviews
FOR EACH ROW
BEGIN
    UPDATE destinations d
    JOIN itineraries i ON d.name = i.destination
    SET d.review_count = d.review_count + 1
    WHERE i.id = NEW.booking_id;
END //
DELIMITER ;

-- =============================================
-- CREATE ADDITIONAL INDEXES
-- =============================================

-- Indexes for new tables
CREATE INDEX idx_user_subscriptions_user_plan ON user_subscriptions(user_id, plan_id);
CREATE INDEX idx_user_subscriptions_status ON user_subscriptions(status);
CREATE INDEX idx_itinerary_categories_itinerary ON itinerary_categories(itinerary_id);
CREATE INDEX idx_destinations_featured ON destinations(is_featured, is_active);
CREATE INDEX idx_trip_photos_itinerary ON trip_photos(itinerary_id, is_public);
CREATE INDEX idx_expense_tracking_itinerary ON expense_tracking(itinerary_id, expense_date);

-- =============================================
-- END OF ENHANCED DATABASE SCHEMA
-- =============================================



