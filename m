Return-Path: <SRS0=ByLK=H7=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B62A3C433DB
	for <containers@archiver.kernel.org>; Mon,  1 Mar 2021 20:47:31 +0000 (UTC)
Received: from smtp1.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 5D1F2600EF
	for <containers@archiver.kernel.org>; Mon,  1 Mar 2021 20:47:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5D1F2600EF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp1.osuosl.org (Postfix) with ESMTP id 165BB83EE9;
	Mon,  1 Mar 2021 20:47:31 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp1.osuosl.org ([127.0.0.1])
	by localhost (smtp1.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id KAII5LsSyM91; Mon,  1 Mar 2021 20:47:30 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp1.osuosl.org (Postfix) with ESMTP id 016EA83F08;
	Mon,  1 Mar 2021 20:47:29 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id BEB77C000A;
	Mon,  1 Mar 2021 20:47:29 +0000 (UTC)
Received: from smtp1.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id E3A84C0001
 for <containers@lists.linux-foundation.org>;
 Mon,  1 Mar 2021 20:47:28 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp1.osuosl.org (Postfix) with ESMTP id D107483F08
 for <containers@lists.linux-foundation.org>;
 Mon,  1 Mar 2021 20:47:28 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp1.osuosl.org ([127.0.0.1])
 by localhost (smtp1.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id cBfxOPDopEIW
 for <containers@lists.linux-foundation.org>;
 Mon,  1 Mar 2021 20:47:27 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.8.0
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by smtp1.osuosl.org (Postfix) with ESMTPS id B709883EE9
 for <containers@lists.linux-foundation.org>;
 Mon,  1 Mar 2021 20:47:27 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1lGpQg-000669-3l; Mon, 01 Mar 2021 20:46:10 +0000
Date: Mon, 1 Mar 2021 21:46:08 +0100
From: Christian Brauner <christian.brauner@ubuntu.com>
To: "Darrick J. Wong" <djwong@kernel.org>
Subject: Re: [PATCH v6 39/40] xfs: support idmapped mounts
Message-ID: <20210301204608.ip7nowqh6fpztkhr@wittgenstein>
References: <20210121131959.646623-1-christian.brauner@ubuntu.com>
 <20210121131959.646623-40-christian.brauner@ubuntu.com>
 <20210301200520.GK7272@magnolia>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20210301200520.GK7272@magnolia>
Cc: Lennart Poettering <lennart@poettering.net>,
 Mimi Zohar <zohar@linux.ibm.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 Andreas Dilger <adilger.kernel@dilger.ca>,
 containers@lists.linux-foundation.org, Christoph Hellwig <hch@lst.de>,
 Tycho Andersen <tycho@tycho.ws>, Paul Moore <paul@paul-moore.com>,
 Jonathan Corbet <corbet@lwn.net>, smbarber@chromium.org,
 Alban Crequy <alban@kinvolk.io>, linux-ext4@vger.kernel.org,
 Mrunal Patel <mpatel@redhat.com>, Kees Cook <keescook@chromium.org>,
 Arnd Bergmann <arnd@arndb.de>, selinux@vger.kernel.org,
 Josh Triplett <josh@joshtriplett.org>,
 Seth Forshee <seth.forshee@canonical.com>, Aleksa Sarai <cyphar@cyphar.com>,
 Alexander Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>,
 OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
 Geoffrey Thomas <geofft@ldpreload.com>, David Howells <dhowells@redhat.com>,
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

On Mon, Mar 01, 2021 at 12:05:20PM -0800, Darrick J. Wong wrote:
> On Thu, Jan 21, 2021 at 02:19:58PM +0100, Christian Brauner wrote:
> > From: Christoph Hellwig <hch@lst.de>
> > 
> > Enable idmapped mounts for xfs. This basically just means passing down
> > the user_namespace argument from the VFS methods down to where it is
> > passed to the relevant helpers.
> > 
> > Note that full-filesystem bulkstat is not supported from inside idmapped
> > mounts as it is an administrative operation that acts on the whole file
> > system. The limitation is not applied to the bulkstat single operation
> > that just operates on a single inode.
> > 
> > Signed-off-by: Christoph Hellwig <hch@lst.de>
> > Signed-off-by: Christian Brauner <christian.brauner@ubuntu.com>
> > ---
> > /* v2 */
> > 
> > /* v3 */
> > 
> > /* v4 */
> > 
> > /* v5 */
> > base-commit: 7c53f6b671f4aba70ff15e1b05148b10d58c2837
> > 
> > /* v6 */
> > unchanged
> > base-commit: 19c329f6808995b142b3966301f217c831e7cf31
> > ---
> >  fs/xfs/xfs_acl.c     |  3 +--
> >  fs/xfs/xfs_file.c    |  4 +++-
> >  fs/xfs/xfs_inode.c   | 26 +++++++++++++++--------
> >  fs/xfs/xfs_inode.h   | 16 +++++++++------
> >  fs/xfs/xfs_ioctl.c   | 35 ++++++++++++++++++-------------
> >  fs/xfs/xfs_ioctl32.c |  6 ++++--
> >  fs/xfs/xfs_iops.c    | 49 +++++++++++++++++++++++++-------------------
> >  fs/xfs/xfs_iops.h    |  3 ++-
> >  fs/xfs/xfs_itable.c  | 17 +++++++++++----
> >  fs/xfs/xfs_itable.h  |  1 +
> >  fs/xfs/xfs_qm.c      |  3 ++-
> >  fs/xfs/xfs_super.c   |  2 +-
> >  fs/xfs/xfs_symlink.c |  5 +++--
> >  fs/xfs/xfs_symlink.h |  5 +++--
> >  14 files changed, 110 insertions(+), 65 deletions(-)
> 
> <snip> Sorry for not noticing until after this went upstream, but...

No problem at all.

> 
> > diff --git a/fs/xfs/xfs_itable.c b/fs/xfs/xfs_itable.c
> > index 16ca97a7ff00..ca310a125d1e 100644
> > --- a/fs/xfs/xfs_itable.c
> > +++ b/fs/xfs/xfs_itable.c
> > @@ -54,10 +54,12 @@ struct xfs_bstat_chunk {
> >  STATIC int
> >  xfs_bulkstat_one_int(
> >  	struct xfs_mount	*mp,
> > +	struct user_namespace	*mnt_userns,
> >  	struct xfs_trans	*tp,
> >  	xfs_ino_t		ino,
> >  	struct xfs_bstat_chunk	*bc)
> >  {
> > +	struct user_namespace	*sb_userns = mp->m_super->s_user_ns;
> >  	struct xfs_icdinode	*dic;		/* dinode core info pointer */
> >  	struct xfs_inode	*ip;		/* incore inode pointer */
> >  	struct inode		*inode;
> > @@ -86,8 +88,8 @@ xfs_bulkstat_one_int(
> >  	 */
> >  	buf->bs_projectid = ip->i_d.di_projid;
> >  	buf->bs_ino = ino;
> > -	buf->bs_uid = i_uid_read(inode);
> > -	buf->bs_gid = i_gid_read(inode);
> > +	buf->bs_uid = from_kuid(sb_userns, i_uid_into_mnt(mnt_userns, inode));
> > +	buf->bs_gid = from_kgid(sb_userns, i_gid_into_mnt(mnt_userns, inode));
> >  	buf->bs_size = dic->di_size;
> >  
> >  	buf->bs_nlink = inode->i_nlink;
> > @@ -173,7 +175,8 @@ xfs_bulkstat_one(
> >  	if (!bc.buf)
> >  		return -ENOMEM;
> >  
> > -	error = xfs_bulkstat_one_int(breq->mp, NULL, breq->startino, &bc);
> > +	error = xfs_bulkstat_one_int(breq->mp, breq->mnt_userns, NULL,
> > +				     breq->startino, &bc);
> >  
> >  	kmem_free(bc.buf);
> >  
> > @@ -194,9 +197,10 @@ xfs_bulkstat_iwalk(
> >  	xfs_ino_t		ino,
> >  	void			*data)
> >  {
> > +	struct xfs_bstat_chunk	*bc = data;
> >  	int			error;
> >  
> > -	error = xfs_bulkstat_one_int(mp, tp, ino, data);
> > +	error = xfs_bulkstat_one_int(mp, bc->breq->mnt_userns, tp, ino, data);
> >  	/* bulkstat just skips over missing inodes */
> >  	if (error == -ENOENT || error == -EINVAL)
> >  		return 0;
> > @@ -239,6 +243,11 @@ xfs_bulkstat(
> >  	};
> >  	int			error;
> >  
> > +	if (breq->mnt_userns != &init_user_ns) {
> > +		xfs_warn_ratelimited(breq->mp,
> > +			"bulkstat not supported inside of idmapped mounts.");
> > +		return -EINVAL;
> 
> Shouldn't this be -EPERM?
> 
> Or -EOPNOTSUPP?

EOPNOTSUPP seems a good choice. Whether or not it's better than EINVAL I
don't know. With my userspace maintainer hat on I would probably say
that EOPNOTSUPP feels a bit more natural and might have the advantage
that it is less overloaded then EINVAL.

> 
> Also, I'm not sure why bulkstat won't work in an idmapped mount but
> bulkstat_single does?  You can use the singleton version to stat inodes
> that aren't inside the submount.

Christoph will very likely have a better informed opinion than I have
but as long as bulkstat is able to discern inodes that need to be
reported idmapped and inodes that don't then I see no reason why this
shouldn't work (at least for privileged users on the host which I think
is the case already).

In any case these changes, if any, aren't vfs changes and so you can
just take them as bugfixes through the xfs tree anyway. So no harm done
in you not spotting it earlier. :)

Thanks for taking another look!
Christian
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
