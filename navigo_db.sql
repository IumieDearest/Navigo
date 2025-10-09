-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Oct 09, 2025 at 03:54 PM
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetUserStats` (IN `user_id` INT)   BEGIN
    SELECT 
        (SELECT COUNT(*) FROM itineraries WHERE user_id = user_id) as itinerary_count,
        (SELECT COUNT(*) FROM saved_places WHERE user_id = user_id) as saved_places_count,
        (SELECT COUNT(*) FROM group_travels WHERE creator_id = user_id) as group_travels_count,
        (SELECT COUNT(*) FROM bookings WHERE user_id = user_id) as booking_count;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
  `last_login` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `businesses`
--

INSERT INTO `businesses` (`id`, `business_name`, `business_type`, `contact_first_name`, `contact_last_name`, `email`, `password`, `phone`, `business_phone`, `website`, `business_address`, `city`, `state`, `country`, `postal_code`, `business_description`, `business_hours`, `amenities`, `social_media`, `is_active`, `is_verified`, `verification_documents`, `email_verified`, `verification_token`, `reset_token`, `reset_token_expires`, `created_at`, `updated_at`, `last_login`) VALUES
(1, 'Grand Hotel Paris', 'hotel', 'Marie', 'Dubois', 'contact@grandhotelparis.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+33123456789', NULL, NULL, NULL, 'Paris', NULL, 'France', NULL, NULL, NULL, NULL, NULL, 1, 1, NULL, 1, NULL, NULL, NULL, '2025-10-09 12:26:07', '2025-10-09 12:26:07', NULL),
(2, 'Tokyo Sushi Bar', 'restaurant', 'Hiroshi', 'Tanaka', 'info@tokyosushibar.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+81312345678', NULL, NULL, NULL, 'Tokyo', NULL, 'Japan', NULL, NULL, NULL, NULL, NULL, 1, 1, NULL, 1, NULL, NULL, NULL, '2025-10-09 12:26:07', '2025-10-09 12:26:07', NULL),
(3, 'Adventure Tours NYC', 'tour', 'Sarah', 'Wilson', 'bookings@adventuretoursnyc.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+12125551234', NULL, NULL, NULL, 'New York', NULL, 'USA', NULL, NULL, NULL, NULL, NULL, 1, 1, NULL, 1, NULL, NULL, NULL, '2025-10-09 12:26:07', '2025-10-09 12:26:07', NULL);

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `business_services`
--

INSERT INTO `business_services` (`id`, `business_id`, `service_name`, `service_type`, `description`, `price`, `currency`, `duration_hours`, `capacity`, `location`, `address`, `latitude`, `longitude`, `amenities`, `availability_schedule`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 1, 'Deluxe Room', 'accommodation', 'Spacious room with city view', 200.00, 'USD', 24.00, NULL, 'Paris, France', NULL, NULL, NULL, NULL, NULL, 1, '2025-10-09 12:26:07', '2025-10-09 12:26:07'),
(2, 1, 'Spa Package', 'activity', 'Relaxing spa treatment', 150.00, 'USD', 2.00, NULL, 'Paris, France', NULL, NULL, NULL, NULL, NULL, 1, '2025-10-09 12:26:07', '2025-10-09 12:26:07'),
(3, 2, 'Omakase Dinner', 'restaurant', 'Chef\'s choice sushi experience', 120.00, 'USD', 2.00, NULL, 'Tokyo, Japan', NULL, NULL, NULL, NULL, NULL, 1, '2025-10-09 12:26:07', '2025-10-09 12:26:07'),
(4, 3, 'City Walking Tour', 'tour', 'Guided walking tour of Manhattan', 50.00, 'USD', 3.00, NULL, 'New York, USA', NULL, NULL, NULL, NULL, NULL, 1, '2025-10-09 12:26:07', '2025-10-09 12:26:07');

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `itineraries`
--

INSERT INTO `itineraries` (`id`, `user_id`, `title`, `description`, `destination`, `start_date`, `end_date`, `budget`, `currency`, `status`, `is_public`, `is_shared`, `share_token`, `created_at`, `updated_at`) VALUES
(1, 1, 'Paris Adventure', 'A romantic getaway to the City of Light', 'Paris, France', '2024-06-01', '2024-06-07', 2500.00, 'USD', 'planning', 0, 0, NULL, '2025-10-09 12:26:07', '2025-10-09 12:26:07'),
(2, 2, 'Tokyo Food Tour', 'Exploring the culinary delights of Tokyo', 'Tokyo, Japan', '2024-07-15', '2024-07-22', 3000.00, 'USD', 'confirmed', 0, 0, NULL, '2025-10-09 12:26:07', '2025-10-09 12:26:07'),
(3, 3, 'NYC Weekend', 'Quick weekend trip to New York', 'New York, USA', '2024-05-10', '2024-05-12', 800.00, 'USD', 'completed', 0, 0, NULL, '2025-10-09 12:26:07', '2025-10-09 12:26:07');

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `saved_places`
--

INSERT INTO `saved_places` (`id`, `user_id`, `name`, `description`, `location`, `address`, `latitude`, `longitude`, `place_type`, `rating`, `price_level`, `website`, `phone`, `notes`, `tags`, `created_at`, `updated_at`) VALUES
(1, 1, 'Eiffel Tower', 'Iconic iron lattice tower', 'Paris, France', NULL, NULL, NULL, 'attraction', 4.80, NULL, NULL, NULL, 'Must visit at sunset', NULL, '2025-10-09 12:26:07', '2025-10-09 12:26:07'),
(2, 2, 'Tsukiji Fish Market', 'Famous fish market', 'Tokyo, Japan', NULL, NULL, NULL, 'attraction', 4.50, NULL, NULL, NULL, 'Best sushi in the world', NULL, '2025-10-09 12:26:07', '2025-10-09 12:26:07'),
(3, 3, 'Central Park', 'Large public park', 'New York, USA', NULL, NULL, NULL, 'attraction', 4.70, NULL, NULL, NULL, 'Great for morning runs', NULL, '2025-10-09 12:26:07', '2025-10-09 12:26:07');

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
  `last_login` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `first_name`, `last_name`, `email`, `password`, `phone`, `date_of_birth`, `profile_picture`, `bio`, `preferences`, `is_active`, `email_verified`, `verification_token`, `reset_token`, `reset_token_expires`, `created_at`, `updated_at`, `last_login`) VALUES
(1, 'John', 'Doe', 'john.doe@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+1234567890', NULL, NULL, NULL, NULL, 1, 1, NULL, NULL, NULL, '2025-10-09 12:26:07', '2025-10-09 12:26:07', NULL),
(2, 'Jane', 'Smith', 'jane.smith@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+1234567891', NULL, NULL, NULL, NULL, 1, 1, NULL, NULL, NULL, '2025-10-09 12:26:07', '2025-10-09 12:26:07', NULL),
(3, 'Mike', 'Johnson', 'mike.johnson@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+1234567892', NULL, NULL, NULL, NULL, 1, 1, NULL, NULL, NULL, '2025-10-09 12:26:07', '2025-10-09 12:26:07', NULL);

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
-- Structure for view `business_dashboard_data`
--
DROP TABLE IF EXISTS `business_dashboard_data`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `business_dashboard_data`  AS SELECT `b`.`id` AS `id`, `b`.`business_name` AS `business_name`, `b`.`business_type` AS `business_type`, `b`.`email` AS `email`, count(distinct `bs`.`id`) AS `total_services`, count(distinct `bk`.`id`) AS `total_bookings`, avg(`r`.`rating`) AS `average_rating`, count(distinct `r`.`id`) AS `total_reviews`, `b`.`last_login` AS `last_login` FROM (((`businesses` `b` left join `business_services` `bs` on(`b`.`id` = `bs`.`business_id` and `bs`.`is_active` = 1)) left join `bookings` `bk` on(`b`.`id` = `bk`.`business_id`)) left join `reviews` `r` on(`b`.`id` = `r`.`business_id`)) WHERE `b`.`is_active` = 1 GROUP BY `b`.`id` ;

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
  ADD KEY `idx_created_at` (`created_at`);

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
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `idx_email` (`email`),
  ADD KEY `idx_active` (`is_active`),
  ADD KEY `idx_created_at` (`created_at`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `analytics`
--
ALTER TABLE `analytics`
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
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
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
-- Constraints for table `bookings`
--
ALTER TABLE `bookings`
  ADD CONSTRAINT `bookings_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `bookings_ibfk_2` FOREIGN KEY (`business_id`) REFERENCES `businesses` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `bookings_ibfk_3` FOREIGN KEY (`service_id`) REFERENCES `business_services` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `bookings_ibfk_4` FOREIGN KEY (`itinerary_id`) REFERENCES `itineraries` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `business_services`
--
ALTER TABLE `business_services`
  ADD CONSTRAINT `business_services_ibfk_1` FOREIGN KEY (`business_id`) REFERENCES `businesses` (`id`) ON DELETE CASCADE;

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
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
