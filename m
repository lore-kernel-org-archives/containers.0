Return-Path: <SRS0=MeFG=EE=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5AC0AC4363A
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 04:44:11 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 768F720739
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 04:44:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=google.com header.i=@google.com header.b="gZ8H/p46"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 768F720739
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id D5A4C86948;
	Thu, 29 Oct 2020 04:44:09 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id AHT60lP57TQq; Thu, 29 Oct 2020 04:44:09 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 14AEA85477;
	Thu, 29 Oct 2020 04:44:09 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id F3015C0859;
	Thu, 29 Oct 2020 04:44:08 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id F100BC0051
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 04:44:07 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id E528086A2F
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 04:44:07 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id nRBe5Hxu6eva
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 04:44:04 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-lj1-f196.google.com (mail-lj1-f196.google.com
 [209.85.208.196])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 1631D8697D
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 04:44:04 +0000 (UTC)
Received: by mail-lj1-f196.google.com with SMTP id i2so1684868ljg.4
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Oct 2020 21:44:03 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=8vJY7X+2qf9mk4yjNjSimkTKUqnRW4h3rIif/0iLOrE=;
 b=gZ8H/p46CECRx9wDoVffbN/h0TJ0bUslUCW4zEC9UGCLKm/cXqu5uiZC1A8cryr+E8
 e0dLqac5CrQ0wZy68hcC5mDMEnQW3ZBUwc7+nrlVGLwjzOWHmxGB84B6A7tq9XDnv19s
 M7QjYPJ1Rgm+8fE1FFuZrcNgCnJkq5XlKbHAN6QN93QfeuU4o+r0DZj/rSPyFxLyR9HX
 goLYDldHw4PKN4C16oNQfIjUL+sxQTmKcTIGcQlhOv8tjXF8krfMfUE47zD8S0ABnIzk
 C8yOWDT4K5Mx4UbUn4ZaqYyEFrICmzbt6zNb1oXbkYLIFdMceLLg+ASw3I9w2T4L15rH
 1NBg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=8vJY7X+2qf9mk4yjNjSimkTKUqnRW4h3rIif/0iLOrE=;
 b=ftaI5LzTJxkQTAGJ/cUfkNyB/01CcrUaoQ5MXEHX9W3fE7+8id/7j4Dldvg20kGgFR
 P88pNfP+Ht+E1THGu4pCTNSw1mkRGiB1n+hwucXNxDOSxYDuXP0apRo4qCK5dNkr7cgx
 I5gzuG+dSrJjwCpRoVO5HlwjhOxtwL6YDaoirWcF39x4RV5Gc2PcuxK3Vk9xgB7oNovk
 NRB5eW9akH852rEH1AlgBcJu7rGH0AgHDh73Zw/vSbehB2kNsxKagH7wxc8xXfE0gvWO
 WlQ47UdnGICbvTMt/fgmDA32l2sXihK2V64kqbi34Qitd0VdIU+u/gbuyX5KTGILNBPA
 FCCw==
X-Gm-Message-State: AOAM532lZeny+xWB+2a8Ju3zz4M3NaP10dfo+3yOuXVuHMYJLXWeY53V
 xUAg5ZIWD5znqNqI1lmtp0qXpx6d9f3Ye7S6YAVoUw==
X-Google-Smtp-Source: ABdhPJw/sZxb5qRToKpsO6Tov3q5O2h9QxUZH9e9awkjhLv1ZkCLPaqe/eslUoWDbcpwUPRAcE7vE1CzAPHEQGncXAA=
X-Received: by 2002:a2e:9c84:: with SMTP id x4mr981272lji.326.1603946642027;
 Wed, 28 Oct 2020 21:44:02 -0700 (PDT)
MIME-Version: 1.0
References: <63598b4f-6ce3-5a11-4552-cdfe308f68e4@gmail.com>
 <CAG48ez0fBE6AJfWh0in=WKkgt98y=KjAen=SQPyTYtvsUbF1yA@mail.gmail.com>
 <20201029020438.GA25673@cisco>
In-Reply-To: <20201029020438.GA25673@cisco>
Date: Thu, 29 Oct 2020 05:43:35 +0100
Message-ID: <CAG48ez1Jz5YqqEMFYoFhgSroHwMeiNqUU9i=QqLN2uLibKthDQ@mail.gmail.com>
Subject: Re: For review: seccomp_user_notif(2) manual page [v2]
To: Tycho Andersen <tycho@tycho.pizza>, 
 "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Giuseppe Scrivano <gscrivan@redhat.com>, Song Liu <songliubraving@fb.com>,
 Will Drewry <wad@chromium.org>, Kees Cook <keescook@chromium.org>,
 Daniel Borkmann <daniel@iogearbox.net>, linux-man <linux-man@vger.kernel.org>,
 Robert Sesek <rsesek@google.com>,
 Containers <containers@lists.linux-foundation.org>,
 lkml <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
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

On Thu, Oct 29, 2020 at 3:04 AM Tycho Andersen <tycho@tycho.pizza> wrote:
> On Thu, Oct 29, 2020 at 02:42:58AM +0100, Jann Horn wrote:
> > On Mon, Oct 26, 2020 at 10:55 AM Michael Kerrisk (man-pages)
> > <mtk.manpages@gmail.com> wrote:
> > >        static bool
> > >        getTargetPathname(struct seccomp_notif *req, int notifyFd,
> > >                          char *path, size_t len)
> > >        {
> > >            char procMemPath[PATH_MAX];
> > >
> > >            snprintf(procMemPath, sizeof(procMemPath), "/proc/%d/mem", req->pid);
> > >
> > >            int procMemFd = open(procMemPath, O_RDONLY);
> > >            if (procMemFd == -1)
> > >                errExit("\tS: open");
> > >
> > >            /* Check that the process whose info we are accessing is still alive.
> > >               If the SECCOMP_IOCTL_NOTIF_ID_VALID operation (performed
> > >               in checkNotificationIdIsValid()) succeeds, we know that the
> > >               /proc/PID/mem file descriptor that we opened corresponds to the
> > >               process for which we received a notification. If that process
> > >               subsequently terminates, then read() on that file descriptor
> > >               will return 0 (EOF). */
> > >
> > >            checkNotificationIdIsValid(notifyFd, req->id);
> > >
> > >            /* Read bytes at the location containing the pathname argument
> > >               (i.e., the first argument) of the mkdir(2) call */
> > >
> > >            ssize_t nread = pread(procMemFd, path, len, req->data.args[0]);
> > >            if (nread == -1)
> > >                errExit("pread");
> >
> > As discussed at
> > <https://lore.kernel.org/r/CAG48ez0m4Y24ZBZCh+Tf4ORMm9_q4n7VOzpGjwGF7_Fe8EQH=Q@mail.gmail.com>,
> > we need to re-check checkNotificationIdIsValid() after reading remote
> > memory but before using the read value in any way. Otherwise, the
> > syscall could in the meantime get interrupted by a signal handler, the
> > signal handler could return, and then the function that performed the
> > syscall could free() allocations or return (thereby freeing buffers on
> > the stack).
> >
> > In essence, this pread() is (unavoidably) a potential use-after-free
> > read; and to make that not have any security impact, we need to check
> > whether UAF read occurred before using the read value. This should
> > probably be called out elsewhere in the manpage, too...
> >
> > Now, of course, **reading** is the easy case. The difficult case is if
> > we have to **write** to the remote process... because then we can't
> > play games like that. If we write data to a freed pointer, we're
> > screwed, that's it. (And for somewhat unrelated bonus fun, consider
> > that /proc/$pid/mem is originally intended for process debugging,
> > including installing breakpoints, and will therefore happily write
> > over "readonly" private mappings, such as typical mappings of
> > executable code.)
> >
> > So, uuuuh... I guess if anyone wants to actually write memory back to
> > the target process, we'd better come up with some dedicated API for
> > that, using an ioctl on the seccomp fd that magically freezes the
>
> By freeze here you mean a killable wait instead of an interruptible
> wait, right?

Nope, nonkillable.

Consider the case of vfork(), where a target process does something like this:

void spawn_executable(char **argv, char **envv) {
  pid_t child = vfork();
  if (child == 0) {
    char path[1000];
    sprintf(path, ...);
    execve(path, argv, envv);
  }
}

and the seccomp notifier wants to look at the execve() path (as a
somewhat silly example). The child process is just borrowing the
parent's stack, and as soon as the child either gets far enough into
execve() or dies, the parent continues using that stack. So keeping
the child in killable sleep would not be enough to prevent reuse of
the child's stack.


But conceptually that's not really a big problem - we already have a
way to force the target task to stay inside the seccomp code no matter
if it gets SIGKILLed or whatever, and that is to take the notify_lock.
When the target task wakes up and wants to continue executing, it has
to first get through mutex_lock(&match->notify_lock) - and that will
always block until the lock is free. So we could e.g. do something
like:

 - Grab references to the source pages in the supervisor's address
space with get_user_pages_fast().
 - Take mmap_sem on the target.
 - Grab references to pages in the relevant range with pin_user_pages_remote().
 - Drop the mmap_sem.
 - Take the notify_lock.
 - Recheck whether the notification with the right ID is still there.
 - Copy data from the pinned source pages to the pinned target pages.
 - Drop the notify_lock.
 - Drop the page references.

and this way we would still guarantee that the target process would
only be blocked in noninterruptible sleep for a small amount of time
(and would not be indirectly blocked on sleeping operations through
the mutex). It'd be pretty straightforward, I think. But as long as we
don't actually need it, it might be easier to just note in the manpage
that this is not currently supported.
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
