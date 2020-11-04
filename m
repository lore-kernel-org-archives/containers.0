Return-Path: <SRS0=KLId=EK=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1FA5FC388F7
	for <containers@archiver.kernel.org>; Wed,  4 Nov 2020 22:14:15 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 823932074B
	for <containers@archiver.kernel.org>; Wed,  4 Nov 2020 22:14:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="RX2JBijV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 823932074B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id C3F54854E0;
	Wed,  4 Nov 2020 22:14:13 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id MHRsHHb0i2m5; Wed,  4 Nov 2020 22:14:12 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id F422C84FA5;
	Wed,  4 Nov 2020 22:14:11 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id DC81EC08A1;
	Wed,  4 Nov 2020 22:14:11 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id AA146C0051
 for <containers@lists.linux-foundation.org>;
 Wed,  4 Nov 2020 22:14:10 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 97704871FA
 for <containers@lists.linux-foundation.org>;
 Wed,  4 Nov 2020 22:14:10 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 5YHnD+XC2Nke
 for <containers@lists.linux-foundation.org>;
 Wed,  4 Nov 2020 22:14:10 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pf1-f178.google.com (mail-pf1-f178.google.com
 [209.85.210.178])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 1551687115
 for <containers@lists.linux-foundation.org>;
 Wed,  4 Nov 2020 22:14:10 +0000 (UTC)
Received: by mail-pf1-f178.google.com with SMTP id 10so18493846pfp.5
 for <containers@lists.linux-foundation.org>;
 Wed, 04 Nov 2020 14:14:10 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:in-reply-to;
 bh=4SX8JmQlcxK5oX4LLeWbxpL7OAoTDYcCU+6+RVvGYlM=;
 b=RX2JBijVQFv1L+Mod4nyguYVc83aMkdQnTSA4fshKUc7aV23uLUvF08QHDh0Is4Pqc
 Y8C7u7YARCq/nsAwL8gHMGWDjRZ/i8rf6teR9z+sDJZUgLYQtq2wJ0I48zHOVm1zkNrf
 ta1xYjO+dpWNT4NcIGfE2jZIbJ6ZSCtbIauIs=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:in-reply-to;
 bh=4SX8JmQlcxK5oX4LLeWbxpL7OAoTDYcCU+6+RVvGYlM=;
 b=VLpQwbTCm6amGEzJIbMcbgg6KMUqZ3UVU1GBPI21xJZWz9cnN6iSZboQiNO4YprahE
 bhXvfJR2CTm6PPGEWPxNAH+aM/UJbGPJuLi/tEfhpHeuh6htmMux0MeIM3MkEUs2WuPa
 KgcCTgo9xrXcgcFBTR5Et9heQvccIYjYizEejNwmV+jMhd7BgMcAg95eL/+ckpJpPGtb
 Q7YFGq/3QVV4KWq28kI5IXpKKuQWaxVF9zSCQGIDoHxYUiMaJfp0FbuIAwZIhSV4fLCs
 j5Ao0H/1MZ4d1kBDVBKXIGdrdnL9emdUi52yrhbD4pSw+VHUUXcWEwrR0pg9WL6Wgwd3
 LdaQ==
X-Gm-Message-State: AOAM5328rOeGVCqJrIKct5t6NJ7d0JtGUEIJ6wTLrhop9LQoK6rPd4am
 a5xflndrGvrY6iJQds8X+E0YGw==
X-Google-Smtp-Source: ABdhPJwnQvdrXkvZA4YnhjXoMmBDm+dt32SsDETknXAd989qVmGT8ZvBz6SW/KD78kJNz8WtONYvwA==
X-Received: by 2002:a17:90b:b12:: with SMTP id
 bf18mr11114pjb.205.1604528049604; 
 Wed, 04 Nov 2020 14:14:09 -0800 (PST)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id j20sm3306738pgh.15.2020.11.04.14.14.08
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Wed, 04 Nov 2020 14:14:08 -0800 (PST)
Date: Wed, 4 Nov 2020 14:14:07 -0800
From: Kees Cook <keescook@chromium.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: RFC: default to spec_store_bypass_disable=prctl
 spectre_v2_user=prctl
Message-ID: <202011041411.AD961737EA@keescook>
References: <20201104215702.GG24993@redhat.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20201104215702.GG24993@redhat.com>
Cc: Tobin Feldman-Fitzthum <tobin@ibm.com>,
 Hubertus Franke <frankeh@us.ibm.com>, Jack Chen <jianyan2@illinois.edu>,
 Giuseppe Scrivano <gscrivan@redhat.com>, YiFei Zhu <yifeifz2@illinois.edu>,
 Waiman Long <longman@redhat.com>, Tianyin Xu <tyxu@illinois.edu>,
 Jann Horn <jannh@google.com>, Jiri Kosina <jikos@kernel.org>,
 Valentin Rothberg <vrothber@redhat.com>,
 Josep Torrellas <torrella@illinois.edu>, Thomas Gleixner <tglx@linutronix.de>,
 Will Drewry <wad@chromium.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 kernel list <linux-kernel@vger.kernel.org>,
 Andy Lutomirski <luto@amacapital.net>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>,
 David Laight <David.Laight@aculab.com>, bpf <bpf@vger.kernel.org>
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

On Wed, Nov 04, 2020 at 04:57:02PM -0500, Andrea Arcangeli wrote:
> Switch the kernel default of SSBD and STIBP to the ones with
> CONFIG_SECCOMP=n (i.e. spec_store_bypass_disable=prctl
> spectre_v2_user=prctl) even if CONFIG_SECCOMP=y.

Agreed. I think this is the right time to flip this switch. I agree with
the (very well described) rationales. :)

Fundamentally, likely everyone who is interested in manipulating the
mitigations are doing so now, and it doesn't make sense (on many fronts)
to tie some to seccomp mode any more (which was intended as a temporary
defense to gain coverage while sysadmins absorbed what the best
practices should be).

Thanks for sending this!

Acked-by: Kees Cook <keescook@chromium.org>

-- 
Kees Cook
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
