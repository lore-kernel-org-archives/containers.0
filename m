Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7AE5239B4AF;
	Mon, 27 Apr 2026 08:27:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777278424; cv=none; b=ExW+Xw91jVVAh4ZG37jQmAXaTeP5IGGemkZLQZJIcGw5IVCJMChSnse1hDKVlYKHHNn/kRffsi/u44N4zhxripxkcK4hJJBgamR3fc7zEeRig6sK25R7B9027WsMRlgi2hvx4aO4ciq+JxCzDQ1gPMHUd3+XvPLuFIUec4j+9zw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777278424; c=relaxed/simple;
	bh=fQ2/ypU05Asy7beJi748/A6lTpXACAw2G+z7PQcm4PE=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=h7kyE8+af03jozcwzIK26LpmmeRXkYb0FojJw4gG5GpGfya/TY1d0NikHLw/tbkaUFe5ZHDVXiDqWrlaZfNF5iyMhtZGBCki1bDi3Cv1q4GVqi214ol2m7mfG7NRLpSP6jx1ppyFBlacwxl6m04KnYqwoU3udmsdciQvTsfOvbI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=pjn55vuN; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="pjn55vuN"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 322F4C2BCB4;
	Mon, 27 Apr 2026 08:27:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1777278422;
	bh=fQ2/ypU05Asy7beJi748/A6lTpXACAw2G+z7PQcm4PE=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=pjn55vuNW5ByS4/bJtr1oB6N2IRJhPjrvtkkfE65foWmEf3p6vbp48zktTu2XfE9r
	 CbtTax0br06ZAE3mipDJYUCxQ5Z/yAnQ5nXYU8rdc0qBiSErpJlS8zmRQxqzYIBDVW
	 8ctk9HweamzdDAdryO4ke/4ZhSZ//9kryV8lTJJGL5I7mbZvmEojyqSo1g/Y0B2AZp
	 rtU1IOfwgXGvsNRpH0rsK7dfXo+odZ3d9asYVnubdIxMiYncU2bRQheMek+lz037j4
	 eiAhuZNcIsFURgN/KeAV4puoepaHtAzMVLmnsEXHpfVx+IvqAKLuRUkU3X/eER85Eu
	 g+zKYjQtgDsQA==
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
Subject: [PATCH v10 3/7] sysfs: remove trivial sysfs_get_tree() wrapper
Date: Mon, 27 Apr 2026 10:26:04 +0200
Message-ID: <e8ac71fc96ad864c8b58fc0a8e5305550c01db25.1777278334.git.legion@kernel.org>
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

Now that FS_USERNS_MOUNT_RESTRICTED is a file_system_type flag,
sysfs_get_tree() is a trivial wrapper around kernfs_get_tree() with no
additional logic. Point sysfs_fs_context_ops.get_tree directly at
kernfs_get_tree() and remove the wrapper.

Signed-off-by: Christian Brauner <brauner@kernel.org>
---
 fs/sysfs/mount.c | 14 +-------------
 1 file changed, 1 insertion(+), 13 deletions(-)

diff --git a/fs/sysfs/mount.c b/fs/sysfs/mount.c
index b45ea5d511e7..88c10823fcaf 100644
--- a/fs/sysfs/mount.c
+++ b/fs/sysfs/mount.c
@@ -23,18 +23,6 @@
 static struct kernfs_root *sysfs_root;
 struct kernfs_node *sysfs_root_kn;
 
-static int sysfs_get_tree(struct fs_context *fc)
-{
-	struct kernfs_fs_context *kfc = fc->fs_private;
-	int ret;
-
-	ret = kernfs_get_tree(fc);
-	if (ret)
-		return ret;
-
-	return 0;
-}
-
 static void sysfs_fs_context_free(struct fs_context *fc)
 {
 	struct kernfs_fs_context *kfc = fc->fs_private;
@@ -47,7 +35,7 @@ static void sysfs_fs_context_free(struct fs_context *fc)
 
 static const struct fs_context_operations sysfs_fs_context_ops = {
 	.free		= sysfs_fs_context_free,
-	.get_tree	= sysfs_get_tree,
+	.get_tree	= kernfs_get_tree,
 };
 
 static int sysfs_init_fs_context(struct fs_context *fc)
-- 
2.54.0

