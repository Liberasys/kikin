#!/bin/bash

readarray -t service_list < <(systemctl list-units -t service --no-pager --no-legend | awk -F'.service ' '{print $1}')
service_number=${#service_list[@]}

output=""
output+="{\n"
output+="\"data\":[\n"

i=0
while [ $i -lt $(($service_number - 1)) ] ; do
  service=${service_list[$i]}
  output+="{\n"
  output+="\"{#SERVICE}\": \"$service\"\n"
  output+="},\n"
  i=$((i+1))
done

service=${service_list[$i]}
output+="{\n"
output+="\"{#SERVICE}\": \"$service\"\n"
output+="}\n"
output+="]\n"
output+="}\n"

echo -ne $output

