PREFIX := /usr/local
bindir = $(PREFIX)/bin
libexecdir = $(PREFIX)/libexec/archivematica

.PHONY: doc install

am:
	sed -i.bak s,@PREFIX@,$(libexecdir), bin/am

install: am
	install -d $(DESTDIR)$(bindir)
	install -d $(DESTDIR)$(libexecdir)
	install bin/am $(DESTDIR)$(bindir)
	install tools/* $(DESTDIR)$(libexecdir)
