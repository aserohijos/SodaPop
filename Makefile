RM =rm
CP =cp
CC =g++

IDIR =./include
CXXFLAGS =-std=c++11 -Wall -O3 -I$(IDIR)
LINK = $(CXX) $(CXXFLAGS)
COMPILE = $(CXX) $(LIBS) $(CXXFLAGS) $(LDFLAGS) $(LDLIBS) -c

SODAPOP = sodapop
SODAPOPMORAN = sodapopMoran
SNAP2ASCII = sodasnap
SUMM2SNAP = sodasumm

INSTALLDIR = /usr/local/bin

all: $(SODAPOP) $(SNAP2ASCII) $(SUMM2SNAP) ${SODAPOPMORAN}

install:
	@echo \#\#\# Installing binaries to $(INSTALLDIR)/...
	$(CP) $(SODAPOP) $(INSTALLDIR)/
	$(CP) $(SNAP2ASCII) $(INSTALLDIR)/
	$(CP) $(SUMM2SNAP) $(INSTALLDIR)/
	$(CP) $(SODAPOPMORAN) $(INSTALLDIR)/
    
uninstall:
	@echo \#\#\# Uninstalling binaries from $(INSTALLDIR)/...
	$(RM) -r $(INSTALLDIR)/$(SODAPOP)
	$(RM) -r $(INSTALLDIR)/$(SNAP2ASCII)
	$(RM) -r $(INSTALLDIR)/$(SUMM2SNAP)
	$(RM) -r $(INSTALLDIR)/$(SODAPOPMORAN)

# link
$(SODAPOP): sodapop.o rng.o global.o gene.o cell.o population.o
	$(LINK) sodapop.o rng.o global.o gene.o cell.o population.o -o sodapop
$(SNAP2ASCII): snap2ascii.o
	$(LINK) -o sodasnap snap2ascii.o rng.o global.o
$(SUMM2SNAP): summ2snap.o rng.o gene.o cell.o global.o
	$(LINK) -o sodasumm summ2snap.o rng.o global.o gene.o cell.o

$(SODAPOPMORAN): sodapopMoran.o rng.o global.o gene.o cell.o population.o
	$(LINK) sodapopMoran.o rng.o global.o gene.o cell.o population.o -o sodapopMoran



# compile different units
rng.o: ./src/rng.cpp
	$(COMPILE) -o rng.o ./src/rng.cpp
global.o: ./src/global.cpp
	$(COMPILE) -o global.o ./src/global.cpp
gene.o: ./src/Gene.cpp
	$(COMPILE) -o gene.o ./src/Gene.cpp
cell.o: ./src/Cell.cpp
	$(COMPILE) -o cell.o ./src/Cell.cpp
population.o: ./src/Population.cpp
	$(COMPILE) -o population.o ./src/Population.cpp
sodapop.o: ./src/evolve.cpp
	$(COMPILE) -o sodapop.o ./src/evolve.cpp
snap2ascii.o: ./tools/snap2ascii.cpp ./src/global.cpp
	$(COMPILE) -o snap2ascii.o ./tools/snap2ascii.cpp
summ2snap.o: ./tools/summ2snap.cpp ./src/Cell.cpp
	$(COMPILE) -o summ2snap.o ./tools/summ2snap.cpp


sodapopMoran.o: ./src/evolve-moran.cpp
	$(COMPILE) -o sodapopMoran.o ./src/evolve-moran.cpp




clean:
	rm -f *.o
