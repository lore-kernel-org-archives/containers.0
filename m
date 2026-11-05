Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.167.41
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1793897971;
	b=ZJUht8hR3T4EvlBLdrJcdk5LHLOkmjnYwboHginfIqm0vsuGu4mPE6iVQNMVngPj8pMd
	 2V77ESzEmnN2zMPKNYcBP++pSzyaYsPCQr2IQI1gjkon8FntbjD1WvyUx6w7MoeqR24yQ
	 v1EhDLu76WtcocZJAJXfqrD3P7LyhkZbDTCMUruqiYLPBeju78bp+p1kqNC7HYkjIKqZR
	 bQ5n7wOSTWDSFxjMzNx2SG0JRlNG9ybyJKyUy/nbavh5Q6wH0OAXIP7WpG7rl9ygfluU2
	 3gHC1T7pB4At5e2dgKGkoMJB6wriUJ/bvPGTlqSpGqaDXU9Mk7ooUqYzqYgYbI1ao5g==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793897971;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=ENTWrgdqNOnhBXm7Ydoc9z3n/Zlmn8Dt6MNiq3/7nzs=;
	b=idsEG/WVYgLidCY/OCSsDz7SACZRfLSNBbPSPeNYb/0WVqRZmYT++nhHsmvpPNX2iHsS
	 aKGXxPwTWzyrOdwSUKuxS7Vxvo0kDA5jpkhCXxxxq4LE0FzlTpZ30AsUHKO34KN4GYmQL
	 G7p1BkyXVREbUX2Y22pcvA7aVuY5exD0YNSeXyx1s02cn/aSCr8DnLNNE9U+9GBaeuYCt
	 SaS8LsYkZB40qcMwDd6wp92Uix8WJz2G+xY7Yc2hd5m/fKkGWSXen6mnLMCZXBsNBQPPE
	 8oa2u1iKQeZuTjYMMZN+S8/wvNLLNI8fiKW1mRJMvdCaMsWHleokVx5uPaifgr/q1KQ==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=none header.from=amacapital.net;
	spf=pass smtp.mailfrom=amacapital.net;
	dkim=pass header.d=amacapital-net.20260707.gappssmtp.com header.i=@amacapital-net.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=XbPZYzmn;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.167.41
Received: from mail-lf1-f41.google.com (mail-lf1-f41.google.com [209.85.167.41])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 66DD2606A32C
	for <containers@lists.linux.dev>; Thu,  5 Nov 2026 16:59:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 66DD2606A32C
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amacapital.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=amacapital-net.20260707.gappssmtp.com header.i=@amacapital-net.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=XbPZYzmn
Received: by mail-lf1-f41.google.com with SMTP id 2adb3069b0e04-5be416e603cso1459002e87.2
        for <containers@lists.linux.dev>; Thu, 05 Nov 2026 08:59:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1793897969; cv=none;
        d=google.com; s=arc-20260327;
        b=qAlWzHiTt2imFCanKryengiOpW2GcKUH+6FgBXX5vjmta2Wg3oKIMG+imtKKgC/6K8
         TKUKZcj5danVqspjvJhxvPk4qsW7jiUvUuuUX1NqlqvwtKgZipsm5MLEbfWB5ETJ7WP1
         wTzdHdocBlg8gDk/gE8a35ROIE77g59EpYQN5CixWUX81n02ztHk5e3k0pBA8OHMd+98
         /6y4XUEqrYv0S/tJq2MasiVPbUGNRZkq/KQpTYI7wxEwjffFEwKb0ZvG1WiKDVFW+DXD
         W1Pb6viwOczxKNszcXxFQWaTZ2VonCrvdOKBod80YHhap4n/PhPAI5YQYK7nz2wkHs45
         V2rw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=ENTWrgdqNOnhBXm7Ydoc9z3n/Zlmn8Dt6MNiq3/7nzs=;
        fh=jWEkxGQhyPK6yM6cRVhwTSJHaD+gH75LNvcktl0QQ5s=;
        b=BodxuwJwcCW7lLxaamWhYkWhRFPX+XIZTCwEi6iekwy8CHdg2nrO4h2GvqZuW62DP5
         xDf3S1D9kjCtf90O9zWPHtMfIG2ocIHRiBIIMzUqLYqxO4lc3mVwAimntKbIZYVaiRV5
         Pgz95aK69EuVMN2UcmFzZKeFUa+6VVagOLekvOhClzgj2qGSvVLtaZZxAbODgkIrx85C
         G145Wau0f4uQOozTdSS9hV1rWn88RdR2odfWyUKp0+sBkw7ZBcCqz8WzGaxd3pUUawp+
         2W5bMNh/h1m7RHJ9H2D83Jpn+9thW0YC8bkwHXm27CcrYQDPJrLq1XaA7KnKyLlWOSRy
         610g==;
        darn=lists.linux.dev
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amacapital-net.20260707.gappssmtp.com; s=20260707; t=1793897969; x=1794502769; darn=lists.linux.dev;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=ENTWrgdqNOnhBXm7Ydoc9z3n/Zlmn8Dt6MNiq3/7nzs=;
        b=XbPZYzmnO1azGVJkjETTm3PKj3lYameII3LwMz3hzRzLKsLKg7LJrpBydDWn9RRq87
         +/i7KEkw4itUOQrYgYGI0zsWbJRN2/Oo9djyg8G2l8hbitmN1sVU2s4j7dMkyTsa71X3
         qrqiLVhwZuwktUcFXdfQaXDc3zMkF7H25m+5uDaNMRey4bkpXQeMlbFZkCF9GFSbGbx4
         SOCP5SdGt2O8hXIrJ1mLX7ijqFfPds6ni+GrOAkJ9Sst4fKVUPstXWKjqv5TqNTY9K43
         Z/yB7vTxx8QvIofyz4jMk8d127DIbXgUGYOVsS0Ly9PckZlsX6Oa5sJhB/AWqhI0yLpQ
         MP5g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793897969; x=1794502769;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=ENTWrgdqNOnhBXm7Ydoc9z3n/Zlmn8Dt6MNiq3/7nzs=;
        b=pF6aRsvqARXeRFnXDuL6HtQwGsD3G+c/AguC3jXcwBJl8d8Thwt/vwvCH2byxmtpE0
         CIZKU0tesCmUFmCZ1xSZx37R8K64qc5aYWs2fSq/sbc7GP6PsbiCabdxLuT8CoYsiFO3
         zDYRLUkfxx9cN6YGtEuRWd4pDFD6tESOvRw03W6wN1nQAhgSSSCNJml18UrczpKDFfyI
         UXVnU+53H1Lgr+TF2nmf8v+1NVMXEmbQsa5x3qLuzF5paw6NbrfIqhYao51kaW38scQc
         tTHSXE+nx4VauXldY39G7ND6Qh/aLN57JKEBqJP+cJvkbTWs3KTNGS2/VllXymMWf/XP
         TLqA==
X-Forwarded-Encrypted: i=1; AKwUvBw0Yb61fsZKMWcQ47amXGFC1tR/ROISfkgwnCVcAxxt2pRql0sNb0jO5p/nqoTI7uY+sUBSPtas/17G@lists.linux.dev
X-Gm-Message-State: APuU4Z+nPHrxBEIwfLW0dAtspOykoBzD1BYCmkCZKg9nnvWE+fFJY4Ma
	WyaZ+4NgXouaM4TgLgoEt+npSrKnYgaJV40J6ijtkg9b2nhK+0h3PXYGpszr0DLHh9kA21YjBSj
	fDyGY0z5dNhJ2ImOW2iH9jgr2EL4Lw8JvkXUn6IbX
X-Gm-Gg: AYBFou3xVEE1aZXtR/8j+qsFA340i+RkgBFY6I232EovEPgNUIMx4pHXWx64O40foAX
	w6++TubZ9Hm1DSZIz78/m/NgbS4lWa7W7wMmmZZy1ey8nL0fs2bTrAwo/4FQQ8bLhdPlDQh81CO
	gPAWF/88r8M2YPQNoGDS9iEYbTUaDpsyWM+qeq9G+Eh/S2YyD2S+Inx32QaGfYtHggtraSi7Kb0
	hwk7iyA7jB6Y5Z3n0WQT3QFIkHZ6vPNFrhISaCtadw9XcdniXPO0BXRAiq5b2lgkorOFnR2+tam
	dehbMwN+U1odmHVCzhNxwe+amytbAzyXg7hjLAQT/AnrquXWOgYb8uLFLcPEvWdW08/cVZ5S2/T
	KYtqhiJTXP/0y90OFIw2bn4om+WiMyACO8A==
X-Received: by 2002:a05:6512:3e1c:b0:5b8:f97f:7a22 with SMTP id
 2adb3069b0e04-5bfd957683fmr6945728e87.54.1793897969539; Thu, 05 Nov 2026
 08:59:29 -0800 (PST)
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Post: <mailto:containers@lists.linux.dev>
List-Help: <mailto:containers+help@lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
List-Owner: <mailto:containers+owner@lists.linux.dev>
Precedence: list
MIME-Version: 1.0
References: <20261028221705.3915340-1-halg@google.com> <aunVmg42/S2uUDWR@hallyn.com>
 <auyink594bxptAPN@google.com>
In-Reply-To: <auyink594bxptAPN@google.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 5 Nov 2026 08:59:17 -0800
X-Gm-Features: AclHuK99RUxjga4Yt7Cih1iKUoXn780fqABuH5tRHwVrGa5--KTUob_Z762ltig
Message-ID: <CALCETrWaFf-X-mD0moxqaqEDWOV+85geK2B2Rs3ArixKd=Ntfw@mail.gmail.com>
Subject: Re: [PATCH 0/8] userns: per-namespace capability bounding set and
 opt-in netns loopback
To: "Hallgrimur H. Gunnarsson" <halg@google.com>
Cc: "Serge E. Hallyn" <serge@hallyn.com>, Christian Brauner <brauner@kernel.org>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Paul Moore <paul@paul-moore.com>, 
	Serge Hallyn <sergeh@kernel.org>, Kees Cook <kees@kernel.org>, 
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

On Thu, Nov 5, 2026 at 7:48=E2=80=AFAM Hallgrimur H. Gunnarsson <halg@googl=
e.com> wrote:
>
> On Tue, Nov 03, 2026 at 06:37:46AM -0600, Serge E. Hallyn wrote:
> > Generally, if I, or some users I support, need to use unprivileged cont=
ainers
> > or user namespaces, then when an 0day comes along, I can hopefully trus=
t them
> > not to exploit it.  The biggest danger comes from the fact that, right =
now, if
> > they can use them, anyone can.  So if someone can trigger some other co=
de running
> > as user nginx or something, that can become a root vector.
> >
> > So what if we had a built-in feature or LSM which implemented a credent=
ial based
> > whitelist, entered at firstboot?  Something like
> >
> > ```
> > # Default deny
> > uid =3D=3D 1000  # approved
> > 1005 < uid < 1010  # approved
> > gid =3D=3D 1005
> > security_label =3D lxc_user_t  # Not sure how far we want to go with th=
is
> > tty # must have a session
> > ```
> >
> > Now, if you want to use user namespaces for generic sandboxes for all
> > users, e.g. to confine browser activity or nginx modules, then this mod=
el
> > may not fit.  Or rather, it might need a few tweaks.
>
> Thanks for taking a look and sharing the credential-based allowlist.
>
> The latter scenario (generic sandboxes for all users) is actually the
> primary use case that I'm targeting. I want to allow unprivileged users t=
o
> create user namespaces, e.g. for sandboxing, but without granting them
> security-sensitive network capabilities (CAP_NET_ADMIN/CAP_NET_RAW) when
> they are not strictly needed, given the historically high risk of local
> privilege escalation associated with them.
>
> The two approaches target complementary layers of the problem. A credenti=
al
> allowlist at creation time controls who can create a user namespace, whil=
e
> this patch series controls what capabilities are available inside that
> namespace (and its descendants) once it is created.
>
> Gating creation works well when there is a clear boundary between trusted
> and untrusted users. However, in a multi-tenant environment (like a large
> container fleet), we generally treat workloads as untrusted by default.
> Because we still want to allow these untrusted workloads to use unprivile=
ged
> user namespaces for sandboxing, it is essential to keep the attack surfac=
e
> small and follow the principle of least privilege whenever possible.
>
> More specifically, this patch series enables that model of safe sandboxin=
g
> across three key use cases:
>
> 1. Configurable capability stripping: Administrators can enable unprivile=
ged
>    user namespaces for all users to support sandboxing, but configure the
>    system to strip CAP_NET_ADMIN and CAP_NET_RAW by default in new user
>    namespaces created by unprivileged users. Basic sandboxing rarely need=
s
>    these (except to bring up loopback, which Patch 1 addresses via
>    CLONE_NEWNET_LOOPBACK).
>
>    The per-namespace bounding set can enforce this either globally via th=
e
>    sysctl, or explicitly via clone3() at the container manager level. Thi=
s
>    restriction is monotonic and persists down the namespace hierarchy.
>
> 2. Selectively granting CAP_NET_ADMIN: Some containerized workloads
>    legitimately need CAP_NET_ADMIN to configure advanced networking for
>    sub-containers. Because an unprivileged creator's child namespace is
>    bounded by:
>
>      parent_bset & (sysctl_ceiling | creator_effective)

Right after sending my last email, I had the following thought of a
variant of the model.  Permission to gain CAP_NET_ADMIN via creating a
userns is kind of like a capability itself, right?  We could get
pretty close to nice semantics if we allocated a capability bit for
this (CAP_USERNS_NET_ADMIN perhaps?) and, by default, giving it to all
users.  Unfortunately, the latter part is tricky because even sticking
it in the ambient set won't keep it from being dropped by setuid.

Perhaps we could have an extra capability mask that is for default-on
capabilities.

The intuition for this is that permission to gain capabilities in a
userns is a mess if it's a sysctl (as sysctls are global and there is
no clean way to say that a particular unprivileged task may
nonetheless create namespaces with CAP_NET_ADMIN) and it's a mess if
it's a securebit (still has the latter problem), but it's much tidier
if it's tied to a task.
