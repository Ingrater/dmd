#!/usr/bin/env bash

dir=${RESULTS_DIR}/runnable
dmddir=${RESULTS_DIR}${SEP}runnable
output_file=${dir}/test_dll_interface.sh.out

rm -f ${output_file}


if [ "${OS}" != "win64" ]; then
    echo "Skipping dll interface test on ${OS}."
    touch ${output_file}
    exit 0
fi

die()
{
    cat ${output_file}
    rm -f ${output_file}
    exit 1
}

$DMD -m${MODEL} -of${dmddir}/test_dll_interface_c.dll runnable/imports/test_dll_interface_c.d -shared -useshared >> ${output_file}
if [ $? -ne 0 ]; then die; fi

$DMD -m${MODEL} -of${dmddir}/test_dll_interface_a.dll runnable/imports/test_dll_interface_a.d runnable/imports/test_dll_interface_a2.d -shared -useshared \
    -Irunnable/imports -L/IMPLIB:${dmddir}/test_dll_interface_a.lib  >> ${output_file}
if [ $? -ne 0 ]; then die; fi

$DMD -m${MODEL} -of${dmddir}/test_dll_interface_b.dll runnable/imports/test_dll_interface_b.d -shared -useshared \
    -Irunnable/imports ${dmddir}/test_dll_interface_a.lib >> ${output_file}
if [ $? -ne 0 ]; then die; fi

$DMD -m${MODEL} -of${dmddir}/test_dll_interface${EXE} runnable/extra-files/test_dll_interface.d -useshared \
    -Irunnable/imports ${dmddir}/test_dll_interface_b.lib ${dmddir}/test_dll_interface_a.lib >> ${output_file}
if [ $? -ne 0 ]; then die; fi

${dmddir}/test_dll_interface${EXE} >> ${output_file}
if [ $? -ne 0 ]; then die; fi
