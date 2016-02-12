#!/usr/bin/env bash

dir=${RESULTS_DIR}/runnable
dmddir=${RESULTS_DIR}${SEP}runnable
output_file=${dir}/test_dll_fixup.sh.out

rm -f ${output_file}

if [ "${OS}" != "win64" ]; then
    echo "Skipping dll fixup test on ${OS}."
    touch ${output_file}
    exit 0
fi

die()
{
    cat ${output_file}
    rm -f ${output_file}
    exit 1
}

$DMD -m${MODEL} -of${dmddir}/test_dll_fixup_a.dll runnable/imports/test_dll_fixup_a.d -shared -useshared -betterC -defaultlib="msvcrt" \
    -L/IMPLIB:${dmddir}/test_dll_fixup_a.lib >> ${output_file}
if [ $? -ne 0 ]; then die; fi


$DMD -m${MODEL} -of${dmddir}/test_dll_fixup${EXE} runnable/extra-files/test_dll_fixup.d -useshared -betterC -defaultlib="msvcrt" \
    -Irunnable/imports ${dmddir}/test_dll_fixup_a.lib >> ${output_file}
if [ $? -ne 0 ]; then die; fi

${dmddir}/test_dll_fixup${EXE} >> ${output_file}
if [ $? -ne 0 ]; then die; fi


