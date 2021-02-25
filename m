Return-Path: <SRS0=QO3b=H3=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.7 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24D4EC433DB
	for <containers@archiver.kernel.org>; Thu, 25 Feb 2021 20:37:25 +0000 (UTC)
Received: from smtp4.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id A9D95601FB
	for <containers@archiver.kernel.org>; Thu, 25 Feb 2021 20:37:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A9D95601FB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp4.osuosl.org (Postfix) with ESMTP id 6ED924EF58;
	Thu, 25 Feb 2021 20:37:24 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp4.osuosl.org ([127.0.0.1])
	by localhost (smtp4.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id hEIxeJ_pkZnH; Thu, 25 Feb 2021 20:37:23 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp4.osuosl.org (Postfix) with ESMTP id 394B34EF57;
	Thu, 25 Feb 2021 20:37:23 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 1255EC000A;
	Thu, 25 Feb 2021 20:37:23 +0000 (UTC)
Received: from smtp3.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 99B8BC0001
 for <containers@lists.linux-foundation.org>;
 Thu, 25 Feb 2021 20:37:21 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp3.osuosl.org (Postfix) with ESMTP id 7F7A66F80E
 for <containers@lists.linux-foundation.org>;
 Thu, 25 Feb 2021 20:37:21 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp3.osuosl.org ([127.0.0.1])
 by localhost (smtp3.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id KIWCkCwGETDg
 for <containers@lists.linux-foundation.org>;
 Thu, 25 Feb 2021 20:37:20 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.8.0
Received: from raptor.unsafe.ru (raptor.unsafe.ru [5.9.43.93])
 by smtp3.osuosl.org (Postfix) with ESMTP id 85C936F48A
 for <containers@lists.linux-foundation.org>;
 Thu, 25 Feb 2021 20:37:20 +0000 (UTC)
Received: from example.org (ip-94-113-225-162.net.upcbroadband.cz
 [94.113.225.162])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits))
 (No client certificate requested)
 by raptor.unsafe.ru (Postfix) with ESMTPSA id 54A7A209D4;
 Thu, 25 Feb 2021 20:37:07 +0000 (UTC)
Date: Thu, 25 Feb 2021 21:36:57 +0100
From: Alexey Gladkov <gladkov.alexey@gmail.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: Re: d28296d248:  stress-ng.sigsegv.ops_per_sec -82.7% regression
Message-ID: <20210225203657.mjhaqnj5vszna5xw@example.org>
References: <20210224051845.GB6114@xsang-OptiPlex-9020>
 <m1czwpl83q.fsf@fess.ebiederm.org>
 <20210224183828.j6uut6sholeo2fzh@example.org>
 <m17dmxl2qa.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <m17dmxl2qa.fsf@fess.ebiederm.org>
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.6.1
 (raptor.unsafe.ru [5.9.43.93]); Thu, 25 Feb 2021 20:37:16 +0000 (UTC)
Cc: Jens Axboe <axboe@kernel.dk>, feng.tang@intel.com,
 0day robot <lkp@intel.com>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Jann Horn <jannh@google.com>, LKML <linux-kernel@vger.kernel.org>,
 Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, lkp@lists.01.org,
 kernel test robot <oliver.sang@intel.com>, ying.huang@intel.com,
 Andrew Morton <akpm@linux-foundation.org>, zhengjun.xing@intel.com,
 Linus Torvalds <torvalds@linux-foundation.org>, io-uring@vger.kernel.org,
 Kees Cook <keescook@chromium.org>
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

On Wed, Feb 24, 2021 at 12:50:21PM -0600, Eric W. Biederman wrote:
> Alexey Gladkov <gladkov.alexey@gmail.com> writes:
> 
> > On Wed, Feb 24, 2021 at 10:54:17AM -0600, Eric W. Biederman wrote:
> >> kernel test robot <oliver.sang@intel.com> writes:
> >> 
> >> > Greeting,
> >> >
> >> > FYI, we noticed a -82.7% regression of stress-ng.sigsegv.ops_per_sec due to commit:
> >> >
> >> >
> >> > commit: d28296d2484fa11e94dff65e93eb25802a443d47 ("[PATCH v7 5/7] Reimplement RLIMIT_SIGPENDING on top of ucounts")
> >> > url: https://github.com/0day-ci/linux/commits/Alexey-Gladkov/Count-rlimits-in-each-user-namespace/20210222-175836
> >> > base: https://git.kernel.org/cgit/linux/kernel/git/shuah/linux-kselftest.git next
> >> >
> >> > in testcase: stress-ng
> >> > on test machine: 48 threads Intel(R) Xeon(R) CPU E5-2697 v2 @ 2.70GHz with 112G memory
> >> > with following parameters:
> >> >
> >> > 	nr_threads: 100%
> >> > 	disk: 1HDD
> >> > 	testtime: 60s
> >> > 	class: interrupt
> >> > 	test: sigsegv
> >> > 	cpufreq_governor: performance
> >> > 	ucode: 0x42e
> >> >
> >> >
> >> > In addition to that, the commit also has significant impact on the
> >> > following tests:
> >> 
> >> Thank you.  Now we have a sense of where we need to test the performance
> >> of these changes carefully.
> >
> > One of the reasons for this is that I rolled back the patch that changed
> > the ucounts.count type to atomic_t. Now get_ucounts() is forced to use a
> > spin_lock to increase the reference count.
> 
> Which given the hickups with getting a working version seems justified.
> 
> Now we can add incremental patches on top to improve the performance.

I'm not sure that get_ucounts() should be used in __sigqueue_alloc() [1].
I tried removing it and running KASAN tests that were failing before. So
far, I have not found any problems.

[1] https://git.kernel.org/pub/scm/linux/kernel/git/legion/linux.git/tree/kernel/signal.c?h=patchset/per-userspace-rlimit/v7.1&id=2d4a2e2be7db42c95acb98abfc2a9b370ddd0604#n428

-- 
Rgrds, legion

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
