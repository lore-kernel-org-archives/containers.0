Return-Path: <SRS0=8SPi=CG=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4DB8CC433E6
	for <containers@archiver.kernel.org>; Fri, 28 Aug 2020 19:29:42 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 2718420848
	for <containers@archiver.kernel.org>; Fri, 28 Aug 2020 19:29:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2718420848
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=xmission.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 0F4EB86C63;
	Fri, 28 Aug 2020 19:29:42 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id a2OaERYSkkkV; Fri, 28 Aug 2020 19:29:41 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 981FE86C08;
	Fri, 28 Aug 2020 19:29:41 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 84219C016F;
	Fri, 28 Aug 2020 19:29:41 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 38E8FC0051
 for <containers@lists.linux-foundation.org>;
 Fri, 28 Aug 2020 19:29:41 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 27E8986C4B
 for <containers@lists.linux-foundation.org>;
 Fri, 28 Aug 2020 19:29:41 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id o7mFAjZHAxnt
 for <containers@lists.linux-foundation.org>;
 Fri, 28 Aug 2020 19:29:40 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from out01.mta.xmission.com (out01.mta.xmission.com [166.70.13.231])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id B2D3F86C08
 for <containers@lists.linux-foundation.org>;
 Fri, 28 Aug 2020 19:29:40 +0000 (UTC)
Received: from in02.mta.xmission.com ([166.70.13.52])
 by out01.mta.xmission.com with esmtps (TLS1.2) tls
 TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256 (Exim 4.93)
 (envelope-from <ebiederm@xmission.com>) id 1kBk4B-009fOT-QS
 for containers@lists.linux-foundation.org; Fri, 28 Aug 2020 13:29:39 -0600
Received: from ip68-227-160-95.om.om.cox.net ([68.227.160.95]
 helo=x220.xmission.com) by in02.mta.xmission.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_256_GCM_SHA384:256) (Exim 4.87)
 (envelope-from <ebiederm@xmission.com>) id 1kBk4B-0003zg-6n
 for containers@lists.linux-foundation.org; Fri, 28 Aug 2020 13:29:39 -0600
From: ebiederm@xmission.com (Eric W. Biederman)
To: Linux Containers <containers@lists.linux-foundation.org> 
Date: Fri, 28 Aug 2020 14:25:55 -0500
Message-ID: <87imd2incs.fsf@x220.int.ebiederm.org>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
X-XM-SPF: eid=1kBk4B-0003zg-6n; ; ; mid=<87imd2incs.fsf@x220.int.ebiederm.org>;
 ; ; hst=in02.mta.xmission.com; ; ; ip=68.227.160.95; ; ;
 frm=ebiederm@xmission.com; ; ; spf=neutral
X-XM-AID: U2FsdGVkX1+R0LR08/IJpwbc99enW4yqakqREqTW2w8=
X-SA-Exim-Connect-IP: 68.227.160.95
X-SA-Exim-Mail-From: ebiederm@xmission.com
Subject: Per user rlimits
X-SA-Exim-Version: 4.2.1 (built Thu, 05 May 2016 13:38:54 -0600)
X-SA-Exim-Scanned: Yes (on in02.mta.xmission.com)
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


Just to scope how much work it would be to fix rlimits
so they are not a problem for user namespaces I took a quick
survey.

The rlimits can be found in
include/uapi/asm-generic/resource.h

There are a total of 16 rlimits.
There are only 4 rlimits that are enforced at anything other
than process granularity.

RLIMIT_NPROC
RLIMIT_MEMLOCK 
RLIMIT_SIGPENDING
RLIMIT_MSGQUEUE

So it should not be difficult to fix those rlimits.

I think the implementation of RLIMIT_MEMLOCK is highly suspect, and
might be worth reexamining, as RLMIT_MEMLOCK it interpreted differently
in different contexts.  For the limit there is mm->locked_vm,
user->lock_vm, and user->locked_shm.

Eric



_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
