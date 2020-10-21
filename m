Return-Path: <SRS0=v/Bo=D4=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4BD1C388F9
	for <containers@archiver.kernel.org>; Wed, 21 Oct 2020 16:49:51 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 0C11020B1F
	for <containers@archiver.kernel.org>; Wed, 21 Oct 2020 16:49:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="eoPI6/Z2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C11020B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 8438886E6C;
	Wed, 21 Oct 2020 16:49:50 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id QFbBQF7PqmMb; Wed, 21 Oct 2020 16:49:50 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 0555C869CB;
	Wed, 21 Oct 2020 16:49:49 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id E22ACC0052;
	Wed, 21 Oct 2020 16:49:49 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 8F7C5C0051
 for <containers@lists.linux-foundation.org>;
 Wed, 21 Oct 2020 16:49:48 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 7BE9786E6A
 for <containers@lists.linux-foundation.org>;
 Wed, 21 Oct 2020 16:49:48 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id j4W4zCcVvw4t
 for <containers@lists.linux-foundation.org>;
 Wed, 21 Oct 2020 16:49:48 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from us-smtp-delivery-124.mimecast.com
 (us-smtp-delivery-124.mimecast.com [216.205.24.124])
 by whitealder.osuosl.org (Postfix) with ESMTPS id C4B06869CB
 for <containers@lists.linux-foundation.org>;
 Wed, 21 Oct 2020 16:49:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
 s=mimecast20190719; t=1603298986;
 h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=EBKIX4NScpYanL37LvbZAWmxt6PXSYIFIAOMsAhRQoo=;
 b=eoPI6/Z2mGJhytO/cdFMkzjpJDVgwv6gH8Y498gWOwS6YdaDSTJ/VslOUNeSy1RK1SvN8G
 7V6CmAnL98aic+Q0Gi65bXg4pPCYrGamRBsqyY3SpRWb0L3UUDklIe+Wt5bbJbgh28wCnv
 OMv9vCSfwa5jdJzdSacxqK4KOAqwTHE=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-429-IGvRjFQzPdiBi1AylCyuRA-1; Wed, 21 Oct 2020 12:49:39 -0400
X-MC-Unique: IGvRjFQzPdiBi1AylCyuRA-1
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com
 [10.5.11.23])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 0A50B5F9C1;
 Wed, 21 Oct 2020 16:49:37 +0000 (UTC)
Received: from x2.localnet (ovpn-117-184.rdu2.redhat.com [10.10.117.184])
 by smtp.corp.redhat.com (Postfix) with ESMTP id 406B6389;
 Wed, 21 Oct 2020 16:49:26 +0000 (UTC)
From: Steve Grubb <sgrubb@redhat.com>
To: Paul Moore <paul@paul-moore.com>, linux-audit@redhat.com
Subject: Re: [PATCH ghak90 V9 05/13] audit: log container info of syscalls
Date: Wed, 21 Oct 2020 12:49:25 -0400
Message-ID: <2174083.ElGaqSPkdT@x2>
Organization: Red Hat
In-Reply-To: <20201021163926.GA3929765@madcap2.tricolour.ca>
References: <cover.1593198710.git.rgb@redhat.com>
 <20201002195231.GH2882171@madcap2.tricolour.ca>
 <20201021163926.GA3929765@madcap2.tricolour.ca>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
Cc: nhorman@tuxdriver.com, Richard Guy Briggs <rgb@redhat.com>,
 linux-api@vger.kernel.org, containers@lists.linux-foundation.org,
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

On Wednesday, October 21, 2020 12:39:26 PM EDT Richard Guy Briggs wrote:
> > I think I have a way to generate a signal to multiple targets in one
> > syscall...  The added challenge is to also give those targets different
> > audit container identifiers.
> 
> Here is an exmple I was able to generate after updating the testsuite
> script to include a signalling example of a nested audit container
> identifier:
> 
> ----
> type=PROCTITLE msg=audit(2020-10-21 10:31:16.655:6731) :
> proctitle=/usr/bin/perl -w containerid/test type=CONTAINER_ID
> msg=audit(2020-10-21 10:31:16.655:6731) :
> contid=7129731255799087104^3333941723245477888 type=OBJ_PID
> msg=audit(2020-10-21 10:31:16.655:6731) : opid=115583 oauid=root ouid=root
> oses=1 obj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
> ocomm=perl type=CONTAINER_ID msg=audit(2020-10-21 10:31:16.655:6731) :
> contid=3333941723245477888 type=OBJ_PID msg=audit(2020-10-21
> 10:31:16.655:6731) : opid=115580 oauid=root ouid=root oses=1
> obj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 ocomm=perl
> type=CONTAINER_ID msg=audit(2020-10-21 10:31:16.655:6731) :
> contid=8098399240850112512^3333941723245477888 type=OBJ_PID
> msg=audit(2020-10-21 10:31:16.655:6731) : opid=115582 oauid=root ouid=root
> oses=1 obj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
> ocomm=perl type=SYSCALL msg=audit(2020-10-21 10:31:16.655:6731) :
> arch=x86_64 syscall=kill success=yes exit=0 a0=0xfffe3c84 a1=SIGTERM
> a2=0x4d524554 a3=0x0 items=0 ppid=115564 pid=115567 auid=root uid=root
> gid=root euid=root suid=root fsuid=root egid=root sgid=root fsgid=root
> tty=ttyS0 ses=1 comm=perl exe=/usr/bin/perl
> subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
> key=testsuite-1603290671-AcLtUulY ----
> 
> There are three CONTAINER_ID records which need some way of associating
> with OBJ_PID records.  An additional CONTAINER_ID record would be present
> if the killing process itself had an audit container identifier.  I think
> the most obvious way to connect them is with a pid= field in the
> CONTAINER_ID record.

pid is the process sending the signal, opid is the process receiving the 
signal. I think you mean opid?

-Steve


_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
