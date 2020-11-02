Return-Path: <SRS0=UpRV=EI=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12423C4742C
	for <containers@archiver.kernel.org>; Mon,  2 Nov 2020 17:55:35 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 473E022243
	for <containers@archiver.kernel.org>; Mon,  2 Nov 2020 17:55:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 473E022243
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id D13C386A5B;
	Mon,  2 Nov 2020 17:55:33 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 7O9wFCKaxqym; Mon,  2 Nov 2020 17:55:32 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id BBE4286A4F;
	Mon,  2 Nov 2020 17:55:32 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id A259DC0889;
	Mon,  2 Nov 2020 17:55:32 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 1B203C0051
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 17:55:32 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 0F0938728B
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 17:55:32 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id c4p3ijQ-n1dF
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 17:55:30 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by hemlock.osuosl.org (Postfix) with ESMTPS id B73E18723B
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 17:55:30 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1kZe3D-0003rS-I9; Mon, 02 Nov 2020 17:55:27 +0000
Date: Mon, 2 Nov 2020 18:55:26 +0100
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Alexey Gladkov <gladkov.alexey@gmail.com>
Subject: Re: [RFC PATCH v1 0/4] Per user namespace rlimits
Message-ID: <20201102175526.eu4npm4v2ggicvaf@wittgenstein>
References: <cover.1604335819.git.gladkov.alexey@gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <cover.1604335819.git.gladkov.alexey@gmail.com>
Cc: Kees Cook <keescook@chromium.org>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 LKML <linux-kernel@vger.kernel.org>,
 "Eric W . Biederman" <ebiederm@xmission.com>,
 Alexey Gladkov <legion@kernel.org>, Christian Brauner <christian@brauner.io>
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

On Mon, Nov 02, 2020 at 05:50:29PM +0100, Alexey Gladkov wrote:
> Preface
> -------
> These patches are for binding the rlimits to a user in the user namespace.
> This patch set can be applied on top of:
> 
> git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git v5.8-2-g43e210d68200
> 
> Problem
> -------
> Some rlimits are set per user: RLIMIT_NPROC, RLIMIT_MEMLOCK, RLIMIT_SIGPENDING,
> RLIMIT_MSGQUEUE. When several containers are created from one user then
> the processes inside the containers influence each other.
> 
> Eric W. Biederman mentioned this issue [1][2][3].
> 
> Introduced changes
> ------------------
> To fix this problem, you can bind the counter of the specified rlimits to the
> user within the user namespace. By default, to preserve backward compatibility,
> only the initial user namespace is used. This patch adds one more prctl
> parameter to change the binding to the user namespace.
> 
> This will not cause the user to take more resources than allowed in the parent
> user namespace because it only virtualizes the rlimit counter. Limits in all
> parent user namespaces are taken into account.
> 
> For example, this allows us to run multiple containers by the same user and
> set the RLIMIT_NPROC to 1 inside.

Thanks for picking this up and working on it. This would definitely fix
many issues for folks running unprivileged containers using a single id
map which is the default behavior for LXC/LXD and so very valuable to
us.

Christian

> 
> ToDo
> ----
> * RLIMIT_MEMLOCK, RLIMIT_SIGPENDING and RLIMIT_MSGQUEUE are not implemented.
> * No documentation.
> * No tests.
> 
> [1] https://lore.kernel.org/containers/87imd2incs.fsf@x220.int.ebiederm.org/
> [2] https://lists.linuxfoundation.org/pipermail/containers/2020-August/042096.html
> [3] https://lists.linuxfoundation.org/pipermail/containers/2020-October/042524.html
> 
> Changelog
> ---------
> v1:
> * After discussion with Eric W. Biederman, I increased the size of ucounts to
>   atomic_long_t.
> * Added ucount_max to avoid the fork bomb.
> 
> --
> 
> Alexey Gladkov (4):
>   Increase size of ucounts to atomic_long_t
>   Move the user's process counter to ucounts
>   Do not allow fork if RLIMIT_NPROC is exceeded in the user namespace
>     tree
>   Allow to change the user namespace in which user rlimits are counted
> 
>  fs/exec.c                      | 13 ++++++---
>  fs/io-wq.c                     | 25 +++++++++++++-----
>  fs/io-wq.h                     |  1 +
>  fs/io_uring.c                  |  1 +
>  include/linux/cred.h           |  8 ++++++
>  include/linux/sched.h          |  3 +++
>  include/linux/sched/user.h     |  1 -
>  include/linux/user_namespace.h | 12 +++++++--
>  include/uapi/linux/prctl.h     |  5 ++++
>  kernel/cred.c                  | 44 ++++++++++++++++++++++++-------
>  kernel/exit.c                  |  2 +-
>  kernel/fork.c                  | 13 ++++++---
>  kernel/sys.c                   | 26 ++++++++++++++++--
>  kernel/ucount.c                | 48 +++++++++++++++++++++++++++++-----
>  kernel/user.c                  |  3 ++-
>  kernel/user_namespace.c        |  3 +++
>  16 files changed, 171 insertions(+), 37 deletions(-)
> 
> -- 
> 2.25.4
> 
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
