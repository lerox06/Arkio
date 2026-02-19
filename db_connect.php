<?php
/**
 * db_connect.php
 * Connexion sécurisée à la base de données via PDO
 * Gestion foncière — Stack PHP 8 / MySQL
 */

declare(strict_types=1);

// ── Configuration ─────────────────────────────────────────────
define('DB_HOST', 'localhost');
define('DB_NAME', 'gestion_fonciere');
define('DB_USER', 'root');          // ← adapter en production
define('DB_PASS', '');              // ← adapter en production
define('DB_CHARSET', 'utf8mb4');

/**
 * Retourne une instance PDO (Singleton).
 * Lève une PDOException en cas d'échec (ne jamais exposer à l'utilisateur).
 */
function getPDO(): PDO
{
    static $pdo = null;

    if ($pdo === null) {
        $dsn = sprintf(
            'mysql:host=%s;dbname=%s;charset=%s',
            DB_HOST,
            DB_NAME,
            DB_CHARSET
        );

        $options = [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES   => false,   // requêtes vraiment préparées
        ];

        try {
            $pdo = new PDO($dsn, DB_USER, DB_PASS, $options);
        } catch (PDOException $e) {
            // En production : logger l'erreur, ne jamais l'afficher
            error_log('[DB] Connexion échouée : ' . $e->getMessage());
            throw new RuntimeException('Service temporairement indisponible.', 503);
        }
    }

    return $pdo;
}
