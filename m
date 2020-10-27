Return-Path: <SRS0=DMKn=EC=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1598BC4363A
	for <containers@archiver.kernel.org>; Tue, 27 Oct 2020 19:14:59 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 5E31220756
	for <containers@archiver.kernel.org>; Tue, 27 Oct 2020 19:14:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="bUUyctzc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E31220756
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id E9F48863FF;
	Tue, 27 Oct 2020 19:14:57 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id sukaiYrJVewd; Tue, 27 Oct 2020 19:14:57 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 730B98641E;
	Tue, 27 Oct 2020 19:14:57 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 58A92C088B;
	Tue, 27 Oct 2020 19:14:57 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 57CDCC0051
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Oct 2020 19:14:56 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 3E5C38651C
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Oct 2020 19:14:56 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id dU5XIn6VkUYZ
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Oct 2020 19:14:55 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pl1-f195.google.com (mail-pl1-f195.google.com
 [209.85.214.195])
 by whitealder.osuosl.org (Postfix) with ESMTPS id A09A1869B9
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Oct 2020 19:14:55 +0000 (UTC)
Received: by mail-pl1-f195.google.com with SMTP id 1so1280596ple.2
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Oct 2020 12:14:55 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=from:to:cc:subject:date:message-id:in-reply-to:references
 :mime-version:content-transfer-encoding;
 bh=gV/VVwoohxFwknw5Qn01WhfBtKTfE0pEszhFmiVXe+4=;
 b=bUUyctzcMSA6GV80xlX1omAD5lD1Q6cPzFS+DHgg4vnT5jm2fUe+9kyTyf1UtGDex9
 e7+aXR4zgdP6JfIYXGGlXWxmD/enEyR76EowHH08WydLVpuwbGdyeqYD7pW7wyRu24Ni
 cTpdJdaLJrOKGJEyA3oq5BVxfJ0ac1hK5p9Ck=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
 :references:mime-version:content-transfer-encoding;
 bh=gV/VVwoohxFwknw5Qn01WhfBtKTfE0pEszhFmiVXe+4=;
 b=QLayW2FmjfGDbDlkIdCwuwGfUWEakfcPJo+tYlk1kVQtxi2y30rtOFELk9tL/OQBnL
 9kChBJvABMKEIkHRPvv4kBdAwDBmxo/lCR8FJdolwCJtJV/T7D3fi+gQSIZEjBdt5Wgs
 HImwgr05G3LAkU2BSKr/tyyIKKCZSvKaE0kK8Jn9N/XyfMx6uLvy+iunL0MPxtasf+2A
 hBBmA4diyw4ckQKCLfAjU+rEhfo254dYRcSJYIIqIAw6zqoC2RPbai26ldAMTY9lOsGv
 U1dkGrYS3ss6A+hybFZDya3H3FrncKIO9ebjJVeldE82Uvl1uZ1Mm1ozsJdzlyiVdLE/
 /gnA==
X-Gm-Message-State: AOAM5333dEE2W6nCasa5g5i7K7v1Z6fd5P5wztYWjPAPc/eOnQiEYZjX
 sblRMr7llhec6ZjZHL22+u3D9Q==
X-Google-Smtp-Source: ABdhPJyjtnpaZtReoire0YN/na6kS75vBmwzx3v3ddCq2YUxAsi++zqYgZgj/AIU9QAB6+bqwbbOtQ==
X-Received: by 2002:a17:902:6a8c:b029:d5:da81:dc42 with SMTP id
 n12-20020a1709026a8cb02900d5da81dc42mr3990687plk.40.1603826094485; 
 Tue, 27 Oct 2020 12:14:54 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id m3sm3052970pfd.217.2020.10.27.12.14.53
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Tue, 27 Oct 2020 12:14:53 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
To: YiFei Zhu <zhuyifei1999@gmail.com>, containers@lists.linux-foundation.org
Subject: Re: [PATCH v5 seccomp 0/5]seccomp: Add bitmap cache of constant allow
 filter results
Date: Tue, 27 Oct 2020 12:14:50 -0700
Message-Id: <160382601078.2318738.11754677445961373147.b4-ty@chromium.org>
X-Mailer: git-send-email 2.25.1
In-Reply-To: <cover.1602431034.git.yifeifz2@illinois.edu>
References: <cover.1602263422.git.yifeifz2@illinois.edu>
 <cover.1602431034.git.yifeifz2@illinois.edu>
MIME-Version: 1.0
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>, Will Drewry <wad@chromium.org>,
 Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>,
 YiFei Zhu <yifeifz2@illinois.edu>, linux-kernel@vger.kernel.org,
 Tobin Feldman-Fitzthum <tobin@ibm.com>, Hubertus Franke <frankeh@us.ibm.com>,
 Andy Lutomirski <luto@amacapital.net>, Valentin Rothberg <vrothber@redhat.com>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>,
 David Laight <David.Laight@aculab.com>, Jack Chen <jianyan2@illinois.edu>,
 Josep Torrellas <torrella@illinois.edu>, bpf@vger.kernel.org,
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

On Sun, 11 Oct 2020 10:47:41 -0500, YiFei Zhu wrote:
> Alternative: https://lore.kernel.org/lkml/20200923232923.3142503-1-keescook@chromium.org/T/
> 
> Major differences from the linked alternative by Kees:
> * No x32 special-case handling -- not worth the complexity
> * No caching of denylist -- not worth the complexity
> * No seccomp arch pinning -- I think this is an independent feature
> * The bitmaps are part of the filters rather than the task.
> 
> [...]

Applied to for-next/seccomp, thanks! I left off patch 5 for now until
we sort out the rest of the SECCOMP_FILTER architectures, and tweaked
patch 3 to include the architecture names.

[1/4] seccomp/cache: Lookup syscall allowlist bitmap for fast path
      https://git.kernel.org/kees/c/f94defb8bf46
[2/4] seccomp/cache: Add "emulator" to check if filter is constant allow
      https://git.kernel.org/kees/c/e7dc9f1e5f6b
[3/4] x86: Enable seccomp architecture tracking
      https://git.kernel.org/kees/c/1f68a4d393fe
[4/4] selftests/seccomp: Compare bitmap vs filter overhead
      https://git.kernel.org/kees/c/57a339117e52

-- 
Kees Cook

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
