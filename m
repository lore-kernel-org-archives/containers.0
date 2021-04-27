Return-Path: <SRS0=Ze4f=JY=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A50BAC43461
	for <containers@archiver.kernel.org>; Tue, 27 Apr 2021 22:10:38 +0000 (UTC)
Received: from smtp3.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id B1F78613B4
	for <containers@archiver.kernel.org>; Tue, 27 Apr 2021 22:10:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B1F78613B4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sargun.me
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp3.osuosl.org (Postfix) with ESMTP id 4FCC860A47;
	Tue, 27 Apr 2021 22:10:37 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp3.osuosl.org ([127.0.0.1])
	by localhost (smtp3.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id e0Z-wNiNTdSx; Tue, 27 Apr 2021 22:10:35 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [IPv6:2605:bc80:3010:104::8cd3:938])
	by smtp3.osuosl.org (Postfix) with ESMTP id 34B99608CF;
	Tue, 27 Apr 2021 22:10:35 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 07F94C001C;
	Tue, 27 Apr 2021 22:10:35 +0000 (UTC)
Received: from smtp2.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 2185FC0001
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Apr 2021 22:10:34 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp2.osuosl.org (Postfix) with ESMTP id 089B0403E7
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Apr 2021 22:10:34 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Authentication-Results: smtp2.osuosl.org (amavisd-new);
 dkim=pass (1024-bit key) header.d=sargun.me
Received: from smtp2.osuosl.org ([127.0.0.1])
 by localhost (smtp2.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id poZdKBWpRMwM
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Apr 2021 22:10:32 +0000 (UTC)
X-Greylist: whitelisted by SQLgrey-1.8.0
Received: from mail-il1-x131.google.com (mail-il1-x131.google.com
 [IPv6:2607:f8b0:4864:20::131])
 by smtp2.osuosl.org (Postfix) with ESMTPS id A8F4340001
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Apr 2021 22:10:32 +0000 (UTC)
Received: by mail-il1-x131.google.com with SMTP id j12so5894632ils.4
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Apr 2021 15:10:32 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sargun.me; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:in-reply-to:user-agent;
 bh=J3OZQuMMYXhVRdbAGQKUg7Wra51AHbtP59/ycR6cv1A=;
 b=oLMo6M7eRBG1HrCjd7sWkyEU1zNn7c1dNI2nSNyG7pjWl3w068pOFMPhpW/AcnTaPv
 tCdMb6rULM+RIohelzjfDLq+l6ZbzrKLyBWjTm5BbpCT+ODZhmB/LKNRZDXI0vUJQYE3
 sV/EQ7yolgixvjTxAhI1tFHPkXqX3J3uqn6vQ=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:in-reply-to:user-agent;
 bh=J3OZQuMMYXhVRdbAGQKUg7Wra51AHbtP59/ycR6cv1A=;
 b=txQz0XaGIS7cfUW81fw3As474thz9VbSZYlyPrPC4YKdYyED8peTRNpR1c4XELmrSt
 11zfDvBeqGyEyVLfSWvYf33tLHLUjGmtVL5Nu+qHENCS30i2Zv553RvSqcYUTVnt0ylX
 N+e7BHwSWQOonQVJb1+zUI8x18j2OLSWFqfmXzZc5mXT6OMSgo4csu8VjThtzj1CpCeb
 mmyDh/kBH0LdpeQArittVWvBAiIZbtcLdifqTYDMXJE3YL0YzsVzrfCJW3iGptMjvjFA
 l3IqSU6F7Dm2eCkSTZ95Z3sGhWkmZIQ8/7PYxGe9nxWCsqUws5q2Juc9fXkCb2gQ/y9h
 HHbQ==
X-Gm-Message-State: AOAM533x4Tq9XxrLd5DC42gZgzyiyd53iw6o2x0Gx5uP41J2RrTYKC1g
 S8yj3R08iuNajVCWf97USy3fMg==
X-Google-Smtp-Source: ABdhPJw34ZHavmKPDKd0vx3zQxgvpuLI+I18D2MJ1XBSYeqrCsPCmQS1A/sWP4DQ9voyjhp4gEccCg==
X-Received: by 2002:a92:c0c2:: with SMTP id t2mr20188209ilf.210.1619561431634; 
 Tue, 27 Apr 2021 15:10:31 -0700 (PDT)
Received: from ircssh-2.c.rugged-nimbus-611.internal
 (80.60.198.104.bc.googleusercontent.com. [104.198.60.80])
 by smtp.gmail.com with ESMTPSA id n22sm528725ioc.5.2021.04.27.15.10.30
 (version=TLS1_2 cipher=ECDHE-ECDSA-CHACHA20-POLY1305 bits=256/256);
 Tue, 27 Apr 2021 15:10:30 -0700 (PDT)
Date: Tue, 27 Apr 2021 22:10:29 +0000
From: Sargun Dhillon <sargun@sargun.me>
To: Tycho Andersen <tycho@tycho.pizza>
Subject: Re: [PATCH RESEND 2/5] seccomp: Add wait_killable semantic to
 seccomp user notifier
Message-ID: <20210427221028.GA16602@ircssh-2.c.rugged-nimbus-611.internal>
References: <20210426180610.2363-1-sargun@sargun.me>
 <20210426180610.2363-3-sargun@sargun.me>
 <20210426190229.GB1605795@cisco>
 <20210426221527.GA30835@ircssh-2.c.rugged-nimbus-611.internal>
 <20210427134853.GA1746081@cisco>
 <CALCETrVrfBtQPh=YeDEK4P9+QHQvNxHbn8ZT3fdQNznpSeS5oQ@mail.gmail.com>
 <20210427170753.GA1786245@cisco>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20210427170753.GA1786245@cisco>
User-Agent: Mutt/1.9.4 (2018-02-28)
Cc: Giuseppe Scrivano <gscrivan@redhat.com>, Will Drewry <wad@chromium.org>,
 Kees Cook <keescook@chromium.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 LKML <linux-kernel@vger.kernel.org>, Alban Crequy <alban@kinvolk.io>,
 Andy Lutomirski <luto@kernel.org>,
 Christian Brauner <christian.brauner@ubuntu.com>
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

On Tue, Apr 27, 2021 at 11:07:53AM -0600, Tycho Andersen wrote:
> On Tue, Apr 27, 2021 at 09:23:42AM -0700, Andy Lutomirski wrote:
> > On Tue, Apr 27, 2021 at 6:48 AM Tycho Andersen <tycho@tycho.pizza> wrote:
> > >
> > > On Mon, Apr 26, 2021 at 10:15:28PM +0000, Sargun Dhillon wrote:
> > > > On Mon, Apr 26, 2021 at 01:02:29PM -0600, Tycho Andersen wrote:
> > > > > On Mon, Apr 26, 2021 at 11:06:07AM -0700, Sargun Dhillon wrote:
> > > > > > @@ -1103,11 +1111,31 @@ static int seccomp_do_user_notification(int this_syscall,
> > > > > >    * This is where we wait for a reply from userspace.
> > > > > >    */
> > > > > >   do {
> > > > > > +         interruptible = notification_interruptible(&n);
> > > > > > +
> > > > > >           mutex_unlock(&match->notify_lock);
> > > > > > -         err = wait_for_completion_interruptible(&n.ready);
> > > > > > +         if (interruptible)
> > > > > > +                 err = wait_for_completion_interruptible(&n.ready);
> > > > > > +         else
> > > > > > +                 err = wait_for_completion_killable(&n.ready);
> > > > > >           mutex_lock(&match->notify_lock);
> > > > > > -         if (err != 0)
> > > > > > +
> > > > > > +         if (err != 0) {
> > > > > > +                 /*
> > > > > > +                  * There is a race condition here where if the
> > > > > > +                  * notification was received with the
> > > > > > +                  * SECCOMP_USER_NOTIF_FLAG_WAIT_KILLABLE flag, but a
> > > > > > +                  * non-fatal signal was received before we could
> > > > > > +                  * transition we could erroneously end our wait early.
> > > > > > +                  *
> > > > > > +                  * The next wait for completion will ensure the signal
> > > > > > +                  * was not fatal.
> > > > > > +                  */
> > > > > > +                 if (interruptible && !notification_interruptible(&n))
> > > > > > +                         continue;
> > > > >
> > > > > I'm trying to understand how one would hit this race,
> > > > >
> > > >
> > > > I'm thinking:
> > > > P: Process that "generates" notification
> > > > S: Supervisor
> > > > U: User
> > > >
> > > > P: Generated notification
> > > > S: ioctl(RECV...) // With wait_killable flag.
> > > > ...complete is called in the supervisor, but the P may not be woken up...
> > > > U: kill -SIGTERM $P
> > > > ...signal gets delivered to p and causes wakeup and
> > > > wait_for_completion_interruptible returns 1...
> > > >
> > > > Then you need to check the race
> > >
> > > I see, thanks. This seems like a consequence of having the flag be
> > > per-RECV-call vs. per-filter. Seems like it might be simpler to have
> > > it be per-filter?
> > >
I agree that it is hard / impossible to guarantee correctness *after* the fact.
> > 
> > Backing up a minute, how is the current behavior not a serious
> > correctness issue?  I can think of two scenarios that seem entirely
> > broken right now:
> > 
> > 1. Process makes a syscall that is not permitted to return -EINTR.  It
> > gets a signal and returns -EINTR when user notifiers are in use.
> >
Yes, there's a whole host of problems here. Things like fsmount should not
be interruptible.
 
> > 2. Process makes a syscall that is permitted to return -EINTR.  But
> > -EINTR for IO means "I got interrupted and *did not do the IO*".
> > Nevertheless, the syscall returns -EINTR and the IO is done.
In general, I think that the idea is to do as little side-effect I/O
as possible. The use cases we've looked at all have nice ways to unwind
them (perf_event_open, BPF, accept), but others are less good for unwinding
(mount). There are some middle ground calls like connect, but they're
less bad.

> > 
> > ISTM the current behavior is severely broken, and the new behavior
> > isn't *that* much better since it simply ignores signals and can't
> > emulate -EINTR (or all the various restart modes, sigh).  Surely the
> > right behavior is to have the seccomped process notice that it got a
> > signal and inform the monitor of that fact so that the monitor can
> > take appropriate action.
> 
> This doesn't help your case (2) though, since the IO could be done
> before the supervisor gets the notification.
> 
I think for something like mount, if it fails (gets interrupted) via a
fatal signal, that's grounds for terminating the container.

> > IOW, I don't think that the current behavior *or* the patched opt-in
> > behavior is great.  I think we would do better to have the filter
> > indicate that it is signal-aware and to document that non-signal-aware
> > filters cannot behave correctly with respect to signals.
> 
> I think it would be hard to make a signal-aware filter, it really does
> feel like the only thing to do is a killable wait.
> 
> Tycho

There are plenty of scenarios where the syscall can be handled in an interruptible
fashion. I like to use accept as an example. I think Jann Horn had put together
a patchset on how the supervisor could be notified (as opposed to background
polling). If the call is interrupted, you can just "finish" the accept on restart
of the sycall by handing the FD over.

I see a handful of paths forward:

* We add a new action USER_NOTIF_KILLABLE which requires a fatal signal
  in order to be interrupted
* We add a chunk of data to the USER_NOTIF return code (say, WAIT_KILLABLE)
  from the BPF filter that indicates what kind of wait should happen
* (what is happening now) An ioctl flag to say pickup the notification
  and put it into a wait_killable state
* An ioctl "command" that puts an existing notifcation in progress into
  the wait killable state.
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
