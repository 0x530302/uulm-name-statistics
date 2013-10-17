KIZ_USER=s_mmuel2

default: all

all:
	ssh $(KIZ_USER)@login.rz.uni-ulm.de ypcat passwd > ./ypcat-users.lst
	cat ./ypcat-users.lst \
		| awk -F ":" '{print $$5}' \
		| awk -F " " '{print $$1}' \
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

	rm ./ypcat-users.lst
	rm ./firstnames.uniq
	rm ./firstnames.lst


