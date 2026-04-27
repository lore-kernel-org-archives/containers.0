Received: from mout-p-101.mailbox.org (mout-p-101.mailbox.org [80.241.56.151])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 25699279DCA
	for <containers@lists.linux.dev>; Mon, 27 Apr 2026 22:35:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=80.241.56.151
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777329304; cv=none; b=TKBrIFTHaRZUcoDkfRyBtmAWrBx3Qf3Ap3ufuqReG7gIGm3dY7mOWZuifuZATZKA9XJB1sCrLrnX+4vhEKmR2ZTE5rJaInY4savEVZ6kttjTsErqNbzgt1At/R03uLq5VOIKsZzt17R5ipPAh6k7WIf/fsu4/Re7ScOEBaLKOkY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777329304; c=relaxed/simple;
	bh=lp6S7Q4W9RI8f81IJLt4FqNSl7Wll17fOsQkKmPS0cc=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=bhwG+Rrg6ZnGp1YagOjvI/OImGdyaj6ZICQjtjkHMwumrJwlwFMWMdm60esyDs9K6p6GpJgnEcIclOan6AjJcG0SD+yOvu4+o8AlGDKmTcahGkvf2nU5/CM4I4xlmKUNvI5stvD3SNAAUmClgUb5LRCG9UN1xiztCCE7XyRDzvo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=cyphar.com; spf=pass smtp.mailfrom=cyphar.com; dkim=pass (2048-bit key) header.d=cyphar.com header.i=@cyphar.com header.b=zzOloM7q; arc=none smtp.client-ip=80.241.56.151
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=cyphar.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=cyphar.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=cyphar.com header.i=@cyphar.com header.b="zzOloM7q"
Received: from smtp1.mailbox.org (smtp1.mailbox.org [IPv6:2001:67c:2050:b231:465::1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mout-p-101.mailbox.org (Postfix) with ESMTPS id 4g4JKb6qmpz9tFH;
	Tue, 28 Apr 2026 00:34:59 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=cyphar.com; s=MBO0001;
	t=1777329300;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=lp6S7Q4W9RI8f81IJLt4FqNSl7Wll17fOsQkKmPS0cc=;
	b=zzOloM7qppfKMMtuJMMEI39+Wffw8nTfsiVaS6GixqvaLHAS7wwikeBqRBl0A3vuUob0gu
	I2EXbtnVjraZw0YE4lO1lNnXkQyQKu3BZKjrir0WCXYrzyBfKc5UGFTKBzP3vd9+SeVi2S
	BYV+ov4Ab6lFM3V8Axx5elH9jaaFW+zNKkHh+pbSTU9ViCTPeJ4/Ledg+wmAHmoVUbZgxD
	wUs1vQw+BTo7JpdRjnaV2RzeZa++Yg3ZsI0AU9e51UEqvNTJfrZH/Jy9zgfaAIfjmdAqFW
	Nh2+w6TQfUncOEcoN60uWHqckCMu6bHSsBj2/CzjKZ2OsDBidbX74vlH9G5+qg==
Authentication-Results: outgoing_mbo_mout;
	dkim=none;
	spf=pass (outgoing_mbo_mout: domain of cyphar@cyphar.com designates 2001:67c:2050:b231:465::1 as permitted sender) smtp.mailfrom=cyphar@cyphar.com
Date: Tue, 28 Apr 2026 08:34:51 +1000
From: Aleksa Sarai <cyphar@cyphar.com>
To: Alexey Gladkov <legion@kernel.org>
Cc: Christian Brauner <brauner@kernel.org>, 
	Dan Klishch <danilklishch@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>, 
	"Eric W . Biederman" <ebiederm@xmission.com>, Kees Cook <keescook@chromium.org>, containers@lists.linux.dev, 
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v10 0/7] proc: subset=pid: Relax check of mount visibility
Message-ID: <2026-04-27-icy-lame-pedals-lizard-1JFqEC@cyphar.com>
References: <cover.1776079055.git.legion@kernel.org>
 <cover.1777278334.git.legion@kernel.org>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="wgwy7sdqlg4y7yc5"
Content-Disposition: inline
In-Reply-To: <cover.1777278334.git.legion@kernel.org>
X-Rspamd-Queue-Id: 4g4JKb6qmpz9tFH


--wgwy7sdqlg4y7yc5
Content-Type: text/plain; protected-headers=v1; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
Subject: Re: [PATCH v10 0/7] proc: subset=pid: Relax check of mount visibility
MIME-Version: 1.0

On 2026-04-27, Alexey Gladkov <legion@kernel.org> wrote:
> When mounting procfs with the subset=3Dpids option, all static files beco=
me
> unavailable and only the dynamic part with information about pids is acce=
ssible.
>=20
> In this case, there is no point in imposing additional restrictions on the
> visibility of the entire filesystem for the mounter. Everything that can =
be
> hidden in procfs is already inaccessible.
>=20
> Currently, these restrictions prevent pidfs from being mounted inside roo=
tless
> containers, as almost all container implementations override part of proc=
fs to
> hide certain directories. Relaxing these restrictions will allow pidfs to=
 be
> used in nested containerization.

Aside from one minor nit about invalf, looks great! Feel free to take my

Reviewed-by: Aleksa Sarai <aleksa@amutable.com>

--=20
Aleksa Sarai
https://www.cyphar.com/

--wgwy7sdqlg4y7yc5
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iJEEABYKADkWIQS2TklVsp+j1GPyqQYol/rSt+lEbwUCae/kixsUgAAAAAAEAA5t
YW51MiwyLjUrMS4xMiwyLDIACgkQKJf60rfpRG/VuQD/UPsI24qwGwwXdLVWZyr3
Ho7Oa8rJ4AqYST3oMyGZWtABAMSTa2tsJV9JFcDqPhzE4BB5TERCr0fAiB3xx5uU
OXUB
=TF0D
-----END PGP SIGNATURE-----

--wgwy7sdqlg4y7yc5--
