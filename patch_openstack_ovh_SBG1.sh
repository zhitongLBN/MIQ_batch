#!/bin/bash

git reset --hard HEAD

# comment service not exist in ovh
refresh_parser='app/models/manageiq/providers/openstack/cloud_manager/refresh_parser.rb'
refresh_parser_line_to_comment=(
  '      @orchestration_service      = @os_handle.detect_orchestration_service'
  '      get_availability_zones'
  '      load_orchestration_stacks'
)
line_if='      unless @os_handle.address.include? "cloud.ovh.net"'
line_end='      end'
for line in "${refresh_parser_line_to_comment[@]}"
do
  sed -i "s/$line/$line_if\n\ \ $line\n$line_end/g" $refresh_parser
done

# add hard code region
openstack_handler='gems/pending/openstack/openstack_handle/handle.rb'
aim_line="      opts.merge!(extra_opts) if extra_opts"
line1="      if auth_url\.include\? \"cloud\.ovh\.net\""
line2="        opts[:openstack_region] = 'SBG1'"
line3="      end"
sed -i "s/$aim_line/$aim_line\n$line1\n$line2\n$line3/g" $openstack_handler

# disable test_conntection for amqp for ovh
ampq_event_monitor='gems/pending/openstack/events/openstack_rabbit_event_monitor.rb'
aim_line='      connection.start'
line_if_amqp='      unless options[:hostname].include? "cloud.ovh.net"'
line_end_amqp='      end'
sed -i "s/$aim_line/$line_if_amqp\n  $aim_line\n$line_end_amqp/g" $ampq_event_monitor
