Return-Path: <SRS0=LRkw=JE=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA083C433B4
	for <containers@archiver.kernel.org>; Wed,  7 Apr 2021 16:56:52 +0000 (UTC)
Received: from smtp1.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 3F71D6120E
	for <containers@archiver.kernel.org>; Wed,  7 Apr 2021 16:56:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3F71D6120E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=xmission.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp1.osuosl.org (Postfix) with ESMTP id EB3E884284;
	Wed,  7 Apr 2021 16:56:51 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp1.osuosl.org ([127.0.0.1])
	by localhost (smtp1.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Em1fqv7b6cGG; Wed,  7 Apr 2021 16:56:51 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp1.osuosl.org (Postfix) with ESMTP id 0C0448428E;
	Wed,  7 Apr 2021 16:56:50 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id CCDEDC000B;
	Wed,  7 Apr 2021 16:56:50 +0000 (UTC)
Received: from smtp2.osuosl.org (smtp2.osuosl.org [IPv6:2605:bc80:3010::133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 9D0CDC000A
 for <containers@lists.linux-foundation.org>;
 Wed,  7 Apr 2021 16:56:49 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp2.osuosl.org (Postfix) with ESMTP id 983CA4040A
 for <containers@lists.linux-foundation.org>;
 Wed,  7 Apr 2021 16:56:49 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp2.osuosl.org ([127.0.0.1])
 by localhost (smtp2.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 93K2svLdk-98
 for <containers@lists.linux-foundation.org>;
 Wed,  7 Apr 2021 16:56:47 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.8.0
Received: from out03.mta.xmission.com (out03.mta.xmission.com [166.70.13.233])
 by smtp2.osuosl.org (Postfix) with ESMTPS id BE6104002B
 for <containers@lists.linux-foundation.org>;
 Wed,  7 Apr 2021 16:56:44 +0000 (UTC)
Received: from in01.mta.xmission.com ([166.70.13.51])
 by out03.mta.xmission.com with esmtps (TLS1.2) tls
 TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256 (Exim 4.93)
 (envelope-from <ebiederm@xmission.com>)
 id 1lUBTt-00CZh7-I0; Wed, 07 Apr 2021 10:56:41 -0600
Received: from ip68-227-160-95.om.om.cox.net ([68.227.160.95]
 helo=fess.xmission.com) by in01.mta.xmission.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_256_GCM_SHA384:256) (Exim 4.87)
 (envelope-from <ebiederm@xmission.com>)
 id 1lUBTs-0007Tf-91; Wed, 07 Apr 2021 10:56:41 -0600
From: ebiederm@xmission.com (Eric W. Biederman)
To: Alexey Gladkov <gladkov.alexey@gmail.com>
References: <cover.1616533074.git.gladkov.alexey@gmail.com>
 <8f0c2888b4e92d51239e154b82d75972e7e39833.1616533074.git.gladkov.alexey@gmail.com>
 <m1y2dwllfg.fsf@fess.ebiederm.org>
 <20210406154444.icpvezlq3izzxf5t@example.org>
Date: Wed, 07 Apr 2021 11:56:36 -0500
In-Reply-To: <20210406154444.icpvezlq3izzxf5t@example.org> (Alexey Gladkov's
 message of "Tue, 6 Apr 2021 17:44:44 +0200")
Message-ID: <m1eefmjanv.fsf@fess.ebiederm.org>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
X-XM-SPF: eid=1lUBTs-0007Tf-91; ; ; mid=<m1eefmjanv.fsf@fess.ebiederm.org>; ; ;
 hst=in01.mta.xmission.com; ; ; ip=68.227.160.95; ; ; frm=ebiederm@xmission.com;
 ; ; spf=neutral
X-XM-AID: U2FsdGVkX18gGOagHueeOSvjjB9O1FjohVGYorUmAaY=
X-SA-Exim-Connect-IP: 68.227.160.95
X-SA-Exim-Mail-From: ebiederm@xmission.com
Subject: Re: [PATCH v9 4/8] Reimplement RLIMIT_NPROC on top of ucounts
X-SA-Exim-Version: 4.2.1 (built Thu, 05 May 2016 13:38:54 -0600)
X-SA-Exim-Scanned: Yes (on in01.mta.xmission.com)
Cc: Jens Axboe <axboe@kernel.dk>, Kees Cook <keescook@chromium.org>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Jann Horn <jannh@google.com>, LKML <linux-kernel@vger.kernel.org>,
 Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org,
 Linus Torvalds <torvalds@linux-foundation.org>,
 Andrew Morton <akpm@linux-foundation.org>
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

Alexey Gladkov <gladkov.alexey@gmail.com> writes:

> On Mon, Apr 05, 2021 at 11:56:35AM -0500, Eric W. Biederman wrote:
>>
>> Also when setting ns->ucount_max[] in create_user_ns because one value
>> is signed and the other is unsigned.  Care should be taken so that
>> rlimit_infinity is translated into the largest positive value the
>> type can hold.
>
> You mean like that ?
>
> ns->ucount_max[UCOUNT_RLIMIT_NPROC] = rlimit(RLIMIT_NPROC) <= LONG_MAX ?
> 	rlimit(RLIMIT_NPROC) : LONG_MAX;
> ns->ucount_max[UCOUNT_RLIMIT_MSGQUEUE] = rlimit(RLIMIT_MSGQUEUE) <= LONG_MAX ?
> 	rlimit(RLIMIT_MSGQUEUE) : LONG_MAX;
> ns->ucount_max[UCOUNT_RLIMIT_SIGPENDING] = rlimit(RLIMIT_SIGPENDING) <= LONG_MAX ?
> 	rlimit(RLIMIT_SIGPENDING) : LONG_MAX;
> ns->ucount_max[UCOUNT_RLIMIT_MEMLOCK] = rlimit(RLIMIT_MEMLOCK) <= LONG_MAX ?
> 	rlimit(RLIMIT_MEMLOCK) : LONG_MAX;

Yes.

I only got as far as:
if (rlimit(RLIMI_NNN) == RLIM_INFINITY) {
	ns->ucount_max[UCOUNT_LIMIT_NNN] = LONG_MAX;
} else {
	ns->ucount_max[UCOUNT_LMIT_NNN] = rlmit(RLIMIT_NNN);
}
But forcing everything about LONG_MAX to LONG_MAX actually looks better
in practice.  Especially as that is effectively RLIMIT_INFINITY anyway.

Eric
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
