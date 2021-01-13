Return-Path: <SRS0=vxAo=GQ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	NICE_REPLY_A,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16FDBC433DB
	for <containers@archiver.kernel.org>; Wed, 13 Jan 2021 00:33:13 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 2148C2312F
	for <containers@archiver.kernel.org>; Wed, 13 Jan 2021 00:33:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2148C2312F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 8271F20495;
	Wed, 13 Jan 2021 00:33:11 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id fd5oU13Fw0Rl; Wed, 13 Jan 2021 00:33:10 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 9378420484;
	Wed, 13 Jan 2021 00:33:10 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 6DD5EC0893;
	Wed, 13 Jan 2021 00:33:10 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 29E00C013A
 for <containers@lists.linux-foundation.org>;
 Wed, 13 Jan 2021 00:33:08 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id D77B820495
 for <containers@lists.linux-foundation.org>;
 Wed, 13 Jan 2021 00:33:07 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id mOG6U2G3mS6h
 for <containers@lists.linux-foundation.org>;
 Wed, 13 Jan 2021 00:33:06 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from merlin.infradead.org (merlin.infradead.org [205.233.59.134])
 by silver.osuosl.org (Postfix) with ESMTPS id 69E1320484
 for <containers@lists.linux-foundation.org>;
 Wed, 13 Jan 2021 00:33:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
 d=infradead.org; s=merlin.20170209; h=Content-Transfer-Encoding:Content-Type:
 In-Reply-To:MIME-Version:Date:Message-ID:From:References:Cc:To:Subject:Sender
 :Reply-To:Content-ID:Content-Description;
 bh=I9mSrNXmHFYMPApxgFQbDM45P8v8X64ckBsmGZBNtcc=; b=u46K90hkeHO3rgVFT8nIkAgzOu
 URjQXngiZDy+HRu2wxUeRCxaK99ieki5JPU6LEoLpjhkVt8RQaLmgBoK0NLhGruy0JFl5qwVZ9cPS
 SBniw1n3CBJVYJBUDWfaeMzEtZSYDwOFRVc7C9nhxeLaPFQjoJu2oIJ7p6N9bT8/PtXvBzktQxxnd
 lRIYvTygjTQRLIo9G3UJCdSTY71pssx/RAVQAZanXGgnbufK9U6wyvZ9UVYX99gwEq42DMQDLHimz
 u/83ju95Eitc0mOBWxZ9GyeE9wzkY074t/cE1JnWyD2WdLBsAqlep2idC+WvMkdxzcr/OJOiGlAaG
 4EiP6yjQ==;
Received: from [2601:1c0:6280:3f0::9abc]
 by merlin.infradead.org with esmtpsa (Exim 4.92.3 #3 (Red Hat Linux))
 id 1kzU5g-0006Zu-CI; Wed, 13 Jan 2021 00:32:48 +0000
Subject: Re: [PATCH v5 41/42] tests: extend mount_setattr tests
To: Christian Brauner <christian.brauner@ubuntu.com>,
 Alexander Viro <viro@zeniv.linux.org.uk>,
 Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org
References: <20210112220124.837960-1-christian.brauner@ubuntu.com>
 <20210112220124.837960-42-christian.brauner@ubuntu.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <5060dcc4-09a3-0ccc-6080-aab3f6b9caef@infradead.org>
Date: Tue, 12 Jan 2021 16:32:32 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:78.0) Gecko/20100101
 Thunderbird/78.4.0
MIME-Version: 1.0
In-Reply-To: <20210112220124.837960-42-christian.brauner@ubuntu.com>
Content-Language: en-US
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
 Seth Forshee <seth.forshee@canonical.com>, Aleksa Sarai <cyphar@cyphar.com>,
 Andy Lutomirski <luto@kernel.org>,
 OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
 Geoffrey Thomas <geofft@ldpreload.com>, David Howells <dhowells@redhat.com>,
 John Johansen <john.johansen@canonical.com>, Theodore Tso <tytso@mit.edu>,
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

Hi,


On 1/12/21 2:01 PM, Christian Brauner wrote:
> ---
> /* v2 */
> patch introduced
> 
> /* v3 */
> - Christoph Hellwig <hch@lst.de>, Darrick J. Wong <darrick.wong@oracle.com>:
>   - Port main test-suite to xfstests.
> 
> /* v4 */
> unchanged
> 
> /* v5 */
> base-commit: 7c53f6b671f4aba70ff15e1b05148b10d58c2837
> ---
>  .../mount_setattr/mount_setattr_test.c        | 483 ++++++++++++++++++
>  1 file changed, 483 insertions(+)
> 
> diff --git a/tools/testing/selftests/mount_setattr/mount_setattr_test.c b/tools/testing/selftests/mount_setattr/mount_setattr_test.c
> index 447b91c05cbd..4e94e566e040 100644
> --- a/tools/testing/selftests/mount_setattr/mount_setattr_test.c
> +++ b/tools/testing/selftests/mount_setattr/mount_setattr_test.c
> @@ -108,15 +108,57 @@ struct mount_attr {
>  	__u64 attr_set;
>  	__u64 attr_clr;
>  	__u64 propagation;
> +	__u64 userns_fd;
>  };
>  #endif

...


Does "/**" have any special meaning inside tools/testing/ and the
selftest framework?  (I don't see any other such users.)

If not, can you just use the usual "/*" instead? (multiple locations)


> +/**
> + * Validate that negative fd values are rejected.
> + */
> +TEST_F(mount_setattr_idmapped, invalid_fd_negative)
> +{
...

> +}
> +
> +/**
> + * Validate that excessively large fd values are rejected.
> + */
> +TEST_F(mount_setattr_idmapped, invalid_fd_large)
> +{
...

> +}
> +
> +/**
> + * Validate that closed fd values are rejected.
> + */
> +TEST_F(mount_setattr_idmapped, invalid_fd_closed)
> +{
...

> +	}
> +}
> +
> +/**
> + * Validate that the initial user namespace is rejected.
> + */
> +TEST_F(mount_setattr_idmapped, invalid_fd_initial_userns)
> +{
...

> +/**
> + * Validate that an attached mount in our mount namespace can be idmapped.
> + * (The kernel enforces that the mount's mount namespace and the caller's mount
> + *  namespace match.)
> + */
> +TEST_F(mount_setattr_idmapped, attached_mount_inside_current_mount_namespace)
> +{
> +}
> +
> +/**
> + * Validate that idmapping a mount is rejected if the mount's mount namespace
> + * and our mount namespace don't match.
> + * (The kernel enforces that the mount's mount namespace and the caller's mount
> + *  namespace match.)
> + */
> +TEST_F(mount_setattr_idmapped, attached_mount_outside_current_mount_namespace)
> +{
...

> +}
> +
> +/**
> + * Validate that an attached mount in our mount namespace can be idmapped.
> + */
> +TEST_F(mount_setattr_idmapped, detached_mount_inside_current_mount_namespace)
> +{
...

> +}
> +
> +/**
> + * Validate that a detached mount not in our mount namespace can be idmapped.
> + */
> +TEST_F(mount_setattr_idmapped, detached_mount_outside_current_mount_namespace)
> +{
...

> +}
> +
> +/**
> + * Validate that currently changing the idmapping of an idmapped mount fails.
> + */
> +TEST_F(mount_setattr_idmapped, change_idmapping)
> +{


thanks.
-- 
~Randy
You can't do anything without having to do something else first.
-- Belefant's Law
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
