Received: from mout-p-103.mailbox.org (mout-p-103.mailbox.org [80.241.56.161])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B6FF81A6837
	for <containers@lists.linux.dev>; Thu, 16 Apr 2026 12:47:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=80.241.56.161
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776343637; cv=none; b=PvHHvaOYhigLKe/8XPqbehip+V4GvhPdGhAqSOeJotnVeRP+F2aIRs+1PPMMti8TT74KLoPJpSV3IfF5RH+krFjqCS5iAMr+lUJYl3ap4YPl2PggWKbOoKh0DjF+FO4jSgbgwiJiMhCDO7LObchHWnjCYzKfx9dNm7e1FpFqc2E=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776343637; c=relaxed/simple;
	bh=0qVX/wN4c8Xs/ape8KUFAL8CHkuwcgD3HyiN2Ds19Bk=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=KXsSavyz2ymyRFdeVqq8zqRWnCYt7L1qLchBiDBFRk7P1AJGYozxbR2SgNjgt2cZ3+FkfuSa80Njprfw3MDGB1rUdfhi9VbLqXXU8ABF5uSyyUv3m9ashzrCwfOeMZeX51MvTJNZSnx/rrrRUWhrjkvxV13FHfirlPHLnbqK1IU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=cyphar.com; spf=pass smtp.mailfrom=cyphar.com; dkim=pass (2048-bit key) header.d=cyphar.com header.i=@cyphar.com header.b=yNd/OrTs; arc=none smtp.client-ip=80.241.56.161
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=cyphar.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=cyphar.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=cyphar.com header.i=@cyphar.com header.b="yNd/OrTs"
Received: from smtp202.mailbox.org (smtp202.mailbox.org [IPv6:2001:67c:2050:b231:465::202])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mout-p-103.mailbox.org (Postfix) with ESMTPS id 4fxHpJ1HYBz9srp;
	Thu, 16 Apr 2026 14:47:04 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=cyphar.com; s=MBO0001;
	t=1776343624;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=tstWI7sprYPwL2F7G4BMlqW849+usc2YHc/H9Y3VOZc=;
	b=yNd/OrTsQ2vjtbc5Qw7ivcDYqiomOaGWHyMXw6vlvMZh0LrU9m6S09s5r/QW1Z6epGsVNm
	2WVgblhnU6BCHyF+vK2Uzdy62tOHLS/ikfq4vOSHF6ghS9dESDxjSTUz5Q4FpZLTTb0euG
	ulxtZN6AVYS9lrUUZ9UAM4Br0Zwv/BhYI78c4Zlkh86KhVC0mkL/MiJ8dvxz9Ra64EUNft
	QymU9XesbjWVop3tbklsmRqm+IplYelQWPh5BR83OJhR6CCC6tl2+I8xB9Dj+rBz4PtIRt
	mMcDyXx1Swvpz6BwbojeQ1VRwv1zVH5+dCQCv6MysHEPM8YQA4y0g3iwUtQ0Sw==
Authentication-Results: outgoing_mbo_mout;
	dkim=none;
	spf=pass (outgoing_mbo_mout: domain of cyphar@cyphar.com designates 2001:67c:2050:b231:465::202 as permitted sender) smtp.mailfrom=cyphar@cyphar.com
Date: Thu, 16 Apr 2026 22:46:50 +1000
From: Aleksa Sarai <cyphar@cyphar.com>
To: Alexey Gladkov <legion@kernel.org>
Cc: Christian Brauner <brauner@kernel.org>, 
	Dan Klishch <danilklishch@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>, 
	"Eric W . Biederman" <ebiederm@xmission.com>, Kees Cook <keescook@chromium.org>, containers@lists.linux.dev, 
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v9 4/5] proc: Skip the visibility check if subset=pid is
 used
Message-ID: <2026-04-16-popular-long-bicep-bistros-8teEl3@cyphar.com>
References: <cover.1770979341.git.legion@kernel.org>
 <cover.1776079055.git.legion@kernel.org>
 <38572c1fb7cf55b4c27dd792adafa52f1216e3a3.1776079055.git.legion@kernel.org>
 <2026-04-16-serious-inky-roach-visitors-SZzNqk@cyphar.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="bv5tgnqdlabxgz4a"
Content-Disposition: inline
In-Reply-To: <2026-04-16-serious-inky-roach-visitors-SZzNqk@cyphar.com>
X-Rspamd-Queue-Id: 4fxHpJ1HYBz9srp


--bv5tgnqdlabxgz4a
Content-Type: text/plain; protected-headers=v1; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
Subject: Re: [PATCH v9 4/5] proc: Skip the visibility check if subset=pid is
 used
MIME-Version: 1.0

On 2026-04-16, Aleksa Sarai <cyphar@cyphar.com> wrote:
> On 2026-04-13, Alexey Gladkov <legion@kernel.org> wrote:
> > When procfs is mounted with the subset=3Dpid option, all system files a=
nd
> > directories from the root of the filesystem are not accessible in
> > userspace. Only dynamic information about processes is available, which
> > cannot be hidden with overmount.
> >=20
> > For this reason, checking for full visibility is not relevant if mounti=
ng
> > is performed with the subset=3Dpid option.
> >=20
> > Signed-off-by: Alexey Gladkov <legion@kernel.org>
> > ---
>=20
> > -static bool mount_too_revealing(const struct super_block *sb, int *new=
_mnt_flags)
> > +static bool mount_too_revealing(struct fs_context *fc, int *new_mnt_fl=
ags)
> >  {
> >  	const unsigned long required_iflags =3D SB_I_NOEXEC | SB_I_NODEV;
> >  	struct mnt_namespace *ns =3D current->nsproxy->mnt_ns;
> > +	const struct super_block *sb =3D fc->root->d_sb;
> >  	unsigned long s_iflags;
> > =20
> >  	if (ns->user_ns =3D=3D &init_user_ns)
> > @@ -6388,7 +6387,7 @@ static bool mount_too_revealing(const struct supe=
r_block *sb, int *new_mnt_flags
> >  		return true;
> >  	}
> > =20
> > -	return !mnt_already_visible(ns, sb, new_mnt_flags);
> > +	return (!fc->skip_visibility && !mnt_already_visible(ns, sb, new_mnt_=
flags));
> >  }
>=20
> Unless I'm missing something (I haven't tested this locally yet, sorry),
> this will allow you to bypass mount_too_revealing() even for
> non-subset=3Dpid mounts because once you create a subset=3Dpid mount then=
 a
> regular procfs mount will see the subset=3Dpid mount and permit it.
>=20
> I think the solution is quite simple -- you can also skip super-blocks
> that have fc->skip_visibility set in mnt_already_visible().

I now see that check was present in v8 but I guess its importance wasn't
obvious. I guess this means we will need to reintroduce
SB_I_USERNS_ALLOW_REVEALING. :/

> Unfortunately, the fact that both subset=3Dpid and fully-loaded procfs
> look like the same type (procfs) to mnt_already_visible() is something
> people have already exploited in userspace. (The k8s workaround from a
> long time ago used subset=3Dpid from a dead pidns to stop the mount from
> being useful to an attacker while still bypassing mount_too_revealing().
> That being said, that workaround was removed a long time ago and I don't
> know how widespread this is.)
>=20
> I'd be happy to give it a shot but if it breaks userspace we might need
> a new mount option to work around it...

--=20
Aleksa Sarai
https://www.cyphar.com/

--bv5tgnqdlabxgz4a
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iJEEABYKADkWIQS2TklVsp+j1GPyqQYol/rSt+lEbwUCaeDaOhsUgAAAAAAEAA5t
YW51MiwyLjUrMS4xMiwyLDIACgkQKJf60rfpRG+yTQD/dOdJmE6eRydxRawQeXBM
jYb0iaA2T7Mu6WxQRMx8reYA/jHzQBeyi8J1/9e+dVKZQmoeZa0Lcmj48tCPUZ1V
4IwE
=7nDS
-----END PGP SIGNATURE-----

--bv5tgnqdlabxgz4a--
