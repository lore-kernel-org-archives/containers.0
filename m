Return-Path: <SRS0=Ze4f=JY=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6772AC433ED
	for <containers@archiver.kernel.org>; Tue, 27 Apr 2021 17:08:12 +0000 (UTC)
Received: from smtp4.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id CC1A8613DA
	for <containers@archiver.kernel.org>; Tue, 27 Apr 2021 17:08:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC1A8613DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tycho.pizza
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp4.osuosl.org (Postfix) with ESMTP id 856D240632;
	Tue, 27 Apr 2021 17:08:11 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp4.osuosl.org ([127.0.0.1])
	by localhost (smtp4.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id xiYXrjsH1ia8; Tue, 27 Apr 2021 17:08:10 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp4.osuosl.org (Postfix) with ESMTP id 240CD4062E;
	Tue, 27 Apr 2021 17:08:10 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id F1F55C0019;
	Tue, 27 Apr 2021 17:08:09 +0000 (UTC)
Received: from smtp1.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id DD73DC000A
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Apr 2021 17:08:07 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp1.osuosl.org (Postfix) with ESMTP id CBBDD83D58
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Apr 2021 17:08:07 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Authentication-Results: smtp1.osuosl.org (amavisd-new);
 dkim=pass (2048-bit key) header.d=tycho.pizza header.b="PXT+9VID";
 dkim=pass (2048-bit key) header.d=messagingengine.com
 header.b="kpT0hcz8"
Received: from smtp1.osuosl.org ([127.0.0.1])
 by localhost (smtp1.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id HNmyYJdmzc5n
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Apr 2021 17:08:04 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.8.0
Received: from wnew4-smtp.messagingengine.com (wnew4-smtp.messagingengine.com
 [64.147.123.18])
 by smtp1.osuosl.org (Postfix) with ESMTPS id 4FAB483D5A
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Apr 2021 17:08:04 +0000 (UTC)
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
 by mailnew.west.internal (Postfix) with ESMTP id 35B56ED0;
 Tue, 27 Apr 2021 13:08:02 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
 by compute4.internal (MEProxy); Tue, 27 Apr 2021 13:08:02 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tycho.pizza; h=
 date:from:to:cc:subject:message-id:references:mime-version
 :content-type:in-reply-to; s=fm3; bh=dpGNdB47HMr5A69m6IUz+7x1trW
 JQi1zXaT6OT2QXA4=; b=PXT+9VIDs49kPYTvrSz7FM5f52topR9XxP6s1r8vuky
 Kt4mYJx7BwwDAI3y1GRkdLqelmRNI98CnTN8Qs8xfTGRC+xLbMjSpT7wOc6SepR9
 1vA1Ny3lW9L3y9Qh6bgBPAImWOJAol4KwubCGx0icPIcr0O5jswkQEAK9XW3/jv4
 1UWH/iAKReo4b2lWH/mnCcoK4oxeCMP3llycSwTnIe98z7nkfV1JcoM+3GKnvap0
 j2WQ9IcF12oeQHoYgzGuWbbyaLAymqDbHpEnumcvHCjiAhDumxDmi4X7fxOvQLuT
 AE4pTRCGqOEf/2WrnPJgKHr/mwSZ0yIiQ2tyF96DjBw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
 messagingengine.com; h=cc:content-type:date:from:in-reply-to
 :message-id:mime-version:references:subject:to:x-me-proxy
 :x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=dpGNdB
 47HMr5A69m6IUz+7x1trWJQi1zXaT6OT2QXA4=; b=kpT0hcz8VM2PoNbz9AF9k0
 iWcgJ6rDbRZ8H/Bg3gECnFJCaBOAkSwwYzkwv1A/z8BZGLSZl0rNt3M0WRxdZb24
 URgu5Hot1wwouS39Bhn3VMRrt7ibC3xu975bCyRtnrUqOyY+406HcgX8egS4Di/K
 5HbjssSpaVhGA1W6vsdVfaObK1XxZysUrDFL6UpRuxJMdUAwriVy1uXbtTnlCLw5
 u0v83XYikpKsHVM20tHklTIH5/TyY94OV+f8nSs74NiO8fJJeqXl8kZXmE/jvEmC
 rGmMTyMWDMBuXRC6n8sdoOtg0IZG33CpecosKo0Od1nfQujMKkfXICYowb1TQeNg
 ==
X-ME-Sender: <xms:8ESIYI8uvaD7iiFRgrvJzwO-_weub7lGvqzQ1GpDyfQnAIRtuDJDiA>
 <xme:8ESIYAtpK547yQGq-c_Pyfx62v4aCKy5daGwFiwJz3K_pLTXH6wVcUYjbp7jSwC-l
 rzCxqB3j1-mPcHu-D8>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduledrvddvtddgudduudcutefuodetggdotefrod
 ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfgh
 necuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmd
 enucfjughrpeffhffvuffkfhggtggujgesthdtredttddtvdenucfhrhhomhepvfihtghh
 ohcutehnuggvrhhsvghnuceothihtghhohesthihtghhohdrphhiiiiirgeqnecuggftrf
 grthhtvghrnhepgeekfeejgeektdejgfefudelkeeuteejgefhhfeugffffeelheegieef
 vdfgtefhnecukfhppedujeefrdefkedruddujedrkedtnecuvehluhhsthgvrhfuihiivg
 eptdenucfrrghrrghmpehmrghilhhfrhhomhepthihtghhohesthihtghhohdrphhiiiii
 rg
X-ME-Proxy: <xmx:8ESIYODzX7D_vX0KASKjHdztk6L5GmwmoczCu6Ushlv533ayINg86A>
 <xmx:8ESIYIeCWaXZfizAqSor6qLfgWZ8x2YFEdrTfvdqeIyx_Dgzx-Uj8Q>
 <xmx:8ESIYNOhGXX5YLzmHehje95NTyu5OINC4d9LTBKQQJ2aMBlOsES5dA>
 <xmx:8USIYGiUc0H1ZMr4VMrXLh2tFIQTaxkyf7y-Al_-QSLXk0xdUDvq_ES5hxY>
Received: from cisco (unknown [173.38.117.80])
 by mail.messagingengine.com (Postfix) with ESMTPA;
 Tue, 27 Apr 2021 13:07:59 -0400 (EDT)
Date: Tue, 27 Apr 2021 11:07:53 -0600
From: Tycho Andersen <tycho@tycho.pizza>
To: Andy Lutomirski <luto@kernel.org>
Subject: Re: [PATCH RESEND 2/5] seccomp: Add wait_killable semantic to
 seccomp user notifier
Message-ID: <20210427170753.GA1786245@cisco>
References: <20210426180610.2363-1-sargun@sargun.me>
 <20210426180610.2363-3-sargun@sargun.me>
 <20210426190229.GB1605795@cisco>
 <20210426221527.GA30835@ircssh-2.c.rugged-nimbus-611.internal>
 <20210427134853.GA1746081@cisco>
 <CALCETrVrfBtQPh=YeDEK4P9+QHQvNxHbn8ZT3fdQNznpSeS5oQ@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CALCETrVrfBtQPh=YeDEK4P9+QHQvNxHbn8ZT3fdQNznpSeS5oQ@mail.gmail.com>
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

On Tue, Apr 27, 2021 at 09:23:42AM -0700, Andy Lutomirski wrote:
> On Tue, Apr 27, 2021 at 6:48 AM Tycho Andersen <tycho@tycho.pizza> wrote:
> >
> > On Mon, Apr 26, 2021 at 10:15:28PM +0000, Sargun Dhillon wrote:
> > > On Mon, Apr 26, 2021 at 01:02:29PM -0600, Tycho Andersen wrote:
> > > > On Mon, Apr 26, 2021 at 11:06:07AM -0700, Sargun Dhillon wrote:
> > > > > @@ -1103,11 +1111,31 @@ static int seccomp_do_user_notification(int this_syscall,
> > > > >    * This is where we wait for a reply from userspace.
> > > > >    */
> > > > >   do {
> > > > > +         interruptible = notification_interruptible(&n);
> > > > > +
> > > > >           mutex_unlock(&match->notify_lock);
> > > > > -         err = wait_for_completion_interruptible(&n.ready);
> > > > > +         if (interruptible)
> > > > > +                 err = wait_for_completion_interruptible(&n.ready);
> > > > > +         else
> > > > > +                 err = wait_for_completion_killable(&n.ready);
> > > > >           mutex_lock(&match->notify_lock);
> > > > > -         if (err != 0)
> > > > > +
> > > > > +         if (err != 0) {
> > > > > +                 /*
> > > > > +                  * There is a race condition here where if the
> > > > > +                  * notification was received with the
> > > > > +                  * SECCOMP_USER_NOTIF_FLAG_WAIT_KILLABLE flag, but a
> > > > > +                  * non-fatal signal was received before we could
> > > > > +                  * transition we could erroneously end our wait early.
> > > > > +                  *
> > > > > +                  * The next wait for completion will ensure the signal
> > > > > +                  * was not fatal.
> > > > > +                  */
> > > > > +                 if (interruptible && !notification_interruptible(&n))
> > > > > +                         continue;
> > > >
> > > > I'm trying to understand how one would hit this race,
> > > >
> > >
> > > I'm thinking:
> > > P: Process that "generates" notification
> > > S: Supervisor
> > > U: User
> > >
> > > P: Generated notification
> > > S: ioctl(RECV...) // With wait_killable flag.
> > > ...complete is called in the supervisor, but the P may not be woken up...
> > > U: kill -SIGTERM $P
> > > ...signal gets delivered to p and causes wakeup and
> > > wait_for_completion_interruptible returns 1...
> > >
> > > Then you need to check the race
> >
> > I see, thanks. This seems like a consequence of having the flag be
> > per-RECV-call vs. per-filter. Seems like it might be simpler to have
> > it be per-filter?
> >
> 
> Backing up a minute, how is the current behavior not a serious
> correctness issue?  I can think of two scenarios that seem entirely
> broken right now:
> 
> 1. Process makes a syscall that is not permitted to return -EINTR.  It
> gets a signal and returns -EINTR when user notifiers are in use.
> 
> 2. Process makes a syscall that is permitted to return -EINTR.  But
> -EINTR for IO means "I got interrupted and *did not do the IO*".
> Nevertheless, the syscall returns -EINTR and the IO is done.
> 
> ISTM the current behavior is severely broken, and the new behavior
> isn't *that* much better since it simply ignores signals and can't
> emulate -EINTR (or all the various restart modes, sigh).  Surely the
> right behavior is to have the seccomped process notice that it got a
> signal and inform the monitor of that fact so that the monitor can
> take appropriate action.

This doesn't help your case (2) though, since the IO could be done
before the supervisor gets the notification.

> IOW, I don't think that the current behavior *or* the patched opt-in
> behavior is great.  I think we would do better to have the filter
> indicate that it is signal-aware and to document that non-signal-aware
> filters cannot behave correctly with respect to signals.

I think it would be hard to make a signal-aware filter, it really does
feel like the only thing to do is a killable wait.

Tycho
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
