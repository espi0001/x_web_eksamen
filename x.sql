-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: mariadb
-- Generation Time: Nov 27, 2025 at 08:11 AM
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
  `comment_pk` bigint(20) UNSIGNED NOT NULL,
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
('0e801399426641b4a0826e2bf362d3f7', '9e23d463c46343b7b612af70925db7be', 'Lotteeee', 0, 0, 0, NULL, 0, 1764181475, NULL, NULL),
('4773a75ec2f543419efb132ce3a5a82c', '8f234d16daf24cb19243d18e1183f4c1', 'post', 0, 0, 0, '', 0, 0, 0, 0),
('64b1ea0fc4ac4623ae426c076bfec939', '9e23d463c46343b7b612af70925db7be', 'Hi', 0, 0, 0, NULL, 0, 1764181285, NULL, NULL),
('72e1f5bca95b4ad598a445f095b1b99a', '0cd10bd6ed6947de91a9bc060b1f7856', 'hej', 0, 0, 0, '', 0, 0, 0, 0),
('c6aa4f460e944c37892538e447e942c0', '8f234d16daf24cb19243d18e1183f4c1', 'helllo', 0, 0, 0, '', 0, 0, 0, 0);

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
('0cd10bd6ed6947de91a9bc060b1f7856', 'c@c.com', 'scrypt:32768:8:1$uLFfrcMweEKGgDd1$7640a5f9aceee055de586e86484d3489ac19c0a3740c39371424b875586af7d4cff984ae89047ff573b7f7b43376fec30183dd7a6a3efc44350c0059d6c085a7', 'cname', 'Marcuss', '', 0, 'https://avatar.iran.liara.run/public/40', '', 43254235, '', 0, 0, 0, 0, '', 0, 0, NULL),
('1', 'daniel@gmail.com', 'password', 'daniel', 'Daniel', 'Jensen', 0, 'avatar.jpg', 'c29fa5894f224964953801c925a7cac5', 0, '', 0, 0, 1, 1, '', 1763829454, 0, NULL),
('2', 'a@aaa.com', 'password', 'santi', 'Santiago', 'Donso', 0, 'avatar.jpg', '', 455656, '', 0, 0, 0, 0, '', 455656, 0, NULL),
('3d7dc1ca16694b9b9c14d0b16cf60beb', 'p@p.com', 'scrypt:32768:8:1$Thqx02CZK3oD7iGt$6a48563bb7f81721c7c2b228dd89153169fa745980e08f5c2970f2acdf7f70b3fcc7956d90af875ba6c8d3b860023a8b8d5dd289209ab17382c9599b69137a67', 'pp', 'pp', '', 0, 'https://avatar.iran.liara.run/public/40', '3f3f83986f364f10bd94876703f4e0b5', 0, '', 0, 0, 0, 0, '0', 1764178352, 0, NULL),
('41cf8bb0b67a4e44b54297dde497d69b', 'o@o.com', 'scrypt:32768:8:1$ic1ywz4n0hFmlnd6$a7301eb587cb10c0b23b64e672c194eb217cc8bbe3cd29ee81e3704f14eac5fb56ba51aa49cf35f9823749c2f591de40f4008f2109b635656819fcbc646ee943', 'oo', 'oo', NULL, NULL, NULL, 'eb6bd0ab95dd45b3b8249a72e536068d', NULL, NULL, 0, 0, 0, 0, NULL, 1764178906, NULL, NULL),
('887b08f417364577adad870faaa057cb', 'd@d.com', 'scrypt:32768:8:1$536EgvMQDWdLbesp$61a4578b95d90c76b87759bae10278658bd19056d5e396c90eb0f345f151cc05cbeda559f02cdc714f1bbdfae2cfce0bca0ced9276cf48856c6cc186e5a9de5f', 'dname', 'marcus', '', 0, 'https://avatar.iran.liara.run/public/40', '', 324234, '', 0, 0, 0, 0, '0', 0, 0, NULL),
('8f234d16daf24cb19243d18e1183f4c1', 'webdevxclone@gmail.com', 'scrypt:32768:8:1$xeJEqrOMpMFo6xew$51a98931454793f13e3da0218be0b41666e8d9fa99eda95493cd0611ee480cdb2e72614313a2f828238d72096f29ebaf1f4b98951a5d129cd1d3193db79be220', 'brumfield', 'marcus', '', 0, 'https://avatar.iran.liara.run/public/40', '', 234342, '', 0, 0, 0, 0, '0', 0, 0, NULL),
('9e23d463c46343b7b612af70925db7be', 'l@l.com', 'scrypt:32768:8:1$MPQqrAKO9N6ew1B8$01eb72378de452511dd2c8a154aa621246f43d58bf03a50a816285976ff8044099704ab1a2041701c5af44406f42f7728ccab1dbca9aa594b48be45896940042', 'lotte2023', 'Lotte', NULL, NULL, 'static/images/avatars/d86cdb0281014039aa8e091d3c7670e9.jpg', '', 1764179094, NULL, 0, 0, 0, 0, NULL, 1764178935, NULL, NULL);

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
-- AUTO_INCREMENT for table `comments`
--
ALTER TABLE `comments`
  MODIFY `comment_pk` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

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
