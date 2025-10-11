-- NaviGo Database Schema
-- Created for NaviGo Travel Planning Application
-- Version: 2.0
-- Updated: 2025-10-11
-- Features: Enhanced security, real-time messaging, social features, API support

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

-- Insert sample users with enhanced profiles
INSERT INTO users (first_name, last_name, email, password, phone, date_of_birth, bio, preferences, is_active, email_verified) VALUES
('John', 'Doe', 'john.doe@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+1234567890', '1990-05-15', 'Passionate traveler and food enthusiast', '{"interests": ["photography", "food", "history"], "travel_style": "budget", "languages": ["English", "Spanish"]}', TRUE, TRUE),
('Jane', 'Smith', 'jane.smith@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+1234567891', '1988-12-03', 'Adventure seeker and culture lover', '{"interests": ["adventure", "culture", "nature"], "travel_style": "luxury", "languages": ["English", "French"]}', TRUE, TRUE),
('Mike', 'Johnson', 'mike.johnson@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+1234567892', '1992-08-22', 'Business traveler and tech enthusiast', '{"interests": ["technology", "business", "networking"], "travel_style": "business", "languages": ["English", "Japanese"]}', TRUE, TRUE),
('Sarah', 'Williams', 'sarah.williams@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+1234567893', '1995-03-10', 'Solo traveler and blogger', '{"interests": ["photography", "writing", "solo_travel"], "travel_style": "backpacker", "languages": ["English", "Italian"]}', TRUE, TRUE),
('David', 'Brown', 'david.brown@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+1234567894', '1987-11-18', 'Family man and travel planner', '{"interests": ["family", "planning", "education"], "travel_style": "family", "languages": ["English", "German"]}', TRUE, TRUE);

-- Insert sample businesses with enhanced information
INSERT INTO businesses (business_name, business_type, contact_first_name, contact_last_name, email, password, phone, business_phone, website, business_address, city, state, country, postal_code, business_description, business_hours, amenities, social_media, is_active, is_verified, email_verified) VALUES
('Grand Hotel Paris', 'hotel', 'Marie', 'Dubois', 'contact@grandhotelparis.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+33123456789', '+33123456790', 'https://grandhotelparis.com', '123 Champs-Élysées, 75008 Paris', 'Paris', 'Île-de-France', 'France', '75008', 'Luxury hotel in the heart of Paris with stunning city views', '{"monday": "24/7", "tuesday": "24/7", "wednesday": "24/7", "thursday": "24/7", "friday": "24/7", "saturday": "24/7", "sunday": "24/7"}', '["wifi", "spa", "restaurant", "concierge", "gym", "pool"]', '{"facebook": "https://facebook.com/grandhotelparis", "instagram": "https://instagram.com/grandhotelparis"}', TRUE, TRUE, TRUE),
('Tokyo Sushi Bar', 'restaurant', 'Hiroshi', 'Tanaka', 'info@tokyosushibar.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+81312345678', '+81312345679', 'https://tokyosushibar.com', '456 Ginza Street, Chuo-ku', 'Tokyo', 'Tokyo', 'Japan', '104-0061', 'Authentic sushi experience with master chefs', '{"monday": "17:00-22:00", "tuesday": "17:00-22:00", "wednesday": "17:00-22:00", "thursday": "17:00-22:00", "friday": "17:00-22:00", "saturday": "17:00-22:00", "sunday": "closed"}', '["wifi", "private_dining", "sake_selection"]', '{"instagram": "https://instagram.com/tokyosushibar", "twitter": "https://twitter.com/tokyosushibar"}', TRUE, TRUE, TRUE),
('Adventure Tours NYC', 'tour', 'Sarah', 'Wilson', 'bookings@adventuretoursnyc.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+12125551234', '+12125551235', 'https://adventuretoursnyc.com', '789 Broadway, New York', 'New York', 'NY', 'USA', '10003', 'Exciting guided tours of New York City', '{"monday": "09:00-18:00", "tuesday": "09:00-18:00", "wednesday": "09:00-18:00", "thursday": "09:00-18:00", "friday": "09:00-18:00", "saturday": "09:00-20:00", "sunday": "09:00-18:00"}', '["professional_guides", "transportation", "equipment"]', '{"facebook": "https://facebook.com/adventuretoursnyc", "instagram": "https://instagram.com/adventuretoursnyc"}', TRUE, TRUE, TRUE),
('Bali Beach Resort', 'hotel', 'Made', 'Sutrisno', 'info@balibeachresort.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+62361234567', '+62361234568', 'https://balibeachresort.com', 'Beach Road, Seminyak', 'Seminyak', 'Bali', 'Indonesia', '80361', 'Tropical paradise with beachfront access', '{"monday": "24/7", "tuesday": "24/7", "wednesday": "24/7", "thursday": "24/7", "friday": "24/7", "saturday": "24/7", "sunday": "24/7"}', '["beach_access", "spa", "restaurant", "pool", "wifi", "airport_transfer"]', '{"facebook": "https://facebook.com/balibeachresort", "instagram": "https://instagram.com/balibeachresort"}', TRUE, TRUE, TRUE);

-- Insert sample itineraries with more realistic dates
INSERT INTO itineraries (user_id, title, description, destination, start_date, end_date, budget, currency, status, is_public) VALUES
(1, 'Paris Adventure', 'A romantic getaway to the City of Light', 'Paris, France', '2024-06-01', '2024-06-07', 2500.00, 'USD', 'planning', TRUE),
(2, 'Tokyo Food Tour', 'Exploring the culinary delights of Tokyo', 'Tokyo, Japan', '2024-07-15', '2024-07-22', 3000.00, 'USD', 'confirmed', TRUE),
(3, 'NYC Weekend', 'Quick weekend trip to New York', 'New York, USA', '2024-05-10', '2024-05-12', 800.00, 'USD', 'completed', FALSE),
(4, 'Bali Retreat', 'Relaxing beach vacation in Bali', 'Bali, Indonesia', '2024-08-20', '2024-08-27', 1800.00, 'USD', 'planning', TRUE),
(5, 'European Grand Tour', 'Multi-city European adventure', 'Europe', '2024-09-01', '2024-09-15', 5000.00, 'USD', 'planning', TRUE);

-- Insert sample business services
INSERT INTO business_services (business_id, service_name, service_type, description, price, currency, duration_hours, capacity, location, address, latitude, longitude, amenities, availability_schedule, is_active) VALUES
(1, 'Deluxe Room', 'accommodation', 'Spacious room with city view', 200.00, 'USD', 24.00, 2, 'Paris, France', '123 Champs-Élysées, 75008 Paris', 48.8566, 2.3522, '["wifi", "minibar", "room_service", "city_view"]', '{"monday": "available", "tuesday": "available", "wednesday": "available", "thursday": "available", "friday": "available", "saturday": "available", "sunday": "available"}', TRUE),
(1, 'Spa Package', 'activity', 'Relaxing spa treatment', 150.00, 'USD', 2.00, 1, 'Paris, France', '123 Champs-Élysées, 75008 Paris', 48.8566, 2.3522, '["massage", "sauna", "steam_room"]', '{"monday": "10:00-20:00", "tuesday": "10:00-20:00", "wednesday": "10:00-20:00", "thursday": "10:00-20:00", "friday": "10:00-20:00", "saturday": "10:00-20:00", "sunday": "10:00-18:00"}', TRUE),
(2, 'Omakase Dinner', 'restaurant', 'Chef\'s choice sushi experience', 120.00, 'USD', 2.00, 8, 'Tokyo, Japan', '456 Ginza Street, Chuo-ku', 35.6762, 139.6503, '["private_dining", "sake_pairing", "chef_interaction"]', '{"monday": "17:00-22:00", "tuesday": "17:00-22:00", "wednesday": "17:00-22:00", "thursday": "17:00-22:00", "friday": "17:00-22:00", "saturday": "17:00-22:00", "sunday": "closed"}', TRUE),
(3, 'City Walking Tour', 'tour', 'Guided walking tour of Manhattan', 50.00, 'USD', 3.00, 20, 'New York, USA', '789 Broadway, New York', 40.7589, -73.9851, '["professional_guide", "small_group", "historical_info"]', '{"monday": "09:00-18:00", "tuesday": "09:00-18:00", "wednesday": "09:00-18:00", "thursday": "09:00-18:00", "friday": "09:00-18:00", "saturday": "09:00-20:00", "sunday": "09:00-18:00"}', TRUE),
(4, 'Beachfront Villa', 'accommodation', 'Luxury villa with private beach access', 300.00, 'USD', 24.00, 6, 'Seminyak, Bali', 'Beach Road, Seminyak', -8.6872, 115.1714, '["private_beach", "pool", "kitchen", "wifi", "air_conditioning"]', '{"monday": "available", "tuesday": "available", "wednesday": "available", "thursday": "available", "friday": "available", "saturday": "available", "sunday": "available"}', TRUE);

-- Insert sample saved places
INSERT INTO saved_places (user_id, name, description, location, address, latitude, longitude, place_type, rating, price_level, website, phone, notes, tags) VALUES
(1, 'Eiffel Tower', 'Iconic iron lattice tower', 'Paris, France', 'Champ de Mars, 7th arrondissement, Paris', 48.8584, 2.2945, 'attraction', 4.8, 2, 'https://toureiffel.paris', '+33144112345', 'Must visit at sunset for the best photos', '["landmark", "romantic", "photography", "sunset"]'),
(2, 'Tsukiji Fish Market', 'Famous fish market', 'Tokyo, Japan', '5-2-1 Tsukiji, Chuo City, Tokyo', 35.6654, 139.7706, 'attraction', 4.5, 1, 'https://tsukiji.or.jp', '+81335420011', 'Best sushi in the world - arrive early!', '["food", "market", "culture", "early_morning"]'),
(3, 'Central Park', 'Large public park', 'New York, USA', 'Central Park, New York, NY', 40.7829, -73.9654, 'attraction', 4.7, 0, 'https://centralparknyc.org', '+12123106000', 'Great for morning runs and picnics', '["park", "nature", "exercise", "free"]'),
(4, 'Ubud Monkey Forest', 'Sacred monkey sanctuary', 'Ubud, Bali', 'Jl. Monkey Forest, Ubud, Bali', -8.5193, 115.2636, 'attraction', 4.3, 1, 'https://monkeyforestubud.com', '+62361971304', 'Amazing experience with friendly monkeys', '["nature", "wildlife", "culture", "photography"]'),
(5, 'Sagrada Familia', 'Unfinished basilica', 'Barcelona, Spain', 'Carrer de Mallorca, 401, Barcelona', 41.4036, 2.1744, 'attraction', 4.6, 2, 'https://sagradafamilia.org', '+34932080708', 'Gaudi\'s masterpiece - book tickets in advance', '["architecture", "religious", "art", "gaudi"]');

-- Insert sample wishlists
INSERT INTO wishlists (user_id, name, description, is_public, is_shared) VALUES
(1, 'European Dream Destinations', 'Places I want to visit in Europe', TRUE, FALSE),
(2, 'Foodie Adventures', 'Restaurants and food experiences to try', TRUE, TRUE),
(3, 'Adventure Sports', 'Thrilling activities around the world', FALSE, FALSE),
(4, 'Photography Spots', 'Beautiful locations for photography', TRUE, FALSE),
(5, 'Family Friendly Places', 'Destinations suitable for family travel', TRUE, FALSE);

-- Insert sample wishlist items
INSERT INTO wishlist_items (wishlist_id, name, description, location, place_type, price_range, priority, notes, target_date) VALUES
(1, 'Santorini Sunset', 'Watch the famous sunset in Oia', 'Santorini, Greece', 'destination', '$$$', 'high', 'Must visit during summer months', '2024-08-15'),
(1, 'Northern Lights', 'See the aurora borealis', 'Tromsø, Norway', 'activity', '$$$$', 'medium', 'Best time is winter, need warm clothes', '2024-12-01'),
(2, 'Jiro Sushi', 'World-famous sushi restaurant', 'Tokyo, Japan', 'restaurant', '$$$$', 'high', 'Need reservations months in advance', '2024-10-01'),
(2, 'Street Food Tour', 'Explore local street food', 'Bangkok, Thailand', 'activity', '$$', 'medium', 'Best to go with a local guide', '2024-09-01'),
(3, 'Skydiving', 'Jump from a plane', 'Interlaken, Switzerland', 'activity', '$$$', 'high', 'Need to be physically fit', '2024-07-01'),
(4, 'Machu Picchu', 'Ancient Incan city', 'Cusco, Peru', 'attraction', '$$$', 'high', 'Book permits in advance', '2024-06-01'),
(5, 'Disneyland Paris', 'Family theme park', 'Paris, France', 'attraction', '$$$', 'medium', 'Great for kids, book fast passes', '2024-08-01');

-- Insert sample travel documents
INSERT INTO travel_documents (user_id, document_type, document_number, issuing_country, issue_date, expiry_date, is_verified, notes) VALUES
(1, 'passport', 'P123456789', 'USA', '2020-01-15', '2030-01-15', TRUE, 'Valid for 10 years'),
(2, 'passport', 'P987654321', 'Canada', '2019-06-20', '2029-06-20', TRUE, 'Canadian passport'),
(3, 'passport', 'P456789123', 'UK', '2021-03-10', '2031-03-10', TRUE, 'British passport'),
(4, 'visa', 'V123456', 'Japan', '2024-01-01', '2024-12-31', TRUE, 'Tourist visa for Japan'),
(5, 'passport', 'P789123456', 'Australia', '2022-09-05', '2032-09-05', TRUE, 'Australian passport');

-- Insert sample user posts
INSERT INTO user_posts (user_id, content, post_type, location, latitude, longitude, is_public, is_featured) VALUES
(1, 'Just had the most amazing croissant in Paris! The buttery layers were perfect. #Paris #Foodie #Travel', 'travel_experience', 'Paris, France', 48.8566, 2.3522, TRUE, FALSE),
(2, 'Tokyo\'s cherry blossoms are absolutely breathtaking this season. Nature\'s beauty at its finest! 🌸 #Tokyo #CherryBlossoms #Japan', 'photo', 'Tokyo, Japan', 35.6762, 139.6503, TRUE, TRUE),
(3, 'Pro tip: Always book your accommodation near public transport. It saves so much time and money! #TravelTips #BudgetTravel', 'tip', 'New York, USA', 40.7589, -73.9851, TRUE, FALSE),
(4, 'The sunset in Bali is magical. Watching it from the beach with a coconut in hand - pure bliss! 🌅 #Bali #Sunset #Beach', 'travel_experience', 'Bali, Indonesia', -8.5193, 115.2636, TRUE, FALSE),
(5, 'Family travel tip: Pack extra snacks and entertainment for kids during long flights. It\'s a lifesaver! #FamilyTravel #Kids #TravelTips', 'tip', 'Barcelona, Spain', 41.4036, 2.1744, TRUE, FALSE);

-- Insert sample user follows
INSERT INTO user_follows (follower_id, following_id) VALUES
(1, 2), (1, 3), (2, 1), (2, 4), (3, 1), (3, 5), (4, 2), (4, 3), (5, 1), (5, 4);

-- Insert sample chat rooms
INSERT INTO chat_rooms (name, description, room_type, group_id, business_id, created_by) VALUES
('Paris Adventure Group', 'Chat for our Paris trip planning', 'group_travel', 1, NULL, 1),
('Customer Support', 'General customer support chat', 'user_support', NULL, NULL, 2),
('Business Inquiries', 'Chat with our business team', 'business_support', NULL, 1, 3);

-- Insert sample chat participants
INSERT INTO chat_participants (room_id, user_id, business_id, role) VALUES
(1, 1, NULL, 'admin'), (1, 2, NULL, 'member'), (1, 3, NULL, 'member'),
(2, 1, NULL, 'member'), (2, 2, NULL, 'member'), (2, 3, NULL, 'member'),
(3, NULL, 1, 'admin'), (3, 1, NULL, 'member'), (3, 2, NULL, 'member');

-- Insert sample chat messages
INSERT INTO chat_messages (room_id, user_id, business_id, message, message_type) VALUES
(1, 1, NULL, 'Welcome everyone to our Paris adventure planning!', 'text'),
(1, 2, NULL, 'Excited to be part of this trip!', 'text'),
(1, 3, NULL, 'What are we planning to see first?', 'text'),
(2, 1, NULL, 'I need help with my booking', 'text'),
(3, NULL, 1, 'Hello! How can we assist you today?', 'text');

-- Insert sample API keys
INSERT INTO api_keys (user_id, business_id, key_name, api_key, secret_key, permissions, rate_limit_per_hour, is_active) VALUES
(1, NULL, 'Personal API Key', 'pk_test_1234567890abcdef', 'sk_test_1234567890abcdef', '["read:profile", "read:itineraries", "write:bookings"]', 1000, TRUE),
(NULL, 1, 'Business API Key', 'pk_business_1234567890abcdef', 'sk_business_1234567890abcdef', '["read:bookings", "write:services", "read:analytics"]', 5000, TRUE),
(2, NULL, 'Travel App Integration', 'pk_app_1234567890abcdef', 'sk_app_1234567890abcdef', '["read:itineraries", "read:places", "write:posts"]', 2000, TRUE);

-- Insert sample webhooks
INSERT INTO webhooks (business_id, webhook_url, events, secret_token, is_active) VALUES
(1, 'https://grandhotelparis.com/webhooks/bookings', '["booking.created", "booking.updated", "booking.cancelled"]', 'whsec_1234567890abcdef', TRUE),
(2, 'https://tokyosushibar.com/webhooks/reservations', '["reservation.created", "reservation.confirmed"]', 'whsec_9876543210fedcba', TRUE),
(3, 'https://adventuretoursnyc.com/webhooks/tours', '["tour.booked", "tour.completed"]', 'whsec_abcdef1234567890', TRUE);

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
-- SECURITY ENHANCEMENTS
-- =============================================

-- Password policies table
CREATE TABLE password_policies (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    business_id INT,
    min_length INT DEFAULT 8,
    require_uppercase BOOLEAN DEFAULT TRUE,
    require_lowercase BOOLEAN DEFAULT TRUE,
    require_numbers BOOLEAN DEFAULT TRUE,
    require_special_chars BOOLEAN DEFAULT TRUE,
    max_age_days INT DEFAULT 90,
    prevent_reuse_count INT DEFAULT 5,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE
);

-- Audit logs table
CREATE TABLE audit_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    business_id INT,
    action VARCHAR(100) NOT NULL,
    table_name VARCHAR(50),
    record_id INT,
    old_values JSON,
    new_values JSON,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE SET NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_business_id (business_id),
    INDEX idx_action (action),
    INDEX idx_created_at (created_at)
);

-- Rate limiting table
CREATE TABLE rate_limits (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    business_id INT,
    endpoint VARCHAR(100) NOT NULL,
    request_count INT DEFAULT 1,
    window_start TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    window_end TIMESTAMP,
    is_blocked BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
    INDEX idx_user_endpoint (user_id, endpoint),
    INDEX idx_business_endpoint (business_id, endpoint),
    INDEX idx_window (window_start, window_end)
);

-- =============================================
-- NEW FEATURES TABLES
-- =============================================

-- Chat/Messaging system
CREATE TABLE chat_rooms (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    room_type ENUM('group_travel', 'business_support', 'user_support', 'general') NOT NULL,
    group_id INT,
    business_id INT,
    is_active BOOLEAN DEFAULT TRUE,
    created_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (group_id) REFERENCES group_travels(id) ON DELETE CASCADE,
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_room_type (room_type),
    INDEX idx_group_id (group_id),
    INDEX idx_business_id (business_id)
);

CREATE TABLE chat_messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    room_id INT NOT NULL,
    user_id INT NOT NULL,
    business_id INT,
    message TEXT NOT NULL,
    message_type ENUM('text', 'image', 'file', 'system') DEFAULT 'text',
    file_url VARCHAR(255),
    is_edited BOOLEAN DEFAULT FALSE,
    edited_at TIMESTAMP NULL,
    reply_to INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (room_id) REFERENCES chat_rooms(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
    FOREIGN KEY (reply_to) REFERENCES chat_messages(id) ON DELETE SET NULL,
    INDEX idx_room_id (room_id),
    INDEX idx_user_id (user_id),
    INDEX idx_created_at (created_at)
);

CREATE TABLE chat_participants (
    id INT AUTO_INCREMENT PRIMARY KEY,
    room_id INT NOT NULL,
    user_id INT,
    business_id INT,
    role ENUM('admin', 'moderator', 'member') DEFAULT 'member',
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_read_at TIMESTAMP NULL,
    is_muted BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (room_id) REFERENCES chat_rooms(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
    UNIQUE KEY unique_room_user (room_id, user_id),
    UNIQUE KEY unique_room_business (room_id, business_id),
    INDEX idx_room_id (room_id)
);

-- Wishlists table
CREATE TABLE wishlists (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    is_public BOOLEAN DEFAULT FALSE,
    is_shared BOOLEAN DEFAULT FALSE,
    share_token VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_public (is_public)
);

CREATE TABLE wishlist_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    wishlist_id INT NOT NULL,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    location VARCHAR(200),
    address TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    place_type ENUM('restaurant', 'attraction', 'hotel', 'activity', 'destination') NOT NULL,
    price_range ENUM('$', '$$', '$$$', '$$$$'),
    priority ENUM('low', 'medium', 'high') DEFAULT 'medium',
    notes TEXT,
    target_date DATE,
    is_visited BOOLEAN DEFAULT FALSE,
    visited_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (wishlist_id) REFERENCES wishlists(id) ON DELETE CASCADE,
    INDEX idx_wishlist_id (wishlist_id),
    INDEX idx_place_type (place_type),
    INDEX idx_priority (priority)
);

-- Travel documents table
CREATE TABLE travel_documents (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    document_type ENUM('passport', 'visa', 'id_card', 'driver_license', 'insurance', 'other') NOT NULL,
    document_number VARCHAR(100) NOT NULL,
    issuing_country VARCHAR(50) NOT NULL,
    issue_date DATE,
    expiry_date DATE,
    document_image VARCHAR(255),
    is_verified BOOLEAN DEFAULT FALSE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_document_type (document_type),
    INDEX idx_expiry_date (expiry_date)
);

-- Social features
CREATE TABLE user_follows (
    id INT AUTO_INCREMENT PRIMARY KEY,
    follower_id INT NOT NULL,
    following_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (follower_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (following_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_follow (follower_id, following_id),
    INDEX idx_follower_id (follower_id),
    INDEX idx_following_id (following_id)
);

CREATE TABLE user_posts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    post_type ENUM('travel_experience', 'tip', 'review', 'photo', 'video') NOT NULL,
    location VARCHAR(200),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    is_public BOOLEAN DEFAULT TRUE,
    is_featured BOOLEAN DEFAULT FALSE,
    likes_count INT DEFAULT 0,
    comments_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_post_type (post_type),
    INDEX idx_public (is_public),
    INDEX idx_created_at (created_at)
);

CREATE TABLE post_likes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES user_posts(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_post_like (post_id, user_id),
    INDEX idx_post_id (post_id),
    INDEX idx_user_id (user_id)
);

CREATE TABLE post_comments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    parent_id INT,
    is_edited BOOLEAN DEFAULT FALSE,
    edited_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES user_posts(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (parent_id) REFERENCES post_comments(id) ON DELETE CASCADE,
    INDEX idx_post_id (post_id),
    INDEX idx_user_id (user_id),
    INDEX idx_parent_id (parent_id)
);

-- =============================================
-- API AND INTEGRATION TABLES
-- =============================================

-- API keys table
CREATE TABLE api_keys (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    business_id INT,
    key_name VARCHAR(100) NOT NULL,
    api_key VARCHAR(255) UNIQUE NOT NULL,
    secret_key VARCHAR(255),
    permissions JSON,
    rate_limit_per_hour INT DEFAULT 1000,
    is_active BOOLEAN DEFAULT TRUE,
    expires_at TIMESTAMP NULL,
    last_used_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
    INDEX idx_api_key (api_key),
    INDEX idx_user_id (user_id),
    INDEX idx_business_id (business_id),
    INDEX idx_is_active (is_active)
);

-- Webhooks table
CREATE TABLE webhooks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    business_id INT NOT NULL,
    webhook_url VARCHAR(255) NOT NULL,
    events JSON NOT NULL,
    secret_token VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    retry_count INT DEFAULT 3,
    timeout_seconds INT DEFAULT 30,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
    INDEX idx_business_id (business_id),
    INDEX idx_is_active (is_active)
);

CREATE TABLE webhook_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    webhook_id INT NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    payload JSON,
    response_status INT,
    response_body TEXT,
    attempt_count INT DEFAULT 1,
    is_successful BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (webhook_id) REFERENCES webhooks(id) ON DELETE CASCADE,
    INDEX idx_webhook_id (webhook_id),
    INDEX idx_event_type (event_type),
    INDEX idx_created_at (created_at)
);

-- =============================================
-- ENHANCED INDEXES FOR PERFORMANCE
-- =============================================

-- Composite indexes for better query performance
CREATE INDEX idx_users_email_active ON users(email, is_active);
CREATE INDEX idx_businesses_type_verified ON businesses(business_type, is_verified, is_active);
CREATE INDEX idx_itineraries_user_status_dates ON itineraries(user_id, status, start_date, end_date);
CREATE INDEX idx_bookings_user_status_date ON bookings(user_id, status, booking_date);
CREATE INDEX idx_reviews_business_rating_public ON reviews(business_id, rating, is_public);
CREATE INDEX idx_notifications_user_type_read ON notifications(user_id, type, is_read, created_at);

-- Full-text search indexes
CREATE FULLTEXT INDEX idx_users_search ON users(first_name, last_name, email);
CREATE FULLTEXT INDEX idx_businesses_search ON businesses(business_name, business_description);
CREATE FULLTEXT INDEX idx_itineraries_search ON itineraries(title, description, destination);
CREATE FULLTEXT INDEX idx_posts_search ON user_posts(content);

-- =============================================
-- ENHANCED STORED PROCEDURES
-- =============================================

-- Procedure to get comprehensive user dashboard data
DELIMITER //
CREATE PROCEDURE GetUserDashboardData(IN user_id INT)
BEGIN
    SELECT 
        u.id,
        u.first_name,
        u.last_name,
        u.email,
        u.profile_picture,
        u.last_login,
        COUNT(DISTINCT i.id) as total_itineraries,
        COUNT(DISTINCT sp.id) as total_saved_places,
        COUNT(DISTINCT w.id) as total_wishlists,
        COUNT(DISTINCT gt.id) as total_group_travels,
        COUNT(DISTINCT b.id) as total_bookings,
        COUNT(DISTINCT p.id) as total_posts,
        COUNT(DISTINCT f.following_id) as following_count,
        COUNT(DISTINCT f2.follower_id) as followers_count
    FROM users u
    LEFT JOIN itineraries i ON u.id = i.user_id
    LEFT JOIN saved_places sp ON u.id = sp.user_id
    LEFT JOIN wishlists w ON u.id = w.user_id
    LEFT JOIN group_travels gt ON u.id = gt.creator_id
    LEFT JOIN bookings b ON u.id = b.user_id
    LEFT JOIN user_posts p ON u.id = p.user_id
    LEFT JOIN user_follows f ON u.id = f.follower_id
    LEFT JOIN user_follows f2 ON u.id = f2.following_id
    WHERE u.id = user_id AND u.is_active = TRUE
    GROUP BY u.id;
END //
DELIMITER ;

-- Procedure to get business analytics
DELIMITER //
CREATE PROCEDURE GetBusinessAnalytics(IN business_id INT, IN start_date DATE, IN end_date DATE)
BEGIN
    SELECT 
        b.business_name,
        COUNT(DISTINCT bs.id) as total_services,
        COUNT(DISTINCT bk.id) as total_bookings,
        COUNT(DISTINCT r.id) as total_reviews,
        AVG(r.rating) as average_rating,
        SUM(bk.total_amount) as total_revenue,
        COUNT(DISTINCT CASE WHEN bk.created_at >= start_date AND bk.created_at <= end_date THEN bk.id END) as bookings_in_period,
        SUM(CASE WHEN bk.created_at >= start_date AND bk.created_at <= end_date THEN bk.total_amount ELSE 0 END) as revenue_in_period
    FROM businesses b
    LEFT JOIN business_services bs ON b.id = bs.business_id AND bs.is_active = TRUE
    LEFT JOIN bookings bk ON b.id = bk.business_id
    LEFT JOIN reviews r ON b.id = r.business_id
    WHERE b.id = business_id AND b.is_active = TRUE
    GROUP BY b.id;
END //
DELIMITER ;

-- =============================================
-- ENHANCED TRIGGERS
-- =============================================

-- Trigger to update post like count
DELIMITER //
CREATE TRIGGER update_post_like_count
AFTER INSERT ON post_likes
FOR EACH ROW
BEGIN
    UPDATE user_posts 
    SET likes_count = likes_count + 1 
    WHERE id = NEW.post_id;
END //
DELIMITER ;

-- Trigger to decrease post like count
DELIMITER //
CREATE TRIGGER decrease_post_like_count
AFTER DELETE ON post_likes
FOR EACH ROW
BEGIN
    UPDATE user_posts 
    SET likes_count = likes_count - 1 
    WHERE id = OLD.post_id;
END //
DELIMITER ;

-- Trigger to update post comment count
DELIMITER //
CREATE TRIGGER update_post_comment_count
AFTER INSERT ON post_comments
FOR EACH ROW
BEGIN
    UPDATE user_posts 
    SET comments_count = comments_count + 1 
    WHERE id = NEW.post_id;
END //
DELIMITER ;

-- Trigger to decrease post comment count
DELIMITER //
CREATE TRIGGER decrease_post_comment_count
AFTER DELETE ON post_comments
FOR EACH ROW
BEGIN
    UPDATE user_posts 
    SET comments_count = comments_count - 1 
    WHERE id = OLD.post_id;
END //
DELIMITER ;

-- =============================================
-- GRANT PERMISSIONS (Adjust as needed)
-- =============================================

-- Create application user (uncomment and modify as needed)
-- CREATE USER 'navigo_user'@'localhost' IDENTIFIED BY 'secure_password';
-- GRANT SELECT, INSERT, UPDATE, DELETE ON navigo_db.* TO 'navigo_user'@'localhost';
-- FLUSH PRIVILEGES;

-- =============================================
-- END OF DATABASE SCHEMA
-- =============================================
