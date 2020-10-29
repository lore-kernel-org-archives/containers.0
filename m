Return-Path: <SRS0=MeFG=EE=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A184C4363A
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 01:43:31 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id CA39420780
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 01:43:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=google.com header.i=@google.com header.b="sLyaw6q6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA39420780
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 2C1B187371;
	Thu, 29 Oct 2020 01:43:30 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id p61Ssl0nHuWF; Thu, 29 Oct 2020 01:43:29 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 5E80F87350;
	Thu, 29 Oct 2020 01:43:29 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 4DF77C0859;
	Thu, 29 Oct 2020 01:43:29 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id A377AC0051
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 01:43:28 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 82B3C207A1
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 01:43:28 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id Q2qm1QYEBMP3
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 01:43:27 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-lj1-f182.google.com (mail-lj1-f182.google.com
 [209.85.208.182])
 by silver.osuosl.org (Postfix) with ESMTPS id D53ED20514
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 01:43:26 +0000 (UTC)
Received: by mail-lj1-f182.google.com with SMTP id x16so1382003ljh.2
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Oct 2020 18:43:26 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=geZ/oO3CDuXNyCg7XC5g4ztQiJhRJ6O3ZCqLsRDfncw=;
 b=sLyaw6q6IpMdxy0i+OrwQjeQfMFuDOZH3wZnxjQU/9rDKBm6tuuxuSZwVs5vSb5WCr
 dhr5wJNw0eYDPLOVlnAfChnG0rwQ3X3IxyOhhms90HJjdyXu5TJC0nW/joAq2f2CND/0
 CfiNH8M48AdnqYWCsLEkk41NY0rIcwZgm0kQcdKN0ApOcudxbm6lIQIC9aN3G5/6sTDd
 E0nFCedw0IDNiUhrY+kLYDTgjCvAEsr7GQTQqiccy0MVtif7ayBSqtuFcqw/pBfWXhhK
 7t/SE3CAxJQ50Fz1/BKEQTbMkwVW/T9PhUh0MdDok3/8p8gBv5Oh9gBVe4i4ApP4av2Y
 EmxQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=geZ/oO3CDuXNyCg7XC5g4ztQiJhRJ6O3ZCqLsRDfncw=;
 b=N4TsmZ4BbFDFd6XLh4g9UdDkFybL1d1DbseJjA87UuOcVF9joQvov4I9LHNvenn/JN
 17TgOAhxf0s/XKHWcaAUpqLJ7EHfVuu1I+54HLSEhZ/v7Nrf98SpR849zh3NLQLGAq43
 fJVDhndeN21a+dQofmCn0o+RaXeC8GYIVSLp2ixoSk0dj5qGvioPrtPhXQ6JlVPYVE9z
 HM2iVSjrLxAk5Pm2qd8J96YTs4rpPRjCXbiF7LLL9vptFxHdWRmduUPqMoVIlNXiClo5
 RnmNYvewJhu2gLJw3FtqpGJJyVlk0Hfk3tY9NtCLzEFXfN6ujdRJz8WSyyt3qudiu0+n
 2p8w==
X-Gm-Message-State: AOAM533iu90omS7Uh89Lk7YCDjJjc/+12oEt7eUuCRWF3royuVr2h5Mb
 XGnibzCndFPOlZMeT9aCclkSxoXidsAbcsIDhIXFng==
X-Google-Smtp-Source: ABdhPJz6TDKuIczDEuNWhwAZLwIsi7p/r5pwANkEoLv02bXcTUl1ox9pp4nTanH9lSHFwu+RpElyT1qPIgjQUosCQDo=
X-Received: by 2002:a2e:b6cf:: with SMTP id m15mr744683ljo.74.1603935804881;
 Wed, 28 Oct 2020 18:43:24 -0700 (PDT)
MIME-Version: 1.0
References: <63598b4f-6ce3-5a11-4552-cdfe308f68e4@gmail.com>
In-Reply-To: <63598b4f-6ce3-5a11-4552-cdfe308f68e4@gmail.com>
Date: Thu, 29 Oct 2020 02:42:58 +0100
Message-ID: <CAG48ez0fBE6AJfWh0in=WKkgt98y=KjAen=SQPyTYtvsUbF1yA@mail.gmail.com>
Subject: Re: For review: seccomp_user_notif(2) manual page [v2]
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>,
 Kees Cook <keescook@chromium.org>
Cc: Giuseppe Scrivano <gscrivan@redhat.com>, Song Liu <songliubraving@fb.com>,
 Will Drewry <wad@chromium.org>, Robert Sesek <rsesek@google.com>,
 Daniel Borkmann <daniel@iogearbox.net>, linux-man <linux-man@vger.kernel.org>,
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

On Mon, Oct 26, 2020 at 10:55 AM Michael Kerrisk (man-pages)
<mtk.manpages@gmail.com> wrote:
>        static bool
>        getTargetPathname(struct seccomp_notif *req, int notifyFd,
>                          char *path, size_t len)
>        {
>            char procMemPath[PATH_MAX];
>
>            snprintf(procMemPath, sizeof(procMemPath), "/proc/%d/mem", req->pid);
>
>            int procMemFd = open(procMemPath, O_RDONLY);
>            if (procMemFd == -1)
>                errExit("\tS: open");
>
>            /* Check that the process whose info we are accessing is still alive.
>               If the SECCOMP_IOCTL_NOTIF_ID_VALID operation (performed
>               in checkNotificationIdIsValid()) succeeds, we know that the
>               /proc/PID/mem file descriptor that we opened corresponds to the
>               process for which we received a notification. If that process
>               subsequently terminates, then read() on that file descriptor
>               will return 0 (EOF). */
>
>            checkNotificationIdIsValid(notifyFd, req->id);
>
>            /* Read bytes at the location containing the pathname argument
>               (i.e., the first argument) of the mkdir(2) call */
>
>            ssize_t nread = pread(procMemFd, path, len, req->data.args[0]);
>            if (nread == -1)
>                errExit("pread");

As discussed at
<https://lore.kernel.org/r/CAG48ez0m4Y24ZBZCh+Tf4ORMm9_q4n7VOzpGjwGF7_Fe8EQH=Q@mail.gmail.com>,
we need to re-check checkNotificationIdIsValid() after reading remote
memory but before using the read value in any way. Otherwise, the
syscall could in the meantime get interrupted by a signal handler, the
signal handler could return, and then the function that performed the
syscall could free() allocations or return (thereby freeing buffers on
the stack).

In essence, this pread() is (unavoidably) a potential use-after-free
read; and to make that not have any security impact, we need to check
whether UAF read occurred before using the read value. This should
probably be called out elsewhere in the manpage, too...

Now, of course, **reading** is the easy case. The difficult case is if
we have to **write** to the remote process... because then we can't
play games like that. If we write data to a freed pointer, we're
screwed, that's it. (And for somewhat unrelated bonus fun, consider
that /proc/$pid/mem is originally intended for process debugging,
including installing breakpoints, and will therefore happily write
over "readonly" private mappings, such as typical mappings of
executable code.)

So, uuuuh... I guess if anyone wants to actually write memory back to
the target process, we'd better come up with some dedicated API for
that, using an ioctl on the seccomp fd that magically freezes the
target process inside the syscall while writing to its memory, or
something like that? And until then, the manpage should have a big fat
warning that writing to the target's memory is simply not possible
(safely).

>            if (nread == 0) {
>                fprintf(stderr, "\tS: pread() of /proc/PID/mem "
>                        "returned 0 (EOF)\n");
>                exit(EXIT_FAILURE);
>            }
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
