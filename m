Return-Path: <SRS0=E41j=IB=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A466EC433E0
	for <containers@archiver.kernel.org>; Wed,  3 Mar 2021 14:05:34 +0000 (UTC)
Received: from smtp2.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 0AEEB64EAE
	for <containers@archiver.kernel.org>; Wed,  3 Mar 2021 14:05:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0AEEB64EAE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp2.osuosl.org (Postfix) with ESMTP id 960C8400E6;
	Wed,  3 Mar 2021 14:05:33 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp2.osuosl.org ([127.0.0.1])
	by localhost (smtp2.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id rWGPUc-QAA_J; Wed,  3 Mar 2021 14:05:32 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [IPv6:2605:bc80:3010:104::8cd3:938])
	by smtp2.osuosl.org (Postfix) with ESMTP id A431A400D8;
	Wed,  3 Mar 2021 14:05:32 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 7BF19C000A;
	Wed,  3 Mar 2021 14:05:32 +0000 (UTC)
Received: from smtp2.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 5C83BC0001
 for <containers@lists.linux-foundation.org>;
 Wed,  3 Mar 2021 14:05:31 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp2.osuosl.org (Postfix) with ESMTP id 4B271400DF
 for <containers@lists.linux-foundation.org>;
 Wed,  3 Mar 2021 14:05:31 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp2.osuosl.org ([127.0.0.1])
 by localhost (smtp2.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 25SJDYxmVZMl
 for <containers@lists.linux-foundation.org>;
 Wed,  3 Mar 2021 14:05:30 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.8.0
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by smtp2.osuosl.org (Postfix) with ESMTPS id 6D202400D8
 for <containers@lists.linux-foundation.org>;
 Wed,  3 Mar 2021 14:05:30 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1lHS7v-0001mB-LN; Wed, 03 Mar 2021 14:05:23 +0000
Date: Wed, 3 Mar 2021 14:05:22 +0000
From: Christian Brauner <christian.brauner@ubuntu.com>
To: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH v6 09/40] xattr: handle idmapped mounts
Message-ID: <20210303140522.jwlzrmhhho3lvpmv@wittgenstein>
References: <20210121131959.646623-10-christian.brauner@ubuntu.com>
 <20210121131959.646623-1-christian.brauner@ubuntu.com>
 <2129497.1614777842@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <2129497.1614777842@warthog.procyon.org.uk>
Cc: Tycho Andersen <tycho@tycho.ws>, containers@lists.linux-foundation.org,
 linux-kernel@vger.kernel.org, linux-security-module@vger.kernel.org,
 linux-fsdevel@vger.kernel.org
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

On Wed, Mar 03, 2021 at 01:24:02PM +0000, David Howells wrote:
> Christian Brauner <christian.brauner@ubuntu.com> wrote:
> 
> > diff --git a/fs/cachefiles/xattr.c b/fs/cachefiles/xattr.c
> > index 72e42438f3d7..a591b5e09637 100644
> > --- a/fs/cachefiles/xattr.c
> > +++ b/fs/cachefiles/xattr.c
> > @@ -39,8 +39,8 @@ int cachefiles_check_object_type(struct cachefiles_object *object)
> >  	_enter("%p{%s}", object, type);
> >  
> >  	/* attempt to install a type label directly */
> > -	ret = vfs_setxattr(dentry, cachefiles_xattr_cache, type, 2,
> > -			   XATTR_CREATE);
> > +	ret = vfs_setxattr(&init_user_ns, dentry, cachefiles_xattr_cache, type,
> > +			   2, XATTR_CREATE);
> 

Hey David,

(Ok, recovered from my run-in with the swapfile bug. I even managed to
get my emails back.)

> Actually, on further consideration, this might be the wrong thing to do in
> cachefiles.  The creds are (or should be) overridden when accesses to the
> underlying filesystem are being made.
> 
> I wonder if this should be using current_cred()->user_ns or
> cache->cache_cred->user_ns instead.

Before I go into the second question please note that this is a no-op
change. So if this is wrong it was wrong before. Which is your point, I
guess.

Please also note that the mnt_userns is _never_ used for (capability)
permission checking, only for idmapping vfs objects and permission
checks based on the i_uid and i_gid. So if your argument about passing
one of those two user namespaces above has anything to do with
permission checking on caps it's most likely wrong. :)

In order to answer this more confidently I need to know a bit more about
how cachefiles are supposed to work.

From what I gather here it seemed what this code is trying to set here
is an internal "CacheFiles.cache" extended attribute on the indode. This
extended attribute doesn't store any uids and gids or filesystem
capabilities so the user namespace isn't relevant for that since there
doesn't need to be any conversion.

What I need to know is what information do you use for cachefiles to
determine whether someone can set that "Cachefiles.cache" extended
attribute on the inode:
- Is it the mnt_userns of a/the mount of the filesystem you're caching for?
- The mnt_userns of the mnt of struct cachefiles_cache?
- Or the stashed or current creds of the caller?

Christian
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
