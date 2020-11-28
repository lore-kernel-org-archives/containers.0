Return-Path: <SRS0=+MRp=FC=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 345F8C63777
	for <containers@archiver.kernel.org>; Sat, 28 Nov 2020 22:54:58 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 8CF2D207FF
	for <containers@archiver.kernel.org>; Sat, 28 Nov 2020 22:54:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8CF2D207FF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=hallyn.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 55FFD204A7;
	Sat, 28 Nov 2020 22:54:57 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id zCb5+DYkKef9; Sat, 28 Nov 2020 22:54:55 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id B183D203F7;
	Sat, 28 Nov 2020 22:54:55 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id A6CDDC163C;
	Sat, 28 Nov 2020 22:54:55 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 92699C0052
 for <containers@lists.linux-foundation.org>;
 Sat, 28 Nov 2020 22:54:53 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 8DC8F87744
 for <containers@lists.linux-foundation.org>;
 Sat, 28 Nov 2020 22:54:53 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id Ph0DyJEVTwSP
 for <containers@lists.linux-foundation.org>;
 Sat, 28 Nov 2020 22:54:52 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from mail.hallyn.com (mail.hallyn.com [178.63.66.53])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 5EE0487743
 for <containers@lists.linux-foundation.org>;
 Sat, 28 Nov 2020 22:54:52 +0000 (UTC)
Received: by mail.hallyn.com (Postfix, from userid 1001)
 id 65BD38AB; Sat, 28 Nov 2020 16:54:50 -0600 (CST)
Date: Sat, 28 Nov 2020 16:54:50 -0600
From: "Serge E. Hallyn" <serge@hallyn.com>
To: Christian Brauner <christian.brauner@ubuntu.com>
Subject: Re: [PATCH v3 00/38] idmapped mounts
Message-ID: <20201128225450.GC22812@mail.hallyn.com>
References: <20201128213527.2669807-1-christian.brauner@ubuntu.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20201128213527.2669807-1-christian.brauner@ubuntu.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
Cc: Lennart Poettering <lennart@poettering.net>,
 Mimi Zohar <zohar@linux.ibm.com>, David Howells <dhowells@redhat.com>,
 Andreas Dilger <adilger.kernel@dilger.ca>,
 containers@lists.linux-foundation.org, Tycho Andersen <tycho@tycho.ws>,
 Paul Moore <paul@paul-moore.com>, Jonathan Corbet <corbet@lwn.net>,
 smbarber@chromium.org, Christoph Hellwig <hch@infradead.org>,
 Alban Crequy <alban@kinvolk.io>, linux-ext4@vger.kernel.org,
 Mrunal Patel <mpatel@redhat.com>, Kees Cook <keescook@chromium.org>,
 Arnd Bergmann <arnd@arndb.de>, selinux@vger.kernel.org,
 Josh Triplett <josh@joshtriplett.org>,
 Seth Forshee <seth.forshee@canonical.com>, Aleksa Sarai <cyphar@cyphar.com>,
 Alexander Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>,
 OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
 Geoffrey Thomas <geofft@ldpreload.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 John Johansen <john.johansen@canonical.com>, Theodore Tso <tytso@mit.edu>,
 Dmitry Kasatkin <dmitry.kasatkin@gmail.com>,
 Stephen Smalley <stephen.smalley.work@gmail.com>, fstests@vger.kernel.org,
 linux-security-module@vger.kernel.org,
 "Eric W. Biederman" <ebiederm@xmission.com>, linux-api@vger.kernel.org,
 Casey Schaufler <casey@schaufler-ca.com>, linux-fsdevel@vger.kernel.org,
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

On Sat, Nov 28, 2020 at 10:34:49PM +0100, Christian Brauner wrote:
> Hey everyone,

Hey Christian,

a general request.  Argue with me if it seems misguided.

When looking at a patch or a small hunk of code, these days, if a variable
called 'ns' or 'user_ns' is seen passed to a function, it can be easy to
assume which user_ns it is based on what you think would make sense, but if
your assumption is wrong, your patch review will be wrong.

Can we stick to a convention where we have maybe

subj_userns - the userns of the task seeking some action
obj_userns - the userns of the thing being acted on - task, superblock,...
mnt_userns - the userns of a mountpoint through which an object is seen

You're replacing a lot of such callers and callsites in this patchset, so
this would be a great time to start doing that.

-serge
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
