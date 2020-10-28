Return-Path: <SRS0=ql3H=ED=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3CEC2C4363A
	for <containers@archiver.kernel.org>; Wed, 28 Oct 2020 18:39:58 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 7603424810
	for <containers@archiver.kernel.org>; Wed, 28 Oct 2020 18:39:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=sargun.me header.i=@sargun.me header.b="tF7de7mb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7603424810
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sargun.me
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id D025286B05;
	Wed, 28 Oct 2020 18:39:56 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 5JA+QfcJBBLf; Wed, 28 Oct 2020 18:39:56 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 0D4F186A1A;
	Wed, 28 Oct 2020 18:39:56 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id E971BC088B;
	Wed, 28 Oct 2020 18:39:55 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 4DF07C0051
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Oct 2020 18:39:54 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 2175E20796
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Oct 2020 18:39:54 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id NkpHLJngHvFi
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Oct 2020 18:39:52 +0000 (UTC)
X-Greylist: delayed 00:28:45 by SQLgrey-1.7.6
Received: from mail-lf1-f67.google.com (mail-lf1-f67.google.com
 [209.85.167.67])
 by silver.osuosl.org (Postfix) with ESMTPS id E57C120414
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Oct 2020 18:39:51 +0000 (UTC)
Received: by mail-lf1-f67.google.com with SMTP id r127so3324lff.12
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Oct 2020 11:39:51 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sargun.me; s=google;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=1KKfnGnBEdd12X89nwYRLUfbpvsSCoekdcU0DHREQhE=;
 b=tF7de7mbM6VeEXWhVjMrNC5cvKMpl0WDoIIp7fDbiFMyA9PP4g3gTmf4LaBzwarT14
 4HlQUlmQiDgdPcyNEbZCIirlXnui4R0jL648Tx95iRiVKLtDrIrgQ3s56LWy8BP1Jh4m
 e5D2GJEtVeWX660AowCOJZdoycU2F+72CGe2Y=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=1KKfnGnBEdd12X89nwYRLUfbpvsSCoekdcU0DHREQhE=;
 b=cGI+eAvEI3GIrOPx+jNyooC8oVZCW7IZhEl9ieZoq7XvYmK4MhEC3Qmy+NWq+sPOzy
 GnArjhkyg+0uoY2XDs9gUOIDrHW0AZmc/slDCUAl7BER0D0drkFzi1qqtzNXRXrww1S6
 uHbK74vPX9hnFQhQVx6f22RiyDoifB3gcfGgo4LeAlp1I9FuF6UYdzEOENpLTKx5FEzT
 V4XfUnQIX9TdMcnJ1Gf/i09es3iSDqyTIc2+yzz14eTQL9ISTpHy2NDd+kfkuLPaZOES
 j2SHCLDzRZ73yqZSznCu3aZvMf62gYFM2IeALgwG7pPgb0X+UoZmeyxbIg6ij+EOXRkx
 PAFA==
X-Gm-Message-State: AOAM533k4yRxrJkpb/EEUw/9v9S7JiOLlZJdd9v+6W0t7PTCryJUlbSE
 OdDTTu+hw/zkuMeZYjwR9I1f2OoCJmMsSDK7uTZBAK11if4dlCol
X-Google-Smtp-Source: ABdhPJxusKQfLH7ldNK0ZejYey8JceBXqtdks06+e2oAEK1AFi5yniwjLl5sysSu+nsrzKiTHTK4yg881qNZWDn/8tc=
X-Received: by 2002:a17:906:bc42:: with SMTP id
 s2mr173094ejv.251.1603907070187; 
 Wed, 28 Oct 2020 10:44:30 -0700 (PDT)
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
 <CAG48ez1drOxgcpuKHiJc+khwmLvqoXfK4yBt9_KHPGQipDf6NQ@mail.gmail.com>
In-Reply-To: <CAG48ez1drOxgcpuKHiJc+khwmLvqoXfK4yBt9_KHPGQipDf6NQ@mail.gmail.com>
From: Sargun Dhillon <sargun@sargun.me>
Date: Wed, 28 Oct 2020 10:43:54 -0700
Message-ID: <CAMp4zn9O-a3_wzO1RLr8uujdS+fGYTC0+b=MRQK9TihLToU--w@mail.gmail.com>
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

On Wed, Oct 28, 2020 at 2:43 AM Jann Horn <jannh@google.com> wrote:
>
> On Wed, Oct 28, 2020 at 7:32 AM Sargun Dhillon <sargun@sargun.me> wrote:
> > On Tue, Oct 27, 2020 at 3:28 AM Jann Horn <jannh@google.com> wrote:
> > > On Tue, Oct 27, 2020 at 7:14 AM Michael Kerrisk (man-pages)
> > > <mtk.manpages@gmail.com> wrote:
> > > > On 10/26/20 4:54 PM, Jann Horn wrote:
> > > > > I'm a bit on the fence now on whether non-blocking mode should use
> > > > > ENOTCONN or not... I guess if we returned ENOENT even when there are
> > > > > no more listeners, you'd have to disambiguate through the poll()
> > > > > revents, which would be kinda ugly?
> > > >
> > > > I must confess, I'm not quite clear on which two cases you
> > > > are trying to distinguish. Can you elaborate?
> > >
> > > Let's say someone writes a program whose responsibilities are just to
> > > handle seccomp events and to listen on some other fd for commands. And
> > > this is implemented with an event loop. Then once all the target
> > > processes are gone (including zombie reaping), we'll start getting
> > > EPOLLERR.
> > >
> > > If NOTIF_RECV starts returning -ENOTCONN at this point, the event loop
> > > can just call into the seccomp logic without any arguments; it can
> > > just call NOTIF_RECV one more time, see the -ENOTCONN, and terminate.
> > > The downside is that there's one more error code userspace has to
> > > special-case.
> > > This would be more consistent with what we'd be doing in the blocking case.
> > >
> > > If NOTIF_RECV keeps returning -ENOENT, the event loop has to also tell
> > > the seccomp logic what the revents are.
> > >
> > > I guess it probably doesn't really matter much.
> >
> > So, in practice, if you're emulating a blocking syscall (such as open,
> > perf_event_open, or any of a number of other syscalls), you probably
> > have to do it on a separate thread in the supervisor because you want
> > to continue to be able to receive new notifications if any other process
> > generates a seccomp notification event that you need to handle.
> >
> > In addition to that, some of these syscalls are preemptible, so you need
> > to poll SECCOMP_IOCTL_NOTIF_ID_VALID to make sure that the program
> > under supervision hasn't left the syscall.
> >
> > If we're to implement a mechanism that makes the seccomp ioctl receive
> > non-blocking, it would be valuable to address this problem as well (getting
> > a notification when the supervisor is processing a syscall and needs to
> > preempt it). In the best case, this can be a minor inconvenience, and
> > in the worst case this can result in weird errors where you're keeping
> > resources open that the container expects to be closed.
>
> Does "a notification" mean signals? Or would you want to have a second
> thread in userspace that poll()s for cancellation events on the
> seccomp fd and then somehow takes care of interrupting the first
> thread, or something like that?

I would be reluctant to be prescriptive in that it be a signal. Right
now, it's implemented
as a second thread in userspace that does a ioctl(...) and checks if
the notification
is valid / alive, and does what's required if the notification has
died (interrupting
the first thread).

>
> Either way, I think your proposal goes beyond the scope of patching
> the existing weirdness, and should be a separate patch.

I agree it should be a separate patch, but I think that it'd be nice if there
was a way to do something like:
* opt-in to getting another message after receiving the notification
  that indicates the program has left the syscall
* when you do the RECV, you can specify a flag or some such asking
  that you get signaled / notified about the program leaving the syscall
* a multiplexed receive that can say if an existing notification in progress
  has left the valid state.

---
The reason I bring this up as part of this current thread / discussion is that
I think that they may be related in terms of how we want the behaviour to act.

I would love to hear how people think this should work, or better suggestions
than the second thread approach above, or the alternative approach of
polling all the notifications in progress on some interval [and relying on
epoll timeout to trigger that interval].
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
