##
#	Makefile para construir el calculador de distancias CAC3.exe
#	
#	AAFR <alffore@gmail.com>
#	2014
#

CC= gcc -c
CLINKER= gcc -o

CFLAGS= -O3 -Wall

LIBS= -lm

OBJ= main.o \
    algoritmoP.o \
    distancias.o \
    recuperaInfoL.o \
    recuperaInfoR.o


 
DIR_SRC=./src/
DIR_BIN=./bin/

all: clean $(OBJ)
	$(CLINKER) $(DIR_BIN)CAC3.exe $(OBJ) $(LIBS) $(CFLAGS)


%.o: $(DIR_SRC)%.c
	$(CC) $(CFLAGS)  $<



docs: borradocs
	doxygen docs/CAC3.dox 


borradocs:

	@rm -rf docs/html
	

clean:
	@rm -rfv *.o

sc: clean
	@rm -rf *.exe