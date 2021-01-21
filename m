Return-Path: <SRS0=Ull0=GY=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B99F3C433E0
	for <containers@archiver.kernel.org>; Thu, 21 Jan 2021 12:05:13 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 17F642395A
	for <containers@archiver.kernel.org>; Thu, 21 Jan 2021 12:05:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 17F642395A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 739078624A;
	Thu, 21 Jan 2021 12:05:12 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id QtqC-Inf_O_r; Thu, 21 Jan 2021 12:05:11 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id D5BE2861F1;
	Thu, 21 Jan 2021 12:05:11 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id B7CA0C088B;
	Thu, 21 Jan 2021 12:05:11 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 74260C088B
 for <containers@lists.linux-foundation.org>;
 Thu, 21 Jan 2021 12:05:10 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 44A2D20788
 for <containers@lists.linux-foundation.org>;
 Thu, 21 Jan 2021 12:05:10 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id H2P+VpGU5lZD
 for <containers@lists.linux-foundation.org>;
 Thu, 21 Jan 2021 12:05:08 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from raptor.unsafe.ru (raptor.unsafe.ru [5.9.43.93])
 by silver.osuosl.org (Postfix) with ESMTP id 8C5762047C
 for <containers@lists.linux-foundation.org>;
 Thu, 21 Jan 2021 12:05:08 +0000 (UTC)
Received: from example.org (ip-94-112-41-137.net.upcbroadband.cz
 [94.112.41.137])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits))
 (No client certificate requested)
 by raptor.unsafe.ru (Postfix) with ESMTPSA id 8DBD220459;
 Thu, 21 Jan 2021 12:04:38 +0000 (UTC)
Date: Thu, 21 Jan 2021 13:04:27 +0100
From: Alexey Gladkov <gladkov.alexey@gmail.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: Re: [RFC PATCH v3 1/8] Use refcount_t for ucounts reference counting
Message-ID: <20210121120427.iiggfmw3tpsmyzeb@example.org>
References: <cover.1610722473.git.gladkov.alexey@gmail.com>
 <116c7669744404364651e3b380db2d82bb23f983.1610722473.git.gladkov.alexey@gmail.com>
 <CAHk-=wjsg0Lgf1Mh2UiJE4sqBDDo0VhFVBUbhed47ot2CQQwfQ@mail.gmail.com>
 <20210118194551.h2hrwof7b3q5vgoi@example.org>
 <CAHk-=wiNpc5BS2BfZhdDqofJx1G=uasBa2Q1eY4cr8O59Rev2A@mail.gmail.com>
 <20210118205629.zro2qkd3ut42bpyq@example.org>
 <87eeig74kv.fsf@x220.int.ebiederm.org>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <87eeig74kv.fsf@x220.int.ebiederm.org>
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.6.1
 (raptor.unsafe.ru [5.9.43.93]); Thu, 21 Jan 2021 12:05:05 +0000 (UTC)
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

On Tue, Jan 19, 2021 at 07:57:36PM -0600, Eric W. Biederman wrote:
> Alexey Gladkov <gladkov.alexey@gmail.com> writes:
> 
> > On Mon, Jan 18, 2021 at 12:34:29PM -0800, Linus Torvalds wrote:
> >> On Mon, Jan 18, 2021 at 11:46 AM Alexey Gladkov
> >> <gladkov.alexey@gmail.com> wrote:
> >> >
> >> > Sorry about that. I thought that this code is not needed when switching
> >> > from int to refcount_t. I was wrong.
> >> 
> >> Well, you _may_ be right. I personally didn't check how the return
> >> value is used.
> >> 
> >> I only reacted to "it certainly _may_ be used, and there is absolutely
> >> no comment anywhere about why it wouldn't matter".
> >
> > I have not found examples where checked the overflow after calling
> > refcount_inc/refcount_add.
> >
> > For example in kernel/fork.c:2298 :
> >
> >    current->signal->nr_threads++;                           
> >    atomic_inc(&current->signal->live);                      
> >    refcount_inc(&current->signal->sigcnt);  
> >
> > $ semind search signal_struct.sigcnt
> > def include/linux/sched/signal.h:83  		refcount_t		sigcnt;
> > m-- kernel/fork.c:723 put_signal_struct 		if (refcount_dec_and_test(&sig->sigcnt))
> > m-- kernel/fork.c:1571 copy_signal 		refcount_set(&sig->sigcnt, 1);
> > m-- kernel/fork.c:2298 copy_process 				refcount_inc(&current->signal->sigcnt);
> >
> > It seems to me that the only way is to use __refcount_inc and then compare
> > the old value with REFCOUNT_MAX
> >
> > Since I have not seen examples of such checks, I thought that this is
> > acceptable. Sorry once again. I have not tried to hide these changes.
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

Did I understand your suggestion correctly that you suggest to use
spin_lock for atomic_read and atomic_inc ?

If so, then we are already incrementing the counter under ucounts_lock.

	...
	if (atomic_read(&ucounts->count) == INT_MAX)
		ucounts = NULL;
	else
		atomic_inc(&ucounts->count);
	spin_unlock_irq(&ucounts_lock);
	return ucounts;

something like this ?

-- 
Rgrds, legion

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
