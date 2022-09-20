#!/bin/bash

# =========================== Encabezado =======================

# Nombre del Script: ej6.sh
# Número de APL: 1
# Número de Ejercicio: 6
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

### Hay que instalar zip y unzip, en Ubuntu ya 
#vienen por defecto pero en el WSL de Windows, dependiendo de la distro
### seguramente haya que instalarlo


Usage() {
    echo "DESCRIPCIÓN"
    echo -e "    $0 [opciones]\n"
    echo "    Funciona como rm pero con opción de recuperación de archivos."
    echo "    Sólo puede seleccionarse una opción a la vez."
    echo "    Solamente pueden eliminarse archivos, no directorios."
    echo "    Sólo puede haber un único archivo eliminado con el mismo nombre y ruta."
    echo -e "    Si se elimina uno igual entonces los datos se sobreescriben al más reciente.\n"
    echo "OPCIONES"
    echo "    -l, --listar"
    echo "           Lista los archivos que contiene la papelera de reciclaje,"
    echo -e "           informando nombre de archivo y su ubicación original.\n"
    echo "    -r, --recuperar <nombre_archivo>"
    echo -e "           Recupera el archivo pasado por parámetro a su ubicación original.\n"
    echo "    -v, --vaciar"
    echo -e "           Vacía la papelera de reciclaje (eliminar definitivamente).\n"
    echo "    -e, --eliminar <nombre_archivo>"
    echo -e "           Elimina el archivo, enviándolo a la papelera de reciclaje.\n"
    echo "    -b, --borrar <nombre_archivo>"
    echo "           Borra un archivo de la papelera, haciendo que no se pueda"
    echo -e "           recuperar.\n"
    echo -e "    -h, --help"
    echo -e "           Muestra esta información y termina la ejecución\n"
}

Listar()
{
    # unzip -p me permite leer un archivo dentro de un zip, en este caso va a ser la lista de
    # archivos que tiene la papelera. El tail es para borrar la primera línea que nos es inútil
    res="$(unzip -p "${rutaPapelera}" ".8RbcsE6wrAyUnX5Rpdata~" | tail -n +2)"
    if [[ "${res}" != "" ]]; then
        echo "${res}"
    else
        echo "La papelera se encuentra vacía."
    fi
    exit 0
}

RecuperarOBorrar() 
{
    # Obtengo la lista de los archivos de mi papelera, sacando la primera línea y quedándome sólo
    # con los nombres
    archivos="$(unzip -p "${rutaPapelera}" ".8RbcsE6wrAyUnX5Rpdata~" | tail -n +2 | grep "^"$nombreArchivo" /")"
    if [[ "$(echo "${archivos}" | wc -l)" -gt 1 ]]; then
        i=1
        temp=""
        # Leo todos los archivos y les doy el formato que piden en la consigna, no pude usar el for
        # porque no me reconocía los saltos de línea del archivo, ni siquiera cambiando el IFS
        while read archivo; do
            temp+=""${i}" - "${archivo}""$'\n'
            ((i++))
        done < <(echo "${archivos}")

        archivos="$(echo "${temp}")"
        # Muestro los archivos con sus opciones
        echo "${archivos}"
        if [ "${B}" -eq 1 ]; then
            echo "¿Qué archivo desea recuperar? __"
        else
            echo "¿Qué archivo desea borrar de la papelera? __"
        fi
        # Ingresa por teclado el número
        read eleccion

        # Si el dato ingresado no está vacío, cumple la expresión regular de ser un número, y está dentro
        # de las opciones...
        if [[ ! -z "${eleccion}" ]] && [[ "${eleccion}" =~ ^[1-9][0-9]* ]] && [[ "${eleccion}" -lt "${i}" ]]; then
            # De la lista de archivos de la papelera, me quedo con el que escogió el usuario, y elimino todos los
            # datos hasta quedarme solamente con la ruta donde se encuentra
            eleccion="$(echo "${archivos}" | grep "^"${eleccion}" - " | sed "s/"""${eleccion}" - """${nombreArchivo}" \/""//1")"
        else
            echo "Opción no válida. Intente de nuevo."
            exit 10
        fi
    # En el caso de que sea solamente un archivo, es decir que solo hay un único archivo con el mismo
    # nombre, y que la lista no esté vacía...
    elif [[ "$(echo "${archivos}" | wc -l)" -eq 1 ]] && [[ "${archivos}" != "" ]]; then
        # Lo mismo que en el anterior, me quedo solamente con la ruta del archivo
        eleccion="$(echo "${archivos}" | sed "s/"${nombreArchivo}" \///1")"
    else
        if [ "${B}" -eq 1 ]; then
            echo "No se encuentra el archivo a borrar."
        else
            echo "No se encuentra el archivo a recuperar."
        fi
        exit 9
    fi
    # Si la opción elegida no fue borrar, entonces descomprimo el archivo y lo devuelvo a su
    # ubicación original, restaurando carpetas en el caso de que se hayan borrado
    # Se descomprime en la carpeta raíz / ya que dentro del zip están las carpetas completas
    # de todo el path, por lo que si se descomprime en algún otro lugar va a colocar el home y etc
    if [ "${B}" -ne 1 ]; then
        unzip -qo "${rutaPapelera}" "${eleccion}"/"${nombreArchivo}" -d /
    fi
    # Ya sea que se esté borrando o restaurando, se elimina el archivo del interior del zip
    zip -dq "${rutaPapelera}" "${eleccion}"/"${nombreArchivo}"
    # Se crea de 0 el archivo temporal, volviendo a poner la primera línea inútil
    echo "8RbcsE6wrAyUnX5RpPuC8hjyWCLyDV6C3tC4NyyT3z6mxeqEmc6c27h35A9FBAYDyFvdeZKQg3XzQQC8xbaCkJ26MnAj8k3KE3Wp7UzsQ5Azvt478n5KLRKD" > "/tmp/.8RbcsE6wrAyUnX5Rpdata~"
    # Se abre de nuevo la lista que está en la papelera, se quita la primera línea, y se utiliza
    # el mismo grep, pero con la opción -v que muestra todo menos lo que matchea.
    # Como el match es idéntico al archivo y la ruta, elimina de la lista solamente el archivo
    # que se restaura o que se borra
    unzip -p "${rutaPapelera}" ".8RbcsE6wrAyUnX5Rpdata~" | tail -n +2 | grep -v "^${nombreArchivo} /${eleccion}$" >> "/tmp/.8RbcsE6wrAyUnX5Rpdata~"
    # Luego de haber generado la lista nueva, se vuelve a guardar dentro del archivo, pisando la anterior
    zip -mjq "${rutaPapelera}" "/tmp/.8RbcsE6wrAyUnX5Rpdata~"
    if [ "${B}" -eq 1 ]; then
        echo "El archivo "/"${eleccion}"/${nombreArchivo}" ha sido borrado de la papelera."
    else
        echo "El archivo "/"${eleccion}"/${nombreArchivo}" ha sido restaurado."
    fi
}

Vaciar()
{
    res="$(unzip -p "${rutaPapelera}" ".8RbcsE6wrAyUnX5Rpdata~" | tail -n +2)"
    if [[ "${res}" = "" ]]; then
        echo "La papelera se encuentra vacía."
    else
        echo "Vaciando papelera..."
        # Elimina todos los archivos que estén dentro del zip
        zip -dq "${rutaPapelera}" "*"
    fi
    exit 0
}

Eliminar()
{
    # Se mueve el archivo de la ruta enviada al zip y se elimina de su ruta original
    zip -mq "${rutaPapelera}" "${rutaAbsoluta}"/"${nombreArchivo}"
    # Se descomprime la lista de archivos que está dentro de la papelera en la ruta tmp
	unzip -qo "${rutaPapelera}" ".8RbcsE6wrAyUnX5Rpdata~" -d "/tmp"
	# Se concatena lo que hubiera en la lista con el nombre y la ruta del nuevo archivo que se agrega
    echo ""${nombreArchivo}" "${rutaAbsoluta}"" >> "/tmp/.8RbcsE6wrAyUnX5Rpdata~"
    # Se vuelve a mover la lista actualizada al interior de la papelera solo el archivo no existía
    if [[ "$(unzip -p "${rutaPapelera}" ".8RbcsE6wrAyUnX5Rpdata~" | tail -n +2 | grep "^${nombreArchivo} ${rutaAbsoluta}$")" = "" ]]; then
       zip -mjq "${rutaPapelera}" "/tmp/.8RbcsE6wrAyUnX5Rpdata~"
    fi
    echo "Eliminando... \""${nombreArchivo}"\""
    exit 0
}

if ! [ -x "$(command -v zip)" ]; then
  echo 'Error: paquete zip no instalado.'
    echo "Por favor use el comando [sudo apt install zip]"
  exit 1
fi


numArgs=$#

# rutaScript=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

ARGUMENTS=$(getopt -a -o '' --long help,listar,recuperar:,vaciar,eliminar:,borrar: -- "$@" 2> /dev/null)
retorno=$?
if [ $retorno -ne 0 ] || [ $# -eq 0 ]; then
    echo "Error: Parámetros incorrectos." 1>&2
    Usage
    exit 1
fi

H=0
L=0
R=0
V=0
E=0
B=0
cantOpciones=0
rutaArchivo=""
nombreArchivo=""
eval set -- "$ARGUMENTS"
while true; do
    case "$1" in
        --help)
            H=1
            ((cantOpciones++))
            shift ;;
        --listar)
            L=1
            ((cantOpciones++))
            shift ;;
        --recuperar)
            R=1
            ((cantOpciones++))
            nombreArchivo="${2}"
            shift 2 ;;
        --vaciar)
            V=1
            ((cantOpciones++))
            shift ;;
        --eliminar)
            E=1
            ((cantOpciones++)) 
            rutaArchivo="${2}"
            shift 2 ;;
        --borrar)
            B=1
            ((cantOpciones++))
            nombreArchivo="${2}"
            shift 2 ;;
        --)
            shift
            break ;;
        *)
            echo "Opción inesperada: $1 - esto no debería suceder."
            exit -1 ;;
    esac
done

if [ $H -eq 1 ]; then 
    Usage
    exit 0
fi

if [ $numArgs -eq $# ]; then
    echo -e "Error: Parámetros incorrectos.\n" 1>&2 
    Usage
    exit 2
fi

if [ $cantOpciones -ne 1 ]; then
    echo -e "Error: Sólo se puede elegir una opción a la vez." 1>&2
    exit 3
fi

# Consigo el nombre de usuario que está usando la consola de shell
usuario="$(id -u -n)"
if [[ ! -x "/home/"${usuario}"/" ]]; then
    echo "Error: No existe un directorio /home/"${usuario}"/ o se necesita permiso de ejecución en el directorio para crear la papelera."
    exit 4
fi
# Guardo la ruta donde se encuentra la papelera
rutaPapelera="/home/"${usuario}"/.papelera.zip"

# Si el archivo de la papelera no existe, o no es la versión del programa que me pertenece, le agrego un
# archivo de nombre raro que representa que sea único, en ese archivo se van a escribir los datos de la papelera
if [[ ! -e "${rutaPapelera}" ]] || [[ ! $(unzip -Z1 "/home/"${usuario}"/.papelera.zip" | grep '^.8RbcsE6wrAyUnX5Rpdata~$') ]]; then
    # Creo el archivo con una primera línea para agregarle alguna otra validación, pero es probable que la termine borrando
    $(echo "8RbcsE6wrAyUnX5RpPuC8hjyWCLyDV6C3tC4NyyT3z6mxeqEmc6c27h35A9FBAYDyFvdeZKQg3XzQQC8xbaCkJ26MnAj8k3KE3Wp7UzsQ5Azvt478n5KLRKD" > "/tmp/.8RbcsE6wrAyUnX5Rpdata~")
    if [[ ! -w "/home/"${usuario}"/" ]]; then
        echo "Error: Se necesita permiso de escritura en el directorio /home/"${usuario}"/ para crear la papelera."
        exit 5
    fi
    # Se llama al programa de zip para que meta el archivo creado en la carpeta tmp a nuestra papelera,
    # con la opción -m elimina el archivo de la ruta original al guardarlo en el zip
    # la opción -j hace que se guarde en la raíz del zip y no cree la carpeta tmp dentro del zip
    # la opción -q hace que no muestre mensajes por consola
    zip -mjq "${rutaPapelera}" "/tmp/.8RbcsE6wrAyUnX5Rpdata~"
# elif [[ ! $(unzip -Z1 "/home/"${usuario}"/.papelera.zip" | grep '^.8RbcsE6wrAyUnX5Rpdata~$') ]]; then
    # echo "Ya existe un archivo de papelera en /home/"${usuario}"/.papelera.zip pero faltan" 
    # echo "archivos necesarios para su funcionamiento."
    # echo "Elimine el archivo y vuelva a intentar ejecutar el programa para proseguir."
    # exit 4

# elif [[ $(unzip -p "/home/"${usuario}"/.papelera.zip" ".8RbcsE6wrAyUnX5Rpdata~") != "18RbcsE6wrAyUnX5RpPuC8hjyWCLyDV6C3tC4NyyT3z6mxeqEmc6c27h35A9FBAYDyFvdeZKQg3XzQQC8xbaCkJ26MnAj8k3KE3Wp7UzsQ5Azvt478n5KLRKD" ]]; then
#     echo "La versión de la papelera que está utilizando está desactualizada." 
#     exit 5
fi

if [ "$L" -eq 1 ]; then
    Listar "${rutaPapelera}"
fi

if [ "$R" -eq 1 ] || [ "$B" -eq 1 ]; then
    RecuperarOBorrar "${nombreArchivo}" "${rutaPapelera}" "${B}"
fi

if [ "$V" -eq 1 ]; then
    Vaciar "${rutaPapelera}"
fi

if [ "$E" -eq 1 ]; then
    if [ ! -e "${rutaArchivo}" ]; then
        echo "Error: El archivo '"${rutaArchivo}"' no existe o el directorio" 1>&2
        echo "       que lo contiene no posee permisos de ejecución para su usuario." 1>&2
        exit 6
    fi
    if [ -d "${rutaArchivo}" ]; then
        echo "Error: No puede eliminar directorios." 1>&2
        exit 7
    fi
    # Todo esto es para parsear el nombre de archivo con ruta que me envían y obtener la ruta absoluta
    # Básicamente envío lo que me ingresan, y si no tiene una / quiere decir que escribieron
    # el nombre del archivo que se encuentra en la carpeta relativa a la posición del shell
    if [[ "$(echo "${rutaArchivo}" | grep -o "/")" = "" ]]; then
        # en cuyo caso la ruta donde se encuentra el archivo es ./
        rutaAbsoluta="./"
    else
        # Si el nombre del archivo tiene algún / significa que me lo enviaron con una ruta, por lo que
        # me quedo con ella 
        rutaAbsoluta="$(echo "${rutaArchivo}" | rev | cut -d'/' -f 2- | rev)"
    fi
    # Acá se resuelve la ruta para obtener su dirección absoluta
    rutaAbsoluta="$(cd "${rutaAbsoluta}" > /dev/null 2>&1 && pwd)"
    if [ ! -w "${rutaAbsoluta}" ]; then
        echo "Error: No se puede eliminar el archivo porque el directorio donde" 
        echo "       se encuentra no posee permisos de escritura para su usuario." 1>&2
        exit 8
    fi

    nombreArchivo="$(echo "${rutaArchivo}" | rev | cut -d'/' -f 1 | rev)"

    if [[ $(echo "${rutaAbsoluta}"/"${nombreArchivo}") = "${rutaPapelera}" ]]; then
        echo "No puede eliminar la papelera."
        exit 10
    fi

    Eliminar "${nombreArchivo}" "${rutaAbsoluta}" "${rutaPapelera}"
fi

#---------------------------------------------------------------------#
#                         FIN DEL EJERCICIO 6                         #
#---------------------------------------------------------------------#