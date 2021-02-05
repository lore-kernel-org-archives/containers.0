Return-Path: <SRS0=7tMn=HH=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.8 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,INCLUDES_CR_TRAILER,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE7D3C433DB
	for <containers@archiver.kernel.org>; Fri,  5 Feb 2021 02:46:52 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 73AE464FB4
	for <containers@archiver.kernel.org>; Fri,  5 Feb 2021 02:46:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 73AE464FB4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 3C1A12E0F2;
	Fri,  5 Feb 2021 02:46:52 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id n1cJ4MqL6bEN; Fri,  5 Feb 2021 02:46:51 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 6606C2E0D7;
	Fri,  5 Feb 2021 02:46:51 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 56F55C08A1;
	Fri,  5 Feb 2021 02:46:51 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 99532C0174
 for <containers@lists.linux-foundation.org>;
 Fri,  5 Feb 2021 02:46:50 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 789E686DFF
 for <containers@lists.linux-foundation.org>;
 Fri,  5 Feb 2021 02:46:50 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id Vo0mIqorBwau
 for <containers@lists.linux-foundation.org>;
 Fri,  5 Feb 2021 02:46:49 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 4A43786DEA
 for <containers@lists.linux-foundation.org>;
 Fri,  5 Feb 2021 02:46:49 +0000 (UTC)
Received: by mail.kernel.org (Postfix) with ESMTPSA id 38AF464FA7;
 Fri,  5 Feb 2021 02:46:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
 s=k20201202; t=1612493208;
 bh=u7fCLAhX1pOwBx9BOcb331n4nXXbCELnac9pfuMdw40=;
 h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
 b=aKqP2NtJwTWkkRvAXb7ogJw+spwaPwbSFR6MdVHrrbndME/wehMGYfotFjvjy44rN
 EdnmJvO8unOg33HhXcSolWitHCL+LnXtd/2PDVjdeMUpItQyGKMMp0VBQYQTHSrIqb
 zLsSTv7Xlht5g1dcjBN4b59L57IfHiVHyB5JQe0ULO5D4icYj+qHxFrhvo2iTR1ZBl
 CdLEX8Od2/oABQQtdkcHad7hv4GhSaGt6UWHQMeWAigWU0tyrEnoqV/nnqY7ti2V5F
 g3tD5v2wmksqiD/Bg3SxiISs6hagCAqXIDn8hDPKaoMHfNQ6L4fFxY+1g3oDePZK4W
 JCnl0mclkQrbg==
Date: Fri, 5 Feb 2021 04:46:40 +0200
From: Jarkko Sakkinen <jarkko@kernel.org>
To: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 1/2] Add namespace tags that can be used for matching
 without pinning a ns
Message-ID: <YByxkDi0Ruhb0AA8@kernel.org>
References: <161246085160.1990927.13137391845549674518.stgit@warthog.procyon.org.uk>
 <161246085966.1990927.2555272056564793056.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <161246085966.1990927.2555272056564793056.stgit@warthog.procyon.org.uk>
Cc: selinux@vger.kernel.org, linux-api@vger.kernel.org,
 containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
 linux-security-module@vger.kernel.org, keyrings@vger.kernel.org,
 sprabhu@redhat.com, linux-fsdevel@vger.kernel.org, christian@brauner.io
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

On Thu, Feb 04, 2021 at 05:47:39PM +0000, David Howells wrote:
> Add a ns tag struct that consists of just a refcount.  It's address can be
> used to compare namespaces without the need to pin a namespace.  Just the
> tag needs pinning.
> 
> Signed-off-by: David Howells <dhowells@redhat.com>
> ---
> 
>  fs/namespace.c            |   18 ++++++++----------
>  include/linux/ns_common.h |   23 +++++++++++++++++++++++
>  include/linux/proc_ns.h   |   38 +++++++++++++++++++++++++++++++++++---
>  init/version.c            |    9 ++++++++-
>  ipc/msgutil.c             |    7 ++++++-
>  ipc/namespace.c           |    8 +++-----
>  kernel/cgroup/cgroup.c    |    5 +++++
>  kernel/cgroup/namespace.c |    6 +++---
>  kernel/pid.c              |    5 +++++
>  kernel/pid_namespace.c    |   18 +++++++++---------
>  kernel/time/namespace.c   |   13 +++++--------
>  kernel/user.c             |    5 +++++
>  kernel/user_namespace.c   |    7 +++----
>  kernel/utsname.c          |   24 +++++++++++++-----------
>  net/core/net_namespace.c  |   38 +++++++++++++++-----------------------
>  15 files changed, 146 insertions(+), 78 deletions(-)
> 
> diff --git a/fs/namespace.c b/fs/namespace.c
> index 9d33909d0f9e..f8da9be8c6f7 100644
> --- a/fs/namespace.c
> +++ b/fs/namespace.c
> @@ -3238,10 +3238,9 @@ static void dec_mnt_namespaces(struct ucounts *ucounts)
>  
>  static void free_mnt_ns(struct mnt_namespace *ns)
>  {
> -	if (!is_anon_ns(ns))
> -		ns_free_inum(&ns->ns);
>  	dec_mnt_namespaces(ns->ucounts);
>  	put_user_ns(ns->user_ns);
> +	destroy_ns_common(&ns->ns);
>  	kfree(ns);
>  }
>  
> @@ -3269,18 +3268,17 @@ static struct mnt_namespace *alloc_mnt_ns(struct user_namespace *user_ns, bool a
>  		dec_mnt_namespaces(ucounts);
>  		return ERR_PTR(-ENOMEM);
>  	}
> -	if (!anon) {
> -		ret = ns_alloc_inum(&new_ns->ns);
> -		if (ret) {
> -			kfree(new_ns);
> -			dec_mnt_namespaces(ucounts);
> -			return ERR_PTR(ret);
> -		}
> +
> +	ret = init_ns_common(&new_ns->ns, anon);
> +	if (ret) {
> +		destroy_ns_common(&new_ns->ns);
> +		kfree(new_ns);
> +		dec_mnt_namespaces(ucounts);
> +		return ERR_PTR(ret);
>  	}
>  	new_ns->ns.ops = &mntns_operations;
>  	if (!anon)
>  		new_ns->seq = atomic64_add_return(1, &mnt_ns_seq);
> -	refcount_set(&new_ns->ns.count, 1);
>  	INIT_LIST_HEAD(&new_ns->list);
>  	init_waitqueue_head(&new_ns->poll);
>  	spin_lock_init(&new_ns->ns_lock);
> diff --git a/include/linux/ns_common.h b/include/linux/ns_common.h
> index 0f1d024bd958..45174ad8a435 100644
> --- a/include/linux/ns_common.h
> +++ b/include/linux/ns_common.h
> @@ -3,14 +3,37 @@
>  #define _LINUX_NS_COMMON_H
>  
>  #include <linux/refcount.h>
> +#include <linux/slab.h>
>  
>  struct proc_ns_operations;
>  
> +/*
> + * Comparable tag for namespaces so that namespaces don't have to be pinned by
> + * something that wishes to detect if a namespace matches a criterion.
> + */
> +struct ns_tag {
> +	refcount_t	usage;

Is that indentation necessary? I'd put just a space.

> +};
> +
>  struct ns_common {
>  	atomic_long_t stashed;
>  	const struct proc_ns_operations *ops;
> +	struct ns_tag *tag;
>  	unsigned int inum;
>  	refcount_t count;
>  };
>  
> +static inline struct ns_tag *get_ns_tag(struct ns_tag *tag)
> +{
> +	if (tag)
> +		refcount_inc(&tag->usage);
> +	return tag;
> +}
> +
> +static inline void put_ns_tag(struct ns_tag *tag)
> +{
> +	if (tag && refcount_dec_and_test(&tag->usage))
> +		kfree(tag);
> +}
> +
>  #endif
> diff --git a/include/linux/proc_ns.h b/include/linux/proc_ns.h
> index 75807ecef880..9fb7eb403923 100644
> --- a/include/linux/proc_ns.h
> +++ b/include/linux/proc_ns.h
> @@ -64,13 +64,45 @@ static inline void proc_free_inum(unsigned int inum) {}
>  
>  #endif /* CONFIG_PROC_FS */
>  
> -static inline int ns_alloc_inum(struct ns_common *ns)
> +/**
> + * init_ns_common - Initialise the common part of a namespace

Nit: init_ns_common()

> + * @ns: The namespace to initialise
> + * @anon: The namespace will be anonymous
> + *
> + * Set up the common part of a namespace, assigning an inode number and
> + * creating a tag.  Returns 0 on success and a negative error code on failure.
> + * On failure, the caller must call destroy_ns_common().

I've used lately (e.g. arch/x86/kernel/cpu/sgx/ioctl.c) along the lines:

* Return:
* - 0:          Initialization was successful.
* - -ENOMEM:    Out of memory.

Looking at the implementation, I guess this is a complete representation of
what it can return?

The driving point here is that this nicely lines up when rendered with
"make htmldocs".

> + */
> +static inline int init_ns_common(struct ns_common *ns, bool anon)
>  {
> +	struct ns_tag *tag;
> +
> +	tag = kzalloc(sizeof(*tag), GFP_KERNEL);
> +	if (!tag)
> +		return -ENOMEM;
> +
> +	refcount_set(&tag->usage, 1);
> +	ns->tag = tag;
> +	ns->inum = 0;
>  	atomic_long_set(&ns->stashed, 0);
> -	return proc_alloc_inum(&ns->inum);
> +	refcount_set(&ns->count, 1);
> +
> +	return anon ? 0 : proc_alloc_inum(&ns->inum);
>  }
>  
> -#define ns_free_inum(ns) proc_free_inum((ns)->inum)
> +/**
> + * destroy_ns_common - Clean up the common part of a namespace

Nit: destroy_ns_common()

/Jarkko
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
