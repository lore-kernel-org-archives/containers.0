Received: from mout-p-103.mailbox.org (mout-p-103.mailbox.org [80.241.56.161])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6E19128CF4A
	for <containers@lists.linux.dev>; Thu, 16 Apr 2026 15:04:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=80.241.56.161
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776351851; cv=none; b=WL02nmXYcREqrQqO53ifRezSjikJoPiDcC6ZsCFq7XCCWnWFfodLM4Z3pW0bDcqbC9Avo+GTjnWcnSQa3h8qYxUJdjLNPSfJYJFubII4m+FxS56ok4+KFMV7RtnAkz+CcPq5bQ42QhsGx6cauygcfI2CwO0XvXVb+v0ln2Pdic0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776351851; c=relaxed/simple;
	bh=9T1Q+XaNnhlW3umObocR8VJBSZsDnWOmcVj1RxeI77Q=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=o8CxUJUbCJIHbBgmbxBzHSkcF16Q5p2F1u9dKGTCIhtCMgfyeOIrUsVwM1+swsapw9uhADP5AblgNRyxpQi+tAXozOFrcwChln5cfgNaR6tN1RVAyL37NsUE1JWeCK7T4JN4I+bMk0PBXEY1gDfCWHuJhbxPUjKQRaM8i4+UfvA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=cyphar.com; spf=pass smtp.mailfrom=cyphar.com; dkim=pass (2048-bit key) header.d=cyphar.com header.i=@cyphar.com header.b=tpVrLiya; arc=none smtp.client-ip=80.241.56.161
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=cyphar.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=cyphar.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=cyphar.com header.i=@cyphar.com header.b="tpVrLiya"
Received: from smtp1.mailbox.org (smtp1.mailbox.org [IPv6:2001:67c:2050:b231:465::1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mout-p-103.mailbox.org (Postfix) with ESMTPS id 4fxLrL2Vf3z9tgp;
	Thu, 16 Apr 2026 17:04:02 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=cyphar.com; s=MBO0001;
	t=1776351842;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=hC7t8spEhWKHM6wVx5Oit0sCkkG9nWS2dFHGbFEdPKU=;
	b=tpVrLiyaqas+xdT41Vmwt1Trsne4+8sorREf/eWu2mRIO00fIMJPfEqKPd2yJQLARdFuDR
	vPCnNZxoTEr+QU6FYyylboVe7XH48HPT3xYG7jIxBH8DL0o9QaQOORBOoqD28kITXzsWY2
	KALjSsVXoKzR+x5fSxaEGVRHSHiCPGAAh97R+yrxZgnxX9TjR+ulIGjS9IITxsVX8eVUgb
	4CMeC2x0e87RrNis9m0V67k9E/vt98gJ5iBfjEsV2+2z7uZYgQWhK+hL3bkX18jzH3PZgf
	4MZDHRqRyN4DxXMECSV23+LReXntd8G79CvzvyOKd3VZ5UyuUhlrgt7UAh6z2g==
Authentication-Results: outgoing_mbo_mout;
	dkim=none;
	spf=pass (outgoing_mbo_mout: domain of cyphar@cyphar.com designates 2001:67c:2050:b231:465::1 as permitted sender) smtp.mailfrom=cyphar@cyphar.com
Date: Fri, 17 Apr 2026 01:03:46 +1000
From: Aleksa Sarai <cyphar@cyphar.com>
To: Christian Brauner <brauner@kernel.org>
Cc: Alexey Gladkov <legion@kernel.org>, 
	Dan Klishch <danilklishch@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>, 
	"Eric W . Biederman" <ebiederm@xmission.com>, Kees Cook <keescook@chromium.org>, containers@lists.linux.dev, 
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v9 4/5] proc: Skip the visibility check if subset=pid is
 used
Message-ID: <2026-04-16-jaded-sour-find-end-6LhEP4@cyphar.com>
References: <cover.1770979341.git.legion@kernel.org>
 <cover.1776079055.git.legion@kernel.org>
 <38572c1fb7cf55b4c27dd792adafa52f1216e3a3.1776079055.git.legion@kernel.org>
 <2026-04-16-serious-inky-roach-visitors-SZzNqk@cyphar.com>
 <2026-04-16-popular-long-bicep-bistros-8teEl3@cyphar.com>
 <20260416-gewusel-dreck-63a7fc32a586@brauner>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="mh5hhobfaqc7uwfm"
Content-Disposition: inline
In-Reply-To: <20260416-gewusel-dreck-63a7fc32a586@brauner>
X-Rspamd-Queue-Id: 4fxLrL2Vf3z9tgp


--mh5hhobfaqc7uwfm
Content-Type: text/plain; protected-headers=v1; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
Subject: Re: [PATCH v9 4/5] proc: Skip the visibility check if subset=pid is
 used
MIME-Version: 1.0

On 2026-04-16, Christian Brauner <brauner@kernel.org> wrote:
> On Thu, Apr 16, 2026 at 10:46:50PM +1000, Aleksa Sarai wrote:
> > On 2026-04-16, Aleksa Sarai <cyphar@cyphar.com> wrote:
> > > On 2026-04-13, Alexey Gladkov <legion@kernel.org> wrote:
> > > > When procfs is mounted with the subset=3Dpid option, all system fil=
es and
> > > > directories from the root of the filesystem are not accessible in
> > > > userspace. Only dynamic information about processes is available, w=
hich
> > > > cannot be hidden with overmount.
> > > >=20
> > > > For this reason, checking for full visibility is not relevant if mo=
unting
> > > > is performed with the subset=3Dpid option.
> > > >=20
> > > > Signed-off-by: Alexey Gladkov <legion@kernel.org>
> > > > ---
> > >=20
> > > > -static bool mount_too_revealing(const struct super_block *sb, int =
*new_mnt_flags)
> > > > +static bool mount_too_revealing(struct fs_context *fc, int *new_mn=
t_flags)
> > > >  {
> > > >  	const unsigned long required_iflags =3D SB_I_NOEXEC | SB_I_NODEV;
> > > >  	struct mnt_namespace *ns =3D current->nsproxy->mnt_ns;
> > > > +	const struct super_block *sb =3D fc->root->d_sb;
> > > >  	unsigned long s_iflags;
> > > > =20
> > > >  	if (ns->user_ns =3D=3D &init_user_ns)
> > > > @@ -6388,7 +6387,7 @@ static bool mount_too_revealing(const struct =
super_block *sb, int *new_mnt_flags
> > > >  		return true;
> > > >  	}
> > > > =20
> > > > -	return !mnt_already_visible(ns, sb, new_mnt_flags);
> > > > +	return (!fc->skip_visibility && !mnt_already_visible(ns, sb, new_=
mnt_flags));
> > > >  }
> > >=20
> > > Unless I'm missing something (I haven't tested this locally yet, sorr=
y),
> > > this will allow you to bypass mount_too_revealing() even for
> > > non-subset=3Dpid mounts because once you create a subset=3Dpid mount =
then a
> > > regular procfs mount will see the subset=3Dpid mount and permit it.
> > >=20
> > > I think the solution is quite simple -- you can also skip super-blocks
> > > that have fc->skip_visibility set in mnt_already_visible().
> >=20
> > I now see that check was present in v8 but I guess its importance wasn't
> > obvious. I guess this means we will need to reintroduce
> > SB_I_USERNS_ALLOW_REVEALING. :/
>=20
> I've been playing with something else. So first we should move
> SB_I_USERNS_REVEALING to an fs_type flag. It's not an optional thing and
> always set and never removed. That also means we can simplify
> sysfs_get_tree() to just kernfs_get_tree().

Seems quite reasonable to me.

> And then we raise SB_I_USERNS_RESTRICTED on all procfs mounts with
> pid_only and disallow using them for calculating mount permissions for
> unrestricted procfs mounts.

I think that's fine here and is probably all we need for now (though I
think that the name is a little confusing especially given my next
comment), but I think there is a bit of a deeper problem here that
deserves to be mentioned if only for posterity.

The core issue really is that we actually have two versions of procfs
now, and they are effectively distinguished by fs_context flags instead
of fs_type. Back when subset=3Dpid was merged there was a discussion about
a hypothetical proc2 -- while that got dropped, we are kind of
reinventing this split in an ad-hoc way.

Conceptually considering them as two distinct fs_types would be the more
semantically correct thing to do, though I think it would be overkill to
come up with some framework for that. (I also really hope we don't have
any other filesystems where this is also the case.)

This is why I think the name is a little weird, since it isn't an issue
about one procfs being restricted in a userns, it's that they are
conceptually unrelated filesystem types. A very lightweight version of
this would be making it something like SB_I_RESTRICTED_VARIANT that
would be more a little more strict than what you have now --
SB_I_RESTRICTED_VARIANT would not be treated as compatible with anything
(even another SB_I_RESTRICTED_VARIANT mount) so that if we add more
variants in the future we don't treat them the same either. (Again, I
don't think we need this now?) Of course this would still allow
subset=3Dpid without a procfs mount because of the other special casing
for it in mount_too_revealing().

We are also limited in what semantics we can change here too (and I'm a
little worried that even this bit for SB_I_USERNS_RESTRICTED is at risk
of breaking something) so maybe that isn't needed today.

--=20
Aleksa Sarai
https://www.cyphar.com/

--mh5hhobfaqc7uwfm
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iJEEABYKADkWIQS2TklVsp+j1GPyqQYol/rSt+lEbwUCaeD6UhsUgAAAAAAEAA5t
YW51MiwyLjUrMS4xMiwyLDIACgkQKJf60rfpRG+OEgEAzCqIysmMjz3sCIfwiBkJ
cvTx+Eg1ee1g0EvBwMv6aJsA/0pqiLm5AlRE9Fl1/X1zMo8czkacW3Hr8qFGaEKC
Zl4N
=RrtB
-----END PGP SIGNATURE-----

--mh5hhobfaqc7uwfm--
