Return-Path: <SRS0=lkaS=DB=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D598BC4363D
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 20:00:40 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id D830420B1F
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 20:00:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="avbGCQqM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D830420B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 47E9086AF4;
	Thu, 24 Sep 2020 20:00:39 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id etAha6zjSh0V; Thu, 24 Sep 2020 20:00:38 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id C73DB86AAB;
	Thu, 24 Sep 2020 20:00:38 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id B52C3C0859;
	Thu, 24 Sep 2020 20:00:38 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 2F052C0051
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 20:00:38 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 1A4BD86AAB
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 20:00:38 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id X2pAD5xWX-YS
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 20:00:37 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pg1-f194.google.com (mail-pg1-f194.google.com
 [209.85.215.194])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 6CA2686AF4
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 20:00:37 +0000 (UTC)
Received: by mail-pg1-f194.google.com with SMTP id k133so365285pgc.7
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 13:00:37 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:in-reply-to;
 bh=+MD2QubiwKdZDJzjnc2wAOK3dZyKxhcYOawuWHop+Wo=;
 b=avbGCQqM983qSOxtkvStgCWx9sRpEeKEGDHd9YWkndoou2/aH5siCielYiOMrMzduL
 Fe2noZykDUuGZ4LQR9NHfzh+YZq63h5jKJDfKza+jfdwvAziUO2yCVU35rzmrXXSDvW8
 Up/SO6HKiwkFMBN2H+97Gna9dqtcH5g3Y0HbI=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:in-reply-to;
 bh=+MD2QubiwKdZDJzjnc2wAOK3dZyKxhcYOawuWHop+Wo=;
 b=hALNjQEfSoqXLSisipkRA9lMS3X+nQHJX8QtaI7/oP9QoucVI6nIDn3nnXExa84Yy/
 WN9uLXvUyFqTi8cvycNfY6XsvMRfMGAt9C5JPaTQuDIoMHbxN4Yd0PoEwcaInBDPPHbG
 tQcyjJVScQ1VdPzY9KlOsG1lfTWFKm/NhC6X6+QWa6UDLk5kevLdYlHRFyjLCaenQ98A
 1zcoR4tj3o7JC03EIy7FNCJbucgrjzw4Z04dVRgGkIVcbgHHTBitbsC9ca4BYHvKJi6z
 tdJdzQN3je7fhKG42rsJcO/iKhhQgHk8r8TXT8HC6Kb/Go07HCihUF3jFNe7DMdIMSDQ
 NN4w==
X-Gm-Message-State: AOAM531FsyL478uzAI6mdj9EI4oxH1TPKA4iVUeYpXtadUXSJTuHx5RY
 n+Ww3es0polIJS5KTRJo1mWsUw==
X-Google-Smtp-Source: ABdhPJw+cepPZiirv+WRgNOWJCnEG6K3L6esLxka7Bt1UZlgbovFX+43wYSgm0HkhFGg9/Z7NbQHsw==
X-Received: by 2002:a63:1464:: with SMTP id 36mr606764pgu.160.1600977636906;
 Thu, 24 Sep 2020 13:00:36 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id c9sm295293pfn.78.2020.09.24.13.00.35
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Thu, 24 Sep 2020 13:00:35 -0700 (PDT)
Date: Thu, 24 Sep 2020 13:00:34 -0700
From: Kees Cook <keescook@chromium.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH v1 0/6] seccomp: Implement constant action bitmaps
Message-ID: <202009241253.7D238A4@keescook>
References: <20200923232923.3142503-1-keescook@chromium.org>
 <20200924185702.GA9225@redhat.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20200924185702.GA9225@redhat.com>
Cc: Giuseppe Scrivano <gscrivan@redhat.com>, Will Drewry <wad@chromium.org>,
 bpf@vger.kernel.org, Jann Horn <jannh@google.com>,
 YiFei Zhu <yifeifz2@illinois.edu>, linux-api@vger.kernel.org,
 containers@lists.linux-foundation.org, Tobin Feldman-Fitzthum <tobin@ibm.com>,
 Hubertus Franke <frankeh@us.ibm.com>, Andy Lutomirski <luto@amacapital.net>,
 Valentin Rothberg <vrothber@redhat.com>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>, Jack Chen <jianyan2@illinois.edu>,
 Josep Torrellas <torrella@illinois.edu>, Tianyin Xu <tyxu@illinois.edu>,
 linux-kernel@vger.kernel.org
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

On Thu, Sep 24, 2020 at 02:57:02PM -0400, Andrea Arcangeli wrote:
> Hello,
> 
> I'm posting this only for the record, feel free to ignore.
> 
> On Wed, Sep 23, 2020 at 04:29:17PM -0700, Kees Cook wrote:
> > rfc: https://lore.kernel.org/lkml/20200616074934.1600036-1-keescook@chromium.org/
> > alternative: https://lore.kernel.org/containers/cover.1600661418.git.yifeifz2@illinois.edu/
> > v1:
> > - rebase to for-next/seccomp
> > - finish X86_X32 support for both pinning and bitmaps
> 
> It's pretty clear the O(1) seccomp filter bitmap was first was
> proposed by your RFC in June (albeit it was located in the wrong place
> and is still in the wrong place in v1).
> 
> > - replace TLB magic with Jann's emulator
>     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
>     
> That's a pretty fundamental change in v1 compared to your the
> non-competing TLB magic technique you used in the RFC last June.
> 
> The bitmap isn't the clever part of the patch, the bitmap can be
> reviewed in seconds, the difficult part to implement and to review is
> how you fill the bitmap and in that respect there's absolutely nothing
> in common in between the "rfc:" and the "alternative" link.
> 
> In June your bitmap-filling engine was this:
> 
> https://lore.kernel.org/lkml/20200616074934.1600036-5-keescook@chromium.org/
> 
> Then on Sep 21 YiFei Zhu posted his new innovative BPF emulation
> innovation that obsoleted your TLB magic of June:
> 
> https://lists.linuxfoundation.org/pipermail/containers/2020-September/042153.html
> 
> And on Sep 23 instead of collaborating and helping YiFei Zhu to
> improve his BPF emulator, you posted the same technique that looks
> remarkably similar without giving YiFei Zhu any attribution and you
> instead attribute the whole idea to Jann Horn:
> 
> https://lkml.kernel.org/r/20200923232923.3142503-5-keescook@chromium.org

?? Because it IS literally Jann's code:
https://lore.kernel.org/lkml/CAG48ez1p=dR_2ikKq=xVxkoGg0fYpTBpkhJSv1w-6BG=76PAvw@mail.gmail.com/
As the first reply to 20200616074934.1600036-5-keescook@chromium.org. In
June. Which I agreed was the way to go. In June.

And When YiFei Zhu sent their series, I saw they were headed in
a direction that looked functionally similar, but significantly
over-engineered, and done without building on the June RFC and its
discussion. So I raised the priority of putting Jann's code in to the
RFC, so I could send out an update demonstrating both how small I would
like the emulator to be, and how to handle things like x32.

How, exactly, am I not collaborating? I was literally trying to
thread-merge and avoid (more) extra work on YiFei Zhu's end.

-- 
Kees Cook
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
