-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: mariadb
-- Generation Time: Dec 02, 2025 at 04:14 PM
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
('41cf8bb0b67a4e44b54297dde497d69b', '04d09b96ceb311f0afe4fa830ee49cd3', 1764666542, NULL),
('41cf8bb0b67a4e44b54297dde497d69b', '04d09c1cceb311f0afe4fa830ee49cd3', 1764677926, NULL);

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
  `post_total_comments` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  `post_total_likes` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  `post_total_bookmarks` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
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
('04bf12c7b49a466b8a62ba0a1382f451', '41cf8bb0b67a4e44b54297dde497d69b', 'cool', 0, 0, 0, NULL, 0, 1764671458, NULL, NULL),
('04d0830aceb311f0afe4fa830ee49cd3', '9d6741b46a8841faba64d527fa59a407', 'Hello world from Laura!', 0, 0, 0, NULL, 0, 1764592872, NULL, NULL),
('04d09b01ceb311f0afe4fa830ee49cd3', '3485e0fa88794a16a6af683e0eae7d99', 'Det her er min første post!', 0, 0, 0, NULL, 0, 1764592872, NULL, NULL),
('04d09b96ceb311f0afe4fa830ee49cd3', '7cc3586578584e0ab1259d523d450cfa', 'Magnus tester systemet 🔥', 0, 0, 0, NULL, 0, 1764592872, NULL, NULL),
('04d09bd9ceb311f0afe4fa830ee49cd3', 'eff6c97024774275a2c97fbbd7dcc155', 'Victor siger hej til hele platformen!', 0, 0, 0, NULL, 0, 1764592872, NULL, NULL),
('04d09c1cceb311f0afe4fa830ee49cd3', '9259607765214c9baf2e016811f7cbe1', 'User5 er klar til at poste 🎉', 0, 1, 0, NULL, 0, 1764592872, NULL, NULL),
('04d09c9cceb311f0afe4fa830ee49cd3', 'b3f8298b28874536aa328d1612f7856c', 'Oliver uploader sin første besked.', 0, 0, 0, NULL, 0, 1764592872, NULL, NULL),
('04d09d83ceb311f0afe4fa830ee49cd3', 'a7af7de3ae224c189973d019c6d96601', 'Ida prøver lige at poste noget.', 0, 0, 0, NULL, 0, 1764592872, NULL, NULL),
('04d09dcdceb311f0afe4fa830ee49cd3', '6dbe73b305ec45a8b3653f751c02ac83', 'Tobias: “Er vi live?”', 0, 0, 0, NULL, 0, 1764592872, NULL, NULL),
('04d09e10ceb311f0afe4fa830ee49cd3', '0f219527b0fc475091408a004ed5e3f7', 'Mathias her – alt virker fint!', 0, 0, 0, NULL, 0, 1764592872, NULL, NULL),
('04d09e45ceb311f0afe4fa830ee49cd3', '1a7115179a4e44508a606bec39d5db83', 'Laura igen – sidste test for nu!', 0, 0, 0, NULL, 0, 1764592872, NULL, NULL),
('0e801399426641b4a0826e2bf362d3f7', '9e23d463c46343b7b612af70925db7be', 'Lotteeee', 0, 0, 0, NULL, 0, 1764181475, NULL, NULL),
('0f9c49eb89014c5a9323078ff62a6e34', '41cf8bb0b67a4e44b54297dde497d69b', 'Hi', 0, 0, 0, NULL, 0, 1764671445, NULL, NULL),
('240f9b6fc0a04387bd211c2619fede52', '9e23d463c46343b7b612af70925db7be', '1 december!', 0, 0, 0, NULL, 0, 1764590376, NULL, 0),
('4773a75ec2f543419efb132ce3a5a82c', '8f234d16daf24cb19243d18e1183f4c1', 'post', 0, 0, 0, '', 0, 0, 0, 0),
('623516d412ae4dbeba44f59e6c06c506', '41cf8bb0b67a4e44b54297dde497d69b', 'hhhh', 0, 0, 0, NULL, 0, 1764670868, NULL, NULL),
('6257e7f2c00c40d995a9f1ee5cf8a953', '9e23d463c46343b7b612af70925db7be', 'HELLO d', 0, 0, 0, NULL, 0, 1764590166, NULL, NULL),
('64b1ea0fc4ac4623ae426c076bfec939', '9e23d463c46343b7b612af70925db7be', 'Hi', 0, 0, 0, NULL, 0, 1764181285, NULL, NULL),
('72e1f5bca95b4ad598a445f095b1b99a', '0cd10bd6ed6947de91a9bc060b1f7856', 'hej', 0, 0, 0, '', 0, 0, 0, 0),
('844b1265cada489586b33166523f4716', '41cf8bb0b67a4e44b54297dde497d69b', 'day', 0, 0, 0, NULL, 0, 1764671461, NULL, NULL),
('85dc0223dacd4e078c7c361e9e6b4837', '41cf8bb0b67a4e44b54297dde497d69b', 'HEEEEEEELOOOOOOOOOO', 0, 0, 0, NULL, 0, 1764671702, NULL, NULL),
('a5b9b7ed39104e389c2d986e64396cde', '41cf8bb0b67a4e44b54297dde497d69b', 'Ester', 0, 0, 0, NULL, 0, 1764671785, NULL, NULL),
('aea52ac28ce24bb3a87de89b3de243e6', '41cf8bb0b67a4e44b54297dde497d69b', 'ggg', 0, 0, 0, NULL, 0, 1764671454, NULL, NULL),
('c6aa4f460e944c37892538e447e942c0', '8f234d16daf24cb19243d18e1183f4c1', 'helllo', 0, 0, 0, '', 0, 0, 0, 0),
('e56ad2e74c2c4a1b84e55e5892028d5b', '41cf8bb0b67a4e44b54297dde497d69b', 'HIIIIIILLO', 0, 0, 0, NULL, 0, 1764671004, NULL, NULL),
('e748d791fac6424790026ba333b7caa0', '41cf8bb0b67a4e44b54297dde497d69b', 'is', 0, 0, 0, NULL, 0, 1764671452, NULL, NULL);

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
(3, 'Very soon!!', '12 days to the Deadline!');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_pk` char(32) NOT NULL,
  `user_email` varchar(100) NOT NULL,
  `user_password` varchar(255) NOT NULL,
  `user_username` varchar(20) NOT NULL,
  `user_first_name` varchar(20) NOT NULL,
  `user_last_name` varchar(20) DEFAULT NULL,
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

INSERT INTO `users` (`user_pk`, `user_email`, `user_password`, `user_username`, `user_first_name`, `user_last_name`, `user_birthday`, `user_avatar_path`, `user_verification_key`, `user_verified_at`, `user_bio`, `user_total_follows`, `user_total_followers`, `user_admin`, `user_is_blocked`, `user_password_reset_key`, `created_at`, `updated_at`, `deleted_at`) VALUES
('0cd10bd6ed6947de91a9bc060b1f7856', 'c@c.com', 'scrypt:32768:8:1$uLFfrcMweEKGgDd1$7640a5f9aceee055de586e86484d3489ac19c0a3740c39371424b875586af7d4cff984ae89047ff573b7f7b43376fec30183dd7a6a3efc44350c0059d6c085a7', 'admin', 'Admin', '', 0, 'static/images/avatars/b55ad30cb10d41f685db685c21aba723.png', '', 43254235, '', 0, 0, 0, 0, '', 0, 1764690545, NULL),
('0f219527b0fc475091408a004ed5e3f7', 'mathias.jensen@example.com', 'scrypt:32768:8:1$Thqx02CZK3oD7iGt$6a48563bb7f81721c7c2b228dd89153169fa745980e08f5c2970f2acdf7f70b3fcc7956d90af875ba6c8d3b860023a8b8d5dd289209ab17382c9599b69137a67', 'mathiasj', 'Mathias', 'Jensen', NULL, 'static/images/avatars/6f77ec71b2f84b68a5b20efffbaedec4.png', '', 43254235, NULL, 0, 0, 0, 0, NULL, 1764592636, NULL, NULL),
('1', 'daniel@gmail.com', 'scrypt:32768:8:1$Thqx02CZK3oD7iGt$6a48563bb7f81721c7c2b228dd89153169fa745980e08f5c2970f2acdf7f70b3fcc7956d90af875ba6c8d3b860023a8b8d5dd289209ab17382c9599b69137a67', 'daniel', 'Daniel', 'Jensen', 0, 'static/images/avatars/6f77ec71b2f84b68a5b20efffbaedec4.png', '', 43254235, '', 0, 0, 1, 1, '', 1763829454, 0, NULL),
('1a7115179a4e44508a606bec39d5db83', 'laura@example.com', 'scrypt:32768:8:1$Thqx02CZK3oD7iGt$6a48563bb7f81721c7c2b228dd89153169fa745980e08f5c2970f2acdf7f70b3fcc7956d90af875ba6c8d3b860023a8b8d5dd289209ab17382c9599b69137a67', 'laura', 'Laura', NULL, NULL, 'static/images/avatars/6f77ec71b2f84b68a5b20efffbaedec4.png', '', 43254235, NULL, 0, 0, 0, 0, NULL, 1764592636, NULL, NULL),
('2', 'a@aaa.com', 'scrypt:32768:8:1$Thqx02CZK3oD7iGt$6a48563bb7f81721c7c2b228dd89153169fa745980e08f5c2970f2acdf7f70b3fcc7956d90af875ba6c8d3b860023a8b8d5dd289209ab17382c9599b69137a67', 'santi', 'Santiago', 'Donso', 0, 'static/images/avatars/6f77ec71b2f84b68a5b20efffbaedec4.png', '', 455656, '', 0, 0, 0, 0, '', 455656, 0, NULL),
('329c600778234351aa3b7209b51d04ee', 'nora@example.com', 'scrypt:32768:8:1$Thqx02CZK3oD7iGt$6a48563bb7f81721c7c2b228dd89153169fa745980e08f5c2970f2acdf7f70b3fcc7956d90af875ba6c8d3b860023a8b8d5dd289209ab17382c9599b69137a67', 'nora', 'Nora', NULL, NULL, 'static/images/avatars/6f77ec71b2f84b68a5b20efffbaedec4.png', '', 43254235, NULL, 0, 0, 0, 0, NULL, 1764592636, NULL, NULL),
('3485e0fa88794a16a6af683e0eae7d99', 'emma@example.com', 'scrypt:32768:8:1$Thqx02CZK3oD7iGt$6a48563bb7f81721c7c2b228dd89153169fa745980e08f5c2970f2acdf7f70b3fcc7956d90af875ba6c8d3b860023a8b8d5dd289209ab17382c9599b69137a67', 'emma', 'Emma', NULL, NULL, 'static/images/avatars/6f77ec71b2f84b68a5b20efffbaedec4.png', '', 324234, NULL, 0, 0, 0, 0, NULL, 1764592636, NULL, NULL),
('3d64bc9339fc4ecbb0a4716bb0e6fc1c', 'user10@example.com', 'scrypt:32768:8:1$Thqx02CZK3oD7iGt$6a48563bb7f81721c7c2b228dd89153169fa745980e08f5c2970f2acdf7f70b3fcc7956d90af875ba6c8d3b860023a8b8d5dd289209ab17382c9599b69137a67', 'user10', 'User10', NULL, NULL, 'static/images/avatars/6f77ec71b2f84b68a5b20efffbaedec4.png', '', 1764598994, NULL, 0, 0, 0, 0, NULL, 1764592563, NULL, NULL),
('41cf8bb0b67a4e44b54297dde497d69b', 'o@o.com', 'scrypt:32768:8:1$ic1ywz4n0hFmlnd6$a7301eb587cb10c0b23b64e672c194eb217cc8bbe3cd29ee81e3704f14eac5fb56ba51aa49cf35f9823749c2f591de40f4008f2109b635656819fcbc646ee943', 'oooo123', 'OLE', NULL, NULL, 'static/images/avatars/1efdd1822b9b4601982e33ffc66702d4.png', '', 1764598994, NULL, 0, 0, 0, 0, NULL, 1764178906, 1764690432, NULL),
('570eb207e22e4d158723d18d04195ec2', 'user6@example.com', 'scrypt:32768:8:1$Thqx02CZK3oD7iGt$6a48563bb7f81721c7c2b228dd89153169fa745980e08f5c2970f2acdf7f70b3fcc7956d90af875ba6c8d3b860023a8b8d5dd289209ab17382c9599b69137a67', 'user6', 'User6', NULL, NULL, 'static/images/avatars/6f77ec71b2f84b68a5b20efffbaedec4.png', '', 1764598994, NULL, 0, 0, 0, 0, NULL, 1764592563, NULL, NULL),
('6dbe73b305ec45a8b3653f751c02ac83', 'tobias.madsen@example.com', 'scrypt:32768:8:1$Thqx02CZK3oD7iGt$6a48563bb7f81721c7c2b228dd89153169fa745980e08f5c2970f2acdf7f70b3fcc7956d90af875ba6c8d3b860023a8b8d5dd289209ab17382c9599b69137a67', 'tobiasm', 'Tobias', 'Madsen', NULL, 'static/images/avatars/6f77ec71b2f84b68a5b20efffbaedec4.png', '', 1764598994, NULL, 0, 0, 0, 0, NULL, 1764592636, NULL, NULL),
('7c5e351716e241f885e86595eb0845ff', 'user2@example.com', 'scrypt:32768:8:1$Thqx02CZK3oD7iGt$6a48563bb7f81721c7c2b228dd89153169fa745980e08f5c2970f2acdf7f70b3fcc7956d90af875ba6c8d3b860023a8b8d5dd289209ab17382c9599b69137a67', 'user2', 'User2', NULL, NULL, 'static/images/avatars/6f77ec71b2f84b68a5b20efffbaedec4.png', '', 1764598994, NULL, 0, 0, 0, 0, NULL, 1764592563, NULL, NULL),
('7cc3586578584e0ab1259d523d450cfa', 'magnus.lund@example.com', 'scrypt:32768:8:1$Thqx02CZK3oD7iGt$6a48563bb7f81721c7c2b228dd89153169fa745980e08f5c2970f2acdf7f70b3fcc7956d90af875ba6c8d3b860023a8b8d5dd289209ab17382c9599b69137a67', 'magnusl', 'Magnus', 'Lund', NULL, 'static/images/avatars/6f77ec71b2f84b68a5b20efffbaedec4.png', '', 1764598994, NULL, 0, 0, 0, 0, NULL, 1764592636, NULL, NULL),
('887b08f417364577adad870faaa057cb', 'd@d.com', 'scrypt:32768:8:1$536EgvMQDWdLbesp$61a4578b95d90c76b87759bae10278658bd19056d5e396c90eb0f345f151cc05cbeda559f02cdc714f1bbdfae2cfce0bca0ced9276cf48856c6cc186e5a9de5f', 'dname', 'marcus', '', 0, 'static/images/avatars/6f77ec71b2f84b68a5b20efffbaedec4.png', '', 324234, '', 0, 0, 0, 0, '0', 0, 1764690655, NULL),
('8f234d16daf24cb19243d18e1183f4c1', 'webdevxclone@gmail.com', 'scrypt:32768:8:1$xeJEqrOMpMFo6xew$51a98931454793f13e3da0218be0b41666e8d9fa99eda95493cd0611ee480cdb2e72614313a2f828238d72096f29ebaf1f4b98951a5d129cd1d3193db79be220', 'brumfield', 'marcus', '', 0, 'static/images/avatars/6f77ec71b2f84b68a5b20efffbaedec4.png', '', 234342, '', 0, 0, 0, 0, '0', 0, 0, NULL),
('9259607765214c9baf2e016811f7cbe1', 'user5@example.com', 'scrypt:32768:8:1$Thqx02CZK3oD7iGt$6a48563bb7f81721c7c2b228dd89153169fa745980e08f5c2970f2acdf7f70b3fcc7956d90af875ba6c8d3b860023a8b8d5dd289209ab17382c9599b69137a67', 'user5', 'User5', NULL, NULL, 'static/images/avatars/6f77ec71b2f84b68a5b20efffbaedec4.png', '', 1764598994, NULL, 0, 0, 0, 0, NULL, 1764592563, NULL, NULL),
('92a44a165ed8472c83123c585ed65d2d', 'user3@example.com', 'scrypt:32768:8:1$Thqx02CZK3oD7iGt$6a48563bb7f81721c7c2b228dd89153169fa745980e08f5c2970f2acdf7f70b3fcc7956d90af875ba6c8d3b860023a8b8d5dd289209ab17382c9599b69137a67', 'user3', 'User3', NULL, NULL, 'static/images/avatars/6f77ec71b2f84b68a5b20efffbaedec4.png', '', 1764598994, NULL, 0, 0, 0, 0, NULL, 1764592563, NULL, NULL),
('9d6741b46a8841faba64d527fa59a407', 'user1@example.com', 'scrypt:32768:8:1$Thqx02CZK3oD7iGt$6a48563bb7f81721c7c2b228dd89153169fa745980e08f5c2970f2acdf7f70b3fcc7956d90af875ba6c8d3b860023a8b8d5dd289209ab17382c9599b69137a67', 'user1', 'User1', NULL, NULL, 'static/images/avatars/6f77ec71b2f84b68a5b20efffbaedec4.png', '', 1764598994, NULL, 0, 0, 0, 0, NULL, 1764592563, NULL, NULL),
('9e23d463c46343b7b612af70925db7be', 'l@l.com', 'scrypt:32768:8:1$MPQqrAKO9N6ew1B8$01eb72378de452511dd2c8a154aa621246f43d58bf03a50a816285976ff8044099704ab1a2041701c5af44406f42f7728ccab1dbca9aa594b48be45896940042', 'lotte2025', 'Lotte H', NULL, NULL, 'static/images/avatars/d86cdb0281014039aa8e091d3c7670e9.jpg', '', 1764179094, NULL, 0, 0, 0, 0, NULL, 1764178935, 1764590195, NULL),
('a7af7de3ae224c189973d019c6d96601', 'ida@example.com', 'scrypt:32768:8:1$Thqx02CZK3oD7iGt$6a48563bb7f81721c7c2b228dd89153169fa745980e08f5c2970f2acdf7f70b3fcc7956d90af875ba6c8d3b860023a8b8d5dd289209ab17382c9599b69137a67', 'ida', 'Ida', NULL, NULL, 'static/images/avatars/6f77ec71b2f84b68a5b20efffbaedec4.png', '', 1764598994, NULL, 0, 0, 0, 0, NULL, 1764592636, NULL, NULL),
('ae63241f8e5d476a80868c2798257c8b', 'user9@example.com', 'scrypt:32768:8:1$Thqx02CZK3oD7iGt$6a48563bb7f81721c7c2b228dd89153169fa745980e08f5c2970f2acdf7f70b3fcc7956d90af875ba6c8d3b860023a8b8d5dd289209ab17382c9599b69137a67', 'user9', 'User9', NULL, NULL, 'static/images/avatars/6f77ec71b2f84b68a5b20efffbaedec4.png', '', 1764598994, NULL, 0, 0, 0, 0, NULL, 1764592563, NULL, NULL),
('b3f8298b28874536aa328d1612f7856c', 'oliver.holm@example.com', 'scrypt:32768:8:1$Thqx02CZK3oD7iGt$6a48563bb7f81721c7c2b228dd89153169fa745980e08f5c2970f2acdf7f70b3fcc7956d90af875ba6c8d3b860023a8b8d5dd289209ab17382c9599b69137a67', 'oliverh', 'Oliver', 'Holm', NULL, 'static/images/avatars/6f77ec71b2f84b68a5b20efffbaedec4.png', '', 1764598994, NULL, 0, 0, 0, 0, NULL, 1764592636, NULL, NULL),
('b71f5fd99f73446c8a6dc441552f26a1', 'anna@example.com', 'scrypt:32768:8:1$Thqx02CZK3oD7iGt$6a48563bb7f81721c7c2b228dd89153169fa745980e08f5c2970f2acdf7f70b3fcc7956d90af875ba6c8d3b860023a8b8d5dd289209ab17382c9599b69137a67', 'anna', 'Anna', NULL, NULL, 'static/images/avatars/6f77ec71b2f84b68a5b20efffbaedec4.png', '', 1764598994, NULL, 0, 0, 0, 0, NULL, 1764592377, NULL, NULL),
('d65322b178c34012a26965e934eccabf', 'user4@example.com', 'scrypt:32768:8:1$Thqx02CZK3oD7iGt$6a48563bb7f81721c7c2b228dd89153169fa745980e08f5c2970f2acdf7f70b3fcc7956d90af875ba6c8d3b860023a8b8d5dd289209ab17382c9599b69137a67', 'user4', 'User4', NULL, NULL, 'static/images/avatars/6f77ec71b2f84b68a5b20efffbaedec4.png', '', 1764598994, NULL, 0, 0, 0, 0, NULL, 1764592563, NULL, NULL),
('d6dd42af83f444d09e7ddcbdda1fdc81', 'freja@example.com', 'scrypt:32768:8:1$Thqx02CZK3oD7iGt$6a48563bb7f81721c7c2b228dd89153169fa745980e08f5c2970f2acdf7f70b3fcc7956d90af875ba6c8d3b860023a8b8d5dd289209ab17382c9599b69137a67', 'freja', 'Freja', NULL, NULL, 'static/images/avatars/6f77ec71b2f84b68a5b20efffbaedec4.png', '', 1764663154, NULL, 0, 0, 0, 0, NULL, 1764592636, NULL, NULL),
('d744ff489af94aeea1e399a2a1248744', 'user7@example.com', 'password', 'user7', 'User7', NULL, NULL, 'https://avatar.iran.liara.run/public/40', '4cc9521aceb211f0afe4fa830ee49cd3', NULL, NULL, 0, 0, 0, 0, NULL, 1764592563, NULL, NULL),
('def17f3b86b54ad59afc8b8ad907752e', 'user8@example.com', 'password', 'user8', 'User8', NULL, NULL, 'https://avatar.iran.liara.run/public/40', '4cc9528fceb211f0afe4fa830ee49cd3', NULL, NULL, 0, 0, 0, 0, NULL, 1764592563, NULL, NULL),
('eff6c97024774275a2c97fbbd7dcc155', 'victor.henriksen@example.com', 'Test1234!', 'victorh', 'Victor', 'Henriksen', NULL, 'https://avatar.iran.liara.run/public/40', '78787d7bceb211f0afe4fa830ee49cd3', NULL, NULL, 0, 0, 0, 0, NULL, 1764592636, NULL, NULL);

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
  ADD KEY `user_first_name` (`user_first_name`),
  ADD KEY `user_last_name` (`user_last_name`);
ALTER TABLE `users` ADD FULLTEXT KEY `user_bio` (`user_bio`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `trends`
--
ALTER TABLE `trends`
  MODIFY `trend_pk` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

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
