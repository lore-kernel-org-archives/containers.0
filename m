Return-Path: <SRS0=lkaS=DB=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A50E1C4363D
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 16:02:27 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 12B1823600
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 16:02:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="pb0eJj9r"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 12B1823600
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id BF45286C22;
	Thu, 24 Sep 2020 16:02:26 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id wHfkgDmz2Drz; Thu, 24 Sep 2020 16:02:26 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 361D586BCB;
	Thu, 24 Sep 2020 16:02:26 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 2C110C0890;
	Thu, 24 Sep 2020 16:02:26 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 47E02C0859
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 16:02:24 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 316FE2E112
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 16:02:24 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id lF-adQ-qGph3
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 16:02:23 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pl1-f196.google.com (mail-pl1-f196.google.com
 [209.85.214.196])
 by silver.osuosl.org (Postfix) with ESMTPS id 5A6052E0B5
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 16:02:23 +0000 (UTC)
Received: by mail-pl1-f196.google.com with SMTP id r19so1925359pls.1
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 09:02:23 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=NRCLmg4VDNmw7XaOEseuJn4hXfsbbPGMKJw0MmQ0DNw=;
 b=pb0eJj9rc50bEDW7RBoGUAvuENUYLTp6H/MsgH6/3hVf+AvE3Iqpy6vw6fTVnTtUc0
 XaprcJ4xCk0WB8pggZarMBsPFF7/4tHj4rRihbeagR33gvtgOohtANOS3YoGU5ymVdnp
 f0aZz6Vq6a1X98YS68yqX3h4R67eRfLA1M83OXQhCSDEej6qDOfQc8iK3hnrWOfmM0ze
 aVvSo4vuvZA3cePODNWKCA3lq4fAnJlyXV8QR6lRnhrbP/E8kfLctMlF0+i3Ag7CqtIX
 nu0J3RkD81Q3EDukQrd958DdXBfz/WuJK+qZU8q5yNnpsLTGY4t5YlONIVKSfepnOJl6
 38tQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=NRCLmg4VDNmw7XaOEseuJn4hXfsbbPGMKJw0MmQ0DNw=;
 b=MKodTnQRp+STpcZ4av9l6Rg4nJ7k9seyRi2PFHGIFOFcxQx5uIMa7/5tDRtuFXVtO3
 JnCVIuSsWDrzv36NQppnRQ5f+BQrI3tEV18j+BFRRSdz6rmz+5W4Aa5LInjjkfiXWiII
 ffena+f7N1KfcOsDJXaa+3U1OFOXFcnRlzfSt2ITGpyq3mXJtaef10J0gFhR/RQC2fYz
 TGq8PmygWUDMhlLpsxeRIMr5Lp9yJGjtiG61RNxUpEZFmrSXIp3bVWRiMykeSqdUjYFe
 usiBwIS7LoNc/ZzUcoTbQF00RGJvKWRIgBursLeOlp/dxM3KnPRkav4NHXfcnmDSpzwn
 j/7A==
X-Gm-Message-State: AOAM530xFWwf0K4c6dneKQSt30fN8lN2KnKBtKSrNZHGHvxrY+6SPI8b
 kpHKTpYtxKUVZVSqW0gic6Nj8uvDZG7Aqxg9kc8=
X-Google-Smtp-Source: ABdhPJwMK2AyELo9LPxKKCnULIfqM45VOQhCysUmD7RLdDao+ghn99Hqy1JLu5VcPdW9QRvffafqvTw1JXKBcnbf0KE=
X-Received: by 2002:a17:90b:4b82:: with SMTP id
 lr2mr52199pjb.184.1600963341422; 
 Thu, 24 Sep 2020 09:02:21 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1600951211.git.yifeifz2@illinois.edu>
 <20bbc8ed4b9f2c83d0f67f37955eb2d789268525.1600951211.git.yifeifz2@illinois.edu>
 <7042ba3307b34ce3b95e5fede823514e@AcuMS.aculab.com>
 <CABqSeASWf_CArdOzASLeRBPZQ-S_vtinhZLteYng4iAof4py+w@mail.gmail.com>
 <665ea57e360a421c958fffa08da77920@AcuMS.aculab.com>
 <CABqSeARmtCk+vUbUfQ39z+mCXiHm2Gd=OopLHXvPTnvwcHfwOw@mail.gmail.com>
In-Reply-To: <CABqSeARmtCk+vUbUfQ39z+mCXiHm2Gd=OopLHXvPTnvwcHfwOw@mail.gmail.com>
From: YiFei Zhu <zhuyifei1999@gmail.com>
Date: Thu, 24 Sep 2020 11:02:10 -0500
Message-ID: <CABqSeAQ2mek4ZJ0SFZDy6obJ_JveoWX9GDi-_Q_e8o8ZPpF-XQ@mail.gmail.com>
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

On Thu, Sep 24, 2020 at 9:37 AM YiFei Zhu <zhuyifei1999@gmail.com> wrote:
> > Try with a slghtly older gcc.
> > I think that entire optimisation (discarding const arrays)
> > is very recent.
>
> Will try, will take a while to get an old GCC to run, however :/

Possibly one of the oldest I can easily get to work is GCC 6.5.0, and
unrolling seems is still the case:

0000000000001560 <__seccomp_filter>:
[...]
    15d4:       41 8b 74 24 04          mov    0x4(%r12),%esi
    15d9:       bf 08 01 00 00          mov    $0x108,%edi
    15de:       81 fe 3e 00 00 c0       cmp    $0xc000003e,%esi
    15e4:       75 30                   jne    1616 <__seccomp_filter+0xb6>
[...]
    1616:       81 fe 03 00 00 40       cmp    $0x40000003,%esi
    161c:       bf 40 01 00 00          mov    $0x140,%edi
    1621:       74 c3                   je     15e6 <__seccomp_filter+0x86>
    1623:       0f 0b                   ud2

Am I overlooking something or should I go further back in the compiler version?

YiFei Zhu
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
