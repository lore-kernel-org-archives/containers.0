Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 01E6C3C5555;
	Mon, 13 Apr 2026 11:22:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776079360; cv=none; b=KhTGN7hNVsu+QCRTkmboxaXR0D35BJhzlXtvdufWO5gyy+seZ2uHUjXJG4P8/Rh69T8CrcmzTIe9gNmpYNSGkuw1LFdOsaM3e1eLA7toUyOHuqHHKvpylWyzWcfqwXKp5cF/sursiJzZ6zr5aVxZqM+hu/M8oMxs8xiWNLWl/Zw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776079360; c=relaxed/simple;
	bh=ih3F+e99A+RK4mWpStCjQYOR4dtgli7oebDrxx5J74Y=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Qqv0q6wySzO7qZStLWLq7SxKH71SOPYi1oFmhZ5JWPxvKsA9df3KvjeY8y77VPW7HH1DqwvViO6fYxnxfis+m3zqqPF8MiL30TXTLaFGZe6Z6il3OeWteziJo6qU/b0kLvHt8BWkeJy7DsnJ8rrB+YwnWbIG1TN3c/yq0frl2GQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Gm/5jPJP; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Gm/5jPJP"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BC8A1C2BCAF;
	Mon, 13 Apr 2026 11:22:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1776079359;
	bh=ih3F+e99A+RK4mWpStCjQYOR4dtgli7oebDrxx5J74Y=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=Gm/5jPJPJZs969fJ+wwOAZySR8Nohs2SH72Wf4o1B2Vlbh1JAiUCe9U3Q4QGjE4k/
	 zHfw/VkPRDkCaSxtPmGrK5KIZi1RplKgewkK6Az5+Ly72VwlDORXXm998LgJUoM3H+
	 I7pmwVVhgxWw2exdijaThEPHU3sSXRew6DDz2x4v3pEUB3hayIjDS+gqpSJ1uUBy3j
	 vdH0R9FGfSg9DBTFBHM837l0hhPxL8xVZKOv5Q/WWFJ2sCPbzmrPiB60y0RVPNsLU9
	 6r1OT2owizJjV0SEtmxtFXASAdDfUGTQmoLZN+UgQbX1zJYrT0JxaIEZUilwnCRoeY
	 6PzMISg6Y0Qhg==
From: Alexey Gladkov <legion@kernel.org>
To: Christian Brauner <brauner@kernel.org>,
	Dan Klishch <danilklishch@gmail.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	Kees Cook <keescook@chromium.org>,
	containers@lists.linux.dev,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v9 5/5] docs: proc: add documentation about mount restrictions
Date: Mon, 13 Apr 2026 13:19:44 +0200
Message-ID: <8d9734a83d9b85130485d76c3562064f836b7361.1776079055.git.legion@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1776079055.git.legion@kernel.org>
References: <cover.1770979341.git.legion@kernel.org> <cover.1776079055.git.legion@kernel.org>
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
 Documentation/filesystems/proc.rst | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/Documentation/filesystems/proc.rst b/Documentation/filesystems/proc.rst
index b0c0d1b45b99..699cc372e6c8 100644
--- a/Documentation/filesystems/proc.rst
+++ b/Documentation/filesystems/proc.rst
@@ -52,6 +52,7 @@ fixes/update part 1.1  Stefani Seibold <stefani@seibold.net>    June 9 2009
 
   4	Configuring procfs
   4.1	Mount options
+  4.2	Mount restrictions
 
   5	Filesystem behavior
 
@@ -2410,6 +2411,20 @@ will use the calling process's active pid namespace. Note that the pid
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
+     a. It's root directory is not the root directory of the filesystem.
+     b. If any file or non-empty procfs directory is hidden by another mount.
+
+  2. A new mount overrides the readonly option or any option from atime familty.
+
 Chapter 5: Filesystem behavior
 ==============================
 
-- 
2.53.0

