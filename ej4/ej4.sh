#!/bin/bash

# =========================== Encabezado =======================

# Nombre del Script: ej4.sh
# Número de APL: 1
# Número de Ejercicio: 4
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

#para codigos que no compilan el resultado es impredecible


Usage() {
    echo "   Uso:"
    echo -e "    $0 --ruta [ruta] --ext [extensiones]\n" #-e sirve para reconocer el \n y demas caracteres de escape
    echo "    Busca archivos en la ruta indicada y devuelve la siguiente información:"
    echo "    1. Cantidad de archivos analizados."
    echo "    2. Cantidad de lineas de codigo y el porcentaje sobre el total."
    echo -e "    3. Cantidad de lineas de comentarios y el porcentaje sobre el total.\n"
    echo "   Opciones:"
    echo "    --ruta [ruta]        analiza y procesa los archivos con las extensiones indicadas."
    echo "    -h, --help           muestra esta información y termina la ejecución."
    echo "    --ext [extensiones]  extensiones que seran analizadas separadas por coma (,)."
    echo ""
    echo "  Notas:"
    echo "      Para codigos que no compilan el resultado es impredecible."
    echo -e "      Para lineas de codigo con indicadores de comentario [//, /*, */] es posible
      que se contabilice también como comentario a pesar no serlo."
    exit 0
}

numArgs=$#

#-a sirve para decirle que los parametros cortos tambien se pueden mandar con la inicial
ARGUMENTS=$(getopt -o h --long help,ruta:,ext: -- "$@" 2>/dev/null)
retorno=$?

if [ $retorno -ne 0 ] || [ $# -ne 4 ]; then
    echo "Error: Parámetros incorrectos." 1>&2
    Usage
fi

HELP=0
EXTPARAM=""
RUTA=""
eval set -- "$ARGUMENTS"
while true; do
    case "$1" in
    --help)
        HELP=1
        shift 2
        break
        ;;
    --h)
        HELP=1
        shift 2
        break
        ;;
    --ruta)
        RUTA="$2"
        shift 2
        ;;
    --ext)
        EXTPARAM="$2"
        shift 2
        ;;
    --)
        shift
        break
        ;;
    *)
        echo "Opción inesperada: $1 - esto no debería suceder."
        exit 1
        ;;
    esac
done

if [ $HELP -eq 1 ]; then
    Usage
fi

if [ "${RUTA}" == "" ]; then
    echo "Error: No se envió una ruta para analizar." 1>&2
    exit 2
fi

if [ ! -d "${RUTA}" ]; then
    echo "Error: La ruta especificada no existe." 1>&2
    exit 2
fi

if [ ! -x "${RUTA}" ]; then
    echo "Error: No tiene permisos de lectura en la ruta especificada." 1>&2
    exit 2
fi

if [ "$EXTPARAM" == "" ]; then
    echo "Error: No se enviaron extensiones para analizar." 1>&2
    exit 2
fi

IFS=","
EXT="-name "
for par in $EXTPARAM; do
    EXT+="'*.$par' -o -name "
done

EXT=${EXT::-10}

ARCHIVOS="find \"${RUTA}\" -type f '(' $EXT ')' "
ARCHIVOS=$(eval $ARCHIVOS)

IFS=$'\n'
LINEASTOTALES=0 #lineas escritas que no sean blancos
ARCHIVOSTOTALES=0
COMENTARIO=0 #lineas de comentario
CODIGO=0     #lineas de codigo
MULTILINEA=0 #bandera para los /* */, asi todo lo que haya despues de un /* cuenta como comoentario
EXTVALIDA="" #guarda las extensiones de los archivos que contenian lineas para procesar
for NOMBREARCHIVO in $ARCHIVOS; do
    CANTLINEASARCHIVO=$(grep -cve '^\s*$' $NOMBREARCHIVO)

    if [ ! -r "$NOMBREARCHIVO" ]; then
        echo "Error: No tiene permisos suficientes para procesar "$NOMBREARCHIVO", no se contabilizará." 1>&2
    else #tiene permiso para la ruta y archivo
        ((ARCHIVOSTOTALES++))
        while IFS= read -r LINEAARCHIVO; do #leo cada linea del archivo 
            sentence=$(echo "$LINEAARCHIVO" | sed -r '/^\s*$/d')
            if ! test -z "$sentence"; then       #si la linea tiene algo escrito
                ((LINEASTOTALES++))              #linea de codigo o comentario, pero no esta vacia
                filename=$(basename -- "$NOMBREARCHIVO") #parseo
                extension="${filename##*.}"

                if [[ $EXTVALIDA != *"$extension"* ]]; then
                    EXTVALIDA+="$extension "
                fi

                if [[ $MULTILINEA -eq 0 ]]; then #es codigo o inicio de comentario
                    sentence=$(echo "$LINEAARCHIVO" | sed 's/ //g' | awk '{print index($0,"//")}')
                    if [[ $LINEAARCHIVO == *"/*"* ]]; then
                        ((COMENTARIO++))
                        MULTILINEA=1 #marco inicio de comentario multilinea
                    elif [[ $sentence > 0 ]]; then
                        ((COMENTARIO++))
                        if [[ $sentence > 1 ]]; then #comentario al final de una linea de codigo
                            ((CODIGO++))
                        fi
                    else
                        ((CODIGO++))
                    fi
                else #esta dentro de un comentario multilinea, o es el fin del comentario
                    if [[ $LINEAARCHIVO == *"*/"* ]]; then
                        ((COMENTARIO++))
                        MULTILINEA=0 #encontre fin de comentario multilinea
                    else
                        ((COMENTARIO++)) #es parte de un comentario multilinea, pero no inicio ni fin
                    fi
                fi
            fi

        done <"$NOMBREARCHIVO"

        sentence=$(echo "$LINEAARCHIVO" | sed -r '/^\s*$/d')
        if ! test -z "$sentence"; then       #si la linea tiene algo escrito
            ((LINEASTOTALES++))              #linea de codigo o comentario, pero no esta vacia
            if [[ $MULTILINEA -eq 0 ]]; then #es codigo o inicio de comentario
                sentence=$(echo "$LINEAARCHIVO" | sed 's/ //g' | awk '{print index($0,"//")}')
                if [[ $LINEAARCHIVO == *"/*"* ]]; then
                    ((COMENTARIO++))
                    MULTILINEA=1 #marco inicio de comentario multilinea
                elif [[ $sentence > 0 ]]; then
                    ((COMENTARIO++))
                    if [[ $sentence > 1 ]]; then #comentario al final de una linea de codigo
                        ((CODIGO++))
                    fi
                else
                    ((CODIGO++))
                fi
            else #esta dentro de un comentario multilinea, o es el fin del comentario
                if [[ $LINEAARCHIVO == *"*/"* ]]; then
                    ((COMENTARIO++))
                    MULTILINEA=0 #encontre fin de comentario multilinea
                else
                    ((COMENTARIO++)) #es parte de un comentario multilinea, pero no inicio ni fin
                fi
            fi
        fi
    fi
done

if [[ $ARCHIVOSTOTALES -ne 0 ]]; then
    if [[ $LINEASTOTALES -ne 0 ]]; then
        echo "Total de archivos analizados: $ARCHIVOSTOTALES, de extensión(es) $EXTVALIDA"
        echo "Lineas totales: $LINEASTOTALES"
        PORCENTAJECODIGO=$(expr $CODIGO \* 100 / $LINEASTOTALES)
        echo "Cantidad de lineas de codigo: $CODIGO, que equivale al $PORCENTAJECODIGO%"
        PORCENTAJECOMENTARIO=$(expr $COMENTARIO \* 100 / $LINEASTOTALES)
        echo "Cantidad de comentarios: $COMENTARIO, que equivale al $PORCENTAJECOMENTARIO%"
    else
        echo "No se encontraron lineas para analizar."
    fi
else
    echo "No se encontraron archivos para analizar."
fi

#---------------------------------------------------------------------#
#                         FIN DEL EJERCICIO 4                         #
#---------------------------------------------------------------------#