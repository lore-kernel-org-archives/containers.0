Return-Path: <SRS0=KJcZ=GT=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98CC8C433E6
	for <containers@archiver.kernel.org>; Sat, 16 Jan 2021 00:28:33 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 1EE2923A01
	for <containers@archiver.kernel.org>; Sat, 16 Jan 2021 00:28:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1EE2923A01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id A7FCE8741E;
	Sat, 16 Jan 2021 00:28:32 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id d9hx7oe75GZI; Sat, 16 Jan 2021 00:28:29 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 38DA8871F2;
	Sat, 16 Jan 2021 00:28:29 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 115F6C0893;
	Sat, 16 Jan 2021 00:28:29 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id BA502C013A
 for <containers@lists.linux-foundation.org>;
 Sat, 16 Jan 2021 00:28:27 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id AB26786BA8
 for <containers@lists.linux-foundation.org>;
 Sat, 16 Jan 2021 00:28:27 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id QKsLxs6bPDFF
 for <containers@lists.linux-foundation.org>;
 Sat, 16 Jan 2021 00:28:26 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 5DFF086BA5
 for <containers@lists.linux-foundation.org>;
 Sat, 16 Jan 2021 00:28:26 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1l0ZR2-0002Mr-95; Sat, 16 Jan 2021 00:27:20 +0000
Date: Sat, 16 Jan 2021 01:27:18 +0100
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH v5 00/42] idmapped mounts
Message-ID: <20210116002718.jjs6eov65cvwrata@wittgenstein>
References: <20210112220124.837960-1-christian.brauner@ubuntu.com>
 <20210114171241.GA1164240@magnolia>
 <20210114204334.GK331610@dread.disaster.area>
 <20210115162423.GB2179337@infradead.org> <YAHWGMb9rTehRsRz@mit.edu>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <YAHWGMb9rTehRsRz@mit.edu>
Cc: Lennart Poettering <lennart@poettering.net>,
 "Darrick J. Wong" <djwong@kernel.org>, Dave Chinner <david@fromorbit.com>,
 Mimi Zohar <zohar@linux.ibm.com>, David Howells <dhowells@redhat.com>,
 Andreas Dilger <adilger.kernel@dilger.ca>,
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
 John Johansen <john.johansen@canonical.com>,
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

On Fri, Jan 15, 2021 at 12:51:20PM -0500, Theodore Ts'o wrote:
> On Fri, Jan 15, 2021 at 04:24:23PM +0000, Christoph Hellwig wrote:
> > 
> > That is what the capabilities are designed for and we already check
> > for them.
> 
> So perhaps I'm confused, but my understanding is that in the
> containers world, capabilities are a lot more complicated.  There is:
> 
> 1) The initial namespace capability set
> 
> 2) The container's user-namespace capability set
> 
> 3) The namespace in which the file system is mounted --- which is
>       "usually, but not necessarily the initial namespace" and
>       presumably could potentially not necessarily be the current
>       container's user name space, is namespaces can be hierarchically
>       arranged.
> 
> Is that correct?  If so, how does this patch set change things (if
> any), and and how does this interact with quota administration
> operations?

The cases you listed are correct. The patchset doesn't change them.
Simply put, the patchset doesn't alter capability checking in any way.

> 
> On a related note, ext4 specifies a "reserved user" or "reserved
> group" which can access the reserved blocks.  If we have a file system
> which is mounted in a namespace running a container which is running
> RHEL or SLES, and in that container, we have a file system mounted (so
> it was not mounted in the initial namespace), with id-mapping --- and
> then there is a further sub-container created with its own user
> sub-namespace further mapping uids/gids --- will the right thing
> happen?  For that matter, how *is* the "right thing" defined?

In short, nothing changes. Whatever happened before happens now.

Specifically s_resuid/s_resgid are superblock mount options and so never
change on a per-mount basis and thus also aren't affected by idmapped
mounts.

> 
> Sorry if this is a potentially stupid question, but I find user
> namespaces and id and capability mapping to be hopefully confusing for
> my tiny brain.  :-)

No, I really appreciate the questions. :) My brain can most likely
handle less. :)

Christian
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
