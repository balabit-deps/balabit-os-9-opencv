#!/bin/bash
set -e
debian_dir="$(dirname "$0")"
[ -z "$debian_dir" ] || cd "$debian_dir"
old_sover="$(grep "^Package: libopencv-core[0-9]" control | cut -c24-)"
new_sover="${1:?need new soversion as parameter}"
[[ "$new_sover" = [0-9]* ]] || (echo>&2 "soversion must start with a digit"; exit 1)
if [[ "$old_sover" = "$new_sover" ]]
then
	echo nothing to be done: $old_sover == $new_sover
	exit 0
fi
packages=(
	$(grep "^Package: lib" control | grep -F "${old_sover}" | cut -c10-)
)
for old_pkg in "${packages[@]}"
do
	new_pkg="${old_pkg/${old_sover}/${new_sover}}"
	sed_args+=("-e" "s/${old_pkg/./\\.}/${new_pkg}/")
	for old_f in ${old_pkg}.*
	do
		new_f="${old_f/${old_sover}/${new_sover}}"
		mv -v "$old_f" "$new_f"
	done
done
sed -i "${sed_args[@]}" control

