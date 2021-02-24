Return-Path: <SRS0=nBW1=H2=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17137C433DB
	for <containers@archiver.kernel.org>; Wed, 24 Feb 2021 18:50:49 +0000 (UTC)
Received: from smtp4.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 63E8F60241
	for <containers@archiver.kernel.org>; Wed, 24 Feb 2021 18:50:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 63E8F60241
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=xmission.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp4.osuosl.org (Postfix) with ESMTP id EE3CC4ECFB;
	Wed, 24 Feb 2021 18:50:47 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp4.osuosl.org ([127.0.0.1])
	by localhost (smtp4.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ESSharb_dKKh; Wed, 24 Feb 2021 18:50:46 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp4.osuosl.org (Postfix) with ESMTP id A77004ECD9;
	Wed, 24 Feb 2021 18:50:46 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 80722C000A;
	Wed, 24 Feb 2021 18:50:46 +0000 (UTC)
Received: from smtp4.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 6F8A2C0001
 for <containers@lists.linux-foundation.org>;
 Wed, 24 Feb 2021 18:50:45 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp4.osuosl.org (Postfix) with ESMTP id 590554ECFB
 for <containers@lists.linux-foundation.org>;
 Wed, 24 Feb 2021 18:50:45 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp4.osuosl.org ([127.0.0.1])
 by localhost (smtp4.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 9TOoofiAeOL5
 for <containers@lists.linux-foundation.org>;
 Wed, 24 Feb 2021 18:50:43 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.8.0
Received: from out03.mta.xmission.com (out03.mta.xmission.com [166.70.13.233])
 by smtp4.osuosl.org (Postfix) with ESMTPS id 587794ECD9
 for <containers@lists.linux-foundation.org>;
 Wed, 24 Feb 2021 18:50:43 +0000 (UTC)
Received: from in01.mta.xmission.com ([166.70.13.51])
 by out03.mta.xmission.com with esmtps (TLS1.2) tls
 TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256 (Exim 4.93)
 (envelope-from <ebiederm@xmission.com>)
 id 1lEzF9-00BE5k-Cx; Wed, 24 Feb 2021 11:50:39 -0700
Received: from ip68-227-160-95.om.om.cox.net ([68.227.160.95]
 helo=fess.xmission.com) by in01.mta.xmission.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_256_GCM_SHA384:256) (Exim 4.87)
 (envelope-from <ebiederm@xmission.com>)
 id 1lEzF8-0003fV-Ej; Wed, 24 Feb 2021 11:50:39 -0700
From: ebiederm@xmission.com (Eric W. Biederman)
To: Alexey Gladkov <gladkov.alexey@gmail.com>
References: <20210224051845.GB6114@xsang-OptiPlex-9020>
 <m1czwpl83q.fsf@fess.ebiederm.org>
 <20210224183828.j6uut6sholeo2fzh@example.org>
Date: Wed, 24 Feb 2021 12:50:21 -0600
In-Reply-To: <20210224183828.j6uut6sholeo2fzh@example.org> (Alexey Gladkov's
 message of "Wed, 24 Feb 2021 19:38:28 +0100")
Message-ID: <m17dmxl2qa.fsf@fess.ebiederm.org>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
X-XM-SPF: eid=1lEzF8-0003fV-Ej; ; ; mid=<m17dmxl2qa.fsf@fess.ebiederm.org>; ; ;
 hst=in01.mta.xmission.com; ; ; ip=68.227.160.95; ; ; frm=ebiederm@xmission.com;
 ; ; spf=neutral
X-XM-AID: U2FsdGVkX19uDlW3DrHDIu/oovVJEMOIV0VkW2WC9Yw=
X-SA-Exim-Connect-IP: 68.227.160.95
X-SA-Exim-Mail-From: ebiederm@xmission.com
Subject: Re: d28296d248:  stress-ng.sigsegv.ops_per_sec -82.7% regression
X-SA-Exim-Version: 4.2.1 (built Thu, 05 May 2016 13:38:54 -0600)
X-SA-Exim-Scanned: Yes (on in01.mta.xmission.com)
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

> On Wed, Feb 24, 2021 at 10:54:17AM -0600, Eric W. Biederman wrote:
>> kernel test robot <oliver.sang@intel.com> writes:
>> 
>> > Greeting,
>> >
>> > FYI, we noticed a -82.7% regression of stress-ng.sigsegv.ops_per_sec due to commit:
>> >
>> >
>> > commit: d28296d2484fa11e94dff65e93eb25802a443d47 ("[PATCH v7 5/7] Reimplement RLIMIT_SIGPENDING on top of ucounts")
>> > url: https://github.com/0day-ci/linux/commits/Alexey-Gladkov/Count-rlimits-in-each-user-namespace/20210222-175836
>> > base: https://git.kernel.org/cgit/linux/kernel/git/shuah/linux-kselftest.git next
>> >
>> > in testcase: stress-ng
>> > on test machine: 48 threads Intel(R) Xeon(R) CPU E5-2697 v2 @ 2.70GHz with 112G memory
>> > with following parameters:
>> >
>> > 	nr_threads: 100%
>> > 	disk: 1HDD
>> > 	testtime: 60s
>> > 	class: interrupt
>> > 	test: sigsegv
>> > 	cpufreq_governor: performance
>> > 	ucode: 0x42e
>> >
>> >
>> > In addition to that, the commit also has significant impact on the
>> > following tests:
>> 
>> Thank you.  Now we have a sense of where we need to test the performance
>> of these changes carefully.
>
> One of the reasons for this is that I rolled back the patch that changed
> the ucounts.count type to atomic_t. Now get_ucounts() is forced to use a
> spin_lock to increase the reference count.

Which given the hickups with getting a working version seems justified.

Now we can add incremental patches on top to improve the performance.


Eric

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
