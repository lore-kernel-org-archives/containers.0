Return-Path: <SRS0=WE+R=II=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 942E6C433DB
	for <containers@archiver.kernel.org>; Wed, 10 Mar 2021 21:14:49 +0000 (UTC)
Received: from smtp4.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id D6D4C64ED6
	for <containers@archiver.kernel.org>; Wed, 10 Mar 2021 21:14:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D6D4C64ED6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp4.osuosl.org (Postfix) with ESMTP id 72C524EC1B;
	Wed, 10 Mar 2021 21:14:48 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp4.osuosl.org ([127.0.0.1])
	by localhost (smtp4.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id bpTYM6UOvfMr; Wed, 10 Mar 2021 21:14:47 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp4.osuosl.org (Postfix) with ESMTP id 18C874EBF9;
	Wed, 10 Mar 2021 21:14:47 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id ED9A5C000B;
	Wed, 10 Mar 2021 21:14:46 +0000 (UTC)
Received: from smtp4.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 20018C0001
 for <containers@lists.linux-foundation.org>;
 Wed, 10 Mar 2021 21:14:45 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp4.osuosl.org (Postfix) with ESMTP id 0A0C64EC1B
 for <containers@lists.linux-foundation.org>;
 Wed, 10 Mar 2021 21:14:45 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp4.osuosl.org ([127.0.0.1])
 by localhost (smtp4.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id MugsUnWAi6Vd
 for <containers@lists.linux-foundation.org>;
 Wed, 10 Mar 2021 21:14:44 +0000 (UTC)
X-Greylist: whitelisted by SQLgrey-1.8.0
Received: from mail-lf1-x12e.google.com (mail-lf1-x12e.google.com
 [IPv6:2a00:1450:4864:20::12e])
 by smtp4.osuosl.org (Postfix) with ESMTPS id F25EF4EBF9
 for <containers@lists.linux-foundation.org>;
 Wed, 10 Mar 2021 21:14:43 +0000 (UTC)
Received: by mail-lf1-x12e.google.com with SMTP id v2so22947191lft.9
 for <containers@lists.linux-foundation.org>;
 Wed, 10 Mar 2021 13:14:43 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=linux-foundation.org; s=google;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=mWjSyj9+MgpkAuhvTxP4EPO0ZRIe4bF8NB224VR5k5Y=;
 b=PIqDJ2U0GSCx4NtqwWKrFE9QHN7qXy5qh2Js/ocQazC6t5gl+kXnW0bxIJE/LFuD2k
 T6xs2xk/6PHqSWp9K4hjRH0M1ASKEW1Ap/K9lX9Q8UAOfl66sg1BvnzXj2ilccmkluus
 iX3LkCYCwJNr7hiSwfQg9Kx4Hg3FIHAwDl0VY=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=mWjSyj9+MgpkAuhvTxP4EPO0ZRIe4bF8NB224VR5k5Y=;
 b=fGe6IRRv2quTqEIlNO/HErpedWTWzw4PB2Cp0Em/TVmtaKGyOCFpFhrf3oD3rjTeMA
 8cr8YFpy8rwFUB1JWP1dkSZTQfte5MD0nLkMvz/yjHkWbrsbUyOs60KUPN3piP15bJNB
 OnsSoJ6uQot29K7Cw+h4YStRSBUiEdKbJ99BVZiaLwBiOUjboSh13P7nkXGRqskaZ84+
 fWWXsaqg5lgtCv01jt9TnzzneX58f7tWUkI6fA7XscL7DG3iECZZ9+VOm4hQPpaKXtjJ
 KesG/+49Fyt60Vyz2KSKqCo2TTt1xqKIyY9yJlonG11ex1MVW+GyCieKY4va9NDyWhJH
 o/Kg==
X-Gm-Message-State: AOAM531kPaRgYLQKPG+8UxLLac6xS4i8SMp+8V2bQgKluUJ2bVmxJlsJ
 EDSYrkhIrrYu2hqcQq+H9E/F8548aH9grW5/
X-Google-Smtp-Source: ABdhPJwBgkGhGBOxk1ECIIP66dJymW0W5JbMl4y40DmcJDSuus9zmfWNXiHWiESr6h6aJZmOHDo/SA==
X-Received: by 2002:a19:6910:: with SMTP id e16mr228716lfc.482.1615410881806; 
 Wed, 10 Mar 2021 13:14:41 -0800 (PST)
Received: from mail-lj1-f176.google.com (mail-lj1-f176.google.com.
 [209.85.208.176])
 by smtp.gmail.com with ESMTPSA id d8sm142634lfg.96.2021.03.10.13.14.41
 for <containers@lists.linux-foundation.org>
 (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
 Wed, 10 Mar 2021 13:14:41 -0800 (PST)
Received: by mail-lj1-f176.google.com with SMTP id h4so27535275ljl.0
 for <containers@lists.linux-foundation.org>;
 Wed, 10 Mar 2021 13:14:41 -0800 (PST)
X-Received: by 2002:a2e:5c84:: with SMTP id q126mr2800569ljb.61.1615410880841; 
 Wed, 10 Mar 2021 13:14:40 -0800 (PST)
MIME-Version: 1.0
References: <cover.1615372955.git.gladkov.alexey@gmail.com>
 <59ee3289194cd97d70085cce701bc494bfcb4fd2.1615372955.git.gladkov.alexey@gmail.com>
In-Reply-To: <59ee3289194cd97d70085cce701bc494bfcb4fd2.1615372955.git.gladkov.alexey@gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 10 Mar 2021 13:14:24 -0800
X-Gmail-Original-Message-ID: <CAHk-=whg4aVxA7LFAUFCzOn78_7TL1CPo+esPKgN5JTHy8H-Rg@mail.gmail.com>
Message-ID: <CAHk-=whg4aVxA7LFAUFCzOn78_7TL1CPo+esPKgN5JTHy8H-Rg@mail.gmail.com>
Subject: Re: [PATCH v8 3/8] Use atomic_t for ucounts reference counting
To: Alexey Gladkov <gladkov.alexey@gmail.com>
Cc: Jens Axboe <axboe@kernel.dk>, Kees Cook <keescook@chromium.org>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Jann Horn <jannh@google.com>, LKML <linux-kernel@vger.kernel.org>,
 Oleg Nesterov <oleg@redhat.com>, Linux-MM <linux-mm@kvack.org>,
 "Eric W . Biederman" <ebiederm@xmission.com>,
 Andrew Morton <akpm@linux-foundation.org>, Alexey Gladkov <legion@kernel.org>,
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

On Wed, Mar 10, 2021 at 4:01 AM Alexey Gladkov <gladkov.alexey@gmail.com> wrote:
>
>
> +/* 127: arbitrary random number, small enough to assemble well */
> +#define refcount_zero_or_close_to_overflow(ucounts) \
> +       ((unsigned int) atomic_read(&ucounts->count) + 127u <= 127u)
> +
> +struct ucounts *get_ucounts(struct ucounts *ucounts)
> +{
> +       if (ucounts) {
> +               if (refcount_zero_or_close_to_overflow(ucounts)) {
> +                       WARN_ONCE(1, "ucounts: counter has reached its maximum value");
> +                       return NULL;
> +               }
> +               atomic_inc(&ucounts->count);
> +       }
> +       return ucounts;

Side note: you probably should just make the limit be the "oh, the
count overflows into the sign bit".

The reason the page cache did that tighter thing is that it actually
has _two_ limits:

 - the "try_get_page()" thing uses the sign bit as a "uhhuh, I've now
used up half of the available reference counting bits, and I will
refuse to use any more".

   This is basically your "get_ucounts()" function. It's a "I want a
refcount, but I'm willing to deal with failures".

 - the page cache has a _different_ set of "I need to unconditionally
get a refcount, and I can *not* deal with failures".

   This is basically the traditional "get_page()", which is only used
in fairly controlled places, and should never be something that can
overflow.

    And *that* special code then uses that
"zero_or_close_to_overflow()" case as a "doing a get_page() in this
situation is very very wrong". This is purely a debugging feature used
for a VM_BUG_ON() (that has never triggered, as far as I know).

For your ucounts situation, you don't have that second case at all, so
you have no reason to ever allow the count to even get remotely close
to overflowing.

A reference count being within 128 counts of overflow (when we're
talking a 32-bit count) is basically never a good idea. It means that
you are way too close to the limit, and there's a risk that lots of
concurrent people all first see an ok value, and then *all* decide to
do the increment, and then you're toast.

In contrast, if you use the sign bit as a "ok, let's stop
incrementing", the fact that your "overflow" test and the increment
aren't atomic really isn't a big deal.

(And yes, you could use a cmpxchg to *make* the overflow test atomic,
but it's often much much more expensive, so..)

                    Linus
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
