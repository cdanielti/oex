create or replace NONEDITIONABLE PACKAGE pck_usuarios IS

    -- Procedimiento para insertar un usuario
    PROCEDURE insertar_usuario(
        p_nombre_usuario IN VARCHAR2,
        p_estatus_usuario IN NUMBER,
        p_fecha_alta IN DATE
    );

    -- Procedimiento para actualizar un usuario
    PROCEDURE actualizar_usuario(
        p_id_usuario IN NUMBER,
        p_nombre_usuario IN VARCHAR2,
        p_estatus_usuario IN NUMBER,
        p_fecha_baja IN DATE
    );

    -- Procedimiento para eliminar un usuario
    PROCEDURE eliminar_usuario(
        p_id_usuario IN NUMBER
    );

    -- Función para obtener información de un usuario
    FUNCTION obtener_usuario(
        p_id_usuario IN NUMBER
    ) RETURN SYS_REFCURSOR;

END pck_usuarios;
