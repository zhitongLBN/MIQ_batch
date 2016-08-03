#!/bin/bash

git reset --hard HEAD

# comment service not exist in ovh
refresh_parser='app/models/manageiq/providers/openstack/cloud_manager/refresh_parser.rb'
refresh_parser_line_to_comment=(
  '      @orchestration_service      = @os_handle.detect_orchestration_service'
  '      get_availability_zones'
  '      load_orchestration_stacks'
  '      get_cloud_services'
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

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# Change the region here, for OVH it can be: SBG1, BHS1, GRA1
line2="        opts[:openstack_region] = 'SBG1'"
#                                         ^^^^
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

line3="      end"
sed -i "s/$aim_line/$aim_line\n$line1\n$line2\n$line3/g" $openstack_handler

# disable test_conntection for amqp for ovh
ampq_event_monitor='gems/pending/openstack/events/openstack_rabbit_event_monitor.rb'
aim_line='      connection.start'
line_if_amqp='      unless options[:hostname].include? "cloud.ovh.net"'
line_end_amqp='      end'
sed -i "s/$aim_line/$line_if_amqp\n  $aim_line\n$line_end_amqp/g" $ampq_event_monitor

# use identity_v2 for ovh
openstack_identity_delegate='gems/pending/openstack/openstack_handle/identity_delegate.rb'
aim_line='    def visible_tenants$'
line_to_add="      if @os_handle.address.include? \"cloud.ovh.net\"
        opts = {
          :provider                => 'OpenStack',
          :openstack_auth_url      => 'https://' + @os_handle.address + '/v2.0/tokens',
          :openstack_username      => @os_handle.username,
          :openstack_api_key       => @os_handle.password,
          :openstack_endpoint_type => 'publicURL',
          :openstack_region        => 'SBG1'
        }
        Fog::Identity::OpenStack::V2.new(opts)
        return visible_tenants_v2
      end
"

echo "$line_to_add" > miq_patch_tmp_text
sed -i "/$aim_line/r miq_patch_tmp_text" $openstack_identity_delegate
rm miq_patch_tmp_text

# get public network address of ovh vm
# should be delete if this is solved
# https://github.com/fog/fog-openstack/issues/39
refresh_parser='app/models/manageiq/providers/openstack/cloud_manager/refresh_parser.rb'
aim_line='      public_network  = {:ipaddress => server.public_ip_address}.delete_nils'

line_to_add="      if @os_handle.address.include? \"cloud.ovh.net\"
        begin
          public_network = {:ipaddress => [server.addresses['Ext-Net'][0]['addr']]}
        rescue
          \$fog_log.warning(\"server: #{id} has no ip address\")
        end
      end
"

echo "$line_to_add" > miq_patch_tmp_text
sed -i "/$aim_line/r miq_patch_tmp_text" $refresh_parser
rm miq_patch_tmp_text

cloudmanager_vm='app/models/manageiq/providers/cloud_manager/vm.rb'
aim_line='    @ipaddresses ||= network_ports.collect(&:ipaddresses).flatten.compact.uniq'

line_to_add="    @ipaddresses = hardware.networks.collect(&:ipaddress).compact.uniq if @ipaddress.nil? || @ipaddresses.empty?"

echo "$line_to_add" > miq_patch_tmp_text
sed -i "/$aim_line/r miq_patch_tmp_text" $cloudmanager_vm
rm miq_patch_tmp_text
