Return-Path: <SRS0=MeFG=EE=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 028E1C5DF9E
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 15:48:28 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 6E3122076E
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 15:48:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6E3122076E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=xmission.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 0A77886BFF;
	Thu, 29 Oct 2020 15:48:27 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id j9cnyNEK07lu; Thu, 29 Oct 2020 15:48:26 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 51C5986B00;
	Thu, 29 Oct 2020 15:48:26 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 39BDCC088B;
	Thu, 29 Oct 2020 15:48:26 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 319CBC0051
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 15:48:24 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 2C6F486CAB
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 15:48:24 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id iBEFs6T7T-Iv
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 15:48:23 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from out02.mta.xmission.com (out02.mta.xmission.com [166.70.13.232])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 8049D86CA1
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 15:48:23 +0000 (UTC)
Received: from in02.mta.xmission.com ([166.70.13.52])
 by out02.mta.xmission.com with esmtps (TLS1.3) tls
 TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384 (Exim 4.93)
 (envelope-from <ebiederm@xmission.com>)
 id 1kYA9W-008Etr-HE; Thu, 29 Oct 2020 09:47:50 -0600
Received: from ip68-227-160-95.om.om.cox.net ([68.227.160.95]
 helo=x220.xmission.com)
 by in02.mta.xmission.com with esmtpsa (TLS1.3) tls
 TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384 (Exim 4.93)
 (envelope-from <ebiederm@xmission.com>)
 id 1kYA9V-00AHk1-Ei; Thu, 29 Oct 2020 09:47:50 -0600
From: ebiederm@xmission.com (Eric W. Biederman)
To: Christian Brauner <christian.brauner@ubuntu.com>
References: <20201029003252.2128653-1-christian.brauner@ubuntu.com>
Date: Thu, 29 Oct 2020 10:47:49 -0500
In-Reply-To: <20201029003252.2128653-1-christian.brauner@ubuntu.com>
 (Christian Brauner's message of "Thu, 29 Oct 2020 01:32:18 +0100")
Message-ID: <87pn51ghju.fsf@x220.int.ebiederm.org>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
X-XM-SPF: eid=1kYA9V-00AHk1-Ei; ; ; mid=<87pn51ghju.fsf@x220.int.ebiederm.org>;
 ; ; hst=in02.mta.xmission.com; ; ; ip=68.227.160.95; ; ;
 frm=ebiederm@xmission.com; ; ; spf=neutral
X-XM-AID: U2FsdGVkX1/KO2990XPv4odhdV8LRkhzi7akeV9MiV4=
X-SA-Exim-Connect-IP: 68.227.160.95
X-SA-Exim-Mail-From: ebiederm@xmission.com
Subject: Re: [PATCH 00/34] fs: idmapped mounts
X-SA-Exim-Version: 4.2.1 (built Sat, 08 Feb 2020 21:53:50 +0000)
X-SA-Exim-Scanned: Yes (on in02.mta.xmission.com)
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

Christian Brauner <christian.brauner@ubuntu.com> writes:

> Hey everyone,
>
> I vanished for a little while to focus on this work here so sorry for
> not being available by mail for a while.
>
> Since quite a long time we have issues with sharing mounts between
> multiple unprivileged containers with different id mappings, sharing a
> rootfs between multiple containers with different id mappings, and also
> sharing regular directories and filesystems between users with different
> uids and gids. The latter use-cases have become even more important with
> the availability and adoption of systemd-homed (cf. [1]) to implement
> portable home directories.

Can you walk us through the motivating use case?

As of this year's LPC I had the distinct impression that the primary use
case for such a feature was due to the RLIMIT_NPROC problem where two
containers with the same users still wanted different uid mappings to
the disk because the users were conflicting with each other because of
the per user rlimits.

Fixing rlimits is straight forward to implement, and easier to manage
for implementations and administrators.



Reading up on systemd-homed it appears to be a way to have encrypted
home directories.  Those home directories can either be encrypted at the
fs or at the block level.  Those home directories appear to have the
goal of being luggable between systems.  If the systems in question
don't have common administration of uids and gids after lugging your
encrypted home directory to another system chowning the files is
required.

Is that the use case you are looking at removing the need for
systemd-homed to avoid chowning after lugging encrypted home directories
from one system to another?  Why would it be desirable to avoid the
chown?


If the goal is to solve fragmented administration of uid assignment I
suggest that it might be better to solve the administration problem so
that all of the uids of interest get assigned the same way on all of the
systems of interest.  To the extent it is possible to solve the uid
assignment problem that would seem to have fewer long term
administrative problems.

Eric
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
