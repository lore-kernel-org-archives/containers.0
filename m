Return-Path: <SRS0=KLId=EK=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.0 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 017BFC2D0A3
	for <containers@archiver.kernel.org>; Wed,  4 Nov 2020 23:41:07 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 59AF820786
	for <containers@archiver.kernel.org>; Wed,  4 Nov 2020 23:41:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="b3mh8Itr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 59AF820786
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 5098C814F1;
	Wed,  4 Nov 2020 23:41:05 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id YFpeFbwu75Xu; Wed,  4 Nov 2020 23:41:03 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id B145187175;
	Wed,  4 Nov 2020 23:41:03 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 940A3C0889;
	Wed,  4 Nov 2020 23:41:03 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 1A705C0051
 for <containers@lists.linux-foundation.org>;
 Wed,  4 Nov 2020 23:41:02 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 082268568D
 for <containers@lists.linux-foundation.org>;
 Wed,  4 Nov 2020 23:41:02 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id qiwL+qvWJpjY
 for <containers@lists.linux-foundation.org>;
 Wed,  4 Nov 2020 23:41:01 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from us-smtp-delivery-124.mimecast.com
 (us-smtp-delivery-124.mimecast.com [216.205.24.124])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 5A1AF853FC
 for <containers@lists.linux-foundation.org>;
 Wed,  4 Nov 2020 23:41:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
 s=mimecast20190719; t=1604533259;
 h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
 in-reply-to:in-reply-to:references:references;
 bh=DVN/srVaTrtu/WkLV+++W+fY4MNzdX1yaxCwzWUhMIo=;
 b=b3mh8ItrnSmmC5NCOkqIm8+2dPxspdeasjPUVsz508kxRXxmCjGDu4DKzMMwPRCDpqUv0P
 Fe6Lj3ZRkxMGYBn5evzAhswcVJnRc0LrSVxLEX738D9Dc81kl240ri3Qj/nf5vHzG09lbT
 F/7bL0lWib/zbRp/OtZ0WzgLGyLCRuc=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-463-99fzgGGpOVS8qgAqTj97sg-1; Wed, 04 Nov 2020 18:40:56 -0500
X-MC-Unique: 99fzgGGpOVS8qgAqTj97sg-1
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com
 [10.5.11.22])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 4255F8015FB;
 Wed,  4 Nov 2020 23:40:52 +0000 (UTC)
Received: from mail (ovpn-116-241.rdu2.redhat.com [10.10.116.241])
 by smtp.corp.redhat.com (Postfix) with ESMTPS id 5593310013D7;
 Wed,  4 Nov 2020 23:40:48 +0000 (UTC)
Date: Wed, 4 Nov 2020 18:40:47 -0500
From: Andrea Arcangeli <aarcange@redhat.com>
To: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: RFC: default to spec_store_bypass_disable=prctl
 spectre_v2_user=prctl
Message-ID: <20201104234047.GA18850@redhat.com>
References: <20201104215702.GG24993@redhat.com>
 <87eel8lnbe.fsf@nanos.tec.linutronix.de>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <87eel8lnbe.fsf@nanos.tec.linutronix.de>
User-Agent: Mutt/1.14.7 (2020-08-29)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
Cc: Tobin Feldman-Fitzthum <tobin@ibm.com>,
 Hubertus Franke <frankeh@us.ibm.com>, Jack Chen <jianyan2@illinois.edu>,
 Giuseppe Scrivano <gscrivan@redhat.com>, YiFei Zhu <yifeifz2@illinois.edu>,
 Waiman Long <longman@redhat.com>, Tianyin Xu <tyxu@illinois.edu>,
 Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>,
 Jiri Kosina <jikos@kernel.org>, Valentin Rothberg <vrothber@redhat.com>,
 Josep Torrellas <torrella@illinois.edu>, Will Drewry <wad@chromium.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 kernel list <linux-kernel@vger.kernel.org>,
 Andy Lutomirski <luto@amacapital.net>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>,
 David Laight <David.Laight@aculab.com>, bpf <bpf@vger.kernel.org>
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

On Thu, Nov 05, 2020 at 12:22:29AM +0100, Thomas Gleixner wrote:
> On Wed, Nov 04 2020 at 16:57, Andrea Arcangeli wrote:
> > ---
> >  Documentation/admin-guide/kernel-parameters.txt | 5 ++---
> 
> Is Documentation/admin-guide/hw-vuln/* still correct? If not, please
> fix that as well.

Right, I missed two seccomp mention that needed removing there too.

Also I noticed below I intended PR_SPEC_INDIRECT_BRANCH
(PR_SPEC_STORE_BYPASS there is no point to even mention it as a
possibility to be considered), so I corrected it.

==
uses no JIT. If sshd prefers to keep doing the STIBP window dressing
exercise, it still can even after this change of defaults by opting-in
with PR_SPEC_STORE_BYPASS.
==

> > >with PR_SPEC_INDIRECT_BRANCH.

> Aside of that please send patches in the proper format so they do not
> need manual interaction when picking them up.

This was a RFC per subject since I expected it wouldn't be final, but
I added Kees' Acked-by and I'll submit it now.

Thanks,
Andrea

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
