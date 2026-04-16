Received: from mout-p-202.mailbox.org (mout-p-202.mailbox.org [80.241.56.172])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 790A537C0F1
	for <containers@lists.linux.dev>; Thu, 16 Apr 2026 12:31:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=80.241.56.172
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776342678; cv=none; b=BTmFDCVP7FsTLuR3kxJadWjG+WflIAAbrXgpncjHnGDCn7JNwHFjN1djbPbxm2hQrTbl5LlXZNxbib+r0f1Fmbp8x3nR2l95B7CkYZgxHCrGVJGn3+5XrmRcWuE7KgRiuZoCL0HCAY8FmQyO9E9B1Me/v8mJflx65zA8EMw4l0A=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776342678; c=relaxed/simple;
	bh=/snnYRfdSQJy8UosFtgCFOb9PsjiC59IF3hJ+Bhow6M=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=cu98e8XDyran+zwyEXRDNeJdnH79lNZUJmCuAD+nAIJKlFLX+pGtOR3eXUFi9xgoR/P3M7IzJB4z7H1o1vwwjah9XCITD5bgFF3f9DZ9NXQkoUAmk4h9qLmFLYZkbGqEp+ah/a9gLvnAbqJZOI7p53PDZzWQ5+l7bUjSKBl4yMc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=cyphar.com; spf=pass smtp.mailfrom=cyphar.com; dkim=pass (2048-bit key) header.d=cyphar.com header.i=@cyphar.com header.b=cR8a5fcc; arc=none smtp.client-ip=80.241.56.172
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=cyphar.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=cyphar.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=cyphar.com header.i=@cyphar.com header.b="cR8a5fcc"
Received: from smtp1.mailbox.org (smtp1.mailbox.org [IPv6:2001:67c:2050:b231:465::1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mout-p-202.mailbox.org (Postfix) with ESMTPS id 4fxHRp1Yk1z9tmv;
	Thu, 16 Apr 2026 14:31:02 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=cyphar.com; s=MBO0001;
	t=1776342662;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=RSEdgIilWbKvnLVdzoCjHp1J8IPfemkvVPEJ2b6JJ3g=;
	b=cR8a5fccImXvidbxSywHjm8yP9CBRXk28o55o/foQ6LWV4D/0XYb1naeFfu56g7GcGEQJe
	LLYObe9DwrZUnDv3j6UkjZ8JSQ8zcPjc+JFvOHl55Dw8q1D5tC5VsiCsBnNYUJXf01WKG7
	SzgMvwvSgzq7XB3iv0kswEpF0m86qO3Z8og0XhxJV2unxl36TJQ3ouovtonyeCHM5zQlwG
	6UEHeq8DzzhJtvUvcyB/OX6a/x7lIqyir5/4o/NM3r1ceYyay7trE1hG1Sg6Q0H56tIO5x
	+N5X6qIKzvhOHmef79Ypw0nq6+3Qd+3Ok0aBJIQi4+WnJKLoo/O8Xuu2q96fFA==
Authentication-Results: outgoing_mbo_mout;
	dkim=none;
	spf=pass (outgoing_mbo_mout: domain of cyphar@cyphar.com designates 2001:67c:2050:b231:465::1 as permitted sender) smtp.mailfrom=cyphar@cyphar.com
Date: Thu, 16 Apr 2026 22:30:51 +1000
From: Aleksa Sarai <cyphar@cyphar.com>
To: Alexey Gladkov <legion@kernel.org>
Cc: Christian Brauner <brauner@kernel.org>, 
	Dan Klishch <danilklishch@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>, 
	"Eric W . Biederman" <ebiederm@xmission.com>, Kees Cook <keescook@chromium.org>, containers@lists.linux.dev, 
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v9 4/5] proc: Skip the visibility check if subset=pid is
 used
Message-ID: <2026-04-16-serious-inky-roach-visitors-SZzNqk@cyphar.com>
References: <cover.1770979341.git.legion@kernel.org>
 <cover.1776079055.git.legion@kernel.org>
 <38572c1fb7cf55b4c27dd792adafa52f1216e3a3.1776079055.git.legion@kernel.org>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="g4e6jdjfuqjlg5v6"
Content-Disposition: inline
In-Reply-To: <38572c1fb7cf55b4c27dd792adafa52f1216e3a3.1776079055.git.legion@kernel.org>
X-Rspamd-Queue-Id: 4fxHRp1Yk1z9tmv


--g4e6jdjfuqjlg5v6
Content-Type: text/plain; protected-headers=v1; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
Subject: Re: [PATCH v9 4/5] proc: Skip the visibility check if subset=pid is
 used
MIME-Version: 1.0

On 2026-04-13, Alexey Gladkov <legion@kernel.org> wrote:
> When procfs is mounted with the subset=3Dpid option, all system files and
> directories from the root of the filesystem are not accessible in
> userspace. Only dynamic information about processes is available, which
> cannot be hidden with overmount.
>=20
> For this reason, checking for full visibility is not relevant if mounting
> is performed with the subset=3Dpid option.
>=20
> Signed-off-by: Alexey Gladkov <legion@kernel.org>
> ---

> -static bool mount_too_revealing(const struct super_block *sb, int *new_m=
nt_flags)
> +static bool mount_too_revealing(struct fs_context *fc, int *new_mnt_flag=
s)
>  {
>  	const unsigned long required_iflags =3D SB_I_NOEXEC | SB_I_NODEV;
>  	struct mnt_namespace *ns =3D current->nsproxy->mnt_ns;
> +	const struct super_block *sb =3D fc->root->d_sb;
>  	unsigned long s_iflags;
> =20
>  	if (ns->user_ns =3D=3D &init_user_ns)
> @@ -6388,7 +6387,7 @@ static bool mount_too_revealing(const struct super_=
block *sb, int *new_mnt_flags
>  		return true;
>  	}
> =20
> -	return !mnt_already_visible(ns, sb, new_mnt_flags);
> +	return (!fc->skip_visibility && !mnt_already_visible(ns, sb, new_mnt_fl=
ags));
>  }

Unless I'm missing something (I haven't tested this locally yet, sorry),
this will allow you to bypass mount_too_revealing() even for
non-subset=3Dpid mounts because once you create a subset=3Dpid mount then a
regular procfs mount will see the subset=3Dpid mount and permit it.

I think the solution is quite simple -- you can also skip super-blocks
that have fc->skip_visibility set in mnt_already_visible().

Unfortunately, the fact that both subset=3Dpid and fully-loaded procfs
look like the same type (procfs) to mnt_already_visible() is something
people have already exploited in userspace. (The k8s workaround from a
long time ago used subset=3Dpid from a dead pidns to stop the mount from
being useful to an attacker while still bypassing mount_too_revealing().
That being said, that workaround was removed a long time ago and I don't
know how widespread this is.)

I'd be happy to give it a shot but if it breaks userspace we might need
a new mount option to work around it...

--=20
Aleksa Sarai
https://www.cyphar.com/

--g4e6jdjfuqjlg5v6
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iJEEABYKADkWIQS2TklVsp+j1GPyqQYol/rSt+lEbwUCaeDWexsUgAAAAAAEAA5t
YW51MiwyLjUrMS4xMiwyLDIACgkQKJf60rfpRG90iAEA93c0gDehfxRlp75MhzTM
v/MZsJzl3wFZ1PJGDwxu/F8A/2zAckjBOq/ekPcAbQB8/FQ10aToBdRsPiKD3Q7R
MFMA
=365J
-----END PGP SIGNATURE-----

--g4e6jdjfuqjlg5v6--
