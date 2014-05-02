#!/bin/sh
export INIT=true

if [ ! -d ./logs ]
then
	mkdir logs
fi

if [ ! -d ./binarios ]
then
	mkdir binarios
fi

if [ ! -d ./maestros ]
then
	mkdir maestros
	mkdir ./maestros/precios
	mkdir ./maestros/precios/proc
fi

if [ ! -d ./aceptados ]
then
	mkdir aceptados
	mkdir ./aceptados/proc
fi

if [ ! -d ./novedades ]
then
	mkdir novedades
fi

if [ ! -d ./rechazados ]
then
	mkdir rechazados
fi

if [ ! -d ./informes ]
then
	mkdir informes
	mkdir ./informes/pres
fi


export LOGDIR=./logs
export BINDIR=./binarios
export LOGEXT=log
export LOGSIZE=20
export MAEDIR=./maestros
export ACEPDIR=./aceptados
export NOVEDIR=./novedades
export RECHDIR=./rechazados
export INFODIR=./informes
