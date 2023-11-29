CC := gcc
YACC := bison
LEX := flex
CFLAGS := -Wall -g
LDFLAGS +=

xyz: xyz.o symtab.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

xyz.o: xyz.tab.c
	$(CC) $(CFLAGS) -c -o $@ $<

symtab.o: symtab.c symtab.h
	$(CC) $(CFLAGS) -c -o $@ $<

xyz.tab.c: xyz.y xyz.yy.c
	$(YACC) -d $<

xyz.yy.c: xyz.l
	$(LEX) -o $@ $<

clean:
	$(RM) *.o xyz.yy.c xyz.tab.c xyz.tab.h xyz
