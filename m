Return-Path: <SRS0=O+XM=JK=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08B4CC433B4
	for <containers@archiver.kernel.org>; Tue, 13 Apr 2021 17:54:06 +0000 (UTC)
Received: from smtp1.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 47841613BB
	for <containers@archiver.kernel.org>; Tue, 13 Apr 2021 17:54:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 47841613BB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp1.osuosl.org (Postfix) with ESMTP id 0A2F584579;
	Tue, 13 Apr 2021 17:54:05 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp1.osuosl.org ([127.0.0.1])
	by localhost (smtp1.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id IyBwrGjcY4UU; Tue, 13 Apr 2021 17:54:04 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp1.osuosl.org (Postfix) with ESMTP id 0BA7F84576;
	Tue, 13 Apr 2021 17:54:04 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id E09EDC000B;
	Tue, 13 Apr 2021 17:54:03 +0000 (UTC)
Received: from smtp2.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 62633C000A
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Apr 2021 17:54:02 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp2.osuosl.org (Postfix) with ESMTP id 5CA58405E9
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Apr 2021 17:54:02 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp2.osuosl.org ([127.0.0.1])
 by localhost (smtp2.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id KqsewWKmgwNl
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Apr 2021 17:54:01 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.8.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
 by smtp2.osuosl.org (Postfix) with ESMTPS id A0E53405D0
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Apr 2021 17:54:01 +0000 (UTC)
Received: by mail.kernel.org (Postfix) with ESMTPSA id 7B65461249;
 Tue, 13 Apr 2021 17:53:58 +0000 (UTC)
Date: Tue, 13 Apr 2021 19:53:55 +0200
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Rodrigo Campos <rodrigo@kinvolk.io>
Subject: Re: [PATCH 1/1] seccomp: Always "goto wait" if the list is empty
Message-ID: <20210413175355.kttgdouoyiykug5i@wittgenstein>
References: <20210413160151.3301-1-rodrigo@kinvolk.io>
 <20210413160151.3301-2-rodrigo@kinvolk.io>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20210413160151.3301-2-rodrigo@kinvolk.io>
Cc: Will Drewry <wad@chromium.org>, Kees Cook <keescook@chromium.org>,
 containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
 stable@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>,
 Alban Crequy <alban@kinvolk.io>
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

On Tue, Apr 13, 2021 at 06:01:51PM +0200, Rodrigo Campos wrote:
> It is possible for the thread with the seccomp filter attached (target)
> to be waken up by an addfd message, but the list be empty. This happens
> when the addfd ioctl on the other side (seccomp agent) is interrupted by
> a signal such as SIGURG. In that case, the target erroneously and
> prematurely returns from the syscall to userspace even though the
> seccomp agent didn't ask for it.
> 
> This happens in the following scenario:
> 
> seccomp_notify_addfd()                                           | seccomp_do_user_notification()
>                                                                  |
>                                                                  |  err = wait_for_completion_interruptible(&n.ready);
>  complete(&knotif->ready);                                       |
>  ret = wait_for_completion_interruptible(&kaddfd.completion);    |
>  // interrupted                                                  |
>                                                                  |
>  mutex_lock(&filter->notify_lock);                               |
>  list_del(&kaddfd.list);                                         |
>  mutex_unlock(&filter->notify_lock);                             |
>                                                                  |  mutex_lock(&match->notify_lock);
>                                                                  |  // This is false, addfd is false
>                                                                  |  if (addfd && n.state != SECCOMP_NOTIFY_REPLIED)
>                                                                  |
>                                                                  |  ret = n.val;
>                                                                  |  err = n.error;
>                                                                  |  flags = n.flags;
> 
> So, the process blocked in seccomp_do_user_notification() will see a
> response. As n is 0 initialized and wasn't set, it will see a 0 as
> return value from the syscall.
> 
> The seccomp agent, when retrying the interrupted syscall, will see an
> ENOENT error as the notification no longer exists (it was already
> answered by this bug).
> 
> This patch fixes the issue by splitting the if in two parts: if we were
> woken up and the state is not replied, we will always do a "goto wait".
> And if that happens and there is an addfd element on the list, we will
> add the fd before "goto wait".
> 
> This issue is present since 5.9, when addfd was added.
> 
> Fixes: 7cf97b1254550
> Cc: stable@vger.kernel.org # 5.9+
> Signed-off-by: Rodrigo Campos <rodrigo@kinvolk.io>
> ---

So the agent will see the return value from
wait_for_completion_interruptible() and know that the addfd wasn't
successful and the target will notice that no addfd request has actually
been added and essentially try again. Seems like a decent fix and can be
backported cleanly. I assume seccomp testsuite passes.

Acked-by: Christian Brauner <christian.brauner@ubuntu.com>
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
