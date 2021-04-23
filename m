Return-Path: <SRS0=gt/T=JU=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 291B0C433B4
	for <containers@archiver.kernel.org>; Fri, 23 Apr 2021 14:36:55 +0000 (UTC)
Received: from smtp2.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 8807861354
	for <containers@archiver.kernel.org>; Fri, 23 Apr 2021 14:36:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8807861354
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp2.osuosl.org (Postfix) with ESMTP id 2CA794063C;
	Fri, 23 Apr 2021 14:36:54 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp2.osuosl.org ([127.0.0.1])
	by localhost (smtp2.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id kbeTlGbN1lrp; Fri, 23 Apr 2021 14:36:53 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [IPv6:2605:bc80:3010:104::8cd3:938])
	by smtp2.osuosl.org (Postfix) with ESMTP id 0DA294061E;
	Fri, 23 Apr 2021 14:36:52 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id E7C02C000E;
	Fri, 23 Apr 2021 14:36:52 +0000 (UTC)
Received: from smtp4.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 279C7C000B
 for <containers@lists.linux-foundation.org>;
 Fri, 23 Apr 2021 14:36:52 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp4.osuosl.org (Postfix) with ESMTP id 20E7040517
 for <containers@lists.linux-foundation.org>;
 Fri, 23 Apr 2021 14:36:52 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Authentication-Results: smtp4.osuosl.org (amavisd-new);
 dkim=pass (2048-bit key) header.d=arista.com
Received: from smtp4.osuosl.org ([127.0.0.1])
 by localhost (smtp4.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id KnNtksv0u6kG
 for <containers@lists.linux-foundation.org>;
 Fri, 23 Apr 2021 14:36:50 +0000 (UTC)
X-Greylist: whitelisted by SQLgrey-1.8.0
Received: from mail-lf1-x133.google.com (mail-lf1-x133.google.com
 [IPv6:2a00:1450:4864:20::133])
 by smtp4.osuosl.org (Postfix) with ESMTPS id 965E1404D7
 for <containers@lists.linux-foundation.org>;
 Fri, 23 Apr 2021 14:36:50 +0000 (UTC)
Received: by mail-lf1-x133.google.com with SMTP id x19so47488385lfa.2
 for <containers@lists.linux-foundation.org>;
 Fri, 23 Apr 2021 07:36:50 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=arista.com; s=google;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=rGVMK1LPh9iIc+XnF1YdK9uGnLn1GjuOH4C0X7AWW18=;
 b=ibnNxKI5LWvzWd65BU2zvJQ3lZMkhb1LLEARrXo8fh/Rbz/rfSC6mIwVjEdsykK89c
 NejtsnaccVOuASPeR9gGFE5MPQzHaHKRgP5Y/pz0cOECwfTI0q8/0miB8rvnra9ZOCZ/
 ng1jnduShfGZAfZyFIY5f0GV9vDniT6Xx7XqgmFTLL7DqonI8SYoqhkDjdN5jfba7u7P
 PvQxVkNETEmcUxzBXMmpliJQJ97BhmLTKtJ+gTKzXfdKmCjPyMCQVNqlf/QSI6u/3aEi
 hksfL1C3NTyGLoxH+em122rqRRn3Wtx8Qdyo4zc0DE13g71NRdPskvQx8eSfOG4kIHrI
 AcoQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=rGVMK1LPh9iIc+XnF1YdK9uGnLn1GjuOH4C0X7AWW18=;
 b=GePZ9SzK7sEwSFEIHI0RDdlglklCptAQLSMyvEp6se4HqLxa5oWrH6EnuPrjrrcBfK
 EhHsSVUN6GlVpfkXgdRRwTaG+3//+vEoUVbYtPIAwsXpafnaJBwAMTBn03W+wWwGh7d5
 fElMsVZGlk8yg5UvWP3YG4p3RAjYJB7w5weFVMUbG2GYxacD5nhZ0STrVQuCfb1AELMM
 uhexsSGxax0AOyS8l57e/i2HQVEHawVzPCWpAwTd2NGoPje+6qUuUpzhFP8VSONca02x
 E/t8aapR22FVg2Deq1uVb2KWvMJcHP+r1EnDnYku0RoyT/qk2VQYtjG8+mF5V9V89sIH
 dZXg==
X-Gm-Message-State: AOAM533S6bzz749EO4UY1Hmgw3CT4RF43pdsbHtVcOgKpyZIon3rMAa5
 DNor5Pyda3s7rsLiYUQ7U9uk40yPqSG0MfWcYSD2NA==
X-Google-Smtp-Source: ABdhPJyP6Uu0qWuAegZYZDUSEd9xuSqzExELRiyoT5S0n936RRLzfq/8QcEhnek3SSimkfoYPYC2HuOLBQSjzbhGPSQ=
X-Received: by 2002:a19:7e97:: with SMTP id z145mr3212097lfc.280.1619188608499; 
 Fri, 23 Apr 2021 07:36:48 -0700 (PDT)
MIME-Version: 1.0
References: <87ft6act3c.fsf@redhat.com>
 <20210421172714.912119-1-snaipe@arista.com>
 <87h7jyvfsm.fsf@redhat.com>
In-Reply-To: <87h7jyvfsm.fsf@redhat.com>
Date: Fri, 23 Apr 2021 16:36:12 +0200
Message-ID: <CAK8sBDOfVKvv4V-0wzz6ZAsi0Gs6pPVDHhxg++RLgcdA5mmF3g@mail.gmail.com>
Subject: Re: LPC 2020 Hackroom Session: summary and next steps for isolated
 user namespaces
To: Giuseppe Scrivano <gscrivan@redhat.com>
Cc: Alexander Mihalicyn <alexander@mihalicyn.com>, jcsible@cert.org,
 Wat Lim <watl@google.com>, Kees Cook <keescook@chromium.org>,
 containers@lists.linux-foundation.org, josh@joshtriplett.org,
 vgoyal@redhat.com, linux-kernel@vger.kernel.org, cyphar@cyphar.com,
 ebiederm@xmission.com, mic@digikod.net, christian.brauner@ubuntu.com,
 luto@amacapital.net, mpatel@redhat.com, ptikhomirov@virtuozzo.com,
 geofft@ldpreload.com
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
From: =?UTF-8?B?RnJhbmtsaW4g4oCcU25haXBl4oCdIE1hdGhpZXU=?= via Containers
 <containers@lists.linux-foundation.org>
Reply-To: =?UTF-8?B?RnJhbmtsaW4g4oCcU25haXBl4oCdIE1hdGhpZXU=?=
 <snaipe@arista.com>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

On Thu, Apr 22, 2021 at 11:18 AM Giuseppe Scrivano <gscrivan@redhat.com> wrote:
> thanks for the feedback.  We are still facing the issue with rootless
> Podman, and these patches (listed here so you won't need to dig into archives):
>
> https://github.com/giuseppe/linux/commit/7e0701b389c497472d11fab8570c153a414050af
> https://github.com/giuseppe/linux/commit/1c5fe726346b216293a527719e64f34e6297f0c2
>
> would solve the issue for us as well and we can use setgroups within a
> user namespace in a safe way.
>
> Any comments on this approach?  Could we move forward with it?
>

I rebased and built your changes on top of v5.10, patched our tool to
burn "shadow" into /proc/self/setgroups, and it's working beautifully:

    $ id
    uid=1000(snaipe) gid=1000(snaipe) groups=1000(snaipe),998(wheel)

    $ bst grep . /proc/self/uid_map /proc/self/gid_map /proc/self/setgroups
    /proc/self/uid_map:         0       1000          1
    /proc/self/uid_map:         1     100000      65536
    /proc/self/gid_map:         0       1000          1
    /proc/self/gid_map:         1     100000      65536
    /proc/self/setgroups:shadow

    $ ls -l
    total 8
    drwxr-xr-x 2 root wheel 4096 Apr 23 14:18 allowed
    drwx---r-x 2 root wheel 4096 Apr 23 14:18 denied

    $ bst sh -c 'id; ls allowed denied'
    uid=0(root) gid=0(root) groups=0(root)
    allowed:
    ls: cannot open directory 'denied': Permission denied

    $ bst --groups 1 sh -c 'id; ls allowed denied'
    uid=0(root) gid=0(root) groups=0(root),1(daemon)
    allowed:
    ls: cannot open directory 'denied': Permission denied

-- 
Snaipe
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
