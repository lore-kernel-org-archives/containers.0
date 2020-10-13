Return-Path: <SRS0=kI60=DU=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.3 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ABC15C433E7
	for <containers@archiver.kernel.org>; Tue, 13 Oct 2020 00:31:32 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 3445F21655
	for <containers@archiver.kernel.org>; Tue, 13 Oct 2020 00:31:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="EgkGa/BE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3445F21655
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id A0EF12E0D6;
	Tue, 13 Oct 2020 00:31:31 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id U-5lC-DaVVVp; Tue, 13 Oct 2020 00:31:29 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id A7A36274EE;
	Tue, 13 Oct 2020 00:31:29 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 832D6C0052;
	Tue, 13 Oct 2020 00:31:29 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 0AC4CC0051
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Oct 2020 00:31:28 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id E3E2686BE1
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Oct 2020 00:31:27 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id BYZzZHbFcDak
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Oct 2020 00:31:27 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pg1-f195.google.com (mail-pg1-f195.google.com
 [209.85.215.195])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 6AA3686BDD
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Oct 2020 00:31:27 +0000 (UTC)
Received: by mail-pg1-f195.google.com with SMTP id i2so16127852pgh.7
 for <containers@lists.linux-foundation.org>;
 Mon, 12 Oct 2020 17:31:27 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=RXZNvLUHIPZhcUjRnKBWUfl+DzXXg5MXS7WMTuKeZqY=;
 b=EgkGa/BElavLOO5do8aI/LDI65T4SLmDW8j8GtvnCsMqRBTuzcnVjgwuSdSDywqjvi
 68gLb90unNImwgG+pg5B/c302jrN06h2wiOsbrS6lxh8EQjYlmK7IUQnSGU/kv2q8QG+
 EWOBIoZOyIobyfZvWYXKxuZwSKTVUMEXBgX4ZSAm7NcGssu/qudmnUEzxRGMANa3Lou5
 MjTF8Aw/QRattq1J+RTgiH8N7u0DTN9vVgQp0Ylvdjn8NkAptoEbXZ5eu6oXV79TtK/9
 bHTxA8tUDVroDUdUEZK0RaWfRT1RH5IBbwfF+F6lF8u/pZVT/m/Yzov79xfTFFBkwVbg
 PhPQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=RXZNvLUHIPZhcUjRnKBWUfl+DzXXg5MXS7WMTuKeZqY=;
 b=V18WqEtNFsj8o/ytxGCvjDe+4evNk9nsHH0rTw+rwrBfMwvHTgsNOdUfw55MUv3OVq
 P3ePceiSj1/SSnSbvAmUEW+6iGpKf7MNexaBk9uleZotNng3LTMLcMHG/wPKQmClYUR6
 P2IgLL4pavgTagsNDMT9MelhSzka4ylvUDVyU9SSmNTMdz7gFZw26pzbGnw+YeSZCPRa
 0TsC/xUkmf+td1fxAMtQqLDeFxbDLcty+xGYGx1hOPCsuGfnlzahDH959jtmNC6EJLm3
 qs+WccRgoM/je9akXY7jtjeT99aDp1H7wMgLmsQ8z9CsOAre6UdfRrHtBaou4NwTW65z
 k9BA==
X-Gm-Message-State: AOAM532Ov4fVx73RiQcxs9feYkq0Nxpqnr90Y6UNkPuYaDjdvQmPqSPh
 qOlLevxAfb2D+siRdsHEmXwIienULSDAx24oLx8=
X-Google-Smtp-Source: ABdhPJwg5QbybFtaIctqSCgVoJcBwsMrZ8yltrreNaMkzpkUU1M8W2QrCl9Pfc1cKWvkAdOBW1KhWVjQhmcp1iD+GHE=
X-Received: by 2002:aa7:8d4c:0:b029:150:f692:4129 with SMTP id
 s12-20020aa78d4c0000b0290150f6924129mr25657902pfe.11.1602549086984; Mon, 12
 Oct 2020 17:31:26 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1602263422.git.yifeifz2@illinois.edu>
 <c2077b8a86c6d82d611007d81ce81d32f718ec59.1602263422.git.yifeifz2@illinois.edu>
 <202010091613.B671C86@keescook>
 <CABqSeARZWBQrLkzd3ozF16ghkADQqcN4rUoJS2MKkd=73g4nVA@mail.gmail.com>
 <202010121556.1110776B83@keescook>
In-Reply-To: <202010121556.1110776B83@keescook>
From: YiFei Zhu <zhuyifei1999@gmail.com>
Date: Mon, 12 Oct 2020 19:31:16 -0500
Message-ID: <CABqSeAT2-vNVUrXSWiGp=cXCvz8LbOrTBo1GbSZP2Z+CKdegJA@mail.gmail.com>
Subject: Re: [PATCH v4 seccomp 5/5] seccomp/cache: Report cache data through
 /proc/pid/seccomp_cache
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

On Mon, Oct 12, 2020 at 5:57 PM Kees Cook <keescook@chromium.org> wrote:
> I think it's fine to just have this "dangle" with a help text update of
> "if seccomp action caching is supported by the architecture, provide the
> /proc/$pid ..."

I think it would be weird if someone sees this help text and wonder...
"hmm does my architecture support seccomp action caching" and without
a clear pointer to how seccomp action cache works, goes and compiles
the kernel with this config option on for the purpose of knowing if
their arch supports it... Or, is it a common practice in the kernel to
leave dangling configs?

YiFei Zhu
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
