Return-Path: <SRS0=Tc9O=GZ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,URIBL_RED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AECFCC433E0
	for <containers@archiver.kernel.org>; Fri, 22 Jan 2021 02:56:07 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id ED77922C7D
	for <containers@archiver.kernel.org>; Fri, 22 Jan 2021 02:56:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ED77922C7D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=namei.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id A906B86559;
	Fri, 22 Jan 2021 02:56:06 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id hUPk0bHpERLT; Fri, 22 Jan 2021 02:56:05 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id B10A286546;
	Fri, 22 Jan 2021 02:56:05 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 95BBCC08A1;
	Fri, 22 Jan 2021 02:56:05 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id C2BD6C013A
 for <containers@lists.linux-foundation.org>;
 Fri, 22 Jan 2021 02:56:03 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id A96A586D26
 for <containers@lists.linux-foundation.org>;
 Fri, 22 Jan 2021 02:56:03 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id x-uYkHT+lZAy
 for <containers@lists.linux-foundation.org>;
 Fri, 22 Jan 2021 02:56:02 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from mail.namei.org (namei.org [65.99.196.166])
 by whitealder.osuosl.org (Postfix) with ESMTPS id B340186E08
 for <containers@lists.linux-foundation.org>;
 Fri, 22 Jan 2021 02:56:02 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by mail.namei.org (Postfix) with ESMTPS id D4D118CE;
 Fri, 22 Jan 2021 02:55:08 +0000 (UTC)
Date: Fri, 22 Jan 2021 13:55:08 +1100 (AEDT)
From: James Morris <jmorris@namei.org>
To: Christian Brauner <christian.brauner@ubuntu.com>
Subject: Re: [PATCH v6 03/40] fs: add file and path permissions helpers
In-Reply-To: <20210121131959.646623-4-christian.brauner@ubuntu.com>
Message-ID: <8c172a1d-e0ae-9796-f5f5-def7fc3de3@namei.org>
References: <20210121131959.646623-1-christian.brauner@ubuntu.com>
 <20210121131959.646623-4-christian.brauner@ubuntu.com>
MIME-Version: 1.0
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

On Thu, 21 Jan 2021, Christian Brauner wrote:

> Add two simple helpers to check permissions on a file and path
> respectively and convert over some callers. It simplifies quite a few
> codepaths and also reduces the churn in later patches quite a bit.
> Christoph also correctly points out that this makes codepaths (e.g.
> ioctls) way easier to follow that would otherwise have to do more
> complex argument passing than necessary.
> 
> Link: https://lore.kernel.org/r/20210112220124.837960-16-christian.brauner@ubuntu.com
> Cc: David Howells <dhowells@redhat.com>
> Cc: Al Viro <viro@zeniv.linux.org.uk>
> Cc: linux-fsdevel@vger.kernel.org
> Suggested-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> Signed-off-by: Christian Brauner <christian.brauner@ubuntu.com>


Reviewed-by: James Morris <jamorris@linux.microsoft.com>


-- 
James Morris
<jmorris@namei.org>

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
