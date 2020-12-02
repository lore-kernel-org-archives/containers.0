Return-Path: <SRS0=YKjC=FG=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B306C64E7B
	for <containers@archiver.kernel.org>; Wed,  2 Dec 2020 14:44:00 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 6A413221EB
	for <containers@archiver.kernel.org>; Wed,  2 Dec 2020 14:43:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6A413221EB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id CD6272E25D;
	Wed,  2 Dec 2020 14:43:56 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id e4vXOOAtWLh0; Wed,  2 Dec 2020 14:43:55 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 213F92044B;
	Wed,  2 Dec 2020 14:43:55 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 08BA4C163C;
	Wed,  2 Dec 2020 14:43:55 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 730C6C0052
 for <containers@lists.linux-foundation.org>;
 Wed,  2 Dec 2020 14:43:53 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 5878187861
 for <containers@lists.linux-foundation.org>;
 Wed,  2 Dec 2020 14:43:53 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id r3ouyd1vJzPC
 for <containers@lists.linux-foundation.org>;
 Wed,  2 Dec 2020 14:43:52 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 7078F87718
 for <containers@lists.linux-foundation.org>;
 Wed,  2 Dec 2020 14:43:52 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1kkTM7-0000bh-6i; Wed, 02 Dec 2020 14:43:43 +0000
Date: Wed, 2 Dec 2020 15:43:42 +0100
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Aleksa Sarai <cyphar@cyphar.com>
Subject: Re: [PATCH v2 0/2] openat2: reject RESOLVE_BENEATH|RESOLVE_IN_ROOT
Message-ID: <20201202144342.dzks7olzr4owv3ev@wittgenstein>
References: <20201027235044.5240-1-cyphar@cyphar.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20201027235044.5240-1-cyphar@cyphar.com>
Cc: containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
 Alexander Viro <viro@zeniv.linux.org.uk>, linux-kselftest@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, Shuah Khan <shuah@kernel.org>
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

On Wed, Oct 28, 2020 at 10:50:42AM +1100, Aleksa Sarai wrote:
> This was an oversight in the original implementation, as it makes no
> sense to specify both scoping flags to the same openat2(2) invocation
> (before this patch, the result of such an invocation was equivalent to
> RESOLVE_IN_ROOT being ignored).
> 
> This is a userspace-visible ABI change, but the only user of openat2(2)
> at the moment is LXC which doesn't specify both flags and so no
> userspace programs will break as a result.
> 
> Changelog:
>   v2: Split patch so as to separate selftest changes. [Shuah Khan]
>   v1: <https://lore.kernel.org/lkml/20201007103608.17349-1-cyphar@cyphar.com/>
> 
> Aleksa Sarai (2):
>   openat2: reject RESOLVE_BENEATH|RESOLVE_IN_ROOT
>   selftests: openat2: add RESOLVE_ conflict test
> 
>  fs/open.c                                      | 4 ++++
>  tools/testing/selftests/openat2/openat2_test.c | 8 +++++++-
>  2 files changed, 11 insertions(+), 1 deletion(-)

I've applied this patchset now. There's no need to have this sit around
another merge window. I'm happy to drop it again in case you're picking
it up later, Al.

Thanks!
Christian
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
