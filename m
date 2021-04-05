Return-Path: <SRS0=cdS5=JC=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_RED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2BA39C43460
	for <containers@archiver.kernel.org>; Mon,  5 Apr 2021 17:01:52 +0000 (UTC)
Received: from smtp1.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id BAEB6613AF
	for <containers@archiver.kernel.org>; Mon,  5 Apr 2021 17:01:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BAEB6613AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=xmission.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp1.osuosl.org (Postfix) with ESMTP id 75B94839A4;
	Mon,  5 Apr 2021 17:01:51 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp1.osuosl.org ([127.0.0.1])
	by localhost (smtp1.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id KzNZrebKlXfv; Mon,  5 Apr 2021 17:01:50 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp1.osuosl.org (Postfix) with ESMTP id 6E2E084C2C;
	Mon,  5 Apr 2021 17:01:50 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 4B1E9C000C;
	Mon,  5 Apr 2021 17:01:50 +0000 (UTC)
Received: from smtp2.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 94748C000A
 for <containers@lists.linux-foundation.org>;
 Mon,  5 Apr 2021 17:01:49 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp2.osuosl.org (Postfix) with ESMTP id 6F97D403A2
 for <containers@lists.linux-foundation.org>;
 Mon,  5 Apr 2021 17:01:49 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp2.osuosl.org ([127.0.0.1])
 by localhost (smtp2.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id p_W0NVl7Ewyr
 for <containers@lists.linux-foundation.org>;
 Mon,  5 Apr 2021 17:01:48 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.8.0
Received: from out01.mta.xmission.com (out01.mta.xmission.com [166.70.13.231])
 by smtp2.osuosl.org (Postfix) with ESMTPS id 604C740264
 for <containers@lists.linux-foundation.org>;
 Mon,  5 Apr 2021 17:01:48 +0000 (UTC)
Received: from in01.mta.xmission.com ([166.70.13.51])
 by out01.mta.xmission.com with esmtps (TLS1.2) tls
 TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256 (Exim 4.93)
 (envelope-from <ebiederm@xmission.com>)
 id 1lTSbj-00HPys-0w; Mon, 05 Apr 2021 11:01:47 -0600
Received: from ip68-227-160-95.om.om.cox.net ([68.227.160.95]
 helo=fess.xmission.com) by in01.mta.xmission.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_256_GCM_SHA384:256) (Exim 4.87)
 (envelope-from <ebiederm@xmission.com>)
 id 1lTSbh-0008Vo-Ta; Mon, 05 Apr 2021 11:01:46 -0600
From: ebiederm@xmission.com (Eric W. Biederman)
To: Alexey Gladkov <gladkov.alexey@gmail.com>
References: <cover.1616533074.git.gladkov.alexey@gmail.com>
 <54956fd06ab4a9938421f345ecf2e1518161cb38.1616533074.git.gladkov.alexey@gmail.com>
Date: Mon, 05 Apr 2021 12:01:41 -0500
In-Reply-To: <54956fd06ab4a9938421f345ecf2e1518161cb38.1616533074.git.gladkov.alexey@gmail.com>
 (Alexey Gladkov's message of "Tue, 23 Mar 2021 21:59:12 +0100")
Message-ID: <m1eefoll6y.fsf@fess.ebiederm.org>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
X-XM-SPF: eid=1lTSbh-0008Vo-Ta; ; ; mid=<m1eefoll6y.fsf@fess.ebiederm.org>; ; ;
 hst=in01.mta.xmission.com; ; ; ip=68.227.160.95; ; ; frm=ebiederm@xmission.com;
 ; ; spf=neutral
X-XM-AID: U2FsdGVkX1/6QFidO/5lE0s5jY0UtdtqKB+He4MOhKY=
X-SA-Exim-Connect-IP: 68.227.160.95
X-SA-Exim-Mail-From: ebiederm@xmission.com
Subject: Re: [PATCH v9 3/8] Use atomic_t for ucounts reference counting
X-SA-Exim-Version: 4.2.1 (built Thu, 05 May 2016 13:38:54 -0600)
X-SA-Exim-Scanned: Yes (on in01.mta.xmission.com)
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

Alexey Gladkov <gladkov.alexey@gmail.com> writes:

> The current implementation of the ucounts reference counter requires the
> use of spin_lock. We're going to use get_ucounts() in more performance
> critical areas like a handling of RLIMIT_SIGPENDING.
>
> Now we need to use spin_lock only if we want to change the hashtable.
>
> v9:
> * Use a negative value to check that the ucounts->count is close to
>   overflow.


Overall this looks good, one small issue below.

Eric

> diff --git a/kernel/ucount.c b/kernel/ucount.c
> index 50cc1dfb7d28..7bac19bb3f1e 100644
> --- a/kernel/ucount.c
> +++ b/kernel/ucount.c
> @@ -11,7 +11,7 @@
>  struct ucounts init_ucounts = {
>  	.ns    = &init_user_ns,
>  	.uid   = GLOBAL_ROOT_UID,
> -	.count = 1,
> +	.count = ATOMIC_INIT(1),
>  };
>  
>  #define UCOUNTS_HASHTABLE_BITS 10
> @@ -139,6 +139,15 @@ static void hlist_add_ucounts(struct ucounts *ucounts)
>  	spin_unlock_irq(&ucounts_lock);
>  }
>  
> +struct ucounts *get_ucounts(struct ucounts *ucounts)
> +{
> +	if (ucounts && atomic_add_negative(1, &ucounts->count)) {
> +		atomic_dec(&ucounts->count);
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^

To handle the pathological case of all of the other uses calling
put_ucounts after the value goes negative, the above should
be put_ucounts intead of atomic_dec.


> +		ucounts = NULL;
> +	}
> +	return ucounts;
> +}
> +
>  struct ucounts *alloc_ucounts(struct user_namespace *ns, kuid_t uid)
>  {
>  	struct hlist_head *hashent = ucounts_hashentry(ns, uid);
> @@ -155,7 +164,7 @@ struct ucounts *alloc_ucounts(struct user_namespace *ns, kuid_t uid)
>  
>  		new->ns = ns;
>  		new->uid = uid;
> -		new->count = 0;
> +		atomic_set(&new->count, 1);
>  
>  		spin_lock_irq(&ucounts_lock);
>  		ucounts = find_ucounts(ns, uid, hashent);
> @@ -163,33 +172,12 @@ struct ucounts *alloc_ucounts(struct user_namespace *ns, kuid_t uid)
>  			kfree(new);
>  		} else {
>  			hlist_add_head(&new->node, hashent);
> -			ucounts = new;
> +			spin_unlock_irq(&ucounts_lock);
> +			return new;
>  		}
>  	}
> -	if (ucounts->count == INT_MAX)
> -		ucounts = NULL;
> -	else
> -		ucounts->count += 1;
>  	spin_unlock_irq(&ucounts_lock);
> -	return ucounts;
> -}
> -
> -struct ucounts *get_ucounts(struct ucounts *ucounts)
> -{
> -	unsigned long flags;
> -
> -	if (!ucounts)
> -		return NULL;
> -
> -	spin_lock_irqsave(&ucounts_lock, flags);
> -	if (ucounts->count == INT_MAX) {
> -		WARN_ONCE(1, "ucounts: counter has reached its maximum value");
> -		ucounts = NULL;
> -	} else {
> -		ucounts->count += 1;
> -	}
> -	spin_unlock_irqrestore(&ucounts_lock, flags);
> -
> +	ucounts = get_ucounts(ucounts);
>  	return ucounts;
>  }
>  
> @@ -197,15 +185,12 @@ void put_ucounts(struct ucounts *ucounts)
>  {
>  	unsigned long flags;
>  
> -	spin_lock_irqsave(&ucounts_lock, flags);
> -	ucounts->count -= 1;
> -	if (!ucounts->count)
> +	if (atomic_dec_and_test(&ucounts->count)) {
> +		spin_lock_irqsave(&ucounts_lock, flags);
>  		hlist_del_init(&ucounts->node);
> -	else
> -		ucounts = NULL;
> -	spin_unlock_irqrestore(&ucounts_lock, flags);
> -
> -	kfree(ucounts);
> +		spin_unlock_irqrestore(&ucounts_lock, flags);
> +		kfree(ucounts);
> +	}
>  }
>  
>  static inline bool atomic_long_inc_below(atomic_long_t *v, int u)
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
