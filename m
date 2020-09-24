Return-Path: <SRS0=lkaS=DB=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6CCF5C4363D
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 19:52:14 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id BD0A32220C
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 19:52:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="U97pSE2E"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BD0A32220C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 5AAEE87466;
	Thu, 24 Sep 2020 19:52:13 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id jF5auZsJ-8EH; Thu, 24 Sep 2020 19:52:12 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id A61D087445;
	Thu, 24 Sep 2020 19:52:12 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 7D46FC0859;
	Thu, 24 Sep 2020 19:52:12 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id E49D2C0051
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 19:52:11 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id C8B3B86AAB
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 19:52:11 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id Yl2tAByT2-20
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 19:52:11 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pf1-f195.google.com (mail-pf1-f195.google.com
 [209.85.210.195])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 2E29E86A99
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 19:52:11 +0000 (UTC)
Received: by mail-pf1-f195.google.com with SMTP id w7so460259pfi.4
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 12:52:11 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:in-reply-to;
 bh=k70Xue22GFlB0rY9wGgnFf8SK2vwmBPDgshtczHYd+4=;
 b=U97pSE2E3cWH2OMa2/1j1GXuJM9azr9TZPGI6w4DyW57tj+j9Ltmd/pid9zUZwnBNi
 v1Nj4NptXZH5IE/5pxa9rv2NDAvYXrXKU7qOVssXD0Xio+R+4dq8ZzTUZn5qwdmrkUA9
 t4M6wZmpJXLoyG+/Q2rEe/S1dt04TRaQ99LTA=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:in-reply-to;
 bh=k70Xue22GFlB0rY9wGgnFf8SK2vwmBPDgshtczHYd+4=;
 b=aaVowBgRnFAwxS8Xg2IyfU/ODsfqHXZfRRVPQzwFbdaFQuVUDa8mvQdWxZ1TWIOcAb
 daEeSLL1Es6XCZNV4rRuhY1F4FDTfl2vYHjIPkyPcoowbw0/RqHmuGTVZZmjD7xb3GVI
 Ab/V5Ehlj2kSpkzu0zJNAf9Vp/vvGKK62IMPBa98Y3kAhelSVPI1s/URu0rneyEz/Tof
 gBTJL5fFX2HrTPK3crt5vxGcvvmB84h3lJ370C2NpH6bm2uZb7EDN8ZKLpEmUfFEl9Qi
 O2KtkHAxTHFCHVHKCs7k//p00ktaMddRT51NszkpU0hRLvD3awfCX9DbsAn5pQtJ6DUM
 gGYQ==
X-Gm-Message-State: AOAM530oTUEjF1to58uOMB/MvhLbpqGRekUrX+S+X+HCy71PYEssy5xw
 sXhDMG5h5hNkMN2EnQRXcu90RA==
X-Google-Smtp-Source: ABdhPJzpsUJFf8IHAHpxoWh4JONrQ/df6mHI3aKnLsuTt2XZEKCv+YjNg5jbY6Sd/88urNoAFy6ZIg==
X-Received: by 2002:a63:42:: with SMTP id 63mr553646pga.419.1600977130625;
 Thu, 24 Sep 2020 12:52:10 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id g9sm295305pfo.144.2020.09.24.12.52.09
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Thu, 24 Sep 2020 12:52:09 -0700 (PDT)
Date: Thu, 24 Sep 2020 12:52:08 -0700
From: Kees Cook <keescook@chromium.org>
To: Paul Moore <paul@paul-moore.com>
Subject: Re: [PATCH 4/6] seccomp: Emulate basic filters for constant action
 results
Message-ID: <202009241251.F719CC4@keescook>
References: <20200923232923.3142503-1-keescook@chromium.org>
 <20200923232923.3142503-5-keescook@chromium.org>
 <CAG48ez251v19U60GYH4aWE6+C-3PYw5mr_Ax_kxnebqDOBn_+Q@mail.gmail.com>
 <202009240038.864365E@keescook>
 <CAHC9VhQpto1KuL7PhjtdjtAjJ2nC+rZNSM7+nSZ_ksqGXbhY+Q@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CAHC9VhQpto1KuL7PhjtdjtAjJ2nC+rZNSM7+nSZ_ksqGXbhY+Q@mail.gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>, Will Drewry <wad@chromium.org>,
 Jann Horn <jannh@google.com>, YiFei Zhu <yifeifz2@illinois.edu>,
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

On Thu, Sep 24, 2020 at 11:28:55AM -0400, Paul Moore wrote:
> On Thu, Sep 24, 2020 at 3:46 AM Kees Cook <keescook@chromium.org> wrote:
> > On Thu, Sep 24, 2020 at 01:47:47AM +0200, Jann Horn wrote:
> > > On Thu, Sep 24, 2020 at 1:29 AM Kees Cook <keescook@chromium.org> wrote:
> > > > This emulates absolutely the most basic seccomp filters to figure out
> > > > if they will always give the same results for a given arch/nr combo.
> > > >
> > > > Nearly all seccomp filters are built from the following ops:
> > > >
> > > > BPF_LD  | BPF_W    | BPF_ABS
> > > > BPF_JMP | BPF_JEQ  | BPF_K
> > > > BPF_JMP | BPF_JGE  | BPF_K
> > > > BPF_JMP | BPF_JGT  | BPF_K
> > > > BPF_JMP | BPF_JSET | BPF_K
> > > > BPF_JMP | BPF_JA
> > > > BPF_RET | BPF_K
> > > >
> > > > These are now emulated to check for accesses beyond seccomp_data::arch
> > > > or unknown instructions.
> > > >
> > > > Not yet implemented are:
> > > >
> > > > BPF_ALU | BPF_AND (generated by libseccomp and Chrome)
> > >
> > > BPF_AND is normally only used on syscall arguments, not on the syscall
> > > number or the architecture, right? And when a syscall argument is
> > > loaded, we abort execution anyway. So I think there is no need to
> > > implement those?
> >
> > Is that right? I can't actually tell what libseccomp is doing with
> > ALU|AND. It looks like it's using it for building jump lists?
> 
> There is an ALU|AND op in the jump resolution code, but that is really
> just if libseccomp needs to fixup the accumulator because a code block
> is expecting a masked value (right now that would only be a syscall
> argument, not the syscall number itself).
> 
> > Paul, Tom, under what cases does libseccomp emit ALU|AND into filters?
> 
> Presently the only place where libseccomp uses ALU|AND is when the
> masked equality comparison is used for comparing syscall arguments
> (SCMP_CMP_MASKED_EQ).  I can't honestly say I have any good
> information about how often that is used by libseccomp callers, but if
> I do a quick search on GitHub for "SCMP_CMP_MASKED_EQ" I see 2k worth
> of code hits; take that for whatever it is worth.  Tom may have some
> more/better information.
> 
> Of course no promises on future use :)  As one quick example, I keep
> thinking about adding the instruction pointer to the list of things
> that can be compared as part of a libseccomp rule, and if we do that I
> would expect that we would want to also allow a masked comparison (and
> utilize another ALU|AND bpf op there).  However, I'm not sure how
> useful that would be in practice.

Okay, cool. Thanks for checking on that. It sounds like the arg-less
bitmap optimization can continue to ignore ALU|AND for now. :)

-- 
Kees Cook
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
