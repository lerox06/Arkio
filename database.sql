-- ============================================================
-- GESTION FONCIÈRE - Script SQL
-- Compatible MySQL / phpMyAdmin
-- ============================================================

CREATE DATABASE IF NOT EXISTS `gestion_fonciere`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE `gestion_fonciere`;

-- ------------------------------------------------------------
-- Table : clients
-- Types : Fond d'investissement, Exploitant (EPHAD...), Privé
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `clients` (
  `id`           INT UNSIGNED     NOT NULL AUTO_INCREMENT,
  `nom`          VARCHAR(150)     NOT NULL,
  `type_client`  ENUM('Fond','Exploitant','Privé') NOT NULL DEFAULT 'Privé',
  `email`        VARCHAR(255)         NULL,
  `telephone`    VARCHAR(20)          NULL,
  `adresse`      TEXT                 NULL,
  `created_at`   TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`   TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- Table : projets
-- Regroupe Promotion, Maîtrise d'Ouvrage (MOA)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `projets` (
  `id`             INT UNSIGNED     NOT NULL AUTO_INCREMENT,
  `reference`      VARCHAR(50)      NOT NULL UNIQUE COMMENT 'Référence interne unique ex: PROM-2024-001',
  `nom`            VARCHAR(200)     NOT NULL,
  `type_activite`  ENUM('Promotion','MOA') NOT NULL,
  `type_bien`      ENUM('Villa Luxe','EPHAD','Résidence','Bureau','Autre') NOT NULL DEFAULT 'Autre',
  `client_id`      INT UNSIGNED         NULL,
  `localisation`   VARCHAR(255)         NULL,
  `surface_m2`     DECIMAL(10,2)        NULL,
  `budget_total`   DECIMAL(15,2)        NULL COMMENT 'Budget en euros',
  `date_debut`     DATE                 NULL,
  `date_fin_prev`  DATE                 NULL,
  `statut`         ENUM('Avant-projet','En cours','Livré','Suspendu') NOT NULL DEFAULT 'Avant-projet',
  `description`    TEXT                 NULL,
  `created_at`     TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`     TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_projets_client`
    FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`)
    ON DELETE SET NULL ON UPDATE CASCADE,
  INDEX `idx_type_activite` (`type_activite`),
  INDEX `idx_statut`        (`statut`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- Table : interventions_entretien
-- Pilier : Entretien Patrimonial
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `interventions_entretien` (
  `id`              INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `projet_id`       INT UNSIGNED     NULL COMMENT 'Bien rattaché au patrimoine',
  `titre`           VARCHAR(200) NOT NULL,
  `type_intervention` ENUM('Préventif','Curatif','Réglementaire','Amélioration') NOT NULL DEFAULT 'Curatif',
  `prestataire`     VARCHAR(150)     NULL,
  `date_planifiee`  DATE             NULL,
  `date_realisation`DATE             NULL,
  `cout_estime`     DECIMAL(12,2)    NULL,
  `cout_reel`       DECIMAL(12,2)    NULL,
  `statut`          ENUM('En attente','En cours','Terminé') NOT NULL DEFAULT 'En attente',
  `priorite`        ENUM('Faible','Moyenne','Haute','Urgente') NOT NULL DEFAULT 'Moyenne',
  `notes`           TEXT             NULL,
  `created_at`      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_entretien_projet`
    FOREIGN KEY (`projet_id`) REFERENCES `projets` (`id`)
    ON DELETE SET NULL ON UPDATE CASCADE,
  INDEX `idx_statut_entretien` (`statut`),
  INDEX `idx_priorite`         (`priorite`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- Table : finances
-- Suivi financier par projet
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `finances` (
  `id`           INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `projet_id`    INT UNSIGNED  NOT NULL,
  `libelle`      VARCHAR(255)  NOT NULL,
  `type_flux`    ENUM('Recette','Dépense') NOT NULL,
  `categorie`    ENUM('Foncier','Construction','Honoraires','Commercialisation','Financement','Autre') NOT NULL DEFAULT 'Autre',
  `montant`      DECIMAL(15,2) NOT NULL,
  `date_flux`    DATE          NOT NULL,
  `justificatif` VARCHAR(500)      NULL COMMENT 'Chemin vers le fichier justificatif',
  `valide`       TINYINT(1)    NOT NULL DEFAULT 0,
  `created_at`   TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_finances_projet`
    FOREIGN KEY (`projet_id`) REFERENCES `projets` (`id`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  INDEX `idx_projet_flux` (`projet_id`, `type_flux`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- DONNÉES DE DÉMONSTRATION
-- ============================================================

INSERT INTO `clients` (`nom`, `type_client`, `email`, `telephone`) VALUES
  ('Fonds Patrimoine Prestige', 'Fond',      'contact@fpp.fr',         '01 44 00 11 22'),
  ('Groupe EPHAD Sérénité',     'Exploitant','direction@ephad-ser.fr',  '04 72 80 90 10'),
  ('M. & Mme Durand',           'Privé',     'p.durand@gmail.com',     '06 12 34 56 78'),
  ('Alpha Invest SCPI',         'Fond',      'invest@alpha-scpi.fr',   '01 55 66 77 88'),
  ('Résidences Senior Azur',    'Exploitant','contact@rs-azur.fr',     '04 93 50 60 70');

INSERT INTO `projets` (`reference`,`nom`,`type_activite`,`type_bien`,`client_id`,`localisation`,`surface_m2`,`budget_total`,`date_debut`,`date_fin_prev`,`statut`) VALUES
  ('PROM-2024-001','Villa Les Palmiers','Promotion','Villa Luxe',   3,'Cannes, 06',           650,  3500000,'2024-03-01','2025-09-30','En cours'),
  ('PROM-2024-002','EPHAD Les Bruyères','Promotion','EPHAD',        2,'Lyon, 69',            4200, 12000000,'2024-01-15','2026-06-30','En cours'),
  ('PROM-2024-003','Domaine Méditerranée','Promotion','Villa Luxe', 1,'Saint-Tropez, 83',    820,  5200000,'2024-06-01','2026-01-31','Avant-projet'),
  ('MOA-2024-001', 'Résidence Seniors Côte d\'Azur','MOA','EPHAD',  5,'Nice, 06',            6500, 18000000,'2023-09-01','2025-12-31','En cours'),
  ('PROM-2025-001','Villa Horizon Bleu','Promotion','Villa Luxe',   3,'Antibes, 06',          480,  2800000,'2025-02-01','2026-08-31','Avant-projet'),
  ('MOA-2023-001', 'Bureaux Prestige Part-Dieu','MOA','Bureau',     4,'Lyon, 69',            2800,  9500000,'2023-05-01','2025-04-30','Livré');

INSERT INTO `interventions_entretien` (`projet_id`,`titre`,`type_intervention`,`prestataire`,`date_planifiee`,`statut`,`priorite`,`cout_estime`) VALUES
  (1,'Révision climatisation Villa Palmiers',  'Préventif',    'ClimPro SARL',  '2025-04-15','En attente','Moyenne', 2500),
  (2,'Contrôle sécurité incendie EPHAD',       'Réglementaire','SecuFire 69',   '2025-03-01','En cours',  'Haute',   8000),
  (4,'Ravalement façade Résidence Azur',       'Curatif',      'BâtiRénov',     '2025-05-10','En attente','Haute',  45000),
  (6,'Maintenance ascenseurs Part-Dieu',       'Préventif',    'Otis Services', '2025-02-28','Terminé',   'Moyenne', 3200),
  (1,'Entretien jardin et piscine',            'Préventif',    'Green Espaces',  NULL,        'En attente','Faible',  1800);

INSERT INTO `finances` (`projet_id`,`libelle`,`type_flux`,`categorie`,`montant`,`date_flux`,`valide`) VALUES
  (1,'Achat terrain Cannes',          'Dépense', 'Foncier',          850000,'2024-03-15',1),
  (1,'Acompte client Durand 30%',     'Recette', 'Commercialisation',1050000,'2024-04-01',1),
  (2,'Honoraires architecte MOE',     'Dépense', 'Honoraires',       420000,'2024-02-10',1),
  (2,'Subvention ARS',                'Recette', 'Financement',     2500000,'2024-03-20',1),
  (3,'Acquisition foncière St-Tropez','Dépense', 'Foncier',         1800000,'2024-07-01',0),
  (4,'Travaux GCO tranche 1',         'Dépense', 'Construction',    4200000,'2024-01-30',1);
