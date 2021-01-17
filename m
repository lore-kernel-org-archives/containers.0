Return-Path: <SRS0=maMt=GU=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91B80C433E0
	for <containers@archiver.kernel.org>; Sun, 17 Jan 2021 21:06:44 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 0A4232247F
	for <containers@archiver.kernel.org>; Sun, 17 Jan 2021 21:06:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0A4232247F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 7FA22203F2;
	Sun, 17 Jan 2021 21:06:43 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id HmBRFpMqzANu; Sun, 17 Jan 2021 21:06:42 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 827A420004;
	Sun, 17 Jan 2021 21:06:42 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 6AE3BC088B;
	Sun, 17 Jan 2021 21:06:42 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 4D4D9C013A
 for <containers@lists.linux-foundation.org>;
 Sun, 17 Jan 2021 21:06:41 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 3B66285886
 for <containers@lists.linux-foundation.org>;
 Sun, 17 Jan 2021 21:06:41 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 5s1jlJLj4lIb
 for <containers@lists.linux-foundation.org>;
 Sun, 17 Jan 2021 21:06:39 +0000 (UTC)
X-Greylist: whitelisted by SQLgrey-1.7.6
Received: from mail107.syd.optusnet.com.au (mail107.syd.optusnet.com.au
 [211.29.132.53])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 930408586A
 for <containers@lists.linux-foundation.org>;
 Sun, 17 Jan 2021 21:06:39 +0000 (UTC)
Received: from dread.disaster.area (pa49-181-54-82.pa.nsw.optusnet.com.au
 [49.181.54.82])
 by mail107.syd.optusnet.com.au (Postfix) with ESMTPS id AB1B4D5ED06;
 Mon, 18 Jan 2021 08:06:22 +1100 (AEDT)
Received: from dave by dread.disaster.area with local (Exim 4.92.3)
 (envelope-from <david@fromorbit.com>)
 id 1l1FFd-0011Hk-2N; Mon, 18 Jan 2021 08:06:21 +1100
Date: Mon, 18 Jan 2021 08:06:21 +1100
From: Dave Chinner <david@fromorbit.com>
To: Christian Brauner <christian.brauner@ubuntu.com>
Subject: Re: [PATCH v5 37/42] xfs: support idmapped mounts
Message-ID: <20210117210621.GA78941@dread.disaster.area>
References: <20210112220124.837960-1-christian.brauner@ubuntu.com>
 <20210112220124.837960-38-christian.brauner@ubuntu.com>
 <20210114205154.GL331610@dread.disaster.area>
 <20210114221048.ppf2pfuxrjak4kvm@wittgenstein>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20210114221048.ppf2pfuxrjak4kvm@wittgenstein>
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.3 cv=F8MpiZpN c=1 sm=1 tr=0 cx=a_idp_d
 a=NAd5MxazP4FGoF8nXO8esw==:117 a=NAd5MxazP4FGoF8nXO8esw==:17
 a=kj9zAlcOel0A:10 a=EmqxpYm9HcoA:10 a=7-415B0cAAAA:8
 a=QsOiS33c3F2EFrvaDEcA:9 a=CjuIK1q_8ugA:10 a=biEYGPWJfzWAr4FL6Ov7:22
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

On Thu, Jan 14, 2021 at 11:10:48PM +0100, Christian Brauner wrote:
> On Fri, Jan 15, 2021 at 07:51:54AM +1100, Dave Chinner wrote:
> > On Tue, Jan 12, 2021 at 11:01:19PM +0100, Christian Brauner wrote:
> > > From: Christoph Hellwig <hch@lst.de>
> > > 
> > > Enable idmapped mounts for xfs. This basically just means passing down
> > > the user_namespace argument from the VFS methods down to where it is
> > > passed to helper.
> > > 
> > > Signed-off-by: Christoph Hellwig <hch@lst.de>
> > ....
> > > @@ -654,6 +658,7 @@ xfs_vn_change_ok(
> > >   */
> > >  static int
> > >  xfs_setattr_nonsize(
> > > +	struct user_namespace	*mnt_userns,
> > >  	struct xfs_inode	*ip,
> > >  	struct iattr		*iattr)
> > >  {
> > > @@ -813,7 +818,7 @@ xfs_setattr_nonsize(
> > >  	 * 	     Posix ACL code seems to care about this issue either.
> > >  	 */
> > >  	if (mask & ATTR_MODE) {
> > > -		error = posix_acl_chmod(&init_user_ns, inode, inode->i_mode);
> > > +		error = posix_acl_chmod(mnt_userns, inode, inode->i_mode);
> > >  		if (error)
> > >  			return error;
> > >  	}
> > > @@ -868,7 +873,7 @@ xfs_setattr_size(
> > >  		 * Use the regular setattr path to update the timestamps.
> > >  		 */
> > >  		iattr->ia_valid &= ~ATTR_SIZE;
> > > -		return xfs_setattr_nonsize(ip, iattr);
> > > +		return xfs_setattr_nonsize(&init_user_ns, ip, iattr);
> > 
> > Shouldn't that be passing mnt_userns?
> 
> Hey Dave,
> 
> Thanks for taking a look.
> 
> This is the time updating codepath.

Yes, I understand the code path, that's why I asked the question and
commented that it's a landmine. That is, if in future we ever need
to do anything that is is in any way namespace related in the
truncate path, the wrong thing will happen because we are passing
the wrong namespace into that function.

Please just pass down the correct namespace for the operation even
though we don't currently require it for the operations being
performed in that path.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
