Return-Path: <SRS0=ql3H=ED=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D1E0C388F7
	for <containers@archiver.kernel.org>; Wed, 28 Oct 2020 09:43:48 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 44D282469D
	for <containers@archiver.kernel.org>; Wed, 28 Oct 2020 09:43:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=google.com header.i=@google.com header.b="HFAjXWqA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 44D282469D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id A2F0F8601B;
	Wed, 28 Oct 2020 09:43:46 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id wiO3qhKnK1G9; Wed, 28 Oct 2020 09:43:46 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id EF78A85B7C;
	Wed, 28 Oct 2020 09:43:45 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id D153FC0859;
	Wed, 28 Oct 2020 09:43:45 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id D21A3C0051
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Oct 2020 09:43:44 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id C919185CD5
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Oct 2020 09:43:44 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id a2bszCB2DJap
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Oct 2020 09:43:44 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-lf1-f66.google.com (mail-lf1-f66.google.com
 [209.85.167.66])
 by whitealder.osuosl.org (Postfix) with ESMTPS id B8FF685B7C
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Oct 2020 09:43:43 +0000 (UTC)
Received: by mail-lf1-f66.google.com with SMTP id a7so6334111lfk.9
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Oct 2020 02:43:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=AFQ11nKNwZI/oGFeZxcljdz8x6kEb8+uWHBsNPCDUO0=;
 b=HFAjXWqAbYshDr2yDxrNzRjLAazYy3NYleGOwhPwLv1pzOgTqSzUGl4QAew8/0Ue0Z
 UoM2bHGRSrCMkFFIE/eRm1e9A6GSJQQnBj0G0icXRTO3f42Z/TOgD2ZwXEDyH4EQzhtk
 ywG5wEF7+x5kI5uzusYn+VP7eFH2BvWpSYX2QaSH7NVhnOuxIXe879Y+CazILhKsmJD6
 IL/m69v/0hvM8YmGddWOL1C5qP87stMvRtBRmf4MLpcBB3WPUywYeyXiWwll/+B6xjhd
 0IHI4V6rTlKalnDT1Hs7tkfxy9/KFXAims9NH7Xvmh8xuaLNrqF4bCuC4UhMykb0uAU1
 +C5w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=AFQ11nKNwZI/oGFeZxcljdz8x6kEb8+uWHBsNPCDUO0=;
 b=WAlwl1nXOPyG1L7KwAdzfOzZ1XOujRDSSKMw2VtQK7QVhF3lSEUt8UGEtccyh11lYn
 uvOmnTk4mcEUEg7UOCYqFQZYh5NkL7YT/mvzvT9gYQmUE7U+AmUnkWC85JkeoelQG1cj
 ferizMcSDb6CongYU/C5ABCa+5HnG4cfJgkpCFAIpCAxsMnWJuB2GZsDdfzJbnA0e9xK
 abyaDDOALWigUXb7eVaBOHA78W4N+T+i//kAwOrPyv4t+RxRPHI73jDQytMPmlYvHBWh
 f5d3Tm/81E++Qo8Kwe1lON8ukPqB3cSRzxpLXuuCH93YKpiP8apg+a6T4AvknLidCkFN
 BrLA==
X-Gm-Message-State: AOAM533vS6NDTZ8PKJTIL1XhsgedOR1XRbJI0uQtB0t3QREzjxrYUaaY
 KB1pVYMkY/OpaVX06tdbiWGSHxTFVRa1W7iRd4reog==
X-Google-Smtp-Source: ABdhPJwVRGG3pvmn4VHogbgp0mRkC+3Vo3abv5ijmC6QlpCo8lhtrVsa4JWD3BkVHYUkQR8qg4e+R3v66NEu2I+If+A=
X-Received: by 2002:a05:6512:1054:: with SMTP id
 c20mr2561887lfb.576.1603878221599; 
 Wed, 28 Oct 2020 02:43:41 -0700 (PDT)
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
 <CAMp4zn_Qt2MYuoLojn5ikRkr-J5yGimirjevoAvorK5wfzrBHg@mail.gmail.com>
In-Reply-To: <CAMp4zn_Qt2MYuoLojn5ikRkr-J5yGimirjevoAvorK5wfzrBHg@mail.gmail.com>
Date: Wed, 28 Oct 2020 10:43:14 +0100
Message-ID: <CAG48ez1drOxgcpuKHiJc+khwmLvqoXfK4yBt9_KHPGQipDf6NQ@mail.gmail.com>
Subject: Re: For review: seccomp_user_notif(2) manual page
To: Sargun Dhillon <sargun@sargun.me>
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
From: Jann Horn via Containers <containers@lists.linux-foundation.org>
Reply-To: Jann Horn <jannh@google.com>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

On Wed, Oct 28, 2020 at 7:32 AM Sargun Dhillon <sargun@sargun.me> wrote:
> On Tue, Oct 27, 2020 at 3:28 AM Jann Horn <jannh@google.com> wrote:
> > On Tue, Oct 27, 2020 at 7:14 AM Michael Kerrisk (man-pages)
> > <mtk.manpages@gmail.com> wrote:
> > > On 10/26/20 4:54 PM, Jann Horn wrote:
> > > > I'm a bit on the fence now on whether non-blocking mode should use
> > > > ENOTCONN or not... I guess if we returned ENOENT even when there are
> > > > no more listeners, you'd have to disambiguate through the poll()
> > > > revents, which would be kinda ugly?
> > >
> > > I must confess, I'm not quite clear on which two cases you
> > > are trying to distinguish. Can you elaborate?
> >
> > Let's say someone writes a program whose responsibilities are just to
> > handle seccomp events and to listen on some other fd for commands. And
> > this is implemented with an event loop. Then once all the target
> > processes are gone (including zombie reaping), we'll start getting
> > EPOLLERR.
> >
> > If NOTIF_RECV starts returning -ENOTCONN at this point, the event loop
> > can just call into the seccomp logic without any arguments; it can
> > just call NOTIF_RECV one more time, see the -ENOTCONN, and terminate.
> > The downside is that there's one more error code userspace has to
> > special-case.
> > This would be more consistent with what we'd be doing in the blocking case.
> >
> > If NOTIF_RECV keeps returning -ENOENT, the event loop has to also tell
> > the seccomp logic what the revents are.
> >
> > I guess it probably doesn't really matter much.
>
> So, in practice, if you're emulating a blocking syscall (such as open,
> perf_event_open, or any of a number of other syscalls), you probably
> have to do it on a separate thread in the supervisor because you want
> to continue to be able to receive new notifications if any other process
> generates a seccomp notification event that you need to handle.
>
> In addition to that, some of these syscalls are preemptible, so you need
> to poll SECCOMP_IOCTL_NOTIF_ID_VALID to make sure that the program
> under supervision hasn't left the syscall.
>
> If we're to implement a mechanism that makes the seccomp ioctl receive
> non-blocking, it would be valuable to address this problem as well (getting
> a notification when the supervisor is processing a syscall and needs to
> preempt it). In the best case, this can be a minor inconvenience, and
> in the worst case this can result in weird errors where you're keeping
> resources open that the container expects to be closed.

Does "a notification" mean signals? Or would you want to have a second
thread in userspace that poll()s for cancellation events on the
seccomp fd and then somehow takes care of interrupting the first
thread, or something like that?

Either way, I think your proposal goes beyond the scope of patching
the existing weirdness, and should be a separate patch.
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
