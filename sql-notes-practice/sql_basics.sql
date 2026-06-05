-- Pratica para crear una base de datos
-- Se va a practicar para crear una base de datos propias,para saber con que tipo de datos se crea la base de datos
--Ademas cerarla correctamente, conectar tablas e insertar usuarios


-- -------------------------------------------------------------INTRO---------------------------------------------------------------------

-- ANTES DE AVANZAR A USAR EL LENGUAJE PRIMERO HAY QUE DEFINIR QUE ES SQL: 

-- Structure Query lenguaje, es un lenguaje utilizado para crear,gestionar, manipular y recuperar(mostrar o llevar a otro lado) información 
-- almacenada en bases de datos relacionales,
-- ¿Que es una base de datos relacional?
-- Este concepto es muy simple una base de datos relacional es una base de datos , en donde las tablas tienen una relación entre si.
-- que signfica que tenga una relación, es muy sencillo que un tipo de dato almacenado en una tabla haga referencia a un dato de otro tabla
-- un dato unico, con lo que al hacer referencia a ese dato que esta haciendo referencia a todas las propiedades(columnas) que el mismo posee.
-- este concepto se aclare mejor en la practica, pero en palabras simple hace referencia a un dato en otra tabla , nos vamos a ese tabla vemos 
-- que nos dice ese registro.

-- Ahora entonces ya tenemos en cuenta que es SQL y para que se utiliza. 
-- Veamos sus propiedades basicas.

-- Servidor de base de datos:Es donde se almancen naturalmente los datos, pero ademas es el motor de base de datos, el programa 
-- realiza basicamente todo, proceso, memoria, almacenamiento,etc....
-- Base de datos: Donde se almacenan los datos, tablas, schemas, etc.. , todo se almacena aqui.
-- Schema: Un contenedor logico dentro de una base de datos, nos muestra visualmente la estructura en la base de datos, igualmente guarda sus relaciones
-- Tabla:Aqui es donde por fin se almacen los datos en si ,en columnas y filas. 
-- Registros:Son las filas y representan el dato unico, las columnas son las carecteristicas del mismo




-- **********************************************************************************************************************************************************
-- ----------------------------------------------------------PART I:CREACIÓN---------------------------------------------------------------------------------
-- **********************************************************************************************************************************************************




--Step 1:Crear base de datos:
--Que tipos de datos puede haber en los registros de una base de datos?
--Como en cualquier lenguaje de programación puede haber enteros,flotantes,caracteres, booleanos
--pero ademas de estos también existen datos como: fecha, fecha y hora, caracteres sin limite
--cada uno de estos tienen ciertas palabraas reservadas. 
--Ademas de esto existe un dato en especial que como tal muestra el numero del resgistro
--es como un dato.

--Ademas de esto existen comandos como REFERENCE y CHECK, estos se ponen al crear el datos y hacen cosas especificas.
-- Por ejemplo REFERENCE hace que el dato que vamos a introducir pertenezca realmente a una tabla definida, lo mismo que con check
--Pero check lo hace a un nivel local , donde le pasamos que cheque que el dato que va a introducir pertence a algo 
--o cumple cierta regla, por ejemplo que es mayor que un numero, menor que un numero,etc...




-- INTEGER
-- NUMERIC/DECIMAL
--VARCHAR(n) where n in Natural numbers
-- TEXT
-- DATE
-- TIMESTAMP
--BOOLEAN
-- SERIAL PRIMARY KEY

-- Recordar que casi todos los comandos de SQL se escriben seperados despues se da un nombre por lo general y los paramentros se 
-- ponen dentro de los parametros separados de comas.



--CREACIÓN DE LA TABLA:

--Se crea el esquema, es la parte visual y como se relacionan las cosas entre si
CREATE SCHEMA PRUEBA_STUDIO;

--Esto es para que mande todas las tablas creadas al esquema correspondiente, si no las manda por defecto a public
SET search_path TO PRUEBA_STUDIO;



-- NOTA:COMO BORRAR, NOSOTROS PODEMOS BORRAR LO QUE SEA CON DROP Y PARA BORRAR TODAS LAS RELACIONES PONEMOS EL COMANDO CASCADE.
-- drop table if exist sistema_electrico,zona, zona2 cascade;
-- drop schema PRUEBA_STUDIO CASCADE;




create table sistema_electrico(
id_circuit SERIAL primary key,
empleado VARCHAR(10) unique,
amperes numeric,
numero_casa integer,
estado boolean
);


-- Como relacionar tablas, en una tabla como dijimos anteriormente tambien podemos tener como tipo de dato un dato que hace referencia a uno que esta en otra tabla
-- es decir el dato insertado en el registro es por asi decirlo asi del tipo tabla ya existente. estoy haciendo referencia a un dato de otra tabla.
-- Si el dato que se intenta insertar no existe en la otra tabla dara un error, como tal estamos haciendo referencia a un dato de otra tabla.



-- CREACIÓN DE TABLA RELACIONAL:

create table zona(
nombre varchar(40),
region varchar(40),
id_circuit integer references sistema_electrico(id_circuit),
estado varchar(40) check(estado in ('Oaxaca','Mexico-City'))
);


--lo anterior representa el caso mas basico en el que hacemos referencia al id del registro 1,2,3,4,....
--pero podemos hacer referencia a otro tipo como en la siguiente tabla que hacemos referencia a un VARCHAR
--en  este caso al empleado,pero SOLO SE PUEDE HACER REFERENCIA A UN DATO QUE SEA UNICO, O SEA SU REGISTRO TIENE QUE SER UNICO
--por ejemplo primary key o poner UNIQUE, por que tenemos que hacer referencia a un solo registro en otra tabla

create table zona2(
calle varchar(40),
responsable varchar(10) references sistema_electrico(empleado),
estado varchar(40) check(estado in ('Oaxaca','Mexico-City'))
);


-- Ahora bien ya sabemos lo basico de como crear una tabla y como relacionarlas entre si. 
--Vamos a recordar lo mas importante, comandos principales
-- CREATE: setencia para crear cualquier cosa en SQL
-- table: Para decir el tipo de 'dato' que vamos a crear en este caso es una tabla
-- TIPOS DE DATOS:importarte recordarlos en espacial SERIAL primary key que es el que lleva el conteo de los registros.
-- los dificiles de recordar igualmente son DATE Y TIMESTAMP

--COMANDOS O FUNCIONES IMPORTANTES: REFERENCE O CHECK, sumamente importantes, al igual UNIQUE.



-- **********************************************************************************************************************************************************
-- -------------------------------------------------------------PART II:CONSULTA Y GESTIÓN-------------------------------------------------------------------
-- **********************************************************************************************************************************************************



-- Una vez creada ya la base de datos veamos como podemos consultar la información de la misma 
-- en este caso para consultar algo primero tenemos que poner el comando SELECT, este comando puede selecionar lo que nostros queramos


-- Podemos selecionar dependiendo del tipo de dato claro esta lo que queramos seperado por comas o podemos selecionar todo con *.
select numero_casa 
from sistema_electrico;


-- Podemos ponerle un apodo al nombre de las columnas.
select 
estado as c
from zona2;

--¿Por que es importante SELECT? Aparentemente no tienen una utilidad mas que selecionar la tabla y mostrarla.
-- es aqui donde esta la utilidad ya que sin SELECT no podriamos ver las tablas que almacenamos, ademas de que nos ayuda a ver la 
-- información que queremos filtrandola, por ejemplo. 




-----------------------WHERE-------------

-- WHERE nos ayuda a filtrar la información podemos decirle mas especificamente que queremos.

-- En este caso queremos ver toda la información del sistema electrico, todas las columnas pero unicamente queremos los datos 
-- donde los amperes sean mayores a 10 , por que estos son los de nuestros interes, ya que ahi puede haber fallas, etc.. 
select all 
from sistema_electrico 
where amperes >10;


-- ADEMAS DE WHERE como en cualquier lenguaje de progrmación tenemos los ordenadores logicos como lo es, OR y AND
-- otra función importante es BETWEEN,IN y NOT IN. 

-- OJO: Estas funciones no funcionan por si solas necesitan  WHERE o alguna otra FUNCION para funcionar


-- En este caso hipotetico queremos ademas de los sistema que estan fallando, los sistemas que estan activos. 
select *
from sistema_electrico
where amperes >10 
and estado = true;


-- Con BETWEEN necesitamos ocupar AND para indicar entre que valores queremos buscar nuestro dato. 
-- desde fechas, cantidades, etc... 



--Por ejemplo en este caso tenemos que buscara valores entre 10 y 20, por que se quieren buscar en una determinada calle 
-- y nosotros sabemos que en cada calle hay maximo 10 casas y estan enumeradas siguiendo el orden de los numeros naturales.
select *
from sistema_electrico 
where numero_casa between 10 and 20;



-- IN anteriormente ya vimos in y sirve para indicar que los elementos a selecionar debemos ser como alguno dentro de
-- los corchetes

select * 
from zona
where region in ('CDMX','OAXACA');



-- ------------------ORDER BY-------------------

-- Esta función que se puede usar al igual que where sin la necesidad mas que de la función select from , nos 
-- ayuda a ordenar los datos antes de mostrarlos ya sea de mayor a menor o de menor a mayor.

-- Se utiliza DESC: de mayor a menor
-- ASC:de menor a mayor
-- estos deben ir al final cuando se especifico por que columna queremos ordenear los datos.

-- En el siguiente ejemplo es para mostrar las casas en orden numerico de mayor a menor

select all 
from sistema_electrico
order by numero_casa DESC;






-- -------------------------------------------------------------PART III: MANIPULACIÓN--------------------------------------------------------------






-- -------------------------------------------------------------PART IV: RECUPERACIÓN-----------------------------------------------------












