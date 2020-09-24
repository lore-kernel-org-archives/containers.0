Return-Path: <SRS0=lkaS=DB=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3903DC4363D
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 14:37:49 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id AA0FB23741
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 14:37:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="hiJKP0bA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA0FB23741
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 53CA586A2F;
	Thu, 24 Sep 2020 14:37:48 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id PutxRrBb5Ua6; Thu, 24 Sep 2020 14:37:45 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id B587B86985;
	Thu, 24 Sep 2020 14:37:45 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 992D2C0859;
	Thu, 24 Sep 2020 14:37:45 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 02D9BC0051
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 14:37:44 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id DCC37874FE
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 14:37:43 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id rqxo1vsBMYCt
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 14:37:42 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pj1-f68.google.com (mail-pj1-f68.google.com
 [209.85.216.68])
 by hemlock.osuosl.org (Postfix) with ESMTPS id B6018874F6
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 14:37:42 +0000 (UTC)
Received: by mail-pj1-f68.google.com with SMTP id v14so1703199pjd.4
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 07:37:42 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=R4i9zfdadrrnX71hdqQs+VUvQUPUWHpKuSmEnQbyjS8=;
 b=hiJKP0bAeEVszBpBvejJbuJiDShopwcUlAdy/0Ct7Z/ZeRpHKTd3xKoQqJISulqHLC
 o3QhS8X5OWXtiH0N4CUu8RearRtfQMFCFNSt2maa+MmdaSSVkPHW4qtawkJg36jidSOm
 /irTHDtRvnkB1jD5whetMY8pNqt42PyFrDWjNCCXoi7BBoqxQZqEVPPFPP0BWKsqnueO
 pDwMmfdKdL1c9lz+8//JjTqORLevu7lTK1V5bdnnXWHmako/f7q6nTkkPazPrzjIl0Ly
 lUnA6B4JoqBChEMr9qs6UTqeAKe0S3PP6TnQGlVkEb/7Iywp6n7cRr2GKGvJjHHWZ6Xt
 o14w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=R4i9zfdadrrnX71hdqQs+VUvQUPUWHpKuSmEnQbyjS8=;
 b=Xtyim32Es1ZUBjXnuB2i+IO63z3ocMiDpFQNWX+rnz4129OnzcA7r1JIBw224/jyGW
 ZOJmh6SbADloBX+p7tcQKolsy7PA+anMBoCkA9g6zf5B0c1V8ya3jHAgaqrtEMiYW4KY
 RZWxtRRcj0KKAYnhKcHwQQqvCLDD0qgYBjuhFCM2f0Lh4pHmPitycFSPZclKUUoUFaSM
 FMO1GIcieT+TrjolQIqkPQy5LN+W0ONRtvR+sTSRZ1kt+upoxOUrda3AQsWD29CkCZjv
 uqtemhQuVat0Pnj4O+UXOPT0NXc2exfOrx0rtSTlldD3dC6WHsqoxO/iClBZQp7mPcZo
 MfFQ==
X-Gm-Message-State: AOAM531n/piHINAFNmFNl/9ecIEPKP1kp+sGc00AStKFM2Mp/L1vs9zL
 1qaDDwq0tIdNG7ZRvnhLWl4homaK+yvi3s3Xa8s=
X-Google-Smtp-Source: ABdhPJxI8taE+t29cLPBxt1C7MtUjX7XEzXJn+KUQrK2FVrn5H2GVR8hAH3xPJgoEQKHMvW91tmC6yI55nuIDVbPdds=
X-Received: by 2002:a17:90b:3252:: with SMTP id
 jy18mr4112252pjb.1.1600958262336; 
 Thu, 24 Sep 2020 07:37:42 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1600951211.git.yifeifz2@illinois.edu>
 <20bbc8ed4b9f2c83d0f67f37955eb2d789268525.1600951211.git.yifeifz2@illinois.edu>
 <7042ba3307b34ce3b95e5fede823514e@AcuMS.aculab.com>
 <CABqSeASWf_CArdOzASLeRBPZQ-S_vtinhZLteYng4iAof4py+w@mail.gmail.com>
 <665ea57e360a421c958fffa08da77920@AcuMS.aculab.com>
In-Reply-To: <665ea57e360a421c958fffa08da77920@AcuMS.aculab.com>
From: YiFei Zhu <zhuyifei1999@gmail.com>
Date: Thu, 24 Sep 2020 09:37:30 -0500
Message-ID: <CABqSeARmtCk+vUbUfQ39z+mCXiHm2Gd=OopLHXvPTnvwcHfwOw@mail.gmail.com>
Subject: Re: [PATCH v2 seccomp 2/6] asm/syscall.h: Add syscall_arches[] array
To: David Laight <David.Laight@aculab.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, Kees Cook <keescook@chromium.org>,
 Jann Horn <jannh@google.com>, YiFei Zhu <yifeifz2@illinois.edu>,
 "containers@lists.linux-foundation.org"
 <containers@lists.linux-foundation.org>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Andy Lutomirski <luto@amacapital.net>, Hubertus Franke <frankeh@us.ibm.com>,
 Jack Chen <jianyan2@illinois.edu>, Dimitrios Skarlatos <dskarlat@cs.cmu.edu>,
 Josep Torrellas <torrella@illinois.edu>, Will Drewry <wad@chromium.org>,
 "bpf@vger.kernel.org" <bpf@vger.kernel.org>, Tianyin Xu <tyxu@illinois.edu>
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

On Thu, Sep 24, 2020 at 9:20 AM David Laight <David.Laight@aculab.com> wrote:
> > Granted, I have CC_OPTIMIZE_FOR_PERFORMANCE rather than
> > CC_OPTIMIZE_FOR_SIZE, but this patch itself is trying to sacrifice
> > some of the memory for speed.
>
> Don't both CC_OPTIMIZE_FOR_PERFORMANCE (-??) and CC_OPTIMIZE_FOR_SIZE (-s)
> generate terrible code?

You have to choose one for "Compiler optimization level" in "General Setup", no?
The former is -O2 and the latter is -Os.

> Try with a slghtly older gcc.
> I think that entire optimisation (discarding const arrays)
> is very recent.

Will try, will take a while to get an old GCC to run, however :/

YiFei Zhu
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
