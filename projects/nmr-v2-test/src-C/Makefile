CC = gcc
CFLAGS = -Wall -Wextra -std=c11

# Cible principale
app: FSM-nmr-v1-test.c functions.o
	$(CC) $(CFLAGS) -o app FSM-nmr-v1-test.c functions.o

# Compilation du module functions
functions.o: functions.c functions.h
	$(CC) $(CFLAGS) -c functions.c

# Nettoyage des fichiers objets et exécutables
clean:
	rm -f *.o app
