Received: from mail-yb1-f170.google.com (mail-yb1-f170.google.com [209.85.219.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D90151836C1
	for <containers@lists.linux.dev>; Wed, 12 Jun 2024 17:29:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.219.170
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1718213361; cv=none; b=emkwder8EH0+e9clYzjd5/MUYp3fD2UYBGvoZ38TH9vmFZqnnkN0itR2+c8vAab0fLPMld0OXmXwvv0zGAZhtdIYiRHYWlLovISuVwfludVXZWsC76UQvNsmbo/bobbzMZHXdgUSSkf+9v5W3QCiScaJyf6jD+djrCBCfkS8Lgs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1718213361; c=relaxed/simple;
	bh=SqHXwxyX0hOMrGyXlbcSlWw9tiq1bd472LhKjNZO0j4=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=DT3upuRFUVuAHRJKiXIlPfYVG+XRHbWeA4VNrAJBF0oyif4BlJbMCJS3FH8CXKGkrxUPkOWBinfBz2rCHdpUpipwyzv4PqBngLNe78jgHpA+q+6oRaoOFune4mTjeYJ/ScWV1ejTOWJye5rkRYpVRmYsE1J7foA1Gs5/zbTXr9o=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=paul-moore.com; spf=pass smtp.mailfrom=paul-moore.com; dkim=pass (2048-bit key) header.d=paul-moore.com header.i=@paul-moore.com header.b=H2g1Z6G9; arc=none smtp.client-ip=209.85.219.170
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=paul-moore.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=paul-moore.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=paul-moore.com header.i=@paul-moore.com header.b="H2g1Z6G9"
Received: by mail-yb1-f170.google.com with SMTP id 3f1490d57ef6-dfe398bc50dso109734276.2
        for <containers@lists.linux.dev>; Wed, 12 Jun 2024 10:29:19 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=paul-moore.com; s=google; t=1718213359; x=1718818159; darn=lists.linux.dev;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=60lvPuusqxavVhRXfVcmrSoiIVupdLi0rpCh21972os=;
        b=H2g1Z6G9aGQhxqL2w9GoooUhnXZjFmdU0HauGpD0WgyiELvLsH407YMj5t0mNTfTix
         fKFWX6xP9IqHsLB3g0EjWBLW0grniV/R7UBAZJ9M7qkWJKk6jt5OH/sDpyq6G2uimOa9
         kXxQOpFukHvTS6mRIRG1liEPPOq1bcElo6B1NAaMRKAjnXm2kAJzk7yGdCfqeXCC2p0K
         2BPAyUDLt8gp3Ld9my2dq5mJMACoxuhGQ14I4q22IAZ76ivGMduTAuWLG9mzVAeMNaav
         GvX3KNpM3qNGzgbHVb+f7qqKzG17R3qNsYfyeLPKT+q2CurWGy4zMxoV9eNXZzm+ysV+
         lMrQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1718213359; x=1718818159;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=60lvPuusqxavVhRXfVcmrSoiIVupdLi0rpCh21972os=;
        b=au3ooLQTNmh1WVockGoK+1PGQ2aI2Jo7DKM3f9TP82WMHZwmsSDLKqxwxfrOjmc5tu
         u9HOwOc4g0B66JXoMr4iKlmOJ31+Cd6k2XKEaX4NH6ruEVlSzgmC7cF57fzS030v+dLD
         o6xY399GbHKBK15nUQNSfAYXkyfp+G+acTg2psInsaWLqCH2WT7nIL2OysthPLtIDS0E
         OPfdlm9VKSPUORDznPOz29cBLtlP/DqQSSz3gUzryG4JdrHhCk1ZMPz3N0cR2f+lZDVT
         bXKd5HNANKKt1+NfNQ/gAsme4Da2SDXvurj5md82SSDdpRq6XzRHRLa2QeYWTUAWy7qM
         dx1Q==
X-Forwarded-Encrypted: i=1; AJvYcCUmOdau/DZEZeUsK4NZhQ7pHXA1XKyHCt5PURTFo8mAoFuh/E5RpVusU3WV1PwLEW+IjLFttPwSmQ/vHVCui41EjCCm3d6YU6Y04Q==
X-Gm-Message-State: AOJu0YwScqzBnzBk3JOkpVncmhDqkjoVopJSknNoD1kvzNgWmrGlbKiD
	8thJxFv2YhTk31aSBTQUGo0h5RoCMRFdiVKq444paDeczfjcPTOlBw7aqib6zZF+THd9Bv8Yq4T
	h2+PxoY1udDihS68wzcEDUOlOk7CDLWUQ+E4z
X-Google-Smtp-Source: AGHT+IEhGQzLLgCG9zMe0EWuDP1y2oVPtsHywKe/9At+CIXkctODudh6oHfrQfYIPwmYuFhbkIgUb9iq6CY+5R6qw6E=
X-Received: by 2002:a25:7:0:b0:de6:1695:13a3 with SMTP id 3f1490d57ef6-dfe62f1a60dmr2505543276.0.1718213358736;
 Wed, 12 Jun 2024 10:29:18 -0700 (PDT)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <20240609104355.442002-1-jcalmels@3xx0.net> <20240609104355.442002-5-jcalmels@3xx0.net>
 <CAHC9VhT5XWbhoY2Nw5jQz4GxpDriUdHw=1YsQ4xLVUtSnFxciA@mail.gmail.com>
 <z2bgjrzeq7crqx24chdbxnaanuhczbjnq6da3xw6al6omjj5xz@mqbzzzfva5sw>
 <887a3658-2d8d-4f9e-98f2-27124bb6f8e6@canonical.com> <CAHC9VhQFNPJTOct5rUv3HT6Z2S20mYdW75seiG8no5=fZd7JjA@mail.gmail.com>
 <uuvwcdsy7o4ulmrdzwffr6uywfacmlkjrontmjdj44luantpok@dtatxaa6tzyv>
 <CAHC9VhRnthf8+KgfuzFHXWEAc9RShDO0G_g0kc1OJ-UTih1ywg@mail.gmail.com> <rgzhcsblub7wedm734n56cw2qf6czjb4jgck6l5miur6odhovo@n5tgrco74zce>
In-Reply-To: <rgzhcsblub7wedm734n56cw2qf6czjb4jgck6l5miur6odhovo@n5tgrco74zce>
From: Paul Moore <paul@paul-moore.com>
Date: Wed, 12 Jun 2024 13:29:06 -0400
Message-ID: <CAHC9VhRGJTND25MFk4gR-FGxoLhMmgUrMpz_YoMFOwL6kr28zQ@mail.gmail.com>
Subject: Re: [PATCH v2 4/4] bpf,lsm: Allow editing capabilities in BPF-LSM hooks
To: Jonathan Calmels <jcalmels@3xx0.net>
Cc: John Johansen <john.johansen@canonical.com>, brauner@kernel.org, ebiederm@xmission.com, 
	Jonathan Corbet <corbet@lwn.net>, James Morris <jmorris@namei.org>, "Serge E. Hallyn" <serge@hallyn.com>, 
	KP Singh <kpsingh@kernel.org>, Matt Bobrowski <mattbobrowski@google.com>, 
	Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, 
	Andrii Nakryiko <andrii@kernel.org>, Martin KaFai Lau <martin.lau@linux.dev>, 
	Eduard Zingerman <eddyz87@gmail.com>, Song Liu <song@kernel.org>, 
	Yonghong Song <yonghong.song@linux.dev>, John Fastabend <john.fastabend@gmail.com>, 
	Stanislav Fomichev <sdf@google.com>, Hao Luo <haoluo@google.com>, Jiri Olsa <jolsa@kernel.org>, 
	Luis Chamberlain <mcgrof@kernel.org>, Kees Cook <kees@kernel.org>, 
	Joel Granados <j.granados@samsung.com>, David Howells <dhowells@redhat.com>, 
	Jarkko Sakkinen <jarkko@kernel.org>, Stephen Smalley <stephen.smalley.work@gmail.com>, 
	Ondrej Mosnacek <omosnace@redhat.com>, Mykola Lysenko <mykolal@fb.com>, Shuah Khan <shuah@kernel.org>, 
	containers@lists.linux.dev, linux-kernel@vger.kernel.org, 
	linux-fsdevel@vger.kernel.org, linux-doc@vger.kernel.org, 
	linux-security-module@vger.kernel.org, bpf@vger.kernel.org, 
	apparmor@lists.ubuntu.com, keyrings@vger.kernel.org, selinux@vger.kernel.org, 
	linux-kselftest@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, Jun 12, 2024 at 4:15=E2=80=AFAM Jonathan Calmels <jcalmels@3xx0.net=
> wrote:
> On Tue, Jun 11, 2024 at 06:38:31PM GMT, Paul Moore wrote:
> > On Tue, Jun 11, 2024 at 6:15=E2=80=AFPM Jonathan Calmels <jcalmels@3xx0=
.net> wrote:

...

> > > Arguably, if we do want fine-grained userns policies, we need LSMs to
> > > influence the userns capset at some point.
> >
> > One could always use, or develop, a LSM that offers additional
> > controls around exercising capabilities.  There are currently four
> > in-tree LSMs, including the capabilities LSM, which supply a
> > security_capable() hook that is used by the capability-based access
> > controls in the kernel; all of these hook implementations work
> > together within the LSM framework and provide an additional level of
> > control/granularity beyond the existing capabilities.
>
> Right, but the idea was to have a simple and easy way to reuse/trigger
> as much of the commoncap one as possible from BPF. If we're saying we
> need to reimplement and/or use a whole new framework, then there is
> little value.

I can appreciate how allowing direct manipulation of capability bits
from a BPF LSM looks attractive, but my hope is that our discussion
here revealed that as you look deeper into making it work there are a
number of pitfalls which prevent this from being a safe option for
generalized systems.

> TBH, I don't feel strongly about this, which is why it is absent from
> v1. However, as John pointed out, we should at least be able to modify
> the blob if we want flexible userns caps policies down the road.

As discussed in this thread, there are existing ways to provide fine
grained control over exercising capabilities that can be safely used
within the LSM framework.  I don't want to speak to what John is
envisioning, but he should be aware of these mechanisms, and if I
recall he did voice a level of concern about the same worries I
mentioned.

I'm happy to discuss ways in which we can adjust the LSM hooks/layer
to support different approaches to capability controls, but one LSM
directly manipulating the state of another is going to be a no vote
from me.

--=20
paul-moore.com
