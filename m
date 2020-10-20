Return-Path: <SRS0=SoaA=D3=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A3A5C4363A
	for <containers@archiver.kernel.org>; Tue, 20 Oct 2020 14:32:20 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id A8C9922251
	for <containers@archiver.kernel.org>; Tue, 20 Oct 2020 14:32:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A8C9922251
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 0DE2886C28;
	Tue, 20 Oct 2020 14:32:19 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 8hGPFoPQ-96g; Tue, 20 Oct 2020 14:32:18 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 6023186BFE;
	Tue, 20 Oct 2020 14:32:18 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 52563C088B;
	Tue, 20 Oct 2020 14:32:18 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id A78EDC0051
 for <containers@lists.linux-foundation.org>;
 Tue, 20 Oct 2020 14:32:16 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 825D020449
 for <containers@lists.linux-foundation.org>;
 Tue, 20 Oct 2020 14:32:16 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 6WrORrs3ytXC
 for <containers@lists.linux-foundation.org>;
 Tue, 20 Oct 2020 14:32:15 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by silver.osuosl.org (Postfix) with ESMTPS id 11A2A2041F
 for <containers@lists.linux-foundation.org>;
 Tue, 20 Oct 2020 14:32:14 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1kUsgN-0000qz-BC; Tue, 20 Oct 2020 14:32:11 +0000
Date: Tue, 20 Oct 2020 16:32:10 +0200
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Giuseppe Scrivano <gscrivan@redhat.com>
Subject: Re: [PATCH v2 2/2] selftests: add tests for CLOSE_RANGE_CLOEXEC
Message-ID: <20201020143210.uwwdinaj45iom4oi@wittgenstein>
References: <20201019102654.16642-1-gscrivan@redhat.com>
 <20201019102654.16642-3-gscrivan@redhat.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20201019102654.16642-3-gscrivan@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org,
 linux@rasmusvillemoes.dk, linux-kernel@vger.kernel.org,
 viro@zeniv.linux.org.uk
X-BeenThere: containers@lists.linux-foundation.org
X-Mailman-Version: 2.1.15
Precedence: list
List-Id: Linux Containers <containers.lists.linuxfoundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>, 
 <mailto:containers-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers@lists.linux-foundation.org>
List-Help: <mailto:containers-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>, 
 <mailto:containers-request@lists.linux-foundation.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

First, thank you for the selftests. That's great to see!

Could you please add a short explanation what you're testing here to the
commit message?

On Mon, Oct 19, 2020 at 12:26:54PM +0200, Giuseppe Scrivano wrote:
> Signed-off-by: Giuseppe Scrivano <gscrivan@redhat.com>
> ---
>  .../testing/selftests/core/close_range_test.c | 74 +++++++++++++++++++
>  1 file changed, 74 insertions(+)
> 
> diff --git a/tools/testing/selftests/core/close_range_test.c b/tools/testing/selftests/core/close_range_test.c
> index c99b98b0d461..c9db282158bb 100644
> --- a/tools/testing/selftests/core/close_range_test.c
> +++ b/tools/testing/selftests/core/close_range_test.c
> @@ -11,6 +11,7 @@
>  #include <string.h>
>  #include <syscall.h>
>  #include <unistd.h>
> +#include <sys/resource.h>
>  
>  #include "../kselftest_harness.h"
>  #include "../clone3/clone3_selftests.h"
> @@ -23,6 +24,10 @@
>  #define CLOSE_RANGE_UNSHARE	(1U << 1)
>  #endif
>  
> +#ifndef CLOSE_RANGE_CLOEXEC
> +#define CLOSE_RANGE_CLOEXEC	(1U << 2)
> +#endif
> +
>  static inline int sys_close_range(unsigned int fd, unsigned int max_fd,
>  				  unsigned int flags)
>  {
> @@ -224,4 +229,73 @@ TEST(close_range_unshare_capped)
>  	EXPECT_EQ(0, WEXITSTATUS(status));
>  }
>  
> +TEST(close_range_cloexec)
> +{
> +	int i, ret;
> +	int open_fds[101];
> +	struct rlimit rlimit;
> +
> +	for (i = 0; i < ARRAY_SIZE(open_fds); i++) {
> +		int fd;
> +
> +		fd = open("/dev/null", O_RDONLY);
> +		ASSERT_GE(fd, 0) {
> +			if (errno == ENOENT)
> +				XFAIL(return, "Skipping test since /dev/null does not exist");
> +		}
> +
> +		open_fds[i] = fd;
> +	}
> +
> +	ret = sys_close_range(1000, 1000, CLOSE_RANGE_CLOEXEC);
> +	if (ret < 0) {
> +		if (errno == ENOSYS)
> +			XFAIL(return, "close_range() syscall not supported");
> +		if (errno == EINVAL)
> +			XFAIL(return, "close_range() doesn't support CLOSE_RANGE_CLOEXEC");
> +	}
> +
> +	/* Ensure the FD_CLOEXEC bit is set also with a resource limit in place.  */
> +	EXPECT_EQ(0, getrlimit(RLIMIT_NOFILE, &rlimit));
> +	rlimit.rlim_cur = 25;
> +	EXPECT_EQ(0, setrlimit(RLIMIT_NOFILE, &rlimit));

I usually prefer to call ASSERT_* to abort at the first true failure
before moving on. And I think all the EXPECT_*()s here should be
ASSERT_*()s because that are all hard failures imho.

Apart from that this looks good.

> +
> +	/* Set close-on-exec for two ranges: [0-50] and [75-100].  */
> +	ret = sys_close_range(open_fds[0], open_fds[50], CLOSE_RANGE_CLOEXEC);
> +	EXPECT_EQ(0, ret);
> +	ret = sys_close_range(open_fds[75], open_fds[100], CLOSE_RANGE_CLOEXEC);
> +	EXPECT_EQ(0, ret);
> +
> +	for (i = 0; i <= 50; i++) {
> +		int flags = fcntl(open_fds[i], F_GETFD);
> +
> +		EXPECT_GT(flags, -1);
> +		EXPECT_EQ(flags & FD_CLOEXEC, FD_CLOEXEC);
> +	}
> +
> +	for (i = 51; i <= 74; i++) {
> +		int flags = fcntl(open_fds[i], F_GETFD);
> +
> +		EXPECT_GT(flags, -1);
> +		EXPECT_EQ(flags & FD_CLOEXEC, 0);
> +	}
> +
> +	for (i = 75; i <= 100; i++) {
> +		int flags = fcntl(open_fds[i], F_GETFD);
> +
> +		EXPECT_GT(flags, -1);
> +		EXPECT_EQ(flags & FD_CLOEXEC, FD_CLOEXEC);
> +	}
> +
> +	/* Test a common pattern.  */
> +	ret = sys_close_range(3, UINT_MAX, CLOSE_RANGE_CLOEXEC);
> +	for (i = 0; i <= 100; i++) {
> +		int flags = fcntl(open_fds[i], F_GETFD);
> +
> +		EXPECT_GT(flags, -1);
> +		EXPECT_EQ(flags & FD_CLOEXEC, FD_CLOEXEC);
> +	}
> +}
> +
> +
>  TEST_HARNESS_MAIN
> -- 
> 2.26.2
> 
> _______________________________________________
> Containers mailing list
> Containers@lists.linux-foundation.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
