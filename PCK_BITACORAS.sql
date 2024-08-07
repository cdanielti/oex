CREATE OR REPLACE PACKAGE PCK_BITACORAS IS
/*
creacion de variables de instancia en el ambito del paquete
*/
SUBTYPE is_procedure_name is varchar2(30);

/*creacion de las excepciones generales de cada procedimiento*/
ie_error_create_table   EXCEPTION;
ie_error_create_trigger EXCEPTION;

/*inicializacion de las excepciones*/
PRAGMA EXCEPTION_INIT(ie_error_create_table,-1200);
PRAGMA EXCEPTION_INIT(ie_error_create_trigger,-1300);


PROCEDURE sp_create_bit (ps_tabla_name in is_procedure_name);

PROCEDURE sp_create_audit_table (ps_tabla_name in is_procedure_name);

PROCEDURE sp_create_audit_trigger (ps_tabla_name in is_procedure_name);

END PCK_BITACORAS;
/


CREATE OR REPLACE PACKAGE BODY PCK_BITACORAS IS
/*
PROCEDIMIENTO QUE INVOCA LA CREACION DE TABLA Y TRIGGER
*/
PROCEDURE sp_create_bit (ps_tabla_name in is_procedure_name) 
IS
BEGIN

    --SE INVOCA EL PROCESIMIENTO QUE CREA LA TABLA
    sp_create_audit_table(ps_tabla_name);
    
    --SE INVOCA EL PROCESIMIENTO QUE CREA EL TRIGGER
    sp_create_audit_trigger(ps_tabla_name);
    
    --TODO SALIO OK
    DBMS_OUTPUT.PUT_LINE('CREACION DE BITACORAS CORRECTA.');

EXCEPTION
    WHEN ie_error_create_table THEN 
        DBMS_OUTPUT.PUT_LINE('ERROR EN LA CREACION DE LA TABLA DE LA BITACORA: '||SQLERRM);
    WHEN ie_error_create_trigger THEN
        DBMS_OUTPUT.PUT_LINE('ERROR EN LA CREACION DEL TRIGGER: '||SQLERRM);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: '||SQLERRM);
END sp_create_bit;

PROCEDURE sp_create_audit_table(ps_tabla_name in is_procedure_name) IS
    v_new_table_name VARCHAR2(255);
BEGIN
    -- Define el nombre de la nueva tabla de bitácora
    v_new_table_name := ps_tabla_name || '_bit';

    -- Crear la tabla de bitácora con las columnas originales y las nuevas columnas para los cambios
    EXECUTE IMMEDIATE 'CREATE TABLE ' || v_new_table_name || ' AS SELECT * FROM ' || ps_tabla_name || ' WHERE 1=0';

    FOR col IN (SELECT column_name, data_type, data_length FROM user_tab_columns WHERE table_name = UPPER(ps_tabla_name)) LOOP
        -- Agregar nuevas columnas para los cambios
        EXECUTE IMMEDIATE 'ALTER TABLE ' || v_new_table_name || ' ADD (' || col.column_name || '_new ' || col.data_type || CASE WHEN col.data_type = 'VARCHAR2' THEN '(' || col.data_length || ')' ELSE '' END || ')';
    END LOOP;
    
    --se agregan las columnas de usuario y fecha de modificacion
    EXECUTE IMMEDIATE 'ALTER TABLE ' || v_new_table_name || ' ADD ( usuario varchar2(50) )';
    EXECUTE IMMEDIATE 'ALTER TABLE ' || v_new_table_name || ' ADD ( fecha TIMESTAMP )';

    DBMS_OUTPUT.PUT_LINE('Tabla de bitácora ' || v_new_table_name || ' creada exitosamente.');
EXCEPTION
    WHEN OTHERS THEN
        RAISE ie_error_create_table;
END sp_create_audit_table;

PROCEDURE sp_create_audit_trigger(ps_tabla_name in is_procedure_name) IS

    v_trigger_name      VARCHAR2(255);
    v_new_table_name    VARCHAR2(255);
    vs_query            VARCHAR2(10000);
    vs_values           VARCHAR2(10000);
    
BEGIN
     -- Define el nombre del trigger y de la nueva tabla de bitácora
    v_trigger_name := 'trg_' || ps_tabla_name || '_audit';
    v_new_table_name := ps_tabla_name || '_bit';
    
    vs_values := 'values (';

    -- Crear el trigger que llenará la tabla de bitácora
    vs_query:= '
    CREATE OR REPLACE TRIGGER ' || v_trigger_name || '
    AFTER UPDATE ON ' || ps_tabla_name || '
    FOR EACH ROW
    BEGIN
        INSERT INTO ' || v_new_table_name || ' (';

    -- Agregar las columnas del insert
    FOR col IN (SELECT column_name FROM user_tab_columns WHERE table_name = UPPER(ps_tabla_name||'_bit')) LOOP
        vs_query:= vs_query  || col.column_name || ',' ;
    END LOOP;
    
    --se agregan las columnas de usuario y fecha
     --vs_query:= vs_query  || 'usuario,fecha,';
    
    vs_query:= vs_query  ||');';
    
    --agregar las columnas de la parte de value
    for col in  ( SELECT column_name FROM user_tab_columns WHERE table_name = UPPER(ps_tabla_name)) LOOP
        vs_values:= vs_values ||':old.' ||col.column_name ||',' ;
    END LOOP;
    
    vs_values := vs_values || replace(replace(vs_values,'values (',''),':old.',':new.');
    
    vs_values := vs_values||'SYS_CONTEXT('||CHR(39)||'USERENV'||CHR(39)||', '||CHR(39)||'SESSION_USER'||CHR(39)||'),SYSTIMESTAMP)';

    --DBMS_OUTPUT.PUT_LINE(vs_query);
    --DBMS_OUTPUT.PUT_LINE(vs_values);
    
    vs_query:= vs_query || CHR(10) || vs_values ||';'|| CHR(10) || 'END;' ;
    
    vs_query:= replace(vs_query,',);',')');
    
    DBMS_OUTPUT.PUT_LINE(vs_query);
    
    
    --EJECUCION DEL QUERY DINAMICO
    EXECUTE IMMEDIATE vs_query;

EXCEPTION
    WHEN OTHERS THEN
        RAISE ie_error_create_trigger;
END sp_create_audit_trigger;


END PCK_BITACORAS;
/
