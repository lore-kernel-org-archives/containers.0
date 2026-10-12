Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EA00D41A50B;
	Mon, 12 Oct 2026 10:25:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791800757; cv=none; b=eCLMK81FxYj3vQVmLAzAp4ajCseplIUWOhBKKypaaU8xbB/bhOIsAs88P1XtuMY3lW+tOTKNH+/ony/4in5SKqLpDgiSlaa0AU5OQXo9enm0H92SnGdmQXRQDyPQqmeCguuD9paa+nf2Zbw4hhOc99iL/z0rCIh6VBd8ehUYaBU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791800757; c=relaxed/simple;
	bh=mzrYFH3CpfUkd38PYRJaOW6C62pyLbdeCdal8MeLj8k=;
	h=From:To:Cc:In-Reply-To:References:Subject:Message-Id:Date:
	 MIME-Version:Content-Type; b=PrZuNPfHk8hDEUYWBrMpd5VQCfvp8hoaCAKK+YK4Cppv0NT8cARh0YSGE8aSnakknZuhSmFmvtnE+TFr03WVNMKpTCT6SEiFeupUOI4+7L0dp46eJc1AuiKwZVT5oO89jJh7tBa6qYubysXZHorOLLzgqnIV2Xklv45+Fe+6EP4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=EQy4hJlN; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="EQy4hJlN"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1F21E1F0089C;
	Mon, 12 Oct 2026 10:25:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791800746;
	bh=jvkm/WTwdOssOISWC9CLiLOFK4k8ZC+6Oi2fNMGz2fE=;
	h=From:To:Cc:In-Reply-To:References:Subject:Date;
	b=EQy4hJlNc/cKXyiXkkMmd+jFWDnN8Msgu6RqEPD2WCSL4sT3MjaFNeUMwsqBL7X9s
	 h00RZIfThNv+FHIDFCINf4L10brPG3zmbWcihqzp+EVIKIyhnJmAC5VSYOszL6U89K
	 w5rWoO74c8id87ezjyNbEu9iotLad71ZyvuzWashnsBHYX3jLlAN9tS0UJtfZhQosq
	 87KqYyScxj2flaCCs54Y0pUqjfgf5ECZDfkcoMuJQvMqevDUCPZgej7qj46llRp5FP
	 oHFYD7EhsqaIiCDvFJV7eOQ9zfErqaq3sLbUB6a0h9k9ZV46uojLr/aRfPm4CsR+z3
	 0ieZAboFIawaQ==
From: Christian Brauner <brauner@kernel.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, 
 Aleksa Sarai <cyphar@cyphar.com>, Kir Kolyshkin <kolyshkin@gmail.com>
Cc: Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@kernel.org>, 
 "Eric W . Biederman" <ebiederm@xmission.com>, 
 David Howells <dhowells@redhat.com>, Amir Goldstein <amir73il@gmail.com>, 
 Andrei Vagin <avagin@google.com>, Shuah Khan <shuah@kernel.org>, 
 Giuseppe Scrivano <giuseppe@scrivano.org>, linux-fsdevel@vger.kernel.org, 
 linux-kernel@vger.kernel.org, linux-kselftest@vger.kernel.org, 
 containers@lists.linux.dev
In-Reply-To: <20261006-nsfs-prune-rfc-v3-0-adb97ea52868@gmail.com>
References: <20261006-nsfs-prune-rfc-v3-0-adb97ea52868@gmail.com>
Subject: Re: [PATCH v3 0/2] mount: add OPEN_TREE_DROP_MNTNS_MOUNTS
Message-Id: <20261012-einnimmt-sukzessiv-mildern-32236d226f83@brauner>
Date: Mon, 12 Oct 2026 12:25:41 +0200
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Mailer: b4 0.17-dev-3d1b8

On Tue, 06 Oct 2026 23:23:55 -0700, Kir Kolyshkin wrote:
> crun, a container runtime, recently started using OPEN_TREE_NAMESPACE to
> set up the container's mount namespace, and open_tree(OPEN_TREE_CLONE)
> for the sources of its bind mounts.  This turns out not to work on hosts
> that have a mount namespace pinned anywhere below such a source: the
> recursive clone picks the pinned namespace up, and move_mount(2) then
> refuses to attach the tree with ELOOP from check_for_nsfs_mounts().
> 
> [...]

Applied to the vfs-7.4.mount branch of the vfs/vfs.git tree.
Patches in the vfs-7.4.mount branch should appear in linux-next soon.

Please report any outstanding bugs that were missed during review in a
new review to the original patch series allowing us to drop it.

It's encouraged to provide Acked-bys and Reviewed-bys even though the
patch has now been applied. If possible patch trailers will be updated.

Note that commit hashes shown below are subject to change due to rebase,
trailer updates or similar. If in doubt, please check the listed branch.

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/vfs/vfs.git
branch: vfs-7.4.mount

[1/2] mount: add OPEN_TREE_DROP_MNTNS_MOUNTS
      https://git.kernel.org/vfs/vfs/c/73b40395c71c
[2/2] selftests/filesystems: test OPEN_TREE_DROP_MNTNS_MOUNTS
      https://git.kernel.org/vfs/vfs/c/e6e54e7117f6

