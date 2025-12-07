# Development Seeds

Datos de prueba para el ambiente de desarrollo.

## Ejemplo:

```sql
-- seed_dev_data.sql

-- Usuarios de prueba
INSERT INTO users (google_id, email, name, role) VALUES
('dev_admin_001', 'admin@test.com', 'Admin Test', 'admin'),
('dev_user_001', 'user1@test.com', 'Usuario Test 1', 'customer'),
('dev_user_002', 'user2@test.com', 'Usuario Test 2', 'customer');

-- Productos de prueba
INSERT INTO products (title, description, price, anime_name, character_name, google_drive_file_id) VALUES
('Naruto Uzumaki Model', 'Modelo 3D de alta calidad', 29.99, 'Naruto', 'Naruto Uzumaki', 'fake_drive_id_001'),
('Goku SSJ Model', 'Modelo 3D de Goku', 39.99, 'Dragon Ball Z', 'Goku', 'fake_drive_id_002');
```
