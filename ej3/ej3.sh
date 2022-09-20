#!/bin/bash

# =========================== Encabezado =======================

# Nombre del Script: ej3.sh
# Número de APL: 1
# Número de Ejercicio: 3
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

#archivos creados directamente como <vim nombre> no van a tener registros
#no se toma en cuenta la creacion y eliminacion de directorios, [pero en teoria si su contenido]


Usage() {
    echo "   Uso:"
    echo "    $0 [opciones]"
    echo -e "    $0 -c [ruta] -a [acciones]\n"
    echo "    Monitorea un directorio y sus subdirectorios. Cuando se produce un cambio"
    echo -e "    en un archivo, realiza distintas acciones.\n"
    echo "   Opciones:"
    echo "    -c [ruta]        registra los cambios en el directorio y subdirectorios,"
    echo "                     el contenido del directorio no debe estar vacío"
    echo "    -a [acciones]    ejecuta distintas acciones cuando se produce un cambio"
    echo "                     en el directorio o subdirectorio y sus archivos no privados"
    echo "                     se pueden enviar varias acciones separadas por \",\""
    echo "    -s [ruta]        ruta donde se ejecutará la acción <publicar>, si no existe"
    echo "                     entonces la crea"
    echo -e "    -h, --help       muestra esta información y termina la ejecución\n"
    echo "   Acciones:"
    echo "    listar           muestra por pantalla los nombres de los archivos que"
    echo "                     sufrieron cambios (archivos creados, modificados,"
    echo "                     renombrados, borrados)"
    echo "    peso             muestra por pantalla el peso de los archivos que sufrieron"
    echo "                     cambios. Solo disponible con la acción <listar>"
    echo "    compilar         compila los archivos dentro de <-c> en el directorio bin/"
    echo "                     donde se encuentra este script"
    echo "    publicar         copia el archivo generado por la acción <compilar> a un"
    echo "                     directorio pasado como parámetro <-s>"
    echo -e "                     solo disponible con la acción <compilar>\n"
    echo "   Bugs Conocidos:"
    echo "    Si se utiliza con un editor de texto como vim, que no sobreescribe"
    echo "    archivos sino que crea unos temporales y luego los renombra,"
    echo "    el script pierde la eficiencia ya que realiza las acciones hasta"
    echo "    tres veces. Para evitar una pérdida de performance aún mayor,"
    echo "    se ignoran los cambios en el archivo temporal \"4913\", ya que"
    echo "    es uno de los archivos utilizados por vim."
    exit 0
}

numArgs=$#

#-a sirve para decirle que los parametros cortos tambien se pueden mandar con la inicial
ARGUMENTS=$(getopt -a -o c:a:s: --long help -- "$@" 2>/dev/null)
retorno=$?
if [ $retorno -ne 0 ] || [ $# -eq 0 ]; then
    echo "Error: Parámetros incorrectos." 1>&2
    Usage
fi

RUTAMONITOREAR=""
ACCIONES=""
s=0
RUTAPUBLICAR=""
eval set -- "$ARGUMENTS"

while true; do
    case "$1" in
    --help)
        Usage
        ;;
    -c)
        RUTAMONITOREAR="$2"
        shift 2
        ;;
    -a)
        ACCIONES="$2"
        shift 2
        ;;
    -s)
        s=1 # Agregué a la variable s para distinguir que se eligió la opción de que se envió una ruta vacía
        RUTAPUBLICAR="$2"
        shift 2
        ;;
    --)
        shift
        break
        ;;
    *)
        echo "Opción inesperada: $1 - esto no debería suceder."
        exit -1
        ;;
    esac
done

# Validación por si no envía ninguna opción pero sí parámetros sueltos
if [ $numArgs -eq $# ]; then
    echo "Error: Parámetros incorrectos." 1>&2 
    Usage
fi

if [ "${RUTAMONITOREAR}" != "" ]; then      #mandaron el paramtro -c
    if [ ! -d "${RUTAMONITOREAR}" ]; then #falta la ruta para -c
        echo "Error: La ruta especificada no existe o no es un directorio." 1>&2
        exit 1
    fi

    if [ ! -r "${RUTAMONITOREAR}" ]; then #no puede acceder a la ruta de -c
        echo "Error: No tiene permisos de lectura en la ruta especificada." 1>&2
        exit 2
    fi
    # La ruta -c es un directorio vacío
    # if [ $(ls "${RUTAMONITOREAR}" -a | wc -l) -eq "2" ]; then
    #     echo "Error: La ruta especificada se encuentra vacía." 1>&2
    #     exit 3
    # fi

    if [ "$ACCIONES" == "" ]; then #no mando ninguna accion
        echo "Error: No se enviaron acciones. Use la opcion -a seguida de las acciones listar, peso, compilar o publicar." 1>&2
        exit 4
    fi

    #tenemos ruta de monitoreo y las acciones a monitorear
    IFS=$','
    PUBLICAR=0
    COMPILAR=0
    PESO=0
    LISTAR=0
    for acc in $(echo "$ACCIONES"); do #reviso que las acciones sean correctas
        if [ ${acc,,} != 'listar' ] && [ ${acc,,} != 'peso' ] && [ ${acc,,} != 'compilar' ] && [ ${acc,,} != 'publicar' ]; then
            echo "Error: La accion $acc no es valida."
            exit 4
        fi

        if [ ${acc,,} == 'publicar' ]; then #banderas para saber que acciones se mandaron
            PUBLICAR=1
        fi
        if [ ${acc,,} == 'compilar' ]; then
            COMPILAR=1
        fi
        if [ ${acc,,} == 'listar' ]; then
            LISTAR=1
        fi
        if [ ${acc,,} == 'peso' ]; then
            PESO=1
        fi
    done
else
    echo "Ruta no especificada"
fi

# No debería tener sentido que vea el peso si no ve los datos de las modificaciones
if [ "$PESO" -eq 1 ] && [ "$LISTAR" -eq 0 ]; then
    echo "Error: La acción peso requiere también la acción listar."
    exit 11
fi
# Agrego validaciones para si se elige la opción -s de publicar
if [ "$s" -eq 1 ]; then
    if [ "$PUBLICAR" -eq 0 ]; then
        echo "Error: Para la opcion -s se necesita de la accion publicar."
        exit 8
    elif [ "${RUTAPUBLICAR}" == "" ]; then
        echo "Error: Para la opcion -s debe especificar la ruta a publicar."
        exit 9
    fi
    # La ruta de -s existe pero no tiene permisos de lectura
    if [ -d "${RUTAMONITOREAR}" ] && [ ! -r "${RUTAPUBLICAR}" ]; then
        echo "Error: No tiene permisos de lectura en la ruta especificada en la opción -s." 1>&2
        exit 10
    fi
fi

if [ $PUBLICAR -eq 1 ]; then
    if [ $COMPILAR -eq 0 ]; then
        echo "Error: Para la accion publicar se necesita tambien la accion compilar."
        exit 6
    elif [ "$s" -eq 0 ]; then
        echo "Error: Para la accion publicar debe especificar la ruta para el directorio destino con la opcion -s."
        exit 7
    elif [ ! -d "${RUTAPUBLICAR}" -a ! -e "${RUTAPUBLICAR}" ]; then #se hace aca para evitar crear
        #un directorio si hay otras acciones invalidas
        mkdir "${RUTAPUBLICAR}"
    fi
fi

BANDERA=0 #para evitar muchos mensajes despues de una modificacion
function execute() {
    # echo "$changed"
    # Si la carpeta no existe, la creo, y concateno todos los archivos

    # IFS="$backIFS"
	filetype="Archivo"
    # Uno de los únicos carácteres que no son válidos como nombre de archivo
    # o carpeta en Linux y Windows es el /, así que separar las columnas por eso
    # hace que cualquier nombre sea válido y sea muy fácil de separar en partes
	NOMBREARCHIVO=$(echo "$changed" | cut -d '/' -f 1)
    ACCION=$(echo "$changed" | cut -d '/' -f 2)
	DIRECCION=$(echo "$changed" | cut -d '/' -f 3-)

	filename=$(basename -- "$NOMBREARCHIVO") #parseo
	extension="${filename##*.}"
	filename="${filename%.*}"

    # Si la acción contiene ISDIR quiere decir que se trata de un directorio,
    # así que procedemos a separar el ISDIR de la acción
	if [[ "$ACCION" = *"ISDIR"* ]]; then
        ACCION=$(echo "$ACCION" | cut -d ',' -f 1)
		filetype="Directorio" # Con esto podemos mostrar que es un directorio
    fi

    # Si no es un archivo oculto, de backup, o el archivo temporal de vim
    if [[ "${NOMBREARCHIVO}" != "4913" ]] && [[ "${NOMBREARCHIVO}" != .* ]] && [[ "${NOMBREARCHIVO}" != *~ ]]; then
        # if [[ $BANDERA -eq 0 ]] && [[ $extension != "swp" ]] && [[ $extension != "swpx" ]] && [[ $extension != "swx" ]] ; then #no se esta editando
        # No creo que sea buena idea ocultar extensiones, yo puedo crear 
        # un archivo swp o lo que sea y lo haría intrackeable
        # no es malo que muestre archivos temporales, ya que el objetivo del script
        # es poder ver todos los cambios que sufre un directorio, eso incluye las modificaciones
        if [[ "$LISTAR" -eq 1 ]]; then 
            if [[ $extension ==  $filename ]]; then
                extension=""
            elif [[ $extension != "" ]]; then
                extension=".$extension"
            fi
            # if [[ $filename = *"~" ]] || [[ $extension = *"~" ]] || [ $ACCION == "MODIFY" ]; then
            # 	filename="${filename%~*}"
            # 	extension="${extension%~*}"
            # Este evento evita los mensajes duplicados al modificar un archivo
            if [[ $ACCION == "CLOSE_WRITE,CLOSE" ]]; then
                ACCIONESP="modificado en"
                # BANDERA=2 #al modificar aparece 3 veces el mensaje, con esto se evita
            elif [[ $ACCION == "CREATE" ]]; then
                ACCIONESP="creado en"
            elif [[ $ACCION == "MOVED_FROM" ]]; then
                ACCIONESP="movido desde"
            elif [[ $ACCION == "MOVED_TO" ]]; then
                ACCIONESP="movido hacia"
            elif [[ $ACCION == "DELETE" ]]; then
                ACCIONESP="eliminado en"
            fi

            if [ $PESO -eq 1 ]; then
                if [[ "$ACCION" != "DELETE" ]] && [[ "$ACCION" != "MOVED_FROM" ]]; then
                    PESOARCHIVO=$(stat -c%s "$DIRECCION""$NOMBREARCHIVO" 2> /dev/null)
                    if [[ "$PESOARCHIVO" != "" ]]; then
                    PESOARCHIVO="<"$PESOARCHIVO">"
                    fi
                else
                    PESOARCHIVO=""
                fi
            fi

            echo ""$filetype": <"$NOMBREARCHIVO"> <"$ACCIONESP"> <"$DIRECCION"> $PESOARCHIVO"

        # else
        # 	if [[ BANDERA -gt 0 ]]; then
        # 		((BANDERA--))
        # 	else
        # 		:
        # 		#sin esto el nano muestra varias modificaciones
        # 	fi
        fi

        if [ "$COMPILAR" -eq 1 ]; then
            if [ ! -d "./bin" -a ! -e "./bin" ]; then
                mkdir "./bin" #creo directorio bin porque no existia
            fi
            > "./bin/compilacion.ej3"
            find "${RUTAMONITOREAR}" -type f -exec cat {} + >> "./bin/compilacion.ej3" 2> /dev/null
        fi

        if [ "$PUBLICAR" -eq 1 ]; then
            cp "./bin/compilacion.ej3" "${RUTAPUBLICAR}""/compilacion.ej3"
        fi
    fi
}

# inotifywait --quiet --recursive -m --timefmt "%d/%m/%y %H:%M" --format "%T %w%f %e" 
setsid inotifywait --quiet --recursive -m --format "%f/%e/%w" \
    --event close_write,move,create,delete "${RUTAMONITOREAR}" --exclude '\.ej3'   |
    while read changed; do
    # echo $changed
	execute $changed
    done &



#---------------------------------------------------------------------#
#                         FIN DEL EJERCICIO 3                         #
#---------------------------------------------------------------------#