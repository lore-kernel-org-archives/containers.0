Return-Path: <SRS0=wqWt=J3=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39FBCC433B4
	for <containers@archiver.kernel.org>; Fri, 30 Apr 2021 23:23:06 +0000 (UTC)
Received: from smtp2.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id AF98861418
	for <containers@archiver.kernel.org>; Fri, 30 Apr 2021 23:23:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF98861418
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp2.osuosl.org (Postfix) with ESMTP id 77C2043232;
	Fri, 30 Apr 2021 23:23:05 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp2.osuosl.org ([127.0.0.1])
	by localhost (smtp2.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id FGPjTGqF0vdL; Fri, 30 Apr 2021 23:23:04 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp2.osuosl.org (Postfix) with ESMTP id 7C0E1401DD;
	Fri, 30 Apr 2021 23:23:04 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 62C81C000D;
	Fri, 30 Apr 2021 23:23:04 +0000 (UTC)
Received: from smtp3.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 64F36C0001
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Apr 2021 23:23:02 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp3.osuosl.org (Postfix) with ESMTP id 3EB026FA2A
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Apr 2021 23:23:02 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Authentication-Results: smtp3.osuosl.org (amavisd-new);
 dkim=pass (2048-bit key) header.d=kernel.org
Received: from smtp3.osuosl.org ([127.0.0.1])
 by localhost (smtp3.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id m00WtEMDumJn
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Apr 2021 23:23:01 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.8.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
 by smtp3.osuosl.org (Postfix) with ESMTPS id B951A6F8B5
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Apr 2021 23:23:01 +0000 (UTC)
Received: by mail.kernel.org (Postfix) with ESMTPSA id 48D906143D
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Apr 2021 23:23:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
 s=k20201202; t=1619824981;
 bh=uKGdbljdVGUHQi7F59H24hqyS4ay41ngXPz142NF5VI=;
 h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
 b=TPkhZLN8mxjWxsgT2WPk6oH1cLXMqqQ9nnNWxI2CV/P0LxdgS7LzVsu/LCcj6nit6
 DQ+JZSJYMwiLuiGeT9hGYIHEuYmR4x4m2fppC89xVc5IYdj556kY8bBBaLiX4JoZ/8
 1gZQOtXikpwQ3F20xGKHAqFucv8Cw4KGPJGoyWKpIIP96ZnCHnnPw957QRSovdurJZ
 dFTyt/QhMEYMgsGXoH0a2ZLQwTrhYGzljRHwIyTNXPv2J4X6VzNp2atvIx2BGi5fg2
 DPDux58pdd/B+A6caPBaCyyVVF9znLS/6Qbs/aLJESz314TbkYzrC+Dis97QWPz3rV
 vYzTl0Cnrm1kw==
Received: by mail-ej1-f43.google.com with SMTP id t4so24284973ejo.0
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Apr 2021 16:23:01 -0700 (PDT)
X-Gm-Message-State: AOAM533nQ0VlFjOcZ8X8VevhxgsF+BDt9SpJa6XtW9TU15COt0Bcs6rt
 CmVTACXm8szlhB7ytLaXyrOZYEuRPvqPEkDF2HBP1g==
X-Google-Smtp-Source: ABdhPJwbkpKTSR9ZXCaL5ZHH1Qt+HE/3pAODcuL1ueLvo4bd+qN0Bkl1AYINz3PbnMv34jstNqIOUi0Y8B/iArQ9Y5A=
X-Received: by 2002:a17:906:c010:: with SMTP id
 e16mr6883221ejz.214.1619824979806; 
 Fri, 30 Apr 2021 16:22:59 -0700 (PDT)
MIME-Version: 1.0
References: <20210430204939.5152-1-sargun@sargun.me>
 <20210430204939.5152-3-sargun@sargun.me>
In-Reply-To: <20210430204939.5152-3-sargun@sargun.me>
From: Andy Lutomirski <luto@kernel.org>
Date: Fri, 30 Apr 2021 16:22:48 -0700
X-Gmail-Original-Message-ID: <CALCETrXWFbB7v8wRKeNC-gxMqUZ9ZJUZx9nQiLu64qYi2Bx5FQ@mail.gmail.com>
Message-ID: <CALCETrXWFbB7v8wRKeNC-gxMqUZ9ZJUZx9nQiLu64qYi2Bx5FQ@mail.gmail.com>
Subject: Re: [PATCH v2 2/5] seccomp: Add wait_killable semantic to seccomp
 user notifier
To: Sargun Dhillon <sargun@sargun.me>
Cc: Giuseppe Scrivano <gscrivan@redhat.com>, Kees Cook <keescook@chromium.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 LKML <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@kernel.org>,
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

On Fri, Apr 30, 2021 at 1:49 PM Sargun Dhillon <sargun@sargun.me> wrote:
>
> The user notifier feature allows for filtering of seccomp notifications in
> userspace. While the user notifier is handling the syscall, the notifying
> process can be preempted, thus ending the notification. This has become a
> growing problem, as Golang has adopted signal based async preemption[1]. In
> this, it will preempt every 10ms, thus leaving the supervisor less than
> 10ms to respond to a given notification. If the syscall require I/O (mount,
> connect) on behalf of the process, it can easily take 10ms.
>
> This allows the supervisor to set a flag that moves the process into a
> state where it is only killable by terminating signals as opposed to all
> signals. The process can still be terminated before the supervisor receives
> the notification.

This is still racy, right?  If a signal arrives after the syscall
enters the seccomp code but before the supervisor gets around to
issuing the new ioctl, the syscall will erroneously return -EINTR,
right?

Can we please just fully fix this instead of piling a racy partial fix
on top of an incorrect design?

--Andy
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
