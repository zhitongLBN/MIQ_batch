# MIQ_batch
Execute this scripts in your ManageIQ folder. It will enable your MIQ's openstack use *ovh SBG1*

To do a refresh manuelally, open rails console, then:
> ovh = ExtManagementSystem.find x

> EmsRefresh.refresh(ovh)
