#!/bin/bash

# A supplimentary command as a tool used in TPS repositories
# Kian Mirjalali, Hamed Saleh
# IOI 2017, Iran


tps_version=1.0



set -e

function errcho {
	>&2 echo "$@"
}



__tps_target_file__="problem.json"

#looking for ${__tps_target_file__} in current and parent directories...
__tps_curr__="$PWD"
while [ "${__tps_curr__}" != "${__tps_prev__}" ] ; do
	if [ -f "${__tps_curr__}/${__tps_target_file__}" ] ; then
		base_dir="${__tps_curr__}"
		break
	fi
	__tps_prev__="${__tps_curr__}"
	__tps_curr__="$(dirname "${__tps_curr__}")"
done



__scripts__="scripts"
__scripts_dir__="${base_dir}/${__scripts__}"


function __tps_list_commands__ {
	ls -a -1 "${__scripts_dir__}" 2>/dev/null | grep -E ".\\.(sh|py|exe)$" | while read f; do echo ${f%.*} ; done
}

function __tps_unify_elements__ {
	_sort=$(which -a "sort" | grep -iv "windows" | head -1)
	if [ -z "${_sort}" ] ; then
		_sort="cat"
	fi
	_uniq="uniq"
#	if which "uniq" >/dev/null 2>&1 ; then
#		_uniq="uniq"
#	elif which "unique" >/dev/null 2>&1 ; then
#		_uniq="unique"
#	else
#		_uniq="cat"
#	fi
	${_sort} | ${_uniq}
}

function __tps_help__ {
	echo "TPS version ${tps_version}"
	echo ""
	echo "Usage: tps <command> <arguments>..."
	echo ""
	if [ -z "${base_dir+x}" ]; then
		echo "Currently not in a TPS repository ('${__tps_target_file__}' not found in any of the parent directories)."
	elif [ ! -d "${__scripts_dir__}" ] ; then
		echo "Directory '${__scripts__}' is not available."
	elif [ -z "$(__tps_list_commands__)" ] ; then
		echo "No commands available in '${__scripts__}'."
	else
		echo "Available commands:"
		__tps_list_commands__ | __tps_unify_elements__
	fi
	exit 1
}


[ $# -gt 0 ] || __tps_help__
__tps_command__="$1"; shift


if [ "${__tps_command__}" == "--bash-completion" ] ; then
	if [ ! -z "${base_dir+x}" -a -d "${__scripts_dir__}" ]; then
		__tps_list_commands__
	fi
	exit 0
fi


if [ -z "${base_dir+x}" ]; then
	errcho "Error: Not in a TPS repository ('${__tps_target_file__}' not found in any of the parent directories)"
	exit 2
fi

export base_dir



if [ ! -d "${__scripts_dir__}" ] ; then
	errcho "Error: Directory '${__scripts__}' not found."
	exit 2
fi

__tps_init__="${__scripts__}/internal/tps_init.sh"
__tps_init_file__="${base_dir}/${__tps_init__}"

if [ ! -f "${__tps_init_file__}" ] ; then
	errcho "Error: File '${__tps_init__}' not found."
	exit 2
fi

source "${__tps_init_file__}"

if [ -f "${__scripts_dir__}/${__tps_command__}.sh" ]; then
	bash "${__scripts_dir__}/${__tps_command__}.sh" "$@"
elif [ -f "${__scripts_dir__}/${__tps_command__}.py" ]; then
	python "${__scripts_dir__}/${__tps_command__}.py" "$@"
elif [ -f "${__scripts_dir__}/${__tps_command__}.exe" ]; then
	"${__scripts_dir__}/${__tps_command__}.exe" "$@"
else
	errcho "Error: command '${__tps_command__}' not found in '${__scripts__}'".
	errcho "Searched for '${__tps_command__}.sh', '${__tps_command__}.py', '${__tps_command__}.exe'."
	exit 2
fi

