#!/bin/bash

jsonname=addons.json
aws eks describe-addon-versions > ${jsonname}
cat $(jsonname) | jq '.addons[] |.addonName + " " + "-----" + " " + .addonVersions[].addonVersion' > result.txt
uniq result.txt
#cat -n result.txt | sort -uk2,2 | sort -nk1,1 | cut -f2