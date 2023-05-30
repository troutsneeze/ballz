# This should compile on Linux and DJGPP without changes

CC=gcc
FLAGS=-Wall

ifdef DJGPP
	LIBS=-lalleg
	EXE=ballz.exe
else
	LIBS=`allegro-config --libs` icon.res
	EXE=ballz
endif

ballz: ballz.c ballz.h datnames.h
	$(CC) $(FLAGS) ballz.c -o $(EXE) $(LIBS) -lm

clean:
	@rm -f ballz $(EXE) *.o *~ core
