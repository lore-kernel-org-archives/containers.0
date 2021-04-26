Return-Path: <SRS0=jAU3=JX=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5DF53C433ED
	for <containers@archiver.kernel.org>; Mon, 26 Apr 2021 22:15:35 +0000 (UTC)
Received: from smtp1.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id A0E09613A9
	for <containers@archiver.kernel.org>; Mon, 26 Apr 2021 22:15:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A0E09613A9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sargun.me
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp1.osuosl.org (Postfix) with ESMTP id 6AFA783A67;
	Mon, 26 Apr 2021 22:15:34 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp1.osuosl.org ([127.0.0.1])
	by localhost (smtp1.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 6iEmVz6OTsdZ; Mon, 26 Apr 2021 22:15:33 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [IPv6:2605:bc80:3010:104::8cd3:938])
	by smtp1.osuosl.org (Postfix) with ESMTP id 5CF3A83A66;
	Mon, 26 Apr 2021 22:15:33 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 3A774C000F;
	Mon, 26 Apr 2021 22:15:33 +0000 (UTC)
Received: from smtp1.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 56448C000B
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Apr 2021 22:15:32 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp1.osuosl.org (Postfix) with ESMTP id 44B9F83A67
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Apr 2021 22:15:32 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp1.osuosl.org ([127.0.0.1])
 by localhost (smtp1.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id pUKGYjLezBcf
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Apr 2021 22:15:31 +0000 (UTC)
X-Greylist: whitelisted by SQLgrey-1.8.0
Received: from mail-il1-x134.google.com (mail-il1-x134.google.com
 [IPv6:2607:f8b0:4864:20::134])
 by smtp1.osuosl.org (Postfix) with ESMTPS id 8562F83A66
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Apr 2021 22:15:31 +0000 (UTC)
Received: by mail-il1-x134.google.com with SMTP id c18so47873539iln.7
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Apr 2021 15:15:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sargun.me; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:in-reply-to:user-agent;
 bh=35JE14+U46LYE27Y6OGkQt/0x6BwuS4vBffRxgk3Bik=;
 b=Pwf6jVJ8R2S4o1XwZ2UFmoLLEj98OH9UhK967+HXKQPF5cEHyeAfVpuSotNh0jUoTq
 S6OR0N3aqSFQ5AbCkosdrTrR/iUQXM5NZfa2Tpdexe0PFKSWNDMal7ed6OLsV1nNxBeh
 4HH/h/abhCmIuOOK9nqSSCw/rb7qD5p5V+KB0=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:in-reply-to:user-agent;
 bh=35JE14+U46LYE27Y6OGkQt/0x6BwuS4vBffRxgk3Bik=;
 b=hKuPAvgX6mRaa9O7FplPKrLeAhDbIJ4xo8opFNrD/X56mGcMkJefrVN6LfKbphkXsq
 ME/kMRb7Kum4ZmdvfirwIePqlFW6cXFybByQvlLF27RigyeRUI6rXkJT19MUCTofo5+u
 oQJ3aSRegcQbVn9o41x1Y5G9dYklN4RhzDKGFkDCSBb2G+MPignFFDWcgQOBWV3SnGkU
 5rolAe9obtxnIMF0NDNZGIcIxAmwyrZmTEnq6d72K6uFoDiy1Z6k5P+CAyNzWCzmBpdZ
 HOuqK1LIRUOgDmRew699jz9iijwQfugx7ejroRTBxKQ3DDKWYIwqmGYZO2XEyPzGmmIX
 /B3w==
X-Gm-Message-State: AOAM531QFQ+CLLAGbWkkTyeQUyFytPHmGFY5krOgAySfrfCHGNbGV84n
 nlxmhqyEbtr1pvKQVPPgwqsFwQ==
X-Google-Smtp-Source: ABdhPJzD2GN88KsTOP4gOv5Ai8WTzKLO2wAKxc6jXZTCiQU2iXaipVDFRyZP1xUof74SRwkiOgz3sQ==
X-Received: by 2002:a05:6e02:92c:: with SMTP id
 o12mr16072169ilt.256.1619475330555; 
 Mon, 26 Apr 2021 15:15:30 -0700 (PDT)
Received: from ircssh-2.c.rugged-nimbus-611.internal
 (80.60.198.104.bc.googleusercontent.com. [104.198.60.80])
 by smtp.gmail.com with ESMTPSA id h17sm490657ilh.55.2021.04.26.15.15.30
 (version=TLS1_2 cipher=ECDHE-ECDSA-CHACHA20-POLY1305 bits=256/256);
 Mon, 26 Apr 2021 15:15:30 -0700 (PDT)
Date: Mon, 26 Apr 2021 22:15:28 +0000
From: Sargun Dhillon <sargun@sargun.me>
To: Tycho Andersen <tycho@tycho.pizza>
Subject: Re: [PATCH RESEND 2/5] seccomp: Add wait_killable semantic to
 seccomp user notifier
Message-ID: <20210426221527.GA30835@ircssh-2.c.rugged-nimbus-611.internal>
References: <20210426180610.2363-1-sargun@sargun.me>
 <20210426180610.2363-3-sargun@sargun.me>
 <20210426190229.GB1605795@cisco>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20210426190229.GB1605795@cisco>
User-Agent: Mutt/1.9.4 (2018-02-28)
Cc: Giuseppe Scrivano <gscrivan@redhat.com>, Will Drewry <wad@chromium.org>,
 Kees Cook <keescook@chromium.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 LKML <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@amacapital.net>,
 Alban Crequy <alban@kinvolk.io>,
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

On Mon, Apr 26, 2021 at 01:02:29PM -0600, Tycho Andersen wrote:
> On Mon, Apr 26, 2021 at 11:06:07AM -0700, Sargun Dhillon wrote:
> > @@ -1103,11 +1111,31 @@ static int seccomp_do_user_notification(int this_syscall,
> >  	 * This is where we wait for a reply from userspace.
> >  	 */
> >  	do {
> > +		interruptible = notification_interruptible(&n);
> > +
> >  		mutex_unlock(&match->notify_lock);
> > -		err = wait_for_completion_interruptible(&n.ready);
> > +		if (interruptible)
> > +			err = wait_for_completion_interruptible(&n.ready);
> > +		else
> > +			err = wait_for_completion_killable(&n.ready);
> >  		mutex_lock(&match->notify_lock);
> > -		if (err != 0)
> > +
> > +		if (err != 0) {
> > +			/*
> > +			 * There is a race condition here where if the
> > +			 * notification was received with the
> > +			 * SECCOMP_USER_NOTIF_FLAG_WAIT_KILLABLE flag, but a
> > +			 * non-fatal signal was received before we could
> > +			 * transition we could erroneously end our wait early.
> > +			 *
> > +			 * The next wait for completion will ensure the signal
> > +			 * was not fatal.
> > +			 */
> > +			if (interruptible && !notification_interruptible(&n))
> > +				continue;
> 
> I'm trying to understand how one would hit this race,
> 

I'm thinking:
P: Process that "generates" notification
S: Supervisor
U: User

P: Generated notification
S: ioctl(RECV...) // With wait_killable flag.
...complete is called in the supervisor, but the P may not be woken up...
U: kill -SIGTERM $P
...signal gets delivered to p and causes wakeup and
wait_for_completion_interruptible returns 1...

Then you need to check the race
> > @@ -1457,6 +1487,12 @@ static long seccomp_notify_recv(struct seccomp_filter *filter,
> >  	unotif.pid = task_pid_vnr(knotif->task);
> >  	unotif.data = *(knotif->data);
> >  
> > +	if (unotif.flags & SECCOMP_USER_NOTIF_FLAG_WAIT_KILLABLE) {
> > +		knotif->wait_killable = true;
> > +		complete(&knotif->ready);
> > +	}
> > +
> > +
> >  	knotif->state = SECCOMP_NOTIFY_SENT;
> >  	wake_up_poll(&filter->wqh, EPOLLOUT | EPOLLWRNORM);
> >  	ret = 0;
> 
> Seems like the idea is that if someone does a ioctl(RECV, ...) twice
> they'll hit it? But doesn't the test for NOTIFY_INIT and return
> -ENOENT above this hunk prevent that?
> 
> Thanks,
> 
> Tycho
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
