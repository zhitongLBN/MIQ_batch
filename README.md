# MIQ_batch
Execute this scripts in your ManageIQ folder. It will enable your MIQ's openstack to use provider *ovh*

To do a refresh provider manuelally, open rails console, then:
> ovh = ExtManagementSystem.find x
>
> EmsRefresh.refresh(ovh)


## About MIQ's version

Tested for MIQ branch master commit 99d8fcd43a1ee798f7fcea418a350bf2474d11ce -> Dec 5, 2016 (tag euwe-1)

For old miq please check your version on this url:

https://github.com/ManageIQ/manageiq/commits/{commit-number}

then compare the commit date, use the branch which is the first less then your miq-version date

> if your miq has a version with commit date Oct 2016, then use branch `miq-6e158f`
>
> as Sep 4 2016 is the first less then Oct 2016

use branch `miq-6e158f` (tested for miq commit 6e158f7b91424a73696724324e515b33bdd747b7) -> Sep 4, 2016

use branch `miq-80d04b` (tested for miq commit 80d04b2779e09162fba71337b43479f7a87d78c1) -> Apr 28, 2016

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

# Done GG WPj
