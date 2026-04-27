Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8B49034F25C;
	Mon, 27 Apr 2026 15:54:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777305288; cv=none; b=IjJORTjNnzTOm2Um/BbZtYZC5ueHmyrPcGgb2dQgnMer469jAGbGPoxM4fzR0Xnrbr9TsiGqeu5kfO4SYgxFrvdURV1Df6vSyo5qzcxypYZPE6QEOx/kRcm9havoh7BGu5tmYjB2lNiB/ng9TlO3QSKMfq76iByK5VMv6AAT6tM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777305288; c=relaxed/simple;
	bh=WqCJFZuy4AXneswmV0Hbd45GezhxOXNMFqcmZpKNlww=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=dGRv4okzf9zIU2D7ntyvwxI8gpPzslxjFXE5IlhbWf10zVex6eegdsxNh187H363dE1ndJH1SHFvFy7M9wAYCwP8mzjrkeRTwA2XhZFAlYVsRNiyuhT2UY5jwSnxqeqxOB/gnpb0pea1QNedMAIU3mEu3tG/0k+iupBfkuzeu9Q=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=XAMSLSEd; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="XAMSLSEd"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C9670C2BCB7;
	Mon, 27 Apr 2026 15:54:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1777305288;
	bh=WqCJFZuy4AXneswmV0Hbd45GezhxOXNMFqcmZpKNlww=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=XAMSLSEdSv2B5svUDBpRxn94s2NzaTYCN8/QGTADhjrqu6cnG6hmOXhdCdgCFiLSK
	 lFbjeGbMYnhZOdEyTLFvid+IWa2KAVwY1q9GaBfI130ZRD4fbMEhnIU9hUcxW1n7yr
	 AycF/mKFaQ/PkG+ROb0dMwD+e8egFyZdSbusMEDPjfiTqpw9qhqslZ1EI3nEQiPrOK
	 blSYFqaklR1mWjSR101RQO5JXJkr38GyyBt9ij+qwPyWe2uiWat00Q2Xf3lNy6JiTc
	 zlY43KtMxb5gxEhh29JLq6YL+pwakXstoP0Q297wwh9PVDF1aqH6rP4Dk6Cv07b+Kc
	 GEHiK4Tfp0jOA==
From: Christian Brauner <brauner@kernel.org>
To: Dan Klishch <danilklishch@gmail.com>,
	Alexey Gladkov <legion@kernel.org>,
	Aleksa Sarai <cyphar@cyphar.com>
Cc: Christian Brauner <brauner@kernel.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	containers@lists.linux.dev,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Kees Cook <kees@kernel.org>
Subject: Re: [PATCH v10 0/7] proc: subset=pid: Relax check of mount visibility
Date: Mon, 27 Apr 2026 17:54:15 +0200
Message-ID: <20260427-kentern-miserabel-289e2376f3f3@brauner>
X-Mailer: git-send-email 2.47.3
In-Reply-To: <cover.1777278334.git.legion@kernel.org>
References: <cover.1777278334.git.legion@kernel.org>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
X-Developer-Signature: v=1; a=openpgp-sha256; l=1978; i=brauner@kernel.org; h=from:subject:message-id; bh=WqCJFZuy4AXneswmV0Hbd45GezhxOXNMFqcmZpKNlww=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS+bzt0Pab4StHBsB19/hm/ak6Xulre9c6e+a1CWbtsp 9A+74eXO0pZGMS4GGTFFFkc2k3C5ZbzVGw2ytSAmcPKBDKEgYtTACai9ICRYVFPfnjGjdCH35fd 4tabNqtH5nr+l2MuUUGLpn8NdjPZJMzwP1honvQMzQoB8XvmZ67G59hu6+eQUV88o8GrUf534nF vTgA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

On Mon, 27 Apr 2026 10:26:01 +0200, Alexey Gladkov wrote:
> When mounting procfs with the subset=pids option, all static files become
> unavailable and only the dynamic part with information about pids is accessible.
> 
> In this case, there is no point in imposing additional restrictions on the
> visibility of the entire filesystem for the mounter. Everything that can be
> hidden in procfs is already inaccessible.
> 
> [...]

Thanks, I think we ended with something that looks quite decent now.

---

Applied to the vfs-7.2.procfs branch of the vfs/vfs.git tree.
Patches in the vfs-7.2.procfs branch should appear in linux-next soon.

Please report any outstanding bugs that were missed during review in a
new review to the original patch series allowing us to drop it.

It's encouraged to provide Acked-bys and Reviewed-bys even though the
patch has now been applied. If possible patch trailers will be updated.

Note that commit hashes shown below are subject to change due to rebase,
trailer updates or similar. If in doubt, please check the listed branch.

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/vfs/vfs.git
branch: vfs-7.2.procfs

[1/7] namespace: record fully visible mounts in list
      https://git.kernel.org/vfs/vfs/c/18920cc2ade4
[2/7] fs: move SB_I_USERNS_VISIBLE to FS_USERNS_MOUNT_RESTRICTED
      https://git.kernel.org/vfs/vfs/c/a09358516cf2
[3/7] sysfs: remove trivial sysfs_get_tree() wrapper
      https://git.kernel.org/vfs/vfs/c/630dc69a9f7d
[4/7] proc: subset=pid: Show /proc/self/net only for CAP_NET_ADMIN
      https://git.kernel.org/vfs/vfs/c/0ff06ac76088
[5/7] proc: prevent reconfiguring subset=pid
      https://git.kernel.org/vfs/vfs/c/87341f4e3436
[6/7] proc: handle subset=pid separately in userns visibility checks
      https://git.kernel.org/vfs/vfs/c/6691ea02bddb
[7/7] docs: proc: add documentation about mount restrictions
      https://git.kernel.org/vfs/vfs/c/65cb11ddcfcd
