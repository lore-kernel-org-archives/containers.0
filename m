Return-Path: <SRS0=hje2=JZ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.0 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AFA92C433ED
	for <containers@archiver.kernel.org>; Wed, 28 Apr 2021 03:20:34 +0000 (UTC)
Received: from smtp3.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 17EC3613FB
	for <containers@archiver.kernel.org>; Wed, 28 Apr 2021 03:20:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 17EC3613FB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sargun.me
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp3.osuosl.org (Postfix) with ESMTP id CA4D060BB5;
	Wed, 28 Apr 2021 03:20:33 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp3.osuosl.org ([127.0.0.1])
	by localhost (smtp3.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 7TNnUmHTU7Vh; Wed, 28 Apr 2021 03:20:32 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp3.osuosl.org (Postfix) with ESMTP id 6FDC260BB0;
	Wed, 28 Apr 2021 03:20:32 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 520F1C0022;
	Wed, 28 Apr 2021 03:20:32 +0000 (UTC)
Received: from smtp3.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 7B77BC0001
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Apr 2021 03:20:31 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp3.osuosl.org (Postfix) with ESMTP id 55ACA60BB5
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Apr 2021 03:20:31 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp3.osuosl.org ([127.0.0.1])
 by localhost (smtp3.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id qfQjm0jLX5lB
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Apr 2021 03:20:30 +0000 (UTC)
X-Greylist: whitelisted by SQLgrey-1.8.0
Received: from mail-il1-x12d.google.com (mail-il1-x12d.google.com
 [IPv6:2607:f8b0:4864:20::12d])
 by smtp3.osuosl.org (Postfix) with ESMTPS id 5770A60BB0
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Apr 2021 03:20:30 +0000 (UTC)
Received: by mail-il1-x12d.google.com with SMTP id p15so15482844iln.3
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Apr 2021 20:20:30 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sargun.me; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:in-reply-to:user-agent;
 bh=3cLeYHve0GFKGDuMF6EPDVsMeBk+BNVyKxjvAlZD9Tc=;
 b=RtH9V2biuBudTzXomRh+EX2m6h/Hja4agdGKVQ1uWArpHZpXUWHkafvABMUDjS6yUI
 olnkc/WTJ+aVOfDZOqkTKEEGFRcr48Tl8f4F+tp9ExnedwPxAydp9WBGwIBw0VX/oYcQ
 cyae2gnIyviYxlRHax1JbAZH5Q/6B1XJHawj8=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:in-reply-to:user-agent;
 bh=3cLeYHve0GFKGDuMF6EPDVsMeBk+BNVyKxjvAlZD9Tc=;
 b=OXmAVodaMSHvtiPeEWqrp295nS0+/twFdCzTsJ5lKoJw8ayAjeFTnHDSqgRncwMN03
 V50esie7EFGwLxXrMhGn+5YEdqQDi3AIlVEY1e1FaHjeSh4sFSS4BlD5P/TpJcYqh7io
 8AsMt3SMx+IJiKldcbNA+CG9vwiE8IrrTmJr+JKrH9FSTBLERH88UeDl3UYHTiP7pmp5
 hbkG/pmzstvUob0b7o4U950a7jVhRLMUqIkFgWtVnr66m3O1kUXYsZWfcxdUKxBuMzDM
 D7rCukqLroQaEQOQp8yiHTDXZ2Aq0/DlWRgwfLIpoCgLMyYGxsb06vbPjN7x/LqClobu
 CCWg==
X-Gm-Message-State: AOAM5318u9k7vC5RyDc50BtUC0T5Gxca7OnZV7+b+GvCOGXlPD2vyJow
 7XZYR2WSeE5wSvv2BrNqdUfYXg==
X-Google-Smtp-Source: ABdhPJwcjmEfu2ubNGPzpfk+/F3EQnQU5ornLD/A1P1K07LcDzYg0iOMwxk9CIJGq6WEVvQfdVBw5A==
X-Received: by 2002:a92:d582:: with SMTP id a2mr20567626iln.206.1619580029213; 
 Tue, 27 Apr 2021 20:20:29 -0700 (PDT)
Received: from ircssh-2.c.rugged-nimbus-611.internal
 (80.60.198.104.bc.googleusercontent.com. [104.198.60.80])
 by smtp.gmail.com with ESMTPSA id f9sm825778iol.23.2021.04.27.20.20.28
 (version=TLS1_2 cipher=ECDHE-ECDSA-CHACHA20-POLY1305 bits=256/256);
 Tue, 27 Apr 2021 20:20:28 -0700 (PDT)
Date: Wed, 28 Apr 2021 03:20:27 +0000
From: Sargun Dhillon <sargun@sargun.me>
To: Andy Lutomirski <luto@kernel.org>
Subject: Re: [PATCH RESEND 2/5] seccomp: Add wait_killable semantic to
 seccomp user notifier
Message-ID: <20210428032026.GA19956@ircssh-2.c.rugged-nimbus-611.internal>
References: <20210426180610.2363-1-sargun@sargun.me>
 <20210426180610.2363-3-sargun@sargun.me>
 <20210426190229.GB1605795@cisco>
 <20210426221527.GA30835@ircssh-2.c.rugged-nimbus-611.internal>
 <20210427134853.GA1746081@cisco>
 <CALCETrVrfBtQPh=YeDEK4P9+QHQvNxHbn8ZT3fdQNznpSeS5oQ@mail.gmail.com>
 <20210427170753.GA1786245@cisco>
 <20210427221028.GA16602@ircssh-2.c.rugged-nimbus-611.internal>
 <CALCETrX9JnHE9BOhRxCc1bCvEBfbOY8bb2rxeKTsDNxfMruntQ@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CALCETrX9JnHE9BOhRxCc1bCvEBfbOY8bb2rxeKTsDNxfMruntQ@mail.gmail.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
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

On Tue, Apr 27, 2021 at 04:19:54PM -0700, Andy Lutomirski wrote:
> On Tue, Apr 27, 2021 at 3:10 PM Sargun Dhillon <sargun@sargun.me> wrote:
> >
> > On Tue, Apr 27, 2021 at 11:07:53AM -0600, Tycho Andersen wrote:
> > > On Tue, Apr 27, 2021 at 09:23:42AM -0700, Andy Lutomirski wrote:
> > > > On Tue, Apr 27, 2021 at 6:48 AM Tycho Andersen <tycho@tycho.pizza> wrote:
> > > > >
> > > > > On Mon, Apr 26, 2021 at 10:15:28PM +0000, Sargun Dhillon wrote:
> > > >
> > > > ISTM the current behavior is severely broken, and the new behavior
> > > > isn't *that* much better since it simply ignores signals and can't
> > > > emulate -EINTR (or all the various restart modes, sigh).  Surely the
> > > > right behavior is to have the seccomped process notice that it got a
> > > > signal and inform the monitor of that fact so that the monitor can
> > > > take appropriate action.
> > >
> > > This doesn't help your case (2) though, since the IO could be done
> > > before the supervisor gets the notification.
> 
> Tycho, I disagree.  Here's how native syscalls work:
> 
> 1. Entry work is done and the syscall hander does whatever it does at
> the beginning of the function.  This is entirely non-interruptible.
> 
> 2. The syscall handler decides it wants to wait, interruptibly,
> killably or otherwise.
> 
> 3. It gets signaled.  It takes appropriate action.  Appropriate action
> does *not* mean -EINTR.  It means that something that is correct *for
> that syscall* happens.  For nanosleep(), this involves the restart
> block (and I don't think we need to support the restart block).  For
> accept(), it mostly seems to mean that the syscall completes as usual.
> For write(2), it means that, depending on file type and whether any IO
> has occured, either -EINTR is returned and no IO happens, or fewer
> bytes than requested are transferred, or the syscall completes.  (Or,
> if it's a KILL, the process dies early and partial IO is ignored.)
> For some syscalls (some AF_UNIX writes, for example, or ptrace()), the
> syscall indeed gets interrupted, but it uses one of the -ERESTART
> mecahnisms.
> 
> User notifiers should allow correct emulation.  Right now, it doesn't,
> but there is no reason it can't.
> 
> > >
> > I think for something like mount, if it fails (gets interrupted) via a
> > fatal signal, that's grounds for terminating the container.
> 
> That would be quite obnoxious if it happens after the container
> starts.  Ctrl-C-ing a fusermount call should not be grounds for
> outright destruction.
> >
> > I see a handful of paths forward:
> >
> > * We add a new action USER_NOTIF_KILLABLE which requires a fatal signal
> >   in order to be interrupted
> > * We add a chunk of data to the USER_NOTIF return code (say, WAIT_KILLABLE)
> >   from the BPF filter that indicates what kind of wait should happen
> > * (what is happening now) An ioctl flag to say pickup the notification
> >   and put it into a wait_killable state
> > * An ioctl "command" that puts an existing notifcation in progress into
> >   the wait killable state.
> 
> In the simplest correct API, I think that kills should always kill the
> task.  Non-kill signals should not kill the syscall but the user
> notifier should be informed that a signal happened.  (Whether this
> requires POLLPRI or some other handshaking mechanism is an open
> question.)
> 
This is pretty easy to do fortunately. I do think that we should have
the ability to do this from the filter as certain syscalls have no
assumptions about how to handle preemption (and while it is waiting for
the supervisor to pick it up, it can be interrupted). We do not want the
intermediate window to act differently. 

I wonder what Kees would prefer.

> The only real downside I see is that genuinely interruptible syscalls
> will end up with higher than necessary signal latency if they occur
> during the interruptible period.  An extended API could allow the
> filter to return an indication that an interrupt should result in a
> specified error code (-EINTR, ERESTARTxyz, etc), and the monitor could
> do a new ioctl() to tell the kernel that the syscall should stop being
> interruptible.  That ioctl() itself would return a status saying
Yeah,
Personally, I'd rather do (in order):
1. ioctl to make syscalls uninterruptible
2. ioctl to re-make syscalls re-interruptible
3. action that upon action handling makes syscall non-interruptible.

I think then I can maybe pickup on Jann's patches to make it so the
supervisor is notified of the interruption if the syscall is interrupted,
but to do this in a non-terrible way is more difficult. I really liked
how Tycho handled memory management in the current notifier, and moving
tracking logic for the in-flight notifications elsewhere feels "icky"
to me, but that's a topic for another day IMHO.

> whether the syscall was already interrupted.  One nice feature of this
> approach is that the existing model is equivalent to the filter saying
> "interruptible with EINTR" and the monitor simply forgetting to do the
> new ioctl.
> 
> --Andy
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
