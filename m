Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 41757426EB6;
	Tue, 11 Aug 2026 09:17:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786439826; cv=none; b=CmrU8TMpiJfnKd3JmQTP0TlnGWNa0M1c1WmJdkNKPHvunKDEuc9dCfuUeoXhZQPlRWeufS6R+wJsipHaI3GNmgq3Yup9uHm2Z6ULBEjWMSO2qdLAhBTZYpgCqfHA009RhFcj8OzhWBp+CeescDFDOwJlcLcNFNkpFLKRxrvWaXo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786439826; c=relaxed/simple;
	bh=q+2kDqyqlGUxRfpPMHuHdhGL+eSfCCVENPXHKU9qZfE=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=sBgEtfcND2lreYPWGZsRhMxxguZFFVsjPF/Na0XjY9c6ZjKhQ2OLuDvGy7ltQePupUvWnyaxDj7yYihXGWe3RpRzqg2At0r9J1q9mcQED8PAAVUCNk29PNrPjgXctzg41Q3EbnQ6itpMqTlHlFyRCc/8VWvTaEer+RmAAsaBNwo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=NArFqj7b; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="NArFqj7b"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C6EA11F000E9;
	Tue, 11 Aug 2026 09:17:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786439824;
	bh=nSRwv3mhpZ4CnCiTzYpHnXxv6ua9WpBy3lSUyjOwMRA=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=NArFqj7b02quSyB+YxLhxgkkkdJIr2BQvaxV7vklqstqwlGdjjw/ALySwNK4W88Pu
	 TcFQer1V8pryzHxpfOgkBlz3yPPpr/4SItF+1tD7GsvXA7D8gD5xnGYaQVSkG70nfv
	 yyRATkb9Gdr3wsm9dTrP0yHJyJKpLtOorONu0nEPagtiqrjJvTU26tqevJdUVdFKWV
	 UaFZBtDfXGTUepmyPYMBABDLg8A1tcQPOqweIusXU+3VD8a/jG2m+mClNZCaYlVcqg
	 gEe14IH7/rOgJugMj7/MjQ+p9WpTeeUsntNtHu7qy061b7qWubDlA3YZFVKCKDbSZy
	 OdH+CPm51fNQA==
Date: Tue, 11 Aug 2026 11:16:58 +0200
From: Alexey Gladkov <legion@kernel.org>
To: GuLingguang <liu83783@gmail.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	containers@lists.linux.dev,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	Aleksa Sarai <cyphar@cyphar.com>,
	"Serge E . Hallyn" <serge@hallyn.com>
Subject: Re: [RFC] mnt_already_visible(): should regular-file mountpoints
 participate in the visibility check?
Message-ID: <anroiuNYZTID6VXS@example.org>
References: <20260808132309.35924-1-liu83783@gmail.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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

In this particular case, yes, but that is not true for other files in
/proc.

>  2. Structure.  A file mountpoint never covers a directory tree, so
>     the directory hierarchy of the fresh mount matches what a bind
>     mount of the existing proc would show.
> 
>  3. Permissions.  The files themselves remain subject to their own
>     permission checks; a fresh mount does not bypass them.
>     (One theoretical caveat: an overmount could in principle replace
>     a proc file with a bind of a less permissive file (e.g. mode
>     0600), which a fresh mount would undo, potentially giving
>     non-root users in the namespace access they did not have before.
>     I am not aware of any real deployment doing this -- the overmounts
>     I know of virtualize read-only values such as uptime/loadavg/
>     meminfo with unchanged permissions -- but I would like the
>     maintainers' view on whether this caveat is a concern.)

A new mount may give you access to content that you could potentially have
(due to insecure file permissions), but the container's creators do not
want to grant you access to it.

For example, podman does not allow you to view the contents of /proc/keys
(0444) or /proc/interrupts (0444), which is set to read-only for everyone
on the system.

> Directory mountpoints are a different matter: a locked directory
> mount can hide an entire subtree (hidepid-style masking), which is
> what the check is designed to catch.  The question is whether file
> mountpoints belong in the same determination.
> 
> Historical record
> 
> The behaviour for file mountpoints has been unchanged since the check
> was introduced in 2013 (rejected then, rejected now), and I could not
> find any record -- commit message, mailing list discussion, or code
> comment -- in which file mountpoints were discussed.  For example,
> the commit message of the 2015 rewrite (7236c85e1be5) speaks only of
> directories.  If the rejection of file mountpoints is intentional,
> could you point to where that intention was recorded?
> 
> Related upstream work
> 
> The check was relaxed earlier this year for restricted proc variants
> (subset=pid) on the grounds that "almost all container
> implementations override part of procfs to hide certain directories"
> (merge a76640171b29, April 2026), and the 2016 LKML thread already
> discussed the same problem, ending with a userspace workaround rather
> than a kernel change.

This change was acceptable because the dynamic part of the proc cannot
be overridden by another mount. 

> Questions
> 
>  1. Should regular-file mountpoints participate in the "not fully
>     visible" determination at all?

Yes. Otherwise, you'll break the existing container creation systems like
docker or podman.

>  2. Is the invariant the check protects about the presence/type of
>     mounts on proc, or about the visibility of procfs's directory
>     tree?

The purpose of the check is described by Eric and applies not only to
directories but also to files.

>  3. Is there a recorded intent for rejecting file mountpoints, and
>     does it still apply given the above?

Previously, this behavior existed in practice, and the container
developers were aware of it. And now it's documented.

https://web.git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/Documentation/filesystems/proc.rst#n2440

> I am deliberately not proposing an implementation yet; I would like
> to understand the intended invariant first.
> 
> Thanks,
> GuLingguang <liu83783@gmail.com>
> 

-- 
Rgrds, legion

