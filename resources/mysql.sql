-- #!mysql
-- #{cucumber
-- #  {meta
-- #    {init
CREATE TABLE IF NOT EXISTS cucumber_meta
(
    id         TINYINT UNSIGNED PRIMARY KEY,
    db_version TINYINT UNSIGNED NOT NULL DEFAULT 1
);
-- #    }
-- #    {get-version
-- #      :id int 1
SELECT db_version
FROM cucumber_meta
WHERE id = :id;
-- #    }
-- #    {set-version
-- #      :id int 1
-- #      :version int
INSERT INTO cucumber_meta (id, db_version)
VALUES (:id, :version)
ON DUPLICATE KEY UPDATE db_version = :version;
-- #    }
-- #  }
-- #  {init
-- #    {players
CREATE TABLE IF NOT EXISTS cucumber_players
(
    id         INT UNSIGNED AUTO_INCREMENT,
    name       VARCHAR(32)  NOT NULL,
    ip         VARCHAR(39)  NOT NULL,
    first_join INT UNSIGNED NOT NULL,
    last_join  INT UNSIGNED NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY `name` (name)
);
-- #    }
-- #    {punishments
-- #      {bans
CREATE TABLE IF NOT EXISTS cucumber_bans
(
    id           INT UNSIGNED AUTO_INCREMENT,
    player_id    INT UNSIGNED NOT NULL,
    reason       VARCHAR(500) DEFAULT NULL,
    expiration   INT UNSIGNED,
    moderator    VARCHAR(32)  NOT NULL,
    time_created INT UNSIGNED NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY `fk__cucumber_bans__player_id__cucumber_players__id` (player_id) REFERENCES cucumber_players (id),
    FOREIGN KEY `fk__cucumber_bans__moderator__cucumber_players__name` (moderator) REFERENCES cucumber_players (name)
);
-- #      }
-- #      {ip-bans
CREATE TABLE IF NOT EXISTS cucumber_ip_bans
(
    id           INT UNSIGNED AUTO_INCREMENT,
    ip           VARCHAR(39)  NOT NULL,
    player_id    INT UNSIGNED NOT NULL,
    reason       VARCHAR(500) DEFAULT NULL,
    expiration   INT UNSIGNED,
    moderator    VARCHAR(32)  NOT NULL,
    time_created INT UNSIGNED NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY `fk__cucumber_ip_bans__player_id__cucumber_players__id` (player_id) REFERENCES cucumber_players (id),
    FOREIGN KEY `fk__cucumber_ip_bans__moderator__cucumber_players__name` (moderator) REFERENCES cucumber_players (name)
);
-- #      }
-- #      {mutes
CREATE TABLE IF NOT EXISTS cucumber_mutes
(
    id           INT UNSIGNED AUTO_INCREMENT,
    player_id    INT UNSIGNED NOT NULL,
    reason       VARCHAR(500) DEFAULT NULL,
    expiration   INT UNSIGNED,
    moderator    VARCHAR(32)  NOT NULL,
    time_created INT UNSIGNED NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY `fk__cucumber_mutes__player_id__cucumber_players__id` (player_id) REFERENCES cucumber_players (id),
    FOREIGN KEY `fk__cucumber_mutes__moderator__cucumber_players__name` (moderator) REFERENCES cucumber_players (name)
);
-- #      }
-- #      {pardons
CREATE TABLE IF NOT EXISTS cucumber_pardons
(
    id           INT UNSIGNED AUTO_INCREMENT,
    type         VARCHAR(12)  NOT NULL,
    player_id    INT UNSIGNED NOT NULL,
    moderator    VARCHAR(32)  NOT NULL,
    time_created INT UNSIGNED NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY `fk__cucumber_pardons__player_id__cucumber_players__id` (player_id) REFERENCES cucumber_players (id),
    FOREIGN KEY `fk__cucumber_pardons__moderator__cucumber_players__name` (moderator) REFERENCES cucumber_players (name)
);
-- #      }
-- #    }
-- #  }
-- #  {migrate
-- #    {get
-- #      {tables
SHOW TABLES;
-- #      }
-- #      {columns-from-table
-- #        :table string
SHOW COLUMNS FROM :table;
-- #      }
-- #    }
-- #    {transfer
-- #      {players
INSERT INTO cucumber_players (id, name, ip, first_join, last_join)
SELECT id, name, ip, first_join, last_join
FROM players;
-- #      }
-- #      {bans
INSERT INTO cucumber_bans (id, player_id, reason, expiration, moderator, time_created)
SELECT id, player, reason, expiration, moderator, UNIX_TIMESTAMP()
FROM bans;
-- #      }
-- #      {ip-bans
INSERT INTO cucumber_ip_bans (id, ip, reason, expiration, moderator, time_created)
SELECT id, ip, reason, expiration, moderator, UNIX_TIMESTAMP()
FROM ip_bans;
-- #      }
-- #      {mutes
INSERT INTO cucumber_mutes (id, player_id, reason, expiration, moderator, time_created)
SELECT id, player, reason, expiration, moderator, UNIX_TIMESTAMP()
FROM mutes;
-- #      }
-- #    }
-- #  }
-- #  {add
-- #    {player
-- #      :name string
-- #      :ip string
INSERT INTO cucumber_players (name, ip, first_join, last_join)
VALUES (:name, :ip, UNIX_TIMESTAMP(), UNIX_TIMESTAMP())
ON DUPLICATE KEY UPDATE ip        = :ip,
                        last_join = UNIX_TIMESTAMP();
-- #    }
-- #  }
-- #  {get
-- #    {player
-- #      {by-name
-- #        :name string
SELECT *
FROM cucumber_players
WHERE name = :name;
-- #      }
-- #      {by-ip
-- #        :ip string
SELECT *
FROM cucumber_players
WHERE ip = :ip;
-- #      }
-- #    }
-- #    {punishments
-- #      {bans
-- #        {all
SELECT cucumber_bans.*,
       cucumber_players.*,
       cucumber_bans.id      AS ban_id,
       cucumber_players.id   AS player_id,
       cucumber_players.name AS player_name
FROM cucumber_bans
         INNER JOIN cucumber_players ON cucumber_bans.player_id = cucumber_players.id;
-- #        }
-- #        {current
SELECT cucumber_bans.*,
       cucumber_players.*,
       cucumber_bans.id      AS ban_id,
       cucumber_players.id   AS player_id,
       cucumber_players.name AS player_name
FROM cucumber_bans
         INNER JOIN cucumber_players ON cucumber_bans.player_id = cucumber_players.id
WHERE cucumber_bans.expiration > UNIX_TIMESTAMP()
   OR cucumber_bans.expiration IS NULL;
-- #        }
-- #        {limited
-- #          :from int
-- #          :limit int
-- #          :all bool false
SELECT cucumber_bans.*,
       cucumber_players.*,
       cucumber_bans.id      AS ban_id,
       cucumber_players.id   AS player_id,
       cucumber_players.name AS player_name
FROM cucumber_bans
         INNER JOIN cucumber_players ON cucumber_bans.player_id = cucumber_players.id
WHERE cucumber_bans.expiration > UNIX_TIMESTAMP()
   OR cucumber_bans.expiration IS NULL
   OR :all
ORDER BY cucumber_bans.time_created DESC
LIMIT :from, :limit;
-- #        }
-- #        {count
-- #          :all bool false
SELECT COUNT(*) AS count
FROM cucumber_bans
WHERE expiration > UNIX_TIMESTAMP()
   OR expiration IS NULL
   OR :all;
-- #        }
-- #        {by-player
-- #          :player string
SELECT cucumber_bans.*,
       cucumber_players.*,
       cucumber_bans.id      AS ban_id,
       cucumber_players.id   AS player_id,
       cucumber_players.name AS player_name
FROM cucumber_bans
         INNER JOIN cucumber_players ON cucumber_bans.player_id = cucumber_players.id
WHERE cucumber_players.name = :player;
-- #        }
-- #      }
-- #      {ip-bans
-- #        {all
SELECT cucumber_ip_bans.*,
       cucumber_players.*,
       cucumber_ip_bans.id   AS ip_ban_id,
       cucumber_players.id   AS player_id,
       cucumber_players.name AS player_name
FROM cucumber_ip_bans
         INNER JOIN cucumber_players ON cucumber_ip_bans.player_id = cucumber_players.id;
-- #        }
-- #        {current
SELECT cucumber_ip_bans.*,
       cucumber_players.*,
       cucumber_ip_bans.id   AS ip_ban_id,
       cucumber_players.id   AS player_id,
       cucumber_players.name AS player_name
FROM cucumber_ip_bans
         INNER JOIN cucumber_players ON cucumber_ip_bans.player_id = cucumber_players.id
WHERE expiration > UNIX_TIMESTAMP()
   OR expiration IS NULL;
-- #        }
-- #        {limited
-- #          :from int
-- #          :limit int
-- #          :all bool false
SELECT cucumber_ip_bans.*,
       cucumber_players.*,
       cucumber_ip_bans.id   AS ip_ban_id,
       cucumber_players.id   AS player_id,
       cucumber_players.name AS player_name
FROM cucumber_ip_bans
         INNER JOIN cucumber_players ON cucumber_ip_bans.player_id = cucumber_players.id
WHERE expiration > UNIX_TIMESTAMP()
   OR expiration IS NULL
   OR :all
ORDER BY time_created DESC
LIMIT :from, :limit;
-- #        }
-- #        {count
-- #          :all bool false
SELECT COUNT(*) AS count
FROM cucumber_ip_bans
WHERE expiration > UNIX_TIMESTAMP()
   OR expiration IS NULL
   OR :all;
-- #        }
-- #        {by-ip
-- #          :ip string
SELECT cucumber_ip_bans.*,
       cucumber_players.*,
       cucumber_ip_bans.id   AS ip_ban_id,
       cucumber_players.id   AS player_id,
       cucumber_players.name AS player_name
FROM cucumber_ip_bans
         INNER JOIN cucumber_players ON cucumber_ip_bans.player_id = cucumber_players.id
WHERE cucumber_ip_bans.ip = :ip;
-- #        }
-- #        {by-player
-- #          :player string
SELECT *
FROM cucumber_ip_bans
WHERE ip IN (
    SELECT *
    FROM (
             SELECT ip
             FROM cucumber_players
             WHERE name = :player
         ) AS a
);
-- #        }
-- #      }
-- #      {mutes
-- #        {all
SELECT cucumber_mutes.*,
       cucumber_players.*,
       cucumber_mutes.id     AS mute_id,
       cucumber_players.id   AS player_id,
       cucumber_players.name AS player_name
FROM cucumber_mutes
         INNER JOIN cucumber_players ON cucumber_mutes.player_id = cucumber_players.id;
-- #        }
-- #        {current
SELECT cucumber_mutes.*,
       cucumber_players.*,
       cucumber_mutes.id     AS mute_id,
       cucumber_players.id   AS player_id,
       cucumber_players.name AS player_name
FROM cucumber_mutes
         INNER JOIN cucumber_players ON cucumber_mutes.player_id = cucumber_players.id
WHERE cucumber_mutes.expiration > UNIX_TIMESTAMP()
   OR cucumber_mutes.expiration IS NULL;
-- #        }
-- #        {limited
-- #          :from int
-- #          :limit int
-- #          :all bool false
SELECT cucumber_mutes.*,
       cucumber_players.*,
       cucumber_mutes.id     AS mute_id,
       cucumber_players.id   AS player_id,
       cucumber_players.name AS player_name
FROM cucumber_mutes
         INNER JOIN cucumber_players ON cucumber_mutes.player_id = cucumber_players.id
WHERE cucumber_mutes.expiration > UNIX_TIMESTAMP()
   OR cucumber_mutes.expiration IS NULL
   OR :all
ORDER BY cucumber_mutes.time_created DESC
LIMIT :from, :limit;
-- #        }
-- #        {count
-- #          :all bool false
SELECT COUNT(*) AS count
FROM cucumber_mutes
WHERE expiration > UNIX_TIMESTAMP()
   OR expiration IS NULL
   OR :all;
-- #        }
-- #        {by-player
-- #          :player string
SELECT cucumber_mutes.*,
       cucumber_players.*,
       cucumber_mutes.id     AS mute_id,
       cucumber_players.id   AS player_id,
       cucumber_players.name AS player_name
FROM cucumber_mutes
         INNER JOIN cucumber_players ON cucumber_mutes.player_id = cucumber_players.id
WHERE cucumber_players.name = :player;
-- #        }
-- #      }
-- #      {pardons
-- #        {by-player
-- #            :player string
SELECT cucumber_pardons.*,
       cucumber_players.*,
       cucumber_pardons.id   AS pardon_id,
       cucumber_players.id   AS player_id,
       cucumber_players.name AS player_name
FROM cucumber_pardons
         INNER JOIN cucumber_players on cucumber_pardons.player_id = cucumber_players.id
WHERE cucumber_players.name = :player;
-- #        }
-- #      }
-- #    }
-- #  }
-- #  {punish
-- #    {ban
-- #      :player string
-- #      :reason string
-- #      :expiration ?int
-- #      :moderator string
INSERT INTO cucumber_bans (player_id, reason, expiration, moderator, time_created)
SELECT id, :reason, :expiration, :moderator, UNIX_TIMESTAMP()
FROM cucumber_players
WHERE name = :player;
-- #    }
-- #    {unban
-- #      :player string
DELETE
FROM cucumber_bans
WHERE player_id IN (
    SELECT *
    FROM (
             SELECT id
             FROM cucumber_players
             WHERE name = :player
         ) AS a
);
-- #    }
-- #    {unban-all
DELETE
FROM cucumber_bans;
-- #    }
-- #    {ip-ban
-- #      :ip string
-- #      :player string
-- #      :reason string
-- #      :expiration ?int
-- #      :moderator string
INSERT INTO cucumber_ip_bans (ip, player_id, reason, expiration, moderator, time_created)
SELECT :ip, id, :reason, :expiration, :moderator, UNIX_TIMESTAMP()
FROM cucumber_players
WHERE name = :player;
-- #    }
-- #    {ip-unban
-- #      :ip string
DELETE
FROM cucumber_ip_bans
WHERE ip = :ip;
-- #    }
-- #    {ip-unban-all
DELETE
FROM cucumber_ip_bans;
-- #    }
-- #    {mute
-- #      :player string
-- #      :reason string
-- #      :expiration ?int
-- #      :moderator string
INSERT INTO cucumber_mutes (player_id, reason, expiration, moderator, time_created)
SELECT id, :reason, :expiration, :moderator, UNIX_TIMESTAMP()
FROM cucumber_players
WHERE name = :player;
-- #    }
-- #    {unmute
-- #      :player string
DELETE
FROM cucumber_mutes
WHERE player_id IN (
    SELECT *
    FROM (
             SELECT id
             FROM cucumber_players
             WHERE name = :player
         ) AS a
);
-- #    }
-- #    {unmute-all
DELETE
FROM cucumber_mutes;
-- #    }
-- #    {pardon
-- #        :type string
-- #        :player string
-- #        :moderator string
INSERT INTO cucumber_pardons (player_id, type, moderator, time_created)
SELECT id, :type, :moderator, UNIX_TIMESTAMP()
FROM cucumber_players
WHERE name = :player
   OR ip = :player;
-- #    }
-- #  }
-- #}