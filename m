Return-Path: <SRS0=l1uc=D6=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.0 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C4D4C5517A
	for <containers@archiver.kernel.org>; Fri, 23 Oct 2020 20:41:03 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 7B11D2087D
	for <containers@archiver.kernel.org>; Fri, 23 Oct 2020 20:41:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="JZd5fuC+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B11D2087D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id E8DA687031;
	Fri, 23 Oct 2020 20:41:01 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id bZDW2B-G2kJ8; Fri, 23 Oct 2020 20:41:00 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id CA60386FD9;
	Fri, 23 Oct 2020 20:41:00 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id ABAABC0052;
	Fri, 23 Oct 2020 20:41:00 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 05A8DC0051
 for <containers@lists.linux-foundation.org>;
 Fri, 23 Oct 2020 20:40:59 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id D3374203B0
 for <containers@lists.linux-foundation.org>;
 Fri, 23 Oct 2020 20:40:58 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id qKdHeifLU2LQ
 for <containers@lists.linux-foundation.org>;
 Fri, 23 Oct 2020 20:40:57 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from us-smtp-delivery-124.mimecast.com
 (us-smtp-delivery-124.mimecast.com [216.205.24.124])
 by silver.osuosl.org (Postfix) with ESMTPS id 25A63203AC
 for <containers@lists.linux-foundation.org>;
 Fri, 23 Oct 2020 20:40:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
 s=mimecast20190719; t=1603485655;
 h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
 in-reply-to:in-reply-to:references:references;
 bh=a3pMnOcWFThjKdDsxfmbI+DYS5weG2T0/ht11gpp4qQ=;
 b=JZd5fuC+MF0GcTWZbKm+vlgseAOW0BcvH3QhlbE0xZEe8sGGcG3IiPzhtanCYHDxxi8Oli
 y+NMfzGFCA8QRK45vQU/fNSRkqtfiwbH9CrvXuA+dsu94n/Mj2R7HOPur+FyCGTxHyyN9N
 35NSXkPXj8r25mdkmubHNweWi08utyU=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-139-Dsav4riYMDeJtcCT1H38iQ-1; Fri, 23 Oct 2020 16:40:53 -0400
X-MC-Unique: Dsav4riYMDeJtcCT1H38iQ-1
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com
 [10.5.11.13])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 44FE41882FB6;
 Fri, 23 Oct 2020 20:40:51 +0000 (UTC)
Received: from madcap2.tricolour.ca (unknown [10.10.110.2])
 by smtp.corp.redhat.com (Postfix) with ESMTPS id A971D614F5;
 Fri, 23 Oct 2020 20:40:36 +0000 (UTC)
Date: Fri, 23 Oct 2020 16:40:33 -0400
From: Richard Guy Briggs <rgb@redhat.com>
To: Paul Moore <paul@paul-moore.com>
Subject: Re: [PATCH ghak90 V9 05/13] audit: log container info of syscalls
Message-ID: <20201023204033.GI2882171@madcap2.tricolour.ca>
References: <cover.1593198710.git.rgb@redhat.com>
 <6e2e10432e1400f747918eeb93bf45029de2aa6c.1593198710.git.rgb@redhat.com>
 <CAHC9VhSCm5eeBcyY8bBsnxr-hK4rkso9_NJHJec2OXLu4m5QTA@mail.gmail.com>
 <20200729194058.kcbsqjhzunjpipgm@madcap2.tricolour.ca>
 <CAHC9VhRUwCKBjffA_XNSjUwvUn8e6zfmy8WD203dK7R2KD0__g@mail.gmail.com>
 <20201002195231.GH2882171@madcap2.tricolour.ca>
 <20201021163926.GA3929765@madcap2.tricolour.ca>
 <CAHC9VhRb7XMyTrcrmzM3yQO+eLdO_r2+DOLKr9apDDeH4ua2Ew@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CAHC9VhRb7XMyTrcrmzM3yQO+eLdO_r2+DOLKr9apDDeH4ua2Ew@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
Cc: nhorman@tuxdriver.com, linux-api@vger.kernel.org,
 containers@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>,
 dhowells@redhat.com, Linux-Audit Mailing List <linux-audit@redhat.com>,
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

On 2020-10-22 21:21, Paul Moore wrote:
> On Wed, Oct 21, 2020 at 12:39 PM Richard Guy Briggs <rgb@redhat.com> wrote:
> > Here is an exmple I was able to generate after updating the testsuite
> > script to include a signalling example of a nested audit container
> > identifier:
> >
> > ----
> > type=PROCTITLE msg=audit(2020-10-21 10:31:16.655:6731) : proctitle=/usr/bin/perl -w containerid/test
> > type=CONTAINER_ID msg=audit(2020-10-21 10:31:16.655:6731) : contid=7129731255799087104^3333941723245477888
> > type=OBJ_PID msg=audit(2020-10-21 10:31:16.655:6731) : opid=115583 oauid=root ouid=root oses=1 obj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 ocomm=perl
> > type=CONTAINER_ID msg=audit(2020-10-21 10:31:16.655:6731) : contid=3333941723245477888
> > type=OBJ_PID msg=audit(2020-10-21 10:31:16.655:6731) : opid=115580 oauid=root ouid=root oses=1 obj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 ocomm=perl
> > type=CONTAINER_ID msg=audit(2020-10-21 10:31:16.655:6731) : contid=8098399240850112512^3333941723245477888
> > type=OBJ_PID msg=audit(2020-10-21 10:31:16.655:6731) : opid=115582 oauid=root ouid=root oses=1 obj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 ocomm=perl
> > type=SYSCALL msg=audit(2020-10-21 10:31:16.655:6731) : arch=x86_64 syscall=kill success=yes exit=0 a0=0xfffe3c84 a1=SIGTERM a2=0x4d524554 a3=0x0 items=0 ppid=115564 pid=115567 auid=root uid=root gid=root euid=root suid=root fsuid=root egid=root sgid=root fsgid=root tty=ttyS0 ses=1 comm=perl exe=/usr/bin/perl subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 key=testsuite-1603290671-AcLtUulY
> > ----
> >
> > There are three CONTAINER_ID records which need some way of associating with OBJ_PID records.  An additional CONTAINER_ID record would be present if the killing process itself had an audit container identifier.  I think the most obvious way to connect them is with a pid= field in the CONTAINER_ID record.
> 
> Using a "pid=" field as a way to link CONTAINER_ID records to other
> records raises a few questions.  What happens if/when we need to
> represent those PIDs in the context of a namespace?  Are we ever going
> to need to link to records which don't have a "pid=" field?  I haven't
> done the homework to know if either of these are a concern right now,
> but I worry that this might become a problem in the future.

Good point about PID namespaces in the future but those accompanying
records will already have to be conditioned for the PID namespace
context that is requesting it, so I don't see this as a showstopper.

I've forgotten about an important one we already hit, which is a network
event that only has a NETFILTER_PKT record, but in that case, there is
no ambiguity since there are no other records associated with that
event.  So the second is already an issue now.  Using
task_tgid_nr(current), in the contid testsuite script network event it
attributed it to ping which caused the event, but we cannot use this
since it wasn't triggered by a syscall and doesn't accurately reflect
the kernel thread that received it.  It could just be set to zero for
network events.

> The idea of using something like "item=" is interesting.  As you
> mention, the "item=" field does present some overlap problems with the
> PATH record, but perhaps we can do something similar.  What if we
> added a "record=" (or similar, I'm not worried about names at this
> point) to each record, reset to 0/1 at the start of each event, and
> when we needed to link records somehow we could add a "related=1,..,N"
> field.  This would potentially be useful beyond just the audit
> container ID work.

Does it make any sense to use the same keyword in each type of record
such as record/records as in PATH/SYSCALL: item/items ?

(I prefer 0-indexed like item=...)

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
