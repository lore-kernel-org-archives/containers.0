Return-Path: <SRS0=lkaS=DB=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C233CC4727D
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 15:29:12 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id CA6E121D91
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 15:29:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=paul-moore-com.20150623.gappssmtp.com header.i=@paul-moore-com.20150623.gappssmtp.com header.b="hN3JCT4/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA6E121D91
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=paul-moore.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 693A786920;
	Thu, 24 Sep 2020 15:29:11 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id vhBcv_xGwnnQ; Thu, 24 Sep 2020 15:29:10 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id DCF97868E8;
	Thu, 24 Sep 2020 15:29:10 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id C1436C0890;
	Thu, 24 Sep 2020 15:29:10 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 6D62FC0859
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 15:29:09 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 68E7C868FB
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 15:29:09 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id bmyZVO1TfkB9
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 15:29:08 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from mail-ed1-f65.google.com (mail-ed1-f65.google.com
 [209.85.208.65])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 1B168868E8
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 15:29:08 +0000 (UTC)
Received: by mail-ed1-f65.google.com with SMTP id b12so3747883edz.11
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 08:29:07 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=paul-moore-com.20150623.gappssmtp.com; s=20150623;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=DWwrSFR+XsVbo72EXCPGN7Yvsrb6I0oZs+oVxjkh+2I=;
 b=hN3JCT4/0mr9lHn1el6A+W9IHJhVcZfLNiBn+2+2ptYhZ2E3ln93PIdOTyrZm4MsWg
 0pPA5aEFZnOI3KgY8otAO4fYpSdYshKnZ4CmKXSbw5JqMttXF9UPXapl5M86DohboovX
 I3ro4WAml5gPUcfGG3zbCTYxhnoAJoBotyNRCrSyqpZDz/gaQeuJnjABGulXeW+vgul2
 WfLGjGxh/urIx8OZzhTSMu8/a21/AzyXO11afB8SfNqZpdfRIv+08n215LLwBniNZZEh
 jK3alXiJ//9LzmOTJndQYIOo7J2mNf+tk68S7tAY55J1Ph4eY4IoKrvEDEnzodg3nw3v
 1Idg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=DWwrSFR+XsVbo72EXCPGN7Yvsrb6I0oZs+oVxjkh+2I=;
 b=JJreUQpDEI8XQgIWc2HnLAatX3k2X+hmTtvpriXJs6FqW4ys6gl0B2p+FQbs4aBEV1
 NTW+E998T7HQZjC9O0Lcbpz3UDSfTVOqJertPK9/YARUnVowf7ZvONGdWzV/DeZUQxTO
 L2UXCjSRhrp9gaF2KZvS5FYpJbL3uxSNb0duEqfQ957yyfNnBCoreknZ+USbRTkx/Woe
 yB76+l/hTgxbalvvEUv9bKXDUNNil7AcpXxywHm3cb6BQtY3n12lF1Shser4bj0ccpo6
 Xn8Y9hZo7jxbdmcLF7UjgtGYJKzms6UKK95kRZ34B6vTYENWa1tPhmdQtmtkpedZ7Hq+
 ExyQ==
X-Gm-Message-State: AOAM531eGL+lQH/PHWsL/N+uXTOPR/RkwyyC1YtMldjO+pKQE6Tn4A3Y
 X4lTX66qStS6sKbIxCEjHitMq3isGmjQtlKH6lzL
X-Google-Smtp-Source: ABdhPJxwnRvlu4GIjD+pyeEz7LhCUZQ/skYgUffP4gTtRClyXesIuk5Q/rFSvs+tgZ6Sn7QvuUd3X5CwxfSMAX6NAl0=
X-Received: by 2002:aa7:ce97:: with SMTP id y23mr494977edv.128.1600961346147; 
 Thu, 24 Sep 2020 08:29:06 -0700 (PDT)
MIME-Version: 1.0
References: <20200923232923.3142503-1-keescook@chromium.org>
 <20200923232923.3142503-5-keescook@chromium.org>
 <CAG48ez251v19U60GYH4aWE6+C-3PYw5mr_Ax_kxnebqDOBn_+Q@mail.gmail.com>
 <202009240038.864365E@keescook>
In-Reply-To: <202009240038.864365E@keescook>
From: Paul Moore <paul@paul-moore.com>
Date: Thu, 24 Sep 2020 11:28:55 -0400
Message-ID: <CAHC9VhQpto1KuL7PhjtdjtAjJ2nC+rZNSM7+nSZ_ksqGXbhY+Q@mail.gmail.com>
Subject: Re: [PATCH 4/6] seccomp: Emulate basic filters for constant action
 results
To: Kees Cook <keescook@chromium.org>, Tom Hromatka <tom.hromatka@oracle.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>, Will Drewry <wad@chromium.org>,
 bpf <bpf@vger.kernel.org>, Jann Horn <jannh@google.com>,
 YiFei Zhu <yifeifz2@illinois.edu>, Linux API <linux-api@vger.kernel.org>,
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

On Thu, Sep 24, 2020 at 3:46 AM Kees Cook <keescook@chromium.org> wrote:
> On Thu, Sep 24, 2020 at 01:47:47AM +0200, Jann Horn wrote:
> > On Thu, Sep 24, 2020 at 1:29 AM Kees Cook <keescook@chromium.org> wrote:
> > > This emulates absolutely the most basic seccomp filters to figure out
> > > if they will always give the same results for a given arch/nr combo.
> > >
> > > Nearly all seccomp filters are built from the following ops:
> > >
> > > BPF_LD  | BPF_W    | BPF_ABS
> > > BPF_JMP | BPF_JEQ  | BPF_K
> > > BPF_JMP | BPF_JGE  | BPF_K
> > > BPF_JMP | BPF_JGT  | BPF_K
> > > BPF_JMP | BPF_JSET | BPF_K
> > > BPF_JMP | BPF_JA
> > > BPF_RET | BPF_K
> > >
> > > These are now emulated to check for accesses beyond seccomp_data::arch
> > > or unknown instructions.
> > >
> > > Not yet implemented are:
> > >
> > > BPF_ALU | BPF_AND (generated by libseccomp and Chrome)
> >
> > BPF_AND is normally only used on syscall arguments, not on the syscall
> > number or the architecture, right? And when a syscall argument is
> > loaded, we abort execution anyway. So I think there is no need to
> > implement those?
>
> Is that right? I can't actually tell what libseccomp is doing with
> ALU|AND. It looks like it's using it for building jump lists?

There is an ALU|AND op in the jump resolution code, but that is really
just if libseccomp needs to fixup the accumulator because a code block
is expecting a masked value (right now that would only be a syscall
argument, not the syscall number itself).

> Paul, Tom, under what cases does libseccomp emit ALU|AND into filters?

Presently the only place where libseccomp uses ALU|AND is when the
masked equality comparison is used for comparing syscall arguments
(SCMP_CMP_MASKED_EQ).  I can't honestly say I have any good
information about how often that is used by libseccomp callers, but if
I do a quick search on GitHub for "SCMP_CMP_MASKED_EQ" I see 2k worth
of code hits; take that for whatever it is worth.  Tom may have some
more/better information.

Of course no promises on future use :)  As one quick example, I keep
thinking about adding the instruction pointer to the list of things
that can be compared as part of a libseccomp rule, and if we do that I
would expect that we would want to also allow a masked comparison (and
utilize another ALU|AND bpf op there).  However, I'm not sure how
useful that would be in practice.

-- 
paul moore
www.paul-moore.com
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
