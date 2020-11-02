Return-Path: <SRS0=UpRV=EI=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4AA87C388F2
	for <containers@archiver.kernel.org>; Mon,  2 Nov 2020 13:49:37 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 8AEAA2227F
	for <containers@archiver.kernel.org>; Mon,  2 Nov 2020 13:49:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=google.com header.i=@google.com header.b="e6rC0R5e"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8AEAA2227F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id DBDF4203F4;
	Mon,  2 Nov 2020 13:49:35 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id U1kONm61AOv0; Mon,  2 Nov 2020 13:49:35 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id EC2A620028;
	Mon,  2 Nov 2020 13:49:34 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id CFBE6C088B;
	Mon,  2 Nov 2020 13:49:34 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 360F5C0051
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 13:49:33 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 1A2C22010F
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 13:49:33 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 8mDcjLCjKXrY
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 13:49:31 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-lf1-f44.google.com (mail-lf1-f44.google.com
 [209.85.167.44])
 by silver.osuosl.org (Postfix) with ESMTPS id 701B320028
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 13:49:31 +0000 (UTC)
Received: by mail-lf1-f44.google.com with SMTP id y184so15573246lfa.12
 for <containers@lists.linux-foundation.org>;
 Mon, 02 Nov 2020 05:49:31 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=crmhEgzkOmERlRibdWJQ5fJu4CKk3cly9oNaCdoNCWg=;
 b=e6rC0R5eB3PGQ+ozTxEoHwxYIrjTzj/lowbcSttME14YVqM0lIps4VooUuhm29uIFE
 q8sNXcIJGw1ny8hoRglYxZ9KpzrARGaG8u/N9tg9+2fxDLajahu8D7ztqKBx0+P+97wD
 4+7gApcowelSqDo/j7gBpM0LF9LMwoRBhHlWlLF0AWUWkY6K823EIHiJsubXmHK+E3xk
 lOAWs2Oo413J9KNPAL17FSBQ2PIaDC1vMh4rOc652o/EuV589g2E4DXpKlkXZkO6XhAc
 gzqCT04f7oiU+lnIkGSrqs7iuqhzD+uA6V/Vg3+E84dav23WLkJXEsQtCLEKQAUdGu0f
 o0cA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=crmhEgzkOmERlRibdWJQ5fJu4CKk3cly9oNaCdoNCWg=;
 b=ZH6KqRRK0i5Fn9Sk2wGdtKyWTttrq7ciPd6HtQ+W5JRvpDKnepWrgx0vaOo5jEt3uU
 /plIKvHfUoIw4Qt3bF6Gy8P9Y4UjxsEqcfRCvb12DNOwO5udh1R/3FUo565QT338N52J
 Ur03jd630ooUo0AYFl4QKeOZAqTmLVruKP4nKC6WKwfNVtK3HKkNd5Q0t6mr+Ye+S6DA
 dLjKmyjkuuKJFElXVfy+grIp20IJQUg7zboeG0tD7HE0fPvzALx1tDvPpOdEyQ2hs9hw
 pDpsC8qw6dYJwFCNmEvuS1/gMeSTD+C8Wh2edp6S5uoMlgmyLbY+l/mrSPVL7UmlHVL7
 t7mw==
X-Gm-Message-State: AOAM533znQAuNwJo71o7w/ZW0NrRtkJBhFR5fWgV1jDzY9VDxuw17JGc
 Yl7NAz1XkjeW64OnktzqOXmMcxR12eMiuBkJANF9Dg==
X-Google-Smtp-Source: ABdhPJzGqIM5asHLIuy+EbHVmr9RXtwczq03HEhFi/zVkHIauFUcnrDjghLCaRPEjzU8Vbt4y8sReBCfx7RX76nxcBo=
X-Received: by 2002:a05:6512:51a:: with SMTP id
 o26mr5441083lfb.381.1604324969162; 
 Mon, 02 Nov 2020 05:49:29 -0800 (PST)
MIME-Version: 1.0
References: <63598b4f-6ce3-5a11-4552-cdfe308f68e4@gmail.com>
 <CAG48ez0fBE6AJfWh0in=WKkgt98y=KjAen=SQPyTYtvsUbF1yA@mail.gmail.com>
 <0de41eb1-e1fd-85da-61b7-fac4e3006726@gmail.com>
 <CAG48ez3qKg-ReY4R=S_thQ6tOzv2ZHV=xW5qBxpqs0iSjH_oFQ@mail.gmail.com>
 <9f9b8b86-6e49-17ef-e414-82e489b0b99a@gmail.com>
In-Reply-To: <9f9b8b86-6e49-17ef-e414-82e489b0b99a@gmail.com>
Date: Mon, 2 Nov 2020 14:49:01 +0100
Message-ID: <CAG48ez0W2zye2KeNiVaKq9RPtUhcUtzP0zOjULRQZbOuRyz+9w@mail.gmail.com>
Subject: Re: For review: seccomp_user_notif(2) manual page [v2]
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
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

On Sat, Oct 31, 2020 at 9:31 AM Michael Kerrisk (man-pages)
<mtk.manpages@gmail.com> wrote:
> On 10/30/20 8:14 PM, Jann Horn wrote:
> > With the caveat that a cancelled syscall
> > could've also led to the memory being munmap()ed, so the nread==0 case
> > could also happen legitimately - so you might want to move this check
> > up above the nread==0 (mm went away) and nread==-1 (mm still exists,
> > but read from address failed, errno EIO) checks if the error message
> > shouldn't appear spuriously.
>
> In any case, I've been refactoring (simplifying) that code a little.
> I haven't so far rearranged the order of the checks, but I already
> log message for the nread==0 case. (Instead, there will eventually
> be an error when the response is sent.)
>
> I also haven't exactly tested the scenario you describe in the
> seccomp unotify scenario, but I think the above is not correct. Here
> are two scenarios I did test, simply with mmap() and /proc/PID/mem
> (no seccomp involved):
>
> Scenario 1:
> A creates a mapping at address X
> B opens /proc/A/mem and and lseeks on resulting FD to offset X
> A terminates
> B reads from FD ==> read() returns 0 (EOF)
>
> Scenario 2:
> A creates a mapping at address X
> B opens /proc/A/mem and and lseeks on resulting FD to offset X
> A unmaps mapping at address X
> B reads from FD ==> read() returns -1 / EIO.
>
> That last scenario seems to contradict what you say, since I
> think you meant that in this case read() should return 0 in
> that case. Have I misunderstood you?

Sorry, I messed up the description when I wrote that. Yes, this looks
as expected - EIO if the VMA is gone, 0 if the mm_users of the
mm_struct have dropped to zero because all tasks that use the mm have
exited.
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
