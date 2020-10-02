printf "\nUsing: "
yanglint -v

printf "\nTEST 1: Manually adding 'config false' statement:\n"
sed -e 's/container errors {/container errors { config false;/' -e 's/^}/uses errors;}/' -e "s/2017-01-26/`date +%Y-%m-%d`/" ietf-restconf\@2017-01-26.yang > ietf-restconf\@`date +%Y-%m-%d`.yang
yanglint -s ietf-restconf@`date +%Y-%m-%d`.yang
printf "Done.\n"

printf "\nTEST 2: Using a 'refine' statement:\n"
sed -e 's/^}/uses errors { refine errors { config false; }}}/' -e "s/2017-01-26/`date +%Y-%m-%d`/" ietf-restconf\@2017-01-26.yang > ietf-restconf\@`date +%Y-%m-%d`.yang
yanglint -s ietf-restconf@`date +%Y-%m-%d`.yang
printf "Done.\n\n"


