Return-Path: <SRS0=kI60=DU=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2E11C433DF
	for <containers@archiver.kernel.org>; Tue, 13 Oct 2020 21:22:40 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 72B7521582
	for <containers@archiver.kernel.org>; Tue, 13 Oct 2020 21:22:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 72B7521582
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 34708203E1;
	Tue, 13 Oct 2020 21:22:39 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id tsUCfoxZsDch; Tue, 13 Oct 2020 21:22:36 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 59BB6203AA;
	Tue, 13 Oct 2020 21:22:36 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 44285C0052;
	Tue, 13 Oct 2020 21:22:36 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 1F84EC0051
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Oct 2020 21:22:35 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 0E8CD875A0
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Oct 2020 21:22:35 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id D3s1VBVNUqIQ
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Oct 2020 21:22:34 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 4AAD587573
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Oct 2020 21:22:34 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1kSRka-0007PO-QI; Tue, 13 Oct 2020 21:22:28 +0000
Date: Tue, 13 Oct 2020 23:22:28 +0200
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: Re: [PATCH 1/2] fs, close_range: add flag CLOSE_RANGE_CLOEXEC
Message-ID: <20201013212228.gan6rcayveanujwd@wittgenstein>
References: <20201013140609.2269319-1-gscrivan@redhat.com>
 <20201013140609.2269319-2-gscrivan@redhat.com>
 <20201013205427.clvqno24ctwxbuyv@wittgenstein>
 <22ff41f8-c009-84f4-849b-a807b7382253@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <22ff41f8-c009-84f4-849b-a807b7382253@rasmusvillemoes.dk>
Cc: linux-fsdevel@vger.kernel.org, Giuseppe Scrivano <gscrivan@redhat.com>,
 containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
 viro@zeniv.linux.org.uk
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

On Tue, Oct 13, 2020 at 11:04:21PM +0200, Rasmus Villemoes wrote:
> On 13/10/2020 22.54, Christian Brauner wrote:
> > On Tue, Oct 13, 2020 at 04:06:08PM +0200, Giuseppe Scrivano wrote:
> > 
> > Hey Guiseppe,
> > 
> > Thanks for the patch!
> > 
> >> When the flag CLOSE_RANGE_CLOEXEC is set, close_range doesn't
> >> immediately close the files but it sets the close-on-exec bit.
> > 
> > Hm, please expand on the use-cases a little here so people know where
> > and how this is useful. Keeping the rationale for a change in the commit
> > log is really important.
> > 
> 
> > I think I don't have quarrels with this patch in principle but I wonder
> > if something like the following wouldn't be easier to follow:
> > 
> > diff --git a/fs/file.c b/fs/file.c
> > index 21c0893f2f1d..872a4098c3be 100644
> > --- a/fs/file.c
> > +++ b/fs/file.c
> > @@ -672,6 +672,32 @@ int __close_fd(struct files_struct *files, unsigned fd)
> >  }
> >  EXPORT_SYMBOL(__close_fd); /* for ksys_close() */
> >  
> > +static inline void __range_cloexec(struct files_struct *cur_fds,
> > +				   unsigned int fd, unsigned max_fd)
> > +{
> > +	struct fdtable *fdt;
> > +	spin_lock(&cur_fds->file_lock);
> > +	fdt = files_fdtable(cur_fds);
> > +	while (fd <= max_fd)
> > +		__set_close_on_exec(fd++, fdt);
> 

(I should've warned that I just proposed this as a completely untested
brainstorm.)

> Doesn't that want to be
> 
>   bitmap_set(fdt->close_on_exec, fd, max_fd - fd + 1)
> 
> to do word-at-a-time? I assume this would mostly be called with (3, ~0U)
> as arguments or something like that.

Yes, that is the common case.

Thanks Rasmus, I was unaware we had that function.

In that case I think we'd actually need sm like:
spin_lock(&cur_fds->file_lock);
fdt = files_fdtable(cur_fds);
cur_max = files_fdtable(cur_fds)->max_fds - 1;
max_fd = min(max_fd, cur_max);
bitmap_set(fdt->close_on_exec, fd, max_fd - fd + 1)

so we retrieve max_fd with the spinlock held, I think.

Christian
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
