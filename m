Return-Path: <SRS0=Ull0=GY=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0FEDFC433E0
	for <containers@archiver.kernel.org>; Thu, 21 Jan 2021 16:08:09 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 7CCD223A1E
	for <containers@archiver.kernel.org>; Thu, 21 Jan 2021 16:08:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7CCD223A1E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 1A80286356;
	Thu, 21 Jan 2021 16:08:08 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 8S-UuzadpVWM; Thu, 21 Jan 2021 16:08:07 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 5BABA86355;
	Thu, 21 Jan 2021 16:08:07 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 4CBA3C088B;
	Thu, 21 Jan 2021 16:08:07 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 0D91BC013A
 for <containers@lists.linux-foundation.org>;
 Thu, 21 Jan 2021 16:08:06 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id F33ED871C9
 for <containers@lists.linux-foundation.org>;
 Thu, 21 Jan 2021 16:08:05 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 2RnNyGDDudS9
 for <containers@lists.linux-foundation.org>;
 Thu, 21 Jan 2021 16:08:05 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from raptor.unsafe.ru (raptor.unsafe.ru [5.9.43.93])
 by hemlock.osuosl.org (Postfix) with ESMTP id F2F728609B
 for <containers@lists.linux-foundation.org>;
 Thu, 21 Jan 2021 16:08:04 +0000 (UTC)
Received: from example.org (ip-94-112-41-137.net.upcbroadband.cz
 [94.112.41.137])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits))
 (No client certificate requested)
 by raptor.unsafe.ru (Postfix) with ESMTPSA id D51E2209D4;
 Thu, 21 Jan 2021 16:07:46 +0000 (UTC)
Date: Thu, 21 Jan 2021 17:07:42 +0100
From: Alexey Gladkov <gladkov.alexey@gmail.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: Re: [RFC PATCH v3 1/8] Use refcount_t for ucounts reference counting
Message-ID: <20210121160742.evd3632lepfytlxb@example.org>
References: <cover.1610722473.git.gladkov.alexey@gmail.com>
 <116c7669744404364651e3b380db2d82bb23f983.1610722473.git.gladkov.alexey@gmail.com>
 <CAHk-=wjsg0Lgf1Mh2UiJE4sqBDDo0VhFVBUbhed47ot2CQQwfQ@mail.gmail.com>
 <20210118194551.h2hrwof7b3q5vgoi@example.org>
 <CAHk-=wiNpc5BS2BfZhdDqofJx1G=uasBa2Q1eY4cr8O59Rev2A@mail.gmail.com>
 <20210118205629.zro2qkd3ut42bpyq@example.org>
 <87eeig74kv.fsf@x220.int.ebiederm.org>
 <20210121120427.iiggfmw3tpsmyzeb@example.org>
 <87ft2u2ss5.fsf@x220.int.ebiederm.org>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <87ft2u2ss5.fsf@x220.int.ebiederm.org>
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.6.1
 (raptor.unsafe.ru [5.9.43.93]); Thu, 21 Jan 2021 16:08:00 +0000 (UTC)
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

On Thu, Jan 21, 2021 at 09:50:34AM -0600, Eric W. Biederman wrote:
> >> The current ucount code does check for overflow and fails the increment
> >> in every case.
> >> 
> >> So arguably it will be a regression and inferior error handling behavior
> >> if the code switches to the ``better'' refcount_t data structure.
> >> 
> >> I originally didn't use refcount_t because silently saturating and not
> >> bothering to handle the error makes me uncomfortable.
> >> 
> >> Not having to acquire the ucounts_lock every time seems nice.  Perhaps
> >> the path forward would be to start with stupid/correct code that always
> >> takes the ucounts_lock for every increment of ucounts->count, that is
> >> later replaced with something more optimal.
> >> 
> >> Not impacting performance in the non-namespace cases and having good
> >> performance in the other cases is a fundamental requirement of merging
> >> code like this.
> >
> > Did I understand your suggestion correctly that you suggest to use
> > spin_lock for atomic_read and atomic_inc ?
> >
> > If so, then we are already incrementing the counter under ucounts_lock.
> >
> > 	...
> > 	if (atomic_read(&ucounts->count) == INT_MAX)
> > 		ucounts = NULL;
> > 	else
> > 		atomic_inc(&ucounts->count);
> > 	spin_unlock_irq(&ucounts_lock);
> > 	return ucounts;
> >
> > something like this ?
> 
> Yes.  But without atomics.  Something a bit more like:
> > 	...
> > 	if (ucounts->count == INT_MAX)
> > 		ucounts = NULL;
> > 	else
> > 		ucounts->count++;
> > 	spin_unlock_irq(&ucounts_lock);
> > 	return ucounts;

This is the original code.

> I do believe at some point we will want to say using the spin_lock for
> ucounts->count is cumbersome, and suboptimal and we want to change it to
> get a better performing implementation.
> 
> Just for getting the semantics correct we should be able to use just
> ucounts_lock for locking.  Then when everything is working we can
> profile and optimize the code.
> 
> I just don't want figuring out what is needed to get hung up over little
> details that we can change later.

OK. So I will drop this my change for now.

-- 
Rgrds, legion

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
