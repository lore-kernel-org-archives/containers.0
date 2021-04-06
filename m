Return-Path: <SRS0=8Bp6=JD=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0436C433ED
	for <containers@archiver.kernel.org>; Tue,  6 Apr 2021 15:55:05 +0000 (UTC)
Received: from smtp1.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 46EE1610CC
	for <containers@archiver.kernel.org>; Tue,  6 Apr 2021 15:55:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 46EE1610CC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp1.osuosl.org (Postfix) with ESMTP id 139FF84A23;
	Tue,  6 Apr 2021 15:55:05 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp1.osuosl.org ([127.0.0.1])
	by localhost (smtp1.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id aFXkwT-xgj0z; Tue,  6 Apr 2021 15:55:04 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp1.osuosl.org (Postfix) with ESMTP id 6A6CC84A1D;
	Tue,  6 Apr 2021 15:55:03 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 46098C000B;
	Tue,  6 Apr 2021 15:55:03 +0000 (UTC)
Received: from smtp2.osuosl.org (smtp2.osuosl.org [IPv6:2605:bc80:3010::133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 17F41C000A
 for <containers@lists.linux-foundation.org>;
 Tue,  6 Apr 2021 15:55:02 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp2.osuosl.org (Postfix) with ESMTP id 0268840109
 for <containers@lists.linux-foundation.org>;
 Tue,  6 Apr 2021 15:55:02 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp2.osuosl.org ([127.0.0.1])
 by localhost (smtp2.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id vR98N5dxJK79
 for <containers@lists.linux-foundation.org>;
 Tue,  6 Apr 2021 15:54:59 +0000 (UTC)
X-Greylist: delayed 00:10:10 by SQLgrey-1.8.0
Received: from vmicros1.altlinux.org (vmicros1.altlinux.org [194.107.17.57])
 by smtp2.osuosl.org (Postfix) with ESMTP id 213DE40196
 for <containers@lists.linux-foundation.org>;
 Tue,  6 Apr 2021 15:54:59 +0000 (UTC)
Received: from imap.altlinux.org (imap.altlinux.org [194.107.17.38])
 by vmicros1.altlinux.org (Postfix) with ESMTP id 719BB72C8B1;
 Tue,  6 Apr 2021 18:44:47 +0300 (MSK)
Received: from example.org (ip-94-113-225-162.net.upcbroadband.cz
 [94.113.225.162])
 by imap.altlinux.org (Postfix) with ESMTPSA id 16D4F4A4729;
 Tue,  6 Apr 2021 18:44:45 +0300 (MSK)
Date: Tue, 6 Apr 2021 17:44:44 +0200
From: Alexey Gladkov <gladkov.alexey@gmail.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: Re: [PATCH v9 4/8] Reimplement RLIMIT_NPROC on top of ucounts
Message-ID: <20210406154444.icpvezlq3izzxf5t@example.org>
References: <cover.1616533074.git.gladkov.alexey@gmail.com>
 <8f0c2888b4e92d51239e154b82d75972e7e39833.1616533074.git.gladkov.alexey@gmail.com>
 <m1y2dwllfg.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <m1y2dwllfg.fsf@fess.ebiederm.org>
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

On Mon, Apr 05, 2021 at 11:56:35AM -0500, Eric W. Biederman wrote:
>
> Also when setting ns->ucount_max[] in create_user_ns because one value
> is signed and the other is unsigned.  Care should be taken so that
> rlimit_infinity is translated into the largest positive value the
> type can hold.

You mean like that ?

ns->ucount_max[UCOUNT_RLIMIT_NPROC] = rlimit(RLIMIT_NPROC) <= LONG_MAX ?
	rlimit(RLIMIT_NPROC) : LONG_MAX;
ns->ucount_max[UCOUNT_RLIMIT_MSGQUEUE] = rlimit(RLIMIT_MSGQUEUE) <= LONG_MAX ?
	rlimit(RLIMIT_MSGQUEUE) : LONG_MAX;
ns->ucount_max[UCOUNT_RLIMIT_SIGPENDING] = rlimit(RLIMIT_SIGPENDING) <= LONG_MAX ?
	rlimit(RLIMIT_SIGPENDING) : LONG_MAX;
ns->ucount_max[UCOUNT_RLIMIT_MEMLOCK] = rlimit(RLIMIT_MEMLOCK) <= LONG_MAX ?
	rlimit(RLIMIT_MEMLOCK) : LONG_MAX;

-- 
Rgrds, legion

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
