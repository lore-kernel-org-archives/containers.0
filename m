Return-Path: <SRS0=hUL4=EF=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6866CC00A89
	for <containers@archiver.kernel.org>; Fri, 30 Oct 2020 19:20:57 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 8C43420739
	for <containers@archiver.kernel.org>; Fri, 30 Oct 2020 19:20:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=google.com header.i=@google.com header.b="NKzAXeWR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8C43420739
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id ED31F86C5E;
	Fri, 30 Oct 2020 19:20:55 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 1LLrvNGdE81g; Fri, 30 Oct 2020 19:20:54 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id EC94A8688A;
	Fri, 30 Oct 2020 19:20:54 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id D1714C0859;
	Fri, 30 Oct 2020 19:20:54 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id D433DC0051
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Oct 2020 19:20:53 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id B472586CBD
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Oct 2020 19:20:53 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id DBs3GvhOkdcr
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Oct 2020 19:20:53 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-lf1-f68.google.com (mail-lf1-f68.google.com
 [209.85.167.68])
 by whitealder.osuosl.org (Postfix) with ESMTPS id A7A8884C3C
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Oct 2020 19:20:52 +0000 (UTC)
Received: by mail-lf1-f68.google.com with SMTP id 126so9254580lfi.8
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Oct 2020 12:20:52 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=7ltXFGIEC1wD1/DcBqIE9Zp9UpD0Eob4weHsly+LU6s=;
 b=NKzAXeWRhEzSsyPxWy8lABW/VB/K7yCL712Wgf/ZLf7MLh2aHZKNViiJYIbi5Z9IUk
 0D2VbKnfwvyD2QdfVIYU+1lfoDbLp2UF9hubMPUnOM8plYKIesS4Jd32XnljUf+5Wr21
 fZ+UR9thk5kKUDBVcXk7E/KewhR4XtulAfljMrcCfiNYGTQrDJ4EF1AvjbDZkzjilzB1
 1k4tGbZ6wS/da8Gqb6S3LJWsxLFX5rCei0jdonnPR7zzIioIklmXmIkKlgBZLR+ERq9I
 TtV6o7qnXxRlP9zqMwKYrd9GYW6Mnx069+xDdw7tkMGQAZ/IdoP9rZYBB5nLy51sfqsR
 3SeQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=7ltXFGIEC1wD1/DcBqIE9Zp9UpD0Eob4weHsly+LU6s=;
 b=A2MPbrZffx7bc9MONX7mfEMxYqM0DtNUr6hT+dUj5GMReGoFXuaFBVLm72AC8ZNm3S
 f6vafBIcUlP3fBBN+6cpkAHq01VZ4Ds7gJHzqhGpZ5n8JKSKw2hS0d+8O4g6J97D2dRC
 StANbf9ET5uf35FjLmXIVJ0JE2neqI113N6oG8l6YvrL6AC3TNcZ1v/LJMRR5KRIQjML
 UZ5iFchFLay4Q11lcDTKBrR1WhfLTyeEapXVQAWDP/A9h40qZBpnrtlmLwVB8+yKggel
 zek0TiB5fGSV3tUPVAT4vo3FyiyHNvKC5oBVXIysEJnK2Vk3QYgFaeXqDBzDwxx8tYst
 visg==
X-Gm-Message-State: AOAM532R2o0kRssVZ+ozq5aO7yWq8f7RnLD263zfYAuQRuKOYQynkYX4
 vJPTnEgQUOae5DsvvHxei26tUwv0tFt09psj+Rq/xQ==
X-Google-Smtp-Source: ABdhPJzPd9Yn3eLEZ6vKKsiFecuFzporMourNqE58Gif0brpSLNfw6y269RW0/w1hGnLsri5OaWqZgnLzVxfJTsympg=
X-Received: by 2002:a19:c357:: with SMTP id t84mr1432560lff.34.1604085650471; 
 Fri, 30 Oct 2020 12:20:50 -0700 (PDT)
MIME-Version: 1.0
References: <63598b4f-6ce3-5a11-4552-cdfe308f68e4@gmail.com>
 <CAG48ez0fBE6AJfWh0in=WKkgt98y=KjAen=SQPyTYtvsUbF1yA@mail.gmail.com>
 <93cfdc79-4c48-bceb-3620-4c63e9f4822e@gmail.com>
In-Reply-To: <93cfdc79-4c48-bceb-3620-4c63e9f4822e@gmail.com>
Date: Fri, 30 Oct 2020 20:20:24 +0100
Message-ID: <CAG48ez3nH2Oiz9wMSpvUxxX_TRYTT98d3Nj1vnCuJOj9CCXH8Q@mail.gmail.com>
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

On Thu, Oct 29, 2020 at 8:14 PM Michael Kerrisk (man-pages)
<mtk.manpages@gmail.com> wrote:
> On 10/29/20 2:42 AM, Jann Horn wrote:
> > As discussed at
> > <https://lore.kernel.org/r/CAG48ez0m4Y24ZBZCh+Tf4ORMm9_q4n7VOzpGjwGF7_Fe8EQH=Q@mail.gmail.com>,
> > we need to re-check checkNotificationIdIsValid() after reading remote
> > memory but before using the read value in any way. Otherwise, the
> > syscall could in the meantime get interrupted by a signal handler, the
> > signal handler could return, and then the function that performed the
> > syscall could free() allocations or return (thereby freeing buffers on
> > the stack).
> >
> > In essence, this pread() is (unavoidably) a potential use-after-free
> > read; and to make that not have any security impact, we need to check
> > whether UAF read occurred before using the read value. This should
> > probably be called out elsewhere in the manpage, too...
> >
> > Now, of course, **reading** is the easy case. The difficult case is if
> > we have to **write** to the remote process... because then we can't
> > play games like that. If we write data to a freed pointer, we're
> > screwed, that's it. (And for somewhat unrelated bonus fun, consider
> > that /proc/$pid/mem is originally intended for process debugging,
> > including installing breakpoints, and will therefore happily write
> > over "readonly" private mappings, such as typical mappings of
> > executable code.)
> >
> > So, uuuuh... I guess if anyone wants to actually write memory back to
> > the target process, we'd better come up with some dedicated API for
> > that, using an ioctl on the seccomp fd that magically freezes the
> > target process inside the syscall while writing to its memory, or
> > something like that? And until then, the manpage should have a big fat
> > warning that writing to the target's memory is simply not possible
> > (safely).
>
> Thank you for your very clear explanation! It turned out to be
> trivially easy to demonstrate this issue with a slightly modified
> version of my program.
>
> As well as the change to the code example that I already mentioned
> my reply of a few hours ago, I've added the following text to the
> page:
>
>    Caveats regarding the use of /proc/[tid]/mem
>        The discussion above noted the need to use the
>        SECCOMP_IOCTL_NOTIF_ID_VALID ioctl(2) when opening the
>        /proc/[tid]/mem file of the target to avoid the possibility of
>        accessing the memory of the wrong process in the event that the
>        target terminates and its ID is recycled by another (unrelated)
>        thread.  However, the use of this ioctl(2) operation is also
>        necessary in other situations, as explained in the following
>        pargraphs.

(nit: paragraphs)

>        Consider the following scenario, where the supervisor tries to
>        read the pathname argument of a target's blocked mount(2) system
>        call:
[...]
> Seem okay?

Yeah, sounds good.

> By the way, is there any analogous kind of issue concerning
> pidfd_getfd()? I'm thinking not, but I wonder if I've missed
> something.

When it is used by a seccomp supervisor, you mean? I think basically
the same thing applies - when resource identifiers (such as memory
addresses or file descriptors) are passed to a syscall, it generally
has to be assumed that those identifiers may become invalid and be
reused as soon as the syscall has returned.
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
