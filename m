Return-Path: <SRS0=v/Bo=D4=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.0 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5648C4363A
	for <containers@archiver.kernel.org>; Wed, 21 Oct 2020 22:19:49 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id E2C53241A4
	for <containers@archiver.kernel.org>; Wed, 21 Oct 2020 22:19:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="OWDTTe0S"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E2C53241A4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 41F321FD21;
	Wed, 21 Oct 2020 22:19:48 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id sK9T1nV6zdmq; Wed, 21 Oct 2020 22:19:46 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 837211FE32;
	Wed, 21 Oct 2020 21:58:21 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 73525C088B;
	Wed, 21 Oct 2020 21:58:21 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id A137EC0051
 for <containers@lists.linux-foundation.org>;
 Wed, 21 Oct 2020 21:58:19 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 5DD501FE32
 for <containers@lists.linux-foundation.org>;
 Wed, 21 Oct 2020 21:58:19 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id cCrs03JNxvRF
 for <containers@lists.linux-foundation.org>;
 Wed, 21 Oct 2020 21:58:12 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from us-smtp-delivery-124.mimecast.com
 (us-smtp-delivery-124.mimecast.com [63.128.21.124])
 by silver.osuosl.org (Postfix) with ESMTPS id C0DF12F335
 for <containers@lists.linux-foundation.org>;
 Wed, 21 Oct 2020 17:53:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
 s=mimecast20190719; t=1603302810;
 h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
 in-reply-to:in-reply-to:references:references;
 bh=0aM6MG+N6GRh+zh31VWFPduo2rgWm3emASszSAw8inM=;
 b=OWDTTe0SiGQKjc0mlEJCoVfy8KB0qeKRwNh34kmfl75kbHUp2t1k4Pqpi9YDFtoYuu/++3
 fa+5IzxIDvNRpnolkxrwuA4Gs7N+uZ2IoeO9rD33K3nvcBofBo/4A51eQeG5wGWloi3uCM
 oMV/LW+Vvw7kojkSlkSwJUO8gTQd7J4=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-582-0BAAGVqzMda2Ab5lMPFbVA-1; Wed, 21 Oct 2020 13:53:23 -0400
X-MC-Unique: 0BAAGVqzMda2Ab5lMPFbVA-1
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com
 [10.5.11.14])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 57DDD804B66;
 Wed, 21 Oct 2020 17:53:20 +0000 (UTC)
Received: from madcap2.tricolour.ca (unknown [10.10.110.2])
 by smtp.corp.redhat.com (Postfix) with ESMTPS id E934B5D9EF;
 Wed, 21 Oct 2020 17:53:06 +0000 (UTC)
Date: Wed, 21 Oct 2020 13:53:03 -0400
From: Richard Guy Briggs <rgb@redhat.com>
To: Steve Grubb <sgrubb@redhat.com>
Subject: Re: [PATCH ghak90 V9 05/13] audit: log container info of syscalls
Message-ID: <20201021175303.GH2882171@madcap2.tricolour.ca>
References: <cover.1593198710.git.rgb@redhat.com>
 <20201002195231.GH2882171@madcap2.tricolour.ca>
 <20201021163926.GA3929765@madcap2.tricolour.ca>
 <2174083.ElGaqSPkdT@x2>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <2174083.ElGaqSPkdT@x2>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
Cc: Paul Moore <paul@paul-moore.com>, nhorman@tuxdriver.com,
 linux-api@vger.kernel.org, containers@lists.linux-foundation.org,
 LKML <linux-kernel@vger.kernel.org>, dhowells@redhat.com,
 linux-audit@redhat.com, netfilter-devel@vger.kernel.org, ebiederm@xmission.com,
 simo@redhat.com, netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
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

On 2020-10-21 12:49, Steve Grubb wrote:
> On Wednesday, October 21, 2020 12:39:26 PM EDT Richard Guy Briggs wrote:
> > > I think I have a way to generate a signal to multiple targets in one
> > > syscall...  The added challenge is to also give those targets different
> > > audit container identifiers.
> > 
> > Here is an exmple I was able to generate after updating the testsuite
> > script to include a signalling example of a nested audit container
> > identifier:
> > 
> > ----
> > type=PROCTITLE msg=audit(2020-10-21 10:31:16.655:6731) :
> > proctitle=/usr/bin/perl -w containerid/test type=CONTAINER_ID
> > msg=audit(2020-10-21 10:31:16.655:6731) :
> > contid=7129731255799087104^3333941723245477888 type=OBJ_PID
> > msg=audit(2020-10-21 10:31:16.655:6731) : opid=115583 oauid=root ouid=root
> > oses=1 obj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
> > ocomm=perl type=CONTAINER_ID msg=audit(2020-10-21 10:31:16.655:6731) :
> > contid=3333941723245477888 type=OBJ_PID msg=audit(2020-10-21
> > 10:31:16.655:6731) : opid=115580 oauid=root ouid=root oses=1
> > obj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 ocomm=perl
> > type=CONTAINER_ID msg=audit(2020-10-21 10:31:16.655:6731) :
> > contid=8098399240850112512^3333941723245477888 type=OBJ_PID
> > msg=audit(2020-10-21 10:31:16.655:6731) : opid=115582 oauid=root ouid=root
> > oses=1 obj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
> > ocomm=perl type=SYSCALL msg=audit(2020-10-21 10:31:16.655:6731) :
> > arch=x86_64 syscall=kill success=yes exit=0 a0=0xfffe3c84 a1=SIGTERM
> > a2=0x4d524554 a3=0x0 items=0 ppid=115564 pid=115567 auid=root uid=root
> > gid=root euid=root suid=root fsuid=root egid=root sgid=root fsgid=root
> > tty=ttyS0 ses=1 comm=perl exe=/usr/bin/perl
> > subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
> > key=testsuite-1603290671-AcLtUulY ----
> > 
> > There are three CONTAINER_ID records which need some way of associating
> > with OBJ_PID records.  An additional CONTAINER_ID record would be present
> > if the killing process itself had an audit container identifier.  I think
> > the most obvious way to connect them is with a pid= field in the
> > CONTAINER_ID record.
> 
> pid is the process sending the signal, opid is the process receiving the 
> signal. I think you mean opid?

If the process sending the signal (it has a pid= field) has an audit
container identifier, it will generate a CONTAINER_ID record.  Each
process being signalled (each has an opid= field) that has an audit
container identifier will also generate a CONTAINER_ID record.  The
former will be much more common.  Which do we use in the CONTAINER_ID
record?  Having swinging fields, pid vs opid does not seem like a
reasonable solution.  Do we go back to "ref=pid=..." vs "ref=opid=..."?

> -Steve

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
