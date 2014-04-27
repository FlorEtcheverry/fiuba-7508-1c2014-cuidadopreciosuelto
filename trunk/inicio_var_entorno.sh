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
fi

if [ ! -d ./novedades ]
then
	mkdir novedades
fi

if [ ! -d ./rechazados ]
then
	mkdir rechazados
fi

export LOGDIR=./logs
export BINDIR=./binarios
export LOGEXT=log
export LOGSIZE=1
export MAEDIR=./maestros
export ACEPDIR=./aceptados
export NOVEDIR=./novedades
export RECHDIR=./rechazados
