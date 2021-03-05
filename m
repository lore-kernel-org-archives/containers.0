Return-Path: <SRS0=8Shw=ID=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0FE2AC433E0
	for <containers@archiver.kernel.org>; Fri,  5 Mar 2021 17:56:54 +0000 (UTC)
Received: from smtp4.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 4C5C5650A5
	for <containers@archiver.kernel.org>; Fri,  5 Mar 2021 17:56:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C5C5650A5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=xmission.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp4.osuosl.org (Postfix) with ESMTP id 066F54AAFC;
	Fri,  5 Mar 2021 17:56:53 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp4.osuosl.org ([127.0.0.1])
	by localhost (smtp4.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Th_M4Z-eTSCU; Fri,  5 Mar 2021 17:56:52 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp4.osuosl.org (Postfix) with ESMTP id B6C7F4A053;
	Fri,  5 Mar 2021 17:56:51 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 87F62C000A;
	Fri,  5 Mar 2021 17:56:51 +0000 (UTC)
Received: from smtp1.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id A7711C0001
 for <containers@lists.linux-foundation.org>;
 Fri,  5 Mar 2021 17:56:50 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp1.osuosl.org (Postfix) with ESMTP id 95B6383D83
 for <containers@lists.linux-foundation.org>;
 Fri,  5 Mar 2021 17:56:50 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp1.osuosl.org ([127.0.0.1])
 by localhost (smtp1.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id a1ngiYVQxN9c
 for <containers@lists.linux-foundation.org>;
 Fri,  5 Mar 2021 17:56:49 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.8.0
Received: from out01.mta.xmission.com (out01.mta.xmission.com [166.70.13.231])
 by smtp1.osuosl.org (Postfix) with ESMTPS id 90F4F83D80
 for <containers@lists.linux-foundation.org>;
 Fri,  5 Mar 2021 17:56:49 +0000 (UTC)
Received: from in02.mta.xmission.com ([166.70.13.52])
 by out01.mta.xmission.com with esmtps (TLS1.3) tls
 TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384 (Exim 4.93)
 (envelope-from <ebiederm@xmission.com>)
 id 1lIEgu-004e9i-VG; Fri, 05 Mar 2021 10:56:45 -0700
Received: from ip68-227-160-95.om.om.cox.net ([68.227.160.95]
 helo=fess.xmission.com)
 by in02.mta.xmission.com with esmtpsa (TLS1.3) tls
 TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384 (Exim 4.93)
 (envelope-from <ebiederm@xmission.com>)
 id 1lIEgt-004li8-IX; Fri, 05 Mar 2021 10:56:44 -0700
From: ebiederm@xmission.com (Eric W. Biederman)
To: Alexey Gladkov <gladkov.alexey@gmail.com>
References: <20210224051845.GB6114@xsang-OptiPlex-9020>
 <m1czwpl83q.fsf@fess.ebiederm.org>
 <20210224183828.j6uut6sholeo2fzh@example.org>
 <m17dmxl2qa.fsf@fess.ebiederm.org>
 <20210225203657.mjhaqnj5vszna5xw@example.org>
Date: Fri, 05 Mar 2021 11:56:44 -0600
In-Reply-To: <20210225203657.mjhaqnj5vszna5xw@example.org> (Alexey Gladkov's
 message of "Thu, 25 Feb 2021 21:36:57 +0100")
Message-ID: <m1czwd32n7.fsf@fess.ebiederm.org>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
X-XM-SPF: eid=1lIEgt-004li8-IX; ; ; mid=<m1czwd32n7.fsf@fess.ebiederm.org>; ; ;
 hst=in02.mta.xmission.com; ; ; ip=68.227.160.95; ; ; frm=ebiederm@xmission.com;
 ; ; spf=neutral
X-XM-AID: U2FsdGVkX1+QpJmPwGjQCYsOz8d21ibu8x9BhUmL7YA=
X-SA-Exim-Connect-IP: 68.227.160.95
X-SA-Exim-Mail-From: ebiederm@xmission.com
Subject: Re: d28296d248:  stress-ng.sigsegv.ops_per_sec -82.7% regression
X-SA-Exim-Version: 4.2.1 (built Sat, 08 Feb 2020 21:53:50 +0000)
X-SA-Exim-Scanned: Yes (on in02.mta.xmission.com)
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

Alexey Gladkov <gladkov.alexey@gmail.com> writes:

> On Wed, Feb 24, 2021 at 12:50:21PM -0600, Eric W. Biederman wrote:
>> Alexey Gladkov <gladkov.alexey@gmail.com> writes:
>> 
>> > On Wed, Feb 24, 2021 at 10:54:17AM -0600, Eric W. Biederman wrote:
>> >> kernel test robot <oliver.sang@intel.com> writes:
>> >> 
>> >> > Greeting,
>> >> >
>> >> > FYI, we noticed a -82.7% regression of stress-ng.sigsegv.ops_per_sec due to commit:
>> >> >
>> >> >
>> >> > commit: d28296d2484fa11e94dff65e93eb25802a443d47 ("[PATCH v7 5/7] Reimplement RLIMIT_SIGPENDING on top of ucounts")
>> >> > url: https://github.com/0day-ci/linux/commits/Alexey-Gladkov/Count-rlimits-in-each-user-namespace/20210222-175836
>> >> > base: https://git.kernel.org/cgit/linux/kernel/git/shuah/linux-kselftest.git next
>> >> >
>> >> > in testcase: stress-ng
>> >> > on test machine: 48 threads Intel(R) Xeon(R) CPU E5-2697 v2 @ 2.70GHz with 112G memory
>> >> > with following parameters:
>> >> >
>> >> > 	nr_threads: 100%
>> >> > 	disk: 1HDD
>> >> > 	testtime: 60s
>> >> > 	class: interrupt
>> >> > 	test: sigsegv
>> >> > 	cpufreq_governor: performance
>> >> > 	ucode: 0x42e
>> >> >
>> >> >
>> >> > In addition to that, the commit also has significant impact on the
>> >> > following tests:
>> >> 
>> >> Thank you.  Now we have a sense of where we need to test the performance
>> >> of these changes carefully.
>> >
>> > One of the reasons for this is that I rolled back the patch that changed
>> > the ucounts.count type to atomic_t. Now get_ucounts() is forced to use a
>> > spin_lock to increase the reference count.
>> 
>> Which given the hickups with getting a working version seems justified.
>> 
>> Now we can add incremental patches on top to improve the performance.
>
> I'm not sure that get_ucounts() should be used in __sigqueue_alloc() [1].
> I tried removing it and running KASAN tests that were failing before. So
> far, I have not found any problems.
>
> [1]
> https://git.kernel.org/pub/scm/linux/kernel/git/legion/linux.git/tree/kernel/signal.c?h=patchset/per-userspace-rlimit/v7.1&id=2d4a2e2be7db42c95acb98abfc2a9b370ddd0604#n428

Hmm.  The code you posted still seems to include the get_ucounts.

I like the idea of not needing to increment and decrement the ucount
reference count every time a signal is sent, unfortunately there is a
problem.  The way we have implemented setresuid allows different threads
in a threaded application to have different cred->user values.

That is actually an extension of what posix supports and pthreads will
keep the creds of a process in sync.  Still I recall looking into this a
few years ago and there were a few applications that take advantage of
the linux behavior.

In principle I think it is possible to hold a ucount reference in
somewhere such as task->signal.  In practice there are enough
complicating factors I don't immediately see how to implement that.

If the creds were stored in signal_struct instead of in task_struct
we could simply move the sigpending counts in set_user, when the uid
of a process changed.

With the current state I don't know how to pick which is the real user.

Eric
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
