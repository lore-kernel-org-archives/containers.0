Return-Path: <SRS0=lkaS=DB=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E1EEC4363D
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 20:46:22 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id D3364221EB
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 20:46:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=paul-moore-com.20150623.gappssmtp.com header.i=@paul-moore-com.20150623.gappssmtp.com header.b="N/W4hr3E"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D3364221EB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=paul-moore.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 8AC28873B9;
	Thu, 24 Sep 2020 20:46:21 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Bn66yNDIQ9dx; Thu, 24 Sep 2020 20:46:20 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 7B61587398;
	Thu, 24 Sep 2020 20:46:20 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 6D47DC0890;
	Thu, 24 Sep 2020 20:46:20 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id C6512C0859
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 20:46:19 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id BA18786BCB
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 20:46:19 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id FMkG7TQTMGGR
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 20:46:18 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from mail-ed1-f66.google.com (mail-ed1-f66.google.com
 [209.85.208.66])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 7632986BC8
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 20:46:18 +0000 (UTC)
Received: by mail-ed1-f66.google.com with SMTP id k14so312025edo.1
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 13:46:18 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=paul-moore-com.20150623.gappssmtp.com; s=20150623;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=hNWgf5JR/cvx4+k2/k8//+NsLRafA9SikURsJTJxHl8=;
 b=N/W4hr3EM1UoBKdrsToiPIHVsXsZea5kjUdS8aVBO0VqX+vlNG+bO2voUqHrH92lkx
 v+cCb7BIpfE7J0COXu9ZveiX7hBiBESo1VPhidpBI1JkRyqPepo3jqNxoErSa7ggD7Bj
 MLUMxpjuK+mfC0nMTCX4DLvJzLTliYNOhloeeWBzNrArRN2m8nCyPvgHXMO/qRm9xIP9
 yDphfjjdEEvwDc1H58P3k8bEMGyF3FdmngMgF+y095/bdm8FGMsTS2nWw1Bvs8iIGz40
 6fSaqQQ8BTbKoWXpnnOg8j1RUBcZ/ah40mqYQZ90MYPclO65VlQGxG253bBnA8WCIAyt
 MFzA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=hNWgf5JR/cvx4+k2/k8//+NsLRafA9SikURsJTJxHl8=;
 b=nsHDN3LWMzsUN2KeV3ekCSNZ9ZuD6I5OrBjtzi+R9G5Dy4Uwy4EEbWepUOTcB7puiu
 GUXpyNEM8E9bsrN6j4Nxn6PnV20hfoMqISGWYC9iRn6tUxnfewfm95wy3D4oxrshr5GF
 gIEqs+b63KWnk3mwbQ3qMlLXfrnqrh7aDAtVUEE5acy5ZV6fvVTxQR5EGB9+htkPfkPw
 J2mCcPtM4eFDICwBjss6Gp8v56ik/vfV1WFSQ9CAiBogJdYK9ZmaQye3jQAsyHoZCahS
 yaNoUEBtFnsB4CRyDcQ4kK0Jp1v5VWQSKLLtSwReiGhQ37ZPEAk4JfmSy1qZ3ddFj4fH
 p5tw==
X-Gm-Message-State: AOAM532OeC3zwlkvwmTRpMGayxXBx28TyszqhS+Qc65oK52t4T5fHmm2
 jYlVCqD5GTwwEr9PdRfEspF7eJe/yax6Ww4uaDcc
X-Google-Smtp-Source: ABdhPJys8MteKkL5WUs90rL77+/4O8I7EJZDSmxK4s4ECn/X6tsLMwrENyCDpmW58kDnYfzhj5A5Va1MBnTmQWGW++s=
X-Received: by 2002:aa7:cd06:: with SMTP id b6mr625058edw.196.1600980376408;
 Thu, 24 Sep 2020 13:46:16 -0700 (PDT)
MIME-Version: 1.0
References: <20200923232923.3142503-1-keescook@chromium.org>
 <20200923232923.3142503-5-keescook@chromium.org>
 <CAG48ez251v19U60GYH4aWE6+C-3PYw5mr_Ax_kxnebqDOBn_+Q@mail.gmail.com>
 <202009240038.864365E@keescook>
 <CAHC9VhQpto1KuL7PhjtdjtAjJ2nC+rZNSM7+nSZ_ksqGXbhY+Q@mail.gmail.com>
 <202009241251.F719CC4@keescook>
In-Reply-To: <202009241251.F719CC4@keescook>
From: Paul Moore <paul@paul-moore.com>
Date: Thu, 24 Sep 2020 16:46:05 -0400
Message-ID: <CAHC9VhQudGg55atznkuWWW5h0d+vZZhO2NF4yNAqreg4NDsHKg@mail.gmail.com>
Subject: Re: [PATCH 4/6] seccomp: Emulate basic filters for constant action
 results
To: Kees Cook <keescook@chromium.org>
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

On Thu, Sep 24, 2020 at 3:52 PM Kees Cook <keescook@chromium.org> wrote:
> On Thu, Sep 24, 2020 at 11:28:55AM -0400, Paul Moore wrote:
> > On Thu, Sep 24, 2020 at 3:46 AM Kees Cook <keescook@chromium.org> wrote:
> > > On Thu, Sep 24, 2020 at 01:47:47AM +0200, Jann Horn wrote:
> > > > On Thu, Sep 24, 2020 at 1:29 AM Kees Cook <keescook@chromium.org> wrote:
> > > > > This emulates absolutely the most basic seccomp filters to figure out
> > > > > if they will always give the same results for a given arch/nr combo.
> > > > >
> > > > > Nearly all seccomp filters are built from the following ops:
> > > > >
> > > > > BPF_LD  | BPF_W    | BPF_ABS
> > > > > BPF_JMP | BPF_JEQ  | BPF_K
> > > > > BPF_JMP | BPF_JGE  | BPF_K
> > > > > BPF_JMP | BPF_JGT  | BPF_K
> > > > > BPF_JMP | BPF_JSET | BPF_K
> > > > > BPF_JMP | BPF_JA
> > > > > BPF_RET | BPF_K
> > > > >
> > > > > These are now emulated to check for accesses beyond seccomp_data::arch
> > > > > or unknown instructions.
> > > > >
> > > > > Not yet implemented are:
> > > > >
> > > > > BPF_ALU | BPF_AND (generated by libseccomp and Chrome)
> > > >
> > > > BPF_AND is normally only used on syscall arguments, not on the syscall
> > > > number or the architecture, right? And when a syscall argument is
> > > > loaded, we abort execution anyway. So I think there is no need to
> > > > implement those?
> > >
> > > Is that right? I can't actually tell what libseccomp is doing with
> > > ALU|AND. It looks like it's using it for building jump lists?
> >
> > There is an ALU|AND op in the jump resolution code, but that is really
> > just if libseccomp needs to fixup the accumulator because a code block
> > is expecting a masked value (right now that would only be a syscall
> > argument, not the syscall number itself).
> >
> > > Paul, Tom, under what cases does libseccomp emit ALU|AND into filters?
> >
> > Presently the only place where libseccomp uses ALU|AND is when the
> > masked equality comparison is used for comparing syscall arguments
> > (SCMP_CMP_MASKED_EQ).  I can't honestly say I have any good
> > information about how often that is used by libseccomp callers, but if
> > I do a quick search on GitHub for "SCMP_CMP_MASKED_EQ" I see 2k worth
> > of code hits; take that for whatever it is worth.  Tom may have some
> > more/better information.
> >
> > Of course no promises on future use :)  As one quick example, I keep
> > thinking about adding the instruction pointer to the list of things
> > that can be compared as part of a libseccomp rule, and if we do that I
> > would expect that we would want to also allow a masked comparison (and
> > utilize another ALU|AND bpf op there).  However, I'm not sure how
> > useful that would be in practice.
>
> Okay, cool. Thanks for checking on that. It sounds like the arg-less
> bitmap optimization can continue to ignore ALU|AND for now. :)

What's really the worst that could happen anyways? (/me ducks)  The
worst case is the filter falls back to the current performance levels
right?

-- 
paul moore
www.paul-moore.com
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
