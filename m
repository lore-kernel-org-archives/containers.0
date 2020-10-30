Return-Path: <SRS0=hUL4=EF=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1556FC00A89
	for <containers@archiver.kernel.org>; Fri, 30 Oct 2020 16:03:41 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 4EB9120724
	for <containers@archiver.kernel.org>; Fri, 30 Oct 2020 16:03:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4EB9120724
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=hallyn.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 4FA1620420;
	Fri, 30 Oct 2020 16:03:39 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id edl8762KwpM3; Fri, 30 Oct 2020 16:03:38 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 74CA92034B;
	Fri, 30 Oct 2020 16:03:38 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 5864BC0859;
	Fri, 30 Oct 2020 16:03:38 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id E7439C0051
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Oct 2020 16:03:36 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id DEF9E20420
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Oct 2020 16:03:36 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id Dk5U4JHQR5sH
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Oct 2020 16:03:35 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from mail.hallyn.com (mail.hallyn.com [178.63.66.53])
 by silver.osuosl.org (Postfix) with ESMTPS id 1A8B92034B
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Oct 2020 16:03:34 +0000 (UTC)
Received: by mail.hallyn.com (Postfix, from userid 1001)
 id 0CBD712C3; Fri, 30 Oct 2020 11:03:32 -0500 (CDT)
Date: Fri, 30 Oct 2020 11:03:32 -0500
From: "Serge E. Hallyn" <serge@hallyn.com>
To: Seth Forshee <seth.forshee@canonical.com>
Subject: Re: [PATCH 00/34] fs: idmapped mounts
Message-ID: <20201030160332.GA30083@mail.hallyn.com>
References: <20201029003252.2128653-1-christian.brauner@ubuntu.com>
 <87pn51ghju.fsf@x220.int.ebiederm.org>
 <20201029155148.5odu4j2kt62ahcxq@yavin.dot.cyphar.com>
 <87361xdm4c.fsf@x220.int.ebiederm.org>
 <20201030150748.GA176340@ubuntu-x1>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20201030150748.GA176340@ubuntu-x1>
User-Agent: Mutt/1.9.4 (2018-02-28)
Cc: Lennart Poettering <lennart@poettering.net>,
 Mimi Zohar <zohar@linux.ibm.com>, David Howells <dhowells@redhat.com>,
 Andreas Dilger <adilger.kernel@dilger.ca>,
 containers@lists.linux-foundation.org, Tycho Andersen <tycho@tycho.ws>,
 Miklos Szeredi <miklos@szeredi.hu>, smbarber@chromium.org,
 Christoph Hellwig <hch@infradead.org>, linux-ext4@vger.kernel.org,
 Mrunal Patel <mpatel@redhat.com>, Kees Cook <keescook@chromium.org>,
 Arnd Bergmann <arnd@arndb.de>, Jann Horn <jannh@google.com>,
 selinux@vger.kernel.org, Josh Triplett <josh@joshtriplett.org>,
 linux-fsdevel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>,
 Andy Lutomirski <luto@kernel.org>,
 OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
 Geoffrey Thomas <geofft@ldpreload.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 John Johansen <john.johansen@canonical.com>, Theodore Tso <tytso@mit.edu>,
 Dmitry Kasatkin <dmitry.kasatkin@gmail.com>,
 Stephen Smalley <stephen.smalley.work@gmail.com>,
 Jonathan Corbet <corbet@lwn.net>, linux-unionfs@vger.kernel.org,
 linux-security-module@vger.kernel.org, linux-audit@redhat.com,
 "Eric W. Biederman" <ebiederm@xmission.com>, linux-api@vger.kernel.org,
 Casey Schaufler <casey@schaufler-ca.com>, Alban Crequy <alban@kinvolk.io>,
 linux-integrity@vger.kernel.org, Todd Kjos <tkjos@google.com>
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

On Fri, Oct 30, 2020 at 10:07:48AM -0500, Seth Forshee wrote:
> On Thu, Oct 29, 2020 at 11:37:23AM -0500, Eric W. Biederman wrote:
> > First and foremost: A uid shift on write to a filesystem is a security
> > bug waiting to happen.  This is especially in the context of facilities
> > like iouring, that play very agressive games with how process context
> > makes it to  system calls.
> > 
> > The only reason containers were not immediately exploitable when iouring
> > was introduced is because the mechanisms are built so that even if
> > something escapes containment the security properties still apply.
> > Changes to the uid when writing to the filesystem does not have that
> > property.  The tiniest slip in containment will be a security issue.
> > 
> > This is not even the least bit theoretical.  I have seem reports of how
> > shitfs+overlayfs created a situation where anyone could read
> > /etc/shadow.
> 
> This bug was the result of a complex interaction with several
> contributing factors. It's fair to say that one component was overlayfs
> writing through an id-shifted mount, but the primary cause was related
> to how copy-up was done coupled with allowing unprivileged overlayfs
> mounts in a user ns. Checks that the mounter had access to the lower fs
> file were not done before copying data up, and so the file was copied up
> temporarily to the id shifted upperdir. Even though it was immediately
> removed, other factors made it possible for the user to get the file
> contents from the upperdir.
> 
> Regardless, I do think you raise a good point. We need to be wary of any
> place the kernel could open files through a shifted mount, especially
> when the open could be influenced by userspace.
> 
> Perhaps kernel file opens through shifted mounts should to be opt-in.
> I.e. unless a flag is passed, or a different open interface used, the
> open will fail if the dentry being opened is subject to id shifting.
> This way any kernel writes which would be subject to id shifting will
> only happen through code which as been written to take it into account.

For my use cases, it would be fine to require opt-in at original fs
mount time by init_user_ns admin.  I.e.
    mount -o allow_idmap /dev/mapper/whoozit /whatzit
I'm quite certain I would always be sharing a separate LV or loopback or
tmpfs.

-serge
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
