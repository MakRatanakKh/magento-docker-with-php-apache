#Makefile

.PHONY: help

help:
	@echo "make build     = build the project"
	@echo "make terminal  = open a terminal in project container"
	@echo "make up        = docker-compose up"
	@echo "make down      = docker-compose down"



build-app:
	cd docker && docker-compose build

build: build-app

up:
	cd docker && docker-compose up

down:
	cd docker && docker-compose down

terminal:
	cd docker && docker exec -it php_74_apache bash