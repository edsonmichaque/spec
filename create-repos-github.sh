for i in docs python go java js ruby rust perl net c spec swift dart cli api; do gh repo create $1/$2-$i --private --add-readme --license Apache-2.0; done
