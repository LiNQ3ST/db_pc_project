-- CST 363 Fall 2026 Term A
-- Group Project: PC Game Library Manager
-- SQL Database by: Nabiha Fatima & Sahtra Green
-- Data by: Sahtra Green
-- Queries by: Nabiha Fatima

-- DBMS: PostgreSQL 18
-- Setup:
-- 1. Create a PostgreSQL database named pc_game_library.
-- 2. Connect to the database.
-- 3. Run this SQL file to create the tables, insert sample data,
--    and execute the four report queries.
-- Note: Running this script again resets the project tables and their sample data. 
-- No additional extensions are required.

-- DATABASE SCHEMA
-- Drop existing tables to allow the script to run multiple times.
-- Tables are dropped in reverse dependency order to avoid foreign key errors.
DROP TABLE IF EXISTS userAchievements;
DROP TABLE IF EXISTS sessions;
DROP TABLE IF EXISTS ownership;
DROP TABLE IF EXISTS gameGenre;
DROP TABLE IF EXISTS achievements;
DROP TABLE IF EXISTS games;
DROP TABLE IF EXISTS genres;
DROP TABLE IF EXISTS developers;
DROP TABLE IF EXISTS users;

-- Create tables and define primary and foreign key relationships.
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE developers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE genres (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE games (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    developer_id INT NOT NULL,
    FOREIGN KEY (developer_id) REFERENCES developers(id)
);

CREATE TABLE gameGenre (
    game_id INT NOT NULL,
    genre_id INT NOT NULL,
    PRIMARY KEY (game_id, genre_id),
    FOREIGN KEY (game_id) REFERENCES games(id),
    FOREIGN KEY (genre_id) REFERENCES genres(id)
);

CREATE TABLE ownership (
    user_id INT NOT NULL,
    game_id INT NOT NULL,
    purchase DATE,
    PRIMARY KEY (user_id, game_id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (game_id) REFERENCES games(id)
);

CREATE TABLE achievements (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    games_id INT NOT NULL,
    FOREIGN KEY (games_id) REFERENCES games(id)
);

CREATE TABLE sessions (
    id SERIAL PRIMARY KEY,
    start_at TIMESTAMP,
    end_at TIMESTAMP,
    user_id INT NOT NULL,
    games_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (games_id) REFERENCES games(id)
);

CREATE TABLE userAchievements (
    user_id INT NOT NULL,
    achievements_id INT NOT NULL,
    PRIMARY KEY (user_id, achievements_id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (achievements_id) REFERENCES achievements(id)
);

-- SAMPLE DATA
-- Populate the database with users, developers, games, genres, ownership records, achievements, and play sessions.
INSERT INTO users (username) VALUES
('Love'),
('Spaghett1'),
('RNGesus'),
('SALTY_CH33SE'),
('KneeYawn_Spase_Ninja'),
('EntropicNightmare'),
('All_the_good_names_Argon');

INSERT INTO developers (name) VALUES
('Bethesda Game Studios'),
('Valve'),
('FromSoftware'),
('CD Projekt RED'),
('Digital Extremes');

INSERT INTO games (title, developer_id) VALUES
('The Elder Scrolls V: Skyrim', 1),
('Fallout 4', 1),
('Half-Life 2', 2),
('Portal 2', 2),
('Counter-Strike 2', 2),
('Dark Souls III', 3),
('Elden Ring', 3),
('The Witcher 3: Wild Hunt', 4),
('Cyberpunk 2077', 4),
('Warframe', 5);

INSERT INTO genres (name) VALUES
('RPG'),
('Adventure'),
('Action'),
('Shooter'),
('Puzzle'),
('Soulslike'),
('Open World');

INSERT INTO gameGenre (game_id, genre_id) VALUES
(1,1), (1,2), (1,7),
(2,1), (2,4), (2,7),
(3,3), (3,4),
(4,2), (4,5),
(5,3), (5,4),
(6,3), (6,6),
(7,1), (7,6), (7,7),
(8,1), (8,2), (8,7),
(9,1), (9,4), (9,7), 
(10,3), (10,4); 

INSERT INTO ownership (user_id, game_id, purchase) VALUES
(1,1,'2023-02-14'),
(1,4,'2024-07-20'),
(1,10,'2025-06-02'),
(2,2,'2022-05-12'),
(2,4,'2023-11-08'),
(2,7,'2025-01-17'),
(3,6,'2023-06-25'),
(3,7,'2024-03-18'),
(3,10,'2025-08-02'),
(4,3,'2022-10-31'),
(4,5,'2023-09-14'),
(4,10,'2024-12-05'),
(5,1,'2021-04-15'),
(5,8,'2023-02-22'),
(5,10,'2024-07-19'),
(6,1,'2022-01-10'),
(6,6,'2023-05-16'),
(6,7,'2024-06-21'),
(6,9,'2025-02-08'),
(7,1,'2022-01-01'),
(7,2,'2022-02-01'),
(7,3,'2022-03-01'),
(7,4,'2022-04-01'),
(7,5,'2022-05-01'),
(7,6,'2022-06-01'),
(7,7,'2022-07-01'),
(7,8,'2022-08-01'),
(7,9,'2022-09-01'),
(7,10,'2022-10-01');

-- name, games_id
INSERT INTO achievements (name, games_id) VALUES
('Dragonborn',1),
('Commonwealth Survivor',2),
('One Free Bullet',3), 
('Lunacy',4), 
('Ace in the Hole',5), 
('Lord of Cinder',6),  
('Elden Lord',7),  
('Master Witcher',8),   
('Night City Legend',9),  
('The Second Dream',10),  
('The War Within',10),   
('The Sacrifice',10); 

INSERT INTO sessions (start_at, end_at, user_id, games_id) VALUES
('2026-10-01 18:00','2026-10-01 20:30',1,1),
('2026-10-03 19:00','2026-10-03 21:15',1,4),

('2026-10-05 16:00','2026-10-05 18:00',2,2),
('2026-10-07 20:00','2026-10-07 22:30',2,7),

('2026-10-09 18:00','2026-10-09 21:00',3,10),
('2026-10-11 19:00','2026-10-11 22:00',3,7),

('2026-10-12 17:00','2026-10-12 19:30',4,5),
('2026-10-14 20:00','2026-10-14 22:00',4,10),

('2026-10-15 18:00','2026-10-15 21:00',5,10),
('2026-10-16 19:00',NULL,5,10),

('2026-10-17 16:00','2026-10-17 19:00',6,6),
('2026-10-18 20:00','2026-10-18 23:00',6,9),

('2026-10-17 14:00','2026-10-18 17:00',7,1),
('2026-10-18 18:00','2026-10-19 20:30',7,8),
('2026-10-20 19:00',NULL,7,10);

INSERT INTO userAchievements (user_id, achievements_id) VALUES
(1,1),
(1,4),
(2,2),
(2,7),
(3,7),
(3,10),
(3,11),
(5,1),
(5,10),
(5,12),
(6,6),
(6,9),
(7,1),
(7,3),
(7,10);

/* ================================================================
   REPORT QUERIES — Nabiha
   ================================================================ */

-- Query 1: Find the games owned by the greatest number of users.
--
-- Information need: The library wants to identify its most popular games.
-- Expected result: Warframe has five owners; Skyrim and Elden Ring each have four.
-- Critical relationship demonstrated: games -> ownership -> users.
SELECT
    g.title,
    COUNT(DISTINCT o.user_id) AS number_of_owners
FROM games AS g
INNER JOIN ownership AS o
    ON g.id = o.game_id
GROUP BY g.id, g.title
HAVING COUNT(DISTINCT o.user_id) >= 1
ORDER BY number_of_owners DESC, g.title;

-- Query 2: Count achievements for every user, including users with zero.
--
-- Information need: The library wants to compare achievement progress across
-- all users, not only users who have earned an achievement.
-- Expected result: RNGesus has three achievements, Love has two, and SALTY_CH33SE has zero.
SELECT
    u.username,
    COUNT(DISTINCT ua.achievements_id) AS achievements_earned
FROM users AS u
LEFT OUTER JOIN userAchievements AS ua
    ON u.id = ua.user_id
GROUP BY u.id, u.username
ORDER BY achievements_earned DESC, u.username;

-- Query 3: Find each user's most recent completed game session.
--
-- Information need: The library wants to show the last game each user finished.
-- Expected result: All_the_good_names_Argon's latest completed session is
-- The Witcher 3: Wild Hunt, and EntropicNightmare's is Cyberpunk 2077.
-- Active sessions are excluded because end_at is NULL.
SELECT
    u.username,
    g.title,
    s.end_at AS completed_at
FROM sessions AS s
INNER JOIN users AS u
    ON s.user_id = u.id
INNER JOIN games AS g
    ON s.games_id = g.id
WHERE s.end_at IS NOT NULL
  AND s.end_at = (
      SELECT MAX(s2.end_at)
      FROM sessions AS s2
      WHERE s2.user_id = s.user_id
        AND s2.end_at IS NOT NULL
  )
ORDER BY s.end_at DESC;

-- Query 4: List distinct RPG and Adventure games and their developers.
--
-- Information need: A user wants to browse games in selected genres.
-- Expected result: Skyrim appears with Bethesda Game Studios as its developer.
-- DISTINCT prevents a game from appearing more than once if it matches more
-- than one selected genre.
SELECT DISTINCT
    g.title,
    d.name AS developer
FROM games AS g
INNER JOIN developers AS d
    ON g.developer_id = d.id
INNER JOIN gameGenre AS gg
    ON g.id = gg.game_id
INNER JOIN genres AS ge
    ON gg.genre_id = ge.id
WHERE ge.name IN ('RPG', 'Adventure')
ORDER BY g.title;