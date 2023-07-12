
CREATE DATABASE IF NOT EXISTS `bbslist` DEFAULT CHARACTER SET ascii COLLATE ascii_general_ci;
USE `bbslist`;

CREATE USER `bbslist`@`localhost` IDENTIFIED BY `dialup`;
GRANT ALL PRIVILIGES ON `bbslist` to `bbslist`@`localhost`;

CREATE TABLE `filters` (
  `name` varchar(8) NOT NULL,
  `bits` bit(16) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=ascii COLLATE=ascii_general_ci;

INSERT INTO `filters` (`name`, `bits`) VALUES
('ASCII',    b'0000000000000001'),
('ANSI',     b'0000000000000010'),
('RIP',      b'0000000000000100'),
('PETSCII',  b'0000000000001000'),
('TELETEXT', b'0000000000010000'),
('EBCDIC',   b'0000000000100000'),
('ATARI',    b'1000000000000000'),
('AMIGA',    b'0100000000000000'),
('C64',      b'0010000000000000'),
('APPLE',    b'0001000000000000'),
('PC',       b'0000100000000000'),
('UNIX',     b'0000010000000000');

CREATE TABLE `hosts` (
  `phone` varchar(7) NOT NULL,
  `protocol` varchar(8) NOT NULL DEFAULT 'telnet',
  `host` varchar(64) NOT NULL,
  `port` varchar(8) NOT NULL DEFAULT '23',
  `name` varchar(256) DEFAULT NULL,
  `description` varchar(1024) DEFAULT NULL,
  `filter` bit(16) NOT NULL DEFAULT b'0'
) ENGINE=InnoDB DEFAULT CHARSET=ascii COLLATE=ascii_general_ci;

CREATE TABLE `modems` (
  `device` varchar(256) NOT NULL,
  `extension` varchar(256) NOT NULL,
  `available` tinyint(1) NOT NULL DEFAULT 1,
  `protocol` varchar(8) DEFAULT NULL,
  `host` varchar(64) DEFAULT NULL,
  `port` varchar(8) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=ascii COLLATE=ascii_general_ci;

INSERT INTO `modems` (`device`, `extension`, `available`, `protocol`, `host`, `port`) VALUES
('/dev/ttyUSB0', 'SIP/modem0', 1, NULL, NULL, NULL),
('/dev/ttyUSB1', 'SIP/modem1', 1, NULL, NULL, NULL);


ALTER TABLE `filters`
  ADD PRIMARY KEY (`name`),
  ADD UNIQUE KEY `bits` (`bits`);

ALTER TABLE `hosts`
  ADD PRIMARY KEY (`phone`);

ALTER TABLE `modems`
  ADD PRIMARY KEY (`device`);
