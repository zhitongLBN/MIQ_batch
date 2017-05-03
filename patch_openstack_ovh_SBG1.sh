#!/bin/bash

# List of files
refresh_parser='app/models/manageiq/providers/openstack/cloud_manager/refresh_parser.rb'
cloud_manager='app/models/manageiq/providers/openstack/cloud_manager.rb'
ampq_event_monitor='gems/pending/openstack/events/openstack_rabbit_event_monitor.rb'
cloudmanager_vm='app/models/manageiq/providers/cloud_manager/vm.rb'
manager_mixin='app/models/manageiq/providers/openstack/manager_mixin.rb'

git checkout $refresh_parser $cloud_manager $ampq_event_monitor $cloudmanager_vm $manager_mixin

# comment service not exist in ovh
# in $refresh_parser
refresh_parser_line_to_comment=(
  '      @orchestration_service      = @os_handle.detect_orchestration_service'
  '      @nfv_service                = @os_handle.detect_nfv_service'
  '      get_availability_zones'
  '      load_orchestration_stacks'
  '      get_host_aggregates'
  '      get_cloud_services'
)
line_if='      unless @os_handle.address.include? "cloud.ovh.net"'
line_end='      end'
for line in "${refresh_parser_line_to_comment[@]}"
do
  sed -i "s/$line/$line_if\n\ \ $line\n$line_end/g" $refresh_parser
done

# disable test_conntection for amqp for ovh
# in $ampq_event_monitor
aim_line='      connection.start'
line_if_amqp='      unless options[:hostname].include? "cloud.ovh.net"'
line_end_amqp='      end'
sed -i "s/$aim_line/$line_if_amqp\n  $aim_line\n$line_end_amqp/g" $ampq_event_monitor

# get public network address of ovh vm
# should be delete if this is solved
# https://github.com/fog/fog-openstack/issues/39
# in $refresh_parser
aim_line='      public_network  = {:ipaddress => server.public_ip_address}.delete_nils'

line_to_add="      if @os_handle.address.include? \"cloud.ovh.net\"
        begin
          public_network = {:ipaddress => server.addresses.values.flatten.map{ |net| net['addr'] }}
        rescue
          \$fog_log.warn(\"server: #{server.id} has no ip address\")
        end
      end
"

echo "$line_to_add" > miq_patch_tmp_text
sed -i "/$aim_line/r miq_patch_tmp_text" $refresh_parser
rm miq_patch_tmp_text

# disable uniqueness hostname for ovh
# in $cloud_manager
aim_line='    return unless hostname.present? # Presence is checked elsewhere'
line_to_add='    return if hostname.include? "cloud.ovh.net"'
sed -i "s/$aim_line/$aim_line\n$line_to_add/" $cloud_manager

# modify the way to get ip from ovh
# in $cloudmanager_vm
aim_line='    @ipaddresses ||= network_ports.collect(&:ipaddresses).flatten.compact.uniq'
line_to_add="    @ipaddresses = hardware.networks.collect(&:ipaddress).compact.uniq if @ipaddress.nil? || @ipaddresses.empty?"

echo "$line_to_add" > miq_patch_tmp_text
sed -i "/$aim_line/r miq_patch_tmp_text" $cloudmanager_vm
rm miq_patch_tmp_text

# disable meter event monitor for ovh
# in $manager_mixin
aim_line='  OpenstackEventMonitor.available?(event_monitor_options)'
line_to_add='  return false if hostname.include? "cloud.ovh.net"'
sed -i "s/$aim_line/$line_to_add\n  $aim_line/g" $manager_mixin
