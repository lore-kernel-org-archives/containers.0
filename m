Return-Path: <SRS0=Ze4f=JY=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3FBC2C433B4
	for <containers@archiver.kernel.org>; Tue, 27 Apr 2021 16:35:13 +0000 (UTC)
Received: from smtp1.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 7C944613C3
	for <containers@archiver.kernel.org>; Tue, 27 Apr 2021 16:35:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7C944613C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sargun.me
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp1.osuosl.org (Postfix) with ESMTP id 2438C83BC4;
	Tue, 27 Apr 2021 16:35:12 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp1.osuosl.org ([127.0.0.1])
	by localhost (smtp1.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id KqbIa8Pn-FY2; Tue, 27 Apr 2021 16:35:11 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp1.osuosl.org (Postfix) with ESMTP id 0E5BF83BE0;
	Tue, 27 Apr 2021 16:35:10 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id DAE2FC0024;
	Tue, 27 Apr 2021 16:35:10 +0000 (UTC)
Received: from smtp4.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 4103EC0011
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Apr 2021 16:35:08 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp4.osuosl.org (Postfix) with ESMTP id 2D93740611
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Apr 2021 16:35:08 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Authentication-Results: smtp4.osuosl.org (amavisd-new);
 dkim=pass (1024-bit key) header.d=sargun.me
Received: from smtp4.osuosl.org ([127.0.0.1])
 by localhost (smtp4.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id zDJxGFQx5AJ3
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Apr 2021 16:35:05 +0000 (UTC)
X-Greylist: whitelisted by SQLgrey-1.8.0
Received: from mail-io1-xd30.google.com (mail-io1-xd30.google.com
 [IPv6:2607:f8b0:4864:20::d30])
 by smtp4.osuosl.org (Postfix) with ESMTPS id E1DBE401D8
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Apr 2021 16:35:04 +0000 (UTC)
Received: by mail-io1-xd30.google.com with SMTP id p8so7506305iol.11
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Apr 2021 09:35:04 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sargun.me; s=google;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=INHOzD23PluMifB464PN3y3YCplArL1gtSHLIv2/4JU=;
 b=XoZF0rMHVUDwD8/V3ZaMnpFrCUzlDeaxMJtq6++MJ9jF5ZWA3V8SUFzQn4RDwb8Lkm
 QQU4mpE/WKOlTiUpcQpEjyWqO3LCJn1lk/T7UZusGYcp3Q0RQFFLEBcHT10Vy7ER/Krp
 Sfgvxkz8NRGLI1Fxh+yS75N4rrdcJdojdlilo=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=INHOzD23PluMifB464PN3y3YCplArL1gtSHLIv2/4JU=;
 b=D8QXGRq5zjjEtM3wpw38gTJOlDxlGjufRExKS2hiy8RYezo5COm3+/ykw7tlTMLlvC
 rGSb2kJgkUzYzgYKXTzoVYPBPAFyktSWpKIqAnhWOsSM+NfHKrW7sraaCllb3/92ghit
 imxXcAp4VJ2yNr8VWU1KzwsoQ16DsHUzlTX/p7ekVuF0F1o7X7/WZyxF7DZtxluRc1ww
 NedKJA37JdTtyUb1N0LHpaEYIOSRleNWuPvhOJUgWoxl9m2DzlsyoJmOzwId7UB6RBZK
 y5WbuCj35PLoBGsayj0vtmdco8Ujjls3vS6GL+3aV8TGMe0LPHEtqMAUfNw1tW653YFj
 KqJQ==
X-Gm-Message-State: AOAM532PQ4aoTXQuwmbPvc7JgxnzdeuE/uNtQjWyymGb/RflEiMxIifS
 HH2xxaN2v/ogSSoP2zZLP8fj7UJ45UqiPk7CVbWvlg==
X-Google-Smtp-Source: ABdhPJzQns1HjP3hSguwiYnNN8zYmAtz0ZNRJCCQEjDVSMXuKi29IJ4y6tTcPiOgDQhO69i9e8pkcNn6c00dltZYxsU=
X-Received: by 2002:a05:6638:35ab:: with SMTP id
 v43mr22446989jal.65.1619541303738; 
 Tue, 27 Apr 2021 09:35:03 -0700 (PDT)
MIME-Version: 1.0
References: <20210426180610.2363-1-sargun@sargun.me>
 <20210426180610.2363-3-sargun@sargun.me>
 <20210426190229.GB1605795@cisco>
 <20210426221527.GA30835@ircssh-2.c.rugged-nimbus-611.internal>
 <20210427134853.GA1746081@cisco>
In-Reply-To: <20210427134853.GA1746081@cisco>
From: Sargun Dhillon <sargun@sargun.me>
Date: Tue, 27 Apr 2021 09:34:26 -0700
Message-ID: <CAMp4zn8MPvkWmt6Yqo+nQCd-HRNRc_=rVYAAF4LjvY2F7-OdGQ@mail.gmail.com>
Subject: Re: [PATCH RESEND 2/5] seccomp: Add wait_killable semantic to seccomp
 user notifier
To: Tycho Andersen <tycho@tycho.pizza>
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
> Tycho

You're right.

I think an alternative solution would be to make it on a per-action
basis, and in the filter have a different action for non-preemptible
user notifications.

Since you can only install one filter, I do not think we want to make
it so we do it on a entire filter basis, in case a filter handles a combination
of preemptible and non-preemptible syscalls. For example if you mix
mount and accept.
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
