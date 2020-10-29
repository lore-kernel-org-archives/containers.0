Return-Path: <SRS0=MeFG=EE=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C891C55179
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 16:15:28 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 6462520756
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 16:15:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6462520756
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=poettering.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id BD87A875A5;
	Thu, 29 Oct 2020 16:15:26 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 0jrqVzWdA-SC; Thu, 29 Oct 2020 16:15:24 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id EF4C78759E;
	Thu, 29 Oct 2020 16:15:23 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id E2572C0859;
	Thu, 29 Oct 2020 16:15:23 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 6CA23C0051
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 16:15:22 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 5567786B81
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 16:15:22 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id GXlFyXMf_Nrf
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 16:15:20 +0000 (UTC)
X-Greylist: delayed 00:10:12 by SQLgrey-1.7.6
Received: from gardel.0pointer.net (gardel.0pointer.net [85.214.157.71])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 94BE186B80
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 16:15:20 +0000 (UTC)
Received: from gardel-login.0pointer.net (gardel.0pointer.net [85.214.157.71])
 by gardel.0pointer.net (Postfix) with ESMTP id 8D3CAE80409;
 Thu, 29 Oct 2020 17:05:05 +0100 (CET)
Received: by gardel-login.0pointer.net (Postfix, from userid 1000)
 id E22A4160834; Thu, 29 Oct 2020 17:05:03 +0100 (CET)
Date: Thu, 29 Oct 2020 17:05:02 +0100
From: Lennart Poettering <lennart@poettering.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: Re: [PATCH 00/34] fs: idmapped mounts
Message-ID: <20201029160502.GA333141@gardel-login>
References: <20201029003252.2128653-1-christian.brauner@ubuntu.com>
 <87pn51ghju.fsf@x220.int.ebiederm.org>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <87pn51ghju.fsf@x220.int.ebiederm.org>
Cc: Mimi Zohar <zohar@linux.ibm.com>, David Howells <dhowells@redhat.com>,
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
 Seth Forshee <seth.forshee@canonical.com>,
 Dmitry Kasatkin <dmitry.kasatkin@gmail.com>,
 Stephen Smalley <stephen.smalley.work@gmail.com>,
 Jonathan Corbet <corbet@lwn.net>, linux-unionfs@vger.kernel.org,
 linux-security-module@vger.kernel.org, linux-audit@redhat.com,
 linux-api@vger.kernel.org, Casey Schaufler <casey@schaufler-ca.com>,
 Alban Crequy <alban@kinvolk.io>, linux-integrity@vger.kernel.org,
 Todd Kjos <tkjos@google.com>
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

On Do, 29.10.20 10:47, Eric W. Biederman (ebiederm@xmission.com) wrote:

> Is that the use case you are looking at removing the need for
> systemd-homed to avoid chowning after lugging encrypted home directories
> from one system to another?  Why would it be desirable to avoid the
> chown?

Yes, I am very interested in seeing Christian's work succeed, for the
usecase in systemd-homed. In systemd-homed each user gets their own
private file system, and these fs shall be owned by the user's local
UID, regardless in which system it is used. The UID should be an
artifact of the local, individual system in this model, and thus
the UID on of the same user/home on system A might be picked as 1010
and on another as 1543, and on a third as 1323, and it shouldn't
matter. This way, home directories become migratable without having to
universially sync UID assignments: it doesn't matter anymore what the
local UID is.

Right now we do a recursive chown() at login time to ensure the home
dir is properly owned. This has two disadvantages:

1. It's slow. In particular on large home dirs, it takes a while to go
   through the whole user's homedir tree and chown/adjust ACLs for
   everything.

2. Because it is so slow we take a shortcut right now: if the
   top-level home dir inode itself is owned by the correct user, we
   skip the recursive chowning. This means in the typical case where a
   user uses the same system most of the time, and thus the UID is
   stable we can avoid the slowness. But this comes at a drawback: if
   the user for some reason ends up with files in their homedir owned
   by an unrelated user, then we'll never notice or readjust.

> If the goal is to solve fragmented administration of uid assignment I
> suggest that it might be better to solve the administration problem so
> that all of the uids of interest get assigned the same way on all of the
> systems of interest.

Well, the goal is to make things simple and be able to use the home
dir everywhere without any prior preparation, without central UID
assignment authority.

The goal is to have a scheme that requires no administration, by
making the UID management problem go away. Hence, if you suggest
solving this by having a central administrative authority: this is
exactly what the model wants to get away from.

Or to say this differently: just because I personally use three
different computers, I certainly don't want to set up LDAP or sync
UIDs manually.

Lennart

--
Lennart Poettering, Berlin
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
