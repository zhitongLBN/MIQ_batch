# MIQ_batch
Execute this scripts in your ManageIQ folder. It will enable your MIQ's openstack use *ovh SBG1*

To do a refresh manuelally, open rails console, then:
> ovh = ExtManagementSystem.find x
>
> EmsRefresh.refresh(ovh)

Tested for MIQ branch master commit 6cb1d21f8b3301321c88a6e00fcdb58035187abc

Tested for MIQ branch master commit 9d92be7774b77ef954843a27a1b7dbfa5a3c97f9

Tested for MIQ branch master commit 80d04b2779e09162fba71337b43479f7a87d78c1

## HOW TO CHANGE REGION
open patch_openstack_ovh_SBG1.sh

find these lines

```
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# Change the region here, for OVH it can be: SBG1, BHS1, GRA1
line2="        opts[:openstack_region] = 'SBG1'"
#                                         ^^^^
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
```

change `'SBG1'` to whatever you like!!!

OVH support now `SBG1`, `BHS1`, `GRA1`

## HOW TO USE
> cd /var/www/miq/

download if there is no MIQ_batch/ present

> git clone https://github.com/zhitongLBN/MIQ_batch.git

else update it

> cd MIQ_batch
>
> git fetch -p --all
>
> git rebase origin/master

execute it

> cp /var/www/miq/MIQ_batch/patch_openstack_ovh_SBG1.sh /var/www/miq/vmdb/
>
> cd /var/www/miq/vmdb/
>
> ./patch_openstack_ovh_SBG1.sh

## AFTER
Please reboot the evm service on the MIQ server to make the patch work

> cd /var/www/miq/vmdb/
>
> bundle exec rake evm:restart

# Done GG WP
