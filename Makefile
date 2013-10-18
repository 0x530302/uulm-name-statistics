KIZ_USER=s_foobar

default: all

all:
	ssh $(KIZ_USER)@login.rz.uni-ulm.de ypcat passwd > ./ypcat-users.lst
	scp $(KIZ_USER)@login.rz.uni-ulm.de:/soft/common/lib/address/address.db .

	cat ./ypcat-users.lst \
		| awk -F ":" '{print $$5}' \
		| sed -e "s/Prof\.\s//" \
		| sed -e "s/Dr\.\s//" \
		| sed -e "s/-Cifs//" \
		| sed -e "s/[^A-Z\s-]/ /gI" \
		| awk -F " " '{print $$1}' \
		| grep -v "Ev-" \
		| grep -v "Cplus-" \
		| grep -v "DNS" \
		| sed -e "s/-$$//" \
		> ./firstnames.lst

	cat ./address.db \
		| awk -F ":" '{print $$1}' \
		| sed -e 's/\(.\)/\U\1/' \
		> ./firstnames.lst

	cat ./firstnames.lst \
		| sort \
		| uniq -i -c \
		| sort -n > ./firstnames.uniq

	echo "var data = [" > ./js/data.js
	cat ./firstnames.uniq \
		| awk -F " " '{print "[\"" $$2 "\", " $$1 "],"}' \
		| sed -e "$$ s/,$$/]/" \
		>> ./js/data.js

	make further
	make clean

# build a datafile out of second, third, etc. name
further:
	cat ./ypcat-users.lst \
		| awk -F ":" '{print $$5}' \
		| sed -e "s/Prof\.\s//" \
		| sed -e "s/Dr\.\s//" \
		| sed -e "s/-Cifs//" \
		| sed -e "s/[^A-Z\s-]/ /gI" \
		| grep -v "Ev-" \
		| grep -v "Cplus-" \
		| grep -v "DNS" \
		| sed -e "s/-$$//" \
		> ./further-names.lst

	# strip first and lastname
	cat ./further-names.lst \
		| sed -e "s/^[A-Z-]*\s//gI" \
		| sed -e "s/^[A-Z-]*$$//gI" \
		| sed -e "s/\s[A-Z-]*$$//gI" \
		| tr ' ' '\n' \
		| sed -e "/^\s*$$/d" \
		> ./further-names-splitted.lst

	cat ./further-names-splitted.lst \
		| sort \
		| uniq -i -c \
		| sort -n > ./further-names.uniq

	echo "var further_data = [" > ./js/further-names-data.js
	cat ./further-names.uniq \
		| awk -F " " '{print "[\"" $$2 "\", " $$1 "],"}' \
		| sed -e "$$ s/,$$/]/" \
		>> ./js/further-names-data.js

clean:
	rm ./ypcat-users.lst
	rm ./address.db
	rm ./firstnames.uniq
	rm ./firstnames.lst

	rm ./further-names.lst
	rm ./further-names.uniq
	rm ./further-names-splitted.lst
