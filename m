Return-Path: <SRS0=Ze4f=JY=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 213ADC433ED
	for <containers@archiver.kernel.org>; Tue, 27 Apr 2021 23:20:12 +0000 (UTC)
Received: from smtp1.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id C0E0761404
	for <containers@archiver.kernel.org>; Tue, 27 Apr 2021 23:20:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C0E0761404
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp1.osuosl.org (Postfix) with ESMTP id 918AC83B7D;
	Tue, 27 Apr 2021 23:20:11 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp1.osuosl.org ([127.0.0.1])
	by localhost (smtp1.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ZGM1Oy94V0yj; Tue, 27 Apr 2021 23:20:10 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp1.osuosl.org (Postfix) with ESMTP id 6C22F83AB2;
	Tue, 27 Apr 2021 23:20:10 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 4F94EC0022;
	Tue, 27 Apr 2021 23:20:10 +0000 (UTC)
Received: from smtp4.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 01A87C0001
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Apr 2021 23:20:09 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp4.osuosl.org (Postfix) with ESMTP id E1B1C40348
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Apr 2021 23:20:08 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Authentication-Results: smtp4.osuosl.org (amavisd-new);
 dkim=pass (2048-bit key) header.d=kernel.org
Received: from smtp4.osuosl.org ([127.0.0.1])
 by localhost (smtp4.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id iAK7-hXJrr-U
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Apr 2021 23:20:08 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.8.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
 by smtp4.osuosl.org (Postfix) with ESMTPS id F043140203
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Apr 2021 23:20:07 +0000 (UTC)
Received: by mail.kernel.org (Postfix) with ESMTPSA id 87501613B0
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Apr 2021 23:20:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
 s=k20201202; t=1619565607;
 bh=b7cCUl+pInAQSCdSLxxEHiqgrpafGjB6QGUrbgdSdW8=;
 h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
 b=gAuNoOnb+TzAJvulRvremrjCXTJbOCGZYpInY2oOOsEIs+tdL4VmZ5jTpik/udDQc
 F8H7zqvRFv7SzXLaRD6ePgyw1lNn27v6BArxAvWqkOqCMvIwqWl7BlvhCuIMlZo7MG
 +clPD40WB5yAeAqQIigAvDAWasc8a4xdiUvFNGYaD0SiFadHsK6QFwCvJ3JieIY4hI
 PdT5m98NgbcJP/jVKGpIZg1T227V5ACxVb57fbkHXLKXtmazjFvoYWW/eXLnsKt2DV
 d5/xdqZuX9bBC2vAFavPKJ/q+YYa31aHk5dFUAWk/2vA3hXmbXQhhJMymVETpzdk6j
 nkJ1Nt1aTjERA==
Received: by mail-ej1-f42.google.com with SMTP id u21so91842403ejo.13
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Apr 2021 16:20:07 -0700 (PDT)
X-Gm-Message-State: AOAM530fGPJo+7Ig1ld+OpSnu2BlJjbHQgwo7fldzZa1P006unyYkGng
 0DeyLNtV1XNU7u3n5qE1iLBe+VfAInQPJov8fge9fw==
X-Google-Smtp-Source: ABdhPJydjs/9Sc1dOAsRhil4oUfvv7Cs/7PhNOIxi+US/eV1CjEpGrInfcbeag8xKQA0HLeXEuHwxlD6Fl7qa8Th9zE=
X-Received: by 2002:a17:906:f742:: with SMTP id
 jp2mr9066184ejb.199.1619565606053; 
 Tue, 27 Apr 2021 16:20:06 -0700 (PDT)
MIME-Version: 1.0
References: <20210426180610.2363-1-sargun@sargun.me>
 <20210426180610.2363-3-sargun@sargun.me>
 <20210426190229.GB1605795@cisco>
 <20210426221527.GA30835@ircssh-2.c.rugged-nimbus-611.internal>
 <20210427134853.GA1746081@cisco>
 <CALCETrVrfBtQPh=YeDEK4P9+QHQvNxHbn8ZT3fdQNznpSeS5oQ@mail.gmail.com>
 <20210427170753.GA1786245@cisco>
 <20210427221028.GA16602@ircssh-2.c.rugged-nimbus-611.internal>
In-Reply-To: <20210427221028.GA16602@ircssh-2.c.rugged-nimbus-611.internal>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 27 Apr 2021 16:19:54 -0700
X-Gmail-Original-Message-ID: <CALCETrX9JnHE9BOhRxCc1bCvEBfbOY8bb2rxeKTsDNxfMruntQ@mail.gmail.com>
Message-ID: <CALCETrX9JnHE9BOhRxCc1bCvEBfbOY8bb2rxeKTsDNxfMruntQ@mail.gmail.com>
Subject: Re: [PATCH RESEND 2/5] seccomp: Add wait_killable semantic to seccomp
 user notifier
To: Sargun Dhillon <sargun@sargun.me>
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

On Tue, Apr 27, 2021 at 3:10 PM Sargun Dhillon <sargun@sargun.me> wrote:
>
> On Tue, Apr 27, 2021 at 11:07:53AM -0600, Tycho Andersen wrote:
> > On Tue, Apr 27, 2021 at 09:23:42AM -0700, Andy Lutomirski wrote:
> > > On Tue, Apr 27, 2021 at 6:48 AM Tycho Andersen <tycho@tycho.pizza> wrote:
> > > >
> > > > On Mon, Apr 26, 2021 at 10:15:28PM +0000, Sargun Dhillon wrote:
> > >
> > > ISTM the current behavior is severely broken, and the new behavior
> > > isn't *that* much better since it simply ignores signals and can't
> > > emulate -EINTR (or all the various restart modes, sigh).  Surely the
> > > right behavior is to have the seccomped process notice that it got a
> > > signal and inform the monitor of that fact so that the monitor can
> > > take appropriate action.
> >
> > This doesn't help your case (2) though, since the IO could be done
> > before the supervisor gets the notification.

Tycho, I disagree.  Here's how native syscalls work:

1. Entry work is done and the syscall hander does whatever it does at
the beginning of the function.  This is entirely non-interruptible.

2. The syscall handler decides it wants to wait, interruptibly,
killably or otherwise.

3. It gets signaled.  It takes appropriate action.  Appropriate action
does *not* mean -EINTR.  It means that something that is correct *for
that syscall* happens.  For nanosleep(), this involves the restart
block (and I don't think we need to support the restart block).  For
accept(), it mostly seems to mean that the syscall completes as usual.
For write(2), it means that, depending on file type and whether any IO
has occured, either -EINTR is returned and no IO happens, or fewer
bytes than requested are transferred, or the syscall completes.  (Or,
if it's a KILL, the process dies early and partial IO is ignored.)
For some syscalls (some AF_UNIX writes, for example, or ptrace()), the
syscall indeed gets interrupted, but it uses one of the -ERESTART
mecahnisms.

User notifiers should allow correct emulation.  Right now, it doesn't,
but there is no reason it can't.

> >
> I think for something like mount, if it fails (gets interrupted) via a
> fatal signal, that's grounds for terminating the container.

That would be quite obnoxious if it happens after the container
starts.  Ctrl-C-ing a fusermount call should not be grounds for
outright destruction.
>
> I see a handful of paths forward:
>
> * We add a new action USER_NOTIF_KILLABLE which requires a fatal signal
>   in order to be interrupted
> * We add a chunk of data to the USER_NOTIF return code (say, WAIT_KILLABLE)
>   from the BPF filter that indicates what kind of wait should happen
> * (what is happening now) An ioctl flag to say pickup the notification
>   and put it into a wait_killable state
> * An ioctl "command" that puts an existing notifcation in progress into
>   the wait killable state.

In the simplest correct API, I think that kills should always kill the
task.  Non-kill signals should not kill the syscall but the user
notifier should be informed that a signal happened.  (Whether this
requires POLLPRI or some other handshaking mechanism is an open
question.)

The only real downside I see is that genuinely interruptible syscalls
will end up with higher than necessary signal latency if they occur
during the interruptible period.  An extended API could allow the
filter to return an indication that an interrupt should result in a
specified error code (-EINTR, ERESTARTxyz, etc), and the monitor could
do a new ioctl() to tell the kernel that the syscall should stop being
interruptible.  That ioctl() itself would return a status saying
whether the syscall was already interrupted.  One nice feature of this
approach is that the existing model is equivalent to the filter saying
"interruptible with EINTR" and the monitor simply forgetting to do the
new ioctl.

--Andy
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
