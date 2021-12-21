echo "Generating tree diagrams..."

# print just the augment tree (yanglint's output is less cluttered)
pyang -f tree --tree-line-length 69 --tree-print-structures -p ../ ../ietf-sztp-csr\@*.yang > ietf-sztp-csr-tree.txt
pyang -f tree --tree-line-length 69 --tree-print-groupings ../ietf-ztp-types\@*.yang > ietf-ztp-types-tree.txt

# print the get-bootstrapping-data rpc + augments
pyang -p ../ -f tree --tree-path /get-bootstrapping-data ietf-sztp-bootstrap-server\@*.yang ../ietf-sztp-csr\@*.yang > ietf-sztp-api-n-csr-tree.txt 
sed 's/reporting-level?        /reporting-level?    /' ietf-sztp-api-n-csr-tree.txt > tmp;
mv tmp ietf-sztp-api-n-csr-tree.txt

# print rpc-errors + structure (ensure "sztp-csr:" prefix appears)
sed -e 's/prefix sztp-csr;/prefix sztp-csr; import ietf-restconf { prefix rc; }/' -e 's#sx:structure csr-request {#augment "/rc:errors/rc:error/rc:error-info" { container csr-request {#' -e 's/uses zt:csr-request-grouping;/uses zt:csr-request-grouping; }/' ../ietf-sztp-csr\@*.yang > ietf-sztp-csr.yang
sed -e "s/2017-01-26/`date +%Y-%m-%d`/" -e 's/anydata error-info {/container error-info {/' -e 's/^}/uses errors { refine errors { config false; }}}/' ietf-restconf\@2017-01-26.yang > ietf-restconf\@`date +%Y-%m-%d`.yang
cp ../ietf-ztp-types\@*.yang .
pyang -f tree --tree-path /errors ietf-restconf\@`date +%Y-%m-%d`.yang ietf-sztp-csr.yang | ghead -n -5  > ietf-sztp-csr-errors-n-struct-tree.txt
#rm ietf-sztp-csr.yang
#rm ietf-ztp-types\@*.yang




