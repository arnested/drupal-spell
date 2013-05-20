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

.PHONY: all test clean install dictionary

CARTON?=carton
EMACS?=emacs
TAR?=bsdtar
PANDOC?=pandoc --atx-headers

VERSION?=$(shell $(CARTON) version)
LANGUAGE?=en

ARCHIVE_NAME=drupal-spell
PACKAGE_NAME=$(ARCHIVE_NAME)-$(VERSION)

all: $(PACKAGE_NAME).tar

dict/drupal.$(LANGUAGE).aspell: dict/drupal.txt
	$(EMACS) --batch -l $(PWD)/$(ARCHIVE_NAME).el --eval "(drupal-spell-find-dictionary \"$(LANGUAGE)\")"

dictionary: dict/drupal.$(LANGUAGE).aspell

$(ARCHIVE_NAME)-pkg.el: $(ARCHIVE_NAME).el
	$(CARTON) package

# create a tar ball in package.el format for uploading to http://marmalade-repo.org
$(PACKAGE_NAME).tar: README $(ARCHIVE_NAME).el $(ARCHIVE_NAME)-pkg.el dict/drupal.$(LANGUAGE).aspell dict/drupal.txt
	$(TAR) -c -s "@^@$(PACKAGE_NAME)/@" -f $(PACKAGE_NAME).tar $^

README: README.md
	$(PANDOC) -t plain -o $@ $^

install: $(PACKAGE_NAME).tar
	$(EMACS) --batch -l package -f package-initialize --eval "(package-install-file \"$(PWD)/$(PACKAGE_NAME).tar\")"

clean:
	$(RM) $(ARCHIVE_NAME)-*.tar $(ARCHIVE_NAME)-pkg.el dict/drupal.*.aspell *~ README
	$(RM) -r elpa
