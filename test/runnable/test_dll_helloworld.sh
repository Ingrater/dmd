#!/usr/bin/env bash

dir=${RESULTS_DIR}/runnable
dmddir=${RESULTS_DIR}${SEP}runnable
output_file=${dir}/test_dll_helloworld.sh.out

rm -f ${output_file}

if [ "${OS}" != "win64" ]; then
    echo "Skipping dll helloworld test on ${OS}."
    touch ${output_file}
    exit 0
fi

die()
{
	echo "test_dll_helloworld failed!"
    cat ${output_file}
    rm -f ${output_file}
    exit 1
}


$DMD -m${MODEL} -of${dmddir}/test_dll_helloworld.exe runnable/extra-files/test_dll_helloworld.d -defaultlib=phobos${MODEL}s > ${output_file}
if [ $? -ne 0 ]; then die; fi

cat ${output_file} | grep "warning LNK" -q
if [ $? -ne 1 ]; then
	echo "Test failed due to linker warning!"
	die
fi

desired="Hello D World!"

result=`${dmddir}/test_dll_helloworld${EXE} | tr -d '\r'` # need to remove \r from '\r\n' in output to match
if [ $? -ne 0 ]; then die; fi
echo "$result" >> ${output_file}

if [ "$desired" = "$result" ]; then
    exit 0
else
    echo "*** Error: got above but was expecting:" >> ${output_file}
    echo "$desired" >> ${output_file}
    die
fi