# Copyright (C) 2023 Gyoza Associate,Inc - All Rights Reserved
# GPLv3
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

TARGET       = gyoza
GZ_FILES     = gz_logger gz_create gz_draw_file_progress gz_download gz_img gz_extract gz_menu gz_import gz_gyoza
SYSLINUX_URL = https://mirrors.edge.kernel.org/pub/linux/utils/boot/syslinux/syslinux-4.07.tar.gz
GET_URL = $(shell tool=`which wget 2>/dev/null || which curl 2>/dev/null`; \
		if echo $$tool | grep 'wget' >/dev/null; then \
			echo $$tool --quiet --output-document=/dev/stdout; \
		elif echo $tool | grep 'curl' >/dev/null; then \
			echo $$tool --insecure --location --silent --show-error; \
		fi)

ifeq "$(GET_URL)" ""
$(error "No download tools found")
endif

ifdef DESTDIR
	INSTALL_PATH = $(DESTDIR)/usr/bin/$(TARGET)
else
	INSTALL_PATH = $(prefix)/usr/bin/$(TARGET)
endif

$(TARGET): $(GZ_FILES) bin.tar.gz
	sed -n '1,/^COPYRIGHT/p' $< > $@
	for file in $(GZ_FILES) ; do \
		tr '\n' '\0' < $$file | sed 's/.*COPYRIGHT//' | sed 's/:<< *UNIT_TEST.*//' | tr '\0' '\n' >> $@; \
	done
	cat bin.tar.gz >> $@
	chmod 755 $@

bin.tar.gz: syslinux-4.07/linux/syslinux
	cp $< .
	tar zcvf $@ --owner=0 --group=0 syslinux theme

syslinux-4.07/linux/syslinux:
	$(GET_URL) $(SYSLINUX_URL) | tar zxvf - ;
	$(MAKE) -C syslinux-4.07/libinstaller
	$(MAKE) -C syslinux-4.07/linux

install: $(TARGET)
	install -m 755 -D $< $(INSTALL_PATH)

uninstall:
	rm -f $(INSTALL_PATH)

clean:
	rm -rf $(TARGET) syslinux syslinux-4.07 bin.tar.gz

.PHONY: clean install uninstall
