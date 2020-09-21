Return-Path: <SRS0=X0Oq=C6=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.3 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5DA2AC4727D
	for <containers@archiver.kernel.org>; Mon, 21 Sep 2020 22:57:57 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id EFA952076E
	for <containers@archiver.kernel.org>; Mon, 21 Sep 2020 22:57:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="W4l5lute"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EFA952076E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 909F9863DE;
	Mon, 21 Sep 2020 22:57:56 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id astt5meqOzSG; Mon, 21 Sep 2020 22:57:56 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 2A3D486378;
	Mon, 21 Sep 2020 22:57:56 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 0F8D4C0859;
	Mon, 21 Sep 2020 22:57:56 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 468A5C0051
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 22:57:55 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 2E7ED86378
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 22:57:55 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id jfCfJMdXPYX2
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 22:57:54 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pf1-f196.google.com (mail-pf1-f196.google.com
 [209.85.210.196])
 by whitealder.osuosl.org (Postfix) with ESMTPS id AA8DB85DB1
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 22:57:54 +0000 (UTC)
Received: by mail-pf1-f196.google.com with SMTP id w7so10626626pfi.4
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 15:57:54 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=mcI5ReI6UwbL3Y9VJsKxXjGv/OVvfXvskB57PaK2fIg=;
 b=W4l5lutecwZ6k8fboRiFxU1Hxvcgtrnw4cWWOU59OcbmJ7FVpQASAgTiMg+NRQBf4/
 tbazCRYfVl6lEvWObHic3/v4bewoM3wo+QpDDwiCrFzI+K3hTSklL74Tza9nCmiz8ycw
 TRFTMwG8wrTzbGND2vTuSPj8hFZnyp2y/w2tnvfMbnbWpm8KdkdCWDp1ws+KJQaDvDyM
 4LTgwDzrwy+DX5SAFuLftsDAQxlkV5e0XM99+Z/qbnmwt7W77anx7EPdzBTWYLqUsy/Q
 SQatbhz1BXbbf7xsBwgcG0nimBTsIEdOJfkFrOu8c0gvQN5LY1XtgD43Xz+qF9sPe7HP
 Zmsg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=mcI5ReI6UwbL3Y9VJsKxXjGv/OVvfXvskB57PaK2fIg=;
 b=iHeCtcvBnBk853/TFUKKTUJcab5YczZ0AgWwu9XWREchLDOcShTQKSUZw6snekIHSV
 5bc+QEu/++X4ofFE/B554+PPpnaPLAWYtjbfu3MHcigEl0vk6n7j15MzeTgqQWEHz/Su
 nLopmbL3SVU3CJvkfKj0xqHSZS3JWh2dgk1KWHdEggOYhFaW65jAI/CC55jnYThvovd6
 HTLj5axfVl5tR+DnUyZWARDNtoTfxdXzvd9UEjvgW5pGpyrHg5Y9hR8QxAFAaPyZeCpo
 Ndlcp6pwSp4Ba6bh0v+EnhFxRl2VtOXiJvqO7U+Vx3mLCqxcTmFGQNObUU/+8K480Ewi
 qSGw==
X-Gm-Message-State: AOAM531QM47PGgQ5QaUq6L3qxAMiTxPu8r+7D3QGdKoNIucESoQ1SMxB
 3m7km+MGA9fKG/rZI/2TaaHJwomxgASWI/61UyQ=
X-Google-Smtp-Source: ABdhPJxmNmNeUhF6KGE9L0xFvJuiYivilDKG16tiyTwkR0KEi87a+EGJhK6cBjkll4oKTyv/9auskXQqWXDxyuQxzvM=
X-Received: by 2002:a63:5043:: with SMTP id q3mr1315846pgl.293.1600729074167; 
 Mon, 21 Sep 2020 15:57:54 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1600661418.git.yifeifz2@illinois.edu>
 <20200921135115.GC3794348@cisco>
 <CABqSeASEw=Qr2CroKEpTyWMRXQkamKVUzXiEe2UsoQTCcv_99A@mail.gmail.com>
 <20200921163916.GE3794348@cisco>
In-Reply-To: <20200921163916.GE3794348@cisco>
From: YiFei Zhu <zhuyifei1999@gmail.com>
Date: Mon, 21 Sep 2020 17:57:43 -0500
Message-ID: <CABqSeAT1p10ZCDcFtdFvd80cqcgw6HOHKf6602jJ14n5fDe4HQ@mail.gmail.com>
Subject: Re: [RFC PATCH seccomp 0/2] seccomp: Add bitmap cache of
 arg-independent filter results that allow syscalls
To: Tycho Andersen <tycho@tycho.pizza>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>, Will Drewry <wad@chromium.org>,
 Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>,
 YiFei Zhu <yifeifz2@illinois.edu>, kernel list <linux-kernel@vger.kernel.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>, Hubertus Franke <frankeh@us.ibm.com>,
 Andy Lutomirski <luto@amacapital.net>, Valentin Rothberg <vrothber@redhat.com>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>, Jack Chen <jianyan2@illinois.edu>,
 Josep Torrellas <torrella@illinois.edu>, bpf <bpf@vger.kernel.org>,
 Tianyin Xu <tyxu@illinois.edu>
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

On Mon, Sep 21, 2020 at 11:39 AM Tycho Andersen <tycho@tycho.pizza> wrote:
> I see, I missed this somehow. So is there a reason to hide this behind
> a config option? Isn't it just always better?
>
> Tycho

You have a good point, though, I think keeping a config would allow
people to "test the differences" in the unlikely case that some issue
occurs. Jann pointed that it should be on by default so I'll do that.

YiFei Zhu
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
