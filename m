Return-Path: <SRS0=NhOQ=DQ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0CEFBC433E7
	for <containers@archiver.kernel.org>; Fri,  9 Oct 2020 05:35:15 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 8233922203
	for <containers@archiver.kernel.org>; Fri,  9 Oct 2020 05:35:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="WGuMCeg8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8233922203
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 1D85D876AD;
	Fri,  9 Oct 2020 05:35:14 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id LuiPNVqYqvRB; Fri,  9 Oct 2020 05:35:13 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 4EE0187677;
	Fri,  9 Oct 2020 05:35:13 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 3830EC016F;
	Fri,  9 Oct 2020 05:35:13 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 50C1CC0051
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 05:35:12 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 3597387629
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 05:35:12 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id QWeJ4xesXBYn
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 05:35:09 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pg1-f193.google.com (mail-pg1-f193.google.com
 [209.85.215.193])
 by whitealder.osuosl.org (Postfix) with ESMTPS id DE4CF8764A
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 05:35:09 +0000 (UTC)
Received: by mail-pg1-f193.google.com with SMTP id r21so2923376pgj.5
 for <containers@lists.linux-foundation.org>;
 Thu, 08 Oct 2020 22:35:09 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:in-reply-to;
 bh=XIdDXZRhz37tftITDPN3YNgJVGlOJnM9JsgYjb/1FXE=;
 b=WGuMCeg8HRFhfL9xv5josACQa4Ayr0gq4NmLmAmq05XCJpivwjrG2kMxdt4rKCIV8z
 JbTyUrJHG83fomoTwM1xIDNPvfLoKJAZXqvvfrFaAurphSjLVSXbUayG31oSqGQXiQHL
 ODmtE5v9kkvCYHCbVVTisV2Bm7MtgIB293WGg=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:in-reply-to;
 bh=XIdDXZRhz37tftITDPN3YNgJVGlOJnM9JsgYjb/1FXE=;
 b=mk0yN7mw/ExdIWE08XTsmH9vjf1wedryRWclV522PnXgnW2ggt55B1nxn4KVuXQR8q
 yRj6xDyWqBzNPoHwqWLOktOZASWmigKMr29BOeDGsiAi8wvXJtf7V6AspStr8grQV8e6
 8YQW0oYzw/scl+aUULLj2XpS6VuxaFYWs5fbPsTKzzDCNwVp5C3gRVgf39TS4Fhg5YDx
 XQRf3x+kQUUNPom0gxJyXhnOA6tKIaEq4+4VkYcDurC9TzmsN52i3MK75Ul34vuqyk3I
 fFY1QC355/U39AjfvU0AuFjToiUmU1ajXyMz84dSP5N0T+fZ2bD+KeqjFDH0q1xXPPoV
 nqhA==
X-Gm-Message-State: AOAM5309PeYKxpjIJsCixqMjdrvj8nO3ou/yS+2g9NPhMjcuOJilZoi4
 n19Q9CYp0ZDZ/A/eCW7DXMrgDg==
X-Google-Smtp-Source: ABdhPJwWlTDSch7HFPQiAjEx67gWISRHKOLLPBnbQPmegZcyaqq6YCtFdArCda8ugJ5SqLfu/DVmtQ==
X-Received: by 2002:a17:90a:4489:: with SMTP id t9mr453187pjg.89.1602221709401; 
 Thu, 08 Oct 2020 22:35:09 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id e1sm9701173pfd.198.2020.10.08.22.35.08
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Thu, 08 Oct 2020 22:35:08 -0700 (PDT)
Date: Thu, 8 Oct 2020 22:35:07 -0700
From: Kees Cook <keescook@chromium.org>
To: YiFei Zhu <zhuyifei1999@gmail.com>
Subject: Re: [PATCH v3 seccomp 3/5] seccomp/cache: Lookup syscall allowlist
 for fast path
Message-ID: <202010082234.C044F0FA@keescook>
References: <cover.1601478774.git.yifeifz2@illinois.edu>
 <83c72471f9f79fa982508bd4db472686a67b8320.1601478774.git.yifeifz2@illinois.edu>
 <202009301422.D9F6E6A@keescook>
 <CABqSeASbRXLYgE=rbKO8g8Si9q7nKEGB2UZpi-BcYG5etWVcjA@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CABqSeASbRXLYgE=rbKO8g8Si9q7nKEGB2UZpi-BcYG5etWVcjA@mail.gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, Jann Horn <jannh@google.com>,
 YiFei Zhu <yifeifz2@illinois.edu>,
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

On Thu, Oct 08, 2020 at 07:17:39PM -0500, YiFei Zhu wrote:
> On Wed, Sep 30, 2020 at 4:32 PM Kees Cook <keescook@chromium.org> wrote:
> >
> > On Wed, Sep 30, 2020 at 10:19:14AM -0500, YiFei Zhu wrote:
> > > From: YiFei Zhu <yifeifz2@illinois.edu>
> > >
> > > The fast (common) path for seccomp should be that the filter permits
> > > the syscall to pass through, and failing seccomp is expected to be
> > > an exceptional case; it is not expected for userspace to call a
> > > denylisted syscall over and over.
> > >
> > > This first finds the current allow bitmask by iterating through
> > > syscall_arches[] array and comparing it to the one in struct
> > > seccomp_data; this loop is expected to be unrolled. It then
> > > does a test_bit against the bitmask. If the bit is set, then
> > > there is no need to run the full filter; it returns
> > > SECCOMP_RET_ALLOW immediately.
> > >
> > > Co-developed-by: Dimitrios Skarlatos <dskarlat@cs.cmu.edu>
> > > Signed-off-by: Dimitrios Skarlatos <dskarlat@cs.cmu.edu>
> > > Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>
> >
> > I'd like the content/ordering of this and the emulator patch to be reorganized a bit.
> > I'd like to see the infrastructure of the cache added first (along with
> > the "always allow" test logic in this patch), with the emulator missing:
> > i.e. the patch is a logical no-op: no behavior changes because nothing
> > ever changes the cache bits, but all the operational logic, structure
> > changes, etc, is in place. Then the next patch would be replacing the
> > no-op with the emulator.
> >
> > > ---
> > >  kernel/seccomp.c | 52 ++++++++++++++++++++++++++++++++++++++++++++++++
> > >  1 file changed, 52 insertions(+)
> > >
> > > diff --git a/kernel/seccomp.c b/kernel/seccomp.c
> > > index f09c9e74ae05..bed3b2a7f6c8 100644
> > > --- a/kernel/seccomp.c
> > > +++ b/kernel/seccomp.c
> > > @@ -172,6 +172,12 @@ struct seccomp_cache_filter_data { };
> > >  static inline void seccomp_cache_prepare(struct seccomp_filter *sfilter)
> > >  {
> > >  }
> > > +
> > > +static inline bool seccomp_cache_check(const struct seccomp_filter *sfilter,
> >
> > bikeshedding: "cache check" doesn't tell me anything about what it's
> > actually checking for. How about calling this seccomp_is_constant_allow() or
> > something that reflects both the "bool" return ("is") and what that bool
> > means ("should always be allowed").
> 
> We have a naming conflict here. I'm about to rename
> seccomp_emu_is_const_allow to seccomp_is_const_allow. Adding another
> seccomp_is_constant_allow is confusing. Suggestions?
> 
> I think I would prefer to change seccomp_cache_check to
> seccomp_cache_check_allow. While in this patch set seccomp_cache_check
> does imply the filter is "constant" allow, argument-processing cache
> may change this, and specifying an "allow" in the name specifies the
> 'what that bool means ("should always be allowed")'.

Yeah, that seems good.

-- 
Kees Cook
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
