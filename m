Return-Path: <SRS0=50w+=DC=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E4B5C4346E
	for <containers@archiver.kernel.org>; Fri, 25 Sep 2020 03:09:15 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 98B8320866
	for <containers@archiver.kernel.org>; Fri, 25 Sep 2020 03:09:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="EeXCN+vi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 98B8320866
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 1007A86CBE;
	Fri, 25 Sep 2020 03:09:14 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 089gHMBV0gq7; Fri, 25 Sep 2020 03:09:12 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 4AD2585BBA;
	Fri, 25 Sep 2020 03:09:12 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 3EC1AC0859;
	Fri, 25 Sep 2020 03:09:12 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 90CD6C0051
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 03:09:11 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 78F0086A2D
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 03:09:11 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id JR9Flz8Z_gTh
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 03:09:10 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pg1-f195.google.com (mail-pg1-f195.google.com
 [209.85.215.195])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id D2503866F2
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 03:09:10 +0000 (UTC)
Received: by mail-pg1-f195.google.com with SMTP id x16so537442pgj.3
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 20:09:10 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:in-reply-to;
 bh=hJ1W1/RS5W0hSkVAbx2PZJL6p6qwRikie5JVs3zNzvM=;
 b=EeXCN+viasa0U6+b2eUA5OPmUiG4kY9mInu5zsqE0vKBwiPrI2/yiRGJavfHhEJAJP
 J7yh3KiOAm0o+rViCqageC3W19loqvQ2a99KvKlv24zmIbBZEha/N+LHrlVWOgOEgk9J
 jxulU8Gikr3EQZgr6dMYlPslVFZjSjsGK+Cxc=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:in-reply-to;
 bh=hJ1W1/RS5W0hSkVAbx2PZJL6p6qwRikie5JVs3zNzvM=;
 b=jBCDaIArE7WlGbHvwLq0Kc7jtsCfOqQfA9zGJ3bbs9RPQp1UGrgNH5I2hsGjwERuXU
 OL2J0CdsJehxTIY81wTGf8gUwsqDqwwtdzw4aBQAlbimCKI2V79yYfV4z0SSWSETS7jV
 4iQvKrybl5ngZmVCeNXsg8lR5TCDv6v4nnMYolYkXFQ+m0WuiYeslpcNfPghwZtPEW7+
 hDrV5wsUgyzkFenhD9s6lpIC6Cm+EGOImZEAh6UfRKeew4WEVukMUzrRtqxTAtjUvOTi
 5+f54rjNr5JNlGa2tzlUx5eP2GJlT0KAp3IN/6Zya1t0lPMRvAc3OV2EzdIRPjjlv1a1
 yp+Q==
X-Gm-Message-State: AOAM532918MjsU/2uadtLVP0AE29o/usfjH5fUM5tFjaB2Ydwjm9AknN
 /trQBj1VbBSaTC9GgAukE0JatQ==
X-Google-Smtp-Source: ABdhPJy3M327HKr9IezlNDMptTHO3YONc893KnALpMIxtXbLrvx0ZnSoE0AAxZuUKojDDbhv4QCZ7w==
X-Received: by 2002:a17:902:b7c4:b029:d0:b7a2:d16 with SMTP id
 v4-20020a170902b7c4b02900d0b7a20d16mr2244425plz.11.1601003350409; 
 Thu, 24 Sep 2020 20:09:10 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id q140sm95635pfc.39.2020.09.24.20.09.08
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Thu, 24 Sep 2020 20:09:09 -0700 (PDT)
Date: Thu, 24 Sep 2020 20:09:07 -0700
From: Kees Cook <keescook@chromium.org>
To: YiFei Zhu <zhuyifei1999@gmail.com>
Subject: Re: [PATCH v2 seccomp 2/6] asm/syscall.h: Add syscall_arches[] array
Message-ID: <202009242000.DE12689BD8@keescook>
References: <b792335294ee5598d0fb42702a49becbce2f925f.1600661419.git.yifeifz2@illinois.edu>
 <202009241658.A062D6AE@keescook>
 <CABqSeAQ=joheH+0LUZ201U-XwFFsHN3Ouo5FGoscUwn+itkL2w@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CABqSeAQ=joheH+0LUZ201U-XwFFsHN3Ouo5FGoscUwn+itkL2w@mail.gmail.com>
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

On Thu, Sep 24, 2020 at 08:27:40PM -0500, YiFei Zhu wrote:
> [resending this too]
> 
> On Thu, Sep 24, 2020 at 6:01 PM Kees Cook <keescook@chromium.org> wrote:
> > Disregarding the "how" of this, yeah, we'll certainly need something to
> > tell seccomp about the arrangement of syscall tables and how to find
> > them.
> >
> > However, I'd still prefer to do this on a per-arch basis, and include
> > more detail, as I've got in my v1.
> >
> > Something missing from both styles, though, is a consolidation of
> > values, where the AUDIT_ARCH* isn't reused in both the seccomp info and
> > the syscall_get_arch() return. The problems here were two-fold:
> >
> > 1) putting this in syscall.h meant you do not have full NR_syscall*
> >    visibility on some architectures (e.g. arm64 plays weird games with
> >    header include order).
> 
> I don't get this one -- I'm not playing with NR_syscall here.

Right, sorry, I may not have been clear. When building my RFC I noticed
that I couldn't use NR_syscall very "early" in the header file include
stack on arm64, which complicated things. So I guess what I mean is
something like "it's probably better to do all these seccomp-specific
macros/etc in asm/include/seccomp.h rather than in syscall.h because I
know at least one architecture that might cause trouble."

> > 2) seccomp needs to handle "multiplexed" tables like x86_x32 (distros
> >    haven't removed CONFIG_X86_X32 widely yet, so it is a reality that
> >    it must be dealt with), which means seccomp's idea of the arch
> >    "number" can't be the same as the AUDIT_ARCH.
> 
> Why so? Does anyone actually use x32 in a container? The memory cost
> and analysis cost is on everyone. The worst case scenario if we don't
> support it is that the syscall is not accelerated.

Ironicailly, that's the only place I actually know for sure where people
using x32 because it shows measurable (10%) speed-up for builders:
https://lore.kernel.org/lkml/CAOesGMgu1i3p7XMZuCEtj63T-ST_jh+BfaHy-K6LhgqNriKHAA@mail.gmail.com

So, yes, as you and Jann both point out, it wouldn't be terrible to just
ignore x32, it seems a shame to penalize it. That said, if the masking
step from my v1 is actually noticable on a native workload, then yeah,
probably x32 should be ignored. My instinct (not measured) is that it's
faster than walking a small array.[citation needed]

> > So, likely a combo of approaches is needed: an array (or more likely,
> > enum), declared in the per-arch seccomp.h file. And I don't see a way
> > to solve #1 cleanly.
> >
> > Regardless, it needs to be split per architecture so that regressions
> > can be bisected/reverted/isolated cleanly. And if we can't actually test
> > it at runtime (or find someone who can) it's not a good idea to make the
> > change. :)
> 
> You have a good point regarding tests. Don't see how it affects
> regressions though. Only one file here is ever included per-build.

It's easier to do a per-arch revert (i.e. all the -stable tree
machinery, etc) with a single SHA instead of having to write a partial
revert, etc.

-- 
Kees Cook
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
