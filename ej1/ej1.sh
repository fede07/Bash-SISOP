#!/bin/bash

# =========================== Encabezado =======================

# Nombre del Script: ej1.sh
# Número de APL: 1
# Número de Ejercicio: 1
# Número de Entrega: Primera reentrega

# ==============================================================

# ------------------------ Integrantes ------------------------
#
#        Nombre      |        Apellido          |      DNI
#        Gianluca    |        Espíndola         |   38.585.140
#        Juan        |        Diaz              |   38.958.153
#        Micaela     |        Dato Firpo        |   39.830.964
#        Melina      |        Sanson            |   42.362.352
#        Federico    |        Rossendy          |   37.804.899
#
# -------------------------------------------------------------

ErrorS()
{
    echo "Error. La sintaxis del script es la siguiente:"
    echo "Para ver la cantidad de saltos de linea: $0 nombre_archivo L"
    echo "Para ver la de caracteres: $0 nombre_archivo C" 
    echo "Para ver la máxima cantidad de caracteres en una línea: $0 nombre_archivo M"
}
ErrorP()
{
    echo "Error. nombre_archivo no encontrado o no posee permiso de lectura."
}
if test $# -ne 2; then #si no se recibieron 2 parametros es un error
    ErrorS
else
    if !( test -r $1 ); then #si no posee permisos de lectura es un error
        ErrorP
    elif test -f $1 && (test $2 = "L" || test $2 = "C" || test $2 = "M"); then #verifica que ambos parametros recibidos sea correcto
        if test $2 = "L"; then #si el segundo parametro es L
            res=`wc -l < $1`
            echo "Cantidad de saltos de línea: $res" 
        elif test $2 = "C"; then #si el segundo parametro es C
            res=`wc -m < $1`
            echo "Cantidad de caracteres: $res"
        else #si no es L ni C, por descarte es M
            res=`wc -L < $1`
            echo "Máxima cantidad de caracteres en una línea: $res"
        fi
    else
        ErrorS
    fi
fi

# Respuestas:
# 1. El objetivo del script es mostrar distintos detalles de un archivo de texto, como lo son la cantidad
#		de saltos de línea, la cantidad de caracteres y la máxima cantidad de caracteres en una línea.
# 2. Los parámetros que recibe son: El nombre del archivo a analizar, seguido por un caracter de opción para indicar
#		la operación a realizar.
# 5. La variable $# muestra la cantidad de parámetros que se enviaron al script.
#	También hay otras variables como:
#	$?: Muestra el valor de retorno del último comando ejecutado.
#	$0: Muestra el nombre del archivo siendo ejecutado.
#	$$: Muestra el process ID del shell que está ejecutando el script.
#	$!: Muestra el process ID del último proceso hijo ejecutado en segundo plano.
#	$*: Muestra todos los parámetros que se enviaron separando palabra a palabra, si se usa entre comillas "$*" muestra todos los parámetros en un string.
#	$@: Muestra todos los parámetros que se enviaron separando palabra a palabra, si se utsa entre comillas "$@" muestra todos los parámetros separados en una lista.
#	$n: Siendo n>=1 y n<=9. Hace referencia al parámetro n enviado. Para parámetros mayores a 9 se escribiría como: ${n}.
#	$_: Muestra el último parámetro enviado a la última línea de comando ejecutada.
#	$-: Muestra la lista de opciones del proceso Shell actual.
# 6. Tipos de comillas:
#	"": Comillas dobles. Son comillas de texto débil, el intérprete de Shell hace reemplazos nombres de variables por su contenido.
#	'': Comillas simples. Son comillas de texto fuerte, el intérprete de Shell no realizar reemplazos y todo el texto en su interior se mantiene igual.
#	``: Comillas francesas. Son comillas de ejecución de comandos, el intérprete de Shell realiza reemplazos de variables y luego ejecuta los comandos que se encuentran dentro.

#---------------------------------------------------------------------#
#                         FIN DEL EJERCICIO 1                         #
#---------------------------------------------------------------------#
