Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A43DF39B4AF;
	Mon, 27 Apr 2026 08:26:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777278417; cv=none; b=PT8Ng6gpLqjscSKXUkda2kPSuxpUc2Pop7hoXMZAo9Lb7U6N0nMW6XwUquii/KzFguHBspctjqHkBW6s23CsdfNK9Z9GrTy/mwTjoQfg9v7wpjl+8WRtajg8BYxiIvGDkGrpauUaVKZIBxPt0QcohUNe13TBj8/+53c6lEO8SNw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777278417; c=relaxed/simple;
	bh=Hgw9EtwhJXIIPJ0mk5lcwbLt8+W+zvZCaQBpQ0guZXI=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=aIlNUxwaCYTbSk4Y6PQPa8f/xMBNir127RDMhIFsYyEFCvxjqQzxtldoE9ix51ZmSxACfRcMmbWo0L54hYpqZ8pLPqoPNN8UCiU2Kox+obqYtkj1xghS3mCxN1BYK2Frbf9ooxPnCPjiepekMDQgxmQq2q8Iq/UFoC289qrr9nw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=A8KTwBMj; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="A8KTwBMj"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4BA38C2BCB4;
	Mon, 27 Apr 2026 08:26:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1777278417;
	bh=Hgw9EtwhJXIIPJ0mk5lcwbLt8+W+zvZCaQBpQ0guZXI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=A8KTwBMjCtGtuzjLTMKE8oi/CaAr44CSPYATg3sz6lYyTh26tF3iOF+UZcsEStK5T
	 u/aWuHdCfDrwm/fPxyKFFi2+0wWX9+qCqh+FWhIBfLBnLUotCMONj6fxtaICELA6Ls
	 x1WiJ+WM0UoA87mVv/fYyvSHunuZi8HR+ZQJ6joGHCv2qBOlBOJ47EYBipqVuBu1CA
	 Dia8/+UVU5MdcTv2rcdPLIBfFgII+yI7HRvLlof2RhUz8krxdwg1dJVRCExfn/JUxS
	 buCMGNrdkCvxfW43f/tlVI/uHizDbbmbVfILmZHYe/iCJylFNkxZ8PJQTDg2C5h7KK
	 ZcuWZ2cyC16TA==
From: Alexey Gladkov <legion@kernel.org>
To: Christian Brauner <brauner@kernel.org>,
	Dan Klishch <danilklishch@gmail.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>,
	Aleksa Sarai <cyphar@cyphar.com>,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	Kees Cook <keescook@chromium.org>,
	containers@lists.linux.dev,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v10 1/7] namespace: record fully visible mounts in list
Date: Mon, 27 Apr 2026 10:26:02 +0200
Message-ID: <684859a8e0ac929cb89c1fbe16ce15b30c70eb1f.1777278334.git.legion@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <cover.1777278334.git.legion@kernel.org>
References: <cover.1776079055.git.legion@kernel.org> <cover.1777278334.git.legion@kernel.org>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Christian Brauner <brauner@kernel.org>

Instead of wading through all the mounts in the mount namespace rbtree
to find fully visible procfs and sysfs mounts, be honest about them
being special cruft and record them in a separate per-mount namespace
list.

Signed-off-by: Christian Brauner <brauner@kernel.org>
---
 fs/mount.h     |  4 ++++
 fs/namespace.c | 19 +++++++++++--------
 2 files changed, 15 insertions(+), 8 deletions(-)

diff --git a/fs/mount.h b/fs/mount.h
index e0816c11a198..5df134d56d47 100644
--- a/fs/mount.h
+++ b/fs/mount.h
@@ -25,6 +25,7 @@ struct mnt_namespace {
 	__u32			n_fsnotify_mask;
 	struct fsnotify_mark_connector __rcu *n_fsnotify_marks;
 #endif
+	struct hlist_head	mnt_visible_mounts; /* SB_I_USERNS_VISIBLE mounts */
 	unsigned int		nr_mounts; /* # of mounts in the namespace */
 	unsigned int		pending_mounts;
 	refcount_t		passive; /* number references not pinning @mounts */
@@ -90,6 +91,7 @@ struct mount {
 	int mnt_expiry_mark;		/* true if marked for expiry */
 	struct hlist_head mnt_pins;
 	struct hlist_head mnt_stuck_children;
+	struct hlist_node mnt_ns_visible; /* link in ns->mnt_visible_mounts */
 	struct mount *overmount;	/* mounted on ->mnt_root */
 } __randomize_layout;
 
@@ -207,6 +209,8 @@ static inline void move_from_ns(struct mount *mnt)
 		ns->mnt_first_node = rb_next(&mnt->mnt_node);
 	rb_erase(&mnt->mnt_node, &ns->mounts);
 	RB_CLEAR_NODE(&mnt->mnt_node);
+	if (!hlist_unhashed(&mnt->mnt_ns_visible))
+		hlist_del_init(&mnt->mnt_ns_visible);
 }
 
 bool has_locked_children(struct mount *mnt, struct dentry *dentry);
diff --git a/fs/namespace.c b/fs/namespace.c
index 854f4fc66469..539b74403072 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -321,6 +321,7 @@ static struct mount *alloc_vfsmnt(const char *name)
 		INIT_HLIST_NODE(&mnt->mnt_slave);
 		INIT_HLIST_NODE(&mnt->mnt_mp_list);
 		INIT_HLIST_HEAD(&mnt->mnt_stuck_children);
+		INIT_HLIST_NODE(&mnt->mnt_ns_visible);
 		RB_CLEAR_NODE(&mnt->mnt_node);
 		mnt->mnt.mnt_idmap = &nop_mnt_idmap;
 	}
@@ -1098,6 +1099,10 @@ static void mnt_add_to_ns(struct mnt_namespace *ns, struct mount *mnt)
 	rb_link_node(&mnt->mnt_node, parent, link);
 	rb_insert_color(&mnt->mnt_node, &ns->mounts);
 
+	if ((mnt->mnt.mnt_sb->s_iflags & SB_I_USERNS_VISIBLE) &&
+	    mnt->mnt.mnt_root == mnt->mnt.mnt_sb->s_root)
+		hlist_add_head(&mnt->mnt_ns_visible, &ns->mnt_visible_mounts);
+
 	mnt_notify_add(mnt);
 }
 
@@ -6310,22 +6315,20 @@ static bool mnt_already_visible(struct mnt_namespace *ns,
 				int *new_mnt_flags)
 {
 	int new_flags = *new_mnt_flags;
-	struct mount *mnt, *n;
+	struct mount *mnt;
+
+	/* Don't acquire namespace semaphore without a good reason. */
+	if (hlist_empty(&ns->mnt_visible_mounts))
+		return false;
 
 	guard(namespace_shared)();
-	rbtree_postorder_for_each_entry_safe(mnt, n, &ns->mounts, mnt_node) {
+	hlist_for_each_entry(mnt, &ns->mnt_visible_mounts, mnt_ns_visible) {
 		struct mount *child;
 		int mnt_flags;
 
 		if (mnt->mnt.mnt_sb->s_type != sb->s_type)
 			continue;
 
-		/* This mount is not fully visible if it's root directory
-		 * is not the root directory of the filesystem.
-		 */
-		if (mnt->mnt.mnt_root != mnt->mnt.mnt_sb->s_root)
-			continue;
-
 		/* A local view of the mount flags */
 		mnt_flags = mnt->mnt.mnt_flags;
 
-- 
2.54.0

