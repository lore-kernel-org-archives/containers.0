Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C5DCC3C277F;
	Tue, 21 Apr 2026 12:24:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776774254; cv=none; b=RXR53soR/PGv0YskXJO9rmgf2ZCFdcWcFB55rCYBEFc5rAeD/E7jaqUxDTGxqBcIAix5i0DTfkJiJr2xdo6eBKnmGciIZNd/gH6f7DFAyRM0VodXwFF6sB0b286TLomyL/6aSdX0Ed++4bnURMiR+eTUvSbiSbbJ9YamiMuY/wc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776774254; c=relaxed/simple;
	bh=zI7ESWr65A1AmIdFGMnVytAaNpUyRk5TU1a5ceJIsPk=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=lh7cpmYdVFTS7MdbnNX8ubPistfZo82kvLNyE45aFwlNPF3FewQrBkSaaWXjFRsZ0L/cQ7vaKZJsfG6jGiElwTMhB04oSUDnfBY+Ff4YxcYmf0Og/qj/L+DpnYCYKI2Lip13+/02WIhy08X7qbds0pQnlc1kNwBR5yoAyMn2wlo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=gNKWzqI1; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="gNKWzqI1"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DD683C2BCB0;
	Tue, 21 Apr 2026 12:24:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1776774253;
	bh=zI7ESWr65A1AmIdFGMnVytAaNpUyRk5TU1a5ceJIsPk=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=gNKWzqI19EZBNey5fOeIbTSlvM1dX3hEqbS5AtNFTbKJ46tCtBeG+90I/5rlztiKJ
	 j7H/FW3R4jt9GTCNc0XFCpHJs764Oj/YZYKN4lNkZ6RUaU/ggIKQxokSCc2KGW0UdY
	 Xh14c5kLRybH0I0W9THmU8KLtm7jCsqwQQC82DJrWSzJpcKb+hjA7X28uP/5IHavIW
	 a2Y6EME8cq6bwuOJGVAnxtatdCJtrN3e5TpHwfiZtOoWHZxHn8R12Sfab4OEYelWE2
	 wKad+qgqHNBcJHW6KfR6m+fGzCh9C3YQOInmq125ZCueTF2rpmrPiDlR1LpmoWEgV7
	 rtGZPn+ArSf6w==
Date: Tue, 21 Apr 2026 14:24:08 +0200
From: Alexey Gladkov <legion@kernel.org>
To: Christian Brauner <brauner@kernel.org>
Cc: Aleksa Sarai <cyphar@cyphar.com>, Dan Klishch <danilklishch@gmail.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	Kees Cook <keescook@chromium.org>, containers@lists.linux.dev,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v9 4/5] proc: Skip the visibility check if subset=pid is
 used
Message-ID: <aedsaAYi48NKWg_0@example.org>
References: <cover.1770979341.git.legion@kernel.org>
 <cover.1776079055.git.legion@kernel.org>
 <38572c1fb7cf55b4c27dd792adafa52f1216e3a3.1776079055.git.legion@kernel.org>
 <2026-04-16-serious-inky-roach-visitors-SZzNqk@cyphar.com>
 <2026-04-16-popular-long-bicep-bistros-8teEl3@cyphar.com>
 <20260416-gewusel-dreck-63a7fc32a586@brauner>
 <2026-04-16-jaded-sour-find-end-6LhEP4@cyphar.com>
 <20260421-duzen-laugenbrezel-e1d1138ff5ae@brauner>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260421-duzen-laugenbrezel-e1d1138ff5ae@brauner>

On Tue, Apr 21, 2026 at 01:51:47PM +0200, Christian Brauner wrote:
> On Fri, Apr 17, 2026 at 01:03:46AM +1000, Aleksa Sarai wrote:
> > On 2026-04-16, Christian Brauner <brauner@kernel.org> wrote:
> > > On Thu, Apr 16, 2026 at 10:46:50PM +1000, Aleksa Sarai wrote:
> > > > On 2026-04-16, Aleksa Sarai <cyphar@cyphar.com> wrote:
> > > > > On 2026-04-13, Alexey Gladkov <legion@kernel.org> wrote:
> > > > > > When procfs is mounted with the subset=pid option, all system files and
> > > > > > directories from the root of the filesystem are not accessible in
> > > > > > userspace. Only dynamic information about processes is available, which
> > > > > > cannot be hidden with overmount.
> > > > > > 
> > > > > > For this reason, checking for full visibility is not relevant if mounting
> > > > > > is performed with the subset=pid option.
> > > > > > 
> > > > > > Signed-off-by: Alexey Gladkov <legion@kernel.org>
> > > > > > ---
> > > > > 
> > > > > > -static bool mount_too_revealing(const struct super_block *sb, int *new_mnt_flags)
> > > > > > +static bool mount_too_revealing(struct fs_context *fc, int *new_mnt_flags)
> > > > > >  {
> > > > > >  	const unsigned long required_iflags = SB_I_NOEXEC | SB_I_NODEV;
> > > > > >  	struct mnt_namespace *ns = current->nsproxy->mnt_ns;
> > > > > > +	const struct super_block *sb = fc->root->d_sb;
> > > > > >  	unsigned long s_iflags;
> > > > > >  
> > > > > >  	if (ns->user_ns == &init_user_ns)
> > > > > > @@ -6388,7 +6387,7 @@ static bool mount_too_revealing(const struct super_block *sb, int *new_mnt_flags
> > > > > >  		return true;
> > > > > >  	}
> > > > > >  
> > > > > > -	return !mnt_already_visible(ns, sb, new_mnt_flags);
> > > > > > +	return (!fc->skip_visibility && !mnt_already_visible(ns, sb, new_mnt_flags));
> > > > > >  }
> > > > > 
> > > > > Unless I'm missing something (I haven't tested this locally yet, sorry),
> > > > > this will allow you to bypass mount_too_revealing() even for
> > > > > non-subset=pid mounts because once you create a subset=pid mount then a
> > > > > regular procfs mount will see the subset=pid mount and permit it.
> > > > > 
> > > > > I think the solution is quite simple -- you can also skip super-blocks
> > > > > that have fc->skip_visibility set in mnt_already_visible().
> > > > 
> > > > I now see that check was present in v8 but I guess its importance wasn't
> > > > obvious. I guess this means we will need to reintroduce
> > > > SB_I_USERNS_ALLOW_REVEALING. :/
> > > 
> > > I've been playing with something else. So first we should move
> > > SB_I_USERNS_REVEALING to an fs_type flag. It's not an optional thing and
> > > always set and never removed. That also means we can simplify
> > > sysfs_get_tree() to just kernfs_get_tree().
> > 
> > Seems quite reasonable to me.
> > 
> > > And then we raise SB_I_USERNS_RESTRICTED on all procfs mounts with
> > > pid_only and disallow using them for calculating mount permissions for
> > > unrestricted procfs mounts.
> > 
> > I think that's fine here and is probably all we need for now (though I
> > think that the name is a little confusing especially given my next
> > comment), but I think there is a bit of a deeper problem here that
> > deserves to be mentioned if only for posterity.
> > 
> > The core issue really is that we actually have two versions of procfs
> > now, and they are effectively distinguished by fs_context flags instead
> > of fs_type. Back when subset=pid was merged there was a discussion about
> > a hypothetical proc2 -- while that got dropped, we are kind of
> > reinventing this split in an ad-hoc way.
> > 
> > Conceptually considering them as two distinct fs_types would be the more
> > semantically correct thing to do, though I think it would be overkill to
> > come up with some framework for that. (I also really hope we don't have
> > any other filesystems where this is also the case.)
> 
> Doing this is almost trivial. The problem really is that we'd expose
> "procfs2" or whatever as a new mount option to userspace without
> actually having fundamentally revamped what we would like procfs2 to do.

Agree.

The new procfs2 should not have the issues present in procfs.

> IOW, it would elevate a security hack that got added a while ago to a
> new filesystem type. I think that would just be sad. So I'm not so
> excited about doing this.
> 
> > This is why I think the name is a little weird, since it isn't an issue
> > about one procfs being restricted in a userns, it's that they are
> > conceptually unrelated filesystem types. A very lightweight version of
> 
> I somewhat disagree because it's unclear where you draw the line. If you
> use the hidepid= stuff at its most restrictive where it only shows tasks
> your user owns you could also argue that it's very close to a separate
> filesystem type. It's strictly subtractive and so is pidonly. There's
> just nothing that's better or novel.
> 
> > this would be making it something like SB_I_RESTRICTED_VARIANT that
> > would be more a little more strict than what you have now --
> > SB_I_RESTRICTED_VARIANT would not be treated as compatible with anything
> > (even another SB_I_RESTRICTED_VARIANT mount) so that if we add more
> > variants in the future we don't treat them the same either. (Again, I
> > don't think we need this now?) Of course this would still allow
> > subset=pid without a procfs mount because of the other special casing
> > for it in mount_too_revealing().
> 
> It's not a problem today. I think we can simply treat
> SB_I_RESTRICTED_VARIANT as not allowing other restricted variants. And
> we'd need a more elaborate mechanism anyway once we'd have "compatible"
> subsets.
> 
> > We are also limited in what semantics we can change here too (and I'm a
> > little worried that even this bit for SB_I_USERNS_RESTRICTED is at risk
> > of breaking something) so maybe that isn't needed today.
> 
> So I think yes, SB_I_RESTRICTED_VARIANT is fine by me for now.

Should I create a new version and add this to my patchset?

-- 
Rgrds, legion

