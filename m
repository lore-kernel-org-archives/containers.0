Received: from mout-p-101.mailbox.org (mout-p-101.mailbox.org [80.241.56.151])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9A9C219D89E
	for <containers@lists.linux.dev>; Wed, 22 Apr 2026 22:33:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=80.241.56.151
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776897187; cv=none; b=cQgM4hXkUe9JZwKtGhbNaTgaVAAFOW51SM5a0Asg3rXHOak6xSm5GXdOpPqGjgmmSx+M0oaeTFuQJdnMOajSHjQBlrIk6GpWoRQ33v0sD3ie381ZcUsduGQ+vO6JgOJGJ1G/iQ4JhieNr0Z+LO50V0wbTbXL+GlHVunAFDHg4NA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776897187; c=relaxed/simple;
	bh=C3hCIB80iTTMgv+7Em6LAHazhvVYnpvWV7/Q4GLlQdQ=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=AqtykeUizzIO2UxKRIG0V0qLdb+OmaAhj/nbRly47vhTvkoSgdZ3WIUIkNqW0yq+kp/xxammVL8Jki/TuRViT5Yqu56jbgeOp3b30f7XtAOCQkZD9hctA5zEPCvfB+bnRl78s4mv9t3XtyBiE00+DXTnZmxg32mNjaHyi5Nx7As=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=cyphar.com; spf=pass smtp.mailfrom=cyphar.com; dkim=pass (2048-bit key) header.d=cyphar.com header.i=@cyphar.com header.b=z0jflcoq; arc=none smtp.client-ip=80.241.56.151
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=cyphar.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=cyphar.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=cyphar.com header.i=@cyphar.com header.b="z0jflcoq"
Received: from smtp202.mailbox.org (smtp202.mailbox.org [IPv6:2001:67c:2050:b231:465::202])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mout-p-101.mailbox.org (Postfix) with ESMTPS id 4g1DWW3FPDz9swN;
	Thu, 23 Apr 2026 00:32:55 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=cyphar.com; s=MBO0001;
	t=1776897175;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=YZNsB1jZ+XgSLUWsMBD+hYG473QYSknETD2GaX6f1fo=;
	b=z0jflcoqtcIwma36bQDNLHwatg5+V+gW3zzfKo2iR7JRfnNfBeCiHKv3CoWZPQSAdJ3X1C
	9T5QGzTgt0iA2fhE4ndmhlMesnqSDrQA7Jamr1dXFNS3tHBLd52N/SAQKPmbzsyS9WMX/V
	DSLkf2BmAx/tvYLbR7F0f/X5feViUcaSQ/QsDlBFNzSr58UQhIKD5Lr8wwZghmXbDMyMCM
	e9TlCD24DMZz+cK2O7rTiClO9CZrIAaHeP6rLp6hRhpnM5j6hdv3CdSRLfHR/WWLrX9wFq
	RwCPgELoVf/zYUC1a0fvESJcR7p07Yo5Ab1wz+ywy8Jo4pT7syfblBRT6oi+xw==
Authentication-Results: outgoing_mbo_mout;
	dkim=none;
	spf=pass (outgoing_mbo_mout: domain of cyphar@cyphar.com designates 2001:67c:2050:b231:465::202 as permitted sender) smtp.mailfrom=cyphar@cyphar.com
Date: Thu, 23 Apr 2026 08:32:41 +1000
From: Aleksa Sarai <cyphar@cyphar.com>
To: Christian Brauner <brauner@kernel.org>
Cc: Alexey Gladkov <legion@kernel.org>, 
	Dan Klishch <danilklishch@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>, 
	"Eric W . Biederman" <ebiederm@xmission.com>, Kees Cook <keescook@chromium.org>, containers@lists.linux.dev, 
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v9 4/5] proc: Skip the visibility check if subset=pid is
 used
Message-ID: <2026-04-22-cruel-dynamic-silkworm-tube-c9v0c0@cyphar.com>
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
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="zlm2b4gbowrplb5a"
Content-Disposition: inline
In-Reply-To: <20260421-duzen-laugenbrezel-e1d1138ff5ae@brauner>
X-Rspamd-Queue-Id: 4g1DWW3FPDz9swN


--zlm2b4gbowrplb5a
Content-Type: text/plain; protected-headers=v1; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
Subject: Re: [PATCH v9 4/5] proc: Skip the visibility check if subset=pid is
 used
MIME-Version: 1.0

On 2026-04-21, Christian Brauner <brauner@kernel.org> wrote:
> On Fri, Apr 17, 2026 at 01:03:46AM +1000, Aleksa Sarai wrote:
> > On 2026-04-16, Christian Brauner <brauner@kernel.org> wrote:
> > > On Thu, Apr 16, 2026 at 10:46:50PM +1000, Aleksa Sarai wrote:
> > > > On 2026-04-16, Aleksa Sarai <cyphar@cyphar.com> wrote:
> > > > > On 2026-04-13, Alexey Gladkov <legion@kernel.org> wrote:
> > > > > > When procfs is mounted with the subset=3Dpid option, all system=
 files and
> > > > > > directories from the root of the filesystem are not accessible =
in
> > > > > > userspace. Only dynamic information about processes is availabl=
e, which
> > > > > > cannot be hidden with overmount.
> > > > > >=20
> > > > > > For this reason, checking for full visibility is not relevant i=
f mounting
> > > > > > is performed with the subset=3Dpid option.
> > > > > >=20
> > > > > > Signed-off-by: Alexey Gladkov <legion@kernel.org>
> > > > > > ---
> > > > >=20
> > > > > > -static bool mount_too_revealing(const struct super_block *sb, =
int *new_mnt_flags)
> > > > > > +static bool mount_too_revealing(struct fs_context *fc, int *ne=
w_mnt_flags)
> > > > > >  {
> > > > > >  	const unsigned long required_iflags =3D SB_I_NOEXEC | SB_I_NO=
DEV;
> > > > > >  	struct mnt_namespace *ns =3D current->nsproxy->mnt_ns;
> > > > > > +	const struct super_block *sb =3D fc->root->d_sb;
> > > > > >  	unsigned long s_iflags;
> > > > > > =20
> > > > > >  	if (ns->user_ns =3D=3D &init_user_ns)
> > > > > > @@ -6388,7 +6387,7 @@ static bool mount_too_revealing(const str=
uct super_block *sb, int *new_mnt_flags
> > > > > >  		return true;
> > > > > >  	}
> > > > > > =20
> > > > > > -	return !mnt_already_visible(ns, sb, new_mnt_flags);
> > > > > > +	return (!fc->skip_visibility && !mnt_already_visible(ns, sb, =
new_mnt_flags));
> > > > > >  }
> > > > >=20
> > > > > Unless I'm missing something (I haven't tested this locally yet, =
sorry),
> > > > > this will allow you to bypass mount_too_revealing() even for
> > > > > non-subset=3Dpid mounts because once you create a subset=3Dpid mo=
unt then a
> > > > > regular procfs mount will see the subset=3Dpid mount and permit i=
t.
> > > > >=20
> > > > > I think the solution is quite simple -- you can also skip super-b=
locks
> > > > > that have fc->skip_visibility set in mnt_already_visible().
> > > >=20
> > > > I now see that check was present in v8 but I guess its importance w=
asn't
> > > > obvious. I guess this means we will need to reintroduce
> > > > SB_I_USERNS_ALLOW_REVEALING. :/
> > >=20
> > > I've been playing with something else. So first we should move
> > > SB_I_USERNS_REVEALING to an fs_type flag. It's not an optional thing =
and
> > > always set and never removed. That also means we can simplify
> > > sysfs_get_tree() to just kernfs_get_tree().
> >=20
> > Seems quite reasonable to me.
> >=20
> > > And then we raise SB_I_USERNS_RESTRICTED on all procfs mounts with
> > > pid_only and disallow using them for calculating mount permissions for
> > > unrestricted procfs mounts.
> >=20
> > I think that's fine here and is probably all we need for now (though I
> > think that the name is a little confusing especially given my next
> > comment), but I think there is a bit of a deeper problem here that
> > deserves to be mentioned if only for posterity.
> >=20
> > The core issue really is that we actually have two versions of procfs
> > now, and they are effectively distinguished by fs_context flags instead
> > of fs_type. Back when subset=3Dpid was merged there was a discussion ab=
out
> > a hypothetical proc2 -- while that got dropped, we are kind of
> > reinventing this split in an ad-hoc way.
> >=20
> > Conceptually considering them as two distinct fs_types would be the more
> > semantically correct thing to do, though I think it would be overkill to
> > come up with some framework for that. (I also really hope we don't have
> > any other filesystems where this is also the case.)
>=20
> Doing this is almost trivial. The problem really is that we'd expose
> "procfs2" or whatever as a new mount option to userspace without
> actually having fundamentally revamped what we would like procfs2 to do.
> IOW, it would elevate a security hack that got added a while ago to a
> new filesystem type. I think that would just be sad. So I'm not so
> excited about doing this.
>=20
> > This is why I think the name is a little weird, since it isn't an issue
> > about one procfs being restricted in a userns, it's that they are
> > conceptually unrelated filesystem types. A very lightweight version of
>=20
> I somewhat disagree because it's unclear where you draw the line. If you
> use the hidepid=3D stuff at its most restrictive where it only shows tasks
> your user owns you could also argue that it's very close to a separate
> filesystem type. It's strictly subtractive and so is pidonly. There's
> just nothing that's better or novel.

I agree that hidepid=3D4 is arguably yet another procfs subset (in fact I
was thinking of giving it as an example in my earlier mail) and arguably
should have somewhat similar restrictions. hidepid=3D1 and hidepid=3D2 are
not as extreme IMHO (since most /proc/$pid/* accesses are gated behind
ptrace_may_access() anyway).

One potential model here would be to have an opaque bitmask of
restrictions and only more-or-equally restricted superblocks can count
towards mnt_already_visible(). But again, I think we can add this once
we need it.

> > this would be making it something like SB_I_RESTRICTED_VARIANT that
> > would be more a little more strict than what you have now --
> > SB_I_RESTRICTED_VARIANT would not be treated as compatible with anything
> > (even another SB_I_RESTRICTED_VARIANT mount) so that if we add more
> > variants in the future we don't treat them the same either. (Again, I
> > don't think we need this now?) Of course this would still allow
> > subset=3Dpid without a procfs mount because of the other special casing
> > for it in mount_too_revealing().
>=20
> It's not a problem today. I think we can simply treat
> SB_I_RESTRICTED_VARIANT as not allowing other restricted variants. And
> we'd need a more elaborate mechanism anyway once we'd have "compatible"
> subsets.
>=20
> > We are also limited in what semantics we can change here too (and I'm a
> > little worried that even this bit for SB_I_USERNS_RESTRICTED is at risk
> > of breaking something) so maybe that isn't needed today.
>=20
> So I think yes, SB_I_RESTRICTED_VARIANT is fine by me for now.

Sounds good.

--=20
Aleksa Sarai
https://www.cyphar.com/

--zlm2b4gbowrplb5a
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iJEEABYKADkWIQS2TklVsp+j1GPyqQYol/rSt+lEbwUCaelMiBsUgAAAAAAEAA5t
YW51MiwyLjUrMS4xMiwyLDIACgkQKJf60rfpRG/V4wEA+87YzHhUE/Sf4D8kjqoL
TWegvIIyKjDA6Qpi/jiZOUAA/1fA4O3YFUBzFkoWDwZzkh82MMT1sFAfOoNi4SCj
0/sE
=Uvjb
-----END PGP SIGNATURE-----

--zlm2b4gbowrplb5a--
