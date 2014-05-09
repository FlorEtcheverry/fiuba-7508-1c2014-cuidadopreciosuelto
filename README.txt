-*-*-*-*-*-*-*-*-*-*-*-*-*-*
75.08 - Sistemas Operativos.
          Grupo 01
-*-*-*-*-*-*-*-*-*-*-*-*-*-*

Observación General:
- Se utilizará el sistema a partir de la terminal.
- Ingresar los comandos y presionar la tecla "ENTER" para ejecutarlos.


Instalar Programa:
- Crear una carpeta con el nombre "grupo01"
- Insertar el dispositivo externo.
- Copiar el contenido dentro de la carpeta creada en el 1er paso.
- Abrir una nueva consola y dirigirse a traves del comando "cd" a la carpeta creada 
  (de ser necesario, ingrese "man cd" para recibir ayuda).
- Descomprima el archivo "Grupo01.tar.gz" en dicha carpeta.
	1) Ejecute el comando "gzip -d Grupo01.tgz"
	2) Luego ejecute el comando "tar -xvf Grupo01.tar".


Pasos para la utilización del sistema RETAILC:
- Abrir una nueva consola y dirigirse a traves del comando "cd" a la carpeta creada
  (en caso de haber cerrado la anterior).
- Ejecutar el comando "./Installer".
- Seguir las instrucciones que le ofrece el instalador.
- De haber terminado completamente la instalación, se verán creados los siguientes directorios,
	* Directorio de Configuración CONFDIR.
	* Directorio de Ejecutableas BINDIR.
	* Directorio de Maestros y Tablas MAEDIR.
	* Directorio de Novedades NOVEDIR.
	* Directorio de Novedades Aceptadas ACEPDIR.
	* Directorio de Informes de Salida INFODIR.
	* Directorio de Archivos Rechazados RECHDIR.
	* Directorio de Logs LOGDIR.
- Se creará un archivo Installer.conf con estos datos.
- También se crea un Installer.log en el mismo directorio, el cual indica el resultado de la instalación. 

- Utilizar el comando "cd" para moverse a la carpeta que contiene los scripts.
- Ejecutar el comando ". ./Initializer"
- Si aceptó ejecutar automaticamente el Listener (demonio) el programa se podrá frenar utilizando 
  el comando ".\Stop" y correrlo nuevamente con el comando ".\Start" utilizando como argumentos el nombre del comando.
- Para empezar a operar copiar los archivos de precios y listas de compras a la carpeta "arribos" (NOVEDIR).


Ejecutar Reporting:
- Abrir una nueva consola y dirigirse a traves del comando "cd" a la carpeta creada, subdirectorio "/bin"
  (en caso de haber cerrado la anterior).
- Ejecutar el comando "Reporting".
- Seguir las instrucciones que le ofrece el menú
  (en caso de querer ver un Reporte guardado, dirigirse al Directorio de Informes de Salida (INFODIR).)

NOTA: Todos los comandos generan su propio log, que contienen información sobre la ejecución de cada uno, los cuales se pueden consultar en caso de comportamiento inesperado.
