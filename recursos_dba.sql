**********Complementando un poco.**********
**MUESTRA LOS ROLES ASIGNADOS AL USUARIO ACTUAL
SELECT granted_role "Rol", admin_option "Admin" FROM user_role_privs;
 
**MUESTRA LOS PRIVILEGIOS A NIVEL SISTEMA DEL USUARIO ACTUAL 
SELECT privilege "Privilegio", admin_option "Admin" FROM user_sys_privs;
 
**VERIFICAR LOS ROLES DE CUALQUIER USUARIO DE LA DB, CONECTADO COMO SYS O DBA
SELECT * FROM DBA_ROLE_PRIVS

**Cómo saber en que tabla se encuentra una columna determinada en Oracle
select table_name from all_tab_columns where column_name='nombre_columna_buscada';

**Personaliza la consulta SQL.filtras por el tipo de dato o por el nombre del propietario de la base de datos.
select table_name from all_tab_columns where column_name='nombre_columna_buscada' and data_type='NVARCHAR2' and owner='propietario_buscado' order by table_name;


/*----------------------------------------------------------------------------------------------------------------*/

Te recomiendo aumentar el database buffer cache. El criterio que sigue para los aciertos es:
Cache Hit Ratio = 1 - (physical reads / (db block gets + consistent gets))
Para saber como esta configurada tu base de datos :
 select physical_reads, db_block_gets, consistent_gets name
from v$buffer_pool_statistics;
 
Si no funciona:
 La relación entre paradas para acceder al redo log y accesos en caché.
 
select name, value
from v$sysstat
where name='redo entries' OR
           name = 'redo log space requests';S
 
Con una relación superior a 1:5.000 es necesario ampliar el tamaño del buffer de redo.
Los aciertos de Library Cache:
 
select sum(pins-reloads) / sum(pins) from v$librarycache;
 
Con un valor menor a 95% se recomienda aumentar el tamaño de la Shared Pool.
Los aciertos en el diccionario de datos
 
select sum(gets), sum(getmisses), (sum(getmisses)/sum(gets))*100
from v$rowcache;
 
Con un porcentaje de fallos (getmisses) frente al de aciertos (gets) mayor de 10-15% es necesario aumentar la Shared Pool y estudiar las consultas lanzadas para asegurarse de que usan parámetros.
 
Espero que te sirva

/*-----------------------------------------------------------------------------------------------------------------*/
Muy útiles estos scripts.
Añado uno relativo a consulta de espacio disponible, ya habeís listado alguno, pero este me parece sencillo y de utilidad también: 
SELECT
   SYSDATE AS FECHA_ACT, DEDICADO.TABLESPACE "TABLESPACE",
   ROUND (DEDICADO.ESPACIO, 2) "ESPACIO DEDICADO (GB)",
   ROUND (LIBRE.ESPACIO, 2) "ESPACIO LIBRE (GB)",
   ROUND (DEDICADO.ESPACIO - LIBRE.ESPACIO, 2) "ESPACIO USADO (GB)",
   LPAD (ROUND ((LIBRE.ESPACIO / DEDICADO.ESPACIO) * 100, 2) || '%', 6, ' ') "% ESPACIO LIBRE"
FROM
   (SELECT
       DDF.TABLESPACE_NAME "TABLESPACE",
       SUM (DDF.BYTES) / 1024 / 1024 / 1024 "ESPACIO"
    FROM
       DBA_DATA_FILES DDF
    WHERE
       DDF.TABLESPACE_NAME IN ('tablespace1', ' tablespace2')
    GROUP BY
       DDF.TABLESPACE_NAME) DEDICADO,
   (SELECT
       DFS.TABLESPACE_NAME "TABLESPACE",
       SUM (DFS.BYTES) / 1024 / 1024 / 1024 "ESPACIO"
    FROM
       DBA_FREE_SPACE DFS
    WHERE
       DFS.TABLESPACE_NAME IN ('tablespace1', ' tablespace2')
    GROUP BY
       DFS.TABLESPACE_NAME) LIBRE
WHERE
   DEDICADO.TABLESPACE = LIBRE.TABLESPACE
ORDER BY
   LIBRE.ESPACIO / DEDICADO.ESPACIO ASC
   
/*---------------------------------------------------------------------------------------------------------------------*/

Mírate las consultas que obtienen información de la vista v$session, como por ejemplo:
-- Consulta Oracle SQL sobre la vista que muestra las conexiones actuales a Oracle
select osuser, username, machine, program
from v$session
order by osuser
 
-- Consulta Oracle SQL que muestra el número de conexiones actuales a Oracle agrupado por aplicación que realiza la conexión
select program Aplicacion, count(program) Numero_Sesiones
from v$session
group by program
 
Con estas consultas puedes localizar los identificadores que necesite para investigar despues más a fondo sobre la consulta: cursores abiertos, recursos que consume, etc.
También te puede ir muy bien consultar la información de la vista v$sqlarea, que te muestra información sobre las últimas consultas ejecutadas. Filtrando por usuario, fecha o contenido de la sentencia SQL, si es corta (si no se trunca y has de utilizar otra vista), puedes filtrar información sobre la/s consulta/s que te interesen.
-- Últimas consultas SQL ejecutadas en Oracle y usuario que las ejecutó:
select distinct        
  vs.sql_text, vs.sharable_mem, vs.persistent_mem, vs.runtime_mem, vs.sorts,       
  vs.executions, vs.parse_calls, vs.module, vs.buffer_gets, vs.disk_reads, vs.version_count,       
  vs.users_opening, vs.loads, to_char(to_date(vs.first_load_time,       
  'YYYY-MM-DD/HH24:MI:SS'),'MM/DD HH24:MI:SS') first_load_time,        
  rawtohex(vs.address) address, vs.hash_value hash_value ,        
  rows_processed , vs.command_type, vs.parsing_user_id ,        
  OPTIMIZER_MODE , au.USERNAME parseuser 
from v$sqlarea vs , all_users au 
where (parsing_user_id != 0) AND (au.user_id(+)=vs.parsing_user_id)

/*---------------------------------------------------------------------------------------------------------------------*/

**Roles que tiene asignado cada usuario
select username, granted_role from user_role_privs


/*----------------------------------------------------------------------------------------------------------------------*/
No acabo de ver bien el orden. ¿Primero alterar el campo y luego vaciarlo? Si el campo tiene datos creo que te dará error. Te copio un ejemplo del foro de la OTN de un método para cambiar el tipo de datos de un campo apoyándote en otro campo auxiliar:
SQL> create table "USER" (UserId varchar2(5))
Table created.
SQL> insert into "USER" values ('12345')
1 row created.
SQL> alter table "USER" add (UserId_tmp number(5))
Table altered.
SQL> update "USER" set userid_tmp=userid
1 row updated.
SQL> alter table "USER" set unused column userid
Table altered.
SQL> alter table "USER" rename column userid_tmp to userid
Table altered.
SQL> alter table "USER" drop unused columns
Table altered.
SQL> desc "USER"
TABLE USER
Name Null? Type 
----------------------------------------- -------- ----------------------------
USERID NUMBER(5)
 
Otra opción que te podría funcionar más rápido, si tienes espacio y no hay muchas restricciones sobre la tabla, es utilizar como apoyo una tabla entera en lugar de un campo en la misma tabla. Tendrías que hacer una copia de la tabla original, y después truncar la original, modificar el tipo de datos del campo con un alter, y finalmente hacer un insert desde la copia con un TO_CHAR para el campo que quieres cambiar de tipo.
 
De todas maneras, yo haría igualmente el backup de la tabla que vas a modificar.
/*-----------------------------------------------------------------------------------------------------------------------*/

Como saber con una conslta si algun proceso: paquete, procedimiento o funcion esta siendo utilizada por algun usuario
 
 
Saludos....
Top
responder
5 August, 2016 - 12:49 #78
Imagen de carlos
carlos
Offline
Joined: 28/12/2005
Puntos: 1553
Hola Franco
 
Podrías probar este script que he encontrado en AskTom. Te muestra lo que cada usuario está ejecutando, y podrías adaptarlo buscando en sql_text partes del SQL de los packages o funciones que te interese controlar.
 
---------------- showsql.sql -------------------------- 
column status format a10 
set feedback off 
set serveroutput on 

select username, sid, serial#, process, status 
from v$session 
where username is not null 
/ 

column username format a20 
column sql_text format a55 word_wrapped 

set serveroutput on size 1000000 
declare 
x number; 
begin 
for x in 
( select username||'('||sid||','||serial#|| 
') ospid = ' || process || 
' program = ' || program username, 
to_char(LOGON_TIME,' Day HH24:MI') logon_time, 
to_char(sysdate,' Day HH24:MI') current_time, 
sql_address, LAST_CALL_ET 
from v$session 
where status = 'ACTIVE' 
and rawtohex(sql_address) <> '00' 
and username is not null order by last_call_et ) 
loop 
for y in ( select max(decode(piece,0,sql_text,null)) || 
max(decode(piece,1,sql_text,null)) || 
max(decode(piece,2,sql_text,null)) || 
max(decode(piece,3,sql_text,null)) 
sql_text 
from v$sqltext_with_newlines 
where address = x.sql_address 
and piece < 4) 
loop 
if ( y.sql_text not like '%listener.get_cmd%' and 
y.sql_text not like '%RAWTOHEX(SQL_ADDRESS)%') 
then 
dbms_output.put_line( '--------------------' ); 
dbms_output.put_line( x.username ); 
dbms_output.put_line( x.logon_time || ' ' || 
x.current_time|| 
' last et = ' || 
x.LAST_CALL_ET); 
dbms_output.put_line( 
substr( y.sql_text, 1, 250 ) ); 
end if; 
end loop; 
end loop; 
end; 
/ 

column username format a15 word_wrapped 
column module format a15 word_wrapped 
column action format a15 word_wrapped 
column client_info format a30 word_wrapped 

select username||'('||sid||','||serial#||')' username, 
module, 
action, 
client_info 
from v$session 
where module||action||client_info is not null; 
Saludos,
Top
responder
21 November, 2016 - 23:16 #79
julio azocar (no verificado)
select * from sys.dba_users order by username como sacar los datos mas ordenados en tablas sale esto
USERNAME USER_ID PASSWORD ------------------------------ ---------- ------------------------------ ACCOUNT_STATUS LOCK_DATE EXPIRY_DA -------------------------------- --------- --------- DEFAULT_TABLESPACE TEMPORARY_TABLESPACE CREATED ------------------------------ ------------------------------ --------- PROFILE INITIAL_RSRC_CONSUMER_GROUP ------------------------------ ------------------------------ EXTERNAL_NAME -------------------------------------------------------------------------------- PASSWORD E -------- -
/*-----------------------------------------------------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------------------------------------------------*/

**Obtener la Lista de Objetos de un Package en Oracle  
SELECT OBJECT_NAME,OBJECT_TYPE FROM dba_objects where owner='webmaster' and object_type='PACKAGE'"


   
   



