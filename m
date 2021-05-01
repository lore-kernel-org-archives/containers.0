Return-Path: <SRS0=C7ko=J4=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44FE2C433B4
	for <containers@archiver.kernel.org>; Sat,  1 May 2021 00:10:08 +0000 (UTC)
Received: from smtp2.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id B659F61260
	for <containers@archiver.kernel.org>; Sat,  1 May 2021 00:10:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B659F61260
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sargun.me
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp2.osuosl.org (Postfix) with ESMTP id 7A39743230;
	Sat,  1 May 2021 00:10:07 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp2.osuosl.org ([127.0.0.1])
	by localhost (smtp2.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id sOFGIaY7D5dQ; Sat,  1 May 2021 00:10:06 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp2.osuosl.org (Postfix) with ESMTP id 78763401DD;
	Sat,  1 May 2021 00:10:06 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 5C063C000E;
	Sat,  1 May 2021 00:10:06 +0000 (UTC)
Received: from smtp3.osuosl.org (smtp3.osuosl.org [IPv6:2605:bc80:3010::136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id D4ADFC0001
 for <containers@lists.linux-foundation.org>;
 Sat,  1 May 2021 00:10:04 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp3.osuosl.org (Postfix) with ESMTP id C6F376FA67
 for <containers@lists.linux-foundation.org>;
 Sat,  1 May 2021 00:10:04 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Authentication-Results: smtp3.osuosl.org (amavisd-new);
 dkim=pass (1024-bit key) header.d=sargun.me
Received: from smtp3.osuosl.org ([127.0.0.1])
 by localhost (smtp3.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 9kEEW4agxARQ
 for <containers@lists.linux-foundation.org>;
 Sat,  1 May 2021 00:10:03 +0000 (UTC)
X-Greylist: whitelisted by SQLgrey-1.8.0
Received: from mail-io1-xd33.google.com (mail-io1-xd33.google.com
 [IPv6:2607:f8b0:4864:20::d33])
 by smtp3.osuosl.org (Postfix) with ESMTPS id 940A1606BB
 for <containers@lists.linux-foundation.org>;
 Sat,  1 May 2021 00:10:03 +0000 (UTC)
Received: by mail-io1-xd33.google.com with SMTP id b9so17261574iod.13
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Apr 2021 17:10:03 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sargun.me; s=google;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=8nmI0Z6GpJ669OoqTL4ZRS5HBzAE6mZbx+jGtxyj3s4=;
 b=TAk5su9x4YNFiIahiV9a5aaJzJsZ734/S9ixVX7Bz0n5yF+3hMGaPGzcXNECetsqWg
 JkHS1ySxd3AQSEDQjy+xEZqIembgrUUi7vL6ea9plM5m16ZqVnUV0HCviU/AnqQAXtPQ
 WY0OTMD6LH4B6yZmmlK4gYsgcNJM2o8nMR04c=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=8nmI0Z6GpJ669OoqTL4ZRS5HBzAE6mZbx+jGtxyj3s4=;
 b=FSLPZ1DijjVElgMDwqhv6QGWQ7cN1wZe0sxRpToSnlJgT55PLqvvWfIsW87oQjJ2qB
 jBXgbj5rN18WN0wZAKOx3jEpmtBN/OUuRzeL8vkHsCrrY5p8ZE9XAr4ZSFd4oEZLtywT
 MKyuxAKPk+DCa985sIj13SnkN4n9wPZdeZbzo1sXLTpL95Sm9E3ybo9RDAb7afsr2EUG
 LBUFEQA652oxf101HhEnXqeEuERcKoBZLb1zE1hvcO9NQYlbIe5JztiOYKFNpzCP6M4O
 Ebx+zBCQ6fxpg9WMssjqC5ajQ9EVgU1uBj9zfACJHJrQgFdaP2QEzTCJmEXaDmCAR5QO
 ugqw==
X-Gm-Message-State: AOAM531OYLvmNQiJzmVK6NngSPpI6t8YVj4lWOYBDpqLnBoB5JV/xhA/
 Z+m3UzDwBuBUT8ff+E6uVy61DyAvHl7O+L9AFWZr1g==
X-Google-Smtp-Source: ABdhPJyT0j0QeyzLWjQB1x7+UCsurnHz/q9/z3ussQHoMN5YDGUGkx6sJfukt1wBMQ+0ZnLAhavewmPl1lpbl04zjDE=
X-Received: by 2002:a5d:84c5:: with SMTP id z5mr5722665ior.33.1619827802465;
 Fri, 30 Apr 2021 17:10:02 -0700 (PDT)
MIME-Version: 1.0
References: <20210430204939.5152-1-sargun@sargun.me>
 <20210430204939.5152-3-sargun@sargun.me>
 <CALCETrXWFbB7v8wRKeNC-gxMqUZ9ZJUZx9nQiLu64qYi2Bx5FQ@mail.gmail.com>
In-Reply-To: <CALCETrXWFbB7v8wRKeNC-gxMqUZ9ZJUZx9nQiLu64qYi2Bx5FQ@mail.gmail.com>
From: Sargun Dhillon <sargun@sargun.me>
Date: Fri, 30 Apr 2021 17:09:26 -0700
Message-ID: <CAMp4zn8A2n7EtbR_=fG99MPgpDTgn-Ju-AzQ8F2rYU9Fri3YTg@mail.gmail.com>
Subject: Re: [PATCH v2 2/5] seccomp: Add wait_killable semantic to seccomp
 user notifier
To: Andy Lutomirski <luto@kernel.org>
Cc: Giuseppe Scrivano <gscrivan@redhat.com>, Kees Cook <keescook@chromium.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 LKML <linux-kernel@vger.kernel.org>,
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

On Fri, Apr 30, 2021 at 4:23 PM Andy Lutomirski <luto@kernel.org> wrote:
>
> On Fri, Apr 30, 2021 at 1:49 PM Sargun Dhillon <sargun@sargun.me> wrote:
> >
> > The user notifier feature allows for filtering of seccomp notifications in
> > userspace. While the user notifier is handling the syscall, the notifying
> > process can be preempted, thus ending the notification. This has become a
> > growing problem, as Golang has adopted signal based async preemption[1]. In
> > this, it will preempt every 10ms, thus leaving the supervisor less than
> > 10ms to respond to a given notification. If the syscall require I/O (mount,
> > connect) on behalf of the process, it can easily take 10ms.
> >
> > This allows the supervisor to set a flag that moves the process into a
> > state where it is only killable by terminating signals as opposed to all
> > signals. The process can still be terminated before the supervisor receives
> > the notification.
>
> This is still racy, right?  If a signal arrives after the syscall
> enters the seccomp code but before the supervisor gets around to
> issuing the new ioctl, the syscall will erroneously return -EINTR,
> right?
>
> Can we please just fully fix this instead of piling a racy partial fix
> on top of an incorrect design?
>
> --Andy

I thought that you were fine with this approach. Sorry.

Maybe this is a dumb question, what's wrong with returning an EINTR if the
syscall was never observed by the supervisor?

I think that the only other reasonable design is that we add data to the
existing action which makes it sleep in wait_killable state.
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
