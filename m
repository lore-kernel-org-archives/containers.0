Return-Path: <SRS0=lkaS=DB=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 328ADC4346E
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 08:15:32 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 93B982068D
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 08:15:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="RVei7Bv4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 93B982068D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 34D59874C2;
	Thu, 24 Sep 2020 08:15:30 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id QCIpSG8pLyBV; Thu, 24 Sep 2020 08:15:29 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id A78B3874BD;
	Thu, 24 Sep 2020 08:15:29 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 8BF74C0889;
	Thu, 24 Sep 2020 08:15:29 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 1282DC0051
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 08:15:28 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 03A96874BF
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 08:15:28 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id KjZEiNqxSCB3
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 08:15:27 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pf1-f196.google.com (mail-pf1-f196.google.com
 [209.85.210.196])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 63B6D874BD
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 08:15:27 +0000 (UTC)
Received: by mail-pf1-f196.google.com with SMTP id f18so1415412pfa.10
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 01:15:27 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:in-reply-to;
 bh=U2el13qFqXukTglGs7cvKDB4IKPjADIDv75hQ/9i9+E=;
 b=RVei7Bv4JMWbyvkyLgdFQFwYfIpkjYeRy3yleinFgOrptu3zTUE/9EyHI98NN+C/im
 x+96TesErw40CMW2cMSm5o5OF37NXz5frZ+kCND0pFHvWzwiM02cMCdZCtO/oRNKJHyH
 BqTHY9BpOHNgc+U56i6p8SKaUYIHr4tUX87jM=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:in-reply-to;
 bh=U2el13qFqXukTglGs7cvKDB4IKPjADIDv75hQ/9i9+E=;
 b=Yvcix6QZwvjBfaX9PS7yHeY8Q4l/MOXutTrOvaYrA+BPHYzlC+d/IyGlB86uaKaQbl
 Lx7Bgg0n1AzIkncgVRlg/Jq7DiDsRYEDqWBCYJpkydmmURsrlAvR9LyiZfDzEc4zF6KQ
 hObne65BGaGEjVUTKdeocOTi6Ey7a41SBE/klLI+owOxm5QkDqsd/uzE4iUq1sqIYgvj
 tcT9ABL70cUbylMuYQ/1G2qaWzKWlb8wWFtdTMqG9o9oFj8IrmpGOej1yhUNOdxkX4Id
 eHIgr4h2BTXqPFyOxrNTxHLwFDNzBj8sJ5lJNmbHYLK1uBm1Zl0nNJO3WQGDtYVv3b6P
 REmg==
X-Gm-Message-State: AOAM531AQ3elofHzVwV30Vhz0C2+q4RjMCLZuzysHB382l0UClLEL7Nf
 ONA9UkGwUB7OJeMf3roBwuQ+tA==
X-Google-Smtp-Source: ABdhPJxpG1Cp3bwo9P3GzvSQphN8aQzF+v4CUOKCDxb9oKuyX9qUhNPoAp+ludYIjdThKbRJpvKwPg==
X-Received: by 2002:a63:ea16:: with SMTP id c22mr2984137pgi.326.1600935326829; 
 Thu, 24 Sep 2020 01:15:26 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id q193sm1932012pfq.127.2020.09.24.01.15.25
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Thu, 24 Sep 2020 01:15:25 -0700 (PDT)
Date: Thu, 24 Sep 2020 01:15:24 -0700
From: Kees Cook <keescook@chromium.org>
To: YiFei Zhu <zhuyifei1999@gmail.com>
Subject: Re: [PATCH 3/6] seccomp: Implement constant action bitmaps
Message-ID: <202009240112.C48EF38EC2@keescook>
References: <20200923232923.3142503-1-keescook@chromium.org>
 <20200923232923.3142503-4-keescook@chromium.org>
 <CAG48ez0d80fOSTyn5QbH33WPz5UkzJJOo+V8of7YMR8pVQxumw@mail.gmail.com>
 <202009240018.A4D8274F@keescook>
 <CABqSeARV4prXOWf9qOBnm5Mm_aAdjwquqFFLQSuL0EegqeWEkA@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CABqSeARV4prXOWf9qOBnm5Mm_aAdjwquqFFLQSuL0EegqeWEkA@mail.gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>, Will Drewry <wad@chromium.org>,
 Jann Horn <jannh@google.com>, YiFei Zhu <yifeifz2@illinois.edu>,
 Linux API <linux-api@vger.kernel.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>,
 Andy Lutomirski <luto@amacapital.net>, Valentin Rothberg <vrothber@redhat.com>,
 Hubertus Franke <frankeh@us.ibm.com>, Jack Chen <jianyan2@illinois.edu>,
 Josep Torrellas <torrella@illinois.edu>, bpf <bpf@vger.kernel.org>,
 Tianyin Xu <tyxu@illinois.edu>, kernel list <linux-kernel@vger.kernel.org>
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

On Thu, Sep 24, 2020 at 03:07:23AM -0500, YiFei Zhu wrote:
> On Thu, Sep 24, 2020 at 2:37 AM Kees Cook <keescook@chromium.org> wrote:
> > >
> > > This belongs over into patch 1.
> >
> > Thanks! I was rushing to get this posted so YiFei Zhu wouldn't spend
> > time fighting with arch and Kconfig stuff. :) I'll clean this (and the
> > other random cruft) up.
> 
> Wait, what? I'm sorry. We have already begun fixing the mentioned
> issues (mostly the split bitmaps for different arches). Although yes
> it's nice to have another implementation to refer to so we get the
> best of both worlds (and yes I'm already copying some of the code I
> think are better here over there), don't you think it's not nice to
> say "Hey I've worked on this in June, it needed rework but I didn't
> send the newer version. Now you sent yours so I'll rush mine so your
> work is redundant."?

I was trying to be helpful: you hadn't seen the RFC, and it was missing
the emulator piece, which I wanted to be small, so I put got it out the
door today. I didn't want you to think you needed to port the larger
emulator over, for example.

> That said, I do think this should be configurable. Users would be free
> to experiment with the bitmap on or off, just like users may turn
> seccomp off entirely. A choice also allows users to select different
> implementations, a few whom I work with have ideas on how to
> accelerate / cache argument dependent syscalls, for example.

I'm open to ideas, but I want to have a non-optional performance
improvement as the first step. :) "seccomp is magically faster" was my
driving goal.

-- 
Kees Cook
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
