CC := gcc
CFLAGS := -Wall -g
LDFLAGS +=

symtab_test: symtab_test.c ../symtab.c ../symtab.h
	$(CC) $(LDFLAGS) $(CFLAGS) -o $@ $< ../symtab.c

clean:
	$(RM) symtab_test
