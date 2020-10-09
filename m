Return-Path: <SRS0=NhOQ=DQ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 46DE6C433DF
	for <containers@archiver.kernel.org>; Fri,  9 Oct 2020 22:47:16 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id C1A2B222C3
	for <containers@archiver.kernel.org>; Fri,  9 Oct 2020 22:47:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="nFnOOMc8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C1A2B222C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 64A112E2F1;
	Fri,  9 Oct 2020 22:47:15 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 6qmHDtENVyIu; Fri,  9 Oct 2020 22:47:13 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id A751C20437;
	Fri,  9 Oct 2020 22:47:13 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 8D964C016F;
	Fri,  9 Oct 2020 22:47:13 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 408ECC0051
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 22:47:12 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 335B187893
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 22:47:12 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id su8qKgFIUUwP
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 22:47:09 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pg1-f194.google.com (mail-pg1-f194.google.com
 [209.85.215.194])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 5E3FB8788D
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 22:47:09 +0000 (UTC)
Received: by mail-pg1-f194.google.com with SMTP id 7so8396498pgm.11
 for <containers@lists.linux-foundation.org>;
 Fri, 09 Oct 2020 15:47:09 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:in-reply-to;
 bh=tY2ViAT8BuOfi5xuMFyOWzlw2bSYg16jBN39DY5VAdQ=;
 b=nFnOOMc8hwTlNtEo9+8Ej+MSHepQT8JXKR5+tljjPBINdllBge3d5tGOIDJSNx+Wkv
 GapnYtqRtJDA/6J+Yg3OlY0A/eo58LHl9EgDXJRaKOt6UVva3ErneneIJdZ6wcZYGRRP
 uQ9FxJut9HVsX/++OQYjAZO0lvCIBrRZ5MbVU=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:in-reply-to;
 bh=tY2ViAT8BuOfi5xuMFyOWzlw2bSYg16jBN39DY5VAdQ=;
 b=cPpE99LrHAPOw6uCxsw6y5fclPto9fQ4rzZXxcj7ZGijVwThm9QRE439/EH4hkRAu2
 zo7mv+yqL904aBQO23OU4+D6ukBE+3qo+/qx7NXpOd+wq+J3On7OoRqopxizwcfR44DC
 7rtximBxpgLnVWiJi6olIEUAHcKB+hcMPrqeBKBCbVZZznjMtSUlqrCu6lRgGVtlKZmV
 ZWxlNbV+T3okrdLBwJDIXS8jKOjWwmQp8iA+RjfRFWuRE603CkqXGwQNbTFaxb+hpsAQ
 oB2bcLsicWBMoZauf78b4teRiGRt3OkPn3JHlt220MaSt2mcSvnry15KLUQjlXot1yvG
 tNPQ==
X-Gm-Message-State: AOAM531Kg+Dht2hhBHNI5QCFhEr/C6QXSOTyMW9jeUcwAGDtUDTQL4+j
 dY5BDTYZBdIuSDFliZXQObh/Qw==
X-Google-Smtp-Source: ABdhPJwAXDU4kg0UyHq4hK2boy1nf0c4Lda0H7tYA5hp6IkpV8e/cuSuVtsBtaeJHCGeHNagW8o3DA==
X-Received: by 2002:a17:90a:c087:: with SMTP id
 o7mr6916984pjs.155.1602283628884; 
 Fri, 09 Oct 2020 15:47:08 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id i24sm11570377pfd.15.2020.10.09.15.47.07
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Fri, 09 Oct 2020 15:47:08 -0700 (PDT)
Date: Fri, 9 Oct 2020 15:47:07 -0700
From: Kees Cook <keescook@chromium.org>
To: Jann Horn <jannh@google.com>
Subject: Re: [PATCH v4 seccomp 2/5] seccomp/cache: Add "emulator" to check if
 filter is constant allow
Message-ID: <202010091545.962A2F5@keescook>
References: <cover.1602263422.git.yifeifz2@illinois.edu>
 <1a40458d081ce0d5423eb0282210055496e28774.1602263422.git.yifeifz2@illinois.edu>
 <CAG48ez1eUfjNPVKeYbk28On9WOaDBysR-=7sYDM-Q=nCzwXcDA@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CAG48ez1eUfjNPVKeYbk28On9WOaDBysR-=7sYDM-Q=nCzwXcDA@mail.gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, YiFei Zhu <yifeifz2@illinois.edu>,
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
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

On Fri, Oct 09, 2020 at 11:30:18PM +0200, Jann Horn wrote:
> On Fri, Oct 9, 2020 at 7:15 PM YiFei Zhu <zhuyifei1999@gmail.com> wrote:
> >
> > From: YiFei Zhu <yifeifz2@illinois.edu>
> >
> > SECCOMP_CACHE will only operate on syscalls that do not access
> > any syscall arguments or instruction pointer. To facilitate
> > this we need a static analyser to know whether a filter will
> > return allow regardless of syscall arguments for a given
> > architecture number / syscall number pair. This is implemented
> > here with a pseudo-emulator, and stored in a per-filter bitmap.
> >
> > In order to build this bitmap at filter attach time, each filter is
> > emulated for every syscall (under each possible architecture), and
> > checked for any accesses of struct seccomp_data that are not the "arch"
> > nor "nr" (syscall) members. If only "arch" and "nr" are examined, and
> > the program returns allow, then we can be sure that the filter must
> > return allow independent from syscall arguments.
> >
> > Nearly all seccomp filters are built from these cBPF instructions:
> >
> > BPF_LD  | BPF_W    | BPF_ABS
> > BPF_JMP | BPF_JEQ  | BPF_K
> > BPF_JMP | BPF_JGE  | BPF_K
> > BPF_JMP | BPF_JGT  | BPF_K
> > BPF_JMP | BPF_JSET | BPF_K
> > BPF_JMP | BPF_JA
> > BPF_RET | BPF_K
> > BPF_ALU | BPF_AND  | BPF_K
> >
> > Each of these instructions are emulated. Any weirdness or loading
> > from a syscall argument will cause the emulator to bail.
> >
> > The emulation is also halted if it reaches a return. In that case,
> > if it returns an SECCOMP_RET_ALLOW, the syscall is marked as good.
> >
> > Emulator structure and comments are from Kees [1] and Jann [2].
> >
> > Emulation is done at attach time. If a filter depends on more
> > filters, and if the dependee does not guarantee to allow the
> > syscall, then we skip the emulation of this syscall.
> >
> > [1] https://lore.kernel.org/lkml/20200923232923.3142503-5-keescook@chromium.org/
> > [2] https://lore.kernel.org/lkml/CAG48ez1p=dR_2ikKq=xVxkoGg0fYpTBpkhJSv1w-6BG=76PAvw@mail.gmail.com/
> [...]
> > @@ -682,6 +693,150 @@ seccomp_prepare_user_filter(const char __user *user_filter)
> >         return filter;
> >  }
> >
> > +#ifdef SECCOMP_ARCH_NATIVE
> > +/**
> > + * seccomp_is_const_allow - check if filter is constant allow with given data
> > + * @fprog: The BPF programs
> > + * @sd: The seccomp data to check against, only syscall number are arch
> > + *      number are considered constant.
> 
> nit: s/syscall number are arch number/syscall number and arch number/
> 
> > + */
> > +static bool seccomp_is_const_allow(struct sock_fprog_kern *fprog,
> > +                                  struct seccomp_data *sd)
> > +{
> > +       unsigned int insns;
> > +       unsigned int reg_value = 0;
> > +       unsigned int pc;
> > +       bool op_res;
> > +
> > +       if (WARN_ON_ONCE(!fprog))
> > +               return false;
> > +
> > +       insns = bpf_classic_proglen(fprog);
> 
> bpf_classic_proglen() is defined as:
> 
> #define bpf_classic_proglen(fprog) (fprog->len * sizeof(fprog->filter[0]))
> 
> so this is wrong - what you want is the number of instructions in the
> program, what you actually have is the size of the program in bytes.
> Please instead check for `pc < fprog->len` in the loop condition.

Oh yes, good catch. I had this wrong in my v1.

-- 
Kees Cook
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
