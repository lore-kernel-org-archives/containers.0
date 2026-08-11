Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B9DF5426D2B;
	Tue, 11 Aug 2026 09:19:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786439993; cv=none; b=KtoTvKlxv3I41FbFfFw3nyU4tuKvpNwQZlJi95wi/hLctuqN2zKain4+ccppfPnTp5OIS6ykDFk3HK+buSSkbK/fdDoqsAecBrve0fd7v8A/G6HhhHDzXA+dFgmLz3G83xkPZij9Dfen+3/caV6aNMbQ+YBwk5B6jWl8fQI/ifA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786439993; c=relaxed/simple;
	bh=hsE4PBe2hb6q0V2ZlmSaMJT2Rik1ktH6/52G+3ykBeE=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=GNW1yYEA3Q5h3RpNDCdqZhrHiIrRMTFNF5+94suqsJ+vNrWBLNaRbEACBwryLsoL8Vncm2dHfDVQqot7hVQfEXSW3ZFVYyxvureGZRdJEBAnxrPKhxR4fA5DsrgcFXN1o9Kj6EZQBcHSjNwZh3ltgUHkePwvF2IKBNtZ+JSGYL4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=n4ol3hkh; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="n4ol3hkh"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3ADB01F000E9;
	Tue, 11 Aug 2026 09:19:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786439992;
	bh=laT/P8hOM5nGLJJKFHrRuF1eD0Z9W43CTTyAgJiUwNk=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=n4ol3hkhHgq4N6abV2ZP6r9R12Hz5wIFk+YGgtEWtKcjXjsLQYUkH6zPjt6V0iDBg
	 OBIVUXXCPIX0lhqWZFJasMAkSicDsIcp5Cmvto9pFbUAvc/h4/kKB5red6uoUoq86f
	 jpukGLs6F4oybbtlGwMgw+/2SCofIWK0sjgY3brv2nPskcjP9MXh2I1zl6avi6y7Lh
	 lATi+8pQlRr4OjM0uTrCKUKuY6ufonUCaEdhO1VTXJM5ksAAbIJqc1rQqT34CcPHoa
	 7h1ko+RdGWQLhH6lNkQZSp3A10ceBQozA9SZRkaFN6E+Te8GzLMqaSnODVTkd3jMar
	 5ajTmuRS6HUCw==
Date: Tue, 11 Aug 2026 11:19:48 +0200
From: Christian Brauner <brauner@kernel.org>
To: GuLingguang <liu83783@gmail.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, 
	containers@lists.linux.dev, Alexander Viro <viro@zeniv.linux.org.uk>, 
	"Eric W . Biederman" <ebiederm@xmission.com>, Aleksa Sarai <cyphar@cyphar.com>, 
	Alexey Gladkov <legion@kernel.org>, "Serge E . Hallyn" <serge@hallyn.com>
Subject: Re: [RFC] mnt_already_visible(): should regular-file mountpoints
 participate in the visibility check?
Message-ID: <20260811-obsession-propeller-eiskalt-a2ca8b0a1017@brauner>
References: <20260808132309.35924-1-liu83783@gmail.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20260808132309.35924-1-liu83783@gmail.com>

On Sat, Aug 08, 2026 at 09:23:09PM +0800, GuLingguang wrote:
> Hi all,
> 
> I have a question about the child-mount check in mnt_already_visible()
> in fs/namespace.c, and I would like to understand the intended
> invariant before proposing anything.
> 
> Background
> 
> The check considers an existing proc mount "not fully visible" when
> it has a locked child mount whose mountpoint is not a permanently
> empty directory:
> 
>         list_for_each_entry(child, &mnt->mnt_mounts, mnt_child) {
>                 struct inode *inode = child->mnt_mountpoint->d_inode;
>                 /* Only worry about locked mounts */
>                 if (!(child->mnt.mnt_flags & MNT_LOCKED))
>                         continue;
>                 /* Is the directory permanently empty? */
>                 if (!is_empty_dir_inode(inode))
>                         goto next;
>         }
> 
> is_empty_dir_inode() returns false for regular files, so a locked
> file mount under /proc (e.g. /proc/uptime) makes the whole proc mount
> "not fully visible", and mounting a fresh proc instance inside a user
> namespace is rejected with EPERM:
> 
>         bwrap: Can't mount proc on /newroot/proc: Operation not permitted
> 
> Real-world impact
> 
> This affects established workloads:
> 
>  * lxcfs (since 2014) overmounts /proc/meminfo and /proc/uptime with
>    FUSE files; lxc reported in March 2016 that this blocked running
>    an unprivileged container inside a privileged one
>    (LKML: "user namespace and fully visible proc and sys mounts").
>  * systemd-nspawn can mask paths under /proc (via --inaccessible=,
>    overmounting them with inaccessible placeholder nodes);
>    flatpak/bwrap inside the container then fails with the EPERM
>    above (systemd issue #34226, still open).
>  * droidspaces virtualizes /proc/uptime and /proc/loadavg the same
>    way today.
>  * Kubernetes works around mount_too_revealing() by mounting proc
>    from an empty pid namespace (noted in the 2025 procfs pidns API
>    series, merge 46582a15c174).
> 
> The invariant
> 
> The check's stated purpose, in Eric Biederman's own words
> (commit 7236c85e1be5), is that fresh mounts of proc and sysfs must
> give the mounter:
> 
>         "no more access to proc and sysfs than if they could have
>          by creating a bind mount"
> 
> The original commit (e51db73532955) phrased it as verifying that
> "the mounted filesystem is not covered in any significant way".
> 
> For a regular-file mountpoint, does a fresh proc mount violate this
> invariant?  It seems not, on three counts:
> 
>  1. Content.  The only thing a fresh mount reveals beyond the covered
>     file is the kernel-generated value of that file, which is already
>     reachable through other means -- e.g. the real uptime is available
>     from /proc/stat's btime and from the uptime(2) syscall, which are
>     not affected by the overmount.  No new information becomes
>     accessible.

It's an information leak. Please trim LLM generated questions to the
bare minimum. We don't have time to read essays the whole day...
