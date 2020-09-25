Return-Path: <SRS0=50w+=DC=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 15869C4727F
	for <containers@archiver.kernel.org>; Fri, 25 Sep 2020 19:42:45 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 6F2A523888
	for <containers@archiver.kernel.org>; Fri, 25 Sep 2020 19:42:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="dtRToJmy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F2A523888
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id C296D20356;
	Fri, 25 Sep 2020 19:42:43 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id uUBVFX2Sisyi; Fri, 25 Sep 2020 19:42:42 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id D0F152034A;
	Fri, 25 Sep 2020 19:42:42 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id B623BC0859;
	Fri, 25 Sep 2020 19:42:42 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id E9A20C0051
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 19:42:40 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id D193A87678
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 19:42:40 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id X30i8wpg+ruw
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 19:42:40 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pj1-f65.google.com (mail-pj1-f65.google.com
 [209.85.216.65])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 3FB858766F
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 19:42:40 +0000 (UTC)
Received: by mail-pj1-f65.google.com with SMTP id fa1so60256pjb.0
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 12:42:40 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:in-reply-to;
 bh=1VTbmlxP/NBx4Wl43Zwmsnljn3SCRy51x1r81CV0BZM=;
 b=dtRToJmyHTTr67lrP3SrUIoLxJrrKsByqQJ1DZqoALfG2zQF4UhGdYQvTnp8NK+c8D
 WvYzv4Xi3KqVHy8qs+yI4HHZLz2S644qeifFYle7DzsHYiTpCwSAc5aDg9+Kc2qNouQm
 4lO83kqhdbxY461s8apYSrnvsCnFPC2jx1V7U=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:in-reply-to;
 bh=1VTbmlxP/NBx4Wl43Zwmsnljn3SCRy51x1r81CV0BZM=;
 b=W7EM2sUAso2XRDwDt0hcA38nHKRQsWs9ppnZ+ECrboTZbbDbqF/xUtUE+1Fi6x/jUA
 h7gaHsDBnIPpbNEYW15/yLXsppFZ/70/LUTEDU6Z2qQ3bd82UM1gJsR7lzO0e1fmI93Q
 qh3rUMRKgmpY7M2Coj/q2auKIfw+Bz8lVirNWzYvdmWhvOCYwxPffQlr1HelBsJ2xTmh
 gLI5+4/LobD0lNvnSTatCWA09154xkyEjBsmlyM7ZglzuusZJzH7bxkKSgCUH0DB9t5+
 MSH1s2kTENX2bJfUrE+9ogICfOXzrZgZP2VcC0qrTo7Js2zRDASHsFBIPM/XZwC3+jE2
 25Iw==
X-Gm-Message-State: AOAM533RjHJbRoOshl91vPXOj8WWUZfBgCNvGGvDMeLrUDDetvGNfSUq
 I4RMHaMzYJmxdEV/44vmfWpvNw==
X-Google-Smtp-Source: ABdhPJzf8ii6Mz6aePsI1Nr3EqtgEdasIytrUnQQEYjVuc6D6GJRGQUbTLrAOQNeoMvoaFUsDiVHrg==
X-Received: by 2002:a17:90b:a0a:: with SMTP id
 gg10mr170348pjb.20.1601062959821; 
 Fri, 25 Sep 2020 12:42:39 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id kk17sm26681pjb.31.2020.09.25.12.42.38
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Fri, 25 Sep 2020 12:42:38 -0700 (PDT)
Date: Fri, 25 Sep 2020 12:42:37 -0700
From: Kees Cook <keescook@chromium.org>
To: YiFei Zhu <zhuyifei1999@gmail.com>
Subject: Re: [PATCH v2 seccomp 3/6] seccomp/cache: Add "emulator" to check if
 filter is arg-dependent
Message-ID: <202009251223.8E46C831E2@keescook>
References: <cover.1600951211.git.yifeifz2@illinois.edu>
 <c14518ba563d4c6bb75b9fac63b69cd4c82f9dcc.1600951211.git.yifeifz2@illinois.edu>
 <202009241601.FFC0CF68@keescook>
 <CABqSeARb7GNU9+sVgGzgqqOmpQNpxq1JsMrZJvS2EC05AyfAVw@mail.gmail.com>
 <CABqSeASM9B77QrWRbqRF19N9-m-bm779-7a3qEDa8NumjBsorw@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CABqSeASM9B77QrWRbqRF19N9-m-bm779-7a3qEDa8NumjBsorw@mail.gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, Jann Horn <jannh@google.com>,
 YiFei Zhu <yifeifz2@illinois.edu>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>,
 kernel list <linux-kernel@vger.kernel.org>,
 Andy Lutomirski <luto@amacapital.net>, Hubertus Franke <frankeh@us.ibm.com>,
 Jack Chen <jianyan2@illinois.edu>, Dimitrios Skarlatos <dskarlat@cs.cmu.edu>,
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
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

On Fri, Sep 25, 2020 at 11:45:05AM -0500, YiFei Zhu wrote:
> On Thu, Sep 24, 2020 at 10:04 PM YiFei Zhu <zhuyifei1999@gmail.com> wrote:
> > > Why do the prepare here instead of during attach? (And note that it
> > > should not be written to fail.)
> >
> > Right.
> 
> During attach a spinlock (current->sighand->siglock) is held. Do we
> really want to put the emulator in the "atomic section"?

It's a good point, but I had some other ideas around it that lead to me
a different conclusion. Here's what I've got in my head:

I don't view filter attach (nor the siglock) as fastpath: the lock is
rarely contested and the "long time" will only be during filter attach.

When performing filter emulation, all the syscalls that are already
marked as "must run filter" on the previous filter can be skipped for
the new filter, since it cannot change the outcome, which makes the
emulation step faster.

The previous filter's bitmap isn't "stable" until siglock is held.

If we do the emulation step before siglock, we have to always do full
evaluation of all syscalls, and then merge the bitmap during attach.
That means all filters ever attached will take maximal time to perform
emulation.

I prefer the idea of the emulation step taking advantage of the bitmap
optimization, since the kernel spends less time doing work over the life
of the process tree. It's certainly marginal, but it also lets all the
bitmap manipulation stay in one place (as opposed to being split between
"prepare" and "attach").

What do you think?

-- 
Kees Cook
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
