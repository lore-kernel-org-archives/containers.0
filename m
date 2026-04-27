Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6250439B4AE;
	Mon, 27 Apr 2026 08:27:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777278432; cv=none; b=mBVJXc4raQ7kk36xX0XU1Z3CvJSxjW0A9inl4M3IbyaFiq5PeXn4CyGlSg+5WoBPGJHSIj1KRbg7yWEqUB5FKtnzeQwnugOSKgegWF5Hg6rxOBId4obymoUXa5xDOwP74LGxDauF5Bq6NzS9MHUAaEtp/sjqz1iNSZRyGQMrtrA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777278432; c=relaxed/simple;
	bh=4CFdS8ty6FAiD669kpwSBvY0yy0/IHHFrNW6KvtXaZk=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=bzPaEikJFxnrFycpre+rfJxdRyiH0Jw/KfgRdzRfmuyWF1rPzO9zm36zLgSif9eIfZAES6ohCAxZ1ACc2PgVq1d+YNoR6KJOBCq1SnsNpmAxyqZ9RDrRr6oheoH4XngfcNg2FM78fQ9NMfMjbxurADwdXELzYi0/ZphrbWIucQU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=RLA16NtG; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="RLA16NtG"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id F1E2FC2BCB4;
	Mon, 27 Apr 2026 08:27:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1777278432;
	bh=4CFdS8ty6FAiD669kpwSBvY0yy0/IHHFrNW6KvtXaZk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=RLA16NtGuLm1ltlMga1iRjoha4q5BNJfIaWMJwP8AOMKp34YDBnQ6BQOqtLCcArA/
	 1/GU3l3std6L6yDfzljxh99B0KXLMimH6YarSxU7zRJ5YsWv5ZCm/boz8OddSTQdi6
	 oDPdbW6y5gjArpEBY/WusGrV8XS1F7CLRi7r/PF8BvxA8eMfyJRNenQMhLYGc36YVz
	 W6yGZsxNpgPJpcA+DVx3uueXf9aylOK55oMjun3swDkjO2QJymYF/x/C7OXGgOlL4F
	 /Gq+NzLi+6I/Xmjo6AdgS+TYNZYRjJYy5FG2T6lq6S85Pw0NIPyRKFFLxSw5P8QdRn
	 /7F6OAAdhgXLg==
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
Subject: [PATCH v10 7/7] docs: proc: add documentation about mount restrictions
Date: Mon, 27 Apr 2026 10:26:08 +0200
Message-ID: <e7cb804df3c1759ee17cf9df1dc4c211d63d7a5f.1777278334.git.legion@kernel.org>
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

procfs has a number of mounting restrictions that are not documented
anywhere.

Signed-off-by: Alexey Gladkov <legion@kernel.org>
---
 Documentation/filesystems/proc.rst | 19 ++++++++++++++++++-
 1 file changed, 18 insertions(+), 1 deletion(-)

diff --git a/Documentation/filesystems/proc.rst b/Documentation/filesystems/proc.rst
index b0c0d1b45b99..b836b725b35d 100644
--- a/Documentation/filesystems/proc.rst
+++ b/Documentation/filesystems/proc.rst
@@ -52,6 +52,7 @@ fixes/update part 1.1  Stefani Seibold <stefani@seibold.net>    June 9 2009
 
   4	Configuring procfs
   4.1	Mount options
+  4.2	Mount restrictions
 
   5	Filesystem behavior
 
@@ -2401,7 +2402,9 @@ prohibited by hidepid=.  If you use some daemon like identd which needs to learn
 information about processes information, just add identd to this group.
 
 subset=pid hides all top level files and directories in the procfs that
-are not related to tasks.
+are not related to tasks. This option cannot be changed on an existing
+procfs instance because overmounts that existed before the change could
+otherwise remain reachable after the top level procfs entries are hidden.
 
 pidns= specifies a pid namespace (either as a string path to something like
 `/proc/$pid/ns/pid`, or a file descriptor when using `FSCONFIG_SET_FD`) that
@@ -2410,6 +2413,20 @@ will use the calling process's active pid namespace. Note that the pid
 namespace of an existing procfs instance cannot be modified (attempting to do
 so will give an `-EBUSY` error).
 
+4.2	Mount restrictions
+--------------------------
+
+If user namespaces are in use, the kernel additionally checks the instances of
+procfs available to the mounter and will not allow procfs to be mounted if:
+
+  1. This mount is not fully visible unless the new procfs is going to be
+     mounted with subset=pid option.
+
+     a. Its root directory is not the root directory of the filesystem.
+     b. If any file or non-empty procfs directory is hidden by another mount.
+
+  2. A new mount overrides the readonly option or any option from atime family.
+
 Chapter 5: Filesystem behavior
 ==============================
 
-- 
2.54.0

