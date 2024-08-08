/*
RECORD(registros)
ejemplo de uso de record
cambio desde github
*/
declare 

le_sin_espacio exception;
pragma exception_init(le_sin_espacio, -60000);
--record del tipo de una tabla existente
lr_user users%ROWTYPE;

--record creado por el usuario
type t_usuario is record    (
                            id users.id_user%TYPE
                            ) ;


lt_usuario t_usuario;


begin
    
    BEGIN
    
        SELECT  * 
        into    lr_user
        FROM    users
        where   id_user = 21 ;

    EXCEPTION
        WHEN OTHERS THEN
            RAISE le_sin_espacio;
    END;
    
    dbms_output.put_line(lr_user.user_name);
    
    begin
        select  id_user
        into    lt_usuario
        from    users
        where   user_name = lr_user.user_name;
        
        dbms_output.put_line(lt_usuario.id);
        
    end;
    
exception
when others then
    dbms_output.put_line(SQLERRM||' '||dbms_utility.format_error_backtrace);
end;
