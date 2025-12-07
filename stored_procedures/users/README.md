# Stored Procedures - Users Module

Stored procedures relacionados con la gestión de usuarios.

## Template de ejemplo:

```sql
-- sp_nombre_del_procedimiento.sql
CREATE OR REPLACE FUNCTION sp_create_user(
    p_google_id VARCHAR(255),
    p_email VARCHAR(255),
    p_name VARCHAR(255),
    p_picture_url TEXT
)
RETURNS TABLE(
    user_id INT,
    created BOOLEAN,
    message TEXT
)
AS $$
DECLARE
    v_user_id INT;
    v_exists BOOLEAN;
BEGIN
    -- Verificar si el usuario ya existe
    SELECT EXISTS(
        SELECT 1 FROM users WHERE google_id = p_google_id
    ) INTO v_exists;

    IF v_exists THEN
        -- Usuario existe, actualizar last_login
        UPDATE users
        SET last_login = CURRENT_TIMESTAMP,
            name = p_name,
            picture_url = p_picture_url
        WHERE google_id = p_google_id
        RETURNING id INTO v_user_id;

        RETURN QUERY SELECT v_user_id, FALSE, 'User updated'::TEXT;
    ELSE
        -- Usuario nuevo, crear
        INSERT INTO users (google_id, email, name, picture_url, role, last_login)
        VALUES (p_google_id, p_email, p_name, p_picture_url, 'customer', CURRENT_TIMESTAMP)
        RETURNING id INTO v_user_id;

        RETURN QUERY SELECT v_user_id, TRUE, 'User created'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;
```

## Stored Procedures sugeridos:

- `sp_create_user.sql` - Crear o actualizar usuario (OAuth)
- `sp_get_user_by_email.sql` - Obtener usuario por email
- `sp_get_user_by_google_id.sql` - Obtener usuario por Google ID
- `sp_update_user_role.sql` - Actualizar rol de usuario
