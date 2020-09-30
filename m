Return-Path: <SRS0=U9nl=DH=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D89CC4363D
	for <containers@archiver.kernel.org>; Wed, 30 Sep 2020 22:54:00 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id F0B8F20719
	for <containers@archiver.kernel.org>; Wed, 30 Sep 2020 22:53:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="dJSvn+nV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F0B8F20719
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 74BD8868A8;
	Wed, 30 Sep 2020 22:53:59 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id El3nQDjJSIXq; Wed, 30 Sep 2020 22:53:58 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id A89A8855D8;
	Wed, 30 Sep 2020 22:53:58 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 9B76EC016F;
	Wed, 30 Sep 2020 22:53:58 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 05CB8C0051
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 22:53:58 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 00ABD87232
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 22:53:58 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id XDCD7dRiL7Dd
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 22:53:57 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pj1-f65.google.com (mail-pj1-f65.google.com
 [209.85.216.65])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 564A68722F
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 22:53:57 +0000 (UTC)
Received: by mail-pj1-f65.google.com with SMTP id t7so767786pjd.3
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 15:53:57 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:in-reply-to;
 bh=xT7z4KWpY1tW0DUzf7kauPlyM86hsIyuR+DbyM/kIF4=;
 b=dJSvn+nVMHOhyyebiONq5L1qo38q1OX51JVgtEQrhaCb9Ko8DFOcatX2GGKv2OpzZr
 sIvN3Ky6KPhHJRJx//ba2NE4yw/9fp3TyA2uoDw7vHOSexKqne+cqwQpImU41Lyz31Bo
 HucnSHirKztZuVWWFld/RQCHHttbmiGQcpaww=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:in-reply-to;
 bh=xT7z4KWpY1tW0DUzf7kauPlyM86hsIyuR+DbyM/kIF4=;
 b=orPYVSb2sjw8C3fyLJRGesnFt5/H8hPC+hBpNjfU1vDCQl/6tos5UJ+mkVI3uVogo1
 bKez1kG64TFFQmXAGOkdECCMkBscpmO9JyHBM+bVSmmhCC0BLbhYQr+xvbHW5QRGllyU
 0kJRvWrnNSQSAPqBrIvkJmx+IIdtu5fwBZLO0dCrA6j/9mrjQCOCZgmLMi//wcfQh/15
 psZWP8+hOji3PNEexSN7r61it/5ap7I1fNmieEeVOmXIGP9ndPcwF6ltDlUAXY0l26r2
 Ho/R2zCLD200Vk3QvrvvcKIhhLcD0bOPkkC1+i3+7/WDglsdStLCvYV2xzAyIAa8Y6Wh
 1Y/g==
X-Gm-Message-State: AOAM532BLWOXV7pNDILfyzSJCD0x9Me9Hoh5X+pU9Ctm0MN//x8QQFIP
 lMOcu6anZG11GY7ZUjAcy6XdAg==
X-Google-Smtp-Source: ABdhPJym9XGRJgUPD0aK76nCGJgVfLs8G5aI0UXZOOiThurScckwIjdLNnP4Mp59y5rMZ/XCz74uUA==
X-Received: by 2002:a17:90b:ecf:: with SMTP id
 gz15mr4360289pjb.126.1601506436994; 
 Wed, 30 Sep 2020 15:53:56 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id 1sm3974626pfx.126.2020.09.30.15.53.55
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Wed, 30 Sep 2020 15:53:56 -0700 (PDT)
Date: Wed, 30 Sep 2020 15:53:55 -0700
From: Kees Cook <keescook@chromium.org>
To: Jann Horn <jannh@google.com>
Subject: Re: [PATCH v3 seccomp 1/5] x86: Enable seccomp architecture tracking
Message-ID: <202009301549.17D3DE5@keescook>
References: <cover.1601478774.git.yifeifz2@illinois.edu>
 <484392624b475cc25d90a787525ede70df9f7d51.1601478774.git.yifeifz2@illinois.edu>
 <202009301418.20BA0CE33@keescook>
 <CAG48ez3039B+w_D7SJBaGGXw9sd1_SzWO+qUnhMs6tcweGa-+w@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CAG48ez3039B+w_D7SJBaGGXw9sd1_SzWO+qUnhMs6tcweGa-+w@mail.gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, YiFei Zhu <yifeifz2@illinois.edu>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>,
 kernel list <linux-kernel@vger.kernel.org>,
 Andy Lutomirski <luto@amacapital.net>, Hubertus Franke <frankeh@us.ibm.com>,
 David Laight <David.Laight@aculab.com>, Jack Chen <jianyan2@illinois.edu>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>,
 Josep Torrellas <torrella@illinois.edu>, Will Drewry <wad@chromium.org>,
 bpf <bpf@vger.kernel.org>, Tianyin Xu <tyxu@illinois.edu>
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

On Wed, Sep 30, 2020 at 11:33:15PM +0200, Jann Horn wrote:
> On Wed, Sep 30, 2020 at 11:21 PM Kees Cook <keescook@chromium.org> wrote:
> > On Wed, Sep 30, 2020 at 10:19:12AM -0500, YiFei Zhu wrote:
> > > From: Kees Cook <keescook@chromium.org>
> > >
> > > Provide seccomp internals with the details to calculate which syscall
> > > table the running kernel is expecting to deal with. This allows for
> > > efficient architecture pinning and paves the way for constant-action
> > > bitmaps.
> > >
> > > Signed-off-by: Kees Cook <keescook@chromium.org>
> > > [YiFei: Removed x32, added macro for nr_syscalls]
> > > Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>
> [...]
> > But otherwise, yes, looks good to me. For this patch, I think the S-o-b chain is probably more
> > accurately captured as:
> >
> > Signed-off-by: Kees Cook <keescook@chromium.org>
> > Co-developed-by: YiFei Zhu <yifeifz2@illinois.edu>
> > Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>
> 
> (Technically, https://www.kernel.org/doc/html/latest/process/submitting-patches.html#when-to-use-acked-by-cc-and-co-developed-by
> says that "every Co-developed-by: must be immediately followed by a
> Signed-off-by: of the associated co-author" (and has an example of how
> that should look).)

Right, but it is not needed for the commit author (here, the From:),
the second example given in the docs shows this:

	From: From Author <from@author.example.org>

	<changelog>

	Co-developed-by: Random Co-Author <random@coauthor.example.org>
	Signed-off-by: Random Co-Author <random@coauthor.example.org>
	Signed-off-by: From Author <from@author.example.org>
	Co-developed-by: Submitting Co-Author <sub@coauthor.example.org>
	Signed-off-by: Submitting Co-Author <sub@coauthor.example.org>

and there is no third co-developer, so it's:

	From: From Author <from@author.example.org>

	<changelog>

	Signed-off-by: From Author <from@author.example.org>
	Co-developed-by: Submitting Co-Author <sub@coauthor.example.org>
	Signed-off-by: Submitting Co-Author <sub@coauthor.example.org>

If I'm the From, and YiFei Zhu is the submitting co-developer, then
it's:

	From: Kees Cook <keescook@chromium.org>

	<changelog>

	Signed-off-by: Kees Cook <keescook@chromium.org>
	Co-developed-by: YiFei Zhu <yifeifz2@illinois.edu>
	Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>

which is what I suggested.

-- 
Kees Cook
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
