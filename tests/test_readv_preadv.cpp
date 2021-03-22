/*
Copyright (C) 2021 The Falco Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

#include <gtest.h>

#include <bpf_harness/filler_test.h>
#include <arpa/inet.h>

TEST(test_readv_preadv_x, readv_double_iovec)
{
	int err;
	uint32_t off;

	char buf1[5] = "AAAA";
	char buf2[5] = "BBBB";
	struct iovec iov[] = {{
				      .iov_base = &buf1,
				      .iov_len = sizeof(buf1),
			      },
			      {
				      .iov_base = &buf2,
				      .iov_len = sizeof(buf2),
			      },
	};

	int count = 2;
	size_t retsize = 11;
	auto fe = new filler_test(PPME_SYSCALL_READV_X);

	unsigned long fd = 15;
	err = fe->do_test(retsize, fd, (unsigned long)&iov, count);
	ASSERT_EQ(err, 0);

	auto ret = (unsigned long)fe->get_retval();
	ASSERT_EQ(ret, 11);
	off = sizeof(ret);

	// this filler handles ring buffer writing via
	// bpf_parse_readv_writev_bufs
	auto size = (int)fe->get_scratch_at(off);
	ASSERT_EQ(size, 10);
	off += sizeof(size);

	char resbuf1[5];
	fe->get_scratch_at(&resbuf1, off, 5);
	ASSERT_STREQ(resbuf1, "AAAA");
	off += sizeof(resbuf1);

	char resbuf2[5];
	fe->get_scratch_at(&resbuf2, off, 5);
	ASSERT_STREQ(resbuf2, "BBBB");
}
