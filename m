Return-Path: <SRS0=vxAo=GQ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7447AC433E0
	for <containers@archiver.kernel.org>; Wed, 13 Jan 2021 16:32:54 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 981E323442
	for <containers@archiver.kernel.org>; Wed, 13 Jan 2021 16:32:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 981E323442
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=xmission.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id EC4E186538;
	Wed, 13 Jan 2021 16:32:52 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id MHaza-o2lp-J; Wed, 13 Jan 2021 16:32:51 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id CD88886529;
	Wed, 13 Jan 2021 16:32:51 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id B0D3BC088B;
	Wed, 13 Jan 2021 16:32:51 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 83183C013A
 for <containers@lists.linux-foundation.org>;
 Wed, 13 Jan 2021 16:32:50 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 716C987263
 for <containers@lists.linux-foundation.org>;
 Wed, 13 Jan 2021 16:32:50 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id K28EujxZr2Rq
 for <containers@lists.linux-foundation.org>;
 Wed, 13 Jan 2021 16:32:45 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from out02.mta.xmission.com (out02.mta.xmission.com [166.70.13.232])
 by hemlock.osuosl.org (Postfix) with ESMTPS id D1B4C8725F
 for <containers@lists.linux-foundation.org>;
 Wed, 13 Jan 2021 16:32:45 +0000 (UTC)
Received: from in02.mta.xmission.com ([166.70.13.52])
 by out02.mta.xmission.com with esmtps (TLS1.3) tls
 TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384 (Exim 4.93)
 (envelope-from <ebiederm@xmission.com>)
 id 1kzj4e-006oSo-Ji; Wed, 13 Jan 2021 09:32:44 -0700
Received: from ip68-227-160-95.om.om.cox.net ([68.227.160.95]
 helo=x220.xmission.com)
 by in02.mta.xmission.com with esmtpsa (TLS1.3) tls
 TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384 (Exim 4.93)
 (envelope-from <ebiederm@xmission.com>)
 id 1kzj4d-009Vz0-HQ; Wed, 13 Jan 2021 09:32:44 -0700
From: ebiederm@xmission.com (Eric W. Biederman)
To: Alexey Gladkov <gladkov.alexey@gmail.com>
References: <cover.1610299857.git.gladkov.alexey@gmail.com>
 <447547b12bba1894d3f1f79d6408dfc60b219b0c.1610299857.git.gladkov.alexey@gmail.com>
Date: Wed, 13 Jan 2021 10:31:40 -0600
In-Reply-To: <447547b12bba1894d3f1f79d6408dfc60b219b0c.1610299857.git.gladkov.alexey@gmail.com>
 (Alexey Gladkov's message of "Sun, 10 Jan 2021 18:33:40 +0100")
Message-ID: <878s8wdcib.fsf@x220.int.ebiederm.org>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
X-XM-SPF: eid=1kzj4d-009Vz0-HQ; ; ; mid=<878s8wdcib.fsf@x220.int.ebiederm.org>;
 ; ; hst=in02.mta.xmission.com; ; ; ip=68.227.160.95; ; ;
 frm=ebiederm@xmission.com; ; ; spf=neutral
X-XM-AID: U2FsdGVkX195fKSBqSZ+lYzEZIXlkNCqt38tQhw2MoY=
X-SA-Exim-Connect-IP: 68.227.160.95
X-SA-Exim-Mail-From: ebiederm@xmission.com
Subject: Re: [RFC PATCH v2 1/8] Use atomic type for ucounts reference counting
X-SA-Exim-Version: 4.2.1 (built Sat, 08 Feb 2020 21:53:50 +0000)
X-SA-Exim-Scanned: Yes (on in02.mta.xmission.com)
Cc: Kees Cook <keescook@chromium.org>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linus Torvalds <torvalds@linux-foundation.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 LKML <linux-kernel@vger.kernel.org>, Alexey Gladkov <legion@kernel.org>,
 Christian Brauner <christian@brauner.io>
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

We might want to use refcount_t instead of atomic_t.  Not a big deal
either way.

> Signed-off-by: Alexey Gladkov <gladkov.alexey@gmail.com>
> ---
>  include/linux/user_namespace.h |  2 +-
>  kernel/ucount.c                | 10 +++++-----
>  2 files changed, 6 insertions(+), 6 deletions(-)
>
> diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
> index 64cf8ebdc4ec..84fefa9247c4 100644
> --- a/include/linux/user_namespace.h
> +++ b/include/linux/user_namespace.h
> @@ -92,7 +92,7 @@ struct ucounts {
>  	struct hlist_node node;
>  	struct user_namespace *ns;
>  	kuid_t uid;
> -	int count;
> +	atomic_t count;
>  	atomic_t ucount[UCOUNT_COUNTS];
>  };
>  
> diff --git a/kernel/ucount.c b/kernel/ucount.c
> index 11b1596e2542..0f2c7c11df19 100644
> --- a/kernel/ucount.c
> +++ b/kernel/ucount.c
> @@ -141,7 +141,8 @@ static struct ucounts *get_ucounts(struct user_namespace *ns, kuid_t uid)
>  
>  		new->ns = ns;
>  		new->uid = uid;
> -		new->count = 0;
> +
> +		atomic_set(&new->count, 0);
>  
>  		spin_lock_irq(&ucounts_lock);
>  		ucounts = find_ucounts(ns, uid, hashent);
> @@ -152,10 +153,10 @@ static struct ucounts *get_ucounts(struct user_namespace *ns, kuid_t uid)
>  			ucounts = new;
>  		}
>  	}
> -	if (ucounts->count == INT_MAX)
> +	if (atomic_read(&ucounts->count) == INT_MAX)
>  		ucounts = NULL;
>  	else
> -		ucounts->count += 1;
> +		atomic_inc(&ucounts->count);
>  	spin_unlock_irq(&ucounts_lock);
>  	return ucounts;
>  }
> @@ -165,8 +166,7 @@ static void put_ucounts(struct ucounts *ucounts)
>  	unsigned long flags;
>  
>  	spin_lock_irqsave(&ucounts_lock, flags);
> -	ucounts->count -= 1;
> -	if (!ucounts->count)
> +	if (atomic_dec_and_test(&ucounts->count))
>  		hlist_del_init(&ucounts->node);
>  	else
>  		ucounts = NULL;


This can become:
static void put_ucounts(struct ucounts *ucounts)
{
	unsigned long flags;

        if (atomic_dec_and_lock_irqsave(&ucounts->count, &ucounts_lock, flags)) {
        	hlist_del_init(&ucounts->node);
                spin_unlock_irqrestore(&ucounts_lock);
                kfree(ucounts);
        }
}

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
