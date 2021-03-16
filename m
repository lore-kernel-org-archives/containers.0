Return-Path: <SRS0=7SHr=IO=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_RED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B3B2C433DB
	for <containers@archiver.kernel.org>; Tue, 16 Mar 2021 19:26:32 +0000 (UTC)
Received: from smtp1.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id E422A64DCE
	for <containers@archiver.kernel.org>; Tue, 16 Mar 2021 19:26:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E422A64DCE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp1.osuosl.org (Postfix) with ESMTP id 9E84483942;
	Tue, 16 Mar 2021 19:26:31 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp1.osuosl.org ([127.0.0.1])
	by localhost (smtp1.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id i4TzDogArSlL; Tue, 16 Mar 2021 19:26:30 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp1.osuosl.org (Postfix) with ESMTP id 6912883934;
	Tue, 16 Mar 2021 19:26:30 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 55CDAC000B;
	Tue, 16 Mar 2021 19:26:30 +0000 (UTC)
Received: from smtp3.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id A6A57C000A
 for <containers@lists.linux-foundation.org>;
 Tue, 16 Mar 2021 19:26:28 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp3.osuosl.org (Postfix) with ESMTP id A1AE3606A2
 for <containers@lists.linux-foundation.org>;
 Tue, 16 Mar 2021 19:26:28 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Authentication-Results: smtp3.osuosl.org (amavisd-new);
 dkim=pass (1024-bit key) header.d=linux-foundation.org
Received: from smtp3.osuosl.org ([127.0.0.1])
 by localhost (smtp3.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id DpYolfcSzcvA
 for <containers@lists.linux-foundation.org>;
 Tue, 16 Mar 2021 19:26:27 +0000 (UTC)
X-Greylist: whitelisted by SQLgrey-1.8.0
Received: from mail-lf1-x134.google.com (mail-lf1-x134.google.com
 [IPv6:2a00:1450:4864:20::134])
 by smtp3.osuosl.org (Postfix) with ESMTPS id 87E3E6064B
 for <containers@lists.linux-foundation.org>;
 Tue, 16 Mar 2021 19:26:27 +0000 (UTC)
Received: by mail-lf1-x134.google.com with SMTP id v2so51171051lft.9
 for <containers@lists.linux-foundation.org>;
 Tue, 16 Mar 2021 12:26:27 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=linux-foundation.org; s=google;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=PJ8ESo0xqLlhuMcPL8POiu1QM1DGh9i+Siia5DD90iA=;
 b=PjQAR7jNs9aEbwhkT9krh4CX5Eq0E0nqKvuTh1ox18H2jnLEyvjLF0ogBNQZx70+qE
 w88lKXrGNC0u2RLFwPYEFIJJP7fzVM1wcZzREZLxuIVXkxTvV3Utf4GXsqCDaqxts1Nt
 pQkwtLqPxVJxeYhj4PkZwJA43mxfvW69caxtc=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=PJ8ESo0xqLlhuMcPL8POiu1QM1DGh9i+Siia5DD90iA=;
 b=spAodccemi3e6PMD/7i8PqOYu1bQmtdvxukzZdCADMppyKdegFVDhoBAv8V9lRau6I
 P7amhiDw2gawplDeElrF1nSsQzMgu9kVQla4mSaY5fjaBo7TL1tK4BZUkmscZ3oObkaM
 9MGriI2vtU+zmloaH4Lx4C8+xD1n95usXSbXcDkMmanE3ctY5Uy0qdrT+myqYhL5eKdy
 vfzSwTGm3PE8Hi/r8wAv6x//0YeLeDHBy2quntDm643q0j9R4Wq3n4lomlT/dNQbunDe
 G8HS6bZU0uyI2XcHr+3ezUusLa+tkPSaTrCO2BVXPsnI15KNY4DaLuRydcFWAPK72M+F
 QKtQ==
X-Gm-Message-State: AOAM532Iq21+jvvdW34mZdM/zieTnxkp8Qic01ZgZ8Zq5LV/RVjUczky
 NB6HeHN0wSfwRVvbC840OStabMOgdbwelYt5
X-Google-Smtp-Source: ABdhPJwJyXyH16ZZXyG97hAf7WdZ2xVnP1C1jqmgUQwgjIF1rhnHYzliY4eK4j6k6+fSQ2SMZ/aiyg==
X-Received: by 2002:ac2:47eb:: with SMTP id b11mr195566lfp.390.1615922784236; 
 Tue, 16 Mar 2021 12:26:24 -0700 (PDT)
Received: from mail-lj1-f169.google.com (mail-lj1-f169.google.com.
 [209.85.208.169])
 by smtp.gmail.com with ESMTPSA id b25sm3277210ljo.80.2021.03.16.12.26.22
 for <containers@lists.linux-foundation.org>
 (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
 Tue, 16 Mar 2021 12:26:23 -0700 (PDT)
Received: by mail-lj1-f169.google.com with SMTP id u10so186716lju.7
 for <containers@lists.linux-foundation.org>;
 Tue, 16 Mar 2021 12:26:22 -0700 (PDT)
X-Received: by 2002:a2e:9bd0:: with SMTP id w16mr118915ljj.465.1615922781857; 
 Tue, 16 Mar 2021 12:26:21 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1615372955.git.gladkov.alexey@gmail.com>
 <59ee3289194cd97d70085cce701bc494bfcb4fd2.1615372955.git.gladkov.alexey@gmail.com>
 <202103151426.ED27141@keescook>
 <CAHk-=wjYOCgM+mKzwTZwkDDg12DdYjFFkmoFKYLim7NFmR9HBg@mail.gmail.com>
 <202103161146.E118DE5@keescook>
In-Reply-To: <202103161146.E118DE5@keescook>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 16 Mar 2021 12:26:05 -0700
X-Gmail-Original-Message-ID: <CAHk-=wj7k2nCB8Q5kMYsYi1ajb99yZ-EYn_MYFMQ2bw3nWuT5Q@mail.gmail.com>
Message-ID: <CAHk-=wj7k2nCB8Q5kMYsYi1ajb99yZ-EYn_MYFMQ2bw3nWuT5Q@mail.gmail.com>
Subject: Re: [PATCH v8 3/8] Use atomic_t for ucounts reference counting
To: Kees Cook <keescook@chromium.org>
Cc: Jens Axboe <axboe@kernel.dk>,
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

On Tue, Mar 16, 2021 at 11:49 AM Kees Cook <keescook@chromium.org> wrote:
>
> Right -- I saw that when digging through the thread. I'm honestly
> curious, though, why did the 0-day bot find a boot crash? (I can't
> imagine ucounts wrapped in 0.4 seconds.) So it looked like an
> increment-from-zero case, which seems like it would be a bug?

Agreed. It's almost certainly a bug. Possibly a use-after-free, but
more likely just a "this count had never gotten initialized to
anything but zero, but is used by the init process (and kernel
threads) and will be incremented but never be free'd, so we never
noticed"

> Heh, right -- I'm not arguing that refcount_t MUST be used, I just didn't
> see the code path that made them unsuitable: hitting INT_MAX - 128 seems
> very hard to do. Anyway, I'll go study it more to try to understand what
> I'm missing.

So as you may have seen later in the thread, I don't like the "INT_MAX
- 128" as a limit.

I think the page count thing does the right thing: it has separate
"debug checks" and "limit checks", and the way it's done it never
really needs to worry about doing the (often) expensive cmpxchg loop,
because the limit check is _so_ far off the final case that we don't
care, and the debug checks aren't about races, they are about "uhhuh,
yoiu used this wrong".

So what the page code does is:

 - try_get_page() has a limit check _and_ a debug check:

    (a) the limit check is "you've used up half the refcounts, I'm not
giving you any more".
    (b) the debug check is "you can't get a page that has a zero count
or has underflowed".

   it's not obvious that it has both of those checks, because they are
merged into one single WARN_ON_ONCE(), but that's purely for "we
actually want that warning for the limit check, because that looks
like somebody trying an attack" and it just got combined.

   So technically, the code really should do

        page = compound_head(page);
        /* Debug check for mis-use of the count */
        if (WARN_ON_ONCE(page_ref_zero_or_close_to_overflow(page)))
                return false;
        /*
         * Limit check - we're not incrementing the
         * count (much) past the halfway point
         */
        if (page_ref_count(page) <= 0)
                return false;

        /* The actual atomic reference - the above were done "carelessly" */
        page_ref_inc(page);
        return true;

   because the "oh, we're not allowing you this ref" is not
_technically_ wrong, it's just traditionally wrong, if you see what I
mean.

and notice how none of the above really cares about the
"page_ref_inc()" itself being atomic wrt the checks.  It's ok if we
race, and the page ref goes a bit above the half-way point. You can't
race _so_ much that you actually overflow, because our limit check is
_so_ far away from the overflow area that it's not an issue.

And similarly, the debug check with
page_ref_zero_or_close_to_overflow() is one of those things that are
trying to see underflows or bad use-cases, and trying to do that
atomically with the actual ref update doesn't really help. The
underfulow or mis-use will have happened before we increment the page
count.

So the above is very close to what the ucounts code I think really
wants to do: the "zero_or_close_to_overflow" is an error case: it
means something just underflowed, or you were trying to increment a
ref to something you didn't have a reference to in the first place.

And the "<= 0" check is just the cheap test for "I'm giving you at
most half the counter space, because I don't want to have to even
remotely worry about overflow".

Note that the above very intentionally does allow the "we can go over
the limit" case for another reason: we still have that regular
*unconditional* get_page(), that has a "I absolutely need a temporary
ref to this page, but I know it's not some long-term thing that a user
can force". That's not only our traditional model, but it's something
that some kernel code simply does need, so it's a good feature in
itself. That might be less of an issue for ucounts, but for pages, we
somethines do have "I need to take a ref to this page just for my own
use while I then drop the page lock and do something else".

The "put_page()" case then has its own debug check (in
"put_page_testzero()") which says "hey, you can't put a page that has
no refcount.

Thct could could easily use that "zero_or_close_to_overflow(()" rule
too, but if you actually do underflow for real, you'll see the zero
(again - races aren't really important because even if you have some
attack vector that depends on the race, such attack vectors will also
have to depend on doing the thing over and over and over again until
it successfully hits the race, so you'll see the zero case in
practice, and trying to be "atomic" for debug testing is thus
pointless.

So I do think out page counting this is actually pretty good.

And it's possible that "refcount_t" could use that exact same model,
and actually then offer that option that ucounts wants, of a "try to
get a refcount, but if we have too many refcounts, then never mind, I
can just return an error to user space instead".

Hmm? On x86 (and honestly, these days on arm too with the new
atomics), it's generally quite a bit cheaper to do an atomic
increment/decrement than it is to do a cmpxchg loop. That seems to
become even more true as microarchitectures optimize those atomics -
apparently AMD actually does regular locked ops by doing them
optimistically out-of-order, and verifying that the serialization
requirements hold after-the-fact. So plain simple locked ops that
historically used to be quite expensive are getting less so (because
they've obviously gotten much more important over the years).

                Linus
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
