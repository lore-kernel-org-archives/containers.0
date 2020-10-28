Return-Path: <SRS0=ql3H=ED=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4EC15C4363A
	for <containers@archiver.kernel.org>; Wed, 28 Oct 2020 06:32:23 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 5F713238E6
	for <containers@archiver.kernel.org>; Wed, 28 Oct 2020 06:32:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=sargun.me header.i=@sargun.me header.b="OH+AqmBT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F713238E6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sargun.me
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id A827D20459;
	Wed, 28 Oct 2020 06:32:21 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ssyB-15Ly6iR; Wed, 28 Oct 2020 06:32:19 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id B9970203CA;
	Wed, 28 Oct 2020 06:32:19 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id A72AFC088B;
	Wed, 28 Oct 2020 06:32:19 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 4DD47C0051
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Oct 2020 06:32:18 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 347A286B71
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Oct 2020 06:32:18 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id YVhCbltG7BFD
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Oct 2020 06:32:17 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from mail-ed1-f65.google.com (mail-ed1-f65.google.com
 [209.85.208.65])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 3C95F8589A
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Oct 2020 06:32:17 +0000 (UTC)
Received: by mail-ed1-f65.google.com with SMTP id dn5so3917765edb.10
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Oct 2020 23:32:17 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sargun.me; s=google;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=qt8DJxbLetO1WoXKcxRo5toKKtnSgKB5eVlWB58cOkk=;
 b=OH+AqmBT9Kdmi64IsMGc8MSNykUCembPpixPv4zzBrzrPu4ucwFsORVaHkMGcfPA4r
 8uCQVHV+8Wyli+9AttwM7qpv4f4tNC2hdEunrUWLLkSkWs0PWOUCa+n8YKIabHg6GLd7
 hiwxshPZf7ZvPf+4dweotp+Ny/sGKfx7EeycI=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=qt8DJxbLetO1WoXKcxRo5toKKtnSgKB5eVlWB58cOkk=;
 b=h30VGxg/+aEDMaNOKWLqQqgdWu+yuEEVWLiYhU/i2rUraJU6aeWERl3J7UjFuszt8m
 /bbNGv8x4K5k+3uoub8vlyYuwtHb68IRvbUcKpZariTEcqAv5OhMsmiBgjT95dcGQulo
 bpgRLSBQkPMRaj21rRuQQTdPiMtblA6rwpp4RIQYdCGZkR2VF5te7q23iqJrouM8PALM
 p13Zy6wnS2T/NBwjB2RF4Ji13ywVC6SIuZWwg9KjIcyvBoQBjvvXVKgSy42g1uFvlKFy
 JS2rTCrn1Hmu1UN4RV4v9UMuzit0BZZ5/4nYNM/uyu7b4Z+QDqGBWxdVdRq6sf0j7RkZ
 RTJA==
X-Gm-Message-State: AOAM532c3Sxdtw5eziIY4rdaDbueS3Q4dXgFpIb59pYWim1WSOdCuMX4
 Os/gRjsEmW6/2TtV1GyXgS7Nx+LNoY0dOz8KxlSvlg==
X-Google-Smtp-Source: ABdhPJwxL/cNreEkGxZEeBkLMJW+nXtxbWJBnh3oGKara0Jkz/gJF9pPGAqnIO/XhWtV5NKiBIa/b6QweHKnigrOa6I=
X-Received: by 2002:a50:fb06:: with SMTP id d6mr6238984edq.312.1603866735356; 
 Tue, 27 Oct 2020 23:32:15 -0700 (PDT)
MIME-Version: 1.0
References: <45f07f17-18b6-d187-0914-6f341fe90857@gmail.com>
 <20200930150330.GC284424@cisco>
 <8bcd956f-58d2-d2f0-ca7c-0a30f3fcd5b8@gmail.com>
 <20200930230327.GA1260245@cisco>
 <CAG48ez1VOUEHVQyo-2+uO7J+-jN5rh7=KmrMJiPaFjwCbKR1Sg@mail.gmail.com>
 <20200930232456.GB1260245@cisco>
 <CAG48ez2xn+_KznEztJ-eVTsTzkbf9CVgPqaAk7TpRNAqbdaRoA@mail.gmail.com>
 <CAG48ez3kpEDO1x_HfvOM2R9M78Ach9O_4+Pjs-vLLfqvZL+13A@mail.gmail.com>
 <656a37b5-75e3-0ded-6ba8-3bb57b537b24@gmail.com>
 <CAG48ez2Uy8=Tz9k1hcr0suLPHjbJi1qUviSGzDQ-XWEGsdNU+A@mail.gmail.com>
 <e2643168-b5d5-4d8c-947a-7895bcabc268@gmail.com>
 <CAG48ez2Nb95ae+XwZPYRju1KO-Ps_4R6QxN6ioUhOy2Uok=uAg@mail.gmail.com>
In-Reply-To: <CAG48ez2Nb95ae+XwZPYRju1KO-Ps_4R6QxN6ioUhOy2Uok=uAg@mail.gmail.com>
From: Sargun Dhillon <sargun@sargun.me>
Date: Tue, 27 Oct 2020 23:31:39 -0700
Message-ID: <CAMp4zn_Qt2MYuoLojn5ikRkr-J5yGimirjevoAvorK5wfzrBHg@mail.gmail.com>
Subject: Re: For review: seccomp_user_notif(2) manual page
To: Jann Horn <jannh@google.com>
Cc: linux-man <linux-man@vger.kernel.org>, Song Liu <songliubraving@fb.com>,
 Will Drewry <wad@chromium.org>, Kees Cook <keescook@chromium.org>,
 Daniel Borkmann <daniel@iogearbox.net>,
 Giuseppe Scrivano <gscrivan@redhat.com>, Robert Sesek <rsesek@google.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 lkml <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
 "Michael Kerrisk \(man-pages\)" <mtk.manpages@gmail.com>,
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
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

On Tue, Oct 27, 2020 at 3:28 AM Jann Horn <jannh@google.com> wrote:
>
> On Tue, Oct 27, 2020 at 7:14 AM Michael Kerrisk (man-pages)
> <mtk.manpages@gmail.com> wrote:
> > On 10/26/20 4:54 PM, Jann Horn wrote:
> > > I'm a bit on the fence now on whether non-blocking mode should use
> > > ENOTCONN or not... I guess if we returned ENOENT even when there are
> > > no more listeners, you'd have to disambiguate through the poll()
> > > revents, which would be kinda ugly?
> >
> > I must confess, I'm not quite clear on which two cases you
> > are trying to distinguish. Can you elaborate?
>
> Let's say someone writes a program whose responsibilities are just to
> handle seccomp events and to listen on some other fd for commands. And
> this is implemented with an event loop. Then once all the target
> processes are gone (including zombie reaping), we'll start getting
> EPOLLERR.
>
> If NOTIF_RECV starts returning -ENOTCONN at this point, the event loop
> can just call into the seccomp logic without any arguments; it can
> just call NOTIF_RECV one more time, see the -ENOTCONN, and terminate.
> The downside is that there's one more error code userspace has to
> special-case.
> This would be more consistent with what we'd be doing in the blocking case.
>
> If NOTIF_RECV keeps returning -ENOENT, the event loop has to also tell
> the seccomp logic what the revents are.
>
> I guess it probably doesn't really matter much.

So, in practice, if you're emulating a blocking syscall (such as open,
perf_event_open, or any of a number of other syscalls), you probably
have to do it on a separate thread in the supervisor because you want
to continue to be able to receive new notifications if any other process
generates a seccomp notification event that you need to handle.

In addition to that, some of these syscalls are preemptible, so you need
to poll SECCOMP_IOCTL_NOTIF_ID_VALID to make sure that the program
under supervision hasn't left the syscall.

If we're to implement a mechanism that makes the seccomp ioctl receive
non-blocking, it would be valuable to address this problem as well (getting
a notification when the supervisor is processing a syscall and needs to
preempt it). In the best case, this can be a minor inconvenience, and
in the worst case this can result in weird errors where you're keeping
resources open that the container expects to be closed.
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
