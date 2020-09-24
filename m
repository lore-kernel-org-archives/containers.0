Return-Path: <SRS0=lkaS=DB=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D875DC4346E
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 07:51:36 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 5627023787
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 07:51:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="LQ9fBJUk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5627023787
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id EC686873A1;
	Thu, 24 Sep 2020 07:51:34 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 8GekQJj-OhbK; Thu, 24 Sep 2020 07:51:34 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 8B8FA8720A;
	Thu, 24 Sep 2020 07:51:34 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 80704C0859;
	Thu, 24 Sep 2020 07:51:34 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 27FF8C0051
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 07:51:33 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 1626186B55
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 07:51:33 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id vvWgRC1uVffy
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 07:51:32 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pf1-f194.google.com (mail-pf1-f194.google.com
 [209.85.210.194])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 92E3986A27
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 07:51:32 +0000 (UTC)
Received: by mail-pf1-f194.google.com with SMTP id k8so1403097pfk.2
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 00:51:32 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=48nix4rTdQigZRa9Vc7CjTQh3htJMAItDGYGEpyaX94=;
 b=LQ9fBJUkchQKhpDJK824w+FTNJrBTTwrBKUZD8qpIHSBjtOPhtIzo6VKaoMMHhNFAL
 lxtHy84Dpu58G96obf8L3Wlh+T+71fNnC8Od/NwficCfZb1+GYjfYw2XDgXjFX8eIQHp
 1YiOujXN/CFMVfOoMiIOvcWc3SFrb+s0TAX5ihF2qGNHuxCsqew19roD2DweOQBLVDtI
 oJxL6FeRwxwgkHl++r4TBYC/gJdE2FOJxlzGFfJv3DJMQs64aAAa26HAOILgU8tv6S8C
 AIq1mphBEYwZbyzic6qye7YROHHz+2iilIUxfJlFdtlG08D5cGckAo8BUW4KMR9JhLdM
 rLCQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=48nix4rTdQigZRa9Vc7CjTQh3htJMAItDGYGEpyaX94=;
 b=tfNdB99DcfzNRd0K1RHXMhj8NAoskxVfFpe2oReojF/nycIVqv3uIgnOljLz7Ytd2o
 9gOrPRqVLTZzZS98ZAEaJP64fOeLwzSlaFn7LDlCygj03pCJ9HZhxDOOyw2JLNg3/sZr
 NH4nn3kfUmLF7cbuMGK8MuPLwn9iegO6izd96vKmJdKqCM2oK+IVMo0WCpm/+5J1N5se
 FQ1sFtybozCvaK2WXmU+xuyC/5cQNJ3hYTFK1Z9uI842NqKA17Dl1HIFyfWC3MIyVnJa
 GY3GaLL+BUg8mkMQH1MCSpavQM3W9Vq2mqhvmVsKbeKyg9nLpsl/ZjP8mP/2AP6ffOjE
 4MQg==
X-Gm-Message-State: AOAM533xdeiRMzDzdgpssDcKTkc/7wYkKhxSCBV3ilPUsp4XLmORz9Yl
 siAYEs9eMeYN3L12HM5v98ohHnGoaKjT46X4pKU=
X-Google-Smtp-Source: ABdhPJx65pp+0WKMk7ffwPmRtbbQTqLX1EOoTsZNPeH430NNbFVserZlspAwXhx3O3RcBnCwjUoE6+jE3pvHXX1gUQg=
X-Received: by 2002:a63:511d:: with SMTP id f29mr3010937pgb.11.1600933891983; 
 Thu, 24 Sep 2020 00:51:31 -0700 (PDT)
MIME-Version: 1.0
References: <20200923232923.3142503-1-keescook@chromium.org>
 <20200923232923.3142503-4-keescook@chromium.org>
 <DM6PR11MB271492D0565E91475D949F5DEF390@DM6PR11MB2714.namprd11.prod.outlook.com>
 <CABqSeAS=b6NQ=mqrD=hV60md3isYSDyAnE9QE_AT4=oYYFkAfQ@mail.gmail.com>
 <202009240037.21A9E3CE@keescook>
In-Reply-To: <202009240037.21A9E3CE@keescook>
From: YiFei Zhu <zhuyifei1999@gmail.com>
Date: Thu, 24 Sep 2020 02:51:20 -0500
Message-ID: <CABqSeATpdn48Jbc1zLugbJBhRJNKr0P+BVx0SyODrEQgrX9HMw@mail.gmail.com>
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

On Thu, Sep 24, 2020 at 2:38 AM Kees Cook <keescook@chromium.org> wrote:
> > Would you mind educating me how this patch plan one handling MIPS? For
> > one kernel they seem to have up to three arch numbers per build,
> > AUDIT_ARCH_MIPS{,64,64N32}. Though ARCH_TRACE_IGNORE_COMPAT_SYSCALLS
> > does not seem to be defined for MIPS so I'm assuming the syscall
> > numbers are the same, but I think it is possible some client uses that
> > arch number to pose different constraints for different processes, so
> > it would better not accelerate them rather than break them.
>
> I'll take a look, but I'm hoping it won't be too hard to fit into what
> I've got designed so for to deal with x86_x32. (Will MIPS want this
> optimization at all?)

I just took a slightly closer look at MIPS and it seems that they have
sparse syscall numbers (defines HAVE_SPARSE_SYSCALL_NR). I don't know
how the different "regions of syscall numbers" are affected by arch
numbers, however...
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
