-*-*-*-*-*-*-*-*-*-*-*-*-*-*
75.08 - Sistemas Operativos.
          Grupo 01
-*-*-*-*-*-*-*-*-*-*-*-*-*-*

Observaciones Generales:
- Se correrá a partir de la consola.
- Ingresar los comamndo y presionar la tecla "ENTER" para ejecutarlos.


Instalar Programa:
- Crear una carpeta con el nombre "Grupo01"
- Insertar el dispositivo externo.
- Copiar el contenido dentro de la carpeta creada en el 1er paso.
- Abrir una nueva consola y dirigirse a traves del comando "cd" a la carpeta creada 
  (de ser necesario, ingrese "man cd" para recibir ayuda).
- Descomprima el archivo "Grupo01.tar.gz" en dicha carpeta.
	1) Ejecute el comando "gzip -d Grupo01.tar.gz"
	2) Luego ejecute el comando "tar -xvf Grupo01.tar".
- Abrir una nueva consola y dirigirse a traves del comando "cd" a la carpeta creada
  (en caso de haber cerrado la anterior).
- Ejecutar el comando "./Installer.sh".
- Seguir las instrucciones que le ofrece el instalador.
- De haber terminado completamente la instalación, se verán creados los siguientes directorios,
	* Directorio de Configuración "/conf".
	* Directorio de Ejecutableas "/bin".
	* Directorio de Maestros y Tablas "/mae".
	* Directorio de Novedades "/arribos".
	* Directorio de Novedades Aceptadas "/aceptadas".
	* Directorio de Informes de Salida "/informes".
	* Directorio de Archivos Rechazados "/rechazados".
	* Directorio de Logs "/log".

Ejecutar Programa
- Abrir una nueva consola y dirigirse a traves del comando "cd" a la carpeta creada, subdirectorio "/bin"
  (en caso de haber cerrado la anterior).
- Ejecutar el comando "./Initializer.sh"
- Si aceptó ejecutar automaticamente el Listener (demonio) el programa se podrá frenar utilizando 
  el comando "./Stop.sh" y correrlo nuevamente con el comando "./Start.sh".
- Para empezar a operar copiar los archivos correspondientes "Listas de Compras" y "Listas de Precios"
  al subdirectorio "/arribos".
  Si los archivos fueron aceptados podrá verlos procesados en los subdirectorios "/aceptadas/proc" y "/mae/precios/proc"
  respectivamente.
  Caso contrario, podrá encontrar los archivos rechazador en el subdirectorio "rechazados".
- Como resultado de los archivos aceptados, se encontraran en el subdirectorio "/informes/pres" las listas presupuestadas.


Ejecutar Reporting:
- Abrir una nueva consola y dirigirse a traves del comando "cd" a la carpeta creada, subdirectorio "/bin"
  (en caso de haber cerrado la anterior).
- Ejecutar el comando "perl Reporting.pl".
- Seguir las instrucciones que le ofrece el menú
  (en caso de querer guardar un Reporte, dirigirse al Directorio de Informes de Salida "/informes")