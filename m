Return-Path: <SRS0=lkaS=DB=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8C510C4363D
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 00:37:07 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 1BAD32145D
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 00:37:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="S+45JSXz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1BAD32145D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 546052A163;
	Thu, 24 Sep 2020 00:37:06 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id zvIrEzEWhkwu; Thu, 24 Sep 2020 00:37:03 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id A8E33275C6;
	Thu, 24 Sep 2020 00:37:03 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 8E69FC0859;
	Thu, 24 Sep 2020 00:37:03 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 714DAC0051
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 00:37:01 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 62135864B3
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 00:37:01 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 9DDzO5rene0w
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 00:36:59 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pl1-f195.google.com (mail-pl1-f195.google.com
 [209.85.214.195])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 6FC0F8648E
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 00:36:59 +0000 (UTC)
Received: by mail-pl1-f195.google.com with SMTP id m15so666663pls.8
 for <containers@lists.linux-foundation.org>;
 Wed, 23 Sep 2020 17:36:59 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=dDFv/RhyMEgSIdYNNun/DQyCy7wkiVHBQ14Pm7oiRaY=;
 b=S+45JSXzgkr09sRCcCdhdTWZqKjGiqaOTVPh6x4Hr3IKq7yQGY+AZH+183mxSCLvjf
 2wRiljZuy+jzjhGx4hWUxnqPHkZSewMIC4SsfqC7sYaruiXEAYfAz0dUFhu/LdBzxnSc
 T/iryvQXvuvaXswywD1clzhRhQfWhW1MViaAwsLawhN5ieaIH6OPi+WcbeNL4aBPmXiP
 IVU24kMSqalWd6B+dv+TIWsi49MBYZ37xmHIgUmCrtpfjvOHVPm0V4BOjrEe9R+/Xg35
 LHOtkejtneIjgUaU/n2/kZeHlVMc7Olyns38MZQUuio2vVwhMNsgaSAGXF2IFjL2Nxes
 I68g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=dDFv/RhyMEgSIdYNNun/DQyCy7wkiVHBQ14Pm7oiRaY=;
 b=G3/rmm2HEzC+lvl4q3C1eFuuU5yoKcLDGHdDGVEAX87MAEtYXEqW4FbddrbHjii1ma
 n1M7mA+RQ2Prm8v/ddfMi1vQuOiBREW/tTIxfsOlv6uaSR5wlI8xF2Hl4kiAxN5/EZPp
 lqgUryn45spIQhtnUGZ/XWwMVciK7iz9kqxTsUQfYD5wk3mckGBn9yFVhNVTNLKGnpv6
 HX9GSOgKwO4AIagnDKxq8fZ1vOs2CLv3MqDJ9BqF4xsAPoyId8rWczP5pDzgIpjQA46W
 JtVI/JYUWrAissEh1NhHSqfKhdieCHUNPtccrupvxp6yFMphL79SNB41Uu2DNvtZSQq2
 Cw4A==
X-Gm-Message-State: AOAM531khk790PvfzXyzMPi/vHtfj2VmOgIvWc8pfE+FI9yXRpqqyPnH
 wVuW/BEEhoV6pGnub55GbU6sBwOcSVwuS2pHK70=
X-Google-Smtp-Source: ABdhPJzcUri7TwdVOiQl74BHN9CWV7BcbuqvjJ4JyKP1RXR2dA1KPOUbcmXOantN/zjW6Rv9EXYhMdraD4cB2D9KhSs=
X-Received: by 2002:a17:902:7445:b029:d1:dea3:a3ca with SMTP id
 e5-20020a1709027445b02900d1dea3a3camr2137109plt.19.1600907819053; Wed, 23 Sep
 2020 17:36:59 -0700 (PDT)
MIME-Version: 1.0
References: <20200923232923.3142503-1-keescook@chromium.org>
 <20200923232923.3142503-4-keescook@chromium.org>
 <DM6PR11MB271492D0565E91475D949F5DEF390@DM6PR11MB2714.namprd11.prod.outlook.com>
In-Reply-To: <DM6PR11MB271492D0565E91475D949F5DEF390@DM6PR11MB2714.namprd11.prod.outlook.com>
From: YiFei Zhu <zhuyifei1999@gmail.com>
Date: Wed, 23 Sep 2020 19:36:47 -0500
Message-ID: <CABqSeAS=b6NQ=mqrD=hV60md3isYSDyAnE9QE_AT4=oYYFkAfQ@mail.gmail.com>
Subject: Re: [PATCH 3/6] seccomp: Implement constant action bitmaps
To: Kees Cook <keescook@chromium.org>
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

On Wed, Sep 23, 2020 at 6:29 PM Kees Cook <keescook@chromium.org> wrote:
> In order to optimize these cases from O(n) to O(1), seccomp can
> use bitmaps to immediately determine the desired action. A critical
> observation in the prior paragraph bears repeating: the common case for
> syscall tests do not check arguments. For any given filter, there is a
> constant mapping from the combination of architecture and syscall to the
> seccomp action result. (For kernels/architectures without CONFIG_COMPAT,
> there is a single architecture.). As such, it is possible to construct
> a mapping of arch/syscall to action, which can be updated as new filters
> are attached to a process.

Would you mind educating me how this patch plan one handling MIPS? For
one kernel they seem to have up to three arch numbers per build,
AUDIT_ARCH_MIPS{,64,64N32}. Though ARCH_TRACE_IGNORE_COMPAT_SYSCALLS
does not seem to be defined for MIPS so I'm assuming the syscall
numbers are the same, but I think it is possible some client uses that
arch number to pose different constraints for different processes, so
it would better not accelerate them rather than break them.


YiFei Zhu
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
