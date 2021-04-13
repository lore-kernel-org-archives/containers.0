Return-Path: <SRS0=O+XM=JK=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96187C433B4
	for <containers@archiver.kernel.org>; Tue, 13 Apr 2021 16:08:02 +0000 (UTC)
Received: from smtp4.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 13B1E6124B
	for <containers@archiver.kernel.org>; Tue, 13 Apr 2021 16:08:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 13B1E6124B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kinvolk.io
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp4.osuosl.org (Postfix) with ESMTP id D03E840563;
	Tue, 13 Apr 2021 16:08:01 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp4.osuosl.org ([127.0.0.1])
	by localhost (smtp4.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id dkatsGO-EHI4; Tue, 13 Apr 2021 16:08:01 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [IPv6:2605:bc80:3010:104::8cd3:938])
	by smtp4.osuosl.org (Postfix) with ESMTP id B547E4055D;
	Tue, 13 Apr 2021 16:08:00 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 9CAB1C000B;
	Tue, 13 Apr 2021 16:08:00 +0000 (UTC)
Received: from smtp2.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id C0E1AC000A
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Apr 2021 16:07:58 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp2.osuosl.org (Postfix) with ESMTP id AB4F8400FE
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Apr 2021 16:07:58 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Authentication-Results: smtp2.osuosl.org (amavisd-new);
 dkim=pass (1024-bit key) header.d=kinvolk.io
Received: from smtp2.osuosl.org ([127.0.0.1])
 by localhost (smtp2.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 0meV32taTJcW
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Apr 2021 16:07:57 +0000 (UTC)
X-Greylist: whitelisted by SQLgrey-1.8.0
Received: from mail-lj1-x233.google.com (mail-lj1-x233.google.com
 [IPv6:2a00:1450:4864:20::233])
 by smtp2.osuosl.org (Postfix) with ESMTPS id 82E43400E1
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Apr 2021 16:07:56 +0000 (UTC)
Received: by mail-lj1-x233.google.com with SMTP id u4so19971281ljo.6
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Apr 2021 09:07:56 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kinvolk.io; s=google;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc:content-transfer-encoding;
 bh=/KJyPMByeKfdgT60ieP/d3a94iiS3K1OI1uOetpEesw=;
 b=BnckUcD+kS4ZFWuMtJYd0CnI7njVo/AxMtEgUPbFUcmdtAG4HBwlW4eAOKb5z92Snv
 Y7of1VvASMfo+stu2k0IzIS+DdpL3CjCB/ap7yTsJ3lEGFyrX20Di7nMcBAj0BA1f+Ln
 PN2+B4yuGEYQm9M4VW1lHEmc9HCVrRmr9nN/c=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc:content-transfer-encoding;
 bh=/KJyPMByeKfdgT60ieP/d3a94iiS3K1OI1uOetpEesw=;
 b=fUYuBPOv6U/JKpvVkjhLlISv/K+hPxR/mYpN519f5wHpGaEYLzVGivDtgsllAjJc7l
 yuUg5YnD0WsQGy9jXtxmiWEZhvPrB2Nb4rAroVVgMoOHYxW5r0AlqGb2qz1D7VDhWV9E
 lSzeUwwOuRLo7D3TUlPIrSeqfnuxtKk7nR7YcFjfMpOQRIQw+Yq35T11SgG1uFOwuSBv
 qC8wD8+ssejjCQlxgFfTbBROHTKj+H0W4JkRoEX9pam4QZ86rXyaC/Bj9RDe2XvZTpEn
 LqAOYia32EgNKD1SBHfdw0UxARyf9Z96ush0F6Rtz2Xz6KNMYJlWSv5Jegx9QhmRPBcW
 Qj+A==
X-Gm-Message-State: AOAM531Fbcs25XPsHu0M4uatkApRBfk+ed3TOis+ns8OlpnU9neXA0Y3
 /dJwZvQYOs8EnpQQdqPo2phQ/vgCL8LhHUMnN9f24w==
X-Google-Smtp-Source: ABdhPJz6dQ6rswRLMTqEF/co3mfu4hP6KC+8VZXJ4JXSVMEzLfKDAkhk1BjgSwPXg6v5SheRe2OT4j27NPJlpyfAdpg=
X-Received: by 2002:a2e:b606:: with SMTP id r6mr21310707ljn.327.1618330074932; 
 Tue, 13 Apr 2021 09:07:54 -0700 (PDT)
MIME-Version: 1.0
References: <20210318051733.2544-1-sargun@sargun.me>
 <20210318051733.2544-2-sargun@sargun.me>
In-Reply-To: <20210318051733.2544-2-sargun@sargun.me>
From: Rodrigo Campos <rodrigo@kinvolk.io>
Date: Tue, 13 Apr 2021 18:07:18 +0200
Message-ID: <CACaBj2YNmjLarF+zMLghSHFiEGg9ZfcPXZ+9iS3qLPWd=7DreQ@mail.gmail.com>
Subject: Re: [PATCH 1/5] seccomp: Refactor notification handler to prepare for
 new semantics
To: Sargun Dhillon <sargun@sargun.me>
Cc: Giuseppe Scrivano <gscrivan@redhat.com>, Kees Cook <keescook@chromium.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 LKML <linux-kernel@vger.kernel.org>
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
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

VGhpcyBwYXRjaCBhbHNvIGZpeGVzIHRoZSBidWcgSSByZXBvcnRlZCBoZXJlOgpodHRwczovL2xv
cmUua2VybmVsLm9yZy9sa21sLzIwMjEwNDEzMTYwMTUxLjMzMDEtMS1yb2RyaWdvQGtpbnZvbGsu
aW8vVC8KCgoKLS0gClJvZHJpZ28gQ2FtcG9zCi0tLQpLaW52b2xrIEdtYkggfCBBZGFsYmVydHN0
ci42YSwgMTA5OTkgQmVybGluIHwgdGVsOiArNDkxNzU1NTg5MzY0Ckdlc2Now6RmdHNmw7xocmVy
L0RpcmVjdG9yczogQWxiYW4gQ3JlcXV5LCBDaHJpcyBLw7xobCwgSWFnbyBMw7NwZXogR2FsZWly
YXMKUmVnaXN0ZXJnZXJpY2h0L0NvdXJ0IG9mIHJlZ2lzdHJhdGlvbjogQW10c2dlcmljaHQgQ2hh
cmxvdHRlbmJ1cmcKUmVnaXN0ZXJudW1tZXIvUmVnaXN0cmF0aW9uIG51bWJlcjogSFJCIDE3MTQx
NCBCClVzdC1JRC1OdW1tZXIvVkFUIElEIG51bWJlcjogREUzMDIyMDcwMDAKX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KQ29udGFpbmVycyBtYWlsaW5nIGxp
c3QKQ29udGFpbmVyc0BsaXN0cy5saW51eC1mb3VuZGF0aW9uLm9yZwpodHRwczovL2xpc3RzLmxp
bnV4Zm91bmRhdGlvbi5vcmcvbWFpbG1hbi9saXN0aW5mby9jb250YWluZXJz
