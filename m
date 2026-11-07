Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.167.50
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1794077276;
	b=K1MkU3YG2t/hKM3DZffYHXfrxP1NH02Djs35Y7SRu19PJNadbLTRkLz46yjPJRDH52co
	 sFkMARupIOiTNbQWj9TmvTviI+WyQ/fwEwGSVYHNLUmKP74S7kIgGHKRf2Xs8rzKDYSXu
	 9ENQwXNOngZuw6ShRL7A+vFO32vC2/vi0hIVDRhkc3nPmp5VedzYhI3XdFlDaOkfEQrkT
	 B5QxCosgOBpcHqE5BnpaIlryt92hKBrgZfLp9gZ6Bo4QJrYHiPABq2viTI0amBOEN4xjn
	 9qT9Feo65dqfDxMrcaCDOES1Y3P85qY/iYE3Wk/XWOmbBMswgGJVzhpMcdkGSDdOdxg==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794077276;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=DWojXY4nDMT9rtwg6h/b477SwUuLPC3ITyeb/WPBYqc=;
	b=4Dzk4X21LfWTPlHs+ODRvr4JV1JYetsC+JdXllvo8XBm2Iz3Yzt69wmFwWFz8Byb5/rt
	 eO7L9vmJ82B7IFm/GRN+so+c3ZqOpiBSZsM23vhLPmyhEBNRULzAHbMjP1yukbbC+MQsG
	 mJhX+Ouf/uaz0EUGELv22Jz5YTK2rTOldxQuDQghMq8nxu4LivG482U8luZQAAsrQlfSl
	 lTmZ2kovBZqNYRRjqTkllxVCUPEuGzyHAbuu27QIzDVp3wkxRD/bR8vVCS6Uzs4Nzl0Bu
	 F/7atqs2uSN3vzxOBJmgS5oGdiGeZjgb6b6HioPjtZld3F5fCWSpxP2Nucz2s//M9/w==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=none header.from=amacapital.net;
	spf=pass smtp.mailfrom=amacapital.net;
	dkim=pass header.d=amacapital-net.20260707.gappssmtp.com header.i=@amacapital-net.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=gAVGj+Pc;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.167.50
Received: from mail-lf1-f50.google.com (mail-lf1-f50.google.com [209.85.167.50])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 02B61606A330
	for <containers@lists.linux.dev>; Sat,  7 Nov 2026 18:47:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 02B61606A330
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amacapital.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=amacapital-net.20260707.gappssmtp.com header.i=@amacapital-net.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=gAVGj+Pc
Received: by mail-lf1-f50.google.com with SMTP id 2adb3069b0e04-5be3ed646a5so1981463e87.1
        for <containers@lists.linux.dev>; Sat, 07 Nov 2026 10:47:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1794077274; cv=none;
        d=google.com; s=arc-20260327;
        b=JFhX8rXqMNONTgFBiwJVGFHpQGID/qCC3/3QA/k0FW+4fEzZ/QXiL6gW5YRYyFjgzC
         aQXWazh1iqQtl1scaJXHFZK0Ilg8rhFC/PXqWFvZU8JbMlofZF7XcKDClnJ8uv2RHZQ4
         vHH5n7+8M2o5vcS2jOnxqyjC0TWVj1nffqSpFUdx4z07MUS9RCs4H2b1V4D/w8wYZydR
         +K1q+Fxsb2nM4DrKVbNpvvuXriPN7xDiCHQe72iMydr/5AMFj7atroqH0+2+8jW/V+fN
         3Iv4beQ5rAqrBbLsI+070cPa4cU08ksHxWi4dqR0UKgLDGJ5k3THGWQ8/nNimAZaytdf
         RTlQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=DWojXY4nDMT9rtwg6h/b477SwUuLPC3ITyeb/WPBYqc=;
        fh=aK0dR/z3jweDVidYvrliQqd6v8IpO3cYebV0xNbyfBM=;
        b=SB2g8y2MjxWh4MkPktRkL5VgbqX1dvxZ35XiVzsNaX2G9Q0FModQVb2C08j3gv/mLr
         qCPBkM8/1zHU62NwuV/RsqY36990mtND18nW0xuYT9NLhJ4VFyd/g/7x6Ay0SeLs3ONI
         iByWZLDdww11gNhoNvb3LByZHF4v/08FPHL6h2VeKRVVJDIsh6erDvm5iooHdHzrIYCg
         5qJOB6bhRNnftryUNFmfqQZWIXEE6XcHf8ac50KENTT7VDD3M8ymxyi/HKIZ0D4WjeTh
         GQaR5J/Vk7NftWQYay+bdn8H73qSH6Q/GcXOvUvX6taP2T4ipeaVwdmV2B4yFCFOhmpz
         GueQ==;
        darn=lists.linux.dev
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amacapital-net.20260707.gappssmtp.com; s=20260707; t=1794077274; x=1794682074; darn=lists.linux.dev;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=DWojXY4nDMT9rtwg6h/b477SwUuLPC3ITyeb/WPBYqc=;
        b=gAVGj+PckLlMxh6ty+VxbbEi1fRd6Ek4quRANdxJnxiZ0r3IPvSVr62IJjmt4vwWRP
         qV0zq2EwoWdhG9WpjAIBvIf6/ZWNVtjXvsklFE4ZGPpVQJEK2tUCKVY9nr3dgslehBmU
         5G0OF8eWZaLtItNYrFLP+OxHcaWoYHx5E+cae/7uUvyjuCtEnb57RxKtwQyuUKhLI9qA
         rbGVAtglchFCO00dtu4fZUJ3YpLAcVYCt17CW9/8nboZVUrUdjYYpcutbqUJwMPne3qL
         FJUM0W0b/PxVKmUdGx89KGpZHXiuoawCGgYFwEiw3iqGvGM0K3NqrYjv88GKCi/ib/Vg
         jyjg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794077274; x=1794682074;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=DWojXY4nDMT9rtwg6h/b477SwUuLPC3ITyeb/WPBYqc=;
        b=es5COoERHG/ph6jEwIdF1E5AVT3wMbxxWP1iFvzMg3loVI2XHE1w1F3Gi96jhg9q/t
         v1/by+u36HKe/ggeQpPOjuJ4wBcJCKzqFrrIlqKFB31T+1k38IPMpadmb+dNiNUryElZ
         07+Zc20UOHDmwkfLyLR3eDnNY4qQ+fync/CR+Mfg76DoPYOV4o5awRx1Qmfip3A8rSvK
         tYvIy0RBAvA9Xpx1hi3Kr8skLDk0/yQHgWNk9TNFEUfNFpLKENZ6s8EXIK0REkPdw2Hq
         RTGl2mOS5mIgzkVNLU8v0dmEngxiMe4i7XhCH24W3H872Nb6yVayjxpgIzWROwB7FBo+
         mv+w==
X-Forwarded-Encrypted: i=1; AL+hErGMYOyKM+kFOzy/AERfYI/kQr2ph3970R3Qv/yyGN/lEipuzA4PSeUjn3R4t8JumeanU0jfI+Ydz0SS@lists.linux.dev
X-Gm-Message-State: APuU4Z9tULlBw8mk7vEGvHKufrZsrV19RWHe6Q/c/e6peh0B2VMWHgau
	jBDQYQrjLXSCGk2dhmfEiB3jOphXZf2wgc8i9JQMDglIRb3ySqzngGAmZb5ysm2sygm+XKD6Ihb
	XGB9hY89oAKMMrwg08Fi5HEQ2ddsFdWEoS9FAXHW6
X-Gm-Gg: AYBFou3RI+XLPIIg1YO9Rsh4hn9RWITHInfdsq29WW4MuG4ju1E6fmzSqvA93908DzL
	lIRlB6iSyNalDNRJEX17lHSgg9mfS6Qk3vJyFydjRR3fPTuvjgghEK2q7RoLHqhuB9tkCtir4+u
	Bg/aSuaR+HRamxet3y4wqqyQAlY//9HR9uWC18F4JY8PhFUQLT0XZB9CVh9uMh5RbGH16h+mTQW
	AuDPHrVE2zA5udj0m4nEgu7oidG5XKrAQiMRmQjbumORS0MxlazEXu5T0lDbgN+nvtkw+0sDMMx
	zQOlHfkUXAv/Fbh1/Icz8bSQuc4Ok9LRr9mXTdOxVnVmsJsxxMWfhtZCx7+G1x8Ig0LoDfw8agm
	FYjGVNebjjRU/Vc3XwZ7y8PjZ2+c7EhYekw==
X-Received: by 2002:a05:6512:291a:b0:5c0:ca1:9dd7 with SMTP id
 2adb3069b0e04-5c00ca19f2bmr594320e87.35.1794077274068; Sat, 07 Nov 2026
 10:47:54 -0800 (PST)
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Post: <mailto:containers@lists.linux.dev>
List-Help: <mailto:containers+help@lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
List-Owner: <mailto:containers+owner@lists.linux.dev>
Precedence: list
MIME-Version: 1.0
References: <20261028221705.3915340-1-halg@google.com> <CALCETrW9ygriu54gxiHFLEd5+hJminQo0r8Jwd63wR69Dj4W7w@mail.gmail.com>
 <20261106-befreien-addieren-eislauf-e09212803534@brauner>
In-Reply-To: <20261106-befreien-addieren-eislauf-e09212803534@brauner>
From: Andy Lutomirski <luto@amacapital.net>
Date: Sat, 7 Nov 2026 10:47:41 -0800
X-Gm-Features: AclHuK9s0dgg3FDVqp4WbjYQnA0hebDpEpxOAgz_VjLjRP_HfRjeTpRH9DX274k
Message-ID: <CALCETrWa1SBLcb5oWjqjgzZvKvCoHjmYFk=Lf5ytEM9uqm5jYA@mail.gmail.com>
Subject: Re: [PATCH 0/8] userns: per-namespace capability bounding set and
 opt-in netns loopback
To: Christian Brauner <brauner@kernel.org>
Cc: "Hallgrimur H. Gunnarsson" <halg@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, 
	Paul Moore <paul@paul-moore.com>, Serge Hallyn <sergeh@kernel.org>, Kees Cook <kees@kernel.org>, 
	"David S . Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, 
	Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, Jan Kara <jack@suse.cz>, 
	James Morris <jmorris@namei.org>, Simon Horman <horms@kernel.org>, Jonathan Corbet <corbet@lwn.net>, 
	Shuah Khan <skhan@linuxfoundation.org>, Randy Dunlap <rdunlap@infradead.org>, 
	Jann Horn <jannh@google.com>, =?UTF-8?Q?G=C3=BCnther_Noack?= <gnoack@google.com>, 
	KP Singh <kpsingh@kernel.org>, Jonathan Calmels <jcalmels@3xx0.net>, 
	Casey Schaufler <casey@schaufler-ca.com>, linux-fsdevel@vger.kernel.org, 
	linux-security-module@vger.kernel.org, linux-api@vger.kernel.org, 
	containers@lists.linux.dev, netdev@vger.kernel.org, linux-doc@vger.kernel.org, 
	linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, Nov 6, 2026 at 5:13=E2=80=AFAM Christian Brauner <brauner@kernel.or=
g> wrote:
>
> On Wed, Oct 28, 2026 at 03:56:11PM -0700, Andy Lutomirski wrote:
> > The whole unshare/clone flag situation is getting out of hand, IMO.
> > And this new thing makes logical sense but is really about reducing
> > exposure.
> >
> > Perhaps we should instead have a small list associated with a userns
> > (extensible in the future) of things that the ns's admin (i.e. whoever
> > has CAP_SYS_ADMIN relative to the ns) may do.  That list could
> > include:
> >
> > - Create loopback with sensible defaults for ipv4 and/or ipv6 (i see
> > no obvious reason to separate them)
> > - Create tun/tap interfaces in that ns (and attach them, etc)
> >
> > And add a very simple new API to do these things.  Actually, the
>
> We've had this idea in the past and I think it is reasonable. I had
> always thought that we should expose a system call to create empty
> namespaces ot any type. Usually I'd be excited about that but I think
> that point is a bit moot and I'd really like see whether we can turn
> cells (or whatever other name) into a first class api.
>
> The problem I have with the patchset as written is that adds a lot of
> moving parts. And yes, I find the CLONE_* and UNSHARE_* flags plus
> sysctl to be suboptimal as well.
>
> So the TL;DR is that CAP_NET_ADMIN + userns =3D
> CAP_NET_PRIVILEGE_ESCALATION 10+ years later. And this patchset wants to
> put it back on a leash.
>
> So why isn't an aggressively stupid solution to this problem to split a
> new capability out of CAP_NET_ADMIN so it covers the absolute minimal
> set of things that should be allowed instead of doing effectively the
> same thing but split over multiple apis?

Because we don't actually have a clean way to make a list of
privileges that are, in theory, harmless but are hazardous from an
attack surface perspective and assign them only to tasks that ought to
have them.

But maybe we should invent such a thing.  It would be very, very nice.

Other than that, I agree with you.

>
> Anything that is reasonably advanced should not be the kernel's
> responsibility to delegate. I really think the old privilege model where
> the kernel grants control over a whole subsystem is inherently flawed
> and is much better replaced if you have the means to let userspace
> services grant and delegate resources.



--=20
Andy Lutomirski
AMA Capital Management, LLC
