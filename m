Return-Path: <SRS0=lkaS=DB=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8D8DC4346E
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 07:46:46 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 3CB55206B2
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 07:46:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="GdNsA/P0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3CB55206B2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id B5EAF869F5;
	Thu, 24 Sep 2020 07:46:45 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ladJG_Cicoit; Thu, 24 Sep 2020 07:46:44 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id B0B73869EB;
	Thu, 24 Sep 2020 07:46:44 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 9513BC0859;
	Thu, 24 Sep 2020 07:46:44 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id E8D01C0051
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 07:46:42 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id D08DA874A0
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 07:46:42 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id IaXkal3BBMEc
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 07:46:42 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pf1-f193.google.com (mail-pf1-f193.google.com
 [209.85.210.193])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 2E31687495
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 07:46:42 +0000 (UTC)
Received: by mail-pf1-f193.google.com with SMTP id x123so1377774pfc.7
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 00:46:42 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:in-reply-to;
 bh=pn8AkGMTGfdnWTJRca9J7bhZq32aHx0QMblFYoTDsz4=;
 b=GdNsA/P0p61OU5c03zIIUOXZv3MQ0nBBcfB3Hc9r0sEY0oXx591w0DRyGt7MjNUDFN
 VhTXCFtMPSzKYr/yxvOnJ7w4D4VOiPCHAj6p2KnhZp3U+tyTB5l9ahqgKrzkT19oYxJA
 +jl1MwnAxFEWmHLz7pOEouqNuDZDlIBIFbkB0=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:in-reply-to;
 bh=pn8AkGMTGfdnWTJRca9J7bhZq32aHx0QMblFYoTDsz4=;
 b=EZ0oStWanEV+rDdbcjvpEOCkGjSSTpvz3Gdv++DEd9lX9/ZhVYlPL8/GbqKoxGD94w
 0LDqTPtaXzmiuGxUvsyFhIyPLCgOHfIL9apEoD6H7aBka/JRUfe6vGKJjDOV3IlRv/qg
 upAmYqzlQbVt/GgiojEUSV7rL0BM8IZ3N33qXd0RUJZmMxC9qhU540NiU2VXaCAACTE6
 +YDurTBJh6bgVxOjt1D0YqQ+gONbdGMzONwSECtVmmhj9HPJ6+rowklPLKDW5ZKguxLM
 NmwriziWhQIIZD/vnBeEVyOPP13olvNK6pGxHgwIWAEBbowuBrUHCJi2fziTbw6x7b/i
 JmRQ==
X-Gm-Message-State: AOAM531O0zFKUCxbNlzDQdrj/H2Xnqq3Z0Im+mx0iOdkEIK6Op98ireA
 O687JOMyOX+5yOvfhkTVO1wULg==
X-Google-Smtp-Source: ABdhPJxpv5eo0PCR5lxqSFEPXJ04YWDS30xuJeZwg37nkM2ihTg/HjMMDvdx6OdSaODt3kicQemxsw==
X-Received: by 2002:aa7:8dc7:0:b029:151:2237:52c5 with SMTP id
 j7-20020aa78dc70000b0290151223752c5mr3014124pfr.32.1600933601671; 
 Thu, 24 Sep 2020 00:46:41 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id b20sm1969377pfb.198.2020.09.24.00.46.40
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Thu, 24 Sep 2020 00:46:40 -0700 (PDT)
Date: Thu, 24 Sep 2020 00:46:39 -0700
From: Kees Cook <keescook@chromium.org>
To: Jann Horn <jannh@google.com>
Subject: Re: [PATCH 4/6] seccomp: Emulate basic filters for constant action
 results
Message-ID: <202009240038.864365E@keescook>
References: <20200923232923.3142503-1-keescook@chromium.org>
 <20200923232923.3142503-5-keescook@chromium.org>
 <CAG48ez251v19U60GYH4aWE6+C-3PYw5mr_Ax_kxnebqDOBn_+Q@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CAG48ez251v19U60GYH4aWE6+C-3PYw5mr_Ax_kxnebqDOBn_+Q@mail.gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>, Will Drewry <wad@chromium.org>,
 Paul Moore <paul@paul-moore.com>, YiFei Zhu <yifeifz2@illinois.edu>,
 Linux API <linux-api@vger.kernel.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 bpf <bpf@vger.kernel.org>, Tobin Feldman-Fitzthum <tobin@ibm.com>,
 Hubertus Franke <frankeh@us.ibm.com>, Andy Lutomirski <luto@amacapital.net>,
 Valentin Rothberg <vrothber@redhat.com>,
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

On Thu, Sep 24, 2020 at 01:47:47AM +0200, Jann Horn wrote:
> On Thu, Sep 24, 2020 at 1:29 AM Kees Cook <keescook@chromium.org> wrote:
> > This emulates absolutely the most basic seccomp filters to figure out
> > if they will always give the same results for a given arch/nr combo.
> >
> > Nearly all seccomp filters are built from the following ops:
> >
> > BPF_LD  | BPF_W    | BPF_ABS
> > BPF_JMP | BPF_JEQ  | BPF_K
> > BPF_JMP | BPF_JGE  | BPF_K
> > BPF_JMP | BPF_JGT  | BPF_K
> > BPF_JMP | BPF_JSET | BPF_K
> > BPF_JMP | BPF_JA
> > BPF_RET | BPF_K
> >
> > These are now emulated to check for accesses beyond seccomp_data::arch
> > or unknown instructions.
> >
> > Not yet implemented are:
> >
> > BPF_ALU | BPF_AND (generated by libseccomp and Chrome)
> 
> BPF_AND is normally only used on syscall arguments, not on the syscall
> number or the architecture, right? And when a syscall argument is
> loaded, we abort execution anyway. So I think there is no need to
> implement those?

Is that right? I can't actually tell what libseccomp is doing with
ALU|AND. It looks like it's using it for building jump lists?

Paul, Tom, under what cases does libseccomp emit ALU|AND into filters?

> > Suggested-by: Jann Horn <jannh@google.com>
> > Link: https://lore.kernel.org/lkml/CAG48ez1p=dR_2ikKq=xVxkoGg0fYpTBpkhJSv1w-6BG=76PAvw@mail.gmail.com/
> > Signed-off-by: Kees Cook <keescook@chromium.org>
> > ---
> >  kernel/seccomp.c  | 82 ++++++++++++++++++++++++++++++++++++++++++++---
> >  net/core/filter.c |  3 +-
> >  2 files changed, 79 insertions(+), 6 deletions(-)
> >
> > diff --git a/kernel/seccomp.c b/kernel/seccomp.c
> > index 111a238bc532..9921f6f39d12 100644
> > --- a/kernel/seccomp.c
> > +++ b/kernel/seccomp.c
> > @@ -610,7 +610,12 @@ static struct seccomp_filter *seccomp_prepare_filter(struct sock_fprog *fprog)
> >  {
> >         struct seccomp_filter *sfilter;
> >         int ret;
> > -       const bool save_orig = IS_ENABLED(CONFIG_CHECKPOINT_RESTORE);
> > +       const bool save_orig =
> > +#if defined(CONFIG_CHECKPOINT_RESTORE) || defined(SECCOMP_ARCH)
> > +               true;
> > +#else
> > +               false;
> > +#endif
> 
> You could probably write this as something like:
> 
> const bool save_orig = IS_ENABLED(CONFIG_CHECKPOINT_RESTORE) ||
> __is_defined(SECCOMP_ARCH);

Ah! Thank you. I went looking for __is_defined() and failed. :)

> 
> [...]
> > diff --git a/net/core/filter.c b/net/core/filter.c
> [...]
> > -static void bpf_release_orig_filter(struct bpf_prog *fp)
> > +void bpf_release_orig_filter(struct bpf_prog *fp)
> >  {
> >         struct sock_fprog_kern *fprog = fp->orig_prog;
> >
> > @@ -1154,6 +1154,7 @@ static void bpf_release_orig_filter(struct bpf_prog *fp)
> >                 kfree(fprog);
> >         }
> >  }
> > +EXPORT_SYMBOL_GPL(bpf_release_orig_filter);
> 
> If this change really belongs into this patch (which I don't think it
> does), please describe why in the commit message.

Yup, more cruft I failed to remove.

-- 
Kees Cook
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
