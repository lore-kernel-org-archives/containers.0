Return-Path: <SRS0=Gs6x=GS=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2CA4CC433E9
	for <containers@archiver.kernel.org>; Fri, 15 Jan 2021 16:29:33 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id BCD17233CF
	for <containers@archiver.kernel.org>; Fri, 15 Jan 2021 16:29:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BCD17233CF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 5FE3420411;
	Fri, 15 Jan 2021 16:29:32 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id q5IQUJdnMEzo; Fri, 15 Jan 2021 16:29:31 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id D30FB2035C;
	Fri, 15 Jan 2021 16:29:31 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id B873EC0893;
	Fri, 15 Jan 2021 16:29:31 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id EF71DC013A
 for <containers@lists.linux-foundation.org>;
 Fri, 15 Jan 2021 16:29:29 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id D68558691A
 for <containers@lists.linux-foundation.org>;
 Fri, 15 Jan 2021 16:29:29 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id r3Kt8zotPwG2
 for <containers@lists.linux-foundation.org>;
 Fri, 15 Jan 2021 16:29:29 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from casper.infradead.org (casper.infradead.org [90.155.50.34])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 42C0A868E4
 for <containers@lists.linux-foundation.org>;
 Fri, 15 Jan 2021 16:29:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
 d=infradead.org; s=casper.20170209; h=In-Reply-To:Content-Type:MIME-Version:
 References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
 Content-Transfer-Encoding:Content-ID:Content-Description;
 bh=Er+tBpIbbLuj0OIqdNy2chPN/Ve8hzD1kKT3RJP39d0=; b=rwXZgdKUw066MkReZNwTWvdrDZ
 +O+Z5xhLd7/kx+ppy6ccAkQPteVkBvNBYeFaNHb1vOy5WPgAW8pROAq3ALviE/ofBGb5Z0OIJ5+AX
 3aTO9JYoy07VWConrD3cxcC01n5AJ/XuQifDlQYUD7Zdk9xhYoZlPu08/WVLh1X6pEs1F95ixJXRs
 GvyrkCwwE3486p2RN5bLzW9J4juLcJMEweckdeecRjBTjh/0ItC7SFnldUzVWbPOEdW/VcDQv0rsX
 QN+h7onKLGjZ6CTuzd6MpZCvn+yYvVFCLUl5X+47PEYMBijpxrr/AfP2+Fj9IHKDJgSwUxYKCpsOi
 aoK+IQOA==;
Received: from hch by casper.infradead.org with local (Exim 4.94 #2 (Red Hat
 Linux)) id 1l0Rtf-0099Fq-85; Fri, 15 Jan 2021 16:24:27 +0000
Date: Fri, 15 Jan 2021 16:24:23 +0000
From: Christoph Hellwig <hch@infradead.org>
To: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v5 00/42] idmapped mounts
Message-ID: <20210115162423.GB2179337@infradead.org>
References: <20210112220124.837960-1-christian.brauner@ubuntu.com>
 <20210114171241.GA1164240@magnolia>
 <20210114204334.GK331610@dread.disaster.area>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20210114204334.GK331610@dread.disaster.area>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by
 casper.infradead.org. See http://www.infradead.org/rpr.html
Cc: Lennart Poettering <lennart@poettering.net>,
 "Darrick J. Wong" <djwong@kernel.org>, Mimi Zohar <zohar@linux.ibm.com>,
 David Howells <dhowells@redhat.com>, Andreas Dilger <adilger.kernel@dilger.ca>,
 containers@lists.linux-foundation.org, Tycho Andersen <tycho@tycho.ws>,
 Paul Moore <paul@paul-moore.com>, Jonathan Corbet <corbet@lwn.net>,
 smbarber@chromium.org, Christoph Hellwig <hch@infradead.org>,
 linux-ext4@vger.kernel.org, Mrunal Patel <mpatel@redhat.com>,
 Kees Cook <keescook@chromium.org>, Arnd Bergmann <arnd@arndb.de>,
 selinux@vger.kernel.org, Josh Triplett <josh@joshtriplett.org>,
 linux-fsdevel@vger.kernel.org, Aleksa Sarai <cyphar@cyphar.com>,
 Alexander Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>,
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

On Fri, Jan 15, 2021 at 07:43:34AM +1100, Dave Chinner wrote:
> > That sounds neat.  AFAICT, the VFS passes the filesystem a mount userns
> > structure, which is then carried down the call stack to whatever
> > functions actually care about mapping kernel [ug]ids to their ondisk
> > versions?
> > 
> > Does quota still work after this patchset is applied?  There isn't any
> > mention of that in the cover letter and I don't see a code patch, so
> > does that mean everything just works?  I'm particularly curious about
> > whether there can exist processes with CAP_SYS_ADMIN and an idmapped
> > mount?  Syscalls like bulkstat and quotactl present file [ug]ids to
> > programs, but afaict there won't be any translating going on?
> 
> bulkstat is not allowed inside user namespaces. It's an init
> namespace only thing because it provides unchecked/unbounded access
> to all inodes in the filesystem, not just those contained within a
> specific mount container.
> 
> Hence I don't think bulkstat output (and other initns+root only
> filesystem introspection APIs) should be subject to or concerned
> about idmapping.

That is what the capabilities are designed for and we already check
for them.
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
