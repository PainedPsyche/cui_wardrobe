CREATE TABLE `outfits` (
    `owner` VARCHAR(60) NOT NULL,
    `slot` TINYINT NOT NULL,
    `name` VARCHAR(255) NULL DEFAULT NULL,
    `clothes` MEDIUMTEXT NULL DEFAULT NULL,

    PRIMARY KEY (`owner`, `slot`)
);