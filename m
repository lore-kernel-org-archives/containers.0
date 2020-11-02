Return-Path: <SRS0=UpRV=EI=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC04AC4742C
	for <containers@archiver.kernel.org>; Mon,  2 Nov 2020 14:14:07 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id EBF9522456
	for <containers@archiver.kernel.org>; Mon,  2 Nov 2020 14:14:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=google.com header.i=@google.com header.b="mH8M9jps"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EBF9522456
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 62EB087359;
	Mon,  2 Nov 2020 14:14:04 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id yxdtGpHPDomu; Mon,  2 Nov 2020 14:14:03 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id A48C28734D;
	Mon,  2 Nov 2020 14:14:03 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 83718C0889;
	Mon,  2 Nov 2020 14:14:03 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 94459C0051
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 14:14:02 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 907C38734D
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 14:14:02 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id bZRuM+xMSp6j
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 14:14:01 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-lj1-f195.google.com (mail-lj1-f195.google.com
 [209.85.208.195])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 547AC87351
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 14:14:01 +0000 (UTC)
Received: by mail-lj1-f195.google.com with SMTP id v19so10199128lji.5
 for <containers@lists.linux-foundation.org>;
 Mon, 02 Nov 2020 06:14:01 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=UWSN6pUmUHVvmlI9O9ME30to/SMhrDIMong6ljJZfek=;
 b=mH8M9jpsGa3f9fcWJHPca/931KX2U+XkxbOX64TG8Zhi5C/ZcESSCqI25qknkzRBLO
 noKBzIlTe+kkzgJhAG7wFIWJHKb+7Biel9RAR2wvFwoQ8awGXak5DIOL/gSrErk8V9Le
 vlO7D9AMDRl3i5YY711AIk6T0Y/LyvuwzQGcNyl4w01onM/Gmvo0d0ZnirRD4P47OtY2
 tzxcRqUU+MRRVpIAht7p86HHVpCbRPuFXM6Wp6qrioc/0YN/b7/4RkUf4BGA22vRsC28
 ayKlOnSmhsPnPgbQkfW35DjULd5kYMYQ9XAPr8m5Wvyv0vFY8DY7k6OmPeCE5GBKo4Wr
 ts3A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=UWSN6pUmUHVvmlI9O9ME30to/SMhrDIMong6ljJZfek=;
 b=TiAES8oNUUqBYGWFCoUkd1d1GTfqew3ljs345zekDrUpABj4W9O4AwGZL2w1JUP6c8
 ve8+AOQubQAsuHekSBHS4uZI7c+f8Lwty4v6KQlBlXEndctdxje6s4SgRVhOi/WO5tLh
 B+qdmzSvELPukD3K6bZfMm0vfqpQLy+roGJ/luKxt2fwGWw3XntUs1CEJLouQb7VpRuV
 bDESXmCNaoSc2qAQ4TAmuFT8v0FkWD5xPQCGUn08zmSeVAPIzxDxpOT1Iwx8PTAqXWUa
 +C9PrZ5BZksL55k0SkxhwP04kyvElHIpCwlV830Q8ywQJ5az9v+rawrvo/nJ/8anTuZ7
 2lfA==
X-Gm-Message-State: AOAM533ioJu+UAmzV+eZAus0aaZf6FLAwUiuydJu7dI1bq6bsd3igN/w
 1lxaZCABlyoKtiotsCG2LcHa1XuP9extNlrN7On4TA==
X-Google-Smtp-Source: ABdhPJybPO8qgl/H4+fZNekPwvUlTXpeBbE0gJrFEKhorJDspmNB/asdWQ1rEsPeRWv77CUoxL2pOk6JOxoYlGfUPn4=
X-Received: by 2002:a2e:b888:: with SMTP id r8mr6414174ljp.138.1604326439180; 
 Mon, 02 Nov 2020 06:13:59 -0800 (PST)
MIME-Version: 1.0
References: <63598b4f-6ce3-5a11-4552-cdfe308f68e4@gmail.com>
 <CAG48ez0fBE6AJfWh0in=WKkgt98y=KjAen=SQPyTYtvsUbF1yA@mail.gmail.com>
 <93cfdc79-4c48-bceb-3620-4c63e9f4822e@gmail.com>
 <CAG48ez3nH2Oiz9wMSpvUxxX_TRYTT98d3Nj1vnCuJOj9CCXH8Q@mail.gmail.com>
 <b43b50a2-fa5c-419d-ad24-3fd40bc26dba@gmail.com>
In-Reply-To: <b43b50a2-fa5c-419d-ad24-3fd40bc26dba@gmail.com>
Date: Mon, 2 Nov 2020 15:13:31 +0100
Message-ID: <CAG48ez000V-5KEpdHd3mNZrqvYYydJcdjZvZxeVph7AFgcxfHA@mail.gmail.com>
Subject: Re: For review: seccomp_user_notif(2) manual page [v2]
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Giuseppe Scrivano <gscrivan@redhat.com>, Song Liu <songliubraving@fb.com>,
 Will Drewry <wad@chromium.org>, Kees Cook <keescook@chromium.org>,
 Daniel Borkmann <daniel@iogearbox.net>, linux-man <linux-man@vger.kernel.org>,
 Robert Sesek <rsesek@google.com>,
 Containers <containers@lists.linux-foundation.org>,
 lkml <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
 bpf <bpf@vger.kernel.org>, Andy Lutomirski <luto@amacapital.net>,
 Christian Brauner <christian@brauner.io>
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
From: Jann Horn via Containers <containers@lists.linux-foundation.org>
Reply-To: Jann Horn <jannh@google.com>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

On Sat, Oct 31, 2020 at 9:51 AM Michael Kerrisk (man-pages)
<mtk.manpages@gmail.com> wrote:
> On 10/30/20 8:20 PM, Jann Horn wrote:
> > On Thu, Oct 29, 2020 at 8:14 PM Michael Kerrisk (man-pages)
> > <mtk.manpages@gmail.com> wrote:
> >> On 10/29/20 2:42 AM, Jann Horn wrote:
> >>> As discussed at
> >>> <https://lore.kernel.org/r/CAG48ez0m4Y24ZBZCh+Tf4ORMm9_q4n7VOzpGjwGF7_Fe8EQH=Q@mail.gmail.com>,
> >>> we need to re-check checkNotificationIdIsValid() after reading remote
> >>> memory but before using the read value in any way. Otherwise, the
> >>> syscall could in the meantime get interrupted by a signal handler, the
> >>> signal handler could return, and then the function that performed the
> >>> syscall could free() allocations or return (thereby freeing buffers on
> >>> the stack).
> >>>
> >>> In essence, this pread() is (unavoidably) a potential use-after-free
> >>> read; and to make that not have any security impact, we need to check
> >>> whether UAF read occurred before using the read value. This should
> >>> probably be called out elsewhere in the manpage, too...
> >>>
> >>> Now, of course, **reading** is the easy case. The difficult case is if
> >>> we have to **write** to the remote process... because then we can't
> >>> play games like that. If we write data to a freed pointer, we're
> >>> screwed, that's it. (And for somewhat unrelated bonus fun, consider
> >>> that /proc/$pid/mem is originally intended for process debugging,
> >>> including installing breakpoints, and will therefore happily write
> >>> over "readonly" private mappings, such as typical mappings of
> >>> executable code.)
> >>>
> >>> So, uuuuh... I guess if anyone wants to actually write memory back to
> >>> the target process, we'd better come up with some dedicated API for
> >>> that, using an ioctl on the seccomp fd that magically freezes the
> >>> target process inside the syscall while writing to its memory, or
> >>> something like that? And until then, the manpage should have a big fat
> >>> warning that writing to the target's memory is simply not possible
> >>> (safely).
> >>
> >> Thank you for your very clear explanation! It turned out to be
> >> trivially easy to demonstrate this issue with a slightly modified
> >> version of my program.
> >>
> >> As well as the change to the code example that I already mentioned
> >> my reply of a few hours ago, I've added the following text to the
> >> page:
> >>
> >>    Caveats regarding the use of /proc/[tid]/mem
> >>        The discussion above noted the need to use the
> >>        SECCOMP_IOCTL_NOTIF_ID_VALID ioctl(2) when opening the
> >>        /proc/[tid]/mem file of the target to avoid the possibility of
> >>        accessing the memory of the wrong process in the event that the
> >>        target terminates and its ID is recycled by another (unrelated)
> >>        thread.  However, the use of this ioctl(2) operation is also
> >>        necessary in other situations, as explained in the following
> >>        pargraphs.
> >
> > (nit: paragraphs)
>
> I spotted that one also already. But thanks for reading carefully!
>
> >>        Consider the following scenario, where the supervisor tries to
> >>        read the pathname argument of a target's blocked mount(2) system
> >>        call:
> > [...]
> >> Seem okay?
> >
> > Yeah, sounds good.
> >
> >> By the way, is there any analogous kind of issue concerning
> >> pidfd_getfd()? I'm thinking not, but I wonder if I've missed
> >> something.
> >
> > When it is used by a seccomp supervisor, you mean? I think basically
> > the same thing applies - when resource identifiers (such as memory
> > addresses or file descriptors) are passed to a syscall, it generally
> > has to be assumed that those identifiers may become invalid and be
> > reused as soon as the syscall has returned.
>
> I probably needed to be more explicit. Would the following (i.e., a
> single cookie check) not be sufficient to handle the above scenario.
> Here, the target is making a syscall a system call that employs the
> file descriptor 'tfd':
>
> T: makes syscall that triggers notification
> S: Get notification
> S: pidfd = pidfd_open(T, 0);
> S: sfd = pifd_getfd(pidfd, tfd, 0)
> S: check that the cookie is still valid
> S: do operation with sfd [*]
>
> By contrast, I can see that we might want to do multiple cookie
> checks in the /proc/PID/mem case, since the supervisor might do
> multiple reads.

Aaah, okay. I didn't really understand the question at first.

> Or, do you mean: there really needs to be another cookie check after
> the point [*], since, if the the target's syscall was interrupted
> and 'tfd' was closed/resused, then the supervisor would be operating
> with a file descriptor that refers to an open file description
> (a "struct file") that is no longer meaningful in the target?
> (Thinking about it, I think this probably is what you mean, but
> I want to confirm.)

I wasn't thinking about your actual question when I wrote that. :P

I think you could argue that leaving out the first cookie check does
not make this incorrect if it was correct before; but you could also
argue that it's hazardous either way (because programs might rely on
synchronous actions that happen when closing an fd that they assume is
the only one associated with a file description, e.g. assuming that
close() will synchronously release an flock() lock). And if we do two
checks, we can at least limit such potentially hazardous interference
to processes that performed syscalls subject to interception, instead
of risking triggering them all over the place.
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
