+-------------------------------------------------------------------------+
| CONSULTAS UTILES DE ORACLE										   	  |
+-------------------------------------------------------------------------+
--http://www.dataprix.com/recopilacion_scripts_consultas_utiles_oracle_sql

•• Consulta Oracle SQL sobre la vista que muestra el estado de la base de datos:
select * from v$instance

•• Consulta Oracle SQL que muestra si la base de datos está abierta
select status from v$instance

•• Consulta Oracle SQL sobre la vista que muestra los parámetros generales de Oracle
select * from v$system_parameter

•• Consulta Oracle SQL para conocer la Versión de Oracle
select value from v$system_parameter where name = 'compatible'

•• Consulta Oracle SQL para conocer la Ubicación y nombre del fichero spfile
select value from v$system_parameter where name = 'spfile'

•• Consulta Oracle SQL para conocer la Ubicación y número de ficheros de control
select value from v$system_parameter where name = 'control_files'

•• Consulta Oracle SQL para conocer el Nombre de la base de datos
select value from v$system_parameter where name = 'db_name'

•• Consulta Oracle SQL sobre la vista que muestra las conexiones actuales a Oracle Para visualizarla es necesario entrar con privilegios de administrador
select osuser, username, machine, program
from v$session
order by osuser

•• Consulta Oracle SQL que muestra el número de conexiones actuales a Oracle agrupado por aplicación que realiza la conexión
select program Aplicacion, count(program) Numero_Sesiones
from v$session
group by program
order by Numero_Sesiones desc

•• Consulta Oracle SQL que muestra los usuarios de Oracle conectados y el número de sesiones por usuario
select username Usuario_Oracle, count(username) Numero_Sesiones
from v$session
group by username
order by Numero_Sesiones desc
++Propietarios de objetos y número de objetos por propietario
select owner, count(owner) Numero
from dba_objects
group by owner
order by Numero desc

•• Consulta Oracle SQL sobre el Diccionario de datos (incluye todas las vistas y tablas de la Base de Datos)
select * from dictionary

•• Consulta Oracle SQL que muestra los datos de una tabla especificada (en este caso todas las tablas que lleven la cadena "XXX"
select * from ALL_ALL_TABLES where upper(table_name) like '%XXX%'

•• Consulta Oracle SQL para conocer las tablas propiedad del usuario actual
select * from user_tables

•• Consulta Oracle SQL para conocer todos los objetos propiedad del usuario conectado a Oracle
select * from user_catalog

•• Consulta Oracle SQL para el DBA de Oracle que muestra los tablespaces, el espacio utilizado, el espacio libre y los ficheros de datos de los mismos:
Select t.tablespace_name "Tablespace", t.status "Estado",
ROUND(MAX(d.bytes)/1024/1024,2) "MB Tamaño",
ROUND((MAX(d.bytes)/1024/1024) -
(SUM(decode(f.bytes, NULL,0, f.bytes))/1024/1024),2) "MB Usados",
ROUND(SUM(decode(f.bytes, NULL,0, f.bytes))/1024/1024,2) "MB Libres",
t.pct_increase "% incremento",
SUBSTR(d.file_name,1,80) "Fichero de datos"
FROM DBA_FREE_SPACE f, DBA_DATA_FILES d, DBA_TABLESPACES t
WHERE t.tablespace_name = d.tablespace_name AND
f.tablespace_name(+) = d.tablespace_name
AND f.file_id(+) = d.file_id GROUP BY t.tablespace_name,
d.file_name, t.pct_increase, t.status ORDER BY 1,3 DESC

•• Consulta Oracle SQL para conocer los productos Oracle instalados y la versión:
select * from product_component_version

•• Consulta Oracle SQL para conocer los roles y privilegios por roles:
select * from role_sys_privs

•• Consulta Oracle SQL para conocer las reglas de integridad y columna a la que afectan:
select constraint_name, column_name from sys.all_cons_columns

•• Consulta Oracle SQL para conocer las tablas de las que es propietario un usuario, en este caso "xxx":
SELECT table_owner, table_name from sys.all_synonyms where table_owner like 'xxx'

•• Consulta Oracle SQL como la anterior, pero de otra forma más efectiva (tablas de las que es propietario un usuario):
SELECT DISTINCT TABLE_NAME
FROM ALL_ALL_TABLES
WHERE OWNER LIKE 'HR'
Parámetros de Oracle, valor actual y su descripción:
SELECT v.name, v.value value, decode(ISSYS_MODIFIABLE, 'DEFERRED',
'TRUE', 'FALSE') ISSYS_MODIFIABLE, decode(v.isDefault, 'TRUE', 'YES',
'FALSE', 'NO') "DEFAULT", DECODE(ISSES_MODIFIABLE, 'IMMEDIATE',
'YES','FALSE', 'NO', 'DEFERRED', 'NO', 'YES') SES_MODIFIABLE,
DECODE(ISSYS_MODIFIABLE, 'IMMEDIATE', 'YES', 'FALSE', 'NO',
'DEFERRED', 'YES','YES') SYS_MODIFIABLE , v.description
FROM V$PARAMETER v
WHERE name not like 'nls%' ORDER BY 1

•• Consulta Oracle SQL que muestra los usuarios de Oracle y datos suyos (fecha de creación, estado, id, nombre, tablespace temporal,...):
Select * FROM dba_users

•• Consulta Oracle SQL para conocer tablespaces y propietarios de los mismos:
select owner, decode(partition_name, null, segment_name,
segment_name || ':' || partition_name) name,
segment_type, tablespace_name,bytes,initial_extent,
next_extent, PCT_INCREASE, extents, max_extents
from dba_segments
Where 1=1 And extents > 1 order by 9 desc, 3
Últimas consultas SQL ejecutadas en Oracle y usuario que las ejecutó:
select distinct vs.sql_text, vs.sharable_mem,
vs.persistent_mem, vs.runtime_mem, vs.sorts,
vs.executions, vs.parse_calls, vs.module,
vs.buffer_gets, vs.disk_reads, vs.version_count,
vs.users_opening, vs.loads,
to_char(to_date(vs.first_load_time,
'YYYY-MM-DD/HH24:MI:SS'),'MM/DD HH24:MI:SS') first_load_time,
rawtohex(vs.address) address, vs.hash_value hash_value ,
rows_processed , vs.command_type, vs.parsing_user_id ,
OPTIMIZER_MODE , au.USERNAME parseuser
from v$sqlarea vs , all_users au
where (parsing_user_id != 0) AND
(au.user_id(+)=vs.parsing_user_id)
and (executions >= 1) order by buffer_gets/executions desc

•• Consulta Oracle SQL para conocer todos los tablespaces:
select * from V$TABLESPACE

•• Consulta Oracle SQL para conocer la memoria Share_Pool libre y usada
select name,to_number(value) bytes
from v$parameter where name ='shared_pool_size'
union all
select name,bytes
from v$sgastat where pool = 'shared pool' and name = 'free memory'
Cursores abiertos por usuario
select b.sid, a.username, b.value Cursores_Abiertos
from v$session a,
v$sesstat b,
v$statname c
where c.name in ('opened cursors current')
and b.statistic# = c.statistic#
and a.sid = b.sid
and a.username is not null
and b.value >0
order by 3

•• Consulta Oracle SQL para conocer los aciertos de la caché (no debería superar el 1 por ciento)
select sum(pins) Ejecuciones, sum(reloads) Fallos_cache,
trunc(sum(reloads)/sum(pins)*100,2) Porcentaje_aciertos
from v$librarycache
where namespace in ('TABLE/PROCEDURE','SQL AREA','BODY','TRIGGER');
Sentencias SQL completas ejecutadas con un texto determinado en el SQL
SELECT c.sid, d.piece, c.serial#, c.username, d.sql_text
FROM v$session c, v$sqltext d
WHERE c.sql_hash_value = d.hash_value
and upper(d.sql_text) like '%WHERE CAMPO LIKE%'
ORDER BY c.sid, d.piece
Una sentencia SQL concreta (filtrado por sid)
SELECT c.sid, d.piece, c.serial#, c.username, d.sql_text
FROM v$session c, v$sqltext d
WHERE c.sql_hash_value = d.hash_value
and sid = 105
ORDER BY c.sid, d.piece

•• Consulta Oracle SQL para conocer el tamaño ocupado por la base de datos
select sum(BYTES)/1024/1024 MB from DBA_EXTENTS

•• Consulta Oracle SQL para conocer el tamaño de los ficheros de datos de la base de datos
select sum(bytes)/1024/1024 MB from dba_data_files

•• Consulta Oracle SQL para conocer el tamaño ocupado por una tabla concreta sin incluir los índices de la misma
select sum(bytes)/1024/1024 MB from user_segments
where segment_type='TABLE' and segment_name='NOMBRETABLA'

•• Consulta Oracle SQL para conocer el tamaño ocupado por una tabla concreta incluyendo los índices de la misma
select sum(bytes)/1024/1024 Table_Allocation_MB from user_segments
where segment_type in ('TABLE','INDEX') and
(segment_name='NOMBRETABLA' or segment_name in
(select index_name from user_indexes where table_name='NOMBRETABLA'))

•• Consulta Oracle SQL para conocer el tamaño ocupado por una columna de una tabla
select sum(vsize('NOMBRECOLUMNA'))/1024/1024 MB from NOMBRETABLA

•• Consulta Oracle SQL para conocer el espacio ocupado por usuario
SELECT owner, SUM(BYTES)/1024/1024 MB FROM DBA_EXTENTS
group by owner

•• Consulta Oracle SQL para conocer el espacio ocupado por los diferentes segmentos (tablas, índices, undo, rollback, cluster, ...)
SELECT SEGMENT_TYPE, SUM(BYTES)/1024/1024 MB FROM DBA_EXTENTS
group by SEGMENT_TYPE

•• Consulta Oracle SQL para obtener todas las funciones de Oracle: NVL, ABS, LTRIM, ...
SELECT distinct object_name
FROM all_arguments
WHERE package_name = 'STANDARD'
order by object_name

•• Consulta Oracle SQL para conocer el espacio ocupado por todos los objetos de la base de datos, muestra los objetos que más ocupan primero
SELECT SEGMENT_NAME, SUM(BYTES)/1024/1024 MB FROM DBA_EXTENTS
group by SEGMENT_NAME
order by 2 desc

•• Para comparar dentro de un DECODE con parte de un texto del contenido de un campo, es decir, para poder utilizar un like u otras funciones en lugar de la igualdad que toma por defecto el DECODE se puede hacer lo siguiente:

Select
decode(CAMPO, (select CAMPO from dual where CAMPO like 'A%'), 'Campo comienza por A',
(select name from dual where name like 'B%'), 'Campo comienza por B',
'Campo no comienza ni por A ni por B')
From TABLA;

•• Cuando un tablespace se queda sin espacio se puede ampliar creando un nuevo fichero de datos, o ampliando uno de los existentes.

Para consultar el espacio ocupado por cada datafile se puede utilizar la consulta de la lista anterior:

Consulta Oracle SQL para el DBA de Oracle que muestra los tablespaces, el espacio utilizado, el espacio libre y los ficheros de datos de los mismos:
Select t.tablespace_name "Tablespace", t.status "Estado",
ROUND(MAX(d.bytes)/1024/1024,2) "MB Tamaño",
ROUND((MAX(d.bytes)/1024/1024) -
(SUM(decode(f.bytes, NULL,0, f.bytes))/1024/1024),2) "MB Usados",
ROUND(SUM(decode(f.bytes, NULL,0, f.bytes))/1024/1024,2) "MB Libres",
t.pct_increase "% incremento",
SUBSTR(d.file_name,1,80) "Fichero de datos"
FROM DBA_FREE_SPACE f, DBA_DATA_FILES d, DBA_TABLESPACES t
WHERE t.tablespace_name = d.tablespace_name AND
f.tablespace_name(+) = d.tablespace_name
AND f.file_id(+) = d.file_id GROUP BY t.tablespace_name,
d.file_name, t.pct_increase, t.status ORDER BY 1,3 DESC

Una vez que localizamos el datafile que podríamos ampliar ejecutaremos la siguiente sentencia para hacerlo:

ALTER DATABASE
DATAFILE '/db/oradata/datafiles/datafile_n.dbf' AUTOEXTEND
ON NEXT 1M MAXSIZE 4000M

Con esta sentencia, el datafile continuaría ampliándose hasta llegar a un máximo de 4Gb.

Si preferimos crear un nuevo datafile porque los que tenemos ya son demasido grandes, una sentencia que podríamos utilizar es la siguiente:

ALTER TABLESPACE "MiTablespace"
ADD
DATAFILE '/db/oradata/datafiles/datafile_m.dbf' SIZE
100M AUTOEXTEND
ON NEXT 1M MAXSIZE 1000M

Crearíamos un nuevo fichero de datos de 100 Mb, y en modo autoextensible hasta 1000 Mb. Por supuesto, el path especificado debe ser el específico de cada base de datos, y se debe utilizar para todo el proceso un usuario con privilegios de DBA.