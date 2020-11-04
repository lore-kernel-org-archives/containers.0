Return-Path: <SRS0=KLId=EK=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 52A0BC2D0A3
	for <containers@archiver.kernel.org>; Wed,  4 Nov 2020 23:22:38 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 93A0B20735
	for <containers@archiver.kernel.org>; Wed,  4 Nov 2020 23:22:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=linutronix.de header.i=@linutronix.de header.b="aEXqHgDK";
	dkim=permerror (0-bit key) header.d=linutronix.de header.i=@linutronix.de header.b="F3Okx9gC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 93A0B20735
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 19DCA847D1;
	Wed,  4 Nov 2020 23:22:37 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id WmeX9oPt7mI7; Wed,  4 Nov 2020 23:22:36 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 9D35C847AC;
	Wed,  4 Nov 2020 23:22:36 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 97ECAC0889;
	Wed,  4 Nov 2020 23:22:36 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 9147AC0051
 for <containers@lists.linux-foundation.org>;
 Wed,  4 Nov 2020 23:22:34 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 8D11085CBB
 for <containers@lists.linux-foundation.org>;
 Wed,  4 Nov 2020 23:22:34 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id mt-+MycB71Y9
 for <containers@lists.linux-foundation.org>;
 Wed,  4 Nov 2020 23:22:33 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from galois.linutronix.de (Galois.linutronix.de [193.142.43.55])
 by whitealder.osuosl.org (Postfix) with ESMTPS id B11BA85CB4
 for <containers@lists.linux-foundation.org>;
 Wed,  4 Nov 2020 23:22:33 +0000 (UTC)
From: Thomas Gleixner <tglx@linutronix.de>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=linutronix.de;
 s=2020; t=1604532150;
 h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
 in-reply-to:in-reply-to:references:references;
 bh=tBjbPwkoZzQZHjlBJZXMKZQC7+j9Z1jjpOPhzPzBOz4=;
 b=aEXqHgDKSYI/jSf7QUGF8FwFdVyFO2ODKDZwNvh3sSqfRarkbFeYePmaC3uCmY1cGhFGTK
 nXN3f4O4TtWODbhWMDOycrjnaEeqisXqBtYFmUnTJN/pVbVfoQodZpa7jqUkwonW1KWQLV
 X1Pl2Nlwob25n/tYJ4Q3UA+GtNpgXda4scAJWa77Za7d+zbg9Gm+8z4isOK6fooSILehA2
 u830wn9MvJRLyy4G2nyk0m6ke+iGJvf8QBjadmF0Dhk8pfYF1i8mFAHm7phZzU6eNgsDKT
 CTpHZkplCEZH2658win+A44REEu69DStTYxfTDGiO68QqAmVPF8xzO5ROI5gCg==
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=linutronix.de;
 s=2020e; t=1604532150;
 h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
 in-reply-to:in-reply-to:references:references;
 bh=tBjbPwkoZzQZHjlBJZXMKZQC7+j9Z1jjpOPhzPzBOz4=;
 b=F3Okx9gCgBZcaKEu8c7K2GEmaOdNF+i1KUunvoTSdRmVZu+DHO7NbBNU7ECja+bQTLrQ2L
 ALe06HvysKaaPGDQ==
To: Andrea Arcangeli <aarcange@redhat.com>, Kees Cook <keescook@chromium.org>
Subject: Re: RFC: default to spec_store_bypass_disable=prctl
 spectre_v2_user=prctl
In-Reply-To: <20201104215702.GG24993@redhat.com>
References: <20201104215702.GG24993@redhat.com>
Date: Thu, 05 Nov 2020 00:22:29 +0100
Message-ID: <87eel8lnbe.fsf@nanos.tec.linutronix.de>
MIME-Version: 1.0
Cc: Waiman Long <longman@redhat.com>, Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, Jann Horn <jannh@google.com>,
 YiFei Zhu <yifeifz2@illinois.edu>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Jiri Kosina <jikos@kernel.org>, Tobin Feldman-Fitzthum <tobin@ibm.com>,
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

On Wed, Nov 04 2020 at 16:57, Andrea Arcangeli wrote:
> ---
>  Documentation/admin-guide/kernel-parameters.txt | 5 ++---

Is Documentation/admin-guide/hw-vuln/* still correct? If not, please
fix that as well.

Aside of that please send patches in the proper format so they do not
need manual interaction when picking them up.

Thanks,

        tglx
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
