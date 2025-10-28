-- phpMyAdmin SQL Dump
-- version 0.0.7
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Oct 28, 2025 at 4:43 PM
-- Last Updated: Oct 28, 2025
-- Update Note: Database schema updated via installer (install.php update)
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `navigo_db`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetBusinessStats` (IN `business_id` INT)   BEGIN
    SELECT 
        (SELECT COUNT(*) FROM business_services WHERE business_id = business_id AND is_active = TRUE) as services_count,
        (SELECT COUNT(*) FROM bookings WHERE business_id = business_id) as bookings_count,
        (SELECT AVG(rating) FROM reviews WHERE business_id = business_id) as average_rating,
        (SELECT COUNT(*) FROM reviews WHERE business_id = business_id) as reviews_count;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetPopularDestinations` (IN `limit_count` INT)   BEGIN
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
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetUserProfile` (IN `user_id` INT)   BEGIN
    SELECT * FROM user_complete_profile WHERE id = user_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetUserStats` (IN `user_id` INT)   BEGIN
    SELECT 
        (SELECT COUNT(*) FROM itineraries WHERE user_id = user_id) as itinerary_count,
        (SELECT COUNT(*) FROM saved_places WHERE user_id = user_id) as saved_places_count,
        (SELECT COUNT(*) FROM group_travels WHERE creator_id = user_id) as group_travels_count,
        (SELECT COUNT(*) FROM bookings WHERE user_id = user_id) as booking_count;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetUserTripHistory` (IN `user_id` INT, IN `limit_count` INT)   BEGIN
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
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateUserProfile` (IN `p_user_id` INT, IN `p_first_name` VARCHAR(50), IN `p_last_name` VARCHAR(50), IN `p_phone` VARCHAR(20), IN `p_location` VARCHAR(200), IN `p_bio` TEXT, IN `p_timezone` VARCHAR(50), IN `p_date_format` ENUM('MM/DD/YYYY','DD/MM/YYYY','YYYY-MM-DD'), IN `p_currency` VARCHAR(3))   BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Update users table
    UPDATE users 
    SET first_name = p_first_name, last_name = p_last_name, updated_at = NOW()
    WHERE id = p_user_id;
    
    -- Update or insert profile settings
    INSERT INTO user_profile_settings (user_id, phone, location, bio, timezone, date_format, currency)
    VALUES (p_user_id, p_phone, p_location, p_bio, p_timezone, p_date_format, p_currency)
    ON DUPLICATE KEY UPDATE
        phone = p_phone,
        location = p_location,
        bio = p_bio,
        timezone = p_timezone,
        date_format = p_date_format,
        currency = p_currency,
        updated_at = NOW();
    
    COMMIT;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `analytics`
--

CREATE TABLE `analytics` (
  `id` int(11) NOT NULL,
  `business_id` int(11) NOT NULL,
  `metric_type` enum('views','bookings','revenue','reviews','rating') NOT NULL,
  `metric_value` decimal(15,2) NOT NULL,
  `date_recorded` date NOT NULL,
  `additional_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`additional_data`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `billing_history`
--

CREATE TABLE `billing_history` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `subscription_id` int(11) DEFAULT NULL,
  `invoice_number` varchar(50) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `currency` varchar(3) DEFAULT 'USD',
  `billing_date` date NOT NULL,
  `due_date` date NOT NULL,
  `status` enum('pending','paid','failed','cancelled','refunded') DEFAULT 'pending',
  `payment_method` varchar(50) DEFAULT NULL,
  `payment_reference` varchar(100) DEFAULT NULL,
  `invoice_url` varchar(500) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `bookings`
--

CREATE TABLE `bookings` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `business_id` int(11) NOT NULL,
  `service_id` int(11) DEFAULT NULL,
  `itinerary_id` int(11) DEFAULT NULL,
  `booking_reference` varchar(50) NOT NULL,
  `service_name` varchar(200) NOT NULL,
  `booking_date` date NOT NULL,
  `check_in_date` date DEFAULT NULL,
  `check_out_date` date DEFAULT NULL,
  `quantity` int(11) DEFAULT 1,
  `total_amount` decimal(10,2) NOT NULL,
  `currency` varchar(3) DEFAULT 'USD',
  `status` enum('pending','confirmed','cancelled','completed','refunded') DEFAULT 'pending',
  `payment_status` enum('pending','paid','failed','refunded') DEFAULT 'pending',
  `payment_method` varchar(50) DEFAULT NULL,
  `payment_reference` varchar(100) DEFAULT NULL,
  `special_requests` text DEFAULT NULL,
  `cancellation_policy` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `businesses`
--

CREATE TABLE `businesses` (
  `id` int(11) NOT NULL,
  `business_name` varchar(100) NOT NULL,
  `business_type` enum('hotel','restaurant','tour','transport','other') NOT NULL,
  `contact_first_name` varchar(50) NOT NULL,
  `contact_last_name` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `business_phone` varchar(20) DEFAULT NULL,
  `website` varchar(255) DEFAULT NULL,
  `business_address` text DEFAULT NULL,
  `city` varchar(50) DEFAULT NULL,
  `state` varchar(50) DEFAULT NULL,
  `country` varchar(50) DEFAULT NULL,
  `postal_code` varchar(20) DEFAULT NULL,
  `business_description` text DEFAULT NULL,
  `business_hours` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`business_hours`)),
  `amenities` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`amenities`)),
  `social_media` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`social_media`)),
  `is_active` tinyint(1) DEFAULT 1,
  `is_verified` tinyint(1) DEFAULT 0,
  `verification_documents` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`verification_documents`)),
  `email_verified` tinyint(1) DEFAULT 0,
  `verification_token` varchar(100) DEFAULT NULL,
  `reset_token` varchar(100) DEFAULT NULL,
  `reset_token_expires` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `last_login` timestamp NULL DEFAULT NULL,
  `subscription_plan_id` int(11) DEFAULT 1,
  `subscription_status` enum('active','cancelled','expired','pending') DEFAULT 'active',
  `subscription_start_date` date DEFAULT NULL,
  `subscription_end_date` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `businesses`
--

INSERT INTO `businesses` (`id`, `business_name`, `business_type`, `contact_first_name`, `contact_last_name`, `email`, `password`, `phone`, `business_phone`, `website`, `business_address`, `city`, `state`, `country`, `postal_code`, `business_description`, `business_hours`, `amenities`, `social_media`, `is_active`, `is_verified`, `verification_documents`, `email_verified`, `verification_token`, `reset_token`, `reset_token_expires`, `created_at`, `updated_at`, `last_login`, `subscription_plan_id`, `subscription_status`, `subscription_start_date`, `subscription_end_date`) VALUES
(1, 'Grand Hotel Paris', 'hotel', 'Marie', 'Dubois', 'contact@grandhotelparis.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+33123456789', NULL, NULL, NULL, 'Paris', NULL, 'France', NULL, NULL, NULL, NULL, NULL, 1, 1, NULL, 1, NULL, NULL, NULL, '2025-10-16 10:19:04', '2025-10-16 10:19:04', NULL, 1, 'active', NULL, NULL),
(2, 'Tokyo Sushi Bar', 'restaurant', 'Hiroshi', 'Tanaka', 'info@tokyosushibar.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+81312345678', NULL, NULL, NULL, 'Tokyo', NULL, 'Japan', NULL, NULL, NULL, NULL, NULL, 1, 1, NULL, 1, NULL, NULL, NULL, '2025-10-16 10:19:04', '2025-10-16 10:19:04', NULL, 1, 'active', NULL, NULL),
(3, 'Adventure Tours NYC', 'tour', 'Sarah', 'Wilson', 'bookings@adventuretoursnyc.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+12125551234', NULL, NULL, NULL, 'New York', NULL, 'USA', NULL, NULL, NULL, NULL, NULL, 1, 1, NULL, 1, NULL, NULL, NULL, '2025-10-16 10:19:04', '2025-10-16 10:19:04', NULL, 1, 'active', NULL, NULL);

-- --------------------------------------------------------

--
-- Stand-in structure for view `business_dashboard_data`
-- (See below for the actual view)
--
CREATE TABLE `business_dashboard_data` (
`id` int(11)
,`business_name` varchar(100)
,`business_type` enum('hotel','restaurant','tour','transport','other')
,`email` varchar(100)
,`total_services` bigint(21)
,`total_bookings` bigint(21)
,`average_rating` decimal(14,4)
,`total_reviews` bigint(21)
,`last_login` timestamp
);

-- --------------------------------------------------------

--
-- Table structure for table `business_services`
--

CREATE TABLE `business_services` (
  `id` int(11) NOT NULL,
  `business_id` int(11) NOT NULL,
  `service_name` varchar(200) NOT NULL,
  `service_type` enum('accommodation','restaurant','tour','transport','activity','other') NOT NULL,
  `description` text DEFAULT NULL,
  `price` decimal(10,2) DEFAULT NULL,
  `currency` varchar(3) DEFAULT 'USD',
  `duration_hours` decimal(5,2) DEFAULT NULL,
  `capacity` int(11) DEFAULT NULL,
  `location` varchar(200) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `amenities` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`amenities`)),
  `availability_schedule` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`availability_schedule`)),
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `business_services`
--

INSERT INTO `business_services` (`id`, `business_id`, `service_name`, `service_type`, `description`, `price`, `currency`, `duration_hours`, `capacity`, `location`, `address`, `latitude`, `longitude`, `amenities`, `availability_schedule`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 1, 'Deluxe Room', 'accommodation', 'Spacious room with city view', 200.00, 'USD', 24.00, NULL, 'Paris, France', NULL, NULL, NULL, NULL, NULL, 1, '2025-10-16 10:19:04', '2025-10-16 10:19:04'),
(2, 1, 'Spa Package', 'activity', 'Relaxing spa treatment', 150.00, 'USD', 2.00, NULL, 'Paris, France', NULL, NULL, NULL, NULL, NULL, 1, '2025-10-16 10:19:04', '2025-10-16 10:19:04'),
(3, 2, 'Omakase Dinner', 'restaurant', 'Chef\'s choice sushi experience', 120.00, 'USD', 2.00, NULL, 'Tokyo, Japan', NULL, NULL, NULL, NULL, NULL, 1, '2025-10-16 10:19:04', '2025-10-16 10:19:04'),
(4, 3, 'City Walking Tour', 'tour', 'Guided walking tour of Manhattan', 50.00, 'USD', 3.00, NULL, 'New York, USA', NULL, NULL, NULL, NULL, NULL, 1, '2025-10-16 10:19:04', '2025-10-16 10:19:04');

-- --------------------------------------------------------

--
-- Table structure for table `destinations`
--

CREATE TABLE `destinations` (
  `id` int(11) NOT NULL,
  `name` varchar(200) NOT NULL,
  `country` varchar(100) NOT NULL,
  `city` varchar(100) DEFAULT NULL,
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `best_time_to_visit` varchar(100) DEFAULT NULL,
  `average_budget_per_day` decimal(10,2) DEFAULT NULL,
  `currency` varchar(3) DEFAULT 'USD',
  `rating` decimal(3,2) DEFAULT NULL,
  `review_count` int(11) DEFAULT 0,
  `image_url` varchar(500) DEFAULT NULL,
  `highlights` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`highlights`)),
  `is_featured` tinyint(1) DEFAULT 0,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `destinations`
--

INSERT INTO `destinations` (`id`, `name`, `country`, `city`, `latitude`, `longitude`, `description`, `best_time_to_visit`, `average_budget_per_day`, `currency`, `rating`, `review_count`, `image_url`, `highlights`, `is_featured`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'Santorini', 'Greece', 'Santorini', 36.39320000, 25.46150000, 'Stunning Greek island with white-washed buildings and blue domes', 'Apr - Oct', 200.00, 'EUR', 4.80, 2420, 'https://images.unsplash.com/photo-1570077188660-9787c0a69d96', '[\"Sunset Views\", \"White Architecture\", \"Volcanic Beaches\"]', 1, 1, '2025-10-16 10:19:13', '2025-10-16 10:19:13'),
(2, 'Kyoto', 'Japan', 'Kyoto', 35.01160000, 135.76810000, 'Ancient capital with temples, gardens, and traditional culture', 'Mar - May, Sep - Nov', 150.00, 'JPY', 4.90, 3150, 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e', '[\"Ancient Temples\", \"Cherry Blossoms\", \"Traditional Gardens\"]', 1, 1, '2025-10-16 10:19:13', '2025-10-16 10:19:13'),
(3, 'Dubai', 'UAE', 'Dubai', 25.20480000, 55.27080000, 'Modern metropolis with luxury shopping and iconic architecture', 'Nov - Mar', 300.00, 'AED', 4.60, 1820, 'https://images.unsplash.com/photo-1512453979798-5ea266f8880c', '[\"Modern Architecture\", \"Luxury Shopping\", \"Desert Safaris\"]', 1, 1, '2025-10-16 10:19:13', '2025-10-16 10:19:13'),
(4, 'Paris', 'France', 'Paris', 48.85660000, 2.35220000, 'City of Light with world-class museums and cuisine', 'Apr - Oct', 250.00, 'EUR', 4.70, 4500, 'https://images.unsplash.com/photo-1502602898536-47ad22581b52', '[\"Eiffel Tower\", \"Louvre Museum\", \"Seine River\"]', 1, 1, '2025-10-16 10:19:13', '2025-10-16 10:19:13'),
(5, 'Tokyo', 'Japan', 'Tokyo', 35.67620000, 139.65030000, 'Bustling metropolis blending tradition and modernity', 'Mar - May, Sep - Nov', 200.00, 'JPY', 4.80, 5200, 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf', '[\"Sushi\", \"Temples\", \"Technology\"]', 1, 1, '2025-10-16 10:19:13', '2025-10-16 10:19:13'),
(6, 'New York', 'USA', 'New York', 40.71280000, -74.00600000, 'The Big Apple with iconic landmarks and diverse culture', 'Apr - Jun, Sep - Nov', 300.00, 'USD', 4.50, 6800, 'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9', '[\"Statue of Liberty\", \"Central Park\", \"Broadway\"]', 1, 1, '2025-10-16 10:19:13', '2025-10-16 10:19:13');

-- --------------------------------------------------------

--
-- Stand-in structure for view `destination_popularity`
-- (See below for the actual view)
--
CREATE TABLE `destination_popularity` (
`name` varchar(200)
,`country` varchar(100)
,`city` varchar(100)
,`rating` decimal(3,2)
,`review_count` int(11)
,`trip_count` bigint(21)
,`average_budget` decimal(14,6)
,`average_trip_rating` decimal(7,6)
);

-- --------------------------------------------------------

--
-- Table structure for table `expense_tracking`
--

CREATE TABLE `expense_tracking` (
  `id` int(11) NOT NULL,
  `itinerary_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `expense_category` enum('accommodation','transportation','food','activities','shopping','other') NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `currency` varchar(3) DEFAULT 'USD',
  `description` varchar(200) DEFAULT NULL,
  `expense_date` date NOT NULL,
  `payment_method` varchar(50) DEFAULT NULL,
  `receipt_url` varchar(500) DEFAULT NULL,
  `is_reimbursable` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `group_members`
--

CREATE TABLE `group_members` (
  `id` int(11) NOT NULL,
  `group_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `role` enum('creator','admin','member') DEFAULT 'member',
  `joined_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `is_active` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Triggers `group_members`
--
DELIMITER $$
CREATE TRIGGER `decrease_group_member_count` AFTER DELETE ON `group_members` FOR EACH ROW BEGIN
    UPDATE group_travels 
    SET current_members = current_members - 1 
    WHERE id = OLD.group_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_group_member_count` AFTER INSERT ON `group_members` FOR EACH ROW BEGIN
    UPDATE group_travels 
    SET current_members = current_members + 1 
    WHERE id = NEW.group_id;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `group_travels`
--

CREATE TABLE `group_travels` (
  `id` int(11) NOT NULL,
  `creator_id` int(11) NOT NULL,
  `itinerary_id` int(11) DEFAULT NULL,
  `group_name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `max_members` int(11) DEFAULT 10,
  `current_members` int(11) DEFAULT 1,
  `is_active` tinyint(1) DEFAULT 1,
  `join_code` varchar(20) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `itineraries`
--

CREATE TABLE `itineraries` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `title` varchar(200) NOT NULL,
  `description` text DEFAULT NULL,
  `destination` varchar(100) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `budget` decimal(10,2) DEFAULT NULL,
  `currency` varchar(3) DEFAULT 'USD',
  `status` enum('planning','confirmed','in_progress','completed','cancelled') DEFAULT 'planning',
  `is_public` tinyint(1) DEFAULT 0,
  `is_shared` tinyint(1) DEFAULT 0,
  `share_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `trip_type` enum('leisure','business','adventure','romantic','family','solo') DEFAULT 'leisure',
  `travel_style` enum('budget','mid_range','luxury') DEFAULT 'mid_range',
  `total_cost` decimal(10,2) DEFAULT 0.00,
  `spent_amount` decimal(10,2) DEFAULT 0.00,
  `rating` decimal(3,2) DEFAULT NULL,
  `review_count` int(11) DEFAULT 0,
  `photos_count` int(11) DEFAULT 0,
  `is_favorite` tinyint(1) DEFAULT 0,
  `highlights` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`highlights`)),
  `activities` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`activities`)),
  `cover_image` varchar(500) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `itineraries`
--

INSERT INTO `itineraries` (`id`, `user_id`, `title`, `description`, `destination`, `start_date`, `end_date`, `budget`, `currency`, `status`, `is_public`, `is_shared`, `share_token`, `created_at`, `updated_at`, `trip_type`, `travel_style`, `total_cost`, `spent_amount`, `rating`, `review_count`, `photos_count`, `is_favorite`, `highlights`, `activities`, `cover_image`) VALUES
(1, 1, 'Paris Adventure', 'A romantic getaway to the City of Light', 'Paris, France', '2024-06-01', '2024-06-07', 2500.00, 'USD', 'planning', 0, 0, NULL, '2025-10-16 10:19:04', '2025-10-16 10:19:04', 'leisure', 'mid_range', 0.00, 0.00, NULL, 0, 0, 0, NULL, NULL, NULL),
(2, 2, 'Tokyo Food Tour', 'Exploring the culinary delights of Tokyo', 'Tokyo, Japan', '2024-07-15', '2024-07-22', 3000.00, 'USD', 'confirmed', 0, 0, NULL, '2025-10-16 10:19:04', '2025-10-16 10:19:04', 'leisure', 'mid_range', 0.00, 0.00, NULL, 0, 0, 0, NULL, NULL, NULL),
(3, 3, 'NYC Weekend', 'Quick weekend trip to New York', 'New York, USA', '2024-05-10', '2024-05-12', 800.00, 'USD', 'completed', 0, 0, NULL, '2025-10-16 10:19:04', '2025-10-16 10:19:04', 'leisure', 'mid_range', 0.00, 0.00, NULL, 0, 0, 0, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `itinerary_categories`
--

CREATE TABLE `itinerary_categories` (
  `id` int(11) NOT NULL,
  `itinerary_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `itinerary_items`
--

CREATE TABLE `itinerary_items` (
  `id` int(11) NOT NULL,
  `itinerary_id` int(11) NOT NULL,
  `day_number` int(11) NOT NULL,
  `title` varchar(200) NOT NULL,
  `description` text DEFAULT NULL,
  `activity_type` enum('accommodation','transportation','attraction','restaurant','activity','other') NOT NULL,
  `start_time` time DEFAULT NULL,
  `end_time` time DEFAULT NULL,
  `location` varchar(200) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `cost` decimal(10,2) DEFAULT NULL,
  `currency` varchar(3) DEFAULT 'USD',
  `booking_reference` varchar(100) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `is_confirmed` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `business_id` int(11) DEFAULT NULL,
  `type` enum('booking','payment','review','system','promotion') NOT NULL,
  `title` varchar(200) NOT NULL,
  `message` text NOT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `action_url` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `read_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `reviews`
--

CREATE TABLE `reviews` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `business_id` int(11) NOT NULL,
  `booking_id` int(11) DEFAULT NULL,
  `rating` int(11) NOT NULL CHECK (`rating` >= 1 and `rating` <= 5),
  `title` varchar(200) DEFAULT NULL,
  `comment` text DEFAULT NULL,
  `is_verified` tinyint(1) DEFAULT 0,
  `is_public` tinyint(1) DEFAULT 1,
  `helpful_count` int(11) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Triggers `reviews`
--
DELIMITER $$
CREATE TRIGGER `update_destination_reviews` AFTER INSERT ON `reviews` FOR EACH ROW BEGIN
    UPDATE destinations d
    JOIN itineraries i ON d.name = i.destination
    SET d.review_count = d.review_count + 1
    WHERE i.id = NEW.booking_id;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `saved_places`
--

CREATE TABLE `saved_places` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `name` varchar(200) NOT NULL,
  `description` text DEFAULT NULL,
  `location` varchar(200) NOT NULL,
  `address` text DEFAULT NULL,
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `place_type` enum('restaurant','attraction','hotel','activity','other') NOT NULL,
  `rating` decimal(3,2) DEFAULT NULL,
  `price_level` int(11) DEFAULT NULL,
  `website` varchar(255) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `tags` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`tags`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `saved_places`
--

INSERT INTO `saved_places` (`id`, `user_id`, `name`, `description`, `location`, `address`, `latitude`, `longitude`, `place_type`, `rating`, `price_level`, `website`, `phone`, `notes`, `tags`, `created_at`, `updated_at`) VALUES
(1, 1, 'Eiffel Tower', 'Iconic iron lattice tower', 'Paris, France', NULL, NULL, NULL, 'attraction', 4.80, NULL, NULL, NULL, 'Must visit at sunset', NULL, '2025-10-16 10:19:05', '2025-10-16 10:19:05'),
(2, 2, 'Tsukiji Fish Market', 'Famous fish market', 'Tokyo, Japan', NULL, NULL, NULL, 'attraction', 4.50, NULL, NULL, NULL, 'Best sushi in the world', NULL, '2025-10-16 10:19:05', '2025-10-16 10:19:05'),
(3, 3, 'Central Park', 'Large public park', 'New York, USA', NULL, NULL, NULL, 'attraction', 4.70, NULL, NULL, NULL, 'Great for morning runs', NULL, '2025-10-16 10:19:05', '2025-10-16 10:19:05');

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

CREATE TABLE `sessions` (
  `id` varchar(128) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `business_id` int(11) DEFAULT NULL,
  `user_type` enum('personal','business') NOT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `last_activity` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `subscription_plans`
--

CREATE TABLE `subscription_plans` (
  `id` int(11) NOT NULL,
  `plan_name` varchar(50) NOT NULL,
  `plan_type` enum('free','traveler','premium') NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `currency` varchar(3) DEFAULT 'USD',
  `billing_cycle` enum('monthly','yearly') DEFAULT 'monthly',
  `features` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`features`)),
  `max_itineraries` int(11) DEFAULT NULL,
  `max_group_members` int(11) DEFAULT NULL,
  `priority_support` tinyint(1) DEFAULT 0,
  `concierge_service` tinyint(1) DEFAULT 0,
  `travel_insurance` tinyint(1) DEFAULT 0,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `subscription_plans`
--

INSERT INTO `subscription_plans` (`id`, `plan_name`, `plan_type`, `price`, `currency`, `billing_cycle`, `features`, `max_itineraries`, `max_group_members`, `priority_support`, `concierge_service`, `travel_insurance`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'Free', 'free', 0.00, 'USD', 'monthly', '[\"Basic trip planning\", \"Limited destinations\", \"Basic support\"]', 3, 1, 0, 0, 0, 1, '2025-10-16 10:19:12', '2025-10-16 10:19:12'),
(2, 'Traveler', 'traveler', 250.00, 'USD', 'monthly', '[\"AI recommendations\", \"Cloud storage\", \"Multi-calendar\", \"Offline access\", \"Priority support\"]', NULL, 5, 1, 0, 0, 1, '2025-10-16 10:19:12', '2025-10-16 10:19:12'),
(3, 'Premium', 'premium', 499.00, 'USD', 'monthly', '[\"All Traveler features\", \"24/7 concierge\", \"Group travel up to 10\", \"Travel insurance\", \"Premium support\"]', NULL, 10, 1, 1, 1, 1, '2025-10-16 10:19:12', '2025-10-16 10:19:12');

-- --------------------------------------------------------

--
-- Table structure for table `trip_categories`
--

CREATE TABLE `trip_categories` (
  `id` int(11) NOT NULL,
  `category_name` varchar(100) NOT NULL,
  `category_type` enum('destination','activity','budget','duration','season') NOT NULL,
  `description` text DEFAULT NULL,
  `icon` varchar(50) DEFAULT NULL,
  `color` varchar(7) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `trip_categories`
--

INSERT INTO `trip_categories` (`id`, `category_name`, `category_type`, `description`, `icon`, `color`, `is_active`, `created_at`) VALUES
(1, 'Beach & Islands', 'destination', 'Tropical beach destinations', 'fas fa-umbrella-beach', '#0891b2', 1, '2025-10-16 10:19:13'),
(2, 'Culture & History', 'destination', 'Historical and cultural sites', 'fas fa-building', '#7c3aed', 1, '2025-10-16 10:19:13'),
(3, 'Adventure', 'activity', 'Adventure and outdoor activities', 'fas fa-mountain', '#10b981', 1, '2025-10-16 10:19:13'),
(4, 'Romantic', 'activity', 'Romantic getaways and couples trips', 'fas fa-heart', '#ef4444', 1, '2025-10-16 10:19:13'),
(5, 'Luxury', 'budget', 'High-end luxury travel', 'fas fa-star', '#f59e0b', 1, '2025-10-16 10:19:13'),
(6, 'Nature', 'destination', 'Natural landscapes and wildlife', 'fas fa-leaf', '#22c55e', 1, '2025-10-16 10:19:13'),
(7, 'Budget', 'budget', 'Affordable travel options', 'fas fa-dollar-sign', '#84cc16', 1, '2025-10-16 10:19:13'),
(8, 'Family', 'activity', 'Family-friendly destinations', 'fas fa-users', '#8b5cf6', 1, '2025-10-16 10:19:13');

-- --------------------------------------------------------

--
-- Table structure for table `trip_photos`
--

CREATE TABLE `trip_photos` (
  `id` int(11) NOT NULL,
  `itinerary_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `photo_url` varchar(500) NOT NULL,
  `caption` text DEFAULT NULL,
  `photo_type` enum('itinerary','activity','accommodation','food','landmark','other') DEFAULT 'itinerary',
  `is_public` tinyint(1) DEFAULT 0,
  `is_featured` tinyint(1) DEFAULT 0,
  `file_size` int(11) DEFAULT NULL,
  `file_type` varchar(50) DEFAULT NULL,
  `uploaded_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Triggers `trip_photos`
--
DELIMITER $$
CREATE TRIGGER `update_itinerary_stats` AFTER INSERT ON `trip_photos` FOR EACH ROW BEGIN
    UPDATE itineraries 
    SET photos_count = photos_count + 1 
    WHERE id = NEW.itinerary_id;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `trip_statistics`
-- (See below for the actual view)
--
CREATE TABLE `trip_statistics` (
`id` int(11)
,`title` varchar(200)
,`destination` varchar(100)
,`start_date` date
,`end_date` date
,`budget` decimal(10,2)
,`total_cost` decimal(10,2)
,`spent_amount` decimal(10,2)
,`rating` decimal(3,2)
,`review_count` int(11)
,`photos_count` int(11)
,`trip_type` enum('leisure','business','adventure','romantic','family','solo')
,`travel_style` enum('budget','mid_range','luxury')
,`first_name` varchar(50)
,`last_name` varchar(50)
,`duration_days` int(7)
,`budget_utilization_percentage` decimal(16,2)
);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `profile_picture` varchar(255) DEFAULT NULL,
  `bio` text DEFAULT NULL,
  `preferences` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`preferences`)),
  `is_active` tinyint(1) DEFAULT 1,
  `email_verified` tinyint(1) DEFAULT 0,
  `verification_token` varchar(100) DEFAULT NULL,
  `reset_token` varchar(100) DEFAULT NULL,
  `reset_token_expires` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `last_login` timestamp NULL DEFAULT NULL,
  `subscription_plan_id` int(11) DEFAULT 1,
  `subscription_status` enum('active','cancelled','expired','pending') DEFAULT 'active',
  `subscription_start_date` date DEFAULT NULL,
  `subscription_end_date` date DEFAULT NULL,
  `dark_mode_preference` tinyint(1) DEFAULT 0,
  `language_preference` varchar(10) DEFAULT 'en',
  `timezone` varchar(50) DEFAULT 'UTC'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `first_name`, `last_name`, `email`, `password`, `phone`, `date_of_birth`, `profile_picture`, `bio`, `preferences`, `is_active`, `email_verified`, `verification_token`, `reset_token`, `reset_token_expires`, `created_at`, `updated_at`, `last_login`, `subscription_plan_id`, `subscription_status`, `subscription_start_date`, `subscription_end_date`, `dark_mode_preference`, `language_preference`, `timezone`) VALUES
(1, 'John', 'Doe', 'john.doe@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+1234567890', NULL, NULL, NULL, NULL, 1, 1, NULL, NULL, NULL, '2025-10-16 10:19:03', '2025-10-16 10:19:03', NULL, 1, 'active', NULL, NULL, 0, 'en', 'UTC'),
(2, 'Jane', 'Smith', 'jane.smith@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+1234567891', NULL, NULL, NULL, NULL, 1, 1, NULL, NULL, NULL, '2025-10-16 10:19:03', '2025-10-16 10:19:03', NULL, 1, 'active', NULL, NULL, 0, 'en', 'UTC'),
(3, 'Mike', 'Johnson', 'mike.johnson@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+1234567892', NULL, NULL, NULL, NULL, 1, 1, NULL, NULL, NULL, '2025-10-16 10:19:03', '2025-10-16 10:19:03', NULL, 1, 'active', NULL, NULL, 0, 'en', 'UTC'),
(4, 'Anna Mae', 'Regis', 'soniumie@gmail.com', '$2y$10$Ay51EFuVG8iuETRm/n0zKex.zQhmRL6YFEXICcezesTvkxOh/zCki', NULL, NULL, NULL, NULL, NULL, 1, 0, 'fc1dedf30d8f5dbe637f3f88636deece34c8322d29f38d8defded73aa04a61a2', NULL, NULL, '2025-10-16 10:45:33', '2025-10-18 12:34:01', '2025-10-18 07:47:33', 1, 'active', NULL, NULL, 0, 'en', 'UTC');

-- --------------------------------------------------------

--
-- Table structure for table `user_achievements`
--

CREATE TABLE `user_achievements` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `achievement_type` varchar(50) NOT NULL,
  `achievement_name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `icon` varchar(50) DEFAULT NULL,
  `unlocked_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `progress` int(11) DEFAULT 0,
  `target` int(11) DEFAULT 1,
  `is_unlocked` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_achievements`
--

INSERT INTO `user_achievements` (`id`, `user_id`, `achievement_type`, `achievement_name`, `description`, `icon`, `unlocked_at`, `progress`, `target`, `is_unlocked`, `created_at`) VALUES
(1, 1, 'globe_trotter', 'Globe Trotter', 'Visited 10+ countries', 'fas fa-globe', '2025-10-16 10:19:18', 12, 10, 1, '2025-10-16 10:19:18'),
(2, 1, 'budget_master', 'Budget Master', 'Saved $5000+ with smart booking', 'fas fa-piggy-bank', '2025-10-16 10:19:18', 1, 1, 1, '2025-10-16 10:19:18'),
(3, 1, 'frequent_flyer', 'Frequent Flyer', '100,000+ miles traveled', 'fas fa-plane', '2025-10-16 10:19:18', 1, 1, 1, '2025-10-16 10:19:18'),
(4, 1, 'adventure_seeker', 'Adventure Seeker', 'Tried 20+ activities', 'fas fa-mountain', '2025-10-16 10:19:18', 15, 20, 0, '2025-10-16 10:19:18'),
(5, 1, 'cultural_explorer', 'Cultural Explorer', 'Visited 5+ UNESCO sites', 'fas fa-landmark', '2025-10-16 10:19:18', 3, 5, 0, '2025-10-16 10:19:18');

-- --------------------------------------------------------

--
-- Stand-in structure for view `user_complete_profile`
-- (See below for the actual view)
--
CREATE TABLE `user_complete_profile` (
`id` int(11)
,`first_name` varchar(50)
,`last_name` varchar(50)
,`email` varchar(100)
,`date_of_birth` date
,`is_active` tinyint(1)
,`email_verified` tinyint(1)
,`last_login` timestamp
,`phone` varchar(20)
,`location` varchar(200)
,`timezone` varchar(50)
,`bio` text
,`date_format` enum('MM/DD/YYYY','DD/MM/YYYY','YYYY-MM-DD')
,`currency` varchar(3)
,`profile_photo` varchar(500)
,`total_trips` int(11)
,`countries_visited` int(11)
,`total_spent` decimal(12,2)
,`total_miles` decimal(10,2)
,`favorite_destination` varchar(200)
,`next_trip_destination` varchar(200)
,`last_trip_date` date
,`plan_name` varchar(50)
,`plan_type` enum('free','traveler','premium')
,`subscription_status` enum('active','cancelled','expired','pending')
,`subscription_end_date` date
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `user_dashboard_data`
-- (See below for the actual view)
--
CREATE TABLE `user_dashboard_data` (
`id` int(11)
,`first_name` varchar(50)
,`last_name` varchar(50)
,`email` varchar(100)
,`total_itineraries` bigint(21)
,`total_saved_places` bigint(21)
,`total_group_travels` bigint(21)
,`last_login` timestamp
);

-- --------------------------------------------------------

--
-- Table structure for table `user_notification_settings`
--

CREATE TABLE `user_notification_settings` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `booking_confirmations` tinyint(1) DEFAULT 1,
  `price_alerts` tinyint(1) DEFAULT 1,
  `travel_reminders` tinyint(1) DEFAULT 1,
  `weekly_digest` tinyint(1) DEFAULT 1,
  `push_notifications` tinyint(1) DEFAULT 1,
  `sms_alerts` tinyint(1) DEFAULT 0,
  `marketing_emails` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_notification_settings`
--

INSERT INTO `user_notification_settings` (`id`, `user_id`, `booking_confirmations`, `price_alerts`, `travel_reminders`, `weekly_digest`, `push_notifications`, `sms_alerts`, `marketing_emails`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, 1, 1, 1, 0, 0, '2025-10-16 10:19:18', '2025-10-16 10:19:18'),
(2, 2, 1, 1, 1, 0, 1, 1, 0, '2025-10-16 10:19:18', '2025-10-16 10:19:18'),
(3, 3, 1, 0, 1, 1, 0, 0, 1, '2025-10-16 10:19:18', '2025-10-16 10:19:18'),
(10, 4, 1, 1, 1, 1, 1, 1, 1, '2025-10-16 10:46:00', '2025-10-18 12:53:31');

-- --------------------------------------------------------

--
-- Table structure for table `user_payment_methods`
--

CREATE TABLE `user_payment_methods` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `payment_type` enum('card','paypal','bank_transfer') NOT NULL,
  `card_brand` varchar(20) DEFAULT NULL,
  `last_four_digits` varchar(4) DEFAULT NULL,
  `expiry_month` varchar(2) DEFAULT NULL,
  `expiry_year` varchar(4) DEFAULT NULL,
  `cardholder_name` varchar(100) DEFAULT NULL,
  `is_primary` tinyint(1) DEFAULT 0,
  `payment_token` varchar(255) NOT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user_preferences`
--

CREATE TABLE `user_preferences` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `travel_style` enum('budget','mid_range','luxury') DEFAULT 'mid_range',
  `accommodation_preference` enum('hotel','hostel','airbnb','resort') DEFAULT 'hotel',
  `transportation_preference` enum('flight','train','bus','car','mixed') DEFAULT 'mixed',
  `activity_interests` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`activity_interests`)),
  `dietary_restrictions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`dietary_restrictions`)),
  `accessibility_needs` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`accessibility_needs`)),
  `language_preferences` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`language_preferences`)),
  `notification_preferences` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`notification_preferences`)),
  `privacy_settings` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`privacy_settings`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_preferences`
--

INSERT INTO `user_preferences` (`id`, `user_id`, `travel_style`, `accommodation_preference`, `transportation_preference`, `activity_interests`, `dietary_restrictions`, `accessibility_needs`, `language_preferences`, `notification_preferences`, `privacy_settings`, `created_at`, `updated_at`) VALUES
(1, 1, 'luxury', 'hotel', 'flight', '[\"culture\", \"food\", \"photography\"]', '[\"vegetarian\"]', NULL, NULL, '{\"email\": true, \"push\": true, \"sms\": false}', NULL, '2025-10-16 10:19:13', '2025-10-16 10:19:13'),
(2, 2, 'mid_range', 'airbnb', 'mixed', '[\"adventure\", \"nature\", \"hiking\"]', '[]', NULL, NULL, '{\"email\": true, \"push\": false, \"sms\": true}', NULL, '2025-10-16 10:19:13', '2025-10-16 10:19:13'),
(3, 3, 'budget', 'hostel', 'bus', '[\"culture\", \"history\", \"art\"]', '[\"vegan\"]', NULL, NULL, '{\"email\": false, \"push\": true, \"sms\": false}', NULL, '2025-10-16 10:19:13', '2025-10-16 10:19:13');

-- --------------------------------------------------------

--
-- Table structure for table `user_profile_settings`
--

CREATE TABLE `user_profile_settings` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `location` varchar(200) DEFAULT NULL,
  `timezone` varchar(50) DEFAULT 'UTC',
  `bio` text DEFAULT NULL,
  `date_format` enum('MM/DD/YYYY','DD/MM/YYYY','YYYY-MM-DD') DEFAULT 'MM/DD/YYYY',
  `currency` varchar(3) DEFAULT 'USD',
  `profile_photo` varchar(500) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_profile_settings`
--

INSERT INTO `user_profile_settings` (`id`, `user_id`, `phone`, `location`, `timezone`, `bio`, `date_format`, `currency`, `profile_photo`, `created_at`, `updated_at`) VALUES
(1, 1, '+1234567890', 'New York, USA', 'America/New_York', 'Passionate traveler exploring the world one destination at a time. Love experiencing new cultures and cuisines.', 'MM/DD/YYYY', 'USD', NULL, '2025-10-16 10:19:18', '2025-10-16 10:19:18'),
(2, 2, '+1234567891', 'Los Angeles, USA', 'America/Los_Angeles', 'Adventure seeker and nature lover. Always looking for the next great outdoor experience.', 'MM/DD/YYYY', 'USD', NULL, '2025-10-16 10:19:18', '2025-10-16 10:19:18'),
(3, 3, '+1234567892', 'Chicago, USA', 'America/Chicago', 'Culture enthusiast and history buff. Love exploring museums and historical sites.', 'DD/MM/YYYY', 'EUR', NULL, '2025-10-16 10:19:18', '2025-10-16 10:19:18'),
(4, 4, '+639947910133', 'Cebu City, Philippines', 'America/Los_Angeles', 'Passionate traveler exploring the world one destination at a time. Love experiencing new cultures and cuisines.', 'MM/DD/YYYY', 'PHP', NULL, '2025-10-16 14:37:43', '2025-10-18 12:03:25');

-- --------------------------------------------------------

--
-- Table structure for table `user_security_settings`
--

CREATE TABLE `user_security_settings` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `two_factor_enabled` tinyint(1) DEFAULT 0,
  `two_factor_secret` varchar(32) DEFAULT NULL,
  `two_factor_backup_codes` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`two_factor_backup_codes`)),
  `login_alerts` tinyint(1) DEFAULT 1,
  `data_sharing` tinyint(1) DEFAULT 0,
  `profile_visibility` enum('private','friends','public') DEFAULT 'private',
  `last_password_change` timestamp NULL DEFAULT NULL,
  `failed_login_attempts` int(11) DEFAULT 0,
  `account_locked_until` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_security_settings`
--

INSERT INTO `user_security_settings` (`id`, `user_id`, `two_factor_enabled`, `two_factor_secret`, `two_factor_backup_codes`, `login_alerts`, `data_sharing`, `profile_visibility`, `last_password_change`, `failed_login_attempts`, `account_locked_until`, `created_at`, `updated_at`) VALUES
(1, 1, 1, NULL, NULL, 1, 0, 'private', '2025-10-16 10:19:18', 0, NULL, '2025-10-16 10:19:18', '2025-10-16 10:19:18'),
(2, 2, 0, NULL, NULL, 1, 1, 'friends', '2025-10-16 10:19:18', 0, NULL, '2025-10-16 10:19:18', '2025-10-16 10:19:18'),
(3, 3, 0, NULL, NULL, 0, 0, 'public', '2025-10-16 10:19:18', 0, NULL, '2025-10-16 10:19:18', '2025-10-16 10:19:18'),
(4, 4, 0, NULL, NULL, 1, 1, 'private', '2025-10-18 12:34:01', 0, NULL, '2025-10-18 12:02:12', '2025-10-18 12:34:01');

-- --------------------------------------------------------

--
-- Table structure for table `user_subscriptions`
--

CREATE TABLE `user_subscriptions` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `plan_id` int(11) NOT NULL,
  `status` enum('active','cancelled','expired','pending') DEFAULT 'pending',
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  `auto_renew` tinyint(1) DEFAULT 1,
  `payment_method` varchar(50) DEFAULT NULL,
  `payment_reference` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user_travel_preferences`
--

CREATE TABLE `user_travel_preferences` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `preferred_class` enum('economy','premium_economy','business','first') DEFAULT 'economy',
  `seat_preference` enum('window','aisle','middle','no_preference') DEFAULT 'no_preference',
  `meal_preference` enum('vegetarian','vegan','halal','kosher','gluten_free','no_preference') DEFAULT 'no_preference',
  `star_rating` enum('1','2','3','4','5','any') DEFAULT 'any',
  `room_type` enum('single','double','twin','suite','family') DEFAULT 'double',
  `budget_range` enum('budget','mid_range','luxury','any') DEFAULT 'mid_range',
  `travel_type` enum('leisure','business','adventure','cultural','family') DEFAULT 'leisure',
  `activity_level` enum('low','moderate','high','extreme') DEFAULT 'moderate',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_travel_preferences`
--

INSERT INTO `user_travel_preferences` (`id`, `user_id`, `preferred_class`, `seat_preference`, `meal_preference`, `star_rating`, `room_type`, `budget_range`, `travel_type`, `activity_level`, `created_at`, `updated_at`) VALUES
(1, 1, 'business', 'window', 'vegetarian', '5', 'suite', 'luxury', 'leisure', 'moderate', '2025-10-16 10:19:18', '2025-10-16 10:19:18'),
(2, 2, 'economy', 'aisle', 'no_preference', '3', 'double', 'mid_range', 'adventure', 'high', '2025-10-16 10:19:18', '2025-10-16 10:19:18'),
(3, 3, 'premium_economy', 'window', 'vegan', '4', 'twin', 'budget', 'cultural', 'low', '2025-10-16 10:19:18', '2025-10-16 10:19:18');

-- --------------------------------------------------------

--
-- Table structure for table `user_travel_stats`
--

CREATE TABLE `user_travel_stats` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `total_trips` int(11) DEFAULT 0,
  `countries_visited` int(11) DEFAULT 0,
  `total_spent` decimal(12,2) DEFAULT 0.00,
  `total_miles` decimal(10,2) DEFAULT 0.00,
  `favorite_destination` varchar(200) DEFAULT NULL,
  `next_trip_destination` varchar(200) DEFAULT NULL,
  `last_trip_date` date DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_travel_stats`
--

INSERT INTO `user_travel_stats` (`id`, `user_id`, `total_trips`, `countries_visited`, `total_spent`, `total_miles`, `favorite_destination`, `next_trip_destination`, `last_trip_date`, `created_at`, `updated_at`) VALUES
(1, 1, 23, 12, 46000.00, 125000.00, 'Tokyo, Japan', 'Nanning, Guangxi, China', '2024-03-15', '2025-10-16 10:19:18', '2025-10-16 10:19:18'),
(2, 2, 15, 8, 25000.00, 85000.00, 'Barcelona, Spain', 'Reykjavik, Iceland', '2024-02-28', '2025-10-16 10:19:18', '2025-10-16 10:19:18'),
(3, 3, 8, 5, 12000.00, 45000.00, 'Rome, Italy', 'Prague, Czech Republic', '2024-01-20', '2025-10-16 10:19:18', '2025-10-16 10:19:18');

-- --------------------------------------------------------

--
-- Structure for view `business_dashboard_data`
--
DROP TABLE IF EXISTS `business_dashboard_data`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `business_dashboard_data`  AS SELECT `b`.`id` AS `id`, `b`.`business_name` AS `business_name`, `b`.`business_type` AS `business_type`, `b`.`email` AS `email`, count(distinct `bs`.`id`) AS `total_services`, count(distinct `bk`.`id`) AS `total_bookings`, avg(`r`.`rating`) AS `average_rating`, count(distinct `r`.`id`) AS `total_reviews`, `b`.`last_login` AS `last_login` FROM (((`businesses` `b` left join `business_services` `bs` on(`b`.`id` = `bs`.`business_id` and `bs`.`is_active` = 1)) left join `bookings` `bk` on(`b`.`id` = `bk`.`business_id`)) left join `reviews` `r` on(`b`.`id` = `r`.`business_id`)) WHERE `b`.`is_active` = 1 GROUP BY `b`.`id` ;

-- --------------------------------------------------------

--
-- Structure for view `destination_popularity`
--
DROP TABLE IF EXISTS `destination_popularity`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `destination_popularity`  AS SELECT `d`.`name` AS `name`, `d`.`country` AS `country`, `d`.`city` AS `city`, `d`.`rating` AS `rating`, `d`.`review_count` AS `review_count`, count(`i`.`id`) AS `trip_count`, avg(`i`.`budget`) AS `average_budget`, avg(`i`.`rating`) AS `average_trip_rating` FROM (`destinations` `d` left join `itineraries` `i` on(`d`.`name` = `i`.`destination`)) WHERE `d`.`is_active` = 1 GROUP BY `d`.`id`, `d`.`name`, `d`.`country`, `d`.`city`, `d`.`rating`, `d`.`review_count` ORDER BY count(`i`.`id`) DESC, `d`.`rating` DESC ;

-- --------------------------------------------------------

--
-- Structure for view `trip_statistics`
--
DROP TABLE IF EXISTS `trip_statistics`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `trip_statistics`  AS SELECT `i`.`id` AS `id`, `i`.`title` AS `title`, `i`.`destination` AS `destination`, `i`.`start_date` AS `start_date`, `i`.`end_date` AS `end_date`, `i`.`budget` AS `budget`, `i`.`total_cost` AS `total_cost`, `i`.`spent_amount` AS `spent_amount`, `i`.`rating` AS `rating`, `i`.`review_count` AS `review_count`, `i`.`photos_count` AS `photos_count`, `i`.`trip_type` AS `trip_type`, `i`.`travel_style` AS `travel_style`, `u`.`first_name` AS `first_name`, `u`.`last_name` AS `last_name`, to_days(`i`.`end_date`) - to_days(`i`.`start_date`) AS `duration_days`, CASE WHEN `i`.`total_cost` > 0 THEN round(`i`.`spent_amount` / `i`.`total_cost` * 100,2) ELSE 0 END AS `budget_utilization_percentage` FROM (`itineraries` `i` join `users` `u` on(`i`.`user_id` = `u`.`id`)) WHERE `u`.`is_active` = 1 ;

-- --------------------------------------------------------

--
-- Structure for view `user_complete_profile`
--
DROP TABLE IF EXISTS `user_complete_profile`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `user_complete_profile`  AS SELECT `u`.`id` AS `id`, `u`.`first_name` AS `first_name`, `u`.`last_name` AS `last_name`, `u`.`email` AS `email`, `u`.`date_of_birth` AS `date_of_birth`, `u`.`is_active` AS `is_active`, `u`.`email_verified` AS `email_verified`, `u`.`last_login` AS `last_login`, `ups`.`phone` AS `phone`, `ups`.`location` AS `location`, `ups`.`timezone` AS `timezone`, `ups`.`bio` AS `bio`, `ups`.`date_format` AS `date_format`, `ups`.`currency` AS `currency`, `ups`.`profile_photo` AS `profile_photo`, `uts`.`total_trips` AS `total_trips`, `uts`.`countries_visited` AS `countries_visited`, `uts`.`total_spent` AS `total_spent`, `uts`.`total_miles` AS `total_miles`, `uts`.`favorite_destination` AS `favorite_destination`, `uts`.`next_trip_destination` AS `next_trip_destination`, `uts`.`last_trip_date` AS `last_trip_date`, `sp`.`plan_name` AS `plan_name`, `sp`.`plan_type` AS `plan_type`, `us`.`status` AS `subscription_status`, `us`.`end_date` AS `subscription_end_date` FROM ((((`users` `u` left join `user_profile_settings` `ups` on(`u`.`id` = `ups`.`user_id`)) left join `user_travel_stats` `uts` on(`u`.`id` = `uts`.`user_id`)) left join `user_subscriptions` `us` on(`u`.`id` = `us`.`user_id` and `us`.`status` = 'active')) left join `subscription_plans` `sp` on(`us`.`plan_id` = `sp`.`id`)) WHERE `u`.`is_active` = 1 ;

-- --------------------------------------------------------

--
-- Structure for view `user_dashboard_data`
--
DROP TABLE IF EXISTS `user_dashboard_data`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `user_dashboard_data`  AS SELECT `u`.`id` AS `id`, `u`.`first_name` AS `first_name`, `u`.`last_name` AS `last_name`, `u`.`email` AS `email`, count(distinct `i`.`id`) AS `total_itineraries`, count(distinct `sp`.`id`) AS `total_saved_places`, count(distinct `gt`.`id`) AS `total_group_travels`, `u`.`last_login` AS `last_login` FROM (((`users` `u` left join `itineraries` `i` on(`u`.`id` = `i`.`user_id`)) left join `saved_places` `sp` on(`u`.`id` = `sp`.`user_id`)) left join `group_travels` `gt` on(`u`.`id` = `gt`.`creator_id`)) WHERE `u`.`is_active` = 1 GROUP BY `u`.`id` ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `analytics`
--
ALTER TABLE `analytics`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_business_id` (`business_id`),
  ADD KEY `idx_metric_type` (`metric_type`),
  ADD KEY `idx_date_recorded` (`date_recorded`);

--
-- Indexes for table `billing_history`
--
ALTER TABLE `billing_history`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `invoice_number` (`invoice_number`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_subscription_id` (`subscription_id`),
  ADD KEY `idx_billing_date` (`billing_date`),
  ADD KEY `idx_status` (`status`);

--
-- Indexes for table `bookings`
--
ALTER TABLE `bookings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `booking_reference` (`booking_reference`),
  ADD KEY `service_id` (`service_id`),
  ADD KEY `itinerary_id` (`itinerary_id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_business_id` (`business_id`),
  ADD KEY `idx_booking_reference` (`booking_reference`),
  ADD KEY `idx_booking_date` (`booking_date`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_payment_status` (`payment_status`),
  ADD KEY `idx_bookings_user_date` (`user_id`,`booking_date`);

--
-- Indexes for table `businesses`
--
ALTER TABLE `businesses`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `idx_email` (`email`),
  ADD KEY `idx_business_type` (`business_type`),
  ADD KEY `idx_active` (`is_active`),
  ADD KEY `idx_verified` (`is_verified`),
  ADD KEY `idx_created_at` (`created_at`),
  ADD KEY `subscription_plan_id` (`subscription_plan_id`);

--
-- Indexes for table `business_services`
--
ALTER TABLE `business_services`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_business_id` (`business_id`),
  ADD KEY `idx_service_type` (`service_type`),
  ADD KEY `idx_active` (`is_active`),
  ADD KEY `idx_location` (`location`);

--
-- Indexes for table `destinations`
--
ALTER TABLE `destinations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_country` (`country`),
  ADD KEY `idx_city` (`city`),
  ADD KEY `idx_featured` (`is_featured`),
  ADD KEY `idx_active` (`is_active`),
  ADD KEY `idx_rating` (`rating`),
  ADD KEY `idx_destinations_featured` (`is_featured`,`is_active`);

--
-- Indexes for table `expense_tracking`
--
ALTER TABLE `expense_tracking`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_itinerary_id` (`itinerary_id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_category` (`expense_category`),
  ADD KEY `idx_expense_date` (`expense_date`),
  ADD KEY `idx_expense_tracking_itinerary` (`itinerary_id`,`expense_date`);

--
-- Indexes for table `group_members`
--
ALTER TABLE `group_members`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_group_user` (`group_id`,`user_id`),
  ADD KEY `idx_group_id` (`group_id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_role` (`role`);

--
-- Indexes for table `group_travels`
--
ALTER TABLE `group_travels`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `join_code` (`join_code`),
  ADD KEY `itinerary_id` (`itinerary_id`),
  ADD KEY `idx_creator_id` (`creator_id`),
  ADD KEY `idx_join_code` (`join_code`),
  ADD KEY `idx_active` (`is_active`);

--
-- Indexes for table `itineraries`
--
ALTER TABLE `itineraries`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_destination` (`destination`),
  ADD KEY `idx_dates` (`start_date`,`end_date`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_public` (`is_public`),
  ADD KEY `idx_itineraries_user_dates` (`user_id`,`start_date`,`end_date`);

--
-- Indexes for table `itinerary_categories`
--
ALTER TABLE `itinerary_categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_itinerary_category` (`itinerary_id`,`category_id`),
  ADD KEY `idx_itinerary_id` (`itinerary_id`),
  ADD KEY `idx_category_id` (`category_id`),
  ADD KEY `idx_itinerary_categories_itinerary` (`itinerary_id`);

--
-- Indexes for table `itinerary_items`
--
ALTER TABLE `itinerary_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_itinerary_id` (`itinerary_id`),
  ADD KEY `idx_day_number` (`day_number`),
  ADD KEY `idx_activity_type` (`activity_type`),
  ADD KEY `idx_location` (`location`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_business_id` (`business_id`),
  ADD KEY `idx_type` (`type`),
  ADD KEY `idx_is_read` (`is_read`),
  ADD KEY `idx_created_at` (`created_at`),
  ADD KEY `idx_notifications_user_read` (`user_id`,`is_read`,`created_at`);

--
-- Indexes for table `reviews`
--
ALTER TABLE `reviews`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_user_business_booking` (`user_id`,`business_id`,`booking_id`),
  ADD KEY `booking_id` (`booking_id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_business_id` (`business_id`),
  ADD KEY `idx_rating` (`rating`),
  ADD KEY `idx_created_at` (`created_at`),
  ADD KEY `idx_reviews_business_rating` (`business_id`,`rating`);

--
-- Indexes for table `saved_places`
--
ALTER TABLE `saved_places`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_place_type` (`place_type`),
  ADD KEY `idx_location` (`location`);

--
-- Indexes for table `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_business_id` (`business_id`),
  ADD KEY `idx_last_activity` (`last_activity`);

--
-- Indexes for table `subscription_plans`
--
ALTER TABLE `subscription_plans`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_plan_type` (`plan_type`),
  ADD KEY `idx_active` (`is_active`);

--
-- Indexes for table `trip_categories`
--
ALTER TABLE `trip_categories`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_category_type` (`category_type`),
  ADD KEY `idx_active` (`is_active`);

--
-- Indexes for table `trip_photos`
--
ALTER TABLE `trip_photos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_itinerary_id` (`itinerary_id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_public` (`is_public`),
  ADD KEY `idx_featured` (`is_featured`),
  ADD KEY `idx_trip_photos_itinerary` (`itinerary_id`,`is_public`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `idx_email` (`email`),
  ADD KEY `idx_active` (`is_active`),
  ADD KEY `idx_created_at` (`created_at`),
  ADD KEY `subscription_plan_id` (`subscription_plan_id`);

--
-- Indexes for table `user_achievements`
--
ALTER TABLE `user_achievements`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_user_achievement` (`user_id`,`achievement_type`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_achievement_type` (`achievement_type`),
  ADD KEY `idx_is_unlocked` (`is_unlocked`);

--
-- Indexes for table `user_notification_settings`
--
ALTER TABLE `user_notification_settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_user_notification_settings` (`user_id`),
  ADD KEY `idx_user_id` (`user_id`);

--
-- Indexes for table `user_payment_methods`
--
ALTER TABLE `user_payment_methods`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_is_primary` (`is_primary`),
  ADD KEY `idx_is_active` (`is_active`);

--
-- Indexes for table `user_preferences`
--
ALTER TABLE `user_preferences`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_user_preferences` (`user_id`),
  ADD KEY `idx_user_id` (`user_id`);

--
-- Indexes for table `user_profile_settings`
--
ALTER TABLE `user_profile_settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_user_profile` (`user_id`),
  ADD KEY `idx_user_id` (`user_id`);

--
-- Indexes for table `user_security_settings`
--
ALTER TABLE `user_security_settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_user_security_settings` (`user_id`),
  ADD KEY `idx_user_id` (`user_id`);

--
-- Indexes for table `user_subscriptions`
--
ALTER TABLE `user_subscriptions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_plan_id` (`plan_id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_dates` (`start_date`,`end_date`),
  ADD KEY `idx_user_subscriptions_user_plan` (`user_id`,`plan_id`),
  ADD KEY `idx_user_subscriptions_status` (`status`);

--
-- Indexes for table `user_travel_preferences`
--
ALTER TABLE `user_travel_preferences`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_user_travel_prefs` (`user_id`),
  ADD KEY `idx_user_id` (`user_id`);

--
-- Indexes for table `user_travel_stats`
--
ALTER TABLE `user_travel_stats`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_user_travel_stats` (`user_id`),
  ADD KEY `idx_user_id` (`user_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `analytics`
--
ALTER TABLE `analytics`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `billing_history`
--
ALTER TABLE `billing_history`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `bookings`
--
ALTER TABLE `bookings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `businesses`
--
ALTER TABLE `businesses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `business_services`
--
ALTER TABLE `business_services`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `destinations`
--
ALTER TABLE `destinations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `expense_tracking`
--
ALTER TABLE `expense_tracking`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `group_members`
--
ALTER TABLE `group_members`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `group_travels`
--
ALTER TABLE `group_travels`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `itineraries`
--
ALTER TABLE `itineraries`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `itinerary_categories`
--
ALTER TABLE `itinerary_categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `itinerary_items`
--
ALTER TABLE `itinerary_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `reviews`
--
ALTER TABLE `reviews`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `saved_places`
--
ALTER TABLE `saved_places`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `subscription_plans`
--
ALTER TABLE `subscription_plans`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `trip_categories`
--
ALTER TABLE `trip_categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `trip_photos`
--
ALTER TABLE `trip_photos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `user_achievements`
--
ALTER TABLE `user_achievements`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `user_notification_settings`
--
ALTER TABLE `user_notification_settings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `user_payment_methods`
--
ALTER TABLE `user_payment_methods`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `user_preferences`
--
ALTER TABLE `user_preferences`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `user_profile_settings`
--
ALTER TABLE `user_profile_settings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `user_security_settings`
--
ALTER TABLE `user_security_settings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `user_subscriptions`
--
ALTER TABLE `user_subscriptions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `user_travel_preferences`
--
ALTER TABLE `user_travel_preferences`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `user_travel_stats`
--
ALTER TABLE `user_travel_stats`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `analytics`
--
ALTER TABLE `analytics`
  ADD CONSTRAINT `analytics_ibfk_1` FOREIGN KEY (`business_id`) REFERENCES `businesses` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `billing_history`
--
ALTER TABLE `billing_history`
  ADD CONSTRAINT `billing_history_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `billing_history_ibfk_2` FOREIGN KEY (`subscription_id`) REFERENCES `user_subscriptions` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `bookings`
--
ALTER TABLE `bookings`
  ADD CONSTRAINT `bookings_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `bookings_ibfk_2` FOREIGN KEY (`business_id`) REFERENCES `businesses` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `bookings_ibfk_3` FOREIGN KEY (`service_id`) REFERENCES `business_services` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `bookings_ibfk_4` FOREIGN KEY (`itinerary_id`) REFERENCES `itineraries` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `businesses`
--
ALTER TABLE `businesses`
  ADD CONSTRAINT `businesses_ibfk_1` FOREIGN KEY (`subscription_plan_id`) REFERENCES `subscription_plans` (`id`);

--
-- Constraints for table `business_services`
--
ALTER TABLE `business_services`
  ADD CONSTRAINT `business_services_ibfk_1` FOREIGN KEY (`business_id`) REFERENCES `businesses` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `expense_tracking`
--
ALTER TABLE `expense_tracking`
  ADD CONSTRAINT `expense_tracking_ibfk_1` FOREIGN KEY (`itinerary_id`) REFERENCES `itineraries` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `expense_tracking_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `group_members`
--
ALTER TABLE `group_members`
  ADD CONSTRAINT `group_members_ibfk_1` FOREIGN KEY (`group_id`) REFERENCES `group_travels` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `group_members_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `group_travels`
--
ALTER TABLE `group_travels`
  ADD CONSTRAINT `group_travels_ibfk_1` FOREIGN KEY (`creator_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `group_travels_ibfk_2` FOREIGN KEY (`itinerary_id`) REFERENCES `itineraries` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `itineraries`
--
ALTER TABLE `itineraries`
  ADD CONSTRAINT `itineraries_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `itinerary_categories`
--
ALTER TABLE `itinerary_categories`
  ADD CONSTRAINT `itinerary_categories_ibfk_1` FOREIGN KEY (`itinerary_id`) REFERENCES `itineraries` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `itinerary_categories_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `trip_categories` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `itinerary_items`
--
ALTER TABLE `itinerary_items`
  ADD CONSTRAINT `itinerary_items_ibfk_1` FOREIGN KEY (`itinerary_id`) REFERENCES `itineraries` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `notifications_ibfk_2` FOREIGN KEY (`business_id`) REFERENCES `businesses` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `reviews`
--
ALTER TABLE `reviews`
  ADD CONSTRAINT `reviews_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `reviews_ibfk_2` FOREIGN KEY (`business_id`) REFERENCES `businesses` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `reviews_ibfk_3` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `saved_places`
--
ALTER TABLE `saved_places`
  ADD CONSTRAINT `saved_places_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `sessions`
--
ALTER TABLE `sessions`
  ADD CONSTRAINT `sessions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `sessions_ibfk_2` FOREIGN KEY (`business_id`) REFERENCES `businesses` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `trip_photos`
--
ALTER TABLE `trip_photos`
  ADD CONSTRAINT `trip_photos_ibfk_1` FOREIGN KEY (`itinerary_id`) REFERENCES `itineraries` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `trip_photos_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`subscription_plan_id`) REFERENCES `subscription_plans` (`id`);

--
-- Constraints for table `user_achievements`
--
ALTER TABLE `user_achievements`
  ADD CONSTRAINT `user_achievements_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `user_notification_settings`
--
ALTER TABLE `user_notification_settings`
  ADD CONSTRAINT `user_notification_settings_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `user_payment_methods`
--
ALTER TABLE `user_payment_methods`
  ADD CONSTRAINT `user_payment_methods_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `user_preferences`
--
ALTER TABLE `user_preferences`
  ADD CONSTRAINT `user_preferences_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `user_profile_settings`
--
ALTER TABLE `user_profile_settings`
  ADD CONSTRAINT `user_profile_settings_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `user_security_settings`
--
ALTER TABLE `user_security_settings`
  ADD CONSTRAINT `user_security_settings_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `user_subscriptions`
--
ALTER TABLE `user_subscriptions`
  ADD CONSTRAINT `user_subscriptions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `user_subscriptions_ibfk_2` FOREIGN KEY (`plan_id`) REFERENCES `subscription_plans` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `user_travel_preferences`
--
ALTER TABLE `user_travel_preferences`
  ADD CONSTRAINT `user_travel_preferences_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `user_travel_stats`
--
ALTER TABLE `user_travel_stats`
  ADD CONSTRAINT `user_travel_stats_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
