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

TEST(test_connect_x, af_inet_connect)
{
	int err;
	uint32_t off;

	auto fe = new filler_test(PPME_SOCKET_CONNECT_X);

	struct sockaddr_in saddr = {
		.sin_family = AF_INET,
		.sin_port = 1234,
		.sin_addr = {
			.s_addr = inet_addr("10.11.12.13"),
		},
	};

	socklen_t slen = sizeof(saddr);

	err = fe->do_test_with_tmp_scratch(0, 5, (unsigned long)&saddr, slen);
	ASSERT_EQ(err, 0);

	auto ret = (unsigned long)fe->get_retval();
	ASSERT_EQ(ret, 0);
	off = sizeof(ret);

	// the connect filler does not provide
	// direct access to the arguments since they aren't there
	// We can however do assertions from tmp_scratch

	struct sockaddr_in *faddr = (struct sockaddr_in *)fe->get_tmp_scratch();
	ASSERT_EQ(faddr->sin_family, AF_INET);
	ASSERT_EQ(faddr->sin_port, 1234);
	ASSERT_EQ(faddr->sin_addr.s_addr, inet_addr("10.11.12.13"));
}
