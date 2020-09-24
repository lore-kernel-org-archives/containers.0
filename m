Return-Path: <SRS0=lkaS=DB=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F678C4346E
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 07:12:26 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id D54D5206C9
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 07:12:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="U7RM1C8n"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D54D5206C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 539592E0DB;
	Thu, 24 Sep 2020 07:12:25 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id sANS-ja+dEWY; Thu, 24 Sep 2020 07:12:24 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 2599A20493;
	Thu, 24 Sep 2020 07:12:24 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 0DD48C0889;
	Thu, 24 Sep 2020 07:12:24 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id A27BFC0051
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 07:12:22 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 9767D2E0D6
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 07:12:22 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id NYDQjc+S1o7J
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 07:12:21 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pg1-f193.google.com (mail-pg1-f193.google.com
 [209.85.215.193])
 by silver.osuosl.org (Postfix) with ESMTPS id 961DF20493
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 07:12:21 +0000 (UTC)
Received: by mail-pg1-f193.google.com with SMTP id d13so1347594pgl.6
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 00:12:21 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:in-reply-to;
 bh=JPyfajfaHq+r5oQ4+KHWAZ8VwhlnanG+Cg9XmXwcpuM=;
 b=U7RM1C8nWHiMvrUrOKOxP2OLNnkhNzx+5Xb+ZMQxUQlQ/k1EejiqZf9v+kTIPp+x+y
 CfUd2Msra+Iq6+48aOR+1uozXy3KUCJ65MrxIuN9LacgwDvrl040rvwOdje3uhosgFR8
 PHfcR07iK0OejM+M/srngdXt8hwsnJWfraF04=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:in-reply-to;
 bh=JPyfajfaHq+r5oQ4+KHWAZ8VwhlnanG+Cg9XmXwcpuM=;
 b=DbHVQ0rLL9xrOlo2X1/TiFHt4VKuA/VDyh2aIZEP3JfNbgt7+DH2Vco2L8ytr1oYhk
 OCZERGeYFfYZTk6JJaJR5WqoWXrBLtspgSA8C0tjbkc6L+NqhnV8M4HCVOA+wnxogXNj
 97kD4Pamxgnti0C6fa3pq1i5IKZc/21xxQG3hVajZai2VW258G6exFuj0a5tZYzyO09K
 YvcKG9j/C2IwJbxQzKWJfFCsEpcc7eg4LnQuHEh8E/cqymWRjIAzLUkjGr/vjgFOSx3h
 7Zwzs3Lre9onxmF0EkZUSiqygc4l0ZXFkT9scznXvbwAWvYgI5cTHoEZ63gm07hrHGMO
 03pA==
X-Gm-Message-State: AOAM530c3joi1V05jTK5asgsgUToEQ/MThTlgET6DSDsBL1mhMNAPvuD
 aZkQPBdAZCT0bSNG8a7O9sDMFQ==
X-Google-Smtp-Source: ABdhPJwKQNB8FoBf+r4HIrsajmVau41WjZYMbzcPpPcitAZ+Zh9hRnUXNOc1+32wdpHjUyTITaPkuQ==
X-Received: by 2002:a63:c20b:: with SMTP id b11mr2902014pgd.421.1600931541212; 
 Thu, 24 Sep 2020 00:12:21 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id n9sm1783640pgi.2.2020.09.24.00.12.20
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Thu, 24 Sep 2020 00:12:20 -0700 (PDT)
Date: Thu, 24 Sep 2020 00:12:19 -0700
From: Kees Cook <keescook@chromium.org>
To: Jann Horn <jannh@google.com>
Subject: Re: [PATCH 2/6] x86: Enable seccomp architecture tracking
Message-ID: <202009240011.A56710DC@keescook>
References: <20200923232923.3142503-1-keescook@chromium.org>
 <20200923232923.3142503-3-keescook@chromium.org>
 <CAG48ez1BXWdWA5zPzOD21bQ4RsHQ6bSDWR8soTkkNphJ=zdHWw@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CAG48ez1BXWdWA5zPzOD21bQ4RsHQ6bSDWR8soTkkNphJ=zdHWw@mail.gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>, Will Drewry <wad@chromium.org>,
 bpf <bpf@vger.kernel.org>, YiFei Zhu <yifeifz2@illinois.edu>,
 Linux API <linux-api@vger.kernel.org>,
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

On Thu, Sep 24, 2020 at 02:45:45AM +0200, Jann Horn wrote:
> On Thu, Sep 24, 2020 at 1:29 AM Kees Cook <keescook@chromium.org> wrote:
> > Provide seccomp internals with the details to calculate which syscall
> > table the running kernel is expecting to deal with. This allows for
> > efficient architecture pinning and paves the way for constant-action
> > bitmaps.
> [...]
> > diff --git a/arch/x86/include/asm/seccomp.h b/arch/x86/include/asm/seccomp.h
> [...]
> > +#ifdef CONFIG_X86_64
> [...]
> > +#else /* !CONFIG_X86_64 */
> > +# define SECCOMP_ARCH                                  AUDIT_ARCH_I386
> > +#endif
> 
> If we are on a 32-bit kernel, performing architecture number checks in
> the kernel is completely pointless, because we know that there is only
> a single architecture identifier under which syscalls can happen.
> 
> While this patch is useful for enabling the bitmap logic in the
> following patches, I think it adds unnecessary overhead in the context
> of the previous patch.

That's what the RFC was trying to do (avoid the logic if there is only a
single arch known to the kernel). I will rework this a bit harder. :)

-- 
Kees Cook
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
