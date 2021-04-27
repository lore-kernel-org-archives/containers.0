Return-Path: <SRS0=Ze4f=JY=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C237C433ED
	for <containers@archiver.kernel.org>; Tue, 27 Apr 2021 16:24:01 +0000 (UTC)
Received: from smtp3.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id AF040613E7
	for <containers@archiver.kernel.org>; Tue, 27 Apr 2021 16:24:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF040613E7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp3.osuosl.org (Postfix) with ESMTP id 5EF916067C;
	Tue, 27 Apr 2021 16:24:00 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp3.osuosl.org ([127.0.0.1])
	by localhost (smtp3.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id eCfEyQBaIdVu; Tue, 27 Apr 2021 16:23:59 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [IPv6:2605:bc80:3010:104::8cd3:938])
	by smtp3.osuosl.org (Postfix) with ESMTP id 39AF160609;
	Tue, 27 Apr 2021 16:23:59 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 1D165C000E;
	Tue, 27 Apr 2021 16:23:59 +0000 (UTC)
Received: from smtp4.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 101A0C000B
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Apr 2021 16:23:58 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp4.osuosl.org (Postfix) with ESMTP id E6FEA4030F
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Apr 2021 16:23:57 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Authentication-Results: smtp4.osuosl.org (amavisd-new);
 dkim=pass (2048-bit key) header.d=kernel.org
Received: from smtp4.osuosl.org ([127.0.0.1])
 by localhost (smtp4.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id acewgAhupkMY
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Apr 2021 16:23:56 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.8.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
 by smtp4.osuosl.org (Postfix) with ESMTPS id 9FA05402F0
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Apr 2021 16:23:56 +0000 (UTC)
Received: by mail.kernel.org (Postfix) with ESMTPSA id 0A4DE613E8
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Apr 2021 16:23:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
 s=k20201202; t=1619540636;
 bh=l/R2qtxCn2ERJyPjYguJ0k39jAGXWUp2uQC+JMs9fuA=;
 h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
 b=O2KYc3CKaic0+kVdqHwz6NUbKNzh+h1LwX/U5B7DAk2n9gfQUarAKKBG4byLutmxL
 CSiAa3kK5T4m0Pq0fUraRZdHUxk2p7CCwxbMdfPvpeI78OhHjYslxmWBVyh0Xi0Fx5
 1PYiI5MSKNTTlp9a/CA9VHEVYNwsY45CaWfegLBTYN8mNgYz+VeQU9zinXSTaJjyyV
 ailQ8+ttWae1DHFXF3xtR4iF/Ql8jTI+lF+2osJe3z7MpJeDbu0uyHXFjoftaPqmS9
 bpHtLU1GnntvAu98y9TYtOmpBOrJTJco12W4rXovHJhYHTfegUgSrEdiEtKDjzikkS
 i5CE7iwNyyigw==
Received: by mail-ej1-f41.google.com with SMTP id zg3so8746887ejb.8
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Apr 2021 09:23:55 -0700 (PDT)
X-Gm-Message-State: AOAM532L6uuT+1qXw8QPpbLucbFgzY/UNBP5f2URPW25TCk3P1USdY84
 GXNK2JCsV132RXLdwAcKY3xdxd1ajdOpuEgSaE7GMA==
X-Google-Smtp-Source: ABdhPJxy9HL2ysFtlcSqWMWsv6cwp5/qFMPBPyFAP9+p+Zf66TnmOU2k4NUG/ma1/9pG/95JQLjY1P5Iln/2Bz8TT8E=
X-Received: by 2002:a17:906:e096:: with SMTP id
 gh22mr2231171ejb.101.1619540634457; 
 Tue, 27 Apr 2021 09:23:54 -0700 (PDT)
MIME-Version: 1.0
References: <20210426180610.2363-1-sargun@sargun.me>
 <20210426180610.2363-3-sargun@sargun.me>
 <20210426190229.GB1605795@cisco>
 <20210426221527.GA30835@ircssh-2.c.rugged-nimbus-611.internal>
 <20210427134853.GA1746081@cisco>
In-Reply-To: <20210427134853.GA1746081@cisco>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 27 Apr 2021 09:23:42 -0700
X-Gmail-Original-Message-ID: <CALCETrVrfBtQPh=YeDEK4P9+QHQvNxHbn8ZT3fdQNznpSeS5oQ@mail.gmail.com>
Message-ID: <CALCETrVrfBtQPh=YeDEK4P9+QHQvNxHbn8ZT3fdQNznpSeS5oQ@mail.gmail.com>
Subject: Re: [PATCH RESEND 2/5] seccomp: Add wait_killable semantic to seccomp
 user notifier
To: Tycho Andersen <tycho@tycho.pizza>
Cc: Giuseppe Scrivano <gscrivan@redhat.com>, Will Drewry <wad@chromium.org>,
 Kees Cook <keescook@chromium.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 LKML <linux-kernel@vger.kernel.org>, Alban Crequy <alban@kinvolk.io>,
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

On Tue, Apr 27, 2021 at 6:48 AM Tycho Andersen <tycho@tycho.pizza> wrote:
>
> On Mon, Apr 26, 2021 at 10:15:28PM +0000, Sargun Dhillon wrote:
> > On Mon, Apr 26, 2021 at 01:02:29PM -0600, Tycho Andersen wrote:
> > > On Mon, Apr 26, 2021 at 11:06:07AM -0700, Sargun Dhillon wrote:
> > > > @@ -1103,11 +1111,31 @@ static int seccomp_do_user_notification(int this_syscall,
> > > >    * This is where we wait for a reply from userspace.
> > > >    */
> > > >   do {
> > > > +         interruptible = notification_interruptible(&n);
> > > > +
> > > >           mutex_unlock(&match->notify_lock);
> > > > -         err = wait_for_completion_interruptible(&n.ready);
> > > > +         if (interruptible)
> > > > +                 err = wait_for_completion_interruptible(&n.ready);
> > > > +         else
> > > > +                 err = wait_for_completion_killable(&n.ready);
> > > >           mutex_lock(&match->notify_lock);
> > > > -         if (err != 0)
> > > > +
> > > > +         if (err != 0) {
> > > > +                 /*
> > > > +                  * There is a race condition here where if the
> > > > +                  * notification was received with the
> > > > +                  * SECCOMP_USER_NOTIF_FLAG_WAIT_KILLABLE flag, but a
> > > > +                  * non-fatal signal was received before we could
> > > > +                  * transition we could erroneously end our wait early.
> > > > +                  *
> > > > +                  * The next wait for completion will ensure the signal
> > > > +                  * was not fatal.
> > > > +                  */
> > > > +                 if (interruptible && !notification_interruptible(&n))
> > > > +                         continue;
> > >
> > > I'm trying to understand how one would hit this race,
> > >
> >
> > I'm thinking:
> > P: Process that "generates" notification
> > S: Supervisor
> > U: User
> >
> > P: Generated notification
> > S: ioctl(RECV...) // With wait_killable flag.
> > ...complete is called in the supervisor, but the P may not be woken up...
> > U: kill -SIGTERM $P
> > ...signal gets delivered to p and causes wakeup and
> > wait_for_completion_interruptible returns 1...
> >
> > Then you need to check the race
>
> I see, thanks. This seems like a consequence of having the flag be
> per-RECV-call vs. per-filter. Seems like it might be simpler to have
> it be per-filter?
>

Backing up a minute, how is the current behavior not a serious
correctness issue?  I can think of two scenarios that seem entirely
broken right now:

1. Process makes a syscall that is not permitted to return -EINTR.  It
gets a signal and returns -EINTR when user notifiers are in use.

2. Process makes a syscall that is permitted to return -EINTR.  But
-EINTR for IO means "I got interrupted and *did not do the IO*".
Nevertheless, the syscall returns -EINTR and the IO is done.

ISTM the current behavior is severely broken, and the new behavior
isn't *that* much better since it simply ignores signals and can't
emulate -EINTR (or all the various restart modes, sigh).  Surely the
right behavior is to have the seccomped process notice that it got a
signal and inform the monitor of that fact so that the monitor can
take appropriate action.

IOW, I don't think that the current behavior *or* the patched opt-in
behavior is great.  I think we would do better to have the filter
indicate that it is signal-aware and to document that non-signal-aware
filters cannot behave correctly with respect to signals.

--Andy
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
