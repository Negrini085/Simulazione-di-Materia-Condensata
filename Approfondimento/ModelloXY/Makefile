# Cartella per generatore random
RND := random
CXXFLAGS := -Wall -pedantic

CC = g++

compila: modelXY


modelXY: modelXY.o random.o
	$(CC) $^ -o $@

modelXY.o: modelXY.cpp modelXY.h
	$(CC) ${CXXFLAGS} -c $< -o $@

%.o : %.cpp
	$(CC) ${CXXFLAGS} -c $< -o $@

random.o: ${RND}/random.cpp ${RND}/random.h
	$(CC) ${CXXFLAGS} -c $< -o $@


clean:
	rm -f *.o modelXY
