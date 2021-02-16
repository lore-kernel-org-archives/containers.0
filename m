Return-Path: <SRS0=HkGd=HS=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-18.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4A4A1C433DB
	for <containers@archiver.kernel.org>; Tue, 16 Feb 2021 17:18:45 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id AFAC864DFF
	for <containers@archiver.kernel.org>; Tue, 16 Feb 2021 17:18:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AFAC864DFF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=xmission.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 87E0884806;
	Tue, 16 Feb 2021 17:18:44 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id H3pJIa_DDzSA; Tue, 16 Feb 2021 17:18:42 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id D83F1847FE;
	Tue, 16 Feb 2021 17:18:42 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id B1203C0893;
	Tue, 16 Feb 2021 17:18:42 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id D1D04C013A
 for <containers@lists.linux-foundation.org>;
 Tue, 16 Feb 2021 17:18:41 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id CA97E871B6
 for <containers@lists.linux-foundation.org>;
 Tue, 16 Feb 2021 17:18:41 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id PAF-Xz76IK04
 for <containers@lists.linux-foundation.org>;
 Tue, 16 Feb 2021 17:18:38 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from out01.mta.xmission.com (out01.mta.xmission.com [166.70.13.231])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 1FDBB87188
 for <containers@lists.linux-foundation.org>;
 Tue, 16 Feb 2021 17:18:37 +0000 (UTC)
Received: from in02.mta.xmission.com ([166.70.13.52])
 by out01.mta.xmission.com with esmtps (TLS1.3) tls
 TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384 (Exim 4.93)
 (envelope-from <ebiederm@xmission.com>)
 id 1lC3zf-00GWii-Lk; Tue, 16 Feb 2021 10:18:35 -0700
Received: from ip68-227-160-95.om.om.cox.net ([68.227.160.95]
 helo=fess.xmission.com)
 by in02.mta.xmission.com with esmtpsa (TLS1.3) tls
 TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384 (Exim 4.93)
 (envelope-from <ebiederm@xmission.com>)
 id 1lC3ze-002DXO-FQ; Tue, 16 Feb 2021 10:18:35 -0700
From: ebiederm@xmission.com (Eric W. Biederman)
To: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 16 Feb 2021 11:14:06 -0600
Message-ID: <m1o8gkrl41.fsf@fess.ebiederm.org>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
X-XM-SPF: eid=1lC3ze-002DXO-FQ; ; ; mid=<m1o8gkrl41.fsf@fess.ebiederm.org>; ; ;
 hst=in02.mta.xmission.com; ; ; ip=68.227.160.95; ; ; frm=ebiederm@xmission.com;
 ; ; spf=neutral
X-XM-AID: U2FsdGVkX190YvMRMg+aQiJEEmFMgKxYszdWrzXBCX0=
X-SA-Exim-Connect-IP: 68.227.160.95
X-SA-Exim-Mail-From: ebiederm@xmission.com
Subject: [GIT PULL] user namespace updates for v5.12-rc1
X-SA-Exim-Version: 4.2.1 (built Sat, 08 Feb 2020 21:53:50 +0000)
X-SA-Exim-Scanned: Yes (on in02.mta.xmission.com)
Cc: Linux Containers <containers@lists.linux-foundation.org>,
 linux-kernel@vger.kernel.org, "Andrew G. Morgan" <morgan@kernel.org>
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


Linus,

Please pull the userns-for-v5.12 branch from the git tree:

  git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git userns-for-v5.12

  HEAD: 95ebabde382c371572297915b104e55403674e73 capabilities: Don't allow writing ambiguous v3 file capabilities

There are several pieces of active development, but only a single change
made it through the gauntlet to be ready for v5.12.  That change is
tightening up the semantics of the v3 capabilities xattr.  It is just
short of being a bug-fix/security issue as no user space is known to
even generate the problem case.

A fix f2b00be48873 ("cap: fix conversions on getxattr") for v3 fscaps
has come in through the overlayfs tree for v5.11.  It touches different
functions so it should be conflict free.

Eric

commit 95ebabde382c371572297915b104e55403674e73
Author: Eric W. Biederman <ebiederm@xmission.com>
Date:   Thu Dec 17 09:42:00 2020 -0600

    capabilities: Don't allow writing ambiguous v3 file capabilities
    
    The v3 file capabilities have a uid field that records the filesystem
    uid of the root user of the user namespace the file capabilities are
    valid in.
    
    When someone is silly enough to have the same underlying uid as the
    root uid of multiple nested containers a v3 filesystem capability can
    be ambiguous.
    
    In the spirit of don't do that then, forbid writing a v3 filesystem
    capability if it is ambiguous.
    
    Fixes: 8db6c34f1dbc ("Introduce v3 namespaced file capabilities")
    Reviewed-by: Andrew G. Morgan <morgan@kernel.org>
    Reviewed-by: Serge Hallyn <serge@hallyn.com>
    Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 security/commoncap.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/security/commoncap.c b/security/commoncap.c
index bacc1111d871..74b9cc8cef34 100644
--- a/security/commoncap.c
+++ b/security/commoncap.c
@@ -481,7 +481,8 @@ int cap_convert_nscap(struct dentry *dentry, const void **ivalue, size_t size)
 	__u32 magic, nsmagic;
 	struct inode *inode = d_backing_inode(dentry);
 	struct user_namespace *task_ns = current_user_ns(),
-		*fs_ns = inode->i_sb->s_user_ns;
+		*fs_ns = inode->i_sb->s_user_ns,
+		*ancestor;
 	kuid_t rootid;
 	size_t newsize;
 
@@ -504,6 +505,15 @@ int cap_convert_nscap(struct dentry *dentry, const void **ivalue, size_t size)
 	if (nsrootid == -1)
 		return -EINVAL;
 
+	/*
+	 * Do not allow allow adding a v3 filesystem capability xattr
+	 * if the rootid field is ambiguous.
+	 */
+	for (ancestor = task_ns->parent; ancestor; ancestor = ancestor->parent) {
+		if (from_kuid(ancestor, rootid) == 0)
+			return -EINVAL;
+	}
+
 	newsize = sizeof(struct vfs_ns_cap_data);
 	nscap = kmalloc(newsize, GFP_ATOMIC);
 	if (!nscap)



_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
