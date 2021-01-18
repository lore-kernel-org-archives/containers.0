Return-Path: <SRS0=zkWj=GV=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.7 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24339C433DB
	for <containers@archiver.kernel.org>; Mon, 18 Jan 2021 19:46:16 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id B7E4920848
	for <containers@archiver.kernel.org>; Mon, 18 Jan 2021 19:46:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B7E4920848
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 6B557865A1;
	Mon, 18 Jan 2021 19:46:15 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id se-la+Chbf6v; Mon, 18 Jan 2021 19:46:14 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id DF9D5864E6;
	Mon, 18 Jan 2021 19:46:14 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id D3ECFC08A1;
	Mon, 18 Jan 2021 19:46:14 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 233E0C013A
 for <containers@lists.linux-foundation.org>;
 Mon, 18 Jan 2021 19:46:14 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 0B0E8866D6
 for <containers@lists.linux-foundation.org>;
 Mon, 18 Jan 2021 19:46:14 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id oeu0t0Hs0-90
 for <containers@lists.linux-foundation.org>;
 Mon, 18 Jan 2021 19:46:13 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from raptor.unsafe.ru (raptor.unsafe.ru [5.9.43.93])
 by whitealder.osuosl.org (Postfix) with ESMTP id 0D84E866D4
 for <containers@lists.linux-foundation.org>;
 Mon, 18 Jan 2021 19:46:12 +0000 (UTC)
Received: from example.org (ip-89-103-122-167.net.upcbroadband.cz
 [89.103.122.167])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits))
 (No client certificate requested)
 by raptor.unsafe.ru (Postfix) with ESMTPSA id 3C0D820479;
 Mon, 18 Jan 2021 19:45:56 +0000 (UTC)
Date: Mon, 18 Jan 2021 20:45:51 +0100
From: Alexey Gladkov <gladkov.alexey@gmail.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC PATCH v3 1/8] Use refcount_t for ucounts reference counting
Message-ID: <20210118194551.h2hrwof7b3q5vgoi@example.org>
References: <cover.1610722473.git.gladkov.alexey@gmail.com>
 <116c7669744404364651e3b380db2d82bb23f983.1610722473.git.gladkov.alexey@gmail.com>
 <CAHk-=wjsg0Lgf1Mh2UiJE4sqBDDo0VhFVBUbhed47ot2CQQwfQ@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CAHk-=wjsg0Lgf1Mh2UiJE4sqBDDo0VhFVBUbhed47ot2CQQwfQ@mail.gmail.com>
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.6.1
 (raptor.unsafe.ru [5.9.43.93]); Mon, 18 Jan 2021 19:46:07 +0000 (UTC)
Cc: Jens Axboe <axboe@kernel.dk>, Kees Cook <keescook@chromium.org>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Jann Horn <jannh@google.com>, LKML <linux-kernel@vger.kernel.org>,
 Oleg Nesterov <oleg@redhat.com>, Linux-MM <linux-mm@kvack.org>,
 "Eric W . Biederman" <ebiederm@xmission.com>,
 Andrew Morton <akpm@linux-foundation.org>, io-uring <io-uring@vger.kernel.org>
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

On Mon, Jan 18, 2021 at 11:14:48AM -0800, Linus Torvalds wrote:
> On Fri, Jan 15, 2021 at 6:59 AM Alexey Gladkov <gladkov.alexey@gmail.com> wrote:
> >
> > @@ -152,10 +153,7 @@ static struct ucounts *get_ucounts(struct user_namespace *ns, kuid_t uid)
> >                         ucounts = new;
> >                 }
> >         }
> > -       if (ucounts->count == INT_MAX)
> > -               ucounts = NULL;
> > -       else
> > -               ucounts->count += 1;
> > +       refcount_inc(&ucounts->count);
> >         spin_unlock_irq(&ucounts_lock);
> >         return ucounts;
> >  }
> 
> This is wrong.
> 
> It used to return NULL when the count saturated.
> 
> Now it just silently saturates.
> 
> I'm not sure how many people care, but that NULL return ends up being
> returned quite widely (through "inc_uncount()" and friends).
> 
> The fact that this has no commit message at all to explain what it is
> doing and why is also a grounds for just NAK.

Sorry about that. I thought that this code is not needed when switching
from int to refcount_t. I was wrong. I'll think about how best to check
it.

-- 
Rgrds, legion

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
