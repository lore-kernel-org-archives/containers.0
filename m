Return-Path: <SRS0=0vdS=HJ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3DB87C433DB
	for <containers@archiver.kernel.org>; Sun,  7 Feb 2021 23:56:01 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id ADF2A64E31
	for <containers@archiver.kernel.org>; Sun,  7 Feb 2021 23:56:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ADF2A64E31
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 84E1986F7E;
	Sun,  7 Feb 2021 23:56:00 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id oF9TUfG9WGsg; Sun,  7 Feb 2021 23:55:59 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 5CCF286E5B;
	Sun,  7 Feb 2021 23:55:59 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 41FEDC0891;
	Sun,  7 Feb 2021 23:55:59 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id D96D4C013A
 for <containers@lists.linux-foundation.org>;
 Sun,  7 Feb 2021 23:55:58 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id CE7EB864C5
 for <containers@lists.linux-foundation.org>;
 Sun,  7 Feb 2021 23:55:58 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id FdD11kWStokW
 for <containers@lists.linux-foundation.org>;
 Sun,  7 Feb 2021 23:55:58 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 55E5A86429
 for <containers@lists.linux-foundation.org>;
 Sun,  7 Feb 2021 23:55:58 +0000 (UTC)
Received: by mail.kernel.org (Postfix) with ESMTPSA id 662B664E2E;
 Sun,  7 Feb 2021 23:55:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
 s=k20201202; t=1612742157;
 bh=HWyvZKJfjuWNmgzJfzyCnofu5H0oIg85cEfM9lGL4SU=;
 h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
 b=IdpTmVHY3NCYvqqLAz9bhRn3sTzyMPSe6DYyrkHOfhhowSOUmukC7P28nIR4vIyiK
 17VlzLCWpG66x8KpzLyEK28MH41sWFm2H6cvjLdICIQbeu80wsOO7zskgPYuepPCyw
 LvflBy5gwoq/9amDk3wwq+SOXKH4nZuWXi4hHoXIsDD5ECuenkJ8k9s3k0HcUrvFo8
 yhoj2MocnwOC+DsYVeqk4m6i3bp2AEkRFzbkeBEALvxZzVgXE3dOD2z5ac4WCZn3kg
 3WOBmwnXIWs4Ud9Fj6ynXAYEWt5KWqO9hCEUlprK/wF86eYS2TZ504QR7lUs5boYGO
 uZuMezGm13kXA==
Date: Mon, 8 Feb 2021 01:55:49 +0200
From: Jarkko Sakkinen <jarkko@kernel.org>
To: David Howells <dhowells@redhat.com>, mchehab+huawei@kernel.org
Subject: Re: [PATCH 1/2] Add namespace tags that can be used for matching
 without pinning a ns
Message-ID: <YCB+BRp7WIa8YoO3@kernel.org>
References: <YByxkDi0Ruhb0AA8@kernel.org>
 <161246085160.1990927.13137391845549674518.stgit@warthog.procyon.org.uk>
 <161246085966.1990927.2555272056564793056.stgit@warthog.procyon.org.uk>
 <2094924.1612513535@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <2094924.1612513535@warthog.procyon.org.uk>
Cc: selinux@vger.kernel.org, linux-api@vger.kernel.org,
 containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
 linux-security-module@vger.kernel.org, keyrings@vger.kernel.org,
 sprabhu@redhat.com, linux-fsdevel@vger.kernel.org, christian@brauner.io
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

On Fri, Feb 05, 2021 at 08:25:35AM +0000, David Howells wrote:
> Jarkko Sakkinen <jarkko@kernel.org> wrote:
> 
> > > + * init_ns_common - Initialise the common part of a namespace
> > 
> > Nit: init_ns_common()
> 
> Interesting.  The majority of code doesn't put the brackets in.
> 
> > I've used lately (e.g. arch/x86/kernel/cpu/sgx/ioctl.c) along the lines:
> > 
> > * Return:
> > * - 0:          Initialization was successful.
> > * - -ENOMEM:    Out of memory.
> 
> Actually, looking at kernel-doc.rst, this isn't necessarily the recommended
> approach as it will much everything into one line, complete with dashes, and
> can't handle splitting over lines.  You probably meant:
> 
>       * Return:
>       * * 0		- OK to runtime suspend the device
>       * * -EBUSY	- Device should not be runtime suspended

A line beginning with dash, lines up just as well, as one beginning with
an asterisk. I've also tested this with "make htmldocs".

This is Mauro's response to my recent patch:

https://lore.kernel.org/lkml/20210125105353.5c695d42@coco.lan/

So, what I can make up from this is that they are equally good
alternatives.

What I'm not still fully registering is the dash after the return value.

I mean double comma is used after parameter. Why this weird dash syntax
is used after return value I have no idea, and the kernel-doc.rst does
not provide any explanation.

> 
> > * Return:
> > * - 0:          Initialization was successful.
> > * - -ENOMEM:    Out of memory.
> > 
> > Looking at the implementation, I guess this is a complete representation of
> > what it can return?
> 
> It isn't.  It can return at least -ENOSPC as well, but it's awkward detailing
> the errors from functions it calls since they can change and then the
> description here is wrong.  I'm not sure there's a perfect answer to that.
> 
> David

What if you just add this as the last entry:

* * -errno:     Otherwise.

/Jarkko
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
