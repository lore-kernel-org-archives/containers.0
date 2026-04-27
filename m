Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3116F39B489;
	Mon, 27 Apr 2026 08:26:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777278415; cv=none; b=tbphbjbfJ1CSmYwXZfjBmSnba1TYGpwGPJqnFaOeJ+UBkAw2rdoFaarkOW6Mt9+K7WbuN28B+AO13KzC1XZzt2DxdMBVfPdSKEFhNewNyl9fDqZVn2h8asHbrZeADTyl4Z0hwnYztQhUoWinwbKz+cUqwjISt0qn+usW86KD2BY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777278415; c=relaxed/simple;
	bh=ZWn/ShM3BXcEtqdiFwW7oAGH8mFbQfpVdxR/3bvVIB8=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=t9TYOSiInsDxrHyekeCSSCcXg2zedx2NaoQy3DXQFPgSaxmRcApBOzQnrAXxig7KDhwFZS1pSqNU5q38Tz6IpAqWcWcr8CNGOwqwPTltUv7LKUCeFcEa8jCS0HUTH5HOc//+iQaqz6jx4mwTXs9O35ZhYzrzZWfstU0Pz8/tCsY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=TZhINGuH; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="TZhINGuH"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D1B2CC19425;
	Mon, 27 Apr 2026 08:26:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1777278414;
	bh=ZWn/ShM3BXcEtqdiFwW7oAGH8mFbQfpVdxR/3bvVIB8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=TZhINGuHBGaYhar+mN2juzz40HfsR5iMPg25STsZ1KWMTBKreXaboyyZt+npGpmhB
	 e/lkDwfz7nRQVmy/HW5NMNjc0TCsv69cbt6RatDND+kNEzZvSTH+QnwODQIPX0N9Gt
	 kHYh8lstkYvuv9eYbqdraHfeZDsmEt4Kn6UetqsA+P4gRWt7TxDLMmU0SS08nDYMAQ
	 mkzbag6kxJ/Xx5F2OuBoZFsIFNszOyVypCDMG62rhCeHR3x52X2FUwUJALw2MBaYiR
	 Jk4T9c9g7l5RfjYiw3ogbGwGgpoVvGeGlZCUfG/bVXlCSK8HpF6O5q86ulrbVdZsBh
	 7Qvdbebqhfjng==
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
Subject: [PATCH v10 0/7] proc: subset=pid: Relax check of mount visibility
Date: Mon, 27 Apr 2026 10:26:01 +0200
Message-ID: <cover.1777278334.git.legion@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <cover.1776079055.git.legion@kernel.org>
References: <cover.1776079055.git.legion@kernel.org>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

When mounting procfs with the subset=pids option, all static files become
unavailable and only the dynamic part with information about pids is accessible.

In this case, there is no point in imposing additional restrictions on the
visibility of the entire filesystem for the mounter. Everything that can be
hidden in procfs is already inaccessible.

Currently, these restrictions prevent pidfs from being mounted inside rootless
containers, as almost all container implementations override part of procfs to
hide certain directories. Relaxing these restrictions will allow pidfs to be
used in nested containerization.

---
Changelog
---------
v10:
* Rework visibility checks around Christian's FS_USERNS_MOUNT_RESTRICTED
  and SB_I_RESTRICTED_VARIANT approach instead of fs_context skip_visibility.
* Add Christian's sysfs_get_tree() cleanup.
* Treat subset=pid procfs as a restricted variant that is allowed without
  mnt_already_visible(), but cannot be used as visibility evidence for later
  mounts.
* Forbid changing subset=pid on procfs reconfigure in either direction to
  avoid exposing pre-existing overmounts after switching to subset=pid.
* Make failed subset=pid reconfigure leave other procfs options unchanged.
* Update procfs documentation accordingly.

v9:
* Rework the patch based on the one proposed by Christian Brauner.

v8:
* Remove mounter credential change on remount as suggested by Christian Brauner.

v7:
* Rebase on v6.19-rc5.
* Rename SB_I_DYNAMIC to SB_I_USERNS_ALLOW_REVEALING.

v6:
* Add documentation about procfs mount restrictions.
* Reorder commits for better review.

v4:
* Set SB_I_DYNAMIC only if pidonly is set.
* Add an error message if subset=pid is canceled during remount.

v3:
* Add 'const' to struct cred *mounter_cred (fix kernel test robot warning).

v2:
* cache the mounters credentials and make access to the net directories
  contingent of the permissions of the mounter of procfs.

Alexey Gladkov (4):
  proc: subset=pid: Show /proc/self/net only for CAP_NET_ADMIN
  proc: prevent reconfiguring subset=pid
  proc: handle subset=pid separately in userns visibility checks
  docs: proc: add documentation about mount restrictions

Christian Brauner (3):
  namespace: record fully visible mounts in list
  fs: move SB_I_USERNS_VISIBLE to FS_USERNS_MOUNT_RESTRICTED
  sysfs: remove trivial sysfs_get_tree() wrapper

 Documentation/filesystems/proc.rst | 19 ++++++++++++++++-
 fs/mount.h                         |  4 ++++
 fs/namespace.c                     | 34 +++++++++++++++++++++++-------
 fs/proc/proc_net.c                 |  8 +++++++
 fs/proc/root.c                     | 24 +++++++++++++++------
 fs/sysfs/mount.c                   | 18 ++--------------
 include/linux/fs.h                 |  1 +
 include/linux/fs/super_types.h     |  2 +-
 include/linux/proc_fs.h            |  1 +
 kernel/acct.c                      |  2 +-
 10 files changed, 80 insertions(+), 33 deletions(-)

-- 
2.54.0

