Return-Path: <SRS0=HbWT=HY=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 373D0C433DB
	for <containers@archiver.kernel.org>; Mon, 22 Feb 2021 10:28:07 +0000 (UTC)
Received: from smtp3.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id A2B6D64DA3
	for <containers@archiver.kernel.org>; Mon, 22 Feb 2021 10:28:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A2B6D64DA3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp3.osuosl.org (Postfix) with ESMTP id 584586F562;
	Mon, 22 Feb 2021 10:28:06 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp3.osuosl.org ([127.0.0.1])
	by localhost (smtp3.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id QFFItRS6zBCk; Mon, 22 Feb 2021 10:28:05 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp3.osuosl.org (Postfix) with ESMTP id D66016F556;
	Mon, 22 Feb 2021 10:28:04 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id AC3EEC000B;
	Mon, 22 Feb 2021 10:28:04 +0000 (UTC)
Received: from smtp3.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 4E691C0001
 for <containers@lists.linux-foundation.org>;
 Mon, 22 Feb 2021 10:28:03 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp3.osuosl.org (Postfix) with ESMTP id 2712D6F562
 for <containers@lists.linux-foundation.org>;
 Mon, 22 Feb 2021 10:28:03 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp3.osuosl.org ([127.0.0.1])
 by localhost (smtp3.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 2aAG5-L80EQB
 for <containers@lists.linux-foundation.org>;
 Mon, 22 Feb 2021 10:28:02 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.8.0
Received: from raptor.unsafe.ru (raptor.unsafe.ru [5.9.43.93])
 by smtp3.osuosl.org (Postfix) with ESMTP id 54A316F556
 for <containers@lists.linux-foundation.org>;
 Mon, 22 Feb 2021 10:28:02 +0000 (UTC)
Received: from example.org (ip-94-113-225-162.net.upcbroadband.cz
 [94.113.225.162])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits))
 (No client certificate requested)
 by raptor.unsafe.ru (Postfix) with ESMTPSA id E9233209FA;
 Mon, 22 Feb 2021 10:27:36 +0000 (UTC)
Date: Mon, 22 Feb 2021 11:27:33 +0100
From: Alexey Gladkov <gladkov.alexey@gmail.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH v6 0/7] Count rlimits in each user namespace
Message-ID: <20210222102733.gic3q7dniljlbosm@example.org>
References: <cover.1613392826.git.gladkov.alexey@gmail.com>
 <CAHk-=wjsmAXyYZs+QQFQtY=w-pOOSWoi-ukvoBVVjBnb+v3q7A@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CAHk-=wjsmAXyYZs+QQFQtY=w-pOOSWoi-ukvoBVVjBnb+v3q7A@mail.gmail.com>
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.6.1
 (raptor.unsafe.ru [5.9.43.93]); Mon, 22 Feb 2021 10:28:01 +0000 (UTC)
Cc: Jens Axboe <axboe@kernel.dk>, Kees Cook <keescook@chromium.org>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Jann Horn <jannh@google.com>, LKML <linux-kernel@vger.kernel.org>,
 Oleg Nesterov <oleg@redhat.com>, Linux-MM <linux-mm@kvack.org>,
 "Eric W . Biederman" <ebiederm@xmission.com>,
 Andrew Morton <akpm@linux-foundation.org>, io-uring <io-uring@vger.kernel.org>
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

On Sun, Feb 21, 2021 at 02:20:00PM -0800, Linus Torvalds wrote:
> On Mon, Feb 15, 2021 at 4:42 AM Alexey Gladkov <gladkov.alexey@gmail.com> wrote:
> >
> > These patches are for binding the rlimit counters to a user in user namespace.
> 
> So this is now version 6, but I think the kernel test robot keeps
> complaining about them causing KASAN issues.
> 
> The complaints seem to change, so I'm hoping they get fixed, but it
> does seem like every version there's a new one. Hmm?

First, KASAN found an unexpected bug in the second patch (Add a reference
to ucounts for each cred). Because I missed that creed_alloc_blank() is
used wider than I found.

Now KASAN has found problems in the RLIMIT_MEMLOCK which I believe I fixed
in v7.

-- 
Rgrds, legion

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
