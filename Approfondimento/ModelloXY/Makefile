#Cartella per generatore random
RND:=random
CXXFLAGS:= -Wall -pedantic

CC = g++

compila: modelXY

%.exe : %.o random.o
	$(CC) $^ -o $@

%.o : %.cpp
	$(CC) ${CXXFLAGS} $< -c

random.o : ${RND}/random.cpp ${RND}/random.h
	$(CC) ${CXXFLAGS} $< -c


clean :
	rm *.o modelXY
