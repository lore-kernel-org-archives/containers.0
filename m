Return-Path: <SRS0=E41j=IB=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94B87C433DB
	for <containers@archiver.kernel.org>; Wed,  3 Mar 2021 16:15:40 +0000 (UTC)
Received: from smtp1.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id BD06264F1B
	for <containers@archiver.kernel.org>; Wed,  3 Mar 2021 16:15:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BD06264F1B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp1.osuosl.org (Postfix) with ESMTP id 504B2843D0;
	Wed,  3 Mar 2021 16:15:39 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp1.osuosl.org ([127.0.0.1])
	by localhost (smtp1.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id TD1NojOyFikM; Wed,  3 Mar 2021 16:15:38 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp1.osuosl.org (Postfix) with ESMTP id 4A9D7843CA;
	Wed,  3 Mar 2021 16:15:38 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 3022BC000B;
	Wed,  3 Mar 2021 16:15:38 +0000 (UTC)
Received: from smtp1.osuosl.org (smtp1.osuosl.org [IPv6:2605:bc80:3010::138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 62EA3C0001
 for <containers@lists.linux-foundation.org>;
 Wed,  3 Mar 2021 16:15:37 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp1.osuosl.org (Postfix) with ESMTP id 44C43843D0
 for <containers@lists.linux-foundation.org>;
 Wed,  3 Mar 2021 16:15:37 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp1.osuosl.org ([127.0.0.1])
 by localhost (smtp1.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id hcdcnOT4KRgK
 for <containers@lists.linux-foundation.org>;
 Wed,  3 Mar 2021 16:15:36 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.8.0
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by smtp1.osuosl.org (Postfix) with ESMTPS id 1AB46843CA
 for <containers@lists.linux-foundation.org>;
 Wed,  3 Mar 2021 16:15:35 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1lHU9p-00030o-EU; Wed, 03 Mar 2021 16:15:29 +0000
Date: Wed, 3 Mar 2021 16:15:28 +0000
From: Christian Brauner <christian.brauner@ubuntu.com>
To: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH v6 09/40] xattr: handle idmapped mounts
Message-ID: <20210303161528.n3jzg66ou2wa43qb@wittgenstein>
References: <20210303140522.jwlzrmhhho3lvpmv@wittgenstein>
 <20210121131959.646623-10-christian.brauner@ubuntu.com>
 <20210121131959.646623-1-christian.brauner@ubuntu.com>
 <2129497.1614777842@warthog.procyon.org.uk>
 <2203252.1614782707@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <2203252.1614782707@warthog.procyon.org.uk>
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

On Wed, Mar 03, 2021 at 02:45:07PM +0000, David Howells wrote:
> Christian Brauner <christian.brauner@ubuntu.com> wrote:
> 
> > In order to answer this more confidently I need to know a bit more about
> > how cachefiles are supposed to work.
> > 
> > From what I gather here it seemed what this code is trying to set here
> > is an internal "CacheFiles.cache" extended attribute on the indode. This
> > extended attribute doesn't store any uids and gids or filesystem
> > capabilities so the user namespace isn't relevant for that since there
> > doesn't need to be any conversion.
> > 
> > What I need to know is what information do you use for cachefiles to
> > determine whether someone can set that "Cachefiles.cache" extended
> > attribute on the inode:
> > - Is it the mnt_userns of a/the mount of the filesystem you're caching for?
> > - The mnt_userns of the mnt of struct cachefiles_cache?
> > - Or the stashed or current creds of the caller?
> 
> Mostly it's about permission checking.  The cache driver wants to do accesses
> onto the files in cache using the context of whatever process writes the
> "bind" command to /dev/cachefiles, not the context of whichever process issued
> a read or write, say, on an NFS file that is being cached.
> 
> This causes standard UNIX perm checking, SELinux checking, etc. all to be
> switched to the appropriate context.  It also controls what appears in the
> audit logs.

(Audit always translates from and to init_user_ns. The changes to make
it aware of user namespaces proper are delayed until the audit id thing
is merged as Paul pointed out to me.)

> 
> There is an exception to this: It also governs the ownership of new files and
> directories created in the cache and what security labels will be set on them.

So from our offline discussion I gather that cachefilesd creates a cache
on a local filesystem (ext4, xfs etc.) for a network filesystem. The way
this is done is by writing "bind" to /dev/cachefiles and pointing it to
a directory to use as the cache.

This directory can currently also be an idmapped mount, say:

mount --bind --idmap /mnt /mnt

and then pointing cachefilesd via a "bind" operation to

/mnt

What I would expect is for cachefilesd to now take that idmapping into
account when creating files in /mnt but as it stands now, it doesn't.
This could leave users confused as the ownership of the files wouldn't
match to what they expressed in the idmapping. Since you're reworking
cachefilesd currently anyway, I would suggest we port cachefilesd to
support idmapped mounts once as part of your rework. I can help there
and until then we do:


diff --git a/fs/cachefiles/bind.c b/fs/cachefiles/bind.c
index dfb14dbddf51..51f21beafad9 100644
--- a/fs/cachefiles/bind.c
+++ b/fs/cachefiles/bind.c
@@ -115,6 +115,12 @@ static int cachefiles_daemon_add_cache(struct cachefiles_cache *cache)
        if (ret < 0)
                goto error_open_root;

+       if (mnt_user_ns(path.mnt) != &init_user_ns) {
+               ret = -EPERM;
+               pr_err("Caches on idmapped mounts are currently not supported\n");
+               goto error_open_root;
+       }
+
        cache->mnt = path.mnt;
        root = path.dentry;

This is safe to do because if a mount is visible in the filesystem it
can't change it's idmapping.

(Might even be worth if you add a helper at this point:

static inline bool mnt_is_idmapped(struct vfsmount *mnt)
{
	return mnt_user_ns(mnt) != &init_user_ns;
}
)

Christian
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
