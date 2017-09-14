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
network_refresh_parser='app/models/manageiq/providers/openstack/network_manager/refresh_parser.rb'
cinder_refresh_parser='app/models/manageiq/providers/storage_manager/cinder_manager/refresh_parser.rb'
swift_refresh_parser='app/models/manageiq/providers/storage_manager/swift_manager/refresh_parser.rb'

git reset app/models/manageiq/providers
git checkout $refresh_parser $cloud_manager $ampq_event_monitor $cloudmanager_vm $manager_mixin
git checkout $network_namager_refresher $storage_namager_cinder_refresher $storage_namager_swift_refresher $event_catcher
git checkout $network_refresh_parser $cinder_refresh_parser $swift_refresh_parser

git apply ../MIQ_batch/patch_diff
