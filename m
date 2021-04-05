Return-Path: <SRS0=cdS5=JC=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_RED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98F4DC433B4
	for <containers@archiver.kernel.org>; Mon,  5 Apr 2021 16:59:00 +0000 (UTC)
Received: from smtp1.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 372F6613AE
	for <containers@archiver.kernel.org>; Mon,  5 Apr 2021 16:59:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 372F6613AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=xmission.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp1.osuosl.org (Postfix) with ESMTP id ED12F848FC;
	Mon,  5 Apr 2021 16:58:59 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp1.osuosl.org ([127.0.0.1])
	by localhost (smtp1.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id n-qUAlwiJ7VA; Mon,  5 Apr 2021 16:58:59 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp1.osuosl.org (Postfix) with ESMTP id 0E34D848F2;
	Mon,  5 Apr 2021 16:58:58 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id DBA64C000C;
	Mon,  5 Apr 2021 16:58:58 +0000 (UTC)
Received: from smtp1.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 722C4C000A
 for <containers@lists.linux-foundation.org>;
 Mon,  5 Apr 2021 16:58:57 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp1.osuosl.org (Postfix) with ESMTP id 6AA90848FC
 for <containers@lists.linux-foundation.org>;
 Mon,  5 Apr 2021 16:58:57 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp1.osuosl.org ([127.0.0.1])
 by localhost (smtp1.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id bb2Bx7e7wpPx
 for <containers@lists.linux-foundation.org>;
 Mon,  5 Apr 2021 16:58:56 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.8.0
Received: from out02.mta.xmission.com (out02.mta.xmission.com [166.70.13.232])
 by smtp1.osuosl.org (Postfix) with ESMTPS id E2520848F2
 for <containers@lists.linux-foundation.org>;
 Mon,  5 Apr 2021 16:58:56 +0000 (UTC)
Received: from in02.mta.xmission.com ([166.70.13.52])
 by out02.mta.xmission.com with esmtps (TLS1.3) tls
 TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384 (Exim 4.93)
 (envelope-from <ebiederm@xmission.com>)
 id 1lTSYx-00GsfU-Nz; Mon, 05 Apr 2021 10:58:55 -0600
Received: from ip68-227-160-95.om.om.cox.net ([68.227.160.95]
 helo=fess.xmission.com)
 by in02.mta.xmission.com with esmtpsa (TLS1.3) tls
 TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384 (Exim 4.93)
 (envelope-from <ebiederm@xmission.com>)
 id 1lTSYw-000Z25-OY; Mon, 05 Apr 2021 10:58:55 -0600
From: ebiederm@xmission.com (Eric W. Biederman)
To: Alexey Gladkov <gladkov.alexey@gmail.com>
References: <cover.1616533074.git.gladkov.alexey@gmail.com>
 <9c8b24db40a030347652ee58f44028ca1081acfa.1616533074.git.gladkov.alexey@gmail.com>
Date: Mon, 05 Apr 2021 11:58:51 -0500
In-Reply-To: <9c8b24db40a030347652ee58f44028ca1081acfa.1616533074.git.gladkov.alexey@gmail.com>
 (Alexey Gladkov's message of "Tue, 23 Mar 2021 21:59:15 +0100")
Message-ID: <m1r1jollbo.fsf@fess.ebiederm.org>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
X-XM-SPF: eid=1lTSYw-000Z25-OY; ; ; mid=<m1r1jollbo.fsf@fess.ebiederm.org>; ; ;
 hst=in02.mta.xmission.com; ; ; ip=68.227.160.95; ; ; frm=ebiederm@xmission.com;
 ; ; spf=neutral
X-XM-AID: U2FsdGVkX1/lRCz+abrVYSdzhXtMBllzyd5yG1jeH8w=
X-SA-Exim-Connect-IP: 68.227.160.95
X-SA-Exim-Mail-From: ebiederm@xmission.com
Subject: Re: [PATCH v9 6/8] Reimplement RLIMIT_SIGPENDING on top of ucounts
X-SA-Exim-Version: 4.2.1 (built Sat, 08 Feb 2020 21:53:50 +0000)
X-SA-Exim-Scanned: Yes (on in02.mta.xmission.com)
Cc: Jens Axboe <axboe@kernel.dk>, Kees Cook <keescook@chromium.org>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linus Torvalds <torvalds@linux-foundation.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Jann Horn <jannh@google.com>, LKML <linux-kernel@vger.kernel.org>,
 Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org,
 Andrew Morton <akpm@linux-foundation.org>, Alexey Gladkov <legion@kernel.org>
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


A small bug below.

Eric


> diff --git a/kernel/signal.c b/kernel/signal.c
> index f2a1b898da29..1b537d9de447 100644
> --- a/kernel/signal.c
> +++ b/kernel/signal.c
> @@ -413,49 +413,44 @@ void task_join_group_stop(struct task_struct *task)
>  static struct sigqueue *
>  __sigqueue_alloc(int sig, struct task_struct *t, gfp_t flags, int override_rlimit)
>  {
> -	struct sigqueue *q = NULL;
> -	struct user_struct *user;
> -	int sigpending;
> +	struct sigqueue *q = kmem_cache_alloc(sigqueue_cachep, flags);
>  
> -	/*
> -	 * Protect access to @t credentials. This can go away when all
> -	 * callers hold rcu read lock.
> -	 *
> -	 * NOTE! A pending signal will hold on to the user refcount,
> -	 * and we get/put the refcount only when the sigpending count
> -	 * changes from/to zero.
> -	 */
> -	rcu_read_lock();
> -	user = __task_cred(t)->user;
> -	sigpending = atomic_inc_return(&user->sigpending);
> -	if (sigpending == 1)
> -		get_uid(user);
> -	rcu_read_unlock();
> +	if (likely(q != NULL)) {
> +		bool overlimit;
>  
> -	if (override_rlimit || likely(sigpending <= task_rlimit(t, RLIMIT_SIGPENDING))) {
> -		q = kmem_cache_alloc(sigqueue_cachep, flags);
> -	} else {
> -		print_dropped_signal(sig);
> -	}
> -
> -	if (unlikely(q == NULL)) {
> -		if (atomic_dec_and_test(&user->sigpending))
> -			free_uid(user);
> -	} else {
>  		INIT_LIST_HEAD(&q->list);
>  		q->flags = 0;
> -		q->user = user;
> +
> +		/*
> +		 * Protect access to @t credentials. This can go away when all
> +		 * callers hold rcu read lock.
> +		 */
> +		rcu_read_lock();
> +		q->ucounts = get_ucounts(task_ucounts(t));
> +		if (q->ucounts) {
> +			overlimit = inc_rlimit_ucounts_and_test(q->ucounts, UCOUNT_RLIMIT_SIGPENDING,
> +					1, task_rlimit(t, RLIMIT_SIGPENDING));
> +
> +			if (override_rlimit || likely(!overlimit)) {
> +				rcu_read_unlock();
> +				return q;
> +			}
> +		}
> +		rcu_read_unlock();

I believe you need to call __sigqueue_free here.

>  	}
>  
> -	return q;
> +	print_dropped_signal(sig);
> +	return NULL;
>  }
>  
>  static void __sigqueue_free(struct sigqueue *q)
>  {
>  	if (q->flags & SIGQUEUE_PREALLOC)
>  		return;
> -	if (atomic_dec_and_test(&q->user->sigpending))
> -		free_uid(q->user);
> +	if (q->ucounts) {
> +		dec_rlimit_ucounts(q->ucounts, UCOUNT_RLIMIT_SIGPENDING, 1);
> +		put_ucounts(q->ucounts);
> +	}
>  	kmem_cache_free(sigqueue_cachep, q);
>  }
>  

Eric
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
