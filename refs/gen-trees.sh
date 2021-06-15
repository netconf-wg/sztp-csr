echo "Generating tree diagrams..."

# print just the augment tree (yanglint's output is less cluttered)
pyang -f tree ../ietf-sztp-csr\@*.yang > ietf-sztp-csr-tree.txt 

# append the sx:structure to the module tree (requires script-fu!)
name=`ls -1 ../ietf-sztp-csr\@*.yang`
mv $name $name.sav
sed -e 's/sx:structure/container/' -e 's/request-info {/request-info { config false;/' $name.sav > $name
echo "" >> ietf-sztp-csr-tree.txt
yanglint -f tree --tree-path /request-info $name | sed -e '/module/d' -e 's/+--ro request-info/structure: request-info/' >> ietf-sztp-csr-tree.txt
mv $name.sav $name

# print the get-bootstrapping-data rpc + augments
pyang -f tree --tree-path /get-bootstrapping-data ietf-sztp-bootstrap-server\@*.yang ../ietf-sztp-csr\@*.yang > ietf-sztp-api-n-csr-tree.txt 
sed 's/reporting-level?        /reporting-level?    /' ietf-sztp-api-n-csr-tree.txt > tmp;
mv tmp ietf-sztp-api-n-csr-tree.txt

# print rpc-errors + structure
sed -e 's/sx:structure/grouping g { container/' -e 's/^}/}}/' ../ietf-sztp-csr\@*.yang > ietf-sztp-csr.yang
sed -e 's/prefix "rc";/prefix "rc"; import ietf-sztp-csr { prefix sztp-csr;}/' -e "s/2017-01-26/`date +%Y-%m-%d`/" -e 's/anydata error-info {/container error-info { uses sztp-csr:g;/' -e 's/^}/uses errors { refine errors { config false; }}}/' ietf-restconf\@2017-01-26.yang > ietf-restconf\@`date +%Y-%m-%d`.yang
pyang -f tree --tree-path /errors ietf-restconf\@`date +%Y-%m-%d`.yang > ietf-sztp-csr-errors-n-struct-tree.txt
rm ietf-sztp-csr.yang



