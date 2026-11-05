Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.remote-ip=209.85.222.179
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=fail;
	t=1793897301;
	b=fqnQz8p0MVaPhWM/GnpZ6V9vc3zIxsEi39hkvaLFs4qtMKE9bG+1JguhtIUS+Id9Eq5Y
	 gew1U5wv+9Gy3TWCp6jsBoUL1R/s/Fsw+Xg9QL1aqZ0Mt3xAlQrHK/uACtsx900m6XPrK
	 y/3XE9zCk3Ogb1adjaNSET8efuJgnbY8+HJ4Aqwkd9mEi6jrvjzewHiXzGcYG1UaKPdWo
	 9+GBRYWM2T6UyqPAgWKuTL3BhhEG8wuyCXfiUX09q4hDWnmfDOB0BCp8xev7aFqnMqeW4
	 UU1mWyfJz39yc7bHli6WcLuyaYylsD/mwuNHaqe4oXKIxAJ8rPLffewf+m3kWl2FoKQ==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793897301;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=VqiTrc04lJztf2dyTmHN89oGm1bJ8PUHM0btmGHDZmI=;
	b=11XQvVB5vJuYhcmBnnmX1ajtm2M3F+cb5Ol0bTusY+RXzm1ESOQbqpZhIA6WsR0dpoZx
	 6nn9cu7Ap95YbQM6wCzJQFeK5/SJMvTHkcExI5fJ1S84VKSJMha1lxpNkEo793j4vaFIF
	 dm5J2jlS1whMDFgZYne9u9F47MhD5OAxX0EAvs1Id7X9zQuI91ViT15xpKEesTx22uBcT
	 ImWJ+iCH8M2ifLCGUz3HQsRvovu589xwl+osJDvJD/sF3mSUHuQ0OKxz6M/U7GDaXWUdB
	 lGhUtpY248G6nZnNKrWz0LlTNEUFHyWnPP5HzAWmUfEC4V8l/KL5O5BwI+L3gtY5vFw==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=none header.from=amacapital.net;
	spf=pass smtp.mailfrom=amacapital.net;
	dkim=pass header.d=amacapital-net.20260707.gappssmtp.com header.i=@amacapital-net.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=gtuY7N1P;
	arc=fail smtp.remote-ip=209.85.222.179
Received: from mail-qk1-f179.google.com (mail-qk1-f179.google.com [209.85.222.179])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 350DB606A331
	for <containers@lists.linux.dev>; Thu,  5 Nov 2026 16:48:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 350DB606A331
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amacapital.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=amacapital-net.20260707.gappssmtp.com header.i=@amacapital-net.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=gtuY7N1P
Received: by mail-qk1-f179.google.com with SMTP id af79cd13be357-93e7ad9f78dso249304885a.1
        for <containers@lists.linux.dev>; Thu, 05 Nov 2026 08:48:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1793897300; cv=none;
        d=google.com; s=arc-20260327;
        b=PT3gGYwQONij/tG729B9vvHXEaLXB8vqmsX5PmasLqGTyok8i6GtE4WRtUeFfZSAhn
         kmKvblClPhSajtY4l3QGaaTZcO/Xf9Wj3eNES2D2yh57BEI317j0r2AvwqlCIaISDigT
         eKuwpFvMDz4RhM5zb6okhQH26SYy4uhwxtAsXqGueKB6ogCwlmZL4eEwmeO74ntbULaY
         WTdIBinBofdA9RN9q27kI+k5IOYpc9N2haTYqVKtFD4WOAlxjaaw9zIozqmQM4uSB9o4
         KaVpC3aFF9r6GB9wjKJb1U+H0hQKYHS7qwoubzngvLvBiXSNJUswz7X+LxK00G9aVrQq
         fqgA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=VqiTrc04lJztf2dyTmHN89oGm1bJ8PUHM0btmGHDZmI=;
        fh=xk+qkJfq9Lxk8i6bn4fbc+ZmzgB8jQv4tNY5MzXJ/iI=;
        b=HNSuo87tBCFYjBcEb27NPAHNM+yLH3Jkkjy8OAvExykuj106ftDLDXDM2gdi/1TiaP
         Kiv9PRxGvrIEAMPJa/lAH1CGPRNFsVfFgFOiMeXN6z80MNaZJZZhV3ryQzomX0ie4Dho
         IKiQCKZ0pdJpfSUGHExZfCi8hRcd93wyslTUTcHuD+hfCWf4QKg+Ix0cqI85CWxhRRAv
         x/ZbjW7XKOtr6mcPVeQM/bOKcfNmiACkPMp3tNf0Ud9JIoo2OelEY73ALZul7DvMY9xO
         Lrek8lybqRaKr8o7i2jIdCCNrAP34/1wrKs5sHbqj5nENTZZIpAJjxqBNCE3IB08z/1/
         BRug==;
        darn=lists.linux.dev
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amacapital-net.20260707.gappssmtp.com; s=20260707; t=1793897300; x=1794502100; darn=lists.linux.dev;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=VqiTrc04lJztf2dyTmHN89oGm1bJ8PUHM0btmGHDZmI=;
        b=gtuY7N1PeBMi7GshlSOLOfQzTpSS4gylkiZj5mHKbMMCXv6xEwIWOlAEubpvRNGGS1
         cvlHhRtH7xmVC+2MB9XvMgSepZ9HUokst9aao9ydKLg7Gmc41Binomkk9UPa9XdxERNz
         FdfKN456HvFWJhodhq+gJjQt2+NnO6J2+KfaTkb/N46EjpXlLlj2xvWsYRxC5p0z6xtM
         CNZZd/ELoAeuJW3/GTn0vO+PLGuIIxQqgY85L+7oVB1PtMM9TqJXBbPu6aDNqBUiZKUM
         MUuNdQJ3bWNnUb9DaKh8+plHgr39RE3Uuzcezkxr4UowPHxJ6Gy3sdEJTfGaKHP+cFZL
         ZAEA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793897300; x=1794502100;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=VqiTrc04lJztf2dyTmHN89oGm1bJ8PUHM0btmGHDZmI=;
        b=TS3zd/NNqKGUuy5ZFyKxucsCZnQqwAkm5ZM6XAjfYkU1g0LE8jb8z6w9HXxVpp9wXL
         D6yNnuLEDLp89AmijwTjfmw/WLCOjW8jR3d6CYpOmbs3n0YGkByTj3dRpl0ZEkUv+OWS
         6EGKOKsIl2W4tnC/+ukzcqEr3r9850udJYDcCFU5LvvrI/s/zM1QxV/PHc8sPYh4FUj4
         QPlH+kVjMyxJ9I7It8MTpSQTW/1W2W8+sG+v0QXP7I43MqeTRYcwa3e3L58l8Wsf6OBd
         YwkGCvTmoZc5Tt5jLyUaqLCUAqPMu9cOiw/AvzN5RaehPSF3WXx2Tdr04VfKO+7oI0pQ
         Sxfg==
X-Forwarded-Encrypted: i=1; AKwUvByhOIKck3AGVj7zh0GKyBFIR8KUWM7EFhXWJxSqP36Kj+dkL1mJ632y2lCkBH/DTTExYvBYSLqNbm+M@lists.linux.dev
X-Gm-Message-State: APuU4Z/fXkLM38npa9QMElI700khCClH1qBqSeCiz1Uni8F3Q0KPw3ta
	DImoolte0+DJ1fcLC2Oi0Fw5cKATRRbZqVCGGZQa2HPjr+qrMf4hraOsrtxmUKtumqqA8Zz0tbx
	ww6OnBePn4pYRcPP09zKT8jpQwBDaiRcfIHgqaFh6
X-Gm-Gg: AYBFou0sThMvPiSznwdcKTciXFzj47jJ2SsnQytowfLkaTqKCicjicHTA/AmrdNqOch
	S4X7bRDlmVetzhYQEAZv3O0v3r7F8ClNOIngqxDZo3186BFQeL01QlZ5K4X3ptqTQozPTfU6lOE
	KH7CpeQppifOHtK3J3po8ww3jPVVbUaNBf4+OuI9roV/AH0QRfCnkftFM9SlFJkCiszvidcoMUU
	O0penm2Tzzc4DEdBtvdX/TehBfqjfNrDRHCh+IQtuEl+gQVpsZ2yp6I4740D2TUj+lURke5iYvX
	9r/3mdj009Bz6rSxRcwDFGECJDXiePCrTI3Lfpfeb4tkBghUttOS3ZnemvqVYudo0XKXEwvg4u3
	yEho7mf/Z3/YrrEzFGVqNSIN6ot2Z+vHahG1o2BnxC5hQmK1cUXXBL7U=
X-Received: by 2002:a05:620a:29c1:b0:93f:334e:df25 with SMTP id
 af79cd13be357-9442175b2f6mr3556460685a.41.1793897300081; Thu, 05 Nov 2026
 08:48:20 -0800 (PST)
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
 <auM32mOlBLu6ZUlt@google.com> <CALCETrUD4vh_iSHV7G0bprUFU8=c+ECo701-tXcbQ3UXBWC1ig@mail.gmail.com>
 <ausXFWLgHabezE7R@google.com>
In-Reply-To: <ausXFWLgHabezE7R@google.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 5 Nov 2026 08:48:07 -0800
X-Gm-Features: AclHuK8CUFetL3KNjWElY9pamqV4vOzKRAOdGaRShI4zykg0vul-u3a1dyx4v8I
Message-ID: <CALCETrXrdQRWTVdCq-V_AVpZG7g=1aCpeyNP3jLXT7VDW=OaVw@mail.gmail.com>
Subject: Re: [PATCH 0/8] userns: per-namespace capability bounding set and
 opt-in netns loopback
To: "Hallgrimur H. Gunnarsson" <halg@google.com>
Cc: Christian Brauner <brauner@kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, 
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

On Wed, Nov 4, 2026 at 3:30=E2=80=AFAM Hallgrimur H. Gunnarsson <halg@googl=
e.com> wrote:
>
> On Tue, Nov 03, 2026 at 10:37:48AM -0800, Andy Lutomirski wrote:
> > On Thu, Oct 29, 2026 at 5:11=E2=80=AFAM Hallgrimur H. Gunnarsson
> > <halg@google.com> wrote:
> > >
> > > On Wed, Oct 28, 2026 at 03:56:11PM -0700, Andy Lutomirski wrote:
> >
> > > >
> > > > Why should the task's cap masks affect this?  *Maybe* cap_bset make=
s
> > > > sense, but I'm struggling a bit to see why cap_permitted and
> > > > cap_effective should matter.
> > >
> > > Sorry, the phrasing here may have been misleading. Just to clarify:
> > > none of the creating task's capability sets (cap_bset, cap_permitted
> > > or cap_effective) are used to restrict the new user namespace.
> > >
> > > When I wrote "reusing the existing task cap_bset, cap_permitted and
> > > cap_effective sets on namespace entry", I was contrasting this with
> > > the prior series from 2024 [1], which proposed adding a 6th per-threa=
d
> > > capability set to struct cred.
> > >
> > > In this series, when a task creates or enters a user namespace, we
> > > simply initialize its new cred->cap_{bset,permitted,effective} in
> > > that namespace to user_ns->cap_bset instead of CAP_FULL_SET.
> > >
> >
> > Okay, this makes *more* sense, but I think it's too weak.
> >
> > I have a sort-of goal of having the creation of unprivileged
> > namespaces be allowed in most contexts by default, *even in Docker*
> > (which would involve the Docker team changing their default seccomp
> > rules, but that bridge can be crossed later).  (In furtherance of this
> > goal, I fixed an ancient bug in newuidmap that gets us quite a bit
> > closer a couple weeks ago.)
> >
> > But tying this mitigation to a parent userns means that it's
> > completely unusable in the single-deep case.
>
> To clarify, this mitigation isn't exclusively tied to the parent userns.
> If a system administrator wants a host-wide policy, like trimming
> CAP_NET_ADMIN for all unprivileged user namespaces, including
> single-deep Docker containers, then the host-wide sysctl handles this
> seamlessly. Any unprivileged process in init_user_ns calling CLONE_NEWUSE=
R
> is subjected to the sysctl ceiling, effectively stripping CAP_NET_ADMIN
> upon creation.

Seems reasonable, but see below.

>
> Where the single-deep case falls short in this series is per-container
> granularity. For flexible configuration on a per-container basis, this
> patch series assumes that containers run in their own user namespace,
> allowing the runtime to bound capabilities at creation time via clone3()
> and have that bound persist down the namespace hierarchy across any neste=
d
> userns creation.

There are plenty of cases of *privileged* user namespaces (i.e.
created by privileged users) that would nonetheless want this.  Or
unprivileged user namespaces on systems that will not have this
restriction set that still want to apply it in their own container.



>
> If a container runs in init_user_ns (as in standard Docker) and we want
> to restrict userns capabilities for that specific container without
> relying on a host-wide sysctl, then you are exactly right. We would need
> some kind of cred-based mechanism to pre-configure a restriction for any
> future CLONE_NEWUSER calls within that container.
>
> > I do have a question about this whole scheme, though: are we talking
> > *just* about CAP_NET_ADMIN?  That is, is there any other bit that has
> > anywhere near enough security relevance to make this kind of thing
> > worthwhile?  Because if it's really just a single bit control, maybe
> > we can come up with a nicer scheme.
>
> Yes, primarily CAP_NET_ADMIN, and to a lesser extent CAP_NET_RAW.
>
> If we look at submissions to Google's kernelCTF VRP [1], 90% of the
> exploit submissions in 2026 require CAP_NET_ADMIN (and about 70%
> across all submissions since the program started in 2023).
>
> Restricting these network capabilities when they are not strictly needed
> (e.g. for sandboxing) is the primary motivation behind the series.
> However, I wrote the userns capability bounding as a generic mask so it
> could restrict arbitrary capabilities down the hierarchy, but if the
> preference is to narrow the scope more specifically to trimming
> CAP_NET_ADMIN and CAP_NET_RAW, that's completely fine by me.
>
> If we go that route and want to support the single-deep Docker case, a
> per-task inheritable securebit might be one way to do it, e.g.
> SECBIT_NO_USERNS_NET and SECBIT_NO_USERNS_NET_LOCKED. Docker could then
> set and lock that bit on a container in init_user_ns without needing a
> parent userns.

This seems perhaps better.  But maybe a bit that applies the
restriction to a userns created by someone who doesn't have
CAP_NET_ADMIN in their own userns?

IMO what we really want is a generic mechanism for sysctl-like
settings that are scoped to a userns.  And we would want the API not
to be filesystem-based (or at least not require *mounting* a
filesystem) because then we would just make everything messier.  This
would solve many problems.

>
> On userns creation, create_user_ns() could record this restriction on
> struct user_namespace. That could either feed into the userns capability
> bounding set proposed in this series (clearing CAP_NET_ADMIN and
> CAP_NET_RAW from user_ns->cap_bset when the bit is set on the creator),
> or be stored as a single boolean in struct user_namespace if we want to
> keep the mechanism minimal and drop the generic capability mask UAPI.
> In the latter case, we would still need to replicate some of the
> userns capability bounding functionality, e.g. strip CAP_NET_ADMIN and
> CAP_NET_RAW in set_cred_user_ns() on namespace entry, and bound the
> parent-owner check in cap_capable_helper().
>
> [1] https://github.com/google/security-research/tree/master/pocs/linux/ke=
rnelctf
