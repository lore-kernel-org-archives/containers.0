Return-Path: <SRS0=lkaS=DB=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 991ACC4346E
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 07:37:06 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id F413623741
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 07:37:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="G+UWjHqR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F413623741
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 4222F2E0E9;
	Thu, 24 Sep 2020 07:37:04 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 3wGgxO6oJYi4; Thu, 24 Sep 2020 07:37:01 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 4FAB52E0DE;
	Thu, 24 Sep 2020 07:37:01 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 37F81C0859;
	Thu, 24 Sep 2020 07:37:01 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id F2C92C0051
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 07:36:59 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id DAA82869D2
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 07:36:59 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id wTdoOM__Dgbv
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 07:36:59 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pf1-f196.google.com (mail-pf1-f196.google.com
 [209.85.210.196])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 0695E869C0
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 07:36:59 +0000 (UTC)
Received: by mail-pf1-f196.google.com with SMTP id o20so1350208pfp.11
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 00:36:59 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:in-reply-to;
 bh=WLJqIscJmXcvk+sqZWhshYhF2CZRRuw+A8ZGwocEwRQ=;
 b=G+UWjHqRmZtL7aOwJRe0U89n54w3ZzxUfJM96kgA17jcRmleJkjoPM8xG/IgtKX+ka
 Ru6WiurvmQ7B/2qcOKO6h91E7rZHfAvvKXRQSk6IwPOMzwJAsA6GS4xx79fuZEIZsMMa
 O32mwaxtv3Spvme5j6mLBMKNpV4AWuTd4s9VA=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:in-reply-to;
 bh=WLJqIscJmXcvk+sqZWhshYhF2CZRRuw+A8ZGwocEwRQ=;
 b=TPajkCdUE1EN486AfKLmRzS+gB4lazIzIU0cvLXqGAT0epUQKKezZhhbM+MLCQWwHm
 YM6OUN5BFEhZKV6H0iPlF5mYv/lknGyspikO1MvD33z9NyoeE8rbHAdRM19/sXMbomq9
 kN9p1OYRqj/0FNBB+ua9NU7fefyE2r+9RVnf+YsAKTmcyJSsAudeQUvBpJhoo4GNbyYk
 Vp4hbBX5JgjFQ7Nlai0Tv4d+KS7fgFuMk4FsBSIjqE0TZkKcLVy9TS2rpuffU8KzQGd3
 xsjhrtuWC9YrT6dbZnwE/5KxCktm5omvd3IWi9OQTokbPWXICV/exIl6lxSPDa0uc1ZF
 7/EQ==
X-Gm-Message-State: AOAM5330WxFESU0RaO0tNRq4Ud1htcGNmxAlFme8x08g/hgHOmHz5rJz
 Fg5z5OClbVsSfqYwL9kyxjBNEQ==
X-Google-Smtp-Source: ABdhPJwOSKne6H8RnHQDk/kqxXJPImal+FWVDntmH5GURex1vAcAC3rXIH/UTAWQhS5owGkqenlz7w==
X-Received: by 2002:a63:5d08:: with SMTP id r8mr2852677pgb.174.1600933018492; 
 Thu, 24 Sep 2020 00:36:58 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id a27sm1817356pfk.52.2020.09.24.00.36.57
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Thu, 24 Sep 2020 00:36:57 -0700 (PDT)
Date: Thu, 24 Sep 2020 00:36:56 -0700
From: Kees Cook <keescook@chromium.org>
To: Jann Horn <jannh@google.com>
Subject: Re: [PATCH 3/6] seccomp: Implement constant action bitmaps
Message-ID: <202009240018.A4D8274F@keescook>
References: <20200923232923.3142503-1-keescook@chromium.org>
 <20200923232923.3142503-4-keescook@chromium.org>
 <CAG48ez0d80fOSTyn5QbH33WPz5UkzJJOo+V8of7YMR8pVQxumw@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CAG48ez0d80fOSTyn5QbH33WPz5UkzJJOo+V8of7YMR8pVQxumw@mail.gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>, Will Drewry <wad@chromium.org>,
 bpf <bpf@vger.kernel.org>, YiFei Zhu <yifeifz2@illinois.edu>,
 Linux API <linux-api@vger.kernel.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>, Hubertus Franke <frankeh@us.ibm.com>,
 Andy Lutomirski <luto@amacapital.net>, Valentin Rothberg <vrothber@redhat.com>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>, Jack Chen <jianyan2@illinois.edu>,
 Josep Torrellas <torrella@illinois.edu>, Tianyin Xu <tyxu@illinois.edu>,
 kernel list <linux-kernel@vger.kernel.org>
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

On Thu, Sep 24, 2020 at 02:25:03AM +0200, Jann Horn wrote:
> On Thu, Sep 24, 2020 at 1:29 AM Kees Cook <keescook@chromium.org> wrote:
> > +/* When no bits are set for a syscall, filters are run. */
> > +struct seccomp_bitmaps {
> > +#ifdef SECCOMP_ARCH
> > +       /* "allow" are initialized to set and only ever get cleared. */
> > +       DECLARE_BITMAP(allow, NR_syscalls);
> 
> This bitmap makes sense.
> 
> > +       /* These are initialized to clear and only ever get set. */
> > +       DECLARE_BITMAP(kill_thread, NR_syscalls);
> > +       DECLARE_BITMAP(kill_process, NR_syscalls);
> 
> I don't think these bitmaps make sense, this is not part of any fastpath.

That's a fair point. I think I arrived at this design because it ended
up making filter addition faster ("don't bother processing this one,
it's already 'kill'"), but it's likely not worse the memory usage
trade-off.

> (However, a "which syscalls have a fixed result" bitmap might make
> sense if we want to export the list of permitted syscalls as a text
> file in procfs, as I mentioned over at
> <https://lore.kernel.org/lkml/CAG48ez3Ofqp4crXGksLmZY6=fGrF_tWyUCg7PBkAetvbbOPeOA@mail.gmail.com/>.)

I haven't found a data structure I'm happy with for this. It seemed like
NR_syscalls * sizeof(u32) was rather a lot (i.e. to store the BPF_RET
value). However, let me discuss that more in the "why in in thread?"
below...

> The "NR_syscalls" part assumes that the compat syscall tables will not
> be bigger than the native syscall table, right? I guess that's usually
> mostly true nowadays, thanks to the syscall table unification...
> (might be worth a comment though)

Hrm, I had convinced myself it was a max() of compat. But I see no
evidence of that now. Which means that I can add these to the per-arch
seccomp defines with something like:

# define SECCOMP_NR_NATIVE	NR_syscalls
# define SECCOMP_NR_COMPAT	X32_NR_syscalls
...

> > +#endif
> > +};
> > +
> >  struct seccomp_filter;
> >  /**
> >   * struct seccomp - the state of a seccomp'ed process
> > @@ -45,6 +56,13 @@ struct seccomp {
> >  #endif
> >         atomic_t filter_count;
> >         struct seccomp_filter *filter;
> > +       struct seccomp_bitmaps native;
> > +#ifdef CONFIG_COMPAT
> > +       struct seccomp_bitmaps compat;
> > +#endif
> > +#ifdef SECCOMP_MULTIPLEXED_SYSCALL_TABLE_ARCH
> > +       struct seccomp_bitmaps multiplex;
> > +#endif
> 
> Why do we have one bitmap per thread (in struct seccomp) instead of
> putting the bitmap for a given filter and all its ancestors into the
> seccomp_filter?

I explicitly didn't want to add code that was run per-filter; I wanted
O(1), not O(n) even if the n work was a small constant. There is
obviously a memory/perf tradeoff here. I wonder if the middle ground
would be to put a bitmap and "constant action" results in the filter....
oh duh. The "top" filter is already going to be composed with its
ancestors. That's all that needs to be checked. Then the tri-state can
be:

bitmap accept[NR_syscalls]: accept or check "known" bitmap
bitmap filter[NR_syscalls]: run filter or return known action
u32 known_action[NR_syscalls];

(times syscall numbering "architecture" counts)

Though perhaps it would be just as fast as:

bitmap run_filter[NR_syscalls]: run filter or return known_action
u32 known_action[NR_syscalls];

where accept isn't treated special...

> 
> >  };
> >
> >  #ifdef CONFIG_HAVE_ARCH_SECCOMP_FILTER
> > diff --git a/kernel/seccomp.c b/kernel/seccomp.c
> > index 0a3ff8eb8aea..111a238bc532 100644
> > --- a/kernel/seccomp.c
> > +++ b/kernel/seccomp.c
> > @@ -318,7 +318,7 @@ static inline u8 seccomp_get_arch(u32 syscall_arch, u32 syscall_nr)
> >
> >  #ifdef SECCOMP_MULTIPLEXED_SYSCALL_TABLE_ARCH
> >         if (syscall_arch == SECCOMP_MULTIPLEXED_SYSCALL_TABLE_ARCH) {
> > -               seccomp_arch |= (sd->nr & SECCOMP_MULTIPLEXED_SYSCALL_TABLE_MASK) >>
> > +               seccomp_arch |= (syscall_nr & SECCOMP_MULTIPLEXED_SYSCALL_TABLE_MASK) >>
> >                                 SECCOMP_MULTIPLEXED_SYSCALL_TABLE_SHIFT;
> 
> This belongs over into patch 1.

Thanks! I was rushing to get this posted so YiFei Zhu wouldn't spend
time fighting with arch and Kconfig stuff. :) I'll clean this (and the
other random cruft) up.

-- 
Kees Cook
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
