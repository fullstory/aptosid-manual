#!/bin/sh

set -e

I18N_LANGUAGES="
	bg:Bulgarian:::
	da:Danish:::
	de:German:Deutsch::
	el:Greek:::
	en:English:English::
	es:Spanish:::
	fr:French:::
	hr:Croatian:::
	hu:Hungarian:::
	it:Italian:::
	ja:Japanese::ttf-kochi-gothic:
	nl:Dutch:Nederlands::
	pl:Polish:::
	pt-br:Brazilian_Portuguese:::
	ro:Romanian:::
	ru:Russian:::
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
			./debian/templates/sidux-manual-LL_CODE.install.in \
				> "./debian/sidux-manual-$(echo ${i} | cut -d\: -f1).install"

	cat ./debian/templates/sidux-manual-common.install.in \
		> ./debian/sidux-manual-common.install
	cat ./debian/templates/sidux-manual-common.links.in \
		> ./debian/sidux-manual-common.links

	# collect package names for the meta package.
	if [ -z "$ALL_I18N_PKG" ]; then
		ALL_I18N_PKG="sidux-manual-$(echo ${i} | cut -d\: -f1)"
	else
		ALL_I18N_PKG="${ALL_I18N_PKG},\n sidux-manual-$(echo ${i} | cut -d\: -f1)"
	fi
done
sed	-e "s/\@ALL_I18N_PKG\@/${ALL_I18N_PKG}/g" \
		./debian/templates/control.meta.in \
			>> debian/control
