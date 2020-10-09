Return-Path: <SRS0=NhOQ=DQ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.5 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B76D8C433DF
	for <containers@archiver.kernel.org>; Fri,  9 Oct 2020 00:17:57 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id EA7E422253
	for <containers@archiver.kernel.org>; Fri,  9 Oct 2020 00:17:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="l+9ARLRb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EA7E422253
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 5CB7D2E228;
	Fri,  9 Oct 2020 00:17:56 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id jSAGbNXlt2mM; Fri,  9 Oct 2020 00:17:53 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 346172E21F;
	Fri,  9 Oct 2020 00:17:53 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 1F0ABC07FF;
	Fri,  9 Oct 2020 00:17:53 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 94BBEC0051
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 00:17:51 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 87C328764C
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 00:17:51 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id FxthVieCa4eM
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 00:17:51 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pf1-f195.google.com (mail-pf1-f195.google.com
 [209.85.210.195])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 05A5D8763A
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 00:17:51 +0000 (UTC)
Received: by mail-pf1-f195.google.com with SMTP id l126so5357047pfd.5
 for <containers@lists.linux-foundation.org>;
 Thu, 08 Oct 2020 17:17:51 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=GfhHHR4pKbk7p2RCtudI48L9yccCmQn13QSmLqHOpqE=;
 b=l+9ARLRb9oLSk2zBqP7Ye+thTIcpC9bxYPWNxSajiaetz6v3CgqO1xHoPTX03fErKa
 QchKdmiUftQRFJ7jMHBLv4Nb8LACpVAlC32HvlYV26TEMUkuZgFDC8MiDZTOk5vU62g4
 GuWs6HoiK5wGXRVFpMbqidU1nmW62b4arwFBI/lDjjRQTQF3vblCUv36QKmjciqYPyXS
 gf0INfCeuAuKNFw4b0qBNdJGO6zsMZOI/RXdSOZObkutDnVNJ1jWEZZfS08DdtggAd+Z
 v8nZiUExVcHkjkABs4GnC4XBLwf4rj40VYZMBEVU4j646xJoiaGib0LiCT0VO+LdU7eS
 SGXg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=GfhHHR4pKbk7p2RCtudI48L9yccCmQn13QSmLqHOpqE=;
 b=keO6SolzqM6Z73Ev6Y3IYXHKwLw2aIQ0czbj1YIf7BF/I5t7uire290I4ks2I/iYo1
 avVfpHhCAoTKfRdYm0l704qCS4ijYhj+kaH9XDHvbb0C/CZgsEMtG9NhwpEqWwJia2bg
 KUTl7bFZtAOgLoVdogQ0a5R6FGjTc4ucVJphl9uXdEgIVdZi8a/xEAH/W6bhi0PH7j3Z
 98xFNs29KWEeRydHexFt5jtxkp/I+rC+v8NN1Ut7gTaWLnJD/N+QM0o+uvZ2k6vC+VOt
 gbM7zrO0CM+5HC3oWSahY+TjvAD8/8yTi5HBcyPo69PRLMIfEV3FZ+TAJkmq9hbjf5Ty
 P2pA==
X-Gm-Message-State: AOAM530i+yQiu1kS7IRsy0PYMpsSMvjbtVLUcJaSAucv/fsyY1R4J0GE
 15ZMp8Qfr9wrW3S0layXF56SXkt3/XEb7nbe0as=
X-Google-Smtp-Source: ABdhPJwcXfNIgKgm3YkQPIhlaT3JnMp3WueuSFA6XTYpyR/WEW0+W0BG2h4lGxp1o1UtTjbNnQYadnf5Ix3d1XgiBug=
X-Received: by 2002:a63:1c19:: with SMTP id c25mr1245508pgc.66.1602202670500; 
 Thu, 08 Oct 2020 17:17:50 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1601478774.git.yifeifz2@illinois.edu>
 <83c72471f9f79fa982508bd4db472686a67b8320.1601478774.git.yifeifz2@illinois.edu>
 <202009301422.D9F6E6A@keescook>
In-Reply-To: <202009301422.D9F6E6A@keescook>
From: YiFei Zhu <zhuyifei1999@gmail.com>
Date: Thu, 8 Oct 2020 19:17:39 -0500
Message-ID: <CABqSeASbRXLYgE=rbKO8g8Si9q7nKEGB2UZpi-BcYG5etWVcjA@mail.gmail.com>
Subject: Re: [PATCH v3 seccomp 3/5] seccomp/cache: Lookup syscall allowlist
 for fast path
To: Kees Cook <keescook@chromium.org>
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

On Wed, Sep 30, 2020 at 4:32 PM Kees Cook <keescook@chromium.org> wrote:
>
> On Wed, Sep 30, 2020 at 10:19:14AM -0500, YiFei Zhu wrote:
> > From: YiFei Zhu <yifeifz2@illinois.edu>
> >
> > The fast (common) path for seccomp should be that the filter permits
> > the syscall to pass through, and failing seccomp is expected to be
> > an exceptional case; it is not expected for userspace to call a
> > denylisted syscall over and over.
> >
> > This first finds the current allow bitmask by iterating through
> > syscall_arches[] array and comparing it to the one in struct
> > seccomp_data; this loop is expected to be unrolled. It then
> > does a test_bit against the bitmask. If the bit is set, then
> > there is no need to run the full filter; it returns
> > SECCOMP_RET_ALLOW immediately.
> >
> > Co-developed-by: Dimitrios Skarlatos <dskarlat@cs.cmu.edu>
> > Signed-off-by: Dimitrios Skarlatos <dskarlat@cs.cmu.edu>
> > Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>
>
> I'd like the content/ordering of this and the emulator patch to be reorganized a bit.
> I'd like to see the infrastructure of the cache added first (along with
> the "always allow" test logic in this patch), with the emulator missing:
> i.e. the patch is a logical no-op: no behavior changes because nothing
> ever changes the cache bits, but all the operational logic, structure
> changes, etc, is in place. Then the next patch would be replacing the
> no-op with the emulator.
>
> > ---
> >  kernel/seccomp.c | 52 ++++++++++++++++++++++++++++++++++++++++++++++++
> >  1 file changed, 52 insertions(+)
> >
> > diff --git a/kernel/seccomp.c b/kernel/seccomp.c
> > index f09c9e74ae05..bed3b2a7f6c8 100644
> > --- a/kernel/seccomp.c
> > +++ b/kernel/seccomp.c
> > @@ -172,6 +172,12 @@ struct seccomp_cache_filter_data { };
> >  static inline void seccomp_cache_prepare(struct seccomp_filter *sfilter)
> >  {
> >  }
> > +
> > +static inline bool seccomp_cache_check(const struct seccomp_filter *sfilter,
>
> bikeshedding: "cache check" doesn't tell me anything about what it's
> actually checking for. How about calling this seccomp_is_constant_allow() or
> something that reflects both the "bool" return ("is") and what that bool
> means ("should always be allowed").

We have a naming conflict here. I'm about to rename
seccomp_emu_is_const_allow to seccomp_is_const_allow. Adding another
seccomp_is_constant_allow is confusing. Suggestions?

I think I would prefer to change seccomp_cache_check to
seccomp_cache_check_allow. While in this patch set seccomp_cache_check
does imply the filter is "constant" allow, argument-processing cache
may change this, and specifying an "allow" in the name specifies the
'what that bool means ("should always be allowed")'.

YiFei Zhu
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
