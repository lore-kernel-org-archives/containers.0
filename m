Return-Path: <SRS0=hje2=JZ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1FB05C433ED
	for <containers@archiver.kernel.org>; Wed, 28 Apr 2021 17:13:49 +0000 (UTC)
Received: from smtp4.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 410896143C
	for <containers@archiver.kernel.org>; Wed, 28 Apr 2021 17:13:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 410896143C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sargun.me
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp4.osuosl.org (Postfix) with ESMTP id C714D40378;
	Wed, 28 Apr 2021 17:13:47 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp4.osuosl.org ([127.0.0.1])
	by localhost (smtp4.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id WMoUZOAAN3hv; Wed, 28 Apr 2021 17:13:46 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [IPv6:2605:bc80:3010:104::8cd3:938])
	by smtp4.osuosl.org (Postfix) with ESMTP id 6DB6C40309;
	Wed, 28 Apr 2021 17:13:46 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 542A1C001C;
	Wed, 28 Apr 2021 17:13:46 +0000 (UTC)
Received: from smtp4.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id B614DC0001
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Apr 2021 17:13:44 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp4.osuosl.org (Postfix) with ESMTP id 8E1E540309
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Apr 2021 17:13:44 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp4.osuosl.org ([127.0.0.1])
 by localhost (smtp4.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id wUISK0Uaji85
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Apr 2021 17:13:43 +0000 (UTC)
X-Greylist: whitelisted by SQLgrey-1.8.0
Received: from mail-io1-xd2d.google.com (mail-io1-xd2d.google.com
 [IPv6:2607:f8b0:4864:20::d2d])
 by smtp4.osuosl.org (Postfix) with ESMTPS id 884BD403CC
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Apr 2021 17:13:43 +0000 (UTC)
Received: by mail-io1-xd2d.google.com with SMTP id f21so27243656ioh.8
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Apr 2021 10:13:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sargun.me; s=google;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=ooT7AWKBiLRbLDiDxglHtQCKmVnoRiy1bmtiucHGkh4=;
 b=KhqAVRWwQscEwvGBMS+mDXMj0e7K2zmCCJ1Bw1N7CpwQQB8REHnna3pQN7wY9J2xm/
 jX4G+whsufvmbwYRPELfw1v1Y9BTSIJR0Aii2E7MWOsjb3etRrjBMg+IhZC3A0fbHAmc
 uMasgnBQtpi/DWICXFEaAFt65LtWj2ZfmL96k=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=ooT7AWKBiLRbLDiDxglHtQCKmVnoRiy1bmtiucHGkh4=;
 b=EZ7cYUooluKnvl983KZk6bcg9rDZp11PzR75LCDrc2n0ExiMLn5inNThAfca5TQVs1
 7eTUHX5mryHBbJo2Wwf3cIYJ2PGKoL82rkOyQjaGq8ENBbSIwpgu3mH9wFtrErvQYQpg
 Jo9V0XNCUC6s4EPuUKt42RddyWaP6T7yYO9c9MdiZHTRO9N/6uDbd6kUKAuvySq1iJK0
 0oWZ1NeSLn9a1Q0mqVGNZG55pVnb72QWdbYJa2To2AagshuRI+QrsLCuM4FBdNMDUz9g
 T31/RKGbr+3VnvgOzQNotsl3wOqQwpsj8fVDQwapTH1FneNALPHf8qvGh4Q6SMoeUjA1
 S3hQ==
X-Gm-Message-State: AOAM5312tuHi+Ybo0xqlRAU/8Qb82Q5D2Qcv29x/QDkn5YmRY2yKx2ht
 3mXkQgnpAq0O1NDDr773vZKP8VVP7Brt3L95u/kcKw==
X-Google-Smtp-Source: ABdhPJz3j0YVNwm95J9ouvrww6lRpo5IoB1zZUqN6MURcLBbeK+4T9hZYBGZdnnS365uavZpq9IIiY0s5hckIqWppUs=
X-Received: by 2002:a02:a695:: with SMTP id j21mr17121924jam.29.1619630022507; 
 Wed, 28 Apr 2021 10:13:42 -0700 (PDT)
MIME-Version: 1.0
References: <20210426190229.GB1605795@cisco>
 <20210426221527.GA30835@ircssh-2.c.rugged-nimbus-611.internal>
 <20210427134853.GA1746081@cisco>
 <CALCETrVrfBtQPh=YeDEK4P9+QHQvNxHbn8ZT3fdQNznpSeS5oQ@mail.gmail.com>
 <20210427170753.GA1786245@cisco>
 <20210427221028.GA16602@ircssh-2.c.rugged-nimbus-611.internal>
 <CALCETrX9JnHE9BOhRxCc1bCvEBfbOY8bb2rxeKTsDNxfMruntQ@mail.gmail.com>
 <20210428002215.GB1786245@cisco>
 <CACaBj2ZchRGzHpGn5TD2FE=yKWZotVRNZ7M78TmvGfM9BoHF4g@mail.gmail.com>
 <CACaBj2aSnzQnbZG0sMM2Vae_yWGzxKWrGUz9xJVL_7akF8DvNA@mail.gmail.com>
 <20210428140817.GA1965193@cisco>
In-Reply-To: <20210428140817.GA1965193@cisco>
From: Sargun Dhillon <sargun@sargun.me>
Date: Wed, 28 Apr 2021 10:13:06 -0700
Message-ID: <CAMp4zn_j+g8gAEPNRo0hD4ioc9a5hEPD=6gcbh8fXs2XxN95mQ@mail.gmail.com>
Subject: Re: [PATCH RESEND 2/5] seccomp: Add wait_killable semantic to seccomp
 user notifier
To: Tycho Andersen <tycho@tycho.pizza>
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

On Wed, Apr 28, 2021 at 7:08 AM Tycho Andersen <tycho@tycho.pizza> wrote:
>
> On Wed, Apr 28, 2021 at 03:20:02PM +0200, Rodrigo Campos wrote:
> > On Wed, Apr 28, 2021 at 1:10 PM Rodrigo Campos <rodrigo@kinvolk.io> wrote:
> > >
> > > On Wed, Apr 28, 2021 at 2:22 AM Tycho Andersen <tycho@tycho.pizza> wrote:
> > > >
> > > > On Tue, Apr 27, 2021 at 04:19:54PM -0700, Andy Lutomirski wrote:
> > > > > User notifiers should allow correct emulation.  Right now, it doesn't,
> > > > > but there is no reason it can't.
> > > >
> > > > Thanks for the explanation.
> > > >
> > > > Consider fsmount, which has a,
> > > >
> > > >         ret = mutex_lock_interruptible(&fc->uapi_mutex);
> > > >         if (ret < 0)
> > > >                 goto err_fsfd;
> > > >
> > > > If a regular task is interrupted during that wait, it return -EINTR
> > > > or whatever back to userspace.
> > > >
> > > > Suppose that we intercept fsmount. The supervisor decides the mount is
> > > > OK, does the fsmount, injects the mount fd into the container, and
> > > > then the tracee receives a signal. At this point, the mount fd is
> > > > visible inside the container. The supervisor gets a notification about
> > > > the signal and revokes the mount fd, but there was some time where it
> > > > was exposed in the container, whereas with the interrupt in the native
> > > > syscall there was never any exposure.
> > >
> > > IIUC, this is solved by my patch, patch 4 of the series. The
> > > supervisor should do the addfd with the flag added in that patch
> > > (SECCOMP_ADDFD_FLAG_SEND) for an atomic "addfd + send".
> >
> > Well, under Andy's proposal handling that is even simpler. If the
> > signal is delivered after we added the fd (note that the container
> > syscall does not return when the signal arrives, as it happens today,
> > it just signals the notifier and continues to wait), we can just
> > ignore the signal and return that (if that is the appropriate thing
> > for that syscall, but I guess after adding an fd there isn't any other
> > reasonable thing to do).
>
> Yes, agreed. After thinking about this more, my example is bogus: the
> kernel doesn't sleep after it installs the fd, so it would ignore any
> signals too.
>
> Even if the kernel *did* sleep after installing the fd, it would still
> be correct emulation to install it and then do whatever the kernel did
> during that sleep. So I withdraw my objection :)
>
> Thanks,
>
> Tycho

Great.

I'll respin the series and add a
SECCOMP_IOCTL_NOTIF_SET_WAIT_KILLABLE command.

We can do the other aforementioned optimizations above when
specific use cases come up. I would like to work on preemption
notification after this lands though.
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
