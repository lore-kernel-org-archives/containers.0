Return-Path: <SRS0=sUbK=FZ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-20.0 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 247CAC433E6
	for <containers@archiver.kernel.org>; Mon, 21 Dec 2020 17:57:45 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id A67AE22B51
	for <containers@archiver.kernel.org>; Mon, 21 Dec 2020 17:57:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A67AE22B51
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 2615786C20;
	Mon, 21 Dec 2020 17:57:44 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ZYqT7rx-kwJb; Mon, 21 Dec 2020 17:57:42 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id D170586846;
	Mon, 21 Dec 2020 17:57:42 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id C25A6C1825;
	Mon, 21 Dec 2020 17:57:42 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id C8766C0893
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Dec 2020 17:57:40 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id B4BC4227A3
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Dec 2020 17:57:40 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id kC8LM8s0CPc8
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Dec 2020 17:57:38 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from us-smtp-delivery-124.mimecast.com
 (us-smtp-delivery-124.mimecast.com [63.128.21.124])
 by silver.osuosl.org (Postfix) with ESMTPS id 58623226FC
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Dec 2020 17:57:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
 s=mimecast20190719; t=1608573456;
 h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
 in-reply-to:in-reply-to:references:references;
 bh=PVTTSIZ+4qn+SwwDnLlevQMhsrEFZG01AfUJnVXzFpk=;
 b=TfCyOqA2SivMCkf/I8XjXMp04bmPvcqtphEmVkjjIgkMM5On4nKiiJfYRxXpqI/PMTiT98
 wA3SGD7rLTorwtISPgYTLzu/JCexWRbsFY7scx5b36VYW80YC5LcMORzxiapoDbuXCDNqU
 1djA5r9+2SQ4VT1J4vRs4GUncPHXqkY=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-64-Hmj-eDYzNaCOHIZWZAk8lw-1; Mon, 21 Dec 2020 12:57:32 -0500
X-MC-Unique: Hmj-eDYzNaCOHIZWZAk8lw-1
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com
 [10.5.11.11])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by mimecast-mx01.redhat.com (Postfix) with ESMTPS id E8B338030A5;
 Mon, 21 Dec 2020 17:57:29 +0000 (UTC)
Received: from madcap2.tricolour.ca (unknown [10.10.110.9])
 by smtp.corp.redhat.com (Postfix) with ESMTPS id B53BD1E5;
 Mon, 21 Dec 2020 17:57:15 +0000 (UTC)
Date: Mon, 21 Dec 2020 12:57:12 -0500
From: Richard Guy Briggs <rgb@redhat.com>
To: Paul Moore <paul@paul-moore.com>
Subject: Re: [PATCH ghak90 v10 01/11] audit: collect audit task parameters
Message-ID: <20201221175712.GI1762914@madcap2.tricolour.ca>
References: <cover.1608225886.git.rgb@redhat.com>
 <982b9adffbd32264a853fe7f4f06f0d0a882c11d.1608225886.git.rgb@redhat.com>
 <CAHC9VhSTuBJ3LXxMY=nD7qBzmKLDjXY0V3hsuN34_siq_xRrig@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CAHC9VhSTuBJ3LXxMY=nD7qBzmKLDjXY0V3hsuN34_siq_xRrig@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
Cc: Jens Axboe <axboe@kernel.dk>, Neil Horman <nhorman@tuxdriver.com>,
 Linux API <linux-api@vger.kernel.org>,
 Linux Containers List <containers@lists.linux-foundation.org>,
 LKML <linux-kernel@vger.kernel.org>, David Howells <dhowells@redhat.com>,
 Linux-Audit Mailing List <linux-audit@redhat.com>,
 Netfilter Devel List <netfilter-devel@vger.kernel.org>,
 "Eric W. Biederman" <ebiederm@xmission.com>, Simo Sorce <simo@redhat.com>,
 Linux NetDev Upstream Mailing List <netdev@vger.kernel.org>,
 Linux FSdevel <linux-fsdevel@vger.kernel.org>,
 Eric Paris <eparis@parisplace.org>, mpatel@redhat.com
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

On 2020-12-21 12:14, Paul Moore wrote:
> On Mon, Dec 21, 2020 at 11:57 AM Richard Guy Briggs <rgb@redhat.com> wrote:
> >
> > The audit-related parameters in struct task_struct should ideally be
> > collected together and accessed through a standard audit API and the audit
> > structures made opaque to other kernel subsystems.
> >
> > Collect the existing loginuid, sessionid and audit_context together in a
> > new opaque struct audit_task_info called "audit" in struct task_struct.
> >
> > Use kmem_cache to manage this pool of memory.
> > Un-inline audit_free() to be able to always recover that memory.
> >
> > Please see the upstream github issues
> > https://github.com/linux-audit/audit-kernel/issues/81
> > https://github.com/linux-audit/audit-kernel/issues/90
> >
> > Signed-off-by: Richard Guy Briggs <rgb@redhat.com>
> > Acked-by: Neil Horman <nhorman@tuxdriver.com>
> > Reviewed-by: Ondrej Mosnacek <omosnace@redhat.com>
> 
> Did Neil and Ondrej really ACK/Review the changes that you made here
> in v10 or are you just carrying over the ACK/Review?  I'm hopeful it
> is the former, because I'm going to be a little upset if it is the
> latter.

It is the latter, sorry.  So, this needs to be reposted without their
ACK/Review lines.

> > ---
> >  fs/io-wq.c            |   8 +--
> >  fs/io_uring.c         |  16 ++---
> >  include/linux/audit.h |  49 +++++---------
> >  include/linux/sched.h |   7 +-
> >  init/init_task.c      |   3 +-
> >  init/main.c           |   2 +
> >  kernel/audit.c        | 154 +++++++++++++++++++++++++++++++++++++++++-
> >  kernel/audit.h        |   7 ++
> >  kernel/auditsc.c      |  24 ++++---
> >  kernel/fork.c         |   1 -
> >  10 files changed, 205 insertions(+), 66 deletions(-)
> 
> -- 
> paul moore
> www.paul-moore.com
> 

- RGB

--
Richard Guy Briggs <rgb@redhat.com>
Sr. S/W Engineer, Kernel Security, Base Operating Systems
Remote, Ottawa, Red Hat Canada
IRC: rgb, SunRaycer
Voice: +1.647.777.2635, Internal: (81) 32635

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
