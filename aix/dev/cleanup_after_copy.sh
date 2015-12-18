#!/usr/bin/env sh

cd ~/prep_rte_area/opt/salt
rm -fR rpmbuild
find ~/prep_rte_area -name "*.pyc" -print | xargs rm -f
find ~/prep_rte_area -name "*.pyo" -print | xargs rm -f
rm -fR ~/prep_rte_area/opt/salt/man/mann
rm -fR ~/prep_rte_area/opt/salt/man/man3
rm -fR ~/prep_rte_area/opt/salt/man/man5
rm -fR ~/prep_rte_area/opt/salt/man/man8
rm -fR ~/prep_rte_area/opt/salt/man/ru*
rm -fR ~/prep_rte_area/opt/salt/man/pl*
rm -fR ~/prep_rte_area/opt/salt/man/ja*
rm -fR ~/prep_rte_area/opt/salt/man/it*
rm -fR ~/prep_rte_area/opt/salt/man/fr*

cd ~/prep_rte_area
../dev/create-wrappers.aix61.sh -y
rm -f *.log
cd ~/

