CFLAGS=-Wall -fPIC -ansi -pedantic
LIBDIR=/lib

ifeq ($(shell if uname -o | grep -q "GNU/Linux" ; then echo true; else echo false; fi),true)
    ifeq ($(shell if [ -e /etc/debian_version ] ; then echo true; else echo false; fi),true)
	DEB_HOST_MULTIARCH ?= $(shell dpkg -L libc6 | sed -nr 's|^/etc/ld\.so\.conf\.d/(.*)\.conf$$|\1|p')
	ifneq ($(DEB_HOST_MULTIARCH),)
	    LIBDIR=/lib/$(DEB_HOST_MULTIARCH)
	endif
    else ifeq ($(shell uname -m),x86_64)  # redhat?
	LIBDIR=/lib64
    endif
endif

PAM_DIR=$(LIBDIR)/security

all: pam_oauth2.o pam_oauth2.so 

pam_oauth2.o: pam_oauth2.c
	$(CC) pam_oauth2.c -lcurl -lpam -shared -o pam_oauth2.o

pam_oauth2.so: pam_oauth2.o
	$(CC) -shared $^ -lcurl -o $@

install: pam_oauth2.so
	install -d $(DESTDIR)$(PAM_DIR)
	install -m 644 $< $(DESTDIR)$(PAM_DIR)

clean:
	$(MAKE) -C jsmn clean
	rm -f *.o *.so
