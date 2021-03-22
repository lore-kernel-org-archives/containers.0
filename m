Return-Path: <SRS0=6KGX=IU=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B38C1C433C1
	for <containers@archiver.kernel.org>; Mon, 22 Mar 2021 02:04:10 +0000 (UTC)
Received: from smtp3.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 335206192D
	for <containers@archiver.kernel.org>; Mon, 22 Mar 2021 02:04:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 335206192D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp3.osuosl.org (Postfix) with ESMTP id D031D605E6;
	Mon, 22 Mar 2021 02:04:09 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp3.osuosl.org ([127.0.0.1])
	by localhost (smtp3.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id SjDAioraqGbb; Mon, 22 Mar 2021 02:04:09 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp3.osuosl.org (Postfix) with ESMTP id E43BA605C5;
	Mon, 22 Mar 2021 02:04:08 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id CAFB8C000A;
	Mon, 22 Mar 2021 02:04:08 +0000 (UTC)
Received: from smtp2.osuosl.org (smtp2.osuosl.org [IPv6:2605:bc80:3010::133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 93740C0001
 for <containers@lists.linux-foundation.org>;
 Mon, 22 Mar 2021 02:04:06 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp2.osuosl.org (Postfix) with ESMTP id 6B06B4029F
 for <containers@lists.linux-foundation.org>;
 Mon, 22 Mar 2021 02:04:06 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Authentication-Results: smtp2.osuosl.org (amavisd-new);
 dkim=pass (1024-bit key) header.d=chromium.org
Received: from smtp2.osuosl.org ([127.0.0.1])
 by localhost (smtp2.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id AQY0A8Ya5Pe6
 for <containers@lists.linux-foundation.org>;
 Mon, 22 Mar 2021 02:04:05 +0000 (UTC)
X-Greylist: whitelisted by SQLgrey-1.8.0
Received: from mail-pg1-x52c.google.com (mail-pg1-x52c.google.com
 [IPv6:2607:f8b0:4864:20::52c])
 by smtp2.osuosl.org (Postfix) with ESMTPS id 3FF8F4029E
 for <containers@lists.linux-foundation.org>;
 Mon, 22 Mar 2021 02:04:05 +0000 (UTC)
Received: by mail-pg1-x52c.google.com with SMTP id o11so7621006pgs.4
 for <containers@lists.linux-foundation.org>;
 Sun, 21 Mar 2021 19:04:05 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=from:to:cc:subject:date:message-id:in-reply-to:references
 :mime-version:content-transfer-encoding;
 bh=x65YhMq/iIE/GtERdS4jdT1t3LPDIu95hEMHpqLewfQ=;
 b=XrTYv7S7ygcocSpP6b76OaPDTYkOI7KCPq5noz1URQ5UN2wYHWrpq7jNy0TJzxQDlT
 NmofbH+Ev4puboNp8o4V0J3FkTu+LguHsb41JsVdoEiTuXlkclSb0Nc7dfEVm9XW2K0f
 3sZ7tsQcgR/mOoHZQdMSPDvLIvj8Y2pQ2N/gM=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
 :references:mime-version:content-transfer-encoding;
 bh=x65YhMq/iIE/GtERdS4jdT1t3LPDIu95hEMHpqLewfQ=;
 b=PYy83DsnnxFV4Myp3Rurqz+wptIWB0rrn0+ldPDeIs5ZjYbjDi/7hykvbPFLfu9AQ6
 jLxxotygjZEnj4XVG8twJ1g3mTBxT94aEhvX0Jzq2wVo6V2AEAgVr4Rh0OISv5VZLpXt
 clTbICHDfytzuqxF2S+wZ9G5XFcfjMmV0fEUgrL6p5ce/i0t7b4/nI4gEqdhGWENEfaS
 zvaZ0jA9EjcMQBXVaE9WKbl1O6wXMZODSueBeW2Y5EJXVtelCmsE9XqkQ1hhm6j47TWo
 Q1IQ3YW+O0ShUhA0qP4684pkB739JwN2FAgNtd3/W9e/7S7FuJwFJBUoqFnxDc34kwDj
 1y3A==
X-Gm-Message-State: AOAM530nU3nXGHPacfRLAv1HXqYGCMqHG2l9X4VTGiWd+sTXWRXXEPMG
 zuZCNNT4xRwjjDTVXYWGJ14gtw==
X-Google-Smtp-Source: ABdhPJx83QBnIf0wj61XqsgP/x34LyD50kxnYCMCY7mstz/EnXTszo1slqBcQBUpu3OnflBed+k9Xg==
X-Received: by 2002:a63:4845:: with SMTP id x5mr19891695pgk.315.1616378644662; 
 Sun, 21 Mar 2021 19:04:04 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id e1sm11649000pjt.10.2021.03.21.19.04.03
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Sun, 21 Mar 2021 19:04:03 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
To: "Kenta.Tada@sony.com" <Kenta.Tada@sony.com>
Subject: Re: [PATCH] seccomp: fix the cond to report loaded filters
Date: Sun, 21 Mar 2021 19:03:29 -0700
Message-Id: <161637860542.4053241.2227340233601035129.b4-ty@chromium.org>
X-Mailer: git-send-email 2.25.1
In-Reply-To: <OSBPR01MB26772D245E2CF4F26B76A989F5669@OSBPR01MB2677.jpnprd01.prod.outlook.com>
References: <OSBPR01MB26772D245E2CF4F26B76A989F5669@OSBPR01MB2677.jpnprd01.prod.outlook.com>
MIME-Version: 1.0
Cc: amistry@google.com, samitolvanen@google.com, adobriyan@gmail.com,
 elver@google.com, Kees Cook <keescook@chromium.org>, paulmck@kernel.org,
 andreyknvl@google.com, rostedt@goodmis.org, shorne@gmail.com, axboe@kernel.dk,
 michael.weiss@aisec.fraunhofer.de, wad@chromium.org,
 containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
 luto@amacapital.net, ebiederm@xmission.com, a.darwish@linutronix.de,
 linux-fsdevel@vger.kernel.org, rppt@kernel.org
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

On Sun, 21 Mar 2021 15:52:19 +0000, Kenta.Tada@sony.com wrote:
> Strictly speaking, seccomp filters are only used
> when CONFIG_SECCOMP_FILTER.
> This patch fixes the condition to enable "Seccomp_filters"
> in /proc/$pid/status.

Applied to for-next/seccomp, thanks!

[1/1] seccomp: fix the cond to report loaded filters
      https://git.kernel.org/kees/c/15a2fd51384a

-- 
Kees Cook

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
