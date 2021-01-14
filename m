Return-Path: <SRS0=onox=GR=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 164D8C433DB
	for <containers@archiver.kernel.org>; Thu, 14 Jan 2021 22:11:54 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 5543E22A84
	for <containers@archiver.kernel.org>; Thu, 14 Jan 2021 22:11:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5543E22A84
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 0333720392;
	Thu, 14 Jan 2021 22:11:53 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id M-ZQ2Z2Wz+tu; Thu, 14 Jan 2021 22:11:50 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id BDD0420357;
	Thu, 14 Jan 2021 22:11:50 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 995C6C0893;
	Thu, 14 Jan 2021 22:11:50 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 300B3C013A
 for <containers@lists.linux-foundation.org>;
 Thu, 14 Jan 2021 22:11:49 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 161B08608D
 for <containers@lists.linux-foundation.org>;
 Thu, 14 Jan 2021 22:11:49 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id x2TY50MhvfTr
 for <containers@lists.linux-foundation.org>;
 Thu, 14 Jan 2021 22:11:48 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 14AA985FAE
 for <containers@lists.linux-foundation.org>;
 Thu, 14 Jan 2021 22:11:47 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1l0ApP-0007xM-ND; Thu, 14 Jan 2021 22:10:51 +0000
Date: Thu, 14 Jan 2021 23:10:48 +0100
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v5 37/42] xfs: support idmapped mounts
Message-ID: <20210114221048.ppf2pfuxrjak4kvm@wittgenstein>
References: <20210112220124.837960-1-christian.brauner@ubuntu.com>
 <20210112220124.837960-38-christian.brauner@ubuntu.com>
 <20210114205154.GL331610@dread.disaster.area>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20210114205154.GL331610@dread.disaster.area>
Cc: Lennart Poettering <lennart@poettering.net>,
 Mimi Zohar <zohar@linux.ibm.com>, David Howells <dhowells@redhat.com>,
 Andreas Dilger <adilger.kernel@dilger.ca>,
 containers@lists.linux-foundation.org, Christoph Hellwig <hch@lst.de>,
 Tycho Andersen <tycho@tycho.ws>, Paul Moore <paul@paul-moore.com>,
 Jonathan Corbet <corbet@lwn.net>, smbarber@chromium.org,
 Christoph Hellwig <hch@infradead.org>, Alban Crequy <alban@kinvolk.io>,
 linux-ext4@vger.kernel.org, Mrunal Patel <mpatel@redhat.com>,
 Kees Cook <keescook@chromium.org>, Arnd Bergmann <arnd@arndb.de>,
 selinux@vger.kernel.org, Josh Triplett <josh@joshtriplett.org>,
 Seth Forshee <seth.forshee@canonical.com>, Aleksa Sarai <cyphar@cyphar.com>,
 Alexander Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>,
 OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
 Geoffrey Thomas <geofft@ldpreload.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 John Johansen <john.johansen@canonical.com>, Theodore Tso <tytso@mit.edu>,
 Dmitry Kasatkin <dmitry.kasatkin@gmail.com>,
 Stephen Smalley <stephen.smalley.work@gmail.com>, linux-xfs@vger.kernel.org,
 linux-security-module@vger.kernel.org,
 "Eric W. Biederman" <ebiederm@xmission.com>, linux-api@vger.kernel.org,
 Casey Schaufler <casey@schaufler-ca.com>, linux-fsdevel@vger.kernel.org,
 linux-integrity@vger.kernel.org,
 Linus Torvalds <torvalds@linux-foundation.org>, Todd Kjos <tkjos@google.com>
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

On Fri, Jan 15, 2021 at 07:51:54AM +1100, Dave Chinner wrote:
> On Tue, Jan 12, 2021 at 11:01:19PM +0100, Christian Brauner wrote:
> > From: Christoph Hellwig <hch@lst.de>
> > 
> > Enable idmapped mounts for xfs. This basically just means passing down
> > the user_namespace argument from the VFS methods down to where it is
> > passed to helper.
> > 
> > Signed-off-by: Christoph Hellwig <hch@lst.de>
> ....
> > @@ -654,6 +658,7 @@ xfs_vn_change_ok(
> >   */
> >  static int
> >  xfs_setattr_nonsize(
> > +	struct user_namespace	*mnt_userns,
> >  	struct xfs_inode	*ip,
> >  	struct iattr		*iattr)
> >  {
> > @@ -813,7 +818,7 @@ xfs_setattr_nonsize(
> >  	 * 	     Posix ACL code seems to care about this issue either.
> >  	 */
> >  	if (mask & ATTR_MODE) {
> > -		error = posix_acl_chmod(&init_user_ns, inode, inode->i_mode);
> > +		error = posix_acl_chmod(mnt_userns, inode, inode->i_mode);
> >  		if (error)
> >  			return error;
> >  	}
> > @@ -868,7 +873,7 @@ xfs_setattr_size(
> >  		 * Use the regular setattr path to update the timestamps.
> >  		 */
> >  		iattr->ia_valid &= ~ATTR_SIZE;
> > -		return xfs_setattr_nonsize(ip, iattr);
> > +		return xfs_setattr_nonsize(&init_user_ns, ip, iattr);
> 
> Shouldn't that be passing mnt_userns?

Hey Dave,

Thanks for taking a look.

This is the time updating codepath.

xfs_setattr_size();
-> xfs_setattr_nonsize(&init_user_ns);

The xfs_setattr_size() helper will assert:

ASSERT((iattr->ia_valid & (ATTR_UID|ATTR_GID|ATTR_ATIME|ATTR_ATIME_SET|
	ATTR_MTIME_SET|ATTR_KILL_PRIV|ATTR_TIMES_SET)) == 0);

While the

xfs_setattr_nonsize() helper will further assert:

ASSERT((mask & ATTR_SIZE) == 0);

so xfs_setattr_nonsize() in this callpath is only used to update the

if (!(iattr->ia_valid & (ATTR_CTIME|ATTR_MTIME)))
	return 0;

so there's no interactions with idmappings in any way. Simply passing
mnt_userns might be clearer though.

But if this would be using the wrong idmapping the xfstest suite I added
would've immediately caught that and failed.

But this specific codepath can also be reliably hit from userspace by
doing ftruncate(fd, 0) so just to be extra sure I added truncate tests
to the xfstests now for both the idmapped and non-idmapped case.

Christian
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
