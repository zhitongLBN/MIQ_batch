# MIQ_batch
Execute this scripts in your ManageIQ folder. It will enable your MIQ's openstack use *ovh*

To do a refresh manuelally, open rails console, then:
> ovh = ExtManagementSystem.find x
>
> EmsRefresh.refresh(ovh)

Tested for MIQ branch master commit 6e158f7b91424a73696724324e515b33bdd747b7

For older MIQ before please use branch `miq-80d04b`
(until master commit 80d04b2779e09162fba71337b43479f7a87d78c1)

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
