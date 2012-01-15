#!/bin/sh
#
# Copyright © 2010-2012 Stefan Lippers-Hollmann <s.l-h@gmx.de>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; version 2 of 
# the License only.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

set -e

#	bg:Bulgarian:български::
#	el:Greek:Ελληνικά::
#	hr:Croatian:Hrvatski::
#	hu:Hungarian:Magyar::
I18N_LANGUAGES="
	cz:Czech:Čeština::
	da:Danish:Dansk::
	de:German:Deutsch::
	en:English:English::
	es:Spanish:Español::
	fr:French:Français::
	it:Italian:Italiano::
	ja:Japanese:日本語:ttf-kochi-gothic:
	nl:Dutch:Nederlands::
	pl:Polish:Polski::
	pt-br:Brazilian_Portuguese:Português::
	ro:Romanian:Română::
	ru:Russian:русский::
	uk:Ukrainian:Українська::
"

# clean up obsolete stuff
rm -f	./debian/*.install \
	./debian/*.links \
	./debian/*.postinst \
	./debian/*.postrm

[ -d ./debian ] || exit 1
cat	./debian/templates/control.source.in \
	./debian/templates/control.common.in \
		> debian/control
for i in $I18N_LANGUAGES; do
	# write debian/control from templates
	LL_LANGUAGE_EXTRA_DEPENDS=""
	if [ -n "$(echo ${i} | cut -d\: -f4)" ]; then
		LL_LANGUAGE_EXTRA_DEPENDS=",\n $(echo ${i} | cut -d\: -f4)"
	fi
	sed	-e "s/\@LL_CODE\@/$(echo ${i} | cut -d\: -f1)/g" \
		-e "s/\@LL_LANGUAGE\@/$(echo ${i} | cut -d\: -f2 | sed s/_/\ /)/g" \
		-e "s/\@LL_LOCAL_LANGUAGE\@/$(echo ${i} | cut -d\: -f3 | sed s/_/\ /)/g" \
		-e "s/\@LL_LANGUAGE_EXTRA_DEPENDS\@/${LL_LANGUAGE_EXTRA_DEPENDS}/g" \
			./debian/templates/control.LL_CODE.in \
				>> ./debian/control

	# write debian/*.install from templates
	sed	-e "s/\@LL_CODE\@/$(echo ${i} | cut -d\: -f1)/g" \
			./debian/templates/aptosid-manual-LL_CODE.install.in \
				> "./debian/aptosid-manual-$(echo ${i} | cut -d\: -f1).install"

	cat ./debian/templates/aptosid-manual-common.install.in \
		> ./debian/aptosid-manual-common.install
	cat ./debian/templates/aptosid-manual-common.links.in \
		> ./debian/aptosid-manual-common.links

	# collect package names for the meta package.
	if [ -z "$ALL_I18N_PKG" ]; then
		ALL_I18N_PKG="aptosid-manual-$(echo ${i} | cut -d\: -f1)"
	else
		ALL_I18N_PKG="${ALL_I18N_PKG},\n aptosid-manual-$(echo ${i} | cut -d\: -f1)"
	fi
done
sed	-e "s/\@ALL_I18N_PKG\@/${ALL_I18N_PKG}/g" \
		./debian/templates/control.meta.in \
			>> debian/control
