PREFIX := /usr/local
bindir = $(PREFIX)/bin
libexecdir = $(PREFIX)/libexec/archivematica
mandir = $(PREFIX)/share/man/man1

.PHONY: doc install install-doc install-makedirs

am:
	sed -i.bak s,@PREFIX@,$(libexecdir), bin/am

doc:
	ronn -r doc/am.1.md

install-makedirs:
	install -d $(DESTDIR)$(bindir)
	install -d $(DESTDIR)$(libexecdir)
	install -d $(DESTDIR)$(mandir)

install-doc:
	install doc/am.1 $(DESTDIR)$(mandir)

install: am doc install-makedirs install-doc
	install bin/am $(DESTDIR)$(bindir)
	install tools/* $(DESTDIR)$(libexecdir)
