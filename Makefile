# This file is part of Drupal spell.

# Copyright (C) 2012, 2013 Arne Jørgensen

# Author: Arne Jørgensen <arne@arnested.dk>

# Drupal spell is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# Drupal mode is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with Drupal spell.  If not, see
# <http://www.gnu.org/licenses/>.

.PHONY: all test clean install

ARCHIVE_NAME:=drupal-spell
VERSION:=$(shell carton version)
PACKAGE_NAME=$(ARCHIVE_NAME)-$(VERSION)
LANGUAGE=en

all: $(PACKAGE_NAME).tar

dict/drupal.$(LANGUAGE).aspell: dict/drupal.txt
	@aspell --lang $(LANGUAGE) create master ./$@ < $^

$(ARCHIVE_NAME)-pkg.el: $(ARCHIVE_NAME).el
	@carton package

# create a tar ball in package.el format for uploading to http://marmalade-repo.org
$(PACKAGE_NAME).tar: README $(ARCHIVE_NAME).el $(ARCHIVE_NAME)-pkg.el dict/drupal.$(LANGUAGE).aspell dict/drupal.txt
	@bsdtar -c -s "@^@$(PACKAGE_NAME)/@" -f $(PACKAGE_NAME).tar $^

README: README.md
	pandoc --atx-headers -t plain -o $@ $^

install: $(PACKAGE_NAME).tar
	@emacs --batch --user `whoami` -l package --eval "(progn \
		(package-initialize)\
		(package-install-file \"`pwd`/$(PACKAGE_NAME).tar\"))"

clean:
	$(RM) $(ARCHIVE_NAME)-*.tar $(ARCHIVE_NAME)-pkg.el dict/drupal.*.aspell *~ README
