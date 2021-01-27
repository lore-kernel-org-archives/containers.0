Return-Path: <SRS0=oCe4=G6=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A06CC433E0
	for <containers@archiver.kernel.org>; Wed, 27 Jan 2021 05:50:19 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 9C55A20709
	for <containers@archiver.kernel.org>; Wed, 27 Jan 2021 05:50:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9C55A20709
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=hallyn.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 4A1B08554A;
	Wed, 27 Jan 2021 05:50:18 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id RrvfiES_e0bA; Wed, 27 Jan 2021 05:50:17 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 9FE5A84EF0;
	Wed, 27 Jan 2021 05:50:17 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 828B0C08A1;
	Wed, 27 Jan 2021 05:50:17 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id E188EC013A
 for <containers@lists.linux-foundation.org>;
 Wed, 27 Jan 2021 05:50:15 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id C46492049C
 for <containers@lists.linux-foundation.org>;
 Wed, 27 Jan 2021 05:50:15 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 9dh5xD4dLFsy
 for <containers@lists.linux-foundation.org>;
 Wed, 27 Jan 2021 05:50:14 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from mail.hallyn.com (mail.hallyn.com [178.63.66.53])
 by silver.osuosl.org (Postfix) with ESMTPS id E3118200ED
 for <containers@lists.linux-foundation.org>;
 Wed, 27 Jan 2021 05:50:13 +0000 (UTC)
Received: by mail.hallyn.com (Postfix, from userid 1001)
 id 55466864; Tue, 26 Jan 2021 23:50:12 -0600 (CST)
Date: Tue, 26 Jan 2021 23:50:12 -0600
From: "Serge E. Hallyn" <serge@hallyn.com>
To: Christian Brauner <christian.brauner@ubuntu.com>
Subject: Re: [PATCH v6 23/40] exec: handle idmapped mounts
Message-ID: <20210127055012.GA32153@mail.hallyn.com>
References: <20210121131959.646623-1-christian.brauner@ubuntu.com>
 <20210121131959.646623-24-christian.brauner@ubuntu.com>
 <875z3l0y56.fsf@x220.int.ebiederm.org>
 <20210125164404.aullgl3vlajgkef3@wittgenstein>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20210125164404.aullgl3vlajgkef3@wittgenstein>
User-Agent: Mutt/1.9.4 (2018-02-28)
Cc: Lennart Poettering <lennart@poettering.net>,
 Mimi Zohar <zohar@linux.ibm.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 Andreas Dilger <adilger.kernel@dilger.ca>,
 containers@lists.linux-foundation.org, Christoph Hellwig <hch@lst.de>,
 Tycho Andersen <tycho@tycho.ws>, Paul Moore <paul@paul-moore.com>,
 Jonathan Corbet <corbet@lwn.net>, smbarber@chromium.org,
 linux-ext4@vger.kernel.org, Mrunal Patel <mpatel@redhat.com>,
 Kees Cook <keescook@chromium.org>, Arnd Bergmann <arnd@arndb.de>,
 selinux@vger.kernel.org, Josh Triplett <josh@joshtriplett.org>,
 linux-fsdevel@vger.kernel.org, Aleksa Sarai <cyphar@cyphar.com>,
 Alexander Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>,
 OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
 Geoffrey Thomas <geofft@ldpreload.com>, David Howells <dhowells@redhat.com>,
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

On Mon, Jan 25, 2021 at 05:44:04PM +0100, Christian Brauner wrote:
> On Mon, Jan 25, 2021 at 10:39:01AM -0600, Eric W. Biederman wrote:
> > Christian Brauner <christian.brauner@ubuntu.com> writes:
> > 
> > > When executing a setuid binary the kernel will verify in bprm_fill_uid()
> > > that the inode has a mapping in the caller's user namespace before
> > > setting the callers uid and gid. Let bprm_fill_uid() handle idmapped
> > > mounts. If the inode is accessed through an idmapped mount it is mapped
> > > according to the mount's user namespace. Afterwards the checks are
> > > identical to non-idmapped mounts. If the initial user namespace is
> > > passed nothing changes so non-idmapped mounts will see identical
> > > behavior as before.
> > 
> > This does not handle the v3 capabilites xattr with embeds a uid.
> > So at least at that level you are missing some critical conversions.
> 
> Thanks for looking. Vfs v3 caps are handled earlier in the series. I'm
> not sure what you're referring to here. There are tests in xfstests that
> verify vfs3 capability behavior.
> 
> Christian

So fwiw I just tested it manually as well.  Scenario:

uid 1000 user ubuntu
uid 1001 user u2
sudo ./mount-idmapped --map-mount b:1000:1001:1 /home/ubuntu/ /mnt
su - u2
  cp /usr/bin/id /mnt/
  unshare -Urm
    setcap cap_setuid=pe /mnt/id
At this point, from init_user_ns,
ubuntu@fscaps:~/mount-idmapped$ /home/u2/rcap /mnt/id
v3, rootid is 1001
ubuntu@fscaps:~/mount-idmapped$ /home/u2/rcap //home/ubuntu/id
v3, rootid is 1000

-serge
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
