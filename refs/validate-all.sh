#/bin/bash

run_unix_cmd() {
  # $1 is the line number
  # $2 is the cmd to run
  # $3 is the expected exit code
  output=`$2 2>&1`
  exit_code=$?
  if [[ $exit_code -ne $3 ]]; then
    printf "failed (incorrect exit status code) on line $1.\n"
    printf "  - exit code: $exit_code (expected $3)\n"
    printf "  - command: $2\n"
    if [[ -z $output ]]; then
      printf "  - output: <none>\n\n"
    else
      printf "  - output: <starts on next line>\n$output\n\n"
    fi
    exit 1
  fi
}

echo "validating ietf-sztp-csr.yang..."
printf "  ^ with pyang..."
response=`pyang -p ../ --ietf -Werror --strict --canonical --max-line-length=69 ../ietf-sztp-csr\@*.yang 2>&1`
if [ $? -ne 0 ]; then
  printf "failed (error code: $?)\n"
  printf "$response\n\n"
  echo
  exit 1
fi
printf "okay.\n"
printf "  ^ with yanglint..."
response=`yanglint -p ../ ../ietf-ztp-types\@*.yang ../ietf-sztp-csr\@*.yang 2>&1`
if [ $? -ne 0 ]; then
  printf "failed (error code: $?)\n"
  printf "$response\n\n"
  echo
  exit 1
fi
printf "okay.\n\n"


# convert RESTCONF example into a NETCONF example
printf "validating ex-api-gbd-without-csr-rpc.json..."
cat ex-api-gbd-without-csr-rpc.json | sed '1,4d' | sed 's/input/get-bootstrapping-data/' > ex-api-gbd-without-csr-rpc-4nc.json
command="yanglint -t rpc -p ../ ietf-sztp-bootstrap-server\@*.yang ../ietf-ztp-types\@*.yang ../ietf-sztp-csr\@*.yang ex-api-gbd-without-csr-rpc-4nc.json"
response=`$command 2>&1`
if [ $? -ne 0 ]; then
  printf "failed (error code: $?)\n"
  printf "$response\n\n"
  echo
  rm ex-api-gbd-without-csr-rpc-4nc.json
  exit 1
fi
printf "okay.\n"

# convert RESTCONF example into a NETCONF example (requires converting YANG module also!)
printf "validating ex-api-gbd-without-csr-rpc-reply.json..."
sed -e 's/^}/uses errors { refine errors { config false; }}}/' -e "s/2017-01-26/`date +%Y-%m-%d`/" ietf-restconf\@2017-01-26.yang > ietf-restconf\@`date +%Y-%m-%d`.yang
cat ex-api-gbd-without-csr-rpc-reply.json | sed '1,5d' > ex-api-gbd-without-csr-rpc-reply-4nc.json
command="yanglint -p ../ ietf-restconf@`date +%Y-%m-%d`.yang ../ietf-ztp-types\@*.yang ../ietf-sztp-csr\@*.yang ex-api-gbd-without-csr-rpc-reply-4nc.json"
response=`$command 2>&1`
exit_code=$?
rm ex-api-gbd-without-csr-rpc-4nc.json
rm ex-api-gbd-without-csr-rpc-reply-4nc.json
rm ietf-restconf\@`date +%Y-%m-%d`.yang
if [ $exit_code -ne 0 ]; then
  printf "failed (error code: $?)\n"
  printf "$response\n\n"
  echo
  exit 1
fi
printf "okay.\n"

printf "validating ex-api-gbd-without-csr-rpc-reply.json's inner payload..."
name=`ls -1 ../ietf-sztp-csr\@*.yang | sed -e 's/\.\.\///'`
sed -e 's/sx:structure/container/' ../ietf-sztp-csr\@*.yang > $name 
command="yanglint -p ../ ../ietf-ztp-types\@*.yang $name ex-api-gbd-without-csr-rpc-reply-inner-payload.json"
response=`$command 2>&1`
exit_code=$?
rm $name
if [ $exit_code -ne 0 ]; then
  printf "failed (error code: $?)\n"
  printf "command: $command\n"
  printf "output: $response\n\n"
  echo
  exit 1
fi
printf "okay.\n"



# convert RESTCONF example into a NETCONF example
printf "validating ex-api-gbd-with-csr-rpc.json..."
cat ex-api-gbd-with-csr-rpc.json | sed '1,4d' | sed 's/input/get-bootstrapping-data/' > ex-api-gbd-with-csr-rpc-4nc.json
response=`yanglint -t rpc -p ../ ietf-sztp-bootstrap-server\@*.yang ../ietf-ztp-types\@*.yang ../ietf-sztp-csr\@*.yang ex-api-gbd-with-csr-rpc-4nc.json 2>&1`
if [ $? -ne 0 ]; then
  printf "failed (error code: $?)\n"
  printf "$response\n\n"
  echo
  rm ex-api-gbd-with-csr-rpc-4nc.json
  exit 1
fi
printf "okay.\n"

printf "validating ex-api-gbd-with-csr-rpc-reply.json..."
cat ex-api-gbd-with-csr-rpc-reply.json | sed '1,5d' | sed 's/output/get-bootstrapping-data/' > ex-api-gbd-with-csr-rpc-reply-4nc.json
response=`yanglint -t reply ietf-sztp-bootstrap-server\@*.yang ../ietf-ztp-types\@*.yang ../ietf-sztp-csr\@*.yang ex-api-gbd-with-csr-rpc-reply-4nc.json 2>&1`
exit_code=$?
rm ex-api-gbd-with-csr-rpc-4nc.json
rm ex-api-gbd-with-csr-rpc-reply-4nc.json
if [ $exit_code -ne 0 ]; then
  printf "failed (error code: $?)\n"
  printf "$response\n\n"
  echo
  exit 1
fi
printf "okay.\n"

printf "Testing refs/ex-keystore-ldevid-same-key.json..."
command="yanglint -p ../ ietf-keystore\@*.yang ietf-crypto-types\@*.yang ex-keystore-ldevid-same-key.json"
run_unix_cmd $LINENO "$command" 0
printf "okay.\n"

printf "Testing refs/ex-keystore-ldevid-new-key.json..."
command="yanglint -p ../ ietf-keystore\@*.yang ietf-crypto-types\@*.yang ex-keystore-ldevid-new-key.json"
run_unix_cmd $LINENO "$command" 0
printf "okay.\n"


echo
