Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.218.71
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793791834;
	b=C3ymZCQE8PUiItV36wfLugYh4eqdxeQ3PppvMUDnaYSD7DI3X88enXoWsYNVIEk32zSP
	 QgXIuqgV4jniLDrHN5E7c8oIiLJEAorOfzIuWBX85csNk20lafWxA2T7L9uIEXdngUU+b
	 8Oy1mYt6yaHv/1dXJbeAmmj3DFNQ/RecnZezioZumIUC+4Lk3loQFLUEParyKa6sJIre/
	 Ko9wpXU9NumlVCdn6dZHb44XRCfzmhKiJTLOcZmCCz4VlFfOpRehQpqMfTAPQUJAg6vy+
	 kxyzdcN9UQEgihzDluZ5WGZOdH/H6yuEk3ZvLz2zmnwzt30Z9Qn35/UZfSIMci1gGqA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793791834;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Received:Date:In-Reply-To:
	 Mime-Version:References:Message-ID:Subject:From:To:Cc:Content-Type:
	 Content-Transfer-Encoding;
	bh=12Z4lOF0jQfTB4x6+mhkZ27w3B4gOwwYBosLZfWaVjk=;
	b=CG9SJGseTkDdkqbGm8HN3SiMLPDRk6gvETUcoL2JiPDWG/C+I/S9fBHYDr0WbSBCaiq+
	 NdRvJTrshrTox4JmkWnaxuE0kqxLWb8BG5AEpSUraiZZfQMT7KogbCus0MZBNE0z98cNY
	 QwcpnYkA50b4UJ6aSV2goRm/77iba+5l/CRTgNQGPXM5+1jLc3R0Mb8C+ZLhNsRt3xbRo
	 t0kCCctkDV7M7SGQom30Y618uf4O47IVEY0MK2cuJgdwzOJb6qBg1EhkulB2na58UVdE8
	 cvN7uCt0RR2sTU7dXB4KL9AM6Imei05FzIS1VJcTqiQw4fJcFPBo8TMM15efnK7GOew==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=google.com;
	spf=pass smtp.mailfrom=flex--halg.bounces.google.com;
	dkim=pass header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=gUcLUqUg;
	arc=none smtp.remote-ip=209.85.218.71
Received: from mail-ej1-f71.google.com (mail-ej1-f71.google.com [209.85.218.71])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A81EF606A333
	for <containers@lists.linux.dev>; Wed,  4 Nov 2026 11:30:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org A81EF606A333
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--halg.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=gUcLUqUg
Received: by mail-ej1-f71.google.com with SMTP id a640c23a62f3a-c42f98f354fso102810366b.0
        for <containers@lists.linux.dev>; Wed, 04 Nov 2026 03:30:33 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20260707; t=1793791832; x=1794396632; darn=lists.linux.dev;
        h=content-transfer-encoding:content-type:cc:to:from:subject
         :message-id:references:mime-version:in-reply-to:date:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=12Z4lOF0jQfTB4x6+mhkZ27w3B4gOwwYBosLZfWaVjk=;
        b=gUcLUqUgWLgvEPIpszQLE1DGjq+/+1c7NRN7ccuNOjlW31M97xLFM4zic3JNpbWHFu
         IEsFCicb4F8pQRmCQYoFYhCn4L66cFcaYaNZtpD1torqqoBtJy4BHPYvIp0ay2LZPSNk
         RsP8wVw2OxMX/UmRB1OTrC5t6e58OplZ3QzQo4W1nQgjMlBDryTT1o5eGTn8U8FBwyfw
         5Bgn8QW1IJd7jrNUu3KZZsL99UlCAUuRHa/A1zq744sdDcB4bMlU3A52vK4ntUdCyJYw
         V4oLC0u3FRos6tNTHSqjEz8uH/Rzjvofz9G5y2qjWKEnA6ZG6rhTanqyoQGmIN/X6+JI
         HTsQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793791832; x=1794396632;
        h=content-transfer-encoding:content-type:cc:to:from:subject
         :message-id:references:mime-version:in-reply-to:date
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=12Z4lOF0jQfTB4x6+mhkZ27w3B4gOwwYBosLZfWaVjk=;
        b=g//kkpk/HPixzlMRR/FHWuYufok7nbXtwwyOYBO+VIGjEuZI+7IMq1Ivk/Hb5N/xKO
         3v+HLU1aUnwzJNsQeVIjErUPmhwnDAamaWvycdA1VIYGjWrh+3nE+dIVF0Q33VBnRLkq
         qtU8ltCIaGv7VOg/vnKbh/veelAFeMMXMO4wsI/qHgwwHCtVF+ZjRPkooNNvxkpcDACw
         E+pYJ0m8a4OYc0hR53FPjpexPjGs/qhEaQswz1c9fPAZ+JbZqVhpGXCEZGyNY1phT7qi
         /RxuScp1aV1lM4A44Gnck1MkPfyVafvYLtyE+hV3/vaYCImYDqXlMkgWGSSMPqk6vEtn
         kCMQ==
X-Forwarded-Encrypted: i=1; AKwUvBz1c95fWJ2LNjy5bW4briyUsu/xMs+fhONOX4QL/hHd/R+vwEwhGuRZKoDaNnto862IRzT9igWxE9y8@lists.linux.dev
X-Gm-Message-State: APuU4Z9Kzrszn04r2dIrFJJbVxj8kqtQEU/sPku1ilzk23MWBG+mPaqb
	F4wVmnLtxo867+tXP9C+DCSo8aN0hHKDGj3e0jJ1C+2tfRz1IqO2aMwM1Jvj9KHYsa2F/AcOUQ=
	=
X-Received: from ejbgw4.prod.google.com ([2002:a17:906:f144:b0:c3f:7129:4c10])
 (user=halg job=prod-delivery.src-stubby-dispatcher) by 2002:a17:907:18c3:b0:c26:22ae:b66b
 with SMTP id a640c23a62f3a-c4ca7aee966mr1382566266b.15.1793791831732; Wed, 04
 Nov 2026 03:30:31 -0800 (PST)
Date: Wed, 4 Nov 2026 11:30:31 +0000
In-Reply-To: <CALCETrUD4vh_iSHV7G0bprUFU8=c+ECo701-tXcbQ3UXBWC1ig@mail.gmail.com>
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Post: <mailto:containers@lists.linux.dev>
List-Help: <mailto:containers+help@lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
List-Owner: <mailto:containers+owner@lists.linux.dev>
Precedence: list
Mime-Version: 1.0
References: <20261028221705.3915340-1-halg@google.com> <CALCETrW9ygriu54gxiHFLEd5+hJminQo0r8Jwd63wR69Dj4W7w@mail.gmail.com>
 <auM32mOlBLu6ZUlt@google.com> <CALCETrUD4vh_iSHV7G0bprUFU8=c+ECo701-tXcbQ3UXBWC1ig@mail.gmail.com>
Message-ID: <ausXFWLgHabezE7R@google.com>
Subject: Re: [PATCH 0/8] userns: per-namespace capability bounding set and
 opt-in netns loopback
From: "Hallgrimur H. Gunnarsson" <halg@google.com>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Christian Brauner <brauner@kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, 
	Paul Moore <paul@paul-moore.com>, Serge Hallyn <sergeh@kernel.org>, Kees Cook <kees@kernel.org>, 
	"David S . Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, 
	Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, Jan Kara <jack@suse.cz>, 
	James Morris <jmorris@namei.org>, Simon Horman <horms@kernel.org>, Jonathan Corbet <corbet@lwn.net>, 
	Shuah Khan <skhan@linuxfoundation.org>, Randy Dunlap <rdunlap@infradead.org>, 
	Jann Horn <jannh@google.com>, "=?utf-8?Q?G=C3=BCnther?= Noack" <gnoack@google.com>, KP Singh <kpsingh@kernel.org>, 
	Jonathan Calmels <jcalmels@3xx0.net>, Casey Schaufler <casey@schaufler-ca.com>, 
	linux-fsdevel@vger.kernel.org, linux-security-module@vger.kernel.org, 
	linux-api@vger.kernel.org, containers@lists.linux.dev, netdev@vger.kernel.org, 
	linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, 
	linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Tue, Nov 03, 2026 at 10:37:48AM -0800, Andy Lutomirski wrote:
> On Thu, Oct 29, 2026 at 5:11=E2=80=AFAM Hallgrimur H. Gunnarsson
> <halg@google.com> wrote:
> >
> > On Wed, Oct 28, 2026 at 03:56:11PM -0700, Andy Lutomirski wrote:
>=20
> > >
> > > Why should the task's cap masks affect this?  *Maybe* cap_bset makes
> > > sense, but I'm struggling a bit to see why cap_permitted and
> > > cap_effective should matter.
> >
> > Sorry, the phrasing here may have been misleading. Just to clarify:
> > none of the creating task's capability sets (cap_bset, cap_permitted
> > or cap_effective) are used to restrict the new user namespace.
> >
> > When I wrote "reusing the existing task cap_bset, cap_permitted and
> > cap_effective sets on namespace entry", I was contrasting this with
> > the prior series from 2024 [1], which proposed adding a 6th per-thread
> > capability set to struct cred.
> >
> > In this series, when a task creates or enters a user namespace, we
> > simply initialize its new cred->cap_{bset,permitted,effective} in
> > that namespace to user_ns->cap_bset instead of CAP_FULL_SET.
> >
>=20
> Okay, this makes *more* sense, but I think it's too weak.
>=20
> I have a sort-of goal of having the creation of unprivileged
> namespaces be allowed in most contexts by default, *even in Docker*
> (which would involve the Docker team changing their default seccomp
> rules, but that bridge can be crossed later).  (In furtherance of this
> goal, I fixed an ancient bug in newuidmap that gets us quite a bit
> closer a couple weeks ago.)
>=20
> But tying this mitigation to a parent userns means that it's
> completely unusable in the single-deep case.

To clarify, this mitigation isn't exclusively tied to the parent userns.
If a system administrator wants a host-wide policy, like trimming
CAP_NET_ADMIN for all unprivileged user namespaces, including
single-deep Docker containers, then the host-wide sysctl handles this
seamlessly. Any unprivileged process in init_user_ns calling CLONE_NEWUSER
is subjected to the sysctl ceiling, effectively stripping CAP_NET_ADMIN
upon creation.

Where the single-deep case falls short in this series is per-container
granularity. For flexible configuration on a per-container basis, this
patch series assumes that containers run in their own user namespace,
allowing the runtime to bound capabilities at creation time via clone3()
and have that bound persist down the namespace hierarchy across any nested
userns creation.

If a container runs in init_user_ns (as in standard Docker) and we want
to restrict userns capabilities for that specific container without
relying on a host-wide sysctl, then you are exactly right. We would need
some kind of cred-based mechanism to pre-configure a restriction for any
future CLONE_NEWUSER calls within that container.

> I do have a question about this whole scheme, though: are we talking
> *just* about CAP_NET_ADMIN?  That is, is there any other bit that has
> anywhere near enough security relevance to make this kind of thing
> worthwhile?  Because if it's really just a single bit control, maybe
> we can come up with a nicer scheme.

Yes, primarily CAP_NET_ADMIN, and to a lesser extent CAP_NET_RAW.

If we look at submissions to Google's kernelCTF VRP [1], 90% of the
exploit submissions in 2026 require CAP_NET_ADMIN (and about 70%
across all submissions since the program started in 2023).

Restricting these network capabilities when they are not strictly needed
(e.g. for sandboxing) is the primary motivation behind the series.
However, I wrote the userns capability bounding as a generic mask so it
could restrict arbitrary capabilities down the hierarchy, but if the
preference is to narrow the scope more specifically to trimming
CAP_NET_ADMIN and CAP_NET_RAW, that's completely fine by me.

If we go that route and want to support the single-deep Docker case, a
per-task inheritable securebit might be one way to do it, e.g.
SECBIT_NO_USERNS_NET and SECBIT_NO_USERNS_NET_LOCKED. Docker could then
set and lock that bit on a container in init_user_ns without needing a
parent userns.

On userns creation, create_user_ns() could record this restriction on
struct user_namespace. That could either feed into the userns capability
bounding set proposed in this series (clearing CAP_NET_ADMIN and
CAP_NET_RAW from user_ns->cap_bset when the bit is set on the creator),
or be stored as a single boolean in struct user_namespace if we want to
keep the mechanism minimal and drop the generic capability mask UAPI.
In the latter case, we would still need to replicate some of the
userns capability bounding functionality, e.g. strip CAP_NET_ADMIN and
CAP_NET_RAW in set_cred_user_ns() on namespace entry, and bound the
parent-owner check in cap_capable_helper().

[1] https://github.com/google/security-research/tree/master/pocs/linux/kern=
elctf
