Return-Path: <SRS0=gu3k=GX=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EBA90C433DB
	for <containers@archiver.kernel.org>; Wed, 20 Jan 2021 02:00:03 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 6358021D79
	for <containers@archiver.kernel.org>; Wed, 20 Jan 2021 02:00:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6358021D79
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=xmission.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 80C522043D;
	Wed, 20 Jan 2021 02:00:02 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id AiAcdmB569iA; Wed, 20 Jan 2021 02:00:00 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 4FF6220425;
	Wed, 20 Jan 2021 02:00:00 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 3CB5FC088B;
	Wed, 20 Jan 2021 02:00:00 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id B0A78C013A
 for <containers@lists.linux-foundation.org>;
 Wed, 20 Jan 2021 01:59:58 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 9CA4E86489
 for <containers@lists.linux-foundation.org>;
 Wed, 20 Jan 2021 01:59:58 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id ChhttY3ed4qq
 for <containers@lists.linux-foundation.org>;
 Wed, 20 Jan 2021 01:59:57 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from out01.mta.xmission.com (out01.mta.xmission.com [166.70.13.231])
 by whitealder.osuosl.org (Postfix) with ESMTPS id D9E1C86416
 for <containers@lists.linux-foundation.org>;
 Wed, 20 Jan 2021 01:59:57 +0000 (UTC)
Received: from in02.mta.xmission.com ([166.70.13.52])
 by out01.mta.xmission.com with esmtps (TLS1.3) tls
 TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384 (Exim 4.93)
 (envelope-from <ebiederm@xmission.com>)
 id 1l22mp-0092wV-9L; Tue, 19 Jan 2021 18:59:55 -0700
Received: from ip68-227-160-95.om.om.cox.net ([68.227.160.95]
 helo=x220.xmission.com)
 by in02.mta.xmission.com with esmtpsa (TLS1.3) tls
 TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384 (Exim 4.93)
 (envelope-from <ebiederm@xmission.com>)
 id 1l22mo-00B0pL-8x; Tue, 19 Jan 2021 18:59:54 -0700
From: ebiederm@xmission.com (Eric W. Biederman)
To: Alexey Gladkov <gladkov.alexey@gmail.com>
References: <cover.1610722473.git.gladkov.alexey@gmail.com>
 <116c7669744404364651e3b380db2d82bb23f983.1610722473.git.gladkov.alexey@gmail.com>
 <CAHk-=wjsg0Lgf1Mh2UiJE4sqBDDo0VhFVBUbhed47ot2CQQwfQ@mail.gmail.com>
 <20210118194551.h2hrwof7b3q5vgoi@example.org>
 <CAHk-=wiNpc5BS2BfZhdDqofJx1G=uasBa2Q1eY4cr8O59Rev2A@mail.gmail.com>
 <20210118205629.zro2qkd3ut42bpyq@example.org>
 <87eeig74kv.fsf@x220.int.ebiederm.org>
Date: Tue, 19 Jan 2021 19:58:44 -0600
In-Reply-To: <87eeig74kv.fsf@x220.int.ebiederm.org> (Eric W. Biederman's
 message of "Tue, 19 Jan 2021 19:57:36 -0600")
Message-ID: <878s8o74iz.fsf@x220.int.ebiederm.org>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
X-XM-SPF: eid=1l22mo-00B0pL-8x; ; ; mid=<878s8o74iz.fsf@x220.int.ebiederm.org>;
 ; ; hst=in02.mta.xmission.com; ; ; ip=68.227.160.95; ; ;
 frm=ebiederm@xmission.com; ; ; spf=neutral
X-XM-AID: U2FsdGVkX1/T2B95TMqxtikO/3YyPpBrhK2ILrwugMw=
X-SA-Exim-Connect-IP: 68.227.160.95
X-SA-Exim-Mail-From: ebiederm@xmission.com
Subject: Re: [RFC PATCH v3 1/8] Use refcount_t for ucounts reference counting
X-SA-Exim-Version: 4.2.1 (built Sat, 08 Feb 2020 21:53:50 +0000)
X-SA-Exim-Scanned: Yes (on in02.mta.xmission.com)
Cc: Jens Axboe <axboe@kernel.dk>, Kees Cook <keescook@chromium.org>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Jann Horn <jannh@google.com>, LKML <linux-kernel@vger.kernel.org>,
 Oleg Nesterov <oleg@redhat.com>, Linux-MM <linux-mm@kvack.org>,
 Andrew Morton <akpm@linux-foundation.org>,
 Linus Torvalds <torvalds@linux-foundation.org>,
 io-uring <io-uring@vger.kernel.org>
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

ebiederm@xmission.com (Eric W. Biederman) writes:

> Alexey Gladkov <gladkov.alexey@gmail.com> writes:
>
>> On Mon, Jan 18, 2021 at 12:34:29PM -0800, Linus Torvalds wrote:
>>> On Mon, Jan 18, 2021 at 11:46 AM Alexey Gladkov
>>> <gladkov.alexey@gmail.com> wrote:
>>> >
>>> > Sorry about that. I thought that this code is not needed when switching
>>> > from int to refcount_t. I was wrong.
>>> 
>>> Well, you _may_ be right. I personally didn't check how the return
>>> value is used.
>>> 
>>> I only reacted to "it certainly _may_ be used, and there is absolutely
>>> no comment anywhere about why it wouldn't matter".
>>
>> I have not found examples where checked the overflow after calling
>> refcount_inc/refcount_add.
>>
>> For example in kernel/fork.c:2298 :
>>
>>    current->signal->nr_threads++;                           
>>    atomic_inc(&current->signal->live);                      
>>    refcount_inc(&current->signal->sigcnt);  
>>
>> $ semind search signal_struct.sigcnt
>> def include/linux/sched/signal.h:83  		refcount_t		sigcnt;
>> m-- kernel/fork.c:723 put_signal_struct 		if (refcount_dec_and_test(&sig->sigcnt))
>> m-- kernel/fork.c:1571 copy_signal 		refcount_set(&sig->sigcnt, 1);
>> m-- kernel/fork.c:2298 copy_process 				refcount_inc(&current->signal->sigcnt);
>>
>> It seems to me that the only way is to use __refcount_inc and then compare
>> the old value with REFCOUNT_MAX
>>
>> Since I have not seen examples of such checks, I thought that this is
>> acceptable. Sorry once again. I have not tried to hide these changes.
>
> The current ucount code does check for overflow and fails the increment
> in every case.
>
> So arguably it will be a regression and inferior error handling behavior
> if the code switches to the ``better'' refcount_t data structure.
>
> I originally didn't use refcount_t because silently saturating and not
> bothering to handle the error makes me uncomfortable.
>
> Not having to acquire the ucounts_lock every time seems nice.  Perhaps
> the path forward would be to start with stupid/correct code that always
> takes the ucounts_lock for every increment of ucounts->count, that is
> later replaced with something more optimal.
>
> Not impacting performance in the non-namespace cases and having good
> performance in the other cases is a fundamental requirement of merging
> code like this.

So starting with something easy to comprehend and simple, may make it
easier to figure out how to optimize the code.

Eric

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
