#!/bin/bash

git reset --hard HEAD

refresh_parser='app/models/manageiq/providers/openstack/cloud_manager/refresh_parser.rb'
refresh_parser_line_to_comment=(
  '      @orchestration_service      = @os_handle.detect_orchestration_service'
  '      get_availability_zones'
  '      load_orchestration_stacks'
)

for line in "${refresh_parser_line_to_comment[@]}"
do
  sed -i "s/$line/# $line/g" $refresh_parser
done

openstack_handler='gems/pending/openstack/openstack_handle/handle.rb'
aim_line=":openstack_endpoint_type => 'publicURL',"
line_to_append="        :openstack_region => 'SBG1'"
sed -i "s/$aim_line/$aim_line\n$line_to_append/g" $openstack_handler
