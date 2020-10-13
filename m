Return-Path: <SRS0=kI60=DU=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4B8DC433DF
	for <containers@archiver.kernel.org>; Tue, 13 Oct 2020 21:09:34 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 2C34F218AC
	for <containers@archiver.kernel.org>; Tue, 13 Oct 2020 21:09:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2C34F218AC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=zeniv.linux.org.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id D64A287C30;
	Tue, 13 Oct 2020 21:09:33 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id RrzyT3+fnCnj; Tue, 13 Oct 2020 21:09:32 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id A869087BAA;
	Tue, 13 Oct 2020 21:09:32 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 9E93FC07FF;
	Tue, 13 Oct 2020 21:09:32 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id D4D0AC0051
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Oct 2020 21:09:31 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id D00F786B21
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Oct 2020 21:09:31 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id EZOXDLEpTnb0
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Oct 2020 21:09:30 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk [195.92.253.2])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 7E766851CB
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Oct 2020 21:09:30 +0000 (UTC)
Received: from viro by ZenIV.linux.org.uk with local (Exim 4.92.3 #3 (Red Hat
 Linux)) id 1kSRXx-00HB9t-Ag; Tue, 13 Oct 2020 21:09:25 +0000
Date: Tue, 13 Oct 2020 22:09:25 +0100
From: Al Viro <viro@zeniv.linux.org.uk>
To: Giuseppe Scrivano <gscrivan@redhat.com>
Subject: Re: [PATCH 1/2] fs, close_range: add flag CLOSE_RANGE_CLOEXEC
Message-ID: <20201013210925.GJ3576660@ZenIV.linux.org.uk>
References: <20201013140609.2269319-1-gscrivan@redhat.com>
 <20201013140609.2269319-2-gscrivan@redhat.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20201013140609.2269319-2-gscrivan@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org,
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

On Tue, Oct 13, 2020 at 04:06:08PM +0200, Giuseppe Scrivano wrote:
> +		spin_lock(&cur_fds->file_lock);
> +		fdt = files_fdtable(cur_fds);
> +		cur_max = fdt->max_fds - 1;
> +		max_fd = min(max_fd, cur_max);
> +		while (fd <= max_fd)
> +			__set_close_on_exec(fd++, fdt);
> +		spin_unlock(&cur_fds->file_lock);

	First of all, this is an atrocious way to set all bits
in a range.  What's more, you don't want to set it for *all*
bits - only for the ones present in open bitmap.  It's probably
harmless at the moment, but let's not create interesting surprises
for the future.
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
