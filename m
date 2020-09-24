Return-Path: <SRS0=lkaS=DB=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 373ABC4346E
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 07:38:25 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id A84D823741
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 07:38:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="HnTNwGP8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A84D823741
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 190B4874C7;
	Thu, 24 Sep 2020 07:38:24 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id d5BzSp-jmyF3; Thu, 24 Sep 2020 07:38:23 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 90F84874A7;
	Thu, 24 Sep 2020 07:38:23 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 7846AC0859;
	Thu, 24 Sep 2020 07:38:23 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 05D86C0051
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 07:38:22 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 020C4869D2
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 07:38:22 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id PnbCxAjFusgw
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 07:38:21 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pl1-f195.google.com (mail-pl1-f195.google.com
 [209.85.214.195])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 869AF869C0
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 07:38:21 +0000 (UTC)
Received: by mail-pl1-f195.google.com with SMTP id y6so1213319plt.9
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 00:38:21 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:in-reply-to;
 bh=2/ZWotEmwV2wYeMAbWubNYS0mAS1AJsi/PuMFNxSA0Y=;
 b=HnTNwGP8FohbDh7X+PypMX569OCpgnEdElmZ7hXNOGxNjGMFfEkxcg1my+0mklYktz
 UQxlLsrFts2bnq6rFWsLPHHuEQQ628XuCnd8XqRUUnUlvMTs3I66PIrsb0ARIcdPpkgp
 owqNp2wrBCqIff3j2oqFxAiN74eNqrGdyR6xo=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:in-reply-to;
 bh=2/ZWotEmwV2wYeMAbWubNYS0mAS1AJsi/PuMFNxSA0Y=;
 b=tDHqTKMSRu4/QobjYzMPFRnMm/kcUgThXc5tfbRiXBeL1uiJP1FOgfAPnjuoO1xjrW
 9FYn9fAxkTcNHn7hJKTHEIUkSPQfq7RWDexbdTL562syVKXle5vZY8lwGqiAVwl0i6iX
 S6MlkZC6YmwU2zCOQtIzMJwscGVEiVhRKxaOrr30/sOjXRAOR/aFiMV/o8FVC5unl47p
 y7hAji9cbzU+bZ/JDniZrIrq+YNgePjSUfCycsH0xFInJnDnKT4bkB5ep0V7ccigOlW0
 B27uTQFbf0Odf8ijlvUsENnp1Sz3s1iaIgVB1cUXUl9yi4w2r6wwC83tS2Y7mb6tLqSu
 +jEg==
X-Gm-Message-State: AOAM532C8Mvw2Jd/2FoV6P2Ivk/dBmO+Y+LmAd40bB9o+e1zSeD+vFLo
 XGj3kgXJPbj5e9bJLI+kaK5itA==
X-Google-Smtp-Source: ABdhPJwgnuX9NNL+oLb/kmNEL0CZL8XPv33AWyRHruVO1Vk1X5iwGSW6FVUhC/l7K0WYG62SFNLf2g==
X-Received: by 2002:a17:90a:ee16:: with SMTP id
 e22mr2551329pjy.81.1600933101134; 
 Thu, 24 Sep 2020 00:38:21 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id k11sm1607476pjs.18.2020.09.24.00.38.20
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Thu, 24 Sep 2020 00:38:20 -0700 (PDT)
Date: Thu, 24 Sep 2020 00:38:19 -0700
From: Kees Cook <keescook@chromium.org>
To: YiFei Zhu <zhuyifei1999@gmail.com>
Subject: Re: [PATCH 3/6] seccomp: Implement constant action bitmaps
Message-ID: <202009240037.21A9E3CE@keescook>
References: <20200923232923.3142503-1-keescook@chromium.org>
 <20200923232923.3142503-4-keescook@chromium.org>
 <DM6PR11MB271492D0565E91475D949F5DEF390@DM6PR11MB2714.namprd11.prod.outlook.com>
 <CABqSeAS=b6NQ=mqrD=hV60md3isYSDyAnE9QE_AT4=oYYFkAfQ@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CABqSeAS=b6NQ=mqrD=hV60md3isYSDyAnE9QE_AT4=oYYFkAfQ@mail.gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>, Will Drewry <wad@chromium.org>,
 bpf <bpf@vger.kernel.org>, Jann Horn <jannh@google.com>,
 YiFei Zhu <yifeifz2@illinois.edu>, linux-api@vger.kernel.org,
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

On Wed, Sep 23, 2020 at 07:36:47PM -0500, YiFei Zhu wrote:
> On Wed, Sep 23, 2020 at 6:29 PM Kees Cook <keescook@chromium.org> wrote:
> > In order to optimize these cases from O(n) to O(1), seccomp can
> > use bitmaps to immediately determine the desired action. A critical
> > observation in the prior paragraph bears repeating: the common case for
> > syscall tests do not check arguments. For any given filter, there is a
> > constant mapping from the combination of architecture and syscall to the
> > seccomp action result. (For kernels/architectures without CONFIG_COMPAT,
> > there is a single architecture.). As such, it is possible to construct
> > a mapping of arch/syscall to action, which can be updated as new filters
> > are attached to a process.
> 
> Would you mind educating me how this patch plan one handling MIPS? For
> one kernel they seem to have up to three arch numbers per build,
> AUDIT_ARCH_MIPS{,64,64N32}. Though ARCH_TRACE_IGNORE_COMPAT_SYSCALLS
> does not seem to be defined for MIPS so I'm assuming the syscall
> numbers are the same, but I think it is possible some client uses that
> arch number to pose different constraints for different processes, so
> it would better not accelerate them rather than break them.

I'll take a look, but I'm hoping it won't be too hard to fit into what
I've got designed so for to deal with x86_x32. (Will MIPS want this
optimization at all?)

-- 
Kees Cook
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
