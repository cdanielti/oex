create or replace NONEDITIONABLE PACKAGE BODY pck_usuarios IS

    -- Procedimiento para insertar un usuario
    PROCEDURE insertar_usuario(
        p_nombre_usuario IN VARCHAR2,
        p_estatus_usuario IN NUMBER,
        p_fecha_alta IN DATE
    ) IS
    BEGIN
        INSERT INTO usuarios (nombre_usuario, estatus_usuario, fecha_alta)
        VALUES (p_nombre_usuario, p_estatus_usuario, p_fecha_alta);

        COMMIT;
    END insertar_usuario;

    -- Procedimiento para actualizar un usuario
    PROCEDURE actualizar_usuario(
        p_id_usuario IN NUMBER,
        p_nombre_usuario IN VARCHAR2,
        p_estatus_usuario IN NUMBER,
        p_fecha_baja IN DATE
    ) IS
    BEGIN
        UPDATE usuarios
        SET nombre_usuario = p_nombre_usuario,
            estatus_usuario = p_estatus_usuario,
            fecha_baja = p_fecha_baja
        WHERE id_usuario = p_id_usuario;

        COMMIT;
    END actualizar_usuario;

    -- Procedimiento para eliminar un usuario
    PROCEDURE eliminar_usuario(
        p_id_usuario IN NUMBER
    ) IS
    BEGIN
        DELETE FROM usuarios
        WHERE id_usuario = p_id_usuario;

        COMMIT;
    END eliminar_usuario;

    -- Función para obtener información de un usuario
    FUNCTION obtener_usuario(
        p_id_usuario IN NUMBER
    ) RETURN SYS_REFCURSOR IS
        v_cursor SYS_REFCURSOR;
    BEGIN
        OPEN v_cursor FOR
            SELECT id_usuario, nombre_usuario, estatus_usuario, fecha_alta, fecha_baja
            FROM usuarios
            WHERE id_usuario = p_id_usuario;

        RETURN v_cursor;
    END obtener_usuario;

END pck_usuarios;
