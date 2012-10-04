DOMAIN=squibby-tasks
SUITE=precise
FLAVOURS=desktop
TASKDESC=$(DOMAIN).desc
TASKDIR=/usr/share/tasksel
DESCDIR=squibby-tasks
VERSION=$(shell expr "`dpkg-parsechangelog 2>/dev/null |grep Version:`" : '.*Version: \(.*\)' | cut -d - -f 1)
ARCH=$(shell dpkg --print-architecture)

all: $(TASKDESC)

$(DESCDIR): squibby-seeds.pl
	./squibby-seeds.pl $(DESCDIR) $(SUITE) $(FLAVOURS)

$(TASKDESC): makedesc.pl $(DESCDIR)
	./makedesc.pl $(DESCDIR) $(TASKDESC)

install:
	install -d $(DESTDIR)$(TASKDIR) \
		$(DESTDIR)/usr/lib/tasksel/info \
		$(DESTDIR)/usr/lib/tasksel/packages
	install -m 0644 $(TASKDESC) $(DESTDIR)$(TASKDIR)
	for flavour in $(filter-out platform,$(FLAVOURS)); do \
		ln -s desktop.preinst $(DESTDIR)/usr/lib/tasksel/info/$$flavour-desktop.preinst; \
	done; \
	for package in packages-$(ARCH)/*; do \
		[ "$$package" = "packages-$(ARCH)/list" ] && continue; \
		install -m 755 $$package $(DESTDIR)/usr/lib/tasksel/packages/; \
	done

clean:
	rm -f $(TASKDESC) *~
	rm -rf germinate-out packagelists*
