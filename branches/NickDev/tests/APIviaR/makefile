
# $Id$

all : Rapi

Rapi : 
	@echo Test Rapi: test api functions using R
	R --vanilla --quiet < Rapi.R > Rapi.out
	rm *.svs *.grd
	diff -w Rapi.out Rapi.out.save
	@echo Test Rapi ended
	

