THISDIR = $(shell pwd)

SRC_VER = v4.29-9680
SRC_BRANCH = rtm

SRC_NAME = softether-src-$(SRC_VER)-$(SRC_BRANCH)
SRC_URL = https://github.com/SoftEtherVPN/SoftEtherVPN_Stable/releases/download/$(SRC_VER)-$(SRC_BRANCH)/$(SRC_NAME).tar.gz

HAMCORE_DIR = $(SRC_VER)/src/bin/BuiltHamcoreFiles/unix
CFLAGS += -minterlink-mips16

all: download_test 
	

download_test:
	( if [ ! -f $(SRC_NAME).tar.gz ]; then \
		wget -t5 --timeout=20 --no-check-certificate -O $(SRC_NAME).tar.gz $(SRC_URL); \
	fi )

extract_test:
	( if [ ! -d $(SRC_VER) ]; then \
		tar xf $(SRC_NAME).tar.gz; \
		patch --binary -d $(SRC_VER) -p1 < softethervpn-$(SRC_VER).patch ; \
		mkdir -p $(SRC_VER)/tmp/ ; \
		mkdir -p $(SRC_VER)/tmp/objs/ ; \
		mkdir -p $(SRC_VER)/tmp/objs/Mayaqua/ ; \
		mkdir -p $(SRC_VER)/tmp/objs/Cedar/ ; \
		mkdir -p $(SRC_VER)/tmp/as/ ; \
		mkdir -p $(SRC_VER)/bin/ ; \
		mkdir -p $(SRC_VER)/bin/vpnserver/ ; \
		mkdir -p $(SRC_VER)/bin/vpnclient/ ; \
		mkdir -p $(SRC_VER)/bin/vpnbridge/ ; \
		mkdir -p $(SRC_VER)/bin/vpncmd/ ; \
	fi )

put_hamcore:
	( mkdir -p $(HAMCORE_DIR) && cp -f hamcore-unix/$(SRC_VER)/hamcore.se2 $(HAMCORE_DIR)/hamcore.se2 && \
		touch -t `date -d next-day +%Y%m%d%H%M` $(HAMCORE_DIR)/hamcore.se2 \
	)

romfs:

