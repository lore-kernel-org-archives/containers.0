Return-Path: <SRS0=DMKn=EC=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65492C4363A
	for <containers@archiver.kernel.org>; Tue, 27 Oct 2020 10:28:54 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id BB13E22263
	for <containers@archiver.kernel.org>; Tue, 27 Oct 2020 10:28:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=google.com header.i=@google.com header.b="SX3vumt+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BB13E22263
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 47EFA84DFD;
	Tue, 27 Oct 2020 10:28:53 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id KHnFLeQHmrjw; Tue, 27 Oct 2020 10:28:52 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id C00EC84C09;
	Tue, 27 Oct 2020 10:28:52 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 95BE9C088B;
	Tue, 27 Oct 2020 10:28:52 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 1C69FC0051
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Oct 2020 10:28:51 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 1832B87258
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Oct 2020 10:28:51 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id xqJf+3umOY6L
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Oct 2020 10:28:50 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-lj1-f194.google.com (mail-lj1-f194.google.com
 [209.85.208.194])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 2022D871F1
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Oct 2020 10:28:50 +0000 (UTC)
Received: by mail-lj1-f194.google.com with SMTP id h20so1122713lji.9
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Oct 2020 03:28:50 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=SXBs8vJX4cJod5E0ma8hUPOwIJojpK61dnpKV/ODZKw=;
 b=SX3vumt+l2xFwFJ7RtGU6f2QwqvLXBNvJIBGPSr2ScNXfHRvXmCpg0n+1g5TYU5nLS
 er6t1l0zNORBj09H+ZooUZPlhEvAKaZMbyK0tHvjx0xf52Lc9zV+/VxaRuXfwO4j3DZS
 BSNoLT8j8uzFqjMddbNAbinjHbTmVWxpugf1ax7hBpEqrp2fvnzsaWEb4iG/OB2c4AIp
 FrLQX+f5C4iZYd6tWM5RnEW7S020S60vUQngFeSZlbJMHUEJWPe4WaELOPFP4YaGQrF2
 Er58dEZ1XpSNCN8LI1ddVAiSEzdRCBcuY84l0Wi5OvgFYxs5XmBA8iYYSQdbkdikXUET
 gTzw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=SXBs8vJX4cJod5E0ma8hUPOwIJojpK61dnpKV/ODZKw=;
 b=k3hCe82VtJfnQ9xhvyOF1ROhFbMwNxU/xFwyfLw/Om8yxpSiZdG7x8QaVBKz83bFFO
 FcWJbmrLzrn1OGmNuWQZoSvkfzRd6vQ0v3zlf6e3XWrZ2EVY20tCjMTeZ+/Qy1xId2Z6
 1F8QRhYPlqF/r5AOOWKoV6ZN6IF4S21yb0nDyvhB+Y4lZgYf2lVw7F0xbXBgRkGdaNhZ
 AfKKd3W3bDIxSHXcDeD8r675TV5+NW9s/K451lRewkqUxdDoYUwcZkssLXYnwtzR9zJw
 O4WpOUDoVG9hlJHwmQREC5crUDFsJi0cHjoAL4tozqnpyIz+spz2kn0p1Kt7MotBJijw
 bcDA==
X-Gm-Message-State: AOAM533Yby0J56K229X4ABAhEneMg/n9aKzF2lgHGTrBgLQpsLOax6De
 CbqLitMcohKWHNRVG+AmIkzqddhYbSL8LAgDrgkrYA==
X-Google-Smtp-Source: ABdhPJxJshhNft3hUOxXAULUlOUPgHVANJYgBC/Mm8PWirgk1D2JwvX0yuxEiO1qIxFs4Z4pw393eScZt+DPrsMeX1c=
X-Received: by 2002:a2e:9c84:: with SMTP id x4mr750615lji.326.1603794527981;
 Tue, 27 Oct 2020 03:28:47 -0700 (PDT)
MIME-Version: 1.0
References: <45f07f17-18b6-d187-0914-6f341fe90857@gmail.com>
 <20200930150330.GC284424@cisco>
 <8bcd956f-58d2-d2f0-ca7c-0a30f3fcd5b8@gmail.com>
 <20200930230327.GA1260245@cisco>
 <CAG48ez1VOUEHVQyo-2+uO7J+-jN5rh7=KmrMJiPaFjwCbKR1Sg@mail.gmail.com>
 <20200930232456.GB1260245@cisco>
 <CAG48ez2xn+_KznEztJ-eVTsTzkbf9CVgPqaAk7TpRNAqbdaRoA@mail.gmail.com>
 <CAG48ez3kpEDO1x_HfvOM2R9M78Ach9O_4+Pjs-vLLfqvZL+13A@mail.gmail.com>
 <656a37b5-75e3-0ded-6ba8-3bb57b537b24@gmail.com>
 <CAG48ez2Uy8=Tz9k1hcr0suLPHjbJi1qUviSGzDQ-XWEGsdNU+A@mail.gmail.com>
 <e2643168-b5d5-4d8c-947a-7895bcabc268@gmail.com>
In-Reply-To: <e2643168-b5d5-4d8c-947a-7895bcabc268@gmail.com>
Date: Tue, 27 Oct 2020 11:28:20 +0100
Message-ID: <CAG48ez2Nb95ae+XwZPYRju1KO-Ps_4R6QxN6ioUhOy2Uok=uAg@mail.gmail.com>
Subject: Re: For review: seccomp_user_notif(2) manual page
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: linux-man <linux-man@vger.kernel.org>, Song Liu <songliubraving@fb.com>,
 Will Drewry <wad@chromium.org>, Kees Cook <keescook@chromium.org>,
 Daniel Borkmann <daniel@iogearbox.net>,
 Giuseppe Scrivano <gscrivan@redhat.com>, Robert Sesek <rsesek@google.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
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

On Tue, Oct 27, 2020 at 7:14 AM Michael Kerrisk (man-pages)
<mtk.manpages@gmail.com> wrote:
> On 10/26/20 4:54 PM, Jann Horn wrote:
> > I'm a bit on the fence now on whether non-blocking mode should use
> > ENOTCONN or not... I guess if we returned ENOENT even when there are
> > no more listeners, you'd have to disambiguate through the poll()
> > revents, which would be kinda ugly?
>
> I must confess, I'm not quite clear on which two cases you
> are trying to distinguish. Can you elaborate?

Let's say someone writes a program whose responsibilities are just to
handle seccomp events and to listen on some other fd for commands. And
this is implemented with an event loop. Then once all the target
processes are gone (including zombie reaping), we'll start getting
EPOLLERR.

If NOTIF_RECV starts returning -ENOTCONN at this point, the event loop
can just call into the seccomp logic without any arguments; it can
just call NOTIF_RECV one more time, see the -ENOTCONN, and terminate.
The downside is that there's one more error code userspace has to
special-case.
This would be more consistent with what we'd be doing in the blocking case.

If NOTIF_RECV keeps returning -ENOENT, the event loop has to also tell
the seccomp logic what the revents are.

I guess it probably doesn't really matter much.
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
