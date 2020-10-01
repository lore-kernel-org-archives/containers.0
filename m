Return-Path: <SRS0=WbUC=DI=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95E46C4727E
	for <containers@archiver.kernel.org>; Thu,  1 Oct 2020 16:05:31 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 154C1204EA
	for <containers@archiver.kernel.org>; Thu,  1 Oct 2020 16:05:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=google.com header.i=@google.com header.b="v0zUtKZZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 154C1204EA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id BB27D86A6F;
	Thu,  1 Oct 2020 16:05:30 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id QKxz0dXpvRV0; Thu,  1 Oct 2020 16:05:30 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 18AF486A51;
	Thu,  1 Oct 2020 16:05:30 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id E8C78C016F;
	Thu,  1 Oct 2020 16:05:29 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 5CC56C0051
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 16:05:29 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 4EA658735B
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 16:05:29 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id I1Yy5aAAyeUD
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 16:05:28 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-ej1-f66.google.com (mail-ej1-f66.google.com
 [209.85.218.66])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 6908B87353
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 16:05:28 +0000 (UTC)
Received: by mail-ej1-f66.google.com with SMTP id ce10so2811783ejc.5
 for <containers@lists.linux-foundation.org>;
 Thu, 01 Oct 2020 09:05:28 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=IMB73dDKkouoCGF4bPiVkzHfDrWjLelK7eqM7hnqOfQ=;
 b=v0zUtKZZ9u7C+SlsQ2sjJJXn5TQDdDxiCusGcV7Bneg7l6BBK2FRvU6tKaf6cwbkZr
 Bxr4HqFic8ETbL+6s6FkrDBJ6RrJRdxI5e6jH9HqzuAdekZiVBeBfcE+BsIOQYPibWjH
 5wDBH5QUEc3dmwkTqAvAlue2C4c55WjFjAt60tuobqpclbLDVXzW3t/vv/ks3GMmLmS3
 6Ce5Q9qnrrxYVWmqMxqGZedF4dz75mbs5iMjV4WMHNXLA/xqRf88EKEmLm0XEz+E9Fl7
 PyFGoySwCEvboCSlpTknQ/0twIK7Hhr3NtN64G/bzOO0hO0Q5LjfZQ38IYFXieNRFg9b
 ZFXQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=IMB73dDKkouoCGF4bPiVkzHfDrWjLelK7eqM7hnqOfQ=;
 b=FwmiRJBqXMjXoKFzXx98zFKm081WONsmnRW/NhWqHnpOwNOyd7Y3sZTPcWSMkj1lGJ
 Gok5Pn/1nwKdObg8EAi4QbqTGc1718vLPZ4Srlr2aQstOM0IF1slWj1XK5upOcCq/xm0
 NsNcBDrQ056ym4bGL9gmZJQHvqD63eSaan5Ja8TOLUIX3vmVE8S9PVIVKJejb0dJBNPj
 82zexoS2qFVjDcy32b6uenPbPRMP0ab2L9yFOVZRb1+vh2m6PS9MYaCvHgTH0GUtOp9h
 qi0XUDLp5DEJPDP1eJhUQ8ZDvJb3McFo8CtZx5OGHKMC4nvgGl3CqcDUZ0uayVb8hmBc
 gqeA==
X-Gm-Message-State: AOAM531BZCBxh/0gbpFyxkVLjHUYl6HbCW7O4VHj8uh5Xz867V5Ei3Vs
 G7G7pM5PuD+FHa9ykxJkiyRt8WGDWx0SChNOrkV6Fg==
X-Google-Smtp-Source: ABdhPJxKtttAvVo28q3xfu3pZ2Zdcn3tId/kcpgfnRwxqrJNDHKqiBhxtoN0zCN6pGxjHl75UiIS9gSFsZdo/e98VLw=
X-Received: by 2002:a17:906:33c8:: with SMTP id
 w8mr4247020eja.233.1601568326659; 
 Thu, 01 Oct 2020 09:05:26 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1601478774.git.yifeifz2@illinois.edu>
 <d3d1c05ea0be2b192f480ec52ad64bffbb22dc9d.1601478774.git.yifeifz2@illinois.edu>
 <CAG48ez0whaSTobwnoJHW+Eyqg5a8H4JCO-KHrgsuNiEg0qbD3w@mail.gmail.com>
 <CABqSeATEMTB_hRt9D9teW6GcDvz4VLfMQyvX=nvgR4Uu4+AgoA@mail.gmail.com>
In-Reply-To: <CABqSeATEMTB_hRt9D9teW6GcDvz4VLfMQyvX=nvgR4Uu4+AgoA@mail.gmail.com>
Date: Thu, 1 Oct 2020 18:05:00 +0200
Message-ID: <CAG48ez3nqG_O3OYLLffVOcFf+ONgFwU9mc+HZ1GixBPbHZLyvw@mail.gmail.com>
Subject: Re: [PATCH v3 seccomp 5/5] seccomp/cache: Report cache data through
 /proc/pid/seccomp_cache
To: YiFei Zhu <zhuyifei1999@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, Kees Cook <keescook@chromium.org>,
 YiFei Zhu <yifeifz2@illinois.edu>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>,
 kernel list <linux-kernel@vger.kernel.org>,
 Andy Lutomirski <luto@amacapital.net>, Hubertus Franke <frankeh@us.ibm.com>,
 David Laight <David.Laight@aculab.com>, Jack Chen <jianyan2@illinois.edu>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>,
 Josep Torrellas <torrella@illinois.edu>, Will Drewry <wad@chromium.org>,
 bpf <bpf@vger.kernel.org>, Tianyin Xu <tyxu@illinois.edu>
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

On Thu, Oct 1, 2020 at 2:06 PM YiFei Zhu <zhuyifei1999@gmail.com> wrote:
> On Wed, Sep 30, 2020 at 5:01 PM Jann Horn <jannh@google.com> wrote:
> > Hmm, this won't work, because the task could be exiting, and seccomp
> > filters are detached in release_task() (using
> > seccomp_filter_release()). And at the moment, seccomp_filter_release()
> > just locklessly NULLs out the tsk->seccomp.filter pointer and drops
> > the reference.
> >
> > The locking here is kind of gross, but basically I think you can
> > change this code to use lock_task_sighand() / unlock_task_sighand()
> > (see the other examples in fs/proc/base.c), and bail out if
> > lock_task_sighand() returns NULL. And in seccomp_filter_release(), add
> > something like this:
> >
> > /* We are effectively holding the siglock by not having any sighand. */
> > WARN_ON(tsk->sighand != NULL);
>
> Ah thanks. I was thinking about how tasks exit and get freed and that
> sort of stuff, and how this would race against them. The last time I
> worked with procfs there was some magic going on that I could not
> figure out, so I was thinking if some magic will stop the task_struct
> from being released, considering it's an argument here.
>
> I just looked at release_task and related functions; looks like it
> will, at the end, decrease the reference count of the task_struct.
> Does procfs increase the refcount while calling the procfs functions?
> Hence, in procfs functions one can rely on the task_struct still being
> a task_struct, but any direct effects of release_task may happen while
> the procfs functions are running?

Yeah.

The ONE() entry you're adding to tgid_base_stuff is used to help
instantiate a "struct inode" when someone looks up the path
"/proc/$tgid/seccomp_cache"; then when that path is opened, a "struct
file" is created that holds a reference to the inode; and while that
file exists, your proc_pid_seccomp_cache() can be invoked.

proc_pid_seccomp_cache() is invoked from proc_single_show()
("PROC_I(inode)->op.proc_show" is proc_pid_seccomp_cache), and
proc_single_show() obtains a temporary reference to the task_struct
using get_pid_task() on a "struct pid" and drops that reference
afterwards with put_task_struct(). The "struct pid" is obtained from
the "struct proc_inode", which is essentially a subclass of "struct
inode". The "struct pid" is kept refererenced until the inode goes
away, via proc_pid_evict_inode(), called by proc_evict_inode().

By looking at put_task_struct() and its callees, you can figure out
which parts of the "struct task" are kept alive by the reference to
it.

By the way, maybe it'd make sense to add this to tid_base_stuff as
well? That should just be one extra line of code. Seccomp filters are
technically per-thread, so it would make sense to have them visible in
the per-thread subdirectories /proc/$pid/task/$tid/.
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
