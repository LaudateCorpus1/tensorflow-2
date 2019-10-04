#!/bin/bash
set -e
# reference: https://git.archlinux.org/svntogit/community.git/tree/trunk/PKGBUILD?h=packages/tensorflow
# reference: https://github.com/gentoo/gentoo/blob/master/sci-libs/tensorflow/tensorflow-2.0.0.ebuild

export PYTHON_BIN_PATH=/usr/bin/python3
export USE_DEFAULT_PYTHON_LIB_PATH=1
export TF_NEED_JEMALLOC=0
export TF_NEED_KAFKA=0
export TF_NEED_OPENCL_SYCL=0
export TF_NEED_AWS=0
export TF_NEED_GCP=0
export TF_NEED_HDFS=0
export TF_NEED_S3=0
export TF_ENABLE_XLA=0
export TF_NEED_GDR=0
export TF_NEED_VERBS=0
export TF_NEED_OPENCL=0
export TF_NEED_MPI=0
export TF_NEED_TENSORRT=0
export TF_NEED_NGRAPH=0
export TF_NEED_IGNITE=0
export TF_NEED_ROCM=0
export TF_SET_ANDROID_WORKSPACE=0
export TF_DOWNLOAD_CLANG=0
export TF_IGNORE_MAX_BAZEL_VERSION=1

cat > .tf_configure.bazelrc <<EOF
build --action_env PYTHON_BIN_PATH="/usr/bin/python3"
build --action_env PYTHON_LIB_PATH="/usr/lib/python3.7/dist-packages"
build --python_path="/usr/bin/python3"
build:xla --define with_xla_support=false
build --config=xla
build:opt --copt=-march=native
build:opt --copt=-Wno-sign-compare
build:opt --host_copt=-march=native
build:opt --define with_default_optimizations=true
test --flaky_test_attempts=3
test --test_size_filters=small,medium
test --test_tag_filters=-benchmark-test,-no_oss,-oss_serial
test --build_tag_filters=-benchmark-test,-no_oss
test --test_tag_filters=-gpu
test --build_tag_filters=-gpu
build --action_env TF_CONFIGURE_IOS="0"
EOF

cat > tools/python_bin_path.sh <<EOF
export PYTHON_BIN_PATH="/usr/bin/python3"
EOF

LOGDIR=debian/buildlogs/
if ! test -r $LOGDIR/libtensorflow_framework.so.log; then
	bazel clean
	bazel build --config=v2 //tensorflow:libtensorflow_framework.so -s 2>&1 | tee $LOGDIR/libtensorflow_framework.so.log
fi
if ! test -r $LOGDIR/libtensorflow.so.log; then
	bazel clean
	bazel build --config=v2 //tensorflow:libtensorflow.so -s 2>&1 | tee $LOGDIR/libtensorflow.so.log
fi
if ! test -r $LOGDIR/libtensorflow_cc.so.log; then
	bazel clean
	bazel build --config=v2 //tensorflow:libtensorflow_cc.so -s 2>&1 | tee $LOGDIR/libtensorflow_cc.so.log
fi
if ! test -r $LOGDIR/install_headers.log; then
	bazel clean
	bazel build --config=v2 //tensorflow:install_headers 
	find bazel-bin/tensorflow/include > $LOGDIR/install_headers.log
fi