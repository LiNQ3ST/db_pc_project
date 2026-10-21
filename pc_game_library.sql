/*
    CST 363 Database Design Project
    Project: PC Game Library Manager
    Section prepared by: Nabiha Fatima
*/

-- Remove existing project tables in dependency order.
DROP TABLE IF EXISTS userAchievements;
DROP TABLE IF EXISTS achievements;
DROP TABLE IF EXISTS sessions;
DROP TABLE IF EXISTS ownership;
DROP TABLE IF EXISTS gameGenre;
DROP TABLE IF EXISTS genres;
DROP TABLE IF EXISTS games;
DROP TABLE IF EXISTS developers;
DROP TABLE IF EXISTS users;

-- Store the users who own or play games in the library.
CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE
);

-- Store game developers.
CREATE TABLE developers (
    id INTEGER PRIMARY KEY,
    name VARCHAR(150) NOT NULL UNIQUE
);

-- Each game is associated with one developer.
CREATE TABLE games (
    id INTEGER PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    developer_id INTEGER NOT NULL,
    CONSTRAINT fk_games_developer
        FOREIGN KEY (developer_id) REFERENCES developers(id)
);

-- Store reusable game genres.
CREATE TABLE genres (
    id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

-- Bridge table for the many-to-many relationship between games and genres.
CREATE TABLE gameGenre (
    game_id INTEGER NOT NULL,
    genre_id INTEGER NOT NULL,
    PRIMARY KEY (game_id, genre_id),
    CONSTRAINT fk_gamegenre_game
        FOREIGN KEY (game_id) REFERENCES games(id),
    CONSTRAINT fk_gamegenre_genre
        FOREIGN KEY (genre_id) REFERENCES genres(id)
);

-- Bridge table showing which users own which games.
CREATE TABLE ownership (
    user_id INTEGER NOT NULL,
    game_id INTEGER NOT NULL,
    purchase DATE,
    PRIMARY KEY (user_id, game_id),
    CONSTRAINT fk_ownership_user
        FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_ownership_game
        FOREIGN KEY (game_id) REFERENCES games(id)
);

-- Store individual game sessions. A NULL end value means the session is active.
-- "end" is quoted because it can be treated as a reserved SQL word.
CREATE TABLE sessions (
    id INTEGER PRIMARY KEY,
    start TIMESTAMP NOT NULL,
    "end" TIMESTAMP,
    user_id INTEGER NOT NULL,
    games_id INTEGER NOT NULL,
    CONSTRAINT fk_sessions_user
        FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_sessions_game
        FOREIGN KEY (games_id) REFERENCES games(id),
    CONSTRAINT valid_session_times
        CHECK ("end" IS NULL OR "end" >= start)
);

-- Store achievements belonging to individual games.
CREATE TABLE achievements (
    id INTEGER PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    games_id INTEGER NOT NULL,
    CONSTRAINT fk_achievements_game
        FOREIGN KEY (games_id) REFERENCES games(id)
);

-- Bridge table showing which users earned which achievements.
CREATE TABLE userAchievements (
    user_id INTEGER NOT NULL,
    achievements_id INTEGER NOT NULL,
    PRIMARY KEY (user_id, achievements_id),
    CONSTRAINT fk_userachievements_user
        FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_userachievements_achievement
        FOREIGN KEY (achievements_id) REFERENCES achievements(id)
);

-- Representative sample data.
INSERT INTO users (id, username) VALUES
    (1, 'Alice'),
    (2, 'Bob'),
    (3, 'Charlie');

INSERT INTO developers (id, name) VALUES
    (1, 'Bethesda'),
    (2, 'Mojang Studios'),
    (3, 'Valve');

INSERT INTO games (id, title, developer_id) VALUES
    (1, 'Skyrim', 1),
    (2, 'Minecraft', 2),
    (3, 'Portal 2', 3);

INSERT INTO genres (id, name) VALUES
    (1, 'RPG'),
    (2, 'Adventure'),
    (3, 'Sandbox'),
    (4, 'Puzzle');

INSERT INTO gameGenre (game_id, genre_id) VALUES
    (1, 1),
    (1, 2),
    (2, 3),
    (3, 4);

INSERT INTO ownership (user_id, game_id, purchase) VALUES
    (1, 1, '2026-09-01'),
    (1, 2, '2026-09-02'),
    (2, 2, '2026-09-03'),
    (2, 3, '2026-09-04'),
    (3, 1, '2026-09-05');

INSERT INTO sessions (id, start, "end", user_id, games_id) VALUES
    (1, '2026-10-01 18:00:00', '2026-10-01 20:00:00', 1, 1),
    (2, '2026-10-02 19:00:00', '2026-10-02 21:30:00', 2, 3),
    (3, '2026-10-03 15:00:00', '2026-10-03 17:00:00', 1, 2),
    (4, '2026-10-04 14:00:00', NULL, 3, 1);

INSERT INTO achievements (id, name, games_id) VALUES
    (1, 'Dragon Slayer', 1),
    (2, 'Build a House', 2),
    (3, 'Portal Master', 3);

INSERT INTO userAchievements (user_id, achievements_id) VALUES
    (1, 1),
    (1, 2),
    (2, 3);

/* ================================================================
   REPORT QUERIES — Nabiha
   ================================================================ */

-- Query 1: Find the games owned by the greatest number of users.
--
-- Information need: The library wants to identify its most popular games.
-- Expected result: Minecraft and Skyrim each have two owners; Portal 2 has one.
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
-- Expected result: Alice has two achievements, Bob has one, and Charlie has zero.
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
-- Expected result: Alice's latest completed session is Minecraft, and Bob's is
-- Portal 2. Charlie's active session is excluded because its end is NULL.
SELECT
    u.username,
    g.title,
    s."end" AS completed_at
FROM sessions AS s
INNER JOIN users AS u
    ON s.user_id = u.id
INNER JOIN games AS g
    ON s.games_id = g.id
WHERE s."end" IS NOT NULL
  AND s."end" = (
      SELECT MAX(s2."end")
      FROM sessions AS s2
      WHERE s2.user_id = s.user_id
        AND s2."end" IS NOT NULL
  )
ORDER BY s."end" DESC;

-- Query 4: List distinct RPG and Adventure games and their developers.
--
-- Information need: A user wants to browse games in selected genres.
-- Expected result: Skyrim appears with Bethesda as its developer.
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

