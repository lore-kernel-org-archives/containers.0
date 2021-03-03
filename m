Return-Path: <SRS0=E41j=IB=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6799AC433DB
	for <containers@archiver.kernel.org>; Wed,  3 Mar 2021 13:24:16 +0000 (UTC)
Received: from smtp2.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id B496164E25
	for <containers@archiver.kernel.org>; Wed,  3 Mar 2021 13:24:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B496164E25
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp2.osuosl.org (Postfix) with ESMTP id 43B95400E1;
	Wed,  3 Mar 2021 13:24:15 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp2.osuosl.org ([127.0.0.1])
	by localhost (smtp2.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 9UajpvDgeHw5; Wed,  3 Mar 2021 13:24:14 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [IPv6:2605:bc80:3010:104::8cd3:938])
	by smtp2.osuosl.org (Postfix) with ESMTP id 4F584400D0;
	Wed,  3 Mar 2021 13:24:14 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 2B600C000A;
	Wed,  3 Mar 2021 13:24:14 +0000 (UTC)
Received: from smtp4.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id C495AC0001
 for <containers@lists.linux-foundation.org>;
 Wed,  3 Mar 2021 13:24:12 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp4.osuosl.org (Postfix) with ESMTP id ADDEB47415
 for <containers@lists.linux-foundation.org>;
 Wed,  3 Mar 2021 13:24:12 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Authentication-Results: smtp4.osuosl.org (amavisd-new);
 dkim=pass (1024-bit key) header.d=redhat.com
Received: from smtp4.osuosl.org ([127.0.0.1])
 by localhost (smtp4.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id iSImfdYwG9VH
 for <containers@lists.linux-foundation.org>;
 Wed,  3 Mar 2021 13:24:11 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.8.0
Received: from us-smtp-delivery-124.mimecast.com
 (us-smtp-delivery-124.mimecast.com [216.205.24.124])
 by smtp4.osuosl.org (Postfix) with ESMTPS id BF83245E00
 for <containers@lists.linux-foundation.org>;
 Wed,  3 Mar 2021 13:24:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
 s=mimecast20190719; t=1614777850;
 h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=vk447qmcUk9k9oiYBDQSU0MXpWTCWyE8diWCiLIMsCQ=;
 b=VsAu2uYPScKRXhYt4/3BbxR486eITEomDYd/GiG5diJxFo6LwvNohuYA0DIiTfVo4N4q1Z
 ozqTSbadjPuBuf7aKsqN517mVZg/qnxcOYc2fDyWuLl01nHtn+BfVpipShyOdDHtFEgW9n
 N8ymIFNlf5XYkKwyqbJ3fvc92rDLhsw=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-399-SfutzYt4PO6iqn8pozASaw-1; Wed, 03 Mar 2021 08:24:06 -0500
X-MC-Unique: SfutzYt4PO6iqn8pozASaw-1
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com
 [10.5.11.14])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by mimecast-mx01.redhat.com (Postfix) with ESMTPS id A6A9D804023;
 Wed,  3 Mar 2021 13:24:04 +0000 (UTC)
Received: from warthog.procyon.org.uk (ovpn-119-68.rdu2.redhat.com
 [10.10.119.68])
 by smtp.corp.redhat.com (Postfix) with ESMTP id 205305D9E2;
 Wed,  3 Mar 2021 13:24:02 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
 Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
 Kingdom.
 Registered in England and Wales under Company Registration No. 3798903
In-Reply-To: <20210121131959.646623-10-christian.brauner@ubuntu.com>
References: <20210121131959.646623-10-christian.brauner@ubuntu.com>
 <20210121131959.646623-1-christian.brauner@ubuntu.com>
To: Tycho Andersen <tycho@tycho.pizza>,
 Christian Brauner <christian.brauner@ubuntu.com>
Subject: Re: [PATCH v6 09/40] xattr: handle idmapped mounts
MIME-Version: 1.0
Content-ID: <2123327.1614777789.1@warthog.procyon.org.uk>
From: David Howells <dhowells@redhat.com>
Date: Wed, 03 Mar 2021 13:24:02 +0000
Message-ID: <2129497.1614777842@warthog.procyon.org.uk>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
Cc: Tycho Andersen <tycho@tycho.ws>, containers@lists.linux-foundation.org,
 linux-kernel@vger.kernel.org, dhowells@redhat.com,
 linux-security-module@vger.kernel.org, linux-fsdevel@vger.kernel.org
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

Christian Brauner <christian.brauner@ubuntu.com> wrote:

> diff --git a/fs/cachefiles/xattr.c b/fs/cachefiles/xattr.c
> index 72e42438f3d7..a591b5e09637 100644
> --- a/fs/cachefiles/xattr.c
> +++ b/fs/cachefiles/xattr.c
> @@ -39,8 +39,8 @@ int cachefiles_check_object_type(struct cachefiles_object *object)
>  	_enter("%p{%s}", object, type);
>  
>  	/* attempt to install a type label directly */
> -	ret = vfs_setxattr(dentry, cachefiles_xattr_cache, type, 2,
> -			   XATTR_CREATE);
> +	ret = vfs_setxattr(&init_user_ns, dentry, cachefiles_xattr_cache, type,
> +			   2, XATTR_CREATE);

Actually, on further consideration, this might be the wrong thing to do in
cachefiles.  The creds are (or should be) overridden when accesses to the
underlying filesystem are being made.

I wonder if this should be using current_cred()->user_ns or
cache->cache_cred->user_ns instead.

David

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
