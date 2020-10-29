Return-Path: <SRS0=MeFG=EE=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3F9CC4363A
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 16:37:46 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 5F28520719
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 16:37:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F28520719
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=xmission.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id B2B862270C;
	Thu, 29 Oct 2020 16:37:45 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 9p42UZuy5Pxa; Thu, 29 Oct 2020 16:37:42 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id B7C1B2039A;
	Thu, 29 Oct 2020 16:37:42 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id A7DD1C0859;
	Thu, 29 Oct 2020 16:37:42 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id AEE0AC0051
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 16:37:40 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id A84AA86972
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 16:37:40 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 0gtOmb8bFiOj
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 16:37:40 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from out03.mta.xmission.com (out03.mta.xmission.com [166.70.13.233])
 by whitealder.osuosl.org (Postfix) with ESMTPS id F05D98688F
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 16:37:39 +0000 (UTC)
Received: from in01.mta.xmission.com ([166.70.13.51])
 by out03.mta.xmission.com with esmtps (TLS1.2) tls
 TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256 (Exim 4.93)
 (envelope-from <ebiederm@xmission.com>)
 id 1kYAvU-00C748-2E; Thu, 29 Oct 2020 10:37:24 -0600
Received: from ip68-227-160-95.om.om.cox.net ([68.227.160.95]
 helo=x220.xmission.com) by in01.mta.xmission.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_256_GCM_SHA384:256) (Exim 4.87)
 (envelope-from <ebiederm@xmission.com>)
 id 1kYAvS-0008Bk-Sf; Thu, 29 Oct 2020 10:37:23 -0600
From: ebiederm@xmission.com (Eric W. Biederman)
To: Aleksa Sarai <cyphar@cyphar.com>
References: <20201029003252.2128653-1-christian.brauner@ubuntu.com>
 <87pn51ghju.fsf@x220.int.ebiederm.org>
 <20201029155148.5odu4j2kt62ahcxq@yavin.dot.cyphar.com>
Date: Thu, 29 Oct 2020 11:37:23 -0500
In-Reply-To: <20201029155148.5odu4j2kt62ahcxq@yavin.dot.cyphar.com> (Aleksa
 Sarai's message of "Fri, 30 Oct 2020 02:51:48 +1100")
Message-ID: <87361xdm4c.fsf@x220.int.ebiederm.org>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
X-XM-SPF: eid=1kYAvS-0008Bk-Sf; ; ; mid=<87361xdm4c.fsf@x220.int.ebiederm.org>;
 ; ; hst=in01.mta.xmission.com; ; ; ip=68.227.160.95; ; ;
 frm=ebiederm@xmission.com; ; ; spf=neutral
X-XM-AID: U2FsdGVkX180W5DqIedhnPmHhxEi5hPqd4yVVQ9Dudw=
X-SA-Exim-Connect-IP: 68.227.160.95
X-SA-Exim-Mail-From: ebiederm@xmission.com
Subject: Re: [PATCH 00/34] fs: idmapped mounts
X-SA-Exim-Version: 4.2.1 (built Thu, 05 May 2016 13:38:54 -0600)
X-SA-Exim-Scanned: Yes (on in01.mta.xmission.com)
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

Aleksa Sarai <cyphar@cyphar.com> writes:

> On 2020-10-29, Eric W. Biederman <ebiederm@xmission.com> wrote:
>> Christian Brauner <christian.brauner@ubuntu.com> writes:
>> 
>> > Hey everyone,
>> >
>> > I vanished for a little while to focus on this work here so sorry for
>> > not being available by mail for a while.
>> >
>> > Since quite a long time we have issues with sharing mounts between
>> > multiple unprivileged containers with different id mappings, sharing a
>> > rootfs between multiple containers with different id mappings, and also
>> > sharing regular directories and filesystems between users with different
>> > uids and gids. The latter use-cases have become even more important with
>> > the availability and adoption of systemd-homed (cf. [1]) to implement
>> > portable home directories.
>> 
>> Can you walk us through the motivating use case?
>> 
>> As of this year's LPC I had the distinct impression that the primary use
>> case for such a feature was due to the RLIMIT_NPROC problem where two
>> containers with the same users still wanted different uid mappings to
>> the disk because the users were conflicting with each other because of
>> the per user rlimits.
>> 
>> Fixing rlimits is straight forward to implement, and easier to manage
>> for implementations and administrators.
>
> This is separate to the question of "isolated user namespaces" and
> managing different mappings between containers. This patchset is solving
> the same problem that shiftfs solved -- sharing a single directory tree
> between containers that have different ID mappings. rlimits (nor any of
> the other proposals we discussed at LPC) will help with this problem.

First and foremost: A uid shift on write to a filesystem is a security
bug waiting to happen.  This is especially in the context of facilities
like iouring, that play very agressive games with how process context
makes it to  system calls.

The only reason containers were not immediately exploitable when iouring
was introduced is because the mechanisms are built so that even if
something escapes containment the security properties still apply.
Changes to the uid when writing to the filesystem does not have that
property.  The tiniest slip in containment will be a security issue.

This is not even the least bit theoretical.  I have seem reports of how
shitfs+overlayfs created a situation where anyone could read
/etc/shadow.

If you are going to write using the same uid to disk from different
containers the question becomes why can't those containers configure
those users to use the same kuid?

What fixing rlimits does is it fixes one of the reasons that different
containers could not share the same kuid for users that want to write to
disk with the same uid.


I humbly suggest that it will be more secure, and easier to maintain for
both developers and users if we fix the reasons people want different
containers to have the same user running with different kuids.

If not what are the reasons we fundamentally need the same on-disk user
using multiple kuids in the kernel?

Eric
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
