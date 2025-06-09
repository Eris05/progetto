-- Inserimento di un dipendente nella tabella app_user
CREATE TABLE IF NOT EXISTS app_user (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(255) NOT NULL,
    username VARCHAR(255) UNIQUE NOT NULL
);

INSERT INTO app_user (id, email, password, role, username)
VALUES
(1, 'dipendente@example.com', '$2a$10$z.qS4jjaTLsBTMX5ZG/jwewOSVyHTbm6x/Mbp.Uy7k8mIN/1DbHpO', 'EMPLOYEE', 'd1');
