#!/bin/bash
echo "AvdList: $(emulator -list-avds)
"

echo "Choose Android AVD to cold-boot:"

avdList="$(emulator -list-avds | grep -v INFO)"

select avd in $avdList;
do
  if [ -n "$avd" ]
  then
    echo "Cold-booting AVD '$avd'"
    emulator @$avd -no-snapshot-load -writable-system
    break
  else
    echo "Unknown option: '$REPLY'"
  fi
done