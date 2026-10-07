Received: from mail-pl1-f173.google.com (mail-pl1-f173.google.com [209.85.214.173])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7E3193CFF49
	for <containers@lists.linux.dev>; Wed,  7 Oct 2026 06:24:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.214.173
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791354254; cv=none; b=AptwvOGaVQWMNKPiTN8HT+OdNPdpIAuVp1sFvREkzyq+zVWAnhMa/s1LucUg/PuLv8F1GJVTev5EzoBAU6ftqC8IB6u8sf/jfL8KEJ28vCckivXRE6S911+N/PJya/kpVcwxLMetqFLSYWGEMw+9qHZ/hbzgbXh+FBUDzmXWNqw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791354254; c=relaxed/simple;
	bh=H5yUNGmr3Aofw0RsQ85oedlEqimTgluIr9D9n1UacwI=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=emZTlFWdu8A+8zN4bi8HYFLto46hBXQnM8rG7vagBwnEouizKCVp73a8CZqZJ5McB0kta8GoIRHgSqMXe2bYGqqQos+M0okNlTCkmvdUjZZ4XAGCN9MmWuHDNHY+Rt/roVBsFY7Stm+Y9Xd/jZvJb64HgC119dmn3kWggQHEQ1U=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=ESmYFefm; arc=none smtp.client-ip=209.85.214.173
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ESmYFefm"
Received: by mail-pl1-f173.google.com with SMTP id d9443c01a7336-2d560775ca2so8463415ad.1
        for <containers@lists.linux.dev>; Tue, 06 Oct 2026 23:24:13 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1791354253; x=1791959053; darn=lists.linux.dev;
        h=cc:to:in-reply-to:references:message-id:content-transfer-encoding
         :content-type:mime-version:subject:date:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=Eldn3SZXEz251aQtu8wp0lwT440swzXtTcbwTv8zgRM=;
        b=ESmYFefmj1QUFWxUBLTa9a8zb1HZ/LMUWNe+gd78SudRttyPlloMV9bCi4A5lmjlzS
         Gx16ztIFXidIlAY3cMxC+bP7egSSGICePmJHlck3AoUvBwozq9QTEJ2+01dgm3m8Ze33
         7eSQmYPI+awEdiGN81tuWcYlzIMXH9MYiWz1rP0lgY7MMmdpd4eXPK0DbRdEPNwsBp2y
         XRLtr0AHTn7wd59W/ugDYBAIcp8zacXXmQL3Mn5zvTsQYvD6MgJ9C5XT4j47QGT2aeas
         DbRTqH0zhL6GU+9ItOCapqVPaK8S31ziEJRldZC+WN5VEgiGGLSIRbDlsjAOAKc+mhCk
         5ajA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791354253; x=1791959053;
        h=cc:to:in-reply-to:references:message-id:content-transfer-encoding
         :content-type:mime-version:subject:date:from:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=Eldn3SZXEz251aQtu8wp0lwT440swzXtTcbwTv8zgRM=;
        b=fbmdu1YYAHto6ovz2V+sd8XbWktvcjhjuPWSSNdxR+c1XZ/663w11rlvrpfNqQg9gj
         IG/WLLfhXtFkEOlXT8T5seSz53q3/tGSWxA8sE7UPgr2JF4nf2Wh3Xwe/ycDvT1z3Ytj
         R4rziIuLPZ4KTTY13x0GuFhHnH1EV2/R8DSgIEF8I0mKsgY8VJgvgmXBeKEsAFa8btUI
         zOIz7oVjtKZuqexNKh/alO5jqibU5cLuYZvzZRoHTvnzpkrZevreebKsO7t+2x8ljqem
         iAkCWWE2W0euAf5S7GNNkVQfNp4FvZFMixVSmHjoJajno03QoJ9zdNYU2qKSj7nU3tQK
         +dWw==
X-Forwarded-Encrypted: i=1; AKwUvByIKtbkCQnpJKlWx2TsYyhRefddfAXiwmwNpvTNJXz5fXI9Fu7+CtNffgY+nFIdr09mQ0He6KaaukGN@lists.linux.dev
X-Gm-Message-State: AFq9FYKzKSsFOVUsWgJeGSzgk9EBuFEUQkdrrg3TZapflM6f0uXciCtl
	/h7PThfF7vtEj00wmVp/BxdsZCRQnEfARjkkNst15/yeb+kCzzIPQwTN
X-Gm-Gg: AYBFou3fBl89rjETuyYGmpzJ4+6+aco41NyVc+sUZ4kM3X+ONqoFVA6oZ0ke/PPUuXa
	wJfA2k2/86woJhsiL25gogSSEV1FiNMxlIUdFbV3c1K3hBMlGiFlag88qHlE4F6PW0uKH5teAaq
	r7GXjHWjQz0yxrpnW1RwcBIfJ7v2Z4EgbP/u5bSNqLH5+53SBp6763NCM1CKElTM8bwV6HLZWTY
	4cIxtftRHkZ+v/5ZyYjljJpz0GgHa0Eaj7wCH1z7xBvvcXE7i1wBB/2RyuqoiGKb90WQfFRgu/S
	JYFWN2aK2peUy1Lwz6v467nSRFvdy371Y4O3IiUaq6st3AxVRJuIH4lXJ/jREioGxcR5Z4PutiE
	qdk80PwFy93AVYRDdNgw2LnQznvU1spMQNYU74VzL/w/rplGPoI+Iw1eJ5OoU9HZTJjaRhXo0xE
	m7FEeaz63iwTIRdjQcHWqaydhaYyGrkuNzJyM4ad0aneVovppSuVfSBFlVVhxTTWFUzDwSTw==
X-Received: by 2002:a17:903:1ae6:b0:2dd:c100:4b87 with SMTP id d9443c01a7336-2e600580aeemr13377715ad.62.1791354252844;
        Tue, 06 Oct 2026 23:24:12 -0700 (PDT)
Received: from [10.1.2.130] ([67.185.120.12])
        by smtp.gmail.com with ESMTPSA id d9443c01a7336-2e60482ccb3sm5303515ad.51.2026.10.06.23.24.11
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 06 Oct 2026 23:24:12 -0700 (PDT)
From: Kir Kolyshkin <kolyshkin@gmail.com>
Date: Tue, 06 Oct 2026 23:23:56 -0700
Subject: [PATCH v3 1/2] mount: add OPEN_TREE_DROP_MNTNS_MOUNTS
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261006-nsfs-prune-rfc-v3-1-adb97ea52868@gmail.com>
References: <20261006-nsfs-prune-rfc-v3-0-adb97ea52868@gmail.com>
In-Reply-To: <20261006-nsfs-prune-rfc-v3-0-adb97ea52868@gmail.com>
To: Christian Brauner <brauner@kernel.org>, 
 Alexander Viro <viro@zeniv.linux.org.uk>, Aleksa Sarai <cyphar@cyphar.com>
Cc: Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@kernel.org>, 
 "Eric W . Biederman" <ebiederm@xmission.com>, 
 David Howells <dhowells@redhat.com>, Amir Goldstein <amir73il@gmail.com>, 
 Andrei Vagin <avagin@google.com>, Shuah Khan <shuah@kernel.org>, 
 Giuseppe Scrivano <giuseppe@scrivano.org>, linux-fsdevel@vger.kernel.org, 
 linux-kernel@vger.kernel.org, linux-kselftest@vger.kernel.org, 
 containers@lists.linux.dev, Kir Kolyshkin <kolyshkin@gmail.com>
X-Mailer: b4 0.14.3

A recursive open_tree(OPEN_TREE_CLONE) copies the nsfs mounts of any
mount namespaces pinned below the source.  When the clone is attached
inside a mount namespace younger than a pinned one, move_mount(2) fails
with ELOOP from check_for_nsfs_mounts(), per the rule from commit
8823c079ba71 ("vfs: Add setns support for the mount namespace") that
prevents mount namespace reference loops.

This breaks container runtimes that use OPEN_TREE_NAMESPACE, such as
crun [1].  The new namespace is younger than everything else, so bind
mounting e.g. the host root fails on any host that pins a mount namespace
(snapd does, under /run/snapd/ns).  By the time it fails, setns() has
already run and userspace cannot recover: the host tree is out of reach,
and the offending mounts cannot be unmounted from the detached copy.

copy_mnt_ns() and create_new_namespace() already leave these mounts
behind; only get_detached_copy() copies them.  Add an open_tree() flag to
drop them from the clone, as suggested by Aleksa [2].  Locked nsfs mounts
are dropped the same way copy_mnt_ns() does it, so nothing new is exposed.

Keep it opt-in: open_tree(OPEN_TREE_CLONE) plus move_mount(2) is how
mount --rbind works through a file descriptor, and in the caller's own
or an older namespace such mounts remain usable.

The flag requires AT_RECURSIVE, since a non-recursive clone has no
submounts to drop, and OPEN_TREE_CLONE or OPEN_TREE_NAMESPACE.  With the
latter it is a no-op, so a runtime can pass it with any recursive
open_tree() call.

Link: https://github.com/containers/crun/issues/2262 [1]
Link: https://lore.kernel.org/all/2026-01-07-oldest-grim-captions-spills-ywC2O3@cyphar.com/ [2]
Assisted-by: Claude:claude-opus-5
Signed-off-by: Kir Kolyshkin <kolyshkin@gmail.com>
---
 fs/namespace.c             | 16 ++++++++++++++--
 include/uapi/linux/mount.h |  1 +
 2 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index ae5dc64f8b45..bb776622a4aa 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -3062,7 +3062,8 @@ static struct mnt_namespace *get_detached_copy(const struct path *path, unsigned
 			ns->seq_origin = src_mnt_ns->ns.ns_id;
 	}
 
-	mnt = __do_loopback(path, (flags & AT_RECURSIVE), CL_COPY_MNT_NS_FILE);
+	mnt = __do_loopback(path, (flags & AT_RECURSIVE),
+			    (flags & OPEN_TREE_DROP_MNTNS_MOUNTS) ? 0 : CL_COPY_MNT_NS_FILE);
 	if (IS_ERR(mnt)) {
 		emptied_ns = ns;
 		return ERR_CAST(mnt);
@@ -3204,7 +3205,18 @@ static struct file *vfs_open_tree(int dfd, const char __user *filename, unsigned
 
 	if (flags & ~(AT_EMPTY_PATH | AT_NO_AUTOMOUNT | AT_RECURSIVE |
 		      AT_SYMLINK_NOFOLLOW | OPEN_TREE_CLONE |
-		      OPEN_TREE_CLOEXEC | OPEN_TREE_NAMESPACE))
+		      OPEN_TREE_CLOEXEC | OPEN_TREE_NAMESPACE |
+		      OPEN_TREE_DROP_MNTNS_MOUNTS))
+		return ERR_PTR(-EINVAL);
+
+	/*
+	 * Only meaningful when a tree is copied recursively: a non-recursive
+	 * clone has no submounts to drop.  OPEN_TREE_NAMESPACE never copies
+	 * pinned mount namespaces, so there the flag is a no-op.
+	 */
+	if ((flags & OPEN_TREE_DROP_MNTNS_MOUNTS) &&
+	    (!(flags & AT_RECURSIVE) ||
+	     !(flags & (OPEN_TREE_CLONE | OPEN_TREE_NAMESPACE))))
 		return ERR_PTR(-EINVAL);
 
 	if ((flags & (AT_RECURSIVE | OPEN_TREE_CLONE | OPEN_TREE_NAMESPACE)) ==
diff --git a/include/uapi/linux/mount.h b/include/uapi/linux/mount.h
index 2204708dbf7a..ac865edac517 100644
--- a/include/uapi/linux/mount.h
+++ b/include/uapi/linux/mount.h
@@ -63,6 +63,7 @@
  */
 #define OPEN_TREE_CLONE		(1 << 0)	/* Clone the target tree and attach the clone */
 #define OPEN_TREE_NAMESPACE	(1 << 1)	/* Clone the target tree into a new mount namespace */
+#define OPEN_TREE_DROP_MNTNS_MOUNTS	(1 << 2)	/* Drop mntns mounts from the clone */
 #define OPEN_TREE_CLOEXEC	O_CLOEXEC	/* Close the file on execve() */
 
 /*

-- 
2.55.0

