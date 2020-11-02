Return-Path: <SRS0=UpRV=EI=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3E73C2D0A3
	for <containers@archiver.kernel.org>; Mon,  2 Nov 2020 18:03:12 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 271CA21D91
	for <containers@archiver.kernel.org>; Mon,  2 Nov 2020 18:03:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 271CA21D91
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 9CACE2044B;
	Mon,  2 Nov 2020 18:03:11 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id IFtTbCNbwsd9; Mon,  2 Nov 2020 18:03:09 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id AB44120384;
	Mon,  2 Nov 2020 18:03:09 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 8F7DCC088B;
	Mon,  2 Nov 2020 18:03:09 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 996BBC0051
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 18:03:08 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 6FFC3203E8
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 18:03:08 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id Ught9Wb9Olem
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 18:03:06 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by silver.osuosl.org (Postfix) with ESMTPS id AFA4B20384
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 18:03:06 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1kZeAZ-0004RJ-CZ; Mon, 02 Nov 2020 18:03:03 +0000
Date: Mon, 2 Nov 2020 19:03:01 +0100
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Alexey Gladkov <gladkov.alexey@gmail.com>
Subject: Re: [RFC PATCH v1 1/4] Increase size of ucounts to atomic_long_t
Message-ID: <20201102180301.dup2cmbqdyrexp22@wittgenstein>
References: <cover.1604335819.git.gladkov.alexey@gmail.com>
 <f3c95ffedbab07f05e0e6e4e5a8bdd6c358194e7.1604335819.git.gladkov.alexey@gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <f3c95ffedbab07f05e0e6e4e5a8bdd6c358194e7.1604335819.git.gladkov.alexey@gmail.com>
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

On Mon, Nov 02, 2020 at 05:50:30PM +0100, Alexey Gladkov wrote:
> In order to be able to use ucounts for rlimits, the size must be increased.
> For example user_struct.mq_bytes (RLIMIT_MSGQUEUE) is unsigned long.

I don't have any issues with this change I just wonder what the exact
reason is. It's not immediately obvious to me.

> 
> Signed-off-by: Alexey Gladkov <gladkov.alexey@gmail.com>
> ---
>  include/linux/user_namespace.h |  4 ++--
>  kernel/ucount.c                | 14 +++++++-------
>  2 files changed, 9 insertions(+), 9 deletions(-)
> 
> diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
> index 6ef1c7109fc4..fc75af812d73 100644
> --- a/include/linux/user_namespace.h
> +++ b/include/linux/user_namespace.h
> @@ -86,7 +86,7 @@ struct user_namespace {
>  	struct ctl_table_header *sysctls;
>  #endif
>  	struct ucounts		*ucounts;
> -	int ucount_max[UCOUNT_COUNTS];
> +	long ucount_max[UCOUNT_COUNTS];
>  } __randomize_layout;
>  
>  struct ucounts {
> @@ -94,7 +94,7 @@ struct ucounts {
>  	struct user_namespace *ns;
>  	kuid_t uid;
>  	int count;
> -	atomic_t ucount[UCOUNT_COUNTS];
> +	atomic_long_t ucount[UCOUNT_COUNTS];
>  };
>  
>  extern struct user_namespace init_user_ns;
> diff --git a/kernel/ucount.c b/kernel/ucount.c
> index 11b1596e2542..7b2bca8582ef 100644
> --- a/kernel/ucount.c
> +++ b/kernel/ucount.c
> @@ -175,14 +175,14 @@ static void put_ucounts(struct ucounts *ucounts)
>  	kfree(ucounts);
>  }
>  
> -static inline bool atomic_inc_below(atomic_t *v, int u)
> +static inline bool atomic_long_inc_below(atomic_long_t *v, int u)
>  {
> -	int c, old;
> -	c = atomic_read(v);
> +	long c, old;
> +	c = atomic_long_read(v);
>  	for (;;) {
>  		if (unlikely(c >= u))
>  			return false;
> -		old = atomic_cmpxchg(v, c, c+1);
> +		old = atomic_long_cmpxchg(v, c, c+1);
>  		if (likely(old == c))
>  			return true;
>  		c = old;
> @@ -199,14 +199,14 @@ struct ucounts *inc_ucount(struct user_namespace *ns, kuid_t uid,
>  		int max;
>  		tns = iter->ns;
>  		max = READ_ONCE(tns->ucount_max[type]);
> -		if (!atomic_inc_below(&iter->ucount[type], max))
> +		if (!atomic_long_inc_below(&iter->ucount[type], max))
>  			goto fail;
>  	}
>  	return ucounts;
>  fail:
>  	bad = iter;
>  	for (iter = ucounts; iter != bad; iter = iter->ns->ucounts)
> -		atomic_dec(&iter->ucount[type]);
> +		atomic_long_dec(&iter->ucount[type]);
>  
>  	put_ucounts(ucounts);
>  	return NULL;
> @@ -216,7 +216,7 @@ void dec_ucount(struct ucounts *ucounts, enum ucount_type type)
>  {
>  	struct ucounts *iter;
>  	for (iter = ucounts; iter; iter = iter->ns->ucounts) {
> -		int dec = atomic_dec_if_positive(&iter->ucount[type]);
> +		int dec = atomic_long_dec_if_positive(&iter->ucount[type]);
>  		WARN_ON_ONCE(dec < 0);
>  	}
>  	put_ucounts(ucounts);
> -- 
> 2.25.4
> 
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
