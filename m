Return-Path: <SRS0=hUL4=EF=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14F33C00A89
	for <containers@archiver.kernel.org>; Fri, 30 Oct 2020 19:15:11 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 5A59A2072C
	for <containers@archiver.kernel.org>; Fri, 30 Oct 2020 19:15:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=google.com header.i=@google.com header.b="GEScQJl/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5A59A2072C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id C21F787516;
	Fri, 30 Oct 2020 19:15:09 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 4SqPrnrTouQu; Fri, 30 Oct 2020 19:15:09 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 0A4AB87553;
	Fri, 30 Oct 2020 19:15:09 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id CFF86C0859;
	Fri, 30 Oct 2020 19:15:08 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 8F069C0051
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Oct 2020 19:15:07 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 8478885FFC
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Oct 2020 19:15:07 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id jgC3ipdo40Sm
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Oct 2020 19:15:06 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-lf1-f54.google.com (mail-lf1-f54.google.com
 [209.85.167.54])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 1DD5486C6E
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Oct 2020 19:15:06 +0000 (UTC)
Received: by mail-lf1-f54.google.com with SMTP id b1so9201876lfp.11
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Oct 2020 12:15:06 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=wG/u6QLDIeO3+GPNzepwWscTWygaEgqcNOvOguEOtzE=;
 b=GEScQJl/XRE+Al+2evygNVW34IiBSkoia8s5HzAl8Hv6DEbsHP21Lirga/6tIsjkoR
 6pndjXo3bhKZOW1Dk5Uub2F/QyY+XpBeX+nLyHZxDUaPhBwraxjKmyUU389u1/xqXlL/
 voC7OY6hmd5Fr4gE/vpOFEq+3M/K4uBWKjshMkpddljKtLvb7oEgjUepvGxdHLB+qlRi
 lsXaJFer4KS7uPl33OEqYL9fA3HJYLgu76FbsgqoBkyILSU1vMZhuNLi6w9qOqfkXaAU
 ytPJv1sI1qSIE1x7QKh8O++0G+mtEs+XlsK0dEAC2cz1JpC6LyJR8sRuqTs2bq0q6mTh
 QDIw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=wG/u6QLDIeO3+GPNzepwWscTWygaEgqcNOvOguEOtzE=;
 b=SCViIpxyQ4melMXpEGcGD3s+zqmnKZUZq/F5wr7BwNRA7/PNh87pZUWJ4Mx+JsqQjP
 MQE0ez1N9IKq0aiuY9p3dFmQTXP8Q+k+hf3a4YTdxgKsiZE/KABLCWbgNxwT37UGdpvV
 rvbp4PZDe+unfVkCbpqkmIhSvzDcAIUhSAq8peyQQLwDqk+4BWz5SRhQFBFhv/77JsyU
 3o51C4LX66g3YrwZ/gdwr/ZPCw5nYoGpVFTI1P/1EOXXUxm8hxex3jsDgDZLxPcW3NiQ
 5Ya5kwIfT/sqV82n0Nvwjx9UVlJHJi5yuYBoMzdm9BOfpmRFhPzGvQNUUynYnGdj7Lgh
 NdVA==
X-Gm-Message-State: AOAM533J14ssEU/3qFuxWtjKawYOQGhpRvPnvVVL6bkqGp7gh0n4Y9m+
 vLI9aZqVOMS8eQHEYNkeNgpyfFSGlxpHJsEyw8vZQA==
X-Google-Smtp-Source: ABdhPJwWwVpiw9gJ/puN8rWssNkdz8vVGHPzS0mmXDNNvTGXQ5m+dUeuCNcHNeJlQwiyM5w1WvddtFCfbNI2DKeMRtk=
X-Received: by 2002:a05:6512:1054:: with SMTP id
 c20mr1626841lfb.576.1604085303713; 
 Fri, 30 Oct 2020 12:15:03 -0700 (PDT)
MIME-Version: 1.0
References: <63598b4f-6ce3-5a11-4552-cdfe308f68e4@gmail.com>
 <CAG48ez0fBE6AJfWh0in=WKkgt98y=KjAen=SQPyTYtvsUbF1yA@mail.gmail.com>
 <0de41eb1-e1fd-85da-61b7-fac4e3006726@gmail.com>
In-Reply-To: <0de41eb1-e1fd-85da-61b7-fac4e3006726@gmail.com>
Date: Fri, 30 Oct 2020 20:14:37 +0100
Message-ID: <CAG48ez3qKg-ReY4R=S_thQ6tOzv2ZHV=xW5qBxpqs0iSjH_oFQ@mail.gmail.com>
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

On Thu, Oct 29, 2020 at 3:19 PM Michael Kerrisk (man-pages)
<mtk.manpages@gmail.com> wrote:
> On 10/29/20 2:42 AM, Jann Horn wrote:
> > On Mon, Oct 26, 2020 at 10:55 AM Michael Kerrisk (man-pages)
> > <mtk.manpages@gmail.com> wrote:
> >>        static bool
> >>        getTargetPathname(struct seccomp_notif *req, int notifyFd,
> >>                          char *path, size_t len)
> >>        {
> >>            char procMemPath[PATH_MAX];
> >>
> >>            snprintf(procMemPath, sizeof(procMemPath), "/proc/%d/mem", req->pid);
> >>
> >>            int procMemFd = open(procMemPath, O_RDONLY);
> >>            if (procMemFd == -1)
> >>                errExit("\tS: open");
> >>
> >>            /* Check that the process whose info we are accessing is still alive.
> >>               If the SECCOMP_IOCTL_NOTIF_ID_VALID operation (performed
> >>               in checkNotificationIdIsValid()) succeeds, we know that the
> >>               /proc/PID/mem file descriptor that we opened corresponds to the
> >>               process for which we received a notification. If that process
> >>               subsequently terminates, then read() on that file descriptor
> >>               will return 0 (EOF). */
> >>
> >>            checkNotificationIdIsValid(notifyFd, req->id);
> >>
> >>            /* Read bytes at the location containing the pathname argument
> >>               (i.e., the first argument) of the mkdir(2) call */
> >>
> >>            ssize_t nread = pread(procMemFd, path, len, req->data.args[0]);
> >>            if (nread == -1)
> >>                errExit("pread");
> >
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
>
> Thanks very much for pointing me at this!
>
> So, I want to conform that the fix to the code is as simple as
> adding a check following the pread() call, something like:
>
> [[
>      ssize_t nread = pread(procMemFd, path, len, req->data.args[argNum]);
>      if (nread == -1)
>         errExit("Supervisor: pread");
>
>      if (nread == 0) {
>         fprintf(stderr, "\tS: pread() of /proc/PID/mem "
>                 "returned 0 (EOF)\n");
>         exit(EXIT_FAILURE);
>      }
>
>      if (close(procMemFd) == -1)
>         errExit("Supervisor: close-/proc/PID/mem");
>
> +    /* Once again check that the notification ID is still valid. The
> +       case we are particularly concerned about here is that just
> +       before we fetched the pathname, the target's blocked system
> +       call was interrupted by a signal handler, and after the handler
> +       returned, the target carried on execution (past the interrupted
> +       system call). In that case, we have no guarantees about what we
> +       are reading, since the target's memory may have been arbitrarily
> +       changed by subsequent operations. */
> +
> +    if (!notificationIdIsValid(notifyFd, req->id, "post-open"))
> +        return false;
> +
>      /* We have no guarantees about what was in the memory of the target
>         process. We therefore treat the buffer returned by pread() as
>         untrusted input. The buffer should be terminated by a null byte;
>         if not, then we will trigger an error for the target process. */
>
>      if (strnlen(path, nread) < nread)
>          return true;
> ]]

Yeah, that should do the job. With the caveat that a cancelled syscall
could've also led to the memory being munmap()ed, so the nread==0 case
could also happen legitimately - so you might want to move this check
up above the nread==0 (mm went away) and nread==-1 (mm still exists,
but read from address failed, errno EIO) checks if the error message
shouldn't appear spuriously.
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
