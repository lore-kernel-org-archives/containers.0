Return-Path: <SRS0=lkaS=DB=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6755C4363D
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 19:19:03 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 4564021D91
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 19:19:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=google.com header.i=@google.com header.b="nW6H9Ez9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4564021D91
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id D554D86B55;
	Thu, 24 Sep 2020 19:19:02 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id SQCmNgpUssXd; Thu, 24 Sep 2020 19:19:02 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 6C75F86AC4;
	Thu, 24 Sep 2020 19:19:02 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 4DB8BC0859;
	Thu, 24 Sep 2020 19:19:02 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id E1DA1C0051
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 19:19:01 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id C9424872FE
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 19:19:01 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 8wYCSNiQ+X0I
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 19:19:01 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-ej1-f66.google.com (mail-ej1-f66.google.com
 [209.85.218.66])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 02101872D6
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 19:19:00 +0000 (UTC)
Received: by mail-ej1-f66.google.com with SMTP id e23so343163eja.3
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 12:19:00 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=rL+0r4nsYsaTnfsp4nKpvqpdZr9u7FgIPOgyMKNt8zc=;
 b=nW6H9Ez9qPwsgMVuKmXTOIP47WKziOB7h4ORZWYHlPlZmcmBaz4bHW4IU2YbZsB5hb
 PKuFmofW4Zkf/3SgserbbqW7aN+s9iDgZbxr9QF0a+XDOyQauEYVVSL/KnakazhwL9D4
 UwrK4zx1t+sRU7ddaxgI/KYI1iAsm8WFKpkl5/8qG0kYIZDGGh7V/oUZv2AqOwFcMrap
 DSM8JWFJFnMD99cr4rEr96PRqnbogR9L4C448SM/gzvmeyrVEi1RWLhCxTScPIvkxccL
 bhyh0HeLsDXVkXxuvggdeni2CgIY8uiKUYP88tL+eo2IucDIcb5mZtmgFAHFmYwp06Dk
 cHcw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=rL+0r4nsYsaTnfsp4nKpvqpdZr9u7FgIPOgyMKNt8zc=;
 b=szoWfPOMrT+OHtWkc3HoNfwKiTOT0bGx+1flLjF59VltS0GUMIpqcpUVsm0+/MyZgz
 f40LEF+YDr4QfSTqJex9p7wC83Bcm0LKmJDOwrMtGGqWfD4nfn0Am9iMVSPDxz3nKw0j
 wSANX/ldU8FjpsO7MgNCfNrxveD1C0hCfZv8IZE2qv4SKzFgh3N08zvfN8b7/voVFOQx
 dmYpABUM2ObGmimkr1UX/xwRP5sXH4ZKdLnGyNeaLtBvtgr0e4Je58iPgOzJQPZkSnJA
 bm2IeDt5eLV1B4I8MMPrTvHxAWEW94Ggu+hRMREkhyajN3PDB3okfZgeKaY55SHX4GtH
 bP5w==
X-Gm-Message-State: AOAM531Sumq6znc+EouxdgEDtjL1niPDfv0d2tlaMsuoi+gO8Czgqrln
 GFfRHt0HqdMg/saD22Zpk5uDpSLbl2dW156OJZm3Ng==
X-Google-Smtp-Source: ABdhPJwH4eJsS5OWHswwTu13j7X710JhXzRLOlQI2ycEssSzTXiSAu4QWPI8Qvq2bTeAc49+G5jFwYQxPfgwyoykqVY=
X-Received: by 2002:a17:907:94cf:: with SMTP id
 dn15mr176599ejc.114.1600975139153; 
 Thu, 24 Sep 2020 12:18:59 -0700 (PDT)
MIME-Version: 1.0
References: <20200923232923.3142503-1-keescook@chromium.org>
 <20200924185702.GA9225@redhat.com>
In-Reply-To: <20200924185702.GA9225@redhat.com>
Date: Thu, 24 Sep 2020 21:18:32 +0200
Message-ID: <CAG48ez3s9u+5_Bd94CP97aqBBKzno1o2obpJPSdMnsHHkOd0qg@mail.gmail.com>
Subject: Re: [PATCH v1 0/6] seccomp: Implement constant action bitmaps
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Giuseppe Scrivano <gscrivan@redhat.com>, Will Drewry <wad@chromium.org>,
 Kees Cook <keescook@chromium.org>, YiFei Zhu <yifeifz2@illinois.edu>,
 Linux API <linux-api@vger.kernel.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 bpf <bpf@vger.kernel.org>, Tobin Feldman-Fitzthum <tobin@ibm.com>,
 Hubertus Franke <frankeh@us.ibm.com>, Andy Lutomirski <luto@amacapital.net>,
 Valentin Rothberg <vrothber@redhat.com>,
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
From: Jann Horn via Containers <containers@lists.linux-foundation.org>
Reply-To: Jann Horn <jannh@google.com>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

On Thu, Sep 24, 2020 at 8:57 PM Andrea Arcangeli <aarcange@redhat.com> wrote:
>
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

You're missing that I did suggest the BPF emulation approach (with
code very similar to Kees' current code) back in June:
https://lore.kernel.org/lkml/CAG48ez1p=dR_2ikKq=xVxkoGg0fYpTBpkhJSv1w-6BG=76PAvw@mail.gmail.com/
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
