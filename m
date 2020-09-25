Return-Path: <SRS0=50w+=DC=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 242A1C4346E
	for <containers@archiver.kernel.org>; Fri, 25 Sep 2020 01:36:11 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 78ECA2083B
	for <containers@archiver.kernel.org>; Fri, 25 Sep 2020 01:36:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="JRYOS6/E"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 78ECA2083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 11FE4871C4;
	Fri, 25 Sep 2020 01:36:10 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id MLdIelGtj4Yx; Fri, 25 Sep 2020 01:36:09 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 967CE8709B;
	Fri, 25 Sep 2020 01:36:09 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 81CFEC0890;
	Fri, 25 Sep 2020 01:36:09 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 4B3D0C0859
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 01:36:08 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 4010986C61
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 01:36:08 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id NUnt7C-uwxVn
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 01:36:07 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pf1-f196.google.com (mail-pf1-f196.google.com
 [209.85.210.196])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 2176B86BDA
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 01:36:07 +0000 (UTC)
Received: by mail-pf1-f196.google.com with SMTP id z19so1584419pfn.8
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 18:36:07 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=fgmv1ZdL7UUXwEEal/l25It5GrSTWQVpHodie+cr1w0=;
 b=JRYOS6/EWijo06SB1EWdfUNPiLTpKE4BWfZ0U4z5NiWUiGwaLLEqBs82QOWSq7GHC/
 Lg0nuso6br2icKGo48MjaGPbXt5XfW+FuOep9LZ2ZL0UgBjAiyXvLvw+nU+81bi+nlID
 UiABi7ZcXRSWMSOkl541UuJvrGPaFFf8TcNRndTcWBo71DcNu87UqP4PY0icMqLb/S4N
 vtzUMuvt3t3P8x6O73AmiMAueQDgU0z+uV7hj+1vegevWLFaqER5uz+8cjRUOqXWyv27
 14y6BlTCkF2D9NOMS0AdWMvO3p//u2+Qf4Tcni0GdmPnH7KSeAVIUvMMT2acozLbmbiR
 lUAA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=fgmv1ZdL7UUXwEEal/l25It5GrSTWQVpHodie+cr1w0=;
 b=J6Dyc3oPXFdbcByZtsCphh//Cf/Hxs1llnMonkUZB5HMyRyzsBmMC5nyOm3zjX/1UC
 4IJSupPvieg/4gwuTVwGC2BpnAAAzz1MiqNv3OxYEShlVP0VRj9FngtiFJZzpQ4iryGG
 gXwUqaDrGpXogphfuNDg0qlLQZQci0leH1EfLin0UBz/wsH2xARu1R2YB77RNCJB0UUm
 G9+EFktf/FjgZbUOsDJyoncGYtbr32MyRkPGCOvmYWz69Sq2VcrYuUiPQtTrqQNLhzC7
 x5k18vyF5NMnztD7G2f7IG7nTMB1XToVx+ScVT0a9hfiChLSyDC9sso6f+r1vkizFyKe
 +J4g==
X-Gm-Message-State: AOAM532n8HR9Eg99SRZHDQSWhctD8fYvs1IO41E9F/G0cc8TXw9VuxR2
 LOmlUG9eYrbdTdBoUcUy0mTOWDWsUg+JxomqPkc=
X-Google-Smtp-Source: ABdhPJxyv0KcwQtrdMtQkTLyrl57OgqJRSWjXZ4r4Z8vu+1JbH/U88tfk1cIxqTiWE1k97krRxR311A3MkeH2l3hX0c=
X-Received: by 2002:a17:902:7445:b029:d1:dea3:a3ca with SMTP id
 e5-20020a1709027445b02900d1dea3a3camr1876986plt.19.1600997766672; Thu, 24 Sep
 2020 18:36:06 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1600951211.git.yifeifz2@illinois.edu>
 <eedf3323eed8615a4be150b39a717de1a68f0c12.1600951211.git.yifeifz2@illinois.edu>
 <202009241646.5739BE3@keescook>
In-Reply-To: <202009241646.5739BE3@keescook>
From: YiFei Zhu <zhuyifei1999@gmail.com>
Date: Thu, 24 Sep 2020 20:35:55 -0500
Message-ID: <CABqSeAR8j=ALk5=Y=D4ivVU8m3DC8XgZp74FyAaeErS_TL4FRQ@mail.gmail.com>
Subject: Re: [PATCH v2 seccomp 5/6] selftests/seccomp: Compare bitmap vs
 filter overhead
To: Kees Cook <keescook@chromium.org>
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

On Thu, Sep 24, 2020 at 6:47 PM Kees Cook <keescook@chromium.org> wrote:
> BTW, did this benchmark tool's results match your expectations from what
> you saw with your RFC? (I assume it helped since you've included in
> here.)

Yes, I updated the commit message with the benchmarks of this patch
series. Though, given that I'm running in a qemu-kvm on my laptop that
has a lot of stuffs running on it (and with the cursed ThinkPad T480
CPU throttling), I had to throw much more syscalls at it to pass the
"approximately equals" expectation... though no idea about what's
going on with 732 vs 737.

Or if you mean if I expected these results, yes.

YiFei Zhu
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
