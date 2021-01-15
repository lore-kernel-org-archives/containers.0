Return-Path: <SRS0=Gs6x=GS=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A36BC433E0
	for <containers@archiver.kernel.org>; Fri, 15 Jan 2021 16:26:38 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id EE4FC23772
	for <containers@archiver.kernel.org>; Fri, 15 Jan 2021 16:26:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EE4FC23772
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 7EFD220411;
	Fri, 15 Jan 2021 16:26:37 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id gUTHiXmphBdx; Fri, 15 Jan 2021 16:26:36 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 62AF72035C;
	Fri, 15 Jan 2021 16:26:36 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 43803C0893;
	Fri, 15 Jan 2021 16:26:36 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id A59D3C013A
 for <containers@lists.linux-foundation.org>;
 Fri, 15 Jan 2021 16:26:33 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 8BA4B86CCF
 for <containers@lists.linux-foundation.org>;
 Fri, 15 Jan 2021 16:26:33 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id b8TMLVPbyLm2
 for <containers@lists.linux-foundation.org>;
 Fri, 15 Jan 2021 16:26:31 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from casper.infradead.org (casper.infradead.org [90.155.50.34])
 by whitealder.osuosl.org (Postfix) with ESMTPS id B70D6838B8
 for <containers@lists.linux-foundation.org>;
 Fri, 15 Jan 2021 16:26:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
 d=infradead.org; s=casper.20170209; h=In-Reply-To:Content-Type:MIME-Version:
 References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
 Content-Transfer-Encoding:Content-ID:Content-Description;
 bh=EUWYO0kUNOPL0+8rq+jqNdckkmjaAICmJuUUQfapnmg=; b=JYVtCComagNhb7hqCp7+K8cypw
 3uzb/XWKSiI2wd079jfEh54E6UXbFNCkIXVtdMz85yoJmiYJ9S2w+4QoKhU1MSjyIOqb1p214g57v
 OYst5auFjT2CF13mk3P4uIRmdte6st+AwYPpwos0v4T/lMifmY9WrdQQJ/mDBdVXp56iuYGKsQtWe
 O2pK8U4clVUk2Sb9MeZFm3JHZxeH3A33eY9EJJ0tIyij6zOm4YqyFbZOyr+g0qLdX/iyHinGps0g6
 AsBdYcDqwjotOAlFnNds/nv+o8gK+6xKbVC4xJsqmvstk6kUedtXelBk3y7JipjaWC7Ly0vyoHz+5
 /kQvaNBw==;
Received: from hch by casper.infradead.org with local (Exim 4.94 #2 (Red Hat
 Linux)) id 1l0RsA-0099BH-9Q; Fri, 15 Jan 2021 16:22:55 +0000
Date: Fri, 15 Jan 2021 16:22:50 +0000
From: Christoph Hellwig <hch@infradead.org>
To: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v5 37/42] xfs: support idmapped mounts
Message-ID: <20210115162250.GA2179337@infradead.org>
References: <20210112220124.837960-1-christian.brauner@ubuntu.com>
 <20210112220124.837960-38-christian.brauner@ubuntu.com>
 <20210114205154.GL331610@dread.disaster.area>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20210114205154.GL331610@dread.disaster.area>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by
 casper.infradead.org. See http://www.infradead.org/rpr.html
Cc: Lennart Poettering <lennart@poettering.net>,
 Mimi Zohar <zohar@linux.ibm.com>, David Howells <dhowells@redhat.com>,
 Andreas Dilger <adilger.kernel@dilger.ca>,
 containers@lists.linux-foundation.org, Christoph Hellwig <hch@lst.de>,
 Tycho Andersen <tycho@tycho.ws>, Paul Moore <paul@paul-moore.com>,
 Jonathan Corbet <corbet@lwn.net>, smbarber@chromium.org,
 Christoph Hellwig <hch@infradead.org>, linux-ext4@vger.kernel.org,
 Mrunal Patel <mpatel@redhat.com>, Kees Cook <keescook@chromium.org>,
 Arnd Bergmann <arnd@arndb.de>, selinux@vger.kernel.org,
 Josh Triplett <josh@joshtriplett.org>, linux-fsdevel@vger.kernel.org,
 Aleksa Sarai <cyphar@cyphar.com>, Alexander Viro <viro@zeniv.linux.org.uk>,
 Andy Lutomirski <luto@kernel.org>,
 OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
 Geoffrey Thomas <geofft@ldpreload.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 John Johansen <john.johansen@canonical.com>, Theodore Tso <tytso@mit.edu>,
 Seth Forshee <seth.forshee@canonical.com>,
 Dmitry Kasatkin <dmitry.kasatkin@gmail.com>,
 Stephen Smalley <stephen.smalley.work@gmail.com>, linux-xfs@vger.kernel.org,
 linux-security-module@vger.kernel.org,
 "Eric W. Biederman" <ebiederm@xmission.com>, linux-api@vger.kernel.org,
 Casey Schaufler <casey@schaufler-ca.com>, Alban Crequy <alban@kinvolk.io>,
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

As Christian already explained we an't hit this with anything related
to uids/gids, the only thing that will be updated are the timestamps,
as also mentioned in the comment that only makes it partially into the
diff context.

> >  	trace_xfs_setattr(ip);
> >  
> > -	error = xfs_vn_change_ok(dentry, iattr);
> > +	error = xfs_vn_change_ok(mnt_userns, dentry, iattr);
> >  	if (error)
> >  		return error;
> >  	return xfs_setattr_size(ip, iattr);
> 
> And this passing mnt_userns down into xfs_setattr_size()?  Seems
> like a bit of a landmine...

That being said we could just pass down the argument, even if it doesn't
make much sense for the size update.
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
