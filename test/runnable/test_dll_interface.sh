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
    echo "test_dll_interface failed!"
    exit 1
}

$DMD -m${MODEL} -of${dmddir}/test_dll_interface_d.lib runnable/imports/test_dll_interface_d.d -lib -defaultlib=phobos${MODEL}s >> ${output_file}
if [ $? -ne 0 ]; then die; fi

$DMD -m${MODEL} -of${dmddir}/test_dll_interface_c.dll runnable/imports/test_dll_interface_c.d -shared >> ${output_file}
if [ $? -ne 0 ]; then die; fi

$DMD -m${MODEL} -of${dmddir}/test_dll_interface_a.dll runnable/imports/test_dll_interface_a.d runnable/imports/test_dll_interface_a2.d -shared \
    -Irunnable/imports  ${dmddir}/test_dll_interface_d.lib -L/IMPLIB:${dmddir}/test_dll_interface_a.lib >> ${output_file}
if [ $? -ne 0 ]; then die; fi

$DMD -m${MODEL} -of${dmddir}/test_dll_interface_b.dll runnable/imports/test_dll_interface_b.d -shared \
    -import=test_dll_interface_a -Irunnable/imports ${dmddir}/test_dll_interface_a.lib >> ${output_file}
if [ $? -ne 0 ]; then die; fi

$DMD -m${MODEL} -of${dmddir}/test_dll_interface${EXE} runnable/extra-files/test_dll_interface.d \
    -import=test_dll_interface_a -import=test_dll_interface_b \
    -Irunnable/imports ${dmddir}/test_dll_interface_a.lib ${dmddir}/test_dll_interface_b.lib >> ${output_file}
if [ $? -ne 0 ]; then die; fi

${dmddir}/test_dll_interface${EXE} >> ${output_file}
if [ $? -ne 0 ]; then die; fi
