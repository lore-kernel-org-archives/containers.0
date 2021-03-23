Return-Path: <SRS0=cSyT=IV=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_RED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3CBCC433C1
	for <containers@archiver.kernel.org>; Tue, 23 Mar 2021 17:25:45 +0000 (UTC)
Received: from smtp4.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 88FB46157E
	for <containers@archiver.kernel.org>; Tue, 23 Mar 2021 17:25:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 88FB46157E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kinvolk.io
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp4.osuosl.org (Postfix) with ESMTP id 44D48404CD;
	Tue, 23 Mar 2021 17:25:45 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp4.osuosl.org ([127.0.0.1])
	by localhost (smtp4.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id pEYTOxjEtZP4; Tue, 23 Mar 2021 17:25:44 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [IPv6:2605:bc80:3010:104::8cd3:938])
	by smtp4.osuosl.org (Postfix) with ESMTP id 1BEBC404D5;
	Tue, 23 Mar 2021 17:25:44 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id E7375C000A;
	Tue, 23 Mar 2021 17:25:43 +0000 (UTC)
Received: from smtp2.osuosl.org (smtp2.osuosl.org [IPv6:2605:bc80:3010::133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 0CCBEC0001
 for <containers@lists.linux-foundation.org>;
 Tue, 23 Mar 2021 17:25:43 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp2.osuosl.org (Postfix) with ESMTP id E88D0400BD
 for <containers@lists.linux-foundation.org>;
 Tue, 23 Mar 2021 17:25:42 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Authentication-Results: smtp2.osuosl.org (amavisd-new);
 dkim=pass (1024-bit key) header.d=kinvolk.io
Received: from smtp2.osuosl.org ([127.0.0.1])
 by localhost (smtp2.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id gSinJZyxhFJD
 for <containers@lists.linux-foundation.org>;
 Tue, 23 Mar 2021 17:25:41 +0000 (UTC)
X-Greylist: whitelisted by SQLgrey-1.8.0
Received: from mail-lj1-x234.google.com (mail-lj1-x234.google.com
 [IPv6:2a00:1450:4864:20::234])
 by smtp2.osuosl.org (Postfix) with ESMTPS id 700EB400B8
 for <containers@lists.linux-foundation.org>;
 Tue, 23 Mar 2021 17:25:41 +0000 (UTC)
Received: by mail-lj1-x234.google.com with SMTP id z25so26644235lja.3
 for <containers@lists.linux-foundation.org>;
 Tue, 23 Mar 2021 10:25:41 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kinvolk.io; s=google;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=EWdPct9cnLJsI959oK8DsHeHnHswNFLX0BJgKrbG4+g=;
 b=aA4B8rBGrnJNMFum2qZ7SSYyJVSoErc0024LO2diJI7yElMidscSDuKODkJ1yYHIE4
 SyvbH7YtKx6jVynFc6BLJmFciPFYWJr5FNAFUmXuQG3dnyeIxG1PE9uvCKsd7ogUPOZf
 wpJQF+yf73A103SKtMRun38UBNilYgEyaUjRU=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=EWdPct9cnLJsI959oK8DsHeHnHswNFLX0BJgKrbG4+g=;
 b=g5MouMht8dPTuWhhsJllAnu81ZJ2wWyiBXBPsUSzDv/6Sx/M429QH/ivFx4murbUas
 aPfjbXqfJspB82v6VFlwpy7fLOB8l2LBDwkeQqtZHAcRvygs5DJfaKxnmC8BmbkvXzCy
 QcwX2whBCqiuW/BBvLPmBS2N0JITZ7KJIoho3GitjGJ9B/gB/EGwjt/Qajku9q7zTjsK
 XhrRc7d/+sRu7J9nx+NQRoiIWcH8Lq+9bdcGjkBh4a+Cpt/dTEPLgzcOqkRx7IBYRejV
 JqTZRXzv/5g+td1kSig4iTxPIOi7MJaaUNXSWDKD5KvZsNPbQGIVGmMGRLuo/wiilNJI
 gFkQ==
X-Gm-Message-State: AOAM533pHhHw0+NTO/3YZAgSUPUp858zH5XYtL2kTyvLoNU/y73eelGR
 pXDqOp87Nejkw+X0l0tVKkPvR7MoJlV9gZaL8QYqkQ==
X-Google-Smtp-Source: ABdhPJy3UjHPGBYeVxg3ixK7Te1OIpI5Z0XaZM9/eD5lfjSb/5bUKza6knwrjWvqyinaK0afPuMDAASodMokarlTtQA=
X-Received: by 2002:a2e:9793:: with SMTP id y19mr3649338lji.374.1616520339246; 
 Tue, 23 Mar 2021 10:25:39 -0700 (PDT)
MIME-Version: 1.0
References: <20210318051726.2488-1-sargun@sargun.me>
In-Reply-To: <20210318051726.2488-1-sargun@sargun.me>
From: Rodrigo Campos <rodrigo@kinvolk.io>
Date: Tue, 23 Mar 2021 18:25:03 +0100
Message-ID: <CACaBj2bxYks-6zOwfzDq_0B0UqgxTY74psp4PCz78jbxqhKVJQ@mail.gmail.com>
Subject: Re: [PATCH 0/5] Handle seccomp notification preemption
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
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

On Thu, Mar 18, 2021 at 6:17 AM Sargun Dhillon <sargun@sargun.me> wrote:
> Changes since v1[1]:
>  * Fix some documentation
>  * Add Rata's patches to allow for direct return from addfd
>
> [1]: https://lore.kernel.org/lkml/20210220090502.7202-1-sargun@sargun.me/
> [2]: https://lore.kernel.org/lkml/202012011322.26DCBC64F2@keescook/
>
> Rodrigo Campos (1):
>   seccomp: Support atomic "addfd + send reply"
>
> Sargun Dhillon (4):
>   seccomp: Refactor notification handler to prepare for new semantics
>   seccomp: Add wait_killable semantic to seccomp user notifier
>   selftests/seccomp: Add test for wait killable notifier
>   selftests/seccomp: Add test for atomic addfd+send

Friendly ping. Any review comments on these patches? :)
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
