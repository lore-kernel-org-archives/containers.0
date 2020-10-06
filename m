Return-Path: <SRS0=G2OP=DN=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.0 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4182C41604
	for <containers@archiver.kernel.org>; Tue,  6 Oct 2020 20:04:21 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 0855920796
	for <containers@archiver.kernel.org>; Tue,  6 Oct 2020 20:04:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="iGvuAtoj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0855920796
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 4FB38207A2;
	Tue,  6 Oct 2020 20:04:20 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id x+LFYYGi929U; Tue,  6 Oct 2020 20:04:18 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id DC63620012;
	Tue,  6 Oct 2020 20:04:17 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id C98A8C016F;
	Tue,  6 Oct 2020 20:04:17 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id B99DFC0051
 for <containers@lists.linux-foundation.org>;
 Tue,  6 Oct 2020 20:04:16 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id A92498484C
 for <containers@lists.linux-foundation.org>;
 Tue,  6 Oct 2020 20:04:16 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id UHWypg_-n4uR
 for <containers@lists.linux-foundation.org>;
 Tue,  6 Oct 2020 20:04:15 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from us-smtp-delivery-124.mimecast.com
 (us-smtp-delivery-124.mimecast.com [216.205.24.124])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id C435D80661
 for <containers@lists.linux-foundation.org>;
 Tue,  6 Oct 2020 20:04:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
 s=mimecast20190719; t=1602014654;
 h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
 in-reply-to:in-reply-to:references:references;
 bh=nAsLvgW1nDOTPpn1U85aTp/X7z+VtDo99/tckF5jXNI=;
 b=iGvuAtojmV7k69MejaC4O5HTbnKN7dN9I6xPrjq3AgVn7746bb1zdtFsaAbCmcE5bBZV+W
 2s56X+TtcRjMyUWkdXcPFBjXrnxltr6EjpuoGu0hrDSl1nJgWP8oDF4VoscwrYN67bPgkk
 T7ICsQAJIIR3Lh8AUHAwwRF3WRhbXcs=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-483-r50GUUy5MiC9VEv4faOv2Q-1; Tue, 06 Oct 2020 16:04:10 -0400
X-MC-Unique: r50GUUy5MiC9VEv4faOv2Q-1
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com
 [10.5.11.14])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 9DA58804018;
 Tue,  6 Oct 2020 20:04:08 +0000 (UTC)
Received: from madcap2.tricolour.ca (unknown [10.10.110.18])
 by smtp.corp.redhat.com (Postfix) with ESMTPS id 767315D9CD;
 Tue,  6 Oct 2020 20:03:50 +0000 (UTC)
Date: Tue, 6 Oct 2020 16:03:47 -0400
From: Richard Guy Briggs <rgb@redhat.com>
To: Paul Moore <paul@paul-moore.com>
Subject: Re: [PATCH ghak90 V9 11/13] audit: contid check descendancy and
 nesting
Message-ID: <20201006200347.GI2882171@madcap2.tricolour.ca>
References: <cover.1593198710.git.rgb@redhat.com>
 <01229b93733d9baf6ac9bb0cc243eeb08ad579cd.1593198710.git.rgb@redhat.com>
 <CAHC9VhT6cLxxws_pYWcL=mWe786xPoTTFfPZ1=P4hx4V3nytXA@mail.gmail.com>
 <20200807171025.523i2sxfyfl7dfjy@madcap2.tricolour.ca>
 <CAHC9VhQ3MVUY8Zs4GNXdaqhiPJBzHW_YcCe=DghAgo7g6yrNBw@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CAHC9VhQ3MVUY8Zs4GNXdaqhiPJBzHW_YcCe=DghAgo7g6yrNBw@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
Cc: nhorman@tuxdriver.com, linux-api@vger.kernel.org,
 containers@lists.linux-foundation.org, aris@redhat.com,
 LKML <linux-kernel@vger.kernel.org>, dhowells@redhat.com,
 Linux-Audit Mailing List <linux-audit@redhat.com>,
 netfilter-devel@vger.kernel.org, ebiederm@xmission.com, simo@redhat.com,
 netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
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

On 2020-08-21 16:13, Paul Moore wrote:
> On Fri, Aug 7, 2020 at 1:10 PM Richard Guy Briggs <rgb@redhat.com> wrote:
> > On 2020-07-05 11:11, Paul Moore wrote:
> > > On Sat, Jun 27, 2020 at 9:23 AM Richard Guy Briggs <rgb@redhat.com> wrote:
> > > > Require the target task to be a descendant of the container
> > > > orchestrator/engine.
> 
> If you want to get formal about this, you need to define "target" in
> the sentence above.  Target of what?

The target is the task having its audit container identifier modified by
the orchestrator current task.

> FWIW, I read the above to basically mean that a task can only set the
> audit container ID of processes which are beneath it in the "process
> tree" where the "process tree" is defined as the relationship between
> a parent and children processes such that the children processes are
> branches below the parent process.

Yes.

> I have no problem with that, with the understanding that nesting
> complicates it somewhat.  For example, this isn't true when one of the
> children is a nested orchestrator, is it?

It should still be true if that child is a nested orchestrator that has
not yet spawned any children or threads (or they have all died off).

It does get more complicated when we consider the scenario outlined
below about perceived layer violations...

> > > > You would only change the audit container ID from one set or inherited
> > > > value to another if you were nesting containers.
> 
> I thought we decided we were going to allow an orchestrator to move a
> process between audit container IDs, yes?  no?

We did?  I don't remember anything about that.  Has this been requested?
This seems to violate the rule that we can't change the audit container
identifier once it has been set (other than nesting).  Can you suggest a
use case?

> > > > If changing the contid, the container orchestrator/engine must be a
> > > > descendant and not same orchestrator as the one that set it so it is not
> > > > possible to change the contid of another orchestrator's container.
> 
> Try rephrasing the above please, it isn't clear to me what you are
> trying to say.

This is harder than I expected to rephrase...  It also makes it clear
that there are some scenarios that have not been considered that may
need to be restricted.

Orchestrator A spawned task B which is itself an orchestrator without
chidren yet.  Orchestrator A sets the audit container identifier of B.
Neither A, nor B, nor any other child of A (or any of their
descendants), nor any orchestrator outside the tree of A (uncles, aunts
and cousins are outside), can change the audit container identifier of
B.

Orchestrator B spawns task C.  Here's where it gets tricky.  It seems
like a layer violation for B to spawn a child C and have A reach over B
to set the audit container identifier of C, especially if B is also an
orchestrator.  This all will be especially hard to police if we don't
limit the ability of an orchestrator task to set an audit container
identifier to that orchestrator's immediate children, only once.

> > Are we able to agree on the premises above?  Is anything asserted that
> > should not be and is there anything missing?
> 
> See above.
> 
> If you want to go back to the definitions/assumptions stage, it
> probably isn't worth worrying about the other comments until we get
> the above sorted.

I don't want to.  I'm trying to confirm that we are on the same page.

> paul moore

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
