Return-Path: <SRS0=KLId=EK=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17A8DC55178
	for <containers@archiver.kernel.org>; Wed,  4 Nov 2020 18:57:09 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 849D82080D
	for <containers@archiver.kernel.org>; Wed,  4 Nov 2020 18:57:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="M8V29X75"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 849D82080D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 12A1D860D1;
	Wed,  4 Nov 2020 18:57:08 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id nFyxL6y81L2e; Wed,  4 Nov 2020 18:57:07 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 930AD85F92;
	Wed,  4 Nov 2020 18:57:07 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 7B87BC088B;
	Wed,  4 Nov 2020 18:57:07 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 75630C0051
 for <containers@lists.linux-foundation.org>;
 Wed,  4 Nov 2020 18:57:06 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 5F5658676E
 for <containers@lists.linux-foundation.org>;
 Wed,  4 Nov 2020 18:57:06 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id G1kSEjvglBKA
 for <containers@lists.linux-foundation.org>;
 Wed,  4 Nov 2020 18:57:05 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pl1-f195.google.com (mail-pl1-f195.google.com
 [209.85.214.195])
 by whitealder.osuosl.org (Postfix) with ESMTPS id BE3FF866B1
 for <containers@lists.linux-foundation.org>;
 Wed,  4 Nov 2020 18:57:05 +0000 (UTC)
Received: by mail-pl1-f195.google.com with SMTP id x23so10732483plr.6
 for <containers@lists.linux-foundation.org>;
 Wed, 04 Nov 2020 10:57:05 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:in-reply-to;
 bh=eFbEFkCwKJ1hR3ookQi/7V8Itg1IPtT/zHbmeIxSz6g=;
 b=M8V29X75bdxqtjcKywJmnyr1FqzkhvieUPrJY63jv4RFhMimKu9+P3nJ1F+HndPJsh
 QzfeuWZuKcE8FrwefX0HGV1DUScWByoTiabA2VGBkCDVtSUXskkYKZXjTs191p7kBgsy
 q5yRcPFcVQ+sw3CiP8F/EyXbTycT5ga0dpB7M=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:in-reply-to;
 bh=eFbEFkCwKJ1hR3ookQi/7V8Itg1IPtT/zHbmeIxSz6g=;
 b=JCF99lQ6mLrn8d9l+r2HpEmIa61S/DFO7nMlH5Ccahga9TRlDq/vY/R2pYfyWDqAEZ
 CAY4BGnyspuxnFZICOcEOmLZhbbzKRH2gjNDXVnLD2AXypr1OpuQ6bcXKwUqAx+J4XAo
 de7qZcJp8BYyx5Nk1CCCtXSMxAlyM/VM60dQqq4zsZ6hZO2iJfM9kRo7W69ZY4gy3GMp
 O4BdUaT4HhboMDEgH/LFcQTPktN0VbPk9tYvG2QkMPFzrkKXsQ2IE4YlHP+aRzz2bdIB
 VBOsYU/FbtFMb+Dc3vz0CEwIbtPpfb/HKTiij2HQ/YvhwzOkSP+yStPtdmXdvJyvOHk2
 lJTA==
X-Gm-Message-State: AOAM5304KHs8jXwS0bJmSNVUk+LnR7tVpL3oNOAmaqkvRNUS7xI+BAyV
 rtq+x9o8wd04xkTBJy/TRQyp+w==
X-Google-Smtp-Source: ABdhPJyu2rjAfEpo9PsZku1g5A6IasXMm5exN3bYVxllgILGsUnNv/NS1FwRd/sfhdORw2FuF5f16w==
X-Received: by 2002:a17:902:ff0e:b029:d6:820d:cb81 with SMTP id
 f14-20020a170902ff0eb02900d6820dcb81mr31394012plj.47.1604516225344; 
 Wed, 04 Nov 2020 10:57:05 -0800 (PST)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id q16sm3066965pff.114.2020.11.04.10.57.03
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Wed, 04 Nov 2020 10:57:04 -0800 (PST)
Date: Wed, 4 Nov 2020 10:57:03 -0800
From: Kees Cook <keescook@chromium.org>
To: YiFei Zhu <zhuyifei1999@gmail.com>
Subject: Re: [PATCH v4 seccomp 5/5] seccomp/cache: Report cache data through
 /proc/pid/seccomp_cache
Message-ID: <202011041052.0D14CD6@keescook>
References: <202010121556.1110776B83@keescook>
 <CABqSeAT2-vNVUrXSWiGp=cXCvz8LbOrTBo1GbSZP2Z+CKdegJA@mail.gmail.com>
 <CABqSeASc-3n_LXpYhb+PYkeAOsfSjih4qLMZ5t=q5yckv3w0nQ@mail.gmail.com>
 <202010221520.44C5A7833E@keescook>
 <CABqSeAT4L65_uS=45uxPZALKaDSDocMviMginLOV2N0h-e1AzA@mail.gmail.com>
 <202010231945.90FA4A4AA@keescook>
 <CABqSeAQ4cCwiPuXEeaGdErMmLDCGxJ-RgweAbUqdrdm+XJXxeg@mail.gmail.com>
 <CABqSeATiV0sQvqpvCuqkOXNbjetY=1=6ry_SciMVmo63W9A88A@mail.gmail.com>
 <202011031612.6AA505157@keescook>
 <CABqSeASFkTFn8ix8-5D0vdZ_FR9bR1PpU3j5eQPYOMshK6FuNA@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CABqSeASFkTFn8ix8-5D0vdZ_FR9bR1PpU3j5eQPYOMshK6FuNA@mail.gmail.com>
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

On Wed, Nov 04, 2020 at 05:40:51AM -0600, YiFei Zhu wrote:
> On Tue, Nov 3, 2020 at 6:29 PM Kees Cook <keescook@chromium.org> wrote:
> > Yeah, this is very interesting. That there is anything measurably _slower_
> > with the cache is surprising. Though with only 4 runs, I wonder if it's
> > still noisy? What happens at 10 runs -- more importantly what is the
> > standard deviation?
> 
> I could do that. it just takes such a long time. Each run takes about
> 20 minutes so with 10 runs per environment, 3 environments (native + 2
> docker) per boot, and 4 boots (2 bootparam * 2 compile config), it's
> 27 hours of compilation. I should probably script it at that point.

Yeah, I was facing the same issues. Though perhaps hackbench (with
multiple CPUs) would be a better test (and it's much faster):

https://lore.kernel.org/lkml/7723ae8d-8333-ba17-6983-a45ec8b11c54@redhat.com/

(I usually run this with a CNT of 20 to get quick results.)

> > I assume this is from Indirect Branch Prediction Barrier (IBPB) and
> > Single Threaded Indirect Branch Prediction (STIBP) (which get enabled
> > for threads under seccomp by default).
> >
> > Try booting with "spectre_v2_user=prctl"
> 
> Hmm, to make sure, boot with just "spectre_v2_user=prctl" on the
> command line and test the performance of that?

Right, see if that eliminates the 3 minute jump seen for seccomp.

-- 
Kees Cook
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
