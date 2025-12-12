-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: mariadb
-- Generation Time: Dec 12, 2025 at 10:45 AM
-- Server version: 10.6.20-MariaDB-ubu2004
-- PHP Version: 8.2.27

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `x`
--

-- --------------------------------------------------------

--
-- Table structure for table `bookmarks`
--

CREATE TABLE `bookmarks` (
  `bookmark_user_fk` char(32) NOT NULL,
  `bookmark_post_fk` char(32) NOT NULL,
  `created_at` bigint(20) UNSIGNED NOT NULL,
  `deleted_at` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `bookmarks`
--

INSERT INTO `bookmarks` (`bookmark_user_fk`, `bookmark_post_fk`, `created_at`, `deleted_at`) VALUES
('0cd10bd6ed6947de91a9bc060b1f7856', '304ed7abae8e4f5286232413087fedc5', 1765477168, NULL),
('36f828e2363b4887bae2f59fdf87abaf', '83df1fe7bca74714ab9788981e93bad4', 1765192603, NULL),
('818473efe156464c8e0cb0d8d62ead08', '47ceb2352e464419bfb5229776b2c9b4', 1765192298, NULL),
('818473efe156464c8e0cb0d8d62ead08', '7a56db10018a4dea98da379045340d63', 1765454941, NULL),
('818473efe156464c8e0cb0d8d62ead08', '8b5ae1c879814278a9e8f2b2f6ff575a', 1765478374, NULL),
('818473efe156464c8e0cb0d8d62ead08', 'b35ac08bba0a4b22b4f7383de2df13d6', 1765192303, NULL),
('818473efe156464c8e0cb0d8d62ead08', 'e8263488f83f407ea70b25e73d0c6154', 1765192301, NULL),
('818473efe156464c8e0cb0d8d62ead08', 'eb1d4b67f2ea4178a2221ca6171011d1', 1765447830, NULL),
('9fa8ec05f9df442eb7720c5deb200b2d', 'e8263488f83f407ea70b25e73d0c6154', 1765192573, NULL);

--
-- Triggers `bookmarks`
--
DELIMITER $$
CREATE TRIGGER `decrease_total_bookmarks` AFTER DELETE ON `bookmarks` FOR EACH ROW UPDATE posts
SET post_total_bookmarks = post_total_bookmarks - 1
WHERE post_pk = OLD.bookmark_post_fk
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `increase_total_bookmarks` AFTER INSERT ON `bookmarks` FOR EACH ROW UPDATE posts
SET post_total_bookmarks = post_total_bookmarks + 1
WHERE post_pk = NEW.bookmark_post_fk
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `comments`
--

CREATE TABLE `comments` (
  `comment_pk` char(32) NOT NULL,
  `comment_user_fk` char(32) NOT NULL,
  `comment_post_fk` char(32) NOT NULL,
  `comment_message` varchar(200) NOT NULL,
  `comment_is_blocked` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` bigint(20) UNSIGNED NOT NULL,
  `updated_at` bigint(20) UNSIGNED DEFAULT NULL,
  `deleted_at` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `comments`
--

INSERT INTO `comments` (`comment_pk`, `comment_user_fk`, `comment_post_fk`, `comment_message`, `comment_is_blocked`, `created_at`, `updated_at`, `deleted_at`) VALUES
('0129436018cf486184e5644d450f2d3f', '818473efe156464c8e0cb0d8d62ead08', 'aa0d9a8c8fa84a6fb921695b1a220d4f', 'Glæder mig', 0, 1765043355, NULL, NULL),
('022cd773f2a54c9bb48feadf9f24ba17', '818473efe156464c8e0cb0d8d62ead08', 'e8263488f83f407ea70b25e73d0c6154', 'Cute billede', 0, 1765043307, NULL, NULL),
('0bfab662ef454edfb6edc30cb05e2c8e', '818473efe156464c8e0cb0d8d62ead08', '47ceb2352e464419bfb5229776b2c9b4', 'Fedt!', 0, 1765043338, NULL, NULL),
('17ba7f9853fe4f0fb4e0ddf3954b309f', '818473efe156464c8e0cb0d8d62ead08', 'c631b41f180d4068893259b1437d42da', 'Det bliver spændende', 0, 1765115612, NULL, NULL),
('3d50d03a50ea436e8afa9b6cc80fd3a3', '818473efe156464c8e0cb0d8d62ead08', 'e08c8878bf6f484b897dae4a9620a48c', 'yes', 0, 1765109781, NULL, NULL),
('497be6ee4b9c4baea59f0d10efdce181', '36f828e2363b4887bae2f59fdf87abaf', '7a56db10018a4dea98da379045340d63', 'I do to!!!!', 0, 1765192665, NULL, NULL),
('70e9ede2915a4927bf98f9dc0fadcbae', '36f828e2363b4887bae2f59fdf87abaf', 'ca3596c77ac342fd854e4222064309da', 'Marcus + Ester + Sara + Sebastian = MESS', 0, 1765192697, NULL, NULL),
('9175b68992344535bbf98ec63686e603', '818473efe156464c8e0cb0d8d62ead08', 'eb1d4b67f2ea4178a2221ca6171011d1', 'søøødt', 0, 1765478162, NULL, NULL),
('afdf3d5d69ee43448394f4da6ad4fdee', '9fa8ec05f9df442eb7720c5deb200b2d', '058bfa8e44a04f83b84ff051d3c673aa', 'Også mig:)', 0, 1765192366, NULL, NULL),
('c5bac889f55345b79f1379078a194b41', '0f2f32396870473b8429db231c399978', '5e5fb929a7814583b2e4e80f35fcb1fc', 'Glæder mig!', 0, 1765192763, NULL, NULL),
('c8678d89a15444a5b6ff27d97191220e', '818473efe156464c8e0cb0d8d62ead08', '83df1fe7bca74714ab9788981e93bad4', 'Mega nice', 0, 1765043347, NULL, NULL),
('da13f404fd084e05a3f0f97929398d4c', '0cd10bd6ed6947de91a9bc060b1f7856', '83df1fe7bca74714ab9788981e93bad4', 'Welcome to X', 0, 1765045941, NULL, NULL),
('ebf0fdddf8184038863fe6eb7775616d', '818473efe156464c8e0cb0d8d62ead08', 'e08c8878bf6f484b897dae4a9620a48c', 'Yay, cant wait!', 0, 1765043325, NULL, NULL),
('ecac200c49c040af8c17d3fb9a2101b1', '0f2f32396870473b8429db231c399978', 'b35ac08bba0a4b22b4f7383de2df13d6', 'Yayyy', 0, 1765192770, NULL, NULL);

--
-- Triggers `comments`
--
DELIMITER $$
CREATE TRIGGER `decrease_total_comments` AFTER DELETE ON `comments` FOR EACH ROW UPDATE posts

SET post_total_comments = post_total_comments - 1

WHERE post_pk = OLD.comment_post_fk
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `increase_total_comments` AFTER INSERT ON `comments` FOR EACH ROW UPDATE posts
SET post_total_comments = post_total_comments + 1
WHERE post_pk = NEW.comment_post_fk
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `follows`
--

CREATE TABLE `follows` (
  `follow_user_fk` char(32) NOT NULL,
  `followed_user_fk` char(32) NOT NULL,
  `created_at` bigint(20) UNSIGNED NOT NULL,
  `deleted_at` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `follows`
--

INSERT INTO `follows` (`follow_user_fk`, `followed_user_fk`, `created_at`, `deleted_at`) VALUES
('02fbe4716fae4533a1f393253d32e20d', '09870c3149e04741b18d48c31f84d942', 1765192330, NULL),
('02fbe4716fae4533a1f393253d32e20d', 'bd49ef73ba214a63b121e472a88fdc51', 1765192328, NULL),
('02fbe4716fae4533a1f393253d32e20d', 'f61f544c01ec4bfe9870a2f4a549c82b', 1765192325, NULL),
('0f2f32396870473b8429db231c399978', '36f828e2363b4887bae2f59fdf87abaf', 1765192730, NULL),
('0f2f32396870473b8429db231c399978', '6e1dc650e73543cbaefba546026c0fb4', 1765192726, NULL),
('0f2f32396870473b8429db231c399978', '818473efe156464c8e0cb0d8d62ead08', 1765192727, NULL),
('0f2f32396870473b8429db231c399978', '8f234d16daf24cb19243d18e1183f4c1', 1765192731, NULL),
('0f2f32396870473b8429db231c399978', '9fa8ec05f9df442eb7720c5deb200b2d', 1765192731, NULL),
('36f828e2363b4887bae2f59fdf87abaf', '0f2f32396870473b8429db231c399978', 1765192593, NULL),
('36f828e2363b4887bae2f59fdf87abaf', '6e1dc650e73543cbaefba546026c0fb4', 1765192593, NULL),
('36f828e2363b4887bae2f59fdf87abaf', '818473efe156464c8e0cb0d8d62ead08', 1765192592, NULL),
('36f828e2363b4887bae2f59fdf87abaf', '8f234d16daf24cb19243d18e1183f4c1', 1765192608, NULL),
('36f828e2363b4887bae2f59fdf87abaf', '9fa8ec05f9df442eb7720c5deb200b2d', 1765192600, NULL),
('818473efe156464c8e0cb0d8d62ead08', '0f2f32396870473b8429db231c399978', 1765192243, NULL),
('818473efe156464c8e0cb0d8d62ead08', '36f828e2363b4887bae2f59fdf87abaf', 1765192250, NULL),
('818473efe156464c8e0cb0d8d62ead08', '6e1dc650e73543cbaefba546026c0fb4', 1765192245, NULL),
('818473efe156464c8e0cb0d8d62ead08', '8f234d16daf24cb19243d18e1183f4c1', 1765192247, NULL),
('818473efe156464c8e0cb0d8d62ead08', '9fa8ec05f9df442eb7720c5deb200b2d', 1765192244, NULL),
('818473efe156464c8e0cb0d8d62ead08', 'ae1be9f69de5499fa7b4ec4d0b0433bc', 1765192248, NULL),
('8f234d16daf24cb19243d18e1183f4c1', '0f2f32396870473b8429db231c399978', 1765192222, NULL),
('8f234d16daf24cb19243d18e1183f4c1', '36f828e2363b4887bae2f59fdf87abaf', 1765192221, NULL),
('8f234d16daf24cb19243d18e1183f4c1', '818473efe156464c8e0cb0d8d62ead08', 1765299975, NULL),
('8f234d16daf24cb19243d18e1183f4c1', '9fa8ec05f9df442eb7720c5deb200b2d', 1765192227, NULL),
('8f234d16daf24cb19243d18e1183f4c1', 'ae1be9f69de5499fa7b4ec4d0b0433bc', 1765299452, NULL),
('9fa8ec05f9df442eb7720c5deb200b2d', '0f2f32396870473b8429db231c399978', 1765192374, NULL),
('9fa8ec05f9df442eb7720c5deb200b2d', '36f828e2363b4887bae2f59fdf87abaf', 1765192367, NULL),
('9fa8ec05f9df442eb7720c5deb200b2d', '6e1dc650e73543cbaefba546026c0fb4', 1765192376, NULL),
('9fa8ec05f9df442eb7720c5deb200b2d', '818473efe156464c8e0cb0d8d62ead08', 1765192368, NULL),
('9fa8ec05f9df442eb7720c5deb200b2d', '8f234d16daf24cb19243d18e1183f4c1', 1765192367, NULL),
('9fa8ec05f9df442eb7720c5deb200b2d', 'ae1be9f69de5499fa7b4ec4d0b0433bc', 1765192372, NULL);

--
-- Triggers `follows`
--
DELIMITER $$
CREATE TRIGGER `decrease_total_followers` AFTER DELETE ON `follows` FOR EACH ROW UPDATE users
SET user_total_followers = user_total_followers - 1
WHERE user_pk = OLD.followed_user_fk
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `decrease_total_follows` AFTER DELETE ON `follows` FOR EACH ROW UPDATE users
SET user_total_follows = user_total_follows - 1
WHERE user_pk = OLD.follow_user_fk
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `increase_total_followers` AFTER INSERT ON `follows` FOR EACH ROW UPDATE users
SET user_total_followers = user_total_followers + 1
WHERE user_pk = NEW.followed_user_fk
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `increase_total_follows` AFTER INSERT ON `follows` FOR EACH ROW UPDATE users
SET user_total_follows = user_total_follows + 1
WHERE user_pk = NEW.follow_user_fk
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `likes`
--

CREATE TABLE `likes` (
  `like_user_fk` char(32) NOT NULL,
  `like_post_fk` char(32) NOT NULL,
  `created_at` bigint(20) UNSIGNED NOT NULL,
  `deleted_at` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `likes`
--

INSERT INTO `likes` (`like_user_fk`, `like_post_fk`, `created_at`, `deleted_at`) VALUES
('0cd10bd6ed6947de91a9bc060b1f7856', '41efa351fc234646a90b134dd1898582', 1765045173, NULL),
('0cd10bd6ed6947de91a9bc060b1f7856', '5e5fb929a7814583b2e4e80f35fcb1fc', 1765045692, NULL),
('0cd10bd6ed6947de91a9bc060b1f7856', 'aa0d9a8c8fa84a6fb921695b1a220d4f', 1765047903, NULL),
('0cd10bd6ed6947de91a9bc060b1f7856', 'b35ac08bba0a4b22b4f7383de2df13d6', 1765045101, NULL),
('0cd10bd6ed6947de91a9bc060b1f7856', 'c631b41f180d4068893259b1437d42da', 1765045050, NULL),
('0cd10bd6ed6947de91a9bc060b1f7856', 'e08c8878bf6f484b897dae4a9620a48c', 1765048397, NULL),
('0cd10bd6ed6947de91a9bc060b1f7856', 'e8263488f83f407ea70b25e73d0c6154', 1765045406, NULL),
('0f2f32396870473b8429db231c399978', '058bfa8e44a04f83b84ff051d3c673aa', 1765192928, NULL),
('0f2f32396870473b8429db231c399978', '304ed7abae8e4f5286232413087fedc5', 1765192930, NULL),
('0f2f32396870473b8429db231c399978', '47ceb2352e464419bfb5229776b2c9b4', 1765192756, NULL),
('0f2f32396870473b8429db231c399978', '5b0023a4d539407d99ba0eb23dbce6b9', 1765192749, NULL),
('0f2f32396870473b8429db231c399978', '5e5fb929a7814583b2e4e80f35fcb1fc', 1765192759, NULL),
('0f2f32396870473b8429db231c399978', '956a00d53b254108a3c0b4c39b98f409', 1765192753, NULL),
('0f2f32396870473b8429db231c399978', 'b35ac08bba0a4b22b4f7383de2df13d6', 1765192747, NULL),
('0f2f32396870473b8429db231c399978', 'd738b90e64f745a7bf4031125deab0bb', 1765192754, NULL),
('0f2f32396870473b8429db231c399978', 'e8263488f83f407ea70b25e73d0c6154', 1765192750, NULL),
('36f828e2363b4887bae2f59fdf87abaf', '266b555caa9e424499c850e958eb8626', 1765193009, NULL),
('36f828e2363b4887bae2f59fdf87abaf', '304ed7abae8e4f5286232413087fedc5', 1765192595, NULL),
('36f828e2363b4887bae2f59fdf87abaf', '956a00d53b254108a3c0b4c39b98f409', 1765192595, NULL),
('36f828e2363b4887bae2f59fdf87abaf', 'b35ac08bba0a4b22b4f7383de2df13d6', 1765192598, NULL),
('36f828e2363b4887bae2f59fdf87abaf', 'ca3596c77ac342fd854e4222064309da', 1765192609, NULL),
('36f828e2363b4887bae2f59fdf87abaf', 'd738b90e64f745a7bf4031125deab0bb', 1765192605, NULL),
('818473efe156464c8e0cb0d8d62ead08', '266b555caa9e424499c850e958eb8626', 1765447862, NULL),
('818473efe156464c8e0cb0d8d62ead08', '41efa351fc234646a90b134dd1898582', 1765057764, NULL),
('818473efe156464c8e0cb0d8d62ead08', '42ef2204ef0746289d4dc16735696256', 1765060585, NULL),
('818473efe156464c8e0cb0d8d62ead08', '47ceb2352e464419bfb5229776b2c9b4', 1765043650, NULL),
('818473efe156464c8e0cb0d8d62ead08', '5e5fb929a7814583b2e4e80f35fcb1fc', 1765043660, NULL),
('818473efe156464c8e0cb0d8d62ead08', '7a56db10018a4dea98da379045340d63', 1765454938, NULL),
('818473efe156464c8e0cb0d8d62ead08', '80ab298bc6d0485987eb477dd7b1cf3c', 1765043656, NULL),
('818473efe156464c8e0cb0d8d62ead08', '822e160bc4314a399cde83294da59c4f', 1765447857, NULL),
('818473efe156464c8e0cb0d8d62ead08', '83df1fe7bca74714ab9788981e93bad4', 1765043667, NULL),
('818473efe156464c8e0cb0d8d62ead08', '956a00d53b254108a3c0b4c39b98f409', 1765043668, NULL),
('818473efe156464c8e0cb0d8d62ead08', '9b5127cd1b004884897d86df0c71b46a', 1765043652, NULL),
('818473efe156464c8e0cb0d8d62ead08', 'aa0d9a8c8fa84a6fb921695b1a220d4f', 1765109768, NULL),
('818473efe156464c8e0cb0d8d62ead08', 'b35ac08bba0a4b22b4f7383de2df13d6', 1765043671, NULL),
('818473efe156464c8e0cb0d8d62ead08', 'c539edea6058440c93ab1bd3781dde1c', 1765109769, NULL),
('818473efe156464c8e0cb0d8d62ead08', 'c631b41f180d4068893259b1437d42da', 1765043646, NULL),
('818473efe156464c8e0cb0d8d62ead08', 'e08c8878bf6f484b897dae4a9620a48c', 1765043658, NULL),
('818473efe156464c8e0cb0d8d62ead08', 'e8263488f83f407ea70b25e73d0c6154', 1765043644, NULL),
('818473efe156464c8e0cb0d8d62ead08', 'eb1d4b67f2ea4178a2221ca6171011d1', 1765447828, NULL),
('818473efe156464c8e0cb0d8d62ead08', 'faac5a9284a94a59b3c58c0b39787db5', 1765447981, NULL),
('9fa8ec05f9df442eb7720c5deb200b2d', '058bfa8e44a04f83b84ff051d3c673aa', 1765192360, NULL),
('9fa8ec05f9df442eb7720c5deb200b2d', '42ef2204ef0746289d4dc16735696256', 1765192576, NULL),
('9fa8ec05f9df442eb7720c5deb200b2d', '47ceb2352e464419bfb5229776b2c9b4', 1765192355, NULL),
('9fa8ec05f9df442eb7720c5deb200b2d', '80ab298bc6d0485987eb477dd7b1cf3c', 1765192575, NULL),
('9fa8ec05f9df442eb7720c5deb200b2d', 'd738b90e64f745a7bf4031125deab0bb', 1765192356, NULL),
('9fa8ec05f9df442eb7720c5deb200b2d', 'e08c8878bf6f484b897dae4a9620a48c', 1765192359, NULL),
('9fa8ec05f9df442eb7720c5deb200b2d', 'faac5a9284a94a59b3c58c0b39787db5', 1765192579, NULL);

--
-- Triggers `likes`
--
DELIMITER $$
CREATE TRIGGER `decrease_total_likes` AFTER DELETE ON `likes` FOR EACH ROW UPDATE posts

SET post_total_likes = post_total_likes - 1

WHERE post_pk = OLD.like_post_fk
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `increase_total_likes` AFTER INSERT ON `likes` FOR EACH ROW UPDATE posts
SET post_total_likes = post_total_likes + 1
WHERE post_pk = NEW.like_post_fk
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `posts`
--

CREATE TABLE `posts` (
  `post_pk` char(32) NOT NULL,
  `post_user_fk` char(32) NOT NULL,
  `post_message` varchar(200) NOT NULL,
  `post_total_comments` bigint(20) UNSIGNED NOT NULL,
  `post_total_likes` bigint(20) UNSIGNED NOT NULL,
  `post_total_bookmarks` bigint(20) UNSIGNED NOT NULL,
  `post_media_path` varchar(255) DEFAULT NULL,
  `post_is_blocked` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` bigint(20) UNSIGNED NOT NULL,
  `updated_at` bigint(20) UNSIGNED DEFAULT NULL,
  `deleted_at` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `posts`
--

INSERT INTO `posts` (`post_pk`, `post_user_fk`, `post_message`, `post_total_comments`, `post_total_likes`, `post_total_bookmarks`, `post_media_path`, `post_is_blocked`, `created_at`, `updated_at`, `deleted_at`) VALUES
('058bfa8e44a04f83b84ff051d3c673aa', '818473efe156464c8e0cb0d8d62ead08', 'Laver eksamen:)))', 1, 2, 0, NULL, 0, 1765060221, NULL, NULL),
('266b555caa9e424499c850e958eb8626', '0f2f32396870473b8429db231c399978', '', 0, 2, 0, 'images/posts/f108f7179dea4f1795e91be20664af22.jpeg', 0, 1764073440, NULL, NULL),
('304ed7abae8e4f5286232413087fedc5', '818473efe156464c8e0cb0d8d62ead08', 'Det virker nu med poste igen!:))', 0, 2, 1, NULL, 0, 1765113404, 1765477771, NULL),
('41efa351fc234646a90b134dd1898582', '09870c3149e04741b18d48c31f84d942', 'GitHub just rolled out custom Copilot agents, including the JFrog Security Agent!', 0, 2, 0, NULL, 0, 1764073440, NULL, NULL),
('42ef2204ef0746289d4dc16735696256', '6e1dc650e73543cbaefba546026c0fb4', 'Farewell, Penneo 💙  Hello, Trafikstyrelsen 💚', 0, 2, 0, NULL, 0, 1764882925, NULL, NULL),
('47ceb2352e464419bfb5229776b2c9b4', 'ae1be9f69de5499fa7b4ec4d0b0433bc', 'Er du klar til et brag af en introtur med ROS DIGITAL? Så hold fast, for vi har pakket weekenden med alt det sjove!', 1, 3, 1, 'images/posts/58e348279f9d4545b65eb871cbc149d6.jpg', 0, 1764883352, NULL, NULL),
('5b0023a4d539407d99ba0eb23dbce6b9', '36f828e2363b4887bae2f59fdf87abaf', 'I love basketball!', 0, 1, 0, NULL, 0, 1765192633, NULL, NULL),
('5e5fb929a7814583b2e4e80f35fcb1fc', '818473efe156464c8e0cb0d8d62ead08', 'Weekend very soon:))!', 1, 3, 0, NULL, 0, 1764883174, 1765109756, NULL),
('7a56db10018a4dea98da379045340d63', '9fa8ec05f9df442eb7720c5deb200b2d', 'I love coding #nerd', 1, 1, 1, NULL, 0, 1765192443, NULL, NULL),
('80ab298bc6d0485987eb477dd7b1cf3c', 'bd49ef73ba214a63b121e472a88fdc51', 'KEA + Cphbusiness = EK 🥳', 0, 2, 0, NULL, 0, 1764881773, 1764881844, NULL),
('822e160bc4314a399cde83294da59c4f', '0f2f32396870473b8429db231c399978', 'This is my first post ever', 0, 1, 0, NULL, 0, 1765192743, NULL, NULL),
('83df1fe7bca74714ab9788981e93bad4', 'ae1be9f69de5499fa7b4ec4d0b0433bc', '✨Profil for tutorerne på EK DIGITAL✨', 2, 1, 1, NULL, 0, 1764883205, NULL, NULL),
('8b5ae1c879814278a9e8f2b2f6ff575a', '818473efe156464c8e0cb0d8d62ead08', 'Jeg er ret nervøs for eksamen på mandag..:(', 0, 0, 1, NULL, 0, 1765477434, NULL, NULL),
('956a00d53b254108a3c0b4c39b98f409', '818473efe156464c8e0cb0d8d62ead08', 'Det lørdag i dag:):)', 0, 3, 0, NULL, 0, 1765038307, 1765060488, NULL),
('9b5127cd1b004884897d86df0c71b46a', '09870c3149e04741b18d48c31f84d942', 'This gives devs instant security checks, dependency insights, and fix suggestions inside their coding flow. ✅', 0, 1, 0, 'images/posts/800d53b62f86483c9e8bfe612e9e139a.jpeg', 0, 1764882747, 1764882760, NULL),
('aa0d9a8c8fa84a6fb921695b1a220d4f', 'ae1be9f69de5499fa7b4ec4d0b0433bc', 'EK Digital Beerpong turnering til introfest – kun for nye studerende!', 1, 2, 0, 'images/posts/9d75974d238744b195a47214d0d7e8d5.jpg', 0, 1764883239, NULL, NULL),
('b35ac08bba0a4b22b4f7383de2df13d6', 'f61f544c01ec4bfe9870a2f4a549c82b', 'My favorite group name is 100% MESS', 1, 4, 1, NULL, 0, 1764882376, NULL, NULL),
('bf76215d0c004b84b844fa75906059a5', '0cd10bd6ed6947de91a9bc060b1f7856', 'Im the admin!', 0, 0, 0, NULL, 0, 1765044247, NULL, NULL),
('c1ad9e9b80c04a698f898c221e15d048', '36f828e2363b4887bae2f59fdf87abaf', 'Went to a concert yesterday', 0, 0, 0, NULL, 0, 1765192645, NULL, NULL),
('c539edea6058440c93ab1bd3781dde1c', '02fbe4716fae4533a1f393253d32e20d', 'UX is the best!', 0, 1, 0, NULL, 0, 1764882569, NULL, NULL),
('c631b41f180d4068893259b1437d42da', 'bd49ef73ba214a63b121e472a88fdc51', 'EK - Erhvervsakademi København er Danmarks største erhvervsakademi med 20.000 studerende.', 1, 2, 0, 'images/posts/25abcb3763a04ee181ba8dd90903a18e.jpg', 0, 1764881878, 1764881901, NULL),
('ca3596c77ac342fd854e4222064309da', '8f234d16daf24cb19243d18e1183f4c1', 'We are group MESS:)!', 1, 1, 0, NULL, 0, 1765191540, NULL, NULL),
('d738b90e64f745a7bf4031125deab0bb', '818473efe156464c8e0cb0d8d62ead08', 'Preview af vores wireframes:)', 0, 3, 0, 'images/posts/8694ff6a2e5c4269a6a97a166faa7df1.png', 0, 1765114287, NULL, NULL),
('e08c8878bf6f484b897dae4a9620a48c', 'f61f544c01ec4bfe9870a2f4a549c82b', 'My elective next year is PHP! Its the best!', 2, 3, 0, NULL, 0, 1764882430, NULL, NULL),
('e8263488f83f407ea70b25e73d0c6154', 'ae1be9f69de5499fa7b4ec4d0b0433bc', '🎉 Nedtællingen er officielt i gang! Vi har haft vores første vejledermøde med en masse nye ansigter, og vi er så småt begyndt at planlægge intro til foråret 2025!🌟', 1, 3, 2, 'images/posts/adfcf7a3858d43f18744f7d967060215.jpg', 0, 1764883305, NULL, NULL),
('eb1d4b67f2ea4178a2221ca6171011d1', '36f828e2363b4887bae2f59fdf87abaf', '', 1, 1, 1, 'images/posts/559e892c9a42448a95ffdb4de5cee492.jpeg', 0, 1765193006, NULL, NULL),
('faac5a9284a94a59b3c58c0b39787db5', '0cd10bd6ed6947de91a9bc060b1f7856', 'Im still admin!', 0, 2, 0, NULL, 0, 1765117853, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `trends`
--

CREATE TABLE `trends` (
  `trend_pk` bigint(20) UNSIGNED NOT NULL,
  `trend_title` varchar(100) NOT NULL,
  `trend_message` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `trends`
--

INSERT INTO `trends` (`trend_pk`, `trend_title`, `trend_message`) VALUES
(1, 'Politics are rotten', 'Everyone talks and only a few try to do something'),
(2, 'New rocket to the moon', 'A new rocket has been sent towards the moon, but id didn\\\'t make it'),
(3, 'Very soon!!', '12 days to the Deadline!'),
(4, 'Deadline has been moved', 'The deadline for UX and DB has been moved'),
(5, 'Trender i Danmark', 'Eurovision');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_pk` char(32) NOT NULL,
  `user_email` varchar(100) NOT NULL,
  `user_password` varchar(255) NOT NULL,
  `user_username` varchar(20) NOT NULL,
  `user_name` varchar(50) NOT NULL,
  `user_birthday` bigint(20) DEFAULT NULL,
  `user_avatar_path` varchar(255) DEFAULT NULL,
  `user_verification_key` char(32) NOT NULL,
  `user_verified_at` bigint(20) UNSIGNED DEFAULT NULL,
  `user_bio` varchar(200) DEFAULT NULL,
  `user_total_follows` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  `user_total_followers` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  `user_admin` tinyint(1) NOT NULL DEFAULT 0,
  `user_is_blocked` tinyint(1) NOT NULL DEFAULT 0,
  `user_password_reset_key` char(32) DEFAULT NULL,
  `created_at` bigint(20) UNSIGNED NOT NULL,
  `updated_at` bigint(20) UNSIGNED DEFAULT NULL,
  `deleted_at` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_pk`, `user_email`, `user_password`, `user_username`, `user_name`, `user_birthday`, `user_avatar_path`, `user_verification_key`, `user_verified_at`, `user_bio`, `user_total_follows`, `user_total_followers`, `user_admin`, `user_is_blocked`, `user_password_reset_key`, `created_at`, `updated_at`, `deleted_at`) VALUES
('02fbe4716fae4533a1f393253d32e20d', 'amri@ek.dk', 'scrypt:32768:8:1$kp6tKkjPwuxhSKUQ$19ca8bc54ed5636d479728d9c844ff11baaf2d494fb1a365afa6ac349e69db1c2fd6771d7a4db83c22c61760bda33ffc345b2bb89d47ef6d87568f1ae7fe3612', 'arturo.mora', 'Arturo', NULL, 'static/images/avatars/afb6f8bbc6ad47e8b8c602c4d142ddc7.jpeg', '', 1764882496, NULL, 3, 0, 0, 0, NULL, 1764882491, 1764882560, NULL),
('09870c3149e04741b18d48c31f84d942', 'github@github.com', 'scrypt:32768:8:1$EQpLAZqyJ4AzBxdB$1ee186e36a931e4119a7af1a8e867edad9f587f99d13d54ee5a3488dcacc5b96219b3035d464b48e53f2c0dc9b7f84f195fb0dd1a106fa68dda129cd7c012e01', 'github', 'GitHub', NULL, 'static/images/avatars/69b4a9c7082045aaa250b00aa8b15a3f.jpeg', '', 1764882653, NULL, 0, 1, 0, 0, NULL, 1764882648, NULL, NULL),
('0cd10bd6ed6947de91a9bc060b1f7856', 'a@admin.com', 'scrypt:32768:8:1$uLFfrcMweEKGgDd1$7640a5f9aceee055de586e86484d3489ac19c0a3740c39371424b875586af7d4cff984ae89047ff573b7f7b43376fec30183dd7a6a3efc44350c0059d6c085a7', 'admin', 'Admin', NULL, 'static/images/avatars/e42ed2a663064dfda854df33924e63ad.png', '', 1762862415, NULL, 0, 0, 1, 0, NULL, 1762862415, 1765117228, NULL),
('0f2f32396870473b8429db231c399978', 'basse.engelbreth@gmail.com', 'scrypt:32768:8:1$QSAOeGR729fHRHQB$218ef690b80e4562c324efa7e4c4f05b315da90d8ee641cd209f2c0265a468eb999a27c4de8e3e073ec7b74189ec687963a0b20e9c3195e3e898466e8a1dcb16', 'denrigtigebasse', 'Sebastian', NULL, 'static/images/avatars/c716bd6977fe440c9fefb8c1744b3210.jpg', '', 1755853200, NULL, 5, 4, 0, 0, NULL, 1755853200, 1764881390, NULL),
('36d47730321e4715a55a3846992babe5', 'espi0001@stud.ek.dk', 'scrypt:32768:8:1$c0sXsJRSj3icVsgY$31ea316dcac316dfafcfb837c6707be6713a0134d5e455e990d8b7e8576a316598b6c7a8c25bde034d05784fc0cfc4a86083a7ebf27f383a9f0cb56278f8355d', 'esger', 'ester', NULL, '/static/images/avatars/bb2cf009d3594973bfa1bdf915682439.png', '', 0, NULL, 0, 0, 0, 0, '988805cfe7c64c1ba59b3df4f3e23965', 1765451609, NULL, NULL),
('36f828e2363b4887bae2f59fdf87abaf', 'mpobrum@gmail.com', 'scrypt:32768:8:1$q1c79fVMR3dlZdZQ$d83a6f622cff2c7a40db5ac6dba34fbe65f13fa6ca9fc99d56c5eb7cd0979629daaaa45e756329fce24e5291cceb14099d796a4688bfad5e635eb38badebe9fe', 'brumfieldkid', 'Marcus', NULL, 'static/images/avatars/671caad28dda47e199132946c93806b6.jpg', '', 1755853200, NULL, 5, 4, 0, 0, NULL, 1755853200, 1764879246, NULL),
('6e1dc650e73543cbaefba546026c0fb4', 'mitri.media@hotmail.com', 'scrypt:32768:8:1$Kj8Mq7o1mbkURrsp$67f14c9b5af74349a51cda4d65e0bfd1efd1aeba6abdca90877274ba127c30336fcb169053e0bd53f030455c8ef0b803922039faa9e455d4c40f0b0de5ac1216', 'mitri', 'Dimitrios', NULL, 'static/images/avatars/f3430b2b4bef43e98aa859d45779362a.jpeg', '', 1764882853, NULL, 0, 4, 0, 0, NULL, 1764882849, 1764882899, NULL),
('74b1d81c3aab461f8f11c8d23065c68f', 'ester.catrinee@gmail.com', 'scrypt:32768:8:1$a5EOfiyg1X1GVg3P$b0c570dace2f26b88447edaf9e6fdc986217fb4cb1522991112929b2c237ceb41ad785ea4390c5081e2e92d2f0263c2c14ddf21a1ac1db8a08258e6017b33235', 'ester', 'ester', NULL, '/static/images/avatars/bb2cf009d3594973bfa1bdf915682439.png', '', 1765475329, NULL, 0, 0, 0, 0, 'a2a2f0e4be054f69baa5a7d33a22a182', 1765475310, NULL, NULL),
('818473efe156464c8e0cb0d8d62ead08', 'ester.piazza.koldbye@gmail.com', 'scrypt:32768:8:1$XrCn4xPgqwUgoxqx$b972f38b63a6ba4142a93c090dfcb19d95345cb13034776a0d267f6dd50c8da7abe5d40a7fd8e001e7bb11827f76707efa476893e8ec6710fd21e622191af1b6', 'ester.piazza', 'Ester Piazza-Koldbye', NULL, 'static/images/avatars/8fab32128e4645ada8c93cc6d5c14ca0.jpeg', '', 1755853200, NULL, 6, 4, 0, 0, NULL, 1755853200, 1765478364, NULL),
('8f234d16daf24cb19243d18e1183f4c1', 'webdevxclone@gmail.com', 'scrypt:32768:8:1$xeJEqrOMpMFo6xew$51a98931454793f13e3da0218be0b41666e8d9fa99eda95493cd0611ee480cdb2e72614313a2f828238d72096f29ebaf1f4b98951a5d129cd1d3193db79be220', 'mess', 'MESS', NULL, 'static/images/avatars/46e13df77f624be799847760e5b4e04a.png', '', 1764882653, NULL, 5, 4, 0, 0, NULL, 1762862415, 1765191165, NULL),
('9fa8ec05f9df442eb7720c5deb200b2d', 'sara@meisner-larsen.dk', 'scrypt:32768:8:1$ZMDnCgfRmvbF0b0v$d0d851c81f5ac34ab27bd2bc7d2fd399b8d40e173ee120a15eba89e6162ed6f7b447c6311551b2a2a9e76a51e92792d553eb52a7c9cc82b8327955b1166eed31', 'sarameisnerl', 'Sara', NULL, 'static/images/avatars/504879679be54d75a05da2de5f8ae7ee.jpg', '', 1755853200, NULL, 6, 4, 0, 0, NULL, 1755853200, 1765192423, NULL),
('ae1be9f69de5499fa7b4ec4d0b0433bc', 'ek.digital@mail.com', 'scrypt:32768:8:1$NOSe7J8d0wXVPFGF$a3bcf0b534abfa924eb76ce48d1c256180968a1e6fb5cd202dc0addf270d947ea239095f0d92bfc1d4a47c73fa0d709e3c05a18cd585c734eb3c9fac69b0ddb1', '_ekdigital', 'ekDigital', NULL, 'static/images/avatars/6824546bb59345ecad98e62dbd45b971.jpg', '', 1764882009, NULL, 0, 3, 0, 0, NULL, 1764882002, 1764882189, NULL),
('bd49ef73ba214a63b121e472a88fdc51', 'ek@gmail.com', 'scrypt:32768:8:1$4JpV4RAAbyt3pGNe$9fb0df89657042d13d2baf95354144225ce722a472361d34113b83010a052b7daa5e5f12edd0a1f26d034edb4c9bc8d91808f1b553b8540b614199fefb93d197', 'ek', 'Erhvervsakademikbh', NULL, 'static/images/avatars/9b02a0a7871043d3881a31fbfabafd8f.jpg', '', 1764881552, NULL, 0, 1, 0, 0, NULL, 1764881524, 1764881574, NULL),
('f61f544c01ec4bfe9870a2f4a549c82b', 'santiago@mail.com', 'scrypt:32768:8:1$zYyYsA5outdOTMGL$459b0c08f193ea78dc2819df24ad3bfd4d8c652cdcf014937a495816170c5af46ffbd3f90787c075b3238456b5b6eb0cfdee80574d4caeb6ffe1f60b179fe879', 'santi', 'Santiago', NULL, 'static/images/avatars/bb2cf009d3594973bfa1bdf915682439.png', '', 1764882300, NULL, 0, 1, 0, 0, NULL, 1764882283, 1764882351, NULL);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `bookmarks`
--
ALTER TABLE `bookmarks`
  ADD PRIMARY KEY (`bookmark_user_fk`,`bookmark_post_fk`),
  ADD KEY `bookmark_post_fk` (`bookmark_post_fk`);

--
-- Indexes for table `comments`
--
ALTER TABLE `comments`
  ADD PRIMARY KEY (`comment_pk`),
  ADD UNIQUE KEY `comment_pk` (`comment_pk`),
  ADD KEY `comment_post_fk` (`comment_post_fk`),
  ADD KEY `comment_user_fk` (`comment_user_fk`);
ALTER TABLE `comments` ADD FULLTEXT KEY `comment_message` (`comment_message`);

--
-- Indexes for table `follows`
--
ALTER TABLE `follows`
  ADD PRIMARY KEY (`follow_user_fk`,`followed_user_fk`),
  ADD KEY `fk_followed_user` (`followed_user_fk`);

--
-- Indexes for table `likes`
--
ALTER TABLE `likes`
  ADD PRIMARY KEY (`like_user_fk`,`like_post_fk`),
  ADD KEY `like_post_fk` (`like_post_fk`);

--
-- Indexes for table `posts`
--
ALTER TABLE `posts`
  ADD PRIMARY KEY (`post_pk`),
  ADD UNIQUE KEY `post_pk` (`post_pk`),
  ADD KEY `post_user_fk` (`post_user_fk`);
ALTER TABLE `posts` ADD FULLTEXT KEY `post_message` (`post_message`);

--
-- Indexes for table `trends`
--
ALTER TABLE `trends`
  ADD PRIMARY KEY (`trend_pk`),
  ADD UNIQUE KEY `trend_pk` (`trend_pk`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_pk`),
  ADD UNIQUE KEY `user_pk` (`user_pk`),
  ADD UNIQUE KEY `user_email` (`user_email`),
  ADD UNIQUE KEY `user_username` (`user_username`),
  ADD KEY `user_first_name` (`user_name`);
ALTER TABLE `users` ADD FULLTEXT KEY `user_bio` (`user_bio`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `trends`
--
ALTER TABLE `trends`
  MODIFY `trend_pk` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `bookmarks`
--
ALTER TABLE `bookmarks`
  ADD CONSTRAINT `fk_bookmark_post` FOREIGN KEY (`bookmark_post_fk`) REFERENCES `posts` (`post_pk`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_bookmark_user` FOREIGN KEY (`bookmark_user_fk`) REFERENCES `users` (`user_pk`) ON DELETE CASCADE;

--
-- Constraints for table `comments`
--
ALTER TABLE `comments`
  ADD CONSTRAINT `fk_comments_post` FOREIGN KEY (`comment_post_fk`) REFERENCES `posts` (`post_pk`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_comments_user` FOREIGN KEY (`comment_user_fk`) REFERENCES `users` (`user_pk`) ON DELETE CASCADE;

--
-- Constraints for table `follows`
--
ALTER TABLE `follows`
  ADD CONSTRAINT `fk_follow_user` FOREIGN KEY (`follow_user_fk`) REFERENCES `users` (`user_pk`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_followed_user` FOREIGN KEY (`followed_user_fk`) REFERENCES `users` (`user_pk`) ON DELETE CASCADE;

--
-- Constraints for table `likes`
--
ALTER TABLE `likes`
  ADD CONSTRAINT `fk_like_post` FOREIGN KEY (`like_post_fk`) REFERENCES `posts` (`post_pk`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_like_user` FOREIGN KEY (`like_user_fk`) REFERENCES `users` (`user_pk`) ON DELETE CASCADE;

--
-- Constraints for table `posts`
--
ALTER TABLE `posts`
  ADD CONSTRAINT `fk_post_user` FOREIGN KEY (`post_user_fk`) REFERENCES `users` (`user_pk`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
