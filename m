Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 938B33AC0CD;
	Mon, 13 Apr 2026 11:22:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776079348; cv=none; b=IaOazMy/3jHioLfmFUFzYWmK7irL2esJAgnFMkvbOH0dVAlcaGLbyeg//vXfh8NjH469KzrOB+pgGpLVkW4trRhRrHUT4dkkvw6kdySDO/SMKuoVfi7DWOmWA51knKNb9oyIhhyT6dpHZH6hi0cZ051PFuk4u8dq4XOlxwxas8g=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776079348; c=relaxed/simple;
	bh=EMnwuptcw9yOjXHvdUwFabzvsTgmsyaU9XU+ZZ4aEd8=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=X0xGIfEwTSQOWss7357asuZqgoTFrAMlzlGy9bVE6/QlMRNFjQ9VCT2zkp01rDjIutnqBQIH09nMoSLHYvbn1T8TnKmnmG3zhug/PtQ+R2+87RaXOzTZPYex/O35PIfiTDzC7y3lEGLJQ6diLXDJxAOlLs5Ci/HlwU0VxaTU4lQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=RZN42p3e; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="RZN42p3e"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 62923C116C6;
	Mon, 13 Apr 2026 11:22:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1776079348;
	bh=EMnwuptcw9yOjXHvdUwFabzvsTgmsyaU9XU+ZZ4aEd8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=RZN42p3e8fUjFkUuHFJM4ilJ6IRtRQMryHHzvLrdGqIx3+ob3fzXS/qAFKZSBy3Xm
	 DbI5bSWwz1h/8CYSLpJsfOxP1p5krYIba4o0+4D2waQDlw7s7zTuOCQzgK1mtqv9V/
	 VNG33PcNd94My1Xful+6qVuhqDm6f52Q8g+vnmsnbthmzLlW9MPh+363UkeZiAC8wH
	 OErwcZON/JeUlYeo6nasucoeVQpZupGidngAduojhNaJU5JnbOCZfElmwVpC+9fnEd
	 juNikuqn/5k/AgvCjuyd/vNFtoTr0Cj8oU3ybNHbTSGxzkxccAL2aKvvZ7FbM+JLlj
	 pzBf/9/eowqnQ==
From: Alexey Gladkov <legion@kernel.org>
To: Christian Brauner <brauner@kernel.org>,
	Dan Klishch <danilklishch@gmail.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	Kees Cook <keescook@chromium.org>,
	containers@lists.linux.dev,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v9 0/5] proc: subset=pid: Relax check of mount visibility
Date: Mon, 13 Apr 2026 13:19:39 +0200
Message-ID: <cover.1776079055.git.legion@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1770979341.git.legion@kernel.org>
References: <cover.1770979341.git.legion@kernel.org>
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
  proc: Disable cancellation of subset=pid option
  proc: Skip the visibility check if subset=pid is used
  docs: proc: add documentation about mount restrictions

Christian Brauner (1):
  namespace: record fully visible mounts in list

 Documentation/filesystems/proc.rst | 15 +++++++++++++
 fs/fs_context.c                    |  1 +
 fs/mount.h                         |  4 ++++
 fs/namespace.c                     | 34 ++++++++++++++++--------------
 fs/proc/proc_net.c                 |  8 +++++++
 fs/proc/root.c                     | 24 ++++++++++++++++-----
 include/linux/fs_context.h         |  1 +
 include/linux/proc_fs.h            |  1 +
 8 files changed, 67 insertions(+), 21 deletions(-)


base-commit: 028ef9c96e96197026887c0f092424679298aae8
-- 
2.53.0

