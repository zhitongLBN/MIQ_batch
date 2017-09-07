#!/bin/bash

# List of files
refresh_parser='app/models/manageiq/providers/openstack/cloud_manager/refresh_parser.rb'
cloud_manager='app/models/manageiq/providers/openstack/cloud_manager.rb'
# ampq_event_monitor='gems/pending/openstack/events/openstack_rabbit_event_monitor.rb'
cloudmanager_vm='app/models/manageiq/providers/cloud_manager/vm.rb'
manager_mixin='app/models/manageiq/providers/openstack/manager_mixin.rb'

network_namager_refresher='app/models/manageiq/providers/openstack/network_manager/refresher.rb'
storage_namager_cinder_refresher='app/models/manageiq/providers/storage_manager/cinder_manager/refresher.rb'
storage_namager_swift_refresher='app/models/manageiq/providers/storage_manager/swift_manager/refresher.rb'
event_catcher='app/models/manageiq/providers/openstack/event_catcher_mixin.rb'

git checkout $refresh_parser $cloud_manager $ampq_event_monitor $cloudmanager_vm $manager_mixin
git checkout $network_namager_refresher $storage_namager_cinder_refresher $storage_namager_swift_refresher $event_catcher

# comment service not exist in ovh
# in $refresh_parser
refresh_parser_line_to_comment=(
  '      @orchestration_service      = @os_handle.detect_orchestration_service'
  '      @network_service            = @os_handle.detect_network_service'
  '      @nfv_service                = @os_handle.detect_nfv_service'
  '      @image_service              = @os_handle.detect_image_service'
  '      @volume_service             = @os_handle.detect_volume_service'
  '      @storage_service            = @os_handle.detect_storage_service'
  '      @identity_service           = @os_handle.identity_service'
  '      get_availability_zones'
  '      load_orchestration_stacks'
  '      get_host_aggregates'
  '      get_cloud_services'
)
line_if='      unless @os_handle.address.include? "cloud.ovh.net"'
line_end='      end'
for line in "${refresh_parser_line_to_comment[@]}"
do
  if [ ! -e "$refresh_parser" ]; then
    echo "$refresh_parser not exist"
  else
    sed -i "s/$line/$line_if\n\ \ $line\n$line_end/g" $refresh_parser
  fi
done

# disable test_conntection for amqp for ovh
# in $ampq_event_monitor
# aim_line='      connection.start'
# line_if_amqp='      unless options[:hostname].include? "cloud.ovh.net"'
# line_end_amqp='      end'

# if [ ! -e "$ampq_event_monitor" ]; then
#   echo "$ampq_event_monitor not exist"
# else
#   sed -i "s/$aim_line/$line_if_amqp\n  $aim_line\n$line_end_amqp/g" $ampq_event_monitor
# fi

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

if [ ! -e "$cloud_manager" ]; then
  echo "$cloud_manager not exist"
else
  sed -i "s/$aim_line/$aim_line\n$line_to_add/" $cloud_manager
fi

# disable cinder and swift support for ovh
# in $cloud_manager
aim_line='  def supports_cinder_service?'
line_to_add='    return false if hostname.include? "cloud.ovh.net"'

if [ ! -e "$cloud_manager" ]; then
  echo "$cloud_manager not exist"
else
  sed -i "s/$aim_line/$aim_line\n$line_to_add/" $cloud_manager
fi

aim_line='  def supports_swift_service?'
line_to_add='    return false if hostname.include? "cloud.ovh.net"'

if [ ! -e "$cloud_manager" ]; then
  echo "$cloud_manager not exist"
else
  sed -i "s/$aim_line/$aim_line\n$line_to_add/" $cloud_manager
fi


# modify the way to get ip from ovh
# in $cloudmanager_vm
aim_line='    @ipaddresses ||= network_ports.collect(&:ipaddresses).flatten.compact.uniq'
line_to_add="    @ipaddresses = hardware.networks.collect(&:ipaddress).compact.uniq if @ipaddress.nil? || @ipaddresses.empty?"

echo "$line_to_add" > miq_patch_tmp_text

if [ ! -e "$cloudmanager_vm" ]; then
  echo "$cloudmanager_vm not exist"
else
  sed -i "/$aim_line/r miq_patch_tmp_text" $cloudmanager_vm
fi
rm miq_patch_tmp_text

# make changes in $manager_mixin

if [ ! -e "$manager_mixin" ]; then
  echo "$manager_mixin not exist"
else
  # disable meter event monitor for ovh
  aim_line='  OpenstackEventMonitor.available?(event_monitor_options)'
  line_to_add='  return false if hostname.include? "cloud.ovh.net"'
  sed -i "s/$aim_line/$line_to_add\n  $aim_line/g" $manager_mixin

  # disable sync_event for ovh
  aim_line='  def sync_event_monitor_available?'
  line_to_add='  return false if hostname.include? "cloud.ovh.net"'
  sed -i "s/$aim_line/$aim_line\n  $line_to_add/g" $manager_mixin

  # replace verify use Identify instead of Compute
  aim_line='    options\[:service\] = "Compute"'
  line_to_replace='    options[:service] = "Identity"'
  sed -i "s/$aim_line/$line_to_replace/g" $manager_mixin
fi

# disable parse_legacy_inventory
refresher_files=(
  $network_namager_refresher
  $storage_namager_cinder_refresher
  $storage_namager_swift_refresher
)
aim_line='    def parse_legacy_inventory(ems)'
line_to_add='      return if ems.hostname.include? "cloud.ovh.net"'
for refresher_f in "${refresher_files[@]}"
do
  if [ ! -e "$refresher_f" ]; then
    echo "$refresher_f not exist"
  else
    sed -i "s/$aim_line/$aim_line\n$line_to_add/g" $refresher_f
  fi
done

# make changes in $event_catcher
# disable event_monitor of openstack event catcher
if [ ! -e "$event_catcher" ]; then
  echo "$event_catcher not exist"
else
  aim_line="    require 'openstack\/openstack_event_monitor'"
  line_to_add='    return if @ems.hostname.include? "cloud.ovh.net"'
  sed -i "s/$aim_line/$aim_line\n$line_to_add/g" $event_catcher

  aim_line='  def monitor_events'
  line_to_add='    return if @ems.hostname.include? "cloud.ovh.net"'
  sed -i "s/$aim_line/$aim_line\n$line_to_add/g" $event_catcher
fi
