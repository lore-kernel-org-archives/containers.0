Received: from mout-p-103.mailbox.org (mout-p-103.mailbox.org [80.241.56.161])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8DB15322B88
	for <containers@lists.linux.dev>; Mon, 27 Apr 2026 22:31:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=80.241.56.161
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777329092; cv=none; b=knzjmFUQae+DPRjfkxzr26cjJgS/dWJggtAo11jf4739RSshLRmJfFiXnrwP8NsRNT+V0jGFkP+0RtVIZrKHU/muemBlT7TDXo+jTsg5wOzNLy2Z//p0SmVOUzmvm95aj83WMFKBwuvVWpyAogTz+W1LVunj1kyQZdg3gZKk+5s=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777329092; c=relaxed/simple;
	bh=koE37U2dNJyk36u1wYgazGG10UvQfk6Cwv1Eb/gTR90=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=AWZg72wwfKkIgMjmFSRoihrjqNKxzHQoGTaIV39QnaADLB9974yCmu6DG+5uP8OHCaqh2B+nGBcz+sfctH/ZvAym/UU2GEdF0GdqRi8Bk7+Vo6vRkjVjF/OcL3CXc97h8L1WcosvMRs8CGnt3jgRMXtq3EGkSnhxjFw8WCbVR/s=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=cyphar.com; spf=pass smtp.mailfrom=cyphar.com; dkim=pass (2048-bit key) header.d=cyphar.com header.i=@cyphar.com header.b=rxQTumEi; arc=none smtp.client-ip=80.241.56.161
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=cyphar.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=cyphar.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=cyphar.com header.i=@cyphar.com header.b="rxQTumEi"
Received: from smtp1.mailbox.org (smtp1.mailbox.org [IPv6:2001:67c:2050:b231:465::1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mout-p-103.mailbox.org (Postfix) with ESMTPS id 4g4JFM5xBlz9tqB;
	Tue, 28 Apr 2026 00:31:19 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=cyphar.com; s=MBO0001;
	t=1777329079;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=sPizMkSC/4rLI/GQp3ohA4AxZEsuWeiwS7TdltvOXSw=;
	b=rxQTumEiPGm3i5pbN0m7Ou5d9ibae5k/XhjBVeB98KBE4FLzGLOpaEsyrL8CyI5zTJjxOw
	lQ+2CGhyv04oZDUBjbuOkuVZBPQ6ZQzTlmR7NWmO5jyMFsKf/6T4+20ikJoHXNH8vB7ZdS
	DhlySNgZLaf7ygKccMKSKWyfKOBDw7GaiwShihTQMKSpp58766gHBT+mhhEGZi2i9sxXUk
	X70kDzAZBz5Gi5iZ45+I3ebOVs5U98m61psID1yfP/oNL1Gr62Ur/IK0AGFLZ3ItrNnZ9f
	sDtkmKpI57+ljlKRrl9/lRTGpWgyna2UoTV/uwqNT5Jdba1oa2ZjBO2tsLKb0w==
Authentication-Results: outgoing_mbo_mout;
	dkim=none;
	spf=pass (outgoing_mbo_mout: domain of cyphar@cyphar.com designates 2001:67c:2050:b231:465::1 as permitted sender) smtp.mailfrom=cyphar@cyphar.com
Date: Tue, 28 Apr 2026 08:31:05 +1000
From: Aleksa Sarai <cyphar@cyphar.com>
To: Alexey Gladkov <legion@kernel.org>
Cc: Christian Brauner <brauner@kernel.org>, 
	Dan Klishch <danilklishch@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>, 
	"Eric W . Biederman" <ebiederm@xmission.com>, Kees Cook <keescook@chromium.org>, containers@lists.linux.dev, 
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v10 5/7] proc: prevent reconfiguring subset=pid
Message-ID: <2026-04-27-dandy-expert-hiker-furniture-F3LYaO@cyphar.com>
References: <cover.1776079055.git.legion@kernel.org>
 <cover.1777278334.git.legion@kernel.org>
 <13295f40f642af5d6e7038d681d43132ad80f7b2.1777278334.git.legion@kernel.org>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="jwa63nlcnrw6nfdy"
Content-Disposition: inline
In-Reply-To: <13295f40f642af5d6e7038d681d43132ad80f7b2.1777278334.git.legion@kernel.org>
X-Rspamd-Queue-Id: 4g4JFM5xBlz9tqB


--jwa63nlcnrw6nfdy
Content-Type: text/plain; protected-headers=v1; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
Subject: Re: [PATCH v10 5/7] proc: prevent reconfiguring subset=pid
MIME-Version: 1.0

On 2026-04-27, Alexey Gladkov <legion@kernel.org> wrote:
> Changing subset=3Dpid on an existing procfs instance is not safe. If a
> full procfs mount has entries hidden by overmounts, switching it to
> subset=3Dpid would hide the top-level procfs entries from lookup and
> readdir while leaving the existing overmounts reachable.
>=20
> Reject attempts to change the subset=3Dpid state during reconfigure before
> applying any other procfs mount options, so a failed reconfigure cannot
> partially update the instance.
>=20
> Signed-off-by: Alexey Gladkov <legion@kernel.org>
> ---
>  fs/proc/root.c | 15 +++++++++++----
>  1 file changed, 11 insertions(+), 4 deletions(-)
>=20
> diff --git a/fs/proc/root.c b/fs/proc/root.c
> index 89e5678129e4..1bf75a4ee146 100644
> --- a/fs/proc/root.c
> +++ b/fs/proc/root.c
> @@ -223,12 +223,17 @@ static int proc_parse_param(struct fs_context *fc, =
struct fs_parameter *param)
>  	return 0;
>  }
> =20
> -static void proc_apply_options(struct proc_fs_info *fs_info,
> +static int proc_apply_options(struct proc_fs_info *fs_info,
>  			       struct fs_context *fc,
>  			       struct user_namespace *user_ns)
>  {
>  	struct proc_fs_context *ctx =3D fc->fs_private;
> =20
> +	if ((ctx->mask & (1 << Opt_subset)) &&
> +	    fc->purpose =3D=3D FS_CONTEXT_FOR_RECONFIGURE &&
> +	    ctx->pidonly !=3D fs_info->pidonly)
> +		return invalf(fc, "proc: subset=3Dpid cannot be changed\n");

Minor nit: Unless I'm missing something, you can just use invalfc here
to auto-add the "proc" prefix (which is what most things do). Also, the
newline is unnecessary and will look odd in mount(8) as nobody else adds
newlines (the fs_context log is not newline-separated).

--=20
Aleksa Sarai
https://www.cyphar.com/

--jwa63nlcnrw6nfdy
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iJEEABYKADkWIQS2TklVsp+j1GPyqQYol/rSt+lEbwUCae/jpRsUgAAAAAAEAA5t
YW51MiwyLjUrMS4xMiwyLDIACgkQKJf60rfpRG9ueQD/c8OctfQuVD97bcrY79DT
iYkB9W/ijHGajiSxTnKsVbkA/2o7sRcN8CH+HnVSgKorJZ0crnAVli/Sndvw4IZr
0jIL
=Ree0
-----END PGP SIGNATURE-----

--jwa63nlcnrw6nfdy--
