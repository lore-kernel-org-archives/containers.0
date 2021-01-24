Return-Path: <SRS0=S6Z7=G3=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 964FFC433E0
	for <containers@archiver.kernel.org>; Sun, 24 Jan 2021 22:46:14 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 2B52922C9F
	for <containers@archiver.kernel.org>; Sun, 24 Jan 2021 22:46:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B52922C9F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id C8AE786A3B;
	Sun, 24 Jan 2021 22:46:13 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id YN17lnBS35lv; Sun, 24 Jan 2021 22:46:12 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 8771E869F2;
	Sun, 24 Jan 2021 22:46:12 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 6F535C0FA7;
	Sun, 24 Jan 2021 22:46:12 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id CF765C013A
 for <containers@lists.linux-foundation.org>;
 Sun, 24 Jan 2021 22:46:10 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id AF7DA203B4
 for <containers@lists.linux-foundation.org>;
 Sun, 24 Jan 2021 22:46:10 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id iD7eYCsqOCws
 for <containers@lists.linux-foundation.org>;
 Sun, 24 Jan 2021 22:46:09 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by silver.osuosl.org (Postfix) with ESMTPS id 5855720034
 for <containers@lists.linux-foundation.org>;
 Sun, 24 Jan 2021 22:46:09 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1l3o7r-0007VN-AX; Sun, 24 Jan 2021 22:44:55 +0000
Date: Sun, 24 Jan 2021 23:44:50 +0100
From: Christian Brauner <christian.brauner@ubuntu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH v6 05/39] namei: make permission helpers idmapped mount
 aware
Message-ID: <20210124224450.3dtdgvwxpdf5niuz@wittgenstein>
References: <20210121131959.646623-1-christian.brauner@ubuntu.com>
 <20210121131959.646623-6-christian.brauner@ubuntu.com>
 <20210122222632.GB25405@fieldses.org>
 <20210123130958.3t6kvgkl634njpsm@wittgenstein>
 <20210124221854.GA1487@fieldses.org>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20210124221854.GA1487@fieldses.org>
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

On Sun, Jan 24, 2021 at 05:18:54PM -0500, J. Bruce Fields wrote:
> On Sat, Jan 23, 2021 at 02:09:58PM +0100, Christian Brauner wrote:
> > On Fri, Jan 22, 2021 at 05:26:32PM -0500, J. Bruce Fields wrote:
> > > If I NFS-exported an idmapped mount, I think I'd expect idmapped clients
> > > to see the mapped IDs.
> > > 
> > > Looks like that means taking the user namespace from the struct
> > > svc_export everwhere, for example:
> > > 
> > > On Thu, Jan 21, 2021 at 02:19:24PM +0100, Christian Brauner wrote:
> > > > index 66f2ef67792a..8d90796e236a 100644
> > > > --- a/fs/nfsd/nfsfh.c
> > > > +++ b/fs/nfsd/nfsfh.c
> > > > @@ -40,7 +40,8 @@ static int nfsd_acceptable(void *expv, struct dentry *dentry)
> > > >  		/* make sure parents give x permission to user */
> > > >  		int err;
> > > >  		parent = dget_parent(tdentry);
> > > > -		err = inode_permission(d_inode(parent), MAY_EXEC);
> > > > +		err = inode_permission(&init_user_ns,
> > > > +				       d_inode(parent), MAY_EXEC);
> > > 
> > > 		err = inode_permission(exp->ex_path.mnt->mnt_userns,
> > > 				      d_inode(parent, MAY_EXEC);
> > 
> > Hey Bruce, thanks! Imho, the clean approach for now is to not export
> > idmapped mounts until we have ported that part of nfs similar to what we
> > do for stacking filesystems for now. I've tested and taken this patch
> > into my tree:
> 
> Oh good, thanks.  My real fear was that we'd fix this up later and leave
> users in a situation where the server exposes different IDs depending on
> kernel version, which would be a mess.  Looks like this should avoid
> that.
> 
> As for making idmapped mounts actually work with nfsd--are you planning
> to do that, or do you need me to?  I hope the patch is straightforward;

I'm happy to do it or help and there's other people I know who are also
interested in that and would likely be happy to do the work too.

> I'm more worried testing it.

This whole series has a large xfstest patch associated with it that
tests regular vfs behavior and vfs behavior with idmapped mounts. Iirc,
xfstests also has infrastructure to test nfs. So I'd expect we expand
the idmapped mounts testsuite to test nfs behavior as well.
So far it has proven pretty helpful and has already unconvered an
unrelated setgid-inheritance xfs bug that Christoph fixed a short time
ago.
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
