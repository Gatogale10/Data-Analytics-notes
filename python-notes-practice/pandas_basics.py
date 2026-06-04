#Es importante importante la libreria de pandas como pd es un standar
import pandas as pd

#Despues se le tiene que asiganar un nombre a esta base de datos que ha sido importada
#en este caso se le pone db pero podria ser cualquiera.
db = pd.read_csv("datasets/tiktok_instagram_global_100countries.csv")

#==============================COMANDOS PRINCIPALES=============================

# Estos comandos son los que nos ayudan a hacer todo son como nuestros instrumentos de cocina
# o nuestras herramientas como en cualquier teorema tenemos nuestras definiciones,lemas, etc..
# tenemos nuestras propias cosas solo falta poneralas en el orden correcto. 
# Bueno ademas de estas funciones tambien en nuestra caja de herramientas estan incluidos los
# principos de programación, for, while, if todo lo que incluye un lenguaje de programacion ademas de 
# otras librerias y todo lo que se pueda hacer con python, el fin resolver el problema, colocando las cosas 
# en el orden correcto. 


# Se podra todo lo que existe imaginablemente y logicamente para resolver un problema como lo planteamos 
# logicamente en nuestra mente.Por ejemplo el copiar un dato, sacar promedios,minimos,maximos, tendencias
# quitar datos, columnas, pegar bases, etc.....



#---------Extraer una base de datos de un tipo de archivo------


# Los archivos mas comunes son los .xlsx y los .cvs que es un formato que maneja excell
# son los mas usados dentro del analisis de datos

# Este es el caso para los archivos cvs., en el caso que cada columna este separa por ; en lugar de ,
db2 = pd.read_csv("datasets/tiktok_instagram_global_100countries.csv",sep = ";")

# Caso .xlsx
#db3 = pd.read_excel("datasets/tiktok_instagram_global_100countries.xlsx")



#----------Visualización de los datos de forma rapida------------------------


#Primero que nada estos para visualizar los datos en la terminal o en alguno IDE de forma rapida

#De forma rapdida hay que tener que lo siguientes son metodos y propiedades pertenencientes 
# si tienen corchetes de nuestro objeto llamado db en automatico es un metodo y puedo o no 
# retornar algo si no retorna nada lo que hara sera imprimir en automatico lo que le estamos 
# pidiendo, si retorna y no imprime tenemos que poner un print para visualizarlo en pantalla



# Esto nos imprime el tamaño de las columnas y filas
print(db.shape)

#Imprime las primeras 5 filas
print(db.head())


#Imprime las primeras n.
n = 10
print(db.head(n))

#Imprime las ultimas 5 
print(db.tail())



#Tipo de dato de cada columna
print(db.dtypes)


#Nombre de cada columna es para observar que estamos viendo
print(db.columns)

#Podremos ver información general como tipos de datos y cuales son nulos
print("Info")
db.info()

#Podremos ver un analisis estadistico rapido y sencillo, como media,std,min, max, percentiles
print("Descripcion")
print(db.describe())



#----!!!!IMPORTANTE!!!!

# Para selecionar una columna en especifico usamos este comando
columnaedad = db["age"]


#-------------COMANDOS TIPICOS PARA LIMPIAR BASES DE DATOS DENTRO DE PYTHON--------------

# La limpieza de datos es muy importante por ello requiremos herramientas para limpiar nuetros
# datos por ejemplo outliers, etc...


#Esto nos muestra cuantos nulos hay por cada columna hay que tener cuidado con las intersecciones
db.isnull().sum()


#Ver el porcentaje de los nulos 
percentage = db.isnull().sum() / len(db) * 100
print(percentage)


#Eliminar filas de los nulos
# Hay que tener cuidado con esta instrucción ya que elimina
# todas las filas nulas no solo de una columna 
db.dropna(inplace=True)

# Para eliminar en especifico la fila de una sola columna 
# tenemos que decir el subconjunto columna que queremos

db.dropna(subset=["age"],inplace=True)

# Este comando es muy util ya que muchas veces vamos a necesitar
# elimar filas con datos nulos para datos cualitativos, pero para cuantitativos
# cuando sea claramente el caso a saber,podemos poner la media en estos datos nulos
# para no perder la demas información entonces usamos el metodo 
# fillna: Que sustituye uno por otro.
# en esta funcion el primer parametro significa que valor va a sustituir
# en las filas nulas de la columna especificada.


#Pero primero selecionamos esa fila
db["age"].fillna(db["age"].mean(),inplace=True) 


#Tambien podemos hacerlo con la mediana , dependiendo del sesgo de la distribución 
# y de los datos con lo que estemos tratando
db["age"].fillna(db["age"].median(),inplace=True)


#En el caso de cuando tengamos muchos datos cualitativos vacios en una fila
#y por obvias razones no queramos eliminarlas por que se perderian los demas datos
#entonces podemos introducir un valor cualitativo como no defindo o el que queramos
db["age"].fillna('No definido',inplace=True)


#Ahora como vemos los duplicados
# nos da los datos en una columa de duplicados
#podemos sumarlos por que es una columna
# sum():funcion muy util que suma los datos de una columna 
# cuantos datos hay
db.duplicated().sum()

#Eliminar duplicados
#!!!!AQUI EN PYTHON DROP ES COMO ELIMINAR!!!!!!
db.drop_duplicates(inplace=True)


#----CAMBIAR EL TIPO DE DATO DE LAS COLUMNAS----
#Existen dos formas de cambiar el tipo de dato de las columnas
#CUALQUIERA DE LAS DOS FORMAS ES VALIDA.
#la primera es usar una funcion de pandas
 
#Primero selecionamos la columna que queremos modificar su valor 
# y despues la igualamos al valor que queremos 
db["age"] = pd.to_numeric(db["age"]) #Usamos una funcion de pandas


# La segunda forma es usar un metodo del objeto bd

#De igual forma selecionamos la columna a la que le queremos 
# cambiar el valor la igualamos y luego ponemos el metodo astype. 

db["age"] = db["age"].astype(int)


#============================= ANALISIS ESTADISTICO BASICO Y AGRUPACIÓN=======================

# Para hacer un analisis estadistico debemos selecionar un columna
# bueno esto es logico por ejemplo para para la media, mediana y modo si queremos la moda 
# de cierta caracteristica por ejemplo altura pues selecionamos esa columna
#y despues de esto ponemos el metodo que nos interesa


#-------- Ordenar--------------


#Ordenar de mayor a menor
db.sort_values("age",ascending=False)

#Ordenar de menor a mayor
db.sort_values("age",ascending=True)


#Tambien podemos ordenar por dos columnas esto se puede hacer en un solo comando 

db.sort_values(["age,addiction_score"],ascending=[True,False])

#Para selecionar o ver columas podemos hacer lo siguiente

db["age"]


#Tambien se pueden seleccionar varias
db[["age,scroll_velocity,ASI"]]

#------Analisis estadistico

print(db.columns)

db["scroll_velocity"].mean()

db["scroll_velocity"].median()

db['gasto'].mode() # Moda

#Este dato no es tan tipico que salga
db['gasto'].std() # Desviacion estandar

db['gasto'].var() # Varianza

db['gasto'].min() # Minimo

db['gasto'].max() # Maximo

#Esto cuenta cuantos datos no nulos hay en la columna
db['scroll_velocity'].count()

#Esto suma todos los datos de la columna siempre que sean reales
db['scroll_velocity'].sum()


#---------Veamos como filtrar por filas los datos--------

# Esto es para filtrar por columna, o sea queremos los datos de esa columna especificamente 
# de un tipo de dato

Filtroedad = db[db["age"]==20]


#Dentro de este comando o funcion ponemos las condiciones que queramos para 
# la filtrar los datos desados en la columna

#Por ejemplo podemos combinar con condicionales como or o and varias veces para filtrar
# la columna.

FiltroCondicionales = db[ (db["age"]==20) or (db["age"]==21)]



#Al igual podemos filtrar por una lista de valores, o sea damos los valores que salen 
# en la lista.
FiltroLista = db[db["age"].isin([21,22,23,24])]

#--------------Agrupar y calcular

#Este comando nos da el promedio de cada caracteristica de una determinada columna
# dada la caracteristica de otra columna

#Ejemplo el srcoll promedio por cada edad 
#esto es comando combianado, no necesariamente el metodo groupby tiene que ir 
#con las siguientes funciones, solo son algunas formas en que podemos aprovecharlo
#y combinarlo cuando nos sea conveniente.


#Lo que dice primero agrupa por edad, que edades tienes, despues de esto
#saca el promedio de scroll por cada edad que tengo
db.groupby("age")["scroll_velocity"].mean()

# y podemos usar los mismos comandos anteriormente vistos para esto 
# lo unico que cambia es que estamos agrupando los datos por cierta columna y ya.

# Suma de gasto por region
db.groupby('region')['gasto'].sum()
# Conteo de clientes por region
db.groupby('region')['cliente_id'].count()


#Tambien podemos hacerlo para que nos muestren distintas medidas de tendencia
# o carateristicas con el comando agg y damos que queremos.
db.groupby('age')['scroll_velocity'].agg(['mean', 'median', 'std', 'count'])


#En todos estos casos podemos ordenar de mayor a menor con la propiedad
# sort_value(ascending=True)

db.groupby("age")["scroll_velocity"].mean().sort_values(ascending=True)



#-------------Colocar nuevas columnas-----

#Podemos dedicir agregar columnas con valores booleanos

db["Nueva_columna"] = db["age"] >20

# Tambien columnas que sean el multiplo de otra etc....

db["Nueva_columna_2"] = db["age"] * 2

# Se puede combinar con todo lo que hicimos anteriormente que sea logico 
# solo es igualarla


#Esto si no se vio antes pero es para una columna con datos cualtativos mas alla de 
# True o False, esto obvio con alguna condición,
db["Nueva_columna"] = db['age'].apply(lambda x: 'Adulto' if x > 24 else 'Joven')




#----------------Visualización de los datos


#Una parte importante es saber mostrar los datos con graficas,vemos las mas 
# sencillas para mostrar nuestros datos y visualizar mejor tendencias.













#=============================VISUALIZACION DE LOS DATOS==============================














