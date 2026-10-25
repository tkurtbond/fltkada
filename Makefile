GPRINSTALL ?= gprinstall

.PHONY: build-dynamic build-static install-dynamic install-static

build-dynamic:
	gprbuild -p -Xlibrary_type=dynamic fltkada.gpr

build-static:
	gprbuild -p -Xlibrary_type=static fltkada.gpr

install-dynamic: build-dynamic
	$(GPRINSTALL) -f -p -m -Xlibrary_type=dynamic fltkada.gpr \
	    --build-name=dynamic --build-var=library_type

install-static: build-static
	$(GPRINSTALL) -f -p -m -Xlibrary_type=static fltkada.gpr \
	    --build-name=static --build-var=library_type
