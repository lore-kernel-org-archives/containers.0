Return-Path: <SRS0=lkaS=DB=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 99A6BC4727E
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 19:14:35 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id DC99B21D91
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 19:14:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="hUuL9B2L"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC99B21D91
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 540782039A;
	Thu, 24 Sep 2020 19:14:34 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id lNg0iKchO6Pt; Thu, 24 Sep 2020 19:14:33 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id CA32D2048B;
	Thu, 24 Sep 2020 19:14:33 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id A4AB4C0859;
	Thu, 24 Sep 2020 19:14:33 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 9F745C0051
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 19:14:31 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 7CD5E20534
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 19:14:31 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id KkmT7i+iTzDr
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 19:14:24 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pj1-f66.google.com (mail-pj1-f66.google.com
 [209.85.216.66])
 by silver.osuosl.org (Postfix) with ESMTPS id 3A2E12039A
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 19:14:22 +0000 (UTC)
Received: by mail-pj1-f66.google.com with SMTP id jw11so272116pjb.0
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 12:14:22 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=from:to:cc:subject:date:message-id:in-reply-to:references
 :mime-version:content-transfer-encoding;
 bh=nYNQfolVzk1vZsWuLLwjSWbS4j2EWyO6uHCWvWRZVeg=;
 b=hUuL9B2LljZoDiYX/vccdvchsfVW3zD0frsCzdluTXClpc8C2HXET+CAJvamf8MLKq
 QFr9vs2aHQNF5XdI/+Bv2dvZtzG8BKQrL9vMYaLUbZqz/gjss7JyVTBH0Mqt5be7chwc
 g3EHPYVjMh1V4WMwfy14LT7tos0fxp4yVfkVQ=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
 :references:mime-version:content-transfer-encoding;
 bh=nYNQfolVzk1vZsWuLLwjSWbS4j2EWyO6uHCWvWRZVeg=;
 b=QoXROqVXk4C/eWT8Y/z7FjO8DqU3w2j5vGPWWdVP/TSfMJBjjGRxwfQl8ZfNsGDg0v
 j8NNhEgP9GVyTi5MrIF7xs/LVXF6JaV1hR5rH+WusZyHwLW+f39bWqqKoUhHFd6uw0Yp
 u4EKSh4eqY+TScT8gLVKdN4J8eLd+zvLh/XIDR8qrCPY3QcWA4K2XYNzrn3yxPxRb1hS
 oUc9M8PpqWWKw8cki1T3VfDL2WRW1EvikcXMR5s5SIWnvvRiQljVlzuzBRI4uTXiUPKU
 7Zwwerk16Hc0RI7Jfo1YIHOCAdIEY9mE/KXql1NMHK0g8X2KOYDs4vPvVL5xmfvqcxWx
 1X6g==
X-Gm-Message-State: AOAM532WLyGH6l/dSDwcpPkXBoP68+gmmWODi5mVa0G3VXj59nu/3WFC
 +Z1NbmnwpLr/K+i7whbYArAoIQ==
X-Google-Smtp-Source: ABdhPJzCOkXIw+4aHc3ITiPqTIKrHpD3nBHPrufYSJk0Eo6cGU3fq7XJIKl/Iks+YT9V1uuYNnr2ag==
X-Received: by 2002:a17:90a:178e:: with SMTP id
 q14mr415155pja.154.1600974861729; 
 Thu, 24 Sep 2020 12:14:21 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id m25sm249209pfa.32.2020.09.24.12.14.20
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Thu, 24 Sep 2020 12:14:20 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
To: containers@lists.linux-foundation.org, YiFei Zhu <zhuyifei1999@gmail.com>
Subject: Re: [PATCH v2 seccomp 1/6] seccomp: Move config option SECCOMP to
 arch/Kconfig
Date: Thu, 24 Sep 2020 12:11:28 -0700
Message-Id: <160097467791.3774715.6342246806292251250.b4-ty@chromium.org>
X-Mailer: git-send-email 2.25.1
In-Reply-To: <9ede6ef35c847e58d61e476c6a39540520066613.1600951211.git.yifeifz2@illinois.edu>
References: <9ede6ef35c847e58d61e476c6a39540520066613.1600951211.git.yifeifz2@illinois.edu>
MIME-Version: 1.0
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>, Will Drewry <wad@chromium.org>,
 Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>,
 YiFei Zhu <yifeifz2@illinois.edu>, Tobin Feldman-Fitzthum <tobin@ibm.com>,
 Hubertus Franke <frankeh@us.ibm.com>, linux-kernel@vger.kernel.org,
 Valentin Rothberg <vrothber@redhat.com>, Jack Chen <jianyan2@illinois.edu>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>,
 Josep Torrellas <torrella@illinois.edu>, bpf@vger.kernel.org,
 Andy Lutomirski <luto@amacapital.net>, Tianyin Xu <tyxu@illinois.edu>
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

On Thu, 24 Sep 2020 07:44:15 -0500, YiFei Zhu wrote:
> In order to make adding configurable features into seccomp
> easier, it's better to have the options at one single location,
> considering easpecially that the bulk of seccomp code is
> arch-independent. An quick look also show that many SECCOMP
> descriptions are outdated; they talk about /proc rather than
> prctl.
> 
> As a result of moving the config option and keeping it default
> on, architectures arm, arm64, csky, riscv, sh, and xtensa
> did not have SECCOMP on by default prior to this and SECCOMP will
> be default in this change.
> 
> Architectures microblaze, mips, powerpc, s390, sh, and sparc
> have an outdated depend on PROC_FS and this dependency is removed
> in this change.
> 
> Suggested-by: Jann Horn <jannh@google.com>
> Link: https://lore.kernel.org/lkml/CAG48ez1YWz9cnp08UZgeieYRhHdqh-ch7aNwc4JRBnGyrmgfMg@mail.gmail.com/
> Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>
> [...]

Yes; I've been meaning to do this for a while now. Thank you! I tweaked
the help text a bit.

Applied, thanks!

[1/1] seccomp: Move config option SECCOMP to arch/Kconfig
      https://git.kernel.org/kees/c/c3c9c2df3636

-- 
Kees Cook

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
