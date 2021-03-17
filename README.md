# Falco BPF driver harness

Note: I will propose this for incubation into falcosecurity/bpf-harness. This is a
temporary home until the proposal gets evaluated.


## Purpose

This test suite is intended to be used as a way to execute the probe on multiple kernels without having to rely on the
libraries and the upper elements in our stack. It's often very difficult to verify if our code here is correct by just
executing the probe against Falco, Falco tests or by using the libraries.

This test suite also serves the purpose of being an helper to those who want to write a new program (a very common one
would be a filler) to be added to our probe.

## Requirements

- kernel built with the `CONFIG_DEBUG_INFO_BTF=y` option;
- this can be checked by verifying if this file is present `/sys/kernel/btf/vmlinux`


## How to test a filler

In general, we create a file for every program we want to test. The naming convention
is `test_<name>.cpp`, tests files are locaed in the `tests/` folder.

**Nota bene**: At the moment of writing, only tests for fillers are supported out of the box, reach out
to the maintainers if you need to write a test for something that's not a filler.

Once you have the file, you can create your test case like this:

The code here is annotated with comments that helps in understanding what is going on.


```cpp
#include <gtest.h>

#include <bpf_harness/filler_test.h>

// The TEST macro here comes from the Google Test framework.
// This is how you declare that this is a test, its name and 'basic' is the type of test you are writing
TEST(test_renameat2, basic)
{
	int err;
	uint32_t off;

	// prepare the program to execute a filler program for the renameat2 syscall (PPME_SYSCALL_RENAMEAT2_X)
	auto fe = new filler_executor(PPME_SYSCALL_RENAMEAT2_X);
	// execute the test with custom arguments.
	// The first argument is the return value and arguments from 0 to 5 can be passed.
	err = fe->do_test(110, -100, (unsigned long)"oldpath", -100, (unsigned long)"newpath");
	
	// assertion that the test program loading was successful
	ASSERT_EQ(err, 0);

	// get the return value after executing the filler and do assertions on it
	auto ret = (unsigned long)fe->get_retval();
	ASSERT_EQ(ret, 110);
	// increment the offset so that we can extract the subsequent values
	// from the memory buffer
	off = sizeof(ret); 

	// get the value of the first argument and do assertions on it
	auto olddirfd = (long)fe->get_argument(off);
	ASSERT_EQ(olddirfd, -100);
	// increment the offset again, this was a long so a sizeof will do again
	off += sizeof(olddirfd);

	// get the value of the second argument and do assertions on its value
	char oldpath[PPM_MAX_PATH_SIZE];
	fe->get_argument(&oldpath, off, PPM_MAX_PATH_SIZE);
	ASSERT_STREQ(oldpath, "oldpath");
	// this time we can't increment the offset using sizeof because this was
	// a null terminated string, get the lenght and add 1 for the \0
	off += strlen(oldpath) + 1;

	// and so on
	auto newdirfd = (long)fe->get_argument(off);
	ASSERT_EQ(newdirfd, -100);
	off += sizeof(newdirfd);

	char newpath[PPM_MAX_PATH_SIZE];
	fe->get_argument(&newpath, off, PPM_MAX_PATH_SIZE);
	ASSERT_STREQ(newpath, "newpath");
}
```

## How to execute tests

The tests here are integrated in our CMake build.

You can build them as follows:

```bash
$ mkdir build
$ cd build
$ cmake ..
$ make runner
```

If you want to see debug information both from the loader and from the probe (bpf_printk) you can do so by
enabling the debug build with the CMake option `-DBPF_TEST_DEBUG=True`.

Now, before executing the test, you will need an actual bpf probe object `probe.o` to test against.

You can compile the probe with:

```bash
$ git clone https://github.com/falcosecurity/libs.git ~/libs
$ cd libs
$ mkdir build
$ cmake -DBUILD_BPF=True ..
$ make bpf
```

Now you can execute the tests with (requires root privileges):

```bash
# ./build/tests/runner -p ~/libs/driver/bpf/probe.o
```
