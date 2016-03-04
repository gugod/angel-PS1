#!/bin/bash

if [[ ! -x angel-PS1 ]]; then
	echo "./angel-PS1 not found!"
	exit 1
fi

final="$PWD/demo.out"

umask 0077

if command -v mktemp >/dev/null ; then
	tmp="$(mktemp -d)"
else
	tmp="${TMPDIR:-/tmp}/tmp.$$.$TIME"
	mkdir "$tmp"
fi
trap "rm -Rf '$tmp'" EXIT

ln -s "$PWD" "$tmp/angel-PS1"
out="$tmp/out"

touch "$tmp/.bash_profile" "$tmp/.bashrc"
cat <<'EOF' >> "$tmp/.bash_profile"
PS1='\u:\w\$ '
EOF

unset PS1
HOME="$tmp"
cd ~/angel-PS1 ; script -q -e -c 'bash -l' "$out" <<'EOF' >/dev/null
echo ; stty echo
echo "'$PS1'"
# == Load angel-PS1 with default prompt =====
eval $(./angel-PS1)
# == Let's play with jobs
sleep 1 &
sleep 1 &
kill -STOP %2
kill %1
fg %2
# == Go back temporarly to the non-angel PS1
angel off
angel on
# == Unload
angel quit
#
# == Load angel-PS1 with Powerline-basic.PS1
# (requires install of Powerline fonts)
eval $(./angel-PS1 -c examples/Powerline-basic.PS1)
set | grep ^APS1
ps
angel quit
set | grep ^APS1
#
# == Load angel-PS1 with 2lines.PS1
eval $(./angel-PS1 -c examples/2lines.PS1)
# This is a static prompt
echo $PROMPT_COMMAND
printf '%q\n' "$PS1"
exit
EOF

while [[ ! -s "$out" ]]
do
	sleep 1
done

(
echo -------------------------------------------------------------------------------
cat "$out"
echo -------------------------------------------------------------------------------
) | tee "$final"
