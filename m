Return-Path: <SRS0=lkaS=DB=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.1 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 441A3C4363D
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 18:57:20 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id B8F4123600
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 18:57:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="cLfXJQCa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B8F4123600
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 7756B87498;
	Thu, 24 Sep 2020 18:57:19 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id caStam7kXFkz; Thu, 24 Sep 2020 18:57:18 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id ED2CF87494;
	Thu, 24 Sep 2020 18:57:18 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id D18C8C0889;
	Thu, 24 Sep 2020 18:57:18 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id A092BC0051
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 18:57:17 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 841AA87498
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 18:57:17 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id IGOE2M1MywRn
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 18:57:15 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from us-smtp-delivery-124.mimecast.com
 (us-smtp-delivery-124.mimecast.com [63.128.21.124])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 6EE5887494
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 18:57:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
 s=mimecast20190719; t=1600973834;
 h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
 in-reply-to:in-reply-to:references:references;
 bh=Axiq0yReIhbW6/4dmIx+opfMoBleK5yZs2UhwoE+Kvs=;
 b=cLfXJQCaCrZjmg8XGAXNgIcegjVWBRj5fDp52NwtL+qRJh3Bm/ll8z5P/Pk/gfcIKzivSX
 sIHPfQmslCB0TA74l9EHDMPJMu/82clK1qkHs8Xfr2/uqi/mBcdsErp2Ddmg5KCsL9++Pi
 dI8HlQHjrOMFTEIc+sMKYs8HpLhwTAQ=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-414-WVV_JMg6OJmaRNofl0ABnw-1; Thu, 24 Sep 2020 14:57:07 -0400
X-MC-Unique: WVV_JMg6OJmaRNofl0ABnw-1
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com
 [10.5.11.13])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 8268E1868410;
 Thu, 24 Sep 2020 18:57:05 +0000 (UTC)
Received: from mail (ovpn-118-223.rdu2.redhat.com [10.10.118.223])
 by smtp.corp.redhat.com (Postfix) with ESMTPS id BDB1A73693;
 Thu, 24 Sep 2020 18:57:02 +0000 (UTC)
Date: Thu, 24 Sep 2020 14:57:02 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
To: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH v1 0/6] seccomp: Implement constant action bitmaps
Message-ID: <20200924185702.GA9225@redhat.com>
References: <20200923232923.3142503-1-keescook@chromium.org>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20200923232923.3142503-1-keescook@chromium.org>
User-Agent: Mutt/1.14.7 (2020-08-29)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
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

Hello,

I'm posting this only for the record, feel free to ignore.

On Wed, Sep 23, 2020 at 04:29:17PM -0700, Kees Cook wrote:
> rfc: https://lore.kernel.org/lkml/20200616074934.1600036-1-keescook@chromium.org/
> alternative: https://lore.kernel.org/containers/cover.1600661418.git.yifeifz2@illinois.edu/
> v1:
> - rebase to for-next/seccomp
> - finish X86_X32 support for both pinning and bitmaps

It's pretty clear the O(1) seccomp filter bitmap was first was
proposed by your RFC in June (albeit it was located in the wrong place
and is still in the wrong place in v1).

> - replace TLB magic with Jann's emulator
    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    
That's a pretty fundamental change in v1 compared to your the
non-competing TLB magic technique you used in the RFC last June.

The bitmap isn't the clever part of the patch, the bitmap can be
reviewed in seconds, the difficult part to implement and to review is
how you fill the bitmap and in that respect there's absolutely nothing
in common in between the "rfc:" and the "alternative" link.

In June your bitmap-filling engine was this:

https://lore.kernel.org/lkml/20200616074934.1600036-5-keescook@chromium.org/

Then on Sep 21 YiFei Zhu posted his new innovative BPF emulation
innovation that obsoleted your TLB magic of June:

https://lists.linuxfoundation.org/pipermail/containers/2020-September/042153.html

And on Sep 23 instead of collaborating and helping YiFei Zhu to
improve his BPF emulator, you posted the same technique that looks
remarkably similar without giving YiFei Zhu any attribution and you
instead attribute the whole idea to Jann Horn:

https://lkml.kernel.org/r/20200923232923.3142503-5-keescook@chromium.org

Thanks,
Andrea

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
