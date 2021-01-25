Return-Path: <SRS0=rDR3=G4=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC823C433DB
	for <containers@archiver.kernel.org>; Mon, 25 Jan 2021 16:40:49 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 6FBF0225AB
	for <containers@archiver.kernel.org>; Mon, 25 Jan 2021 16:40:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6FBF0225AB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=xmission.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 1F82786C2D;
	Mon, 25 Jan 2021 16:40:49 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id RO5QmEkQbgyA; Mon, 25 Jan 2021 16:40:48 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 5FE1F86C2C;
	Mon, 25 Jan 2021 16:40:48 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 48FC4C08A1;
	Mon, 25 Jan 2021 16:40:48 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id A910CC013A
 for <containers@lists.linux-foundation.org>;
 Mon, 25 Jan 2021 16:40:46 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 95F7686C2C
 for <containers@lists.linux-foundation.org>;
 Mon, 25 Jan 2021 16:40:46 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id jDuJvZHmcDxQ
 for <containers@lists.linux-foundation.org>;
 Mon, 25 Jan 2021 16:40:45 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from out03.mta.xmission.com (out03.mta.xmission.com [166.70.13.233])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 962D886806
 for <containers@lists.linux-foundation.org>;
 Mon, 25 Jan 2021 16:40:45 +0000 (UTC)
Received: from in02.mta.xmission.com ([166.70.13.52])
 by out03.mta.xmission.com with esmtps (TLS1.3) tls
 TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384 (Exim 4.93)
 (envelope-from <ebiederm@xmission.com>)
 id 1l44ua-000JK6-HB; Mon, 25 Jan 2021 09:40:20 -0700
Received: from ip68-227-160-95.om.om.cox.net ([68.227.160.95]
 helo=x220.xmission.com)
 by in02.mta.xmission.com with esmtpsa (TLS1.3) tls
 TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384 (Exim 4.93)
 (envelope-from <ebiederm@xmission.com>)
 id 1l44uY-005na2-OS; Mon, 25 Jan 2021 09:40:20 -0700
From: ebiederm@xmission.com (Eric W. Biederman)
To: Christian Brauner <christian.brauner@ubuntu.com>
References: <20210121131959.646623-1-christian.brauner@ubuntu.com>
 <20210121131959.646623-24-christian.brauner@ubuntu.com>
Date: Mon, 25 Jan 2021 10:39:01 -0600
In-Reply-To: <20210121131959.646623-24-christian.brauner@ubuntu.com>
 (Christian Brauner's message of "Thu, 21 Jan 2021 14:19:42 +0100")
Message-ID: <875z3l0y56.fsf@x220.int.ebiederm.org>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
X-XM-SPF: eid=1l44uY-005na2-OS; ; ; mid=<875z3l0y56.fsf@x220.int.ebiederm.org>;
 ; ; hst=in02.mta.xmission.com; ; ; ip=68.227.160.95; ; ;
 frm=ebiederm@xmission.com; ; ; spf=neutral
X-XM-AID: U2FsdGVkX1/xzi6ZD1Y1LahVVXJQCa6ijNXolO+AIc8=
X-SA-Exim-Connect-IP: 68.227.160.95
X-SA-Exim-Mail-From: ebiederm@xmission.com
Subject: Re: [PATCH v6 23/40] exec: handle idmapped mounts
X-SA-Exim-Version: 4.2.1 (built Sat, 08 Feb 2020 21:53:50 +0000)
X-SA-Exim-Scanned: Yes (on in02.mta.xmission.com)
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
 linux-security-module@vger.kernel.org, linux-api@vger.kernel.org,
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

Christian Brauner <christian.brauner@ubuntu.com> writes:

> When executing a setuid binary the kernel will verify in bprm_fill_uid()
> that the inode has a mapping in the caller's user namespace before
> setting the callers uid and gid. Let bprm_fill_uid() handle idmapped
> mounts. If the inode is accessed through an idmapped mount it is mapped
> according to the mount's user namespace. Afterwards the checks are
> identical to non-idmapped mounts. If the initial user namespace is
> passed nothing changes so non-idmapped mounts will see identical
> behavior as before.

This does not handle the v3 capabilites xattr with embeds a uid.
So at least at that level you are missing some critical conversions.

Eric

> Link: https://lore.kernel.org/r/20210112220124.837960-32-christian.brauner@ubuntu.com
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: David Howells <dhowells@redhat.com>
> Cc: Al Viro <viro@zeniv.linux.org.uk>
> Cc: linux-fsdevel@vger.kernel.org
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> Signed-off-by: Christian Brauner <christian.brauner@ubuntu.com>
> ---
> /* v2 */
> unchanged
>
> /* v3 */
> unchanged
>
> /* v4 */
> - Serge Hallyn <serge@hallyn.com>:
>   - Use "mnt_userns" to refer to a vfsmount's userns everywhere to make
>     terminology consistent.
>
> /* v5 */
> unchanged
> base-commit: 7c53f6b671f4aba70ff15e1b05148b10d58c2837
>
> /* v6 */
> base-commit: 19c329f6808995b142b3966301f217c831e7cf31
>
> - Christoph Hellwig <hch@lst.de>:
>   - Use new file_mnt_user_ns() helper.
> ---
>  fs/exec.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
>
> diff --git a/fs/exec.c b/fs/exec.c
> index d803227805f6..48d1e8b1610b 100644
> --- a/fs/exec.c
> +++ b/fs/exec.c
> @@ -1580,6 +1580,7 @@ static void check_unsafe_exec(struct linux_binprm *bprm)
>  static void bprm_fill_uid(struct linux_binprm *bprm, struct file *file)
>  {
>  	/* Handle suid and sgid on files */
> +	struct user_namespace *mnt_userns;
>  	struct inode *inode;
>  	unsigned int mode;
>  	kuid_t uid;
> @@ -1596,13 +1597,15 @@ static void bprm_fill_uid(struct linux_binprm *bprm, struct file *file)
>  	if (!(mode & (S_ISUID|S_ISGID)))
>  		return;
>  
> +	mnt_userns = file_mnt_user_ns(file);
> +
>  	/* Be careful if suid/sgid is set */
>  	inode_lock(inode);
>  
>  	/* reload atomically mode/uid/gid now that lock held */
>  	mode = inode->i_mode;
> -	uid = inode->i_uid;
> -	gid = inode->i_gid;
> +	uid = i_uid_into_mnt(mnt_userns, inode);
> +	gid = i_gid_into_mnt(mnt_userns, inode);
>  	inode_unlock(inode);
>  
>  	/* We ignore suid/sgid if there are no mappings for them in the ns */
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
