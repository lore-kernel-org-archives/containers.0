Received: from mail-yb1-f171.google.com (mail-yb1-f171.google.com [209.85.219.171])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9A96314EC64
	for <containers@lists.linux.dev>; Thu, 16 May 2024 16:23:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.219.171
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1715876629; cv=none; b=ZTSCIoH8WpS1e7uFlaIxCGwb/xEIHSBD5SNCQkkYbusf4HctTpNHFwmEC2DYitxaIu7RPHx7EGelB65ePHJwi+qgoED+212EDITcCT27nLRCmY6+el34A9fgqCHeeWfgAlQ6ir8JC/HR93OVZK1rlnYEKmX/ji0f1q9TBiKxsbM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1715876629; c=relaxed/simple;
	bh=EZ7K4NzPBe6mgvmzDvgcN0o2b/NCkPR6fbfbuMDf1ag=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=OYzmPFzwaZQHPlsuByqxGkr0ALulpXBPfXqHM+2py7vvVQOucdMyM8zv1i59YRL5kJPC64KpyXh5nN1MrqZ9dvG4NtOFOxJXKlqIWWRhfX79liCd7BfCs/m6pXyY26wAR9Lf+D8Yspimkv6pfYPFDtd92eUqhnxm2JMDyhHyClY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=paul-moore.com; spf=pass smtp.mailfrom=paul-moore.com; dkim=pass (2048-bit key) header.d=paul-moore.com header.i=@paul-moore.com header.b=IXjXbKkL; arc=none smtp.client-ip=209.85.219.171
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=paul-moore.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=paul-moore.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=paul-moore.com header.i=@paul-moore.com header.b="IXjXbKkL"
Received: by mail-yb1-f171.google.com with SMTP id 3f1490d57ef6-de462979e00so8996745276.3
        for <containers@lists.linux.dev>; Thu, 16 May 2024 09:23:47 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=paul-moore.com; s=google; t=1715876626; x=1716481426; darn=lists.linux.dev;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=Razho7lHGpyap1v7dPaP5qSSISsR7xC/uw6XBXBKDDs=;
        b=IXjXbKkLXfwwbRQ8QHEgf+mGVoHdA6VfvfoR43tTl0uDnO4zyVGJeLcGTXQifaH6S3
         DAYr0qntXfyLyLZWtWjFtpmTudKHAmV6ggW0mjwOiQCehlYq1ieNfjMcP2kVxcshIMAX
         jHaR/SVKpoMsAGEFB5NyTkDl7dUMW/xJ0gQikv1xCaLNwKmj2ojxfJlG1/8dqj3vz0LM
         goCusj/CMRttDSWvnxLngzEoFT3ue39lF4Y4lV/W+f0xS3MPQx/NVrKn1fqnj538lX9W
         gUgqcBPW9UFf14wcgvxCEpKsVTilWXCe4a64D7DA19k0/hxaz8YtVVnbU8YhsAFrfB5+
         ev5A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1715876626; x=1716481426;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=Razho7lHGpyap1v7dPaP5qSSISsR7xC/uw6XBXBKDDs=;
        b=KN+HHSoCgzXaEAvft8lTIgaJxbP4KkKLUabhdNB34McJoUc6mT/kNzXFWmr1JFGNGu
         A0hU0BDuDKK47xESPMH54wlWCCuqM2flXm4h52WBFIS0jFehGqPF4fRM/5Mwj7TCex/k
         p3IzU8I8r8EqPBhYdu5hI0fYJMgdCWDuArmLULGrA3cvnCUWjWA1ELpHhIljhhUjpFCj
         6749eYvg9Rl+rUf2y1wZVc6Ubd8Rz8gQZICsRV5LHP3NIVVIi3jbRZLeRVAS/NsmmARI
         3JbtiFcy73Gsw+1HOPCaVHu+0MwY8hNQBag6jxCz2gIMMDf5vPKHwHfrr3DC+oR4S6aS
         YcGA==
X-Forwarded-Encrypted: i=1; AJvYcCXLU4JPn4bWWZExbEyhkuGztaZ/DuEKd3GpfqctKTGKN1eof45eTtVQ7Tq2eerEAOOHuwglrvP0CZtDhytWHs0nwWE9i+k1dYNJ3Q==
X-Gm-Message-State: AOJu0YyiE9k7KUvK3hohdSCU2T0bA9hKYrDfm7diqZbUtXF1waGZ2UJF
	WAfzrly115VbhJ2jHDqL/oPyZiVvvLjqYrdEE8huBD2oQ2+XcB3JlvrgNOYW/PmgCIsLLH5lWjn
	tQmB4y+ZztqeC1szD9BFBBvr/xoZgHXTQV/bZ
X-Google-Smtp-Source: AGHT+IEe/+V1bbRxOWwuKMKyGJUCyojV3Orv/M9T3K8RKww9g1UJdluzqC20c4o+/xI6Shg9MmTrzyhw8zyqu2pFzkc=
X-Received: by 2002:a25:ade7:0:b0:dcd:5c7:8466 with SMTP id
 3f1490d57ef6-dee4f3a9f30mr20073221276.44.1715876626618; Thu, 16 May 2024
 09:23:46 -0700 (PDT)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <20240516092213.6799-1-jcalmels@3xx0.net>
In-Reply-To: <20240516092213.6799-1-jcalmels@3xx0.net>
From: Paul Moore <paul@paul-moore.com>
Date: Thu, 16 May 2024 12:23:35 -0400
Message-ID: <CAHC9VhQ=nNPLRHF8RAMxArT1CESei+qYsnGse6--ixPhACAWTA@mail.gmail.com>
Subject: Re: [PATCH 0/3] Introduce user namespace capabilities
To: Jonathan Calmels <jcalmels@3xx0.net>, Serge Hallyn <serge@hallyn.com>
Cc: brauner@kernel.org, ebiederm@xmission.com, 
	Luis Chamberlain <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, 
	Joel Granados <j.granados@samsung.com>, James Morris <jmorris@namei.org>, 
	David Howells <dhowells@redhat.com>, Jarkko Sakkinen <jarkko@kernel.org>, containers@lists.linux.dev, 
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
	linux-security-module@vger.kernel.org, keyrings@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, May 16, 2024 at 5:21=E2=80=AFAM Jonathan Calmels <jcalmels@3xx0.net=
> wrote:
>
> It's that time of the year again where we debate security settings for us=
er
> namespaces ;)
>
> I=E2=80=99ve been experimenting with different approaches to address the =
gripe
> around user namespaces being used as attack vectors.
> After invaluable feedback from Serge and Christian offline, this is what =
I
> came up with.

As Serge is the capabilities maintainer it would be good to hear his
thoughts on-list about this proposal.

> There are obviously a lot of things we could do differently but I feel th=
is
> is the right balance between functionality, simplicity and security. This
> also serves as a good foundation and could always be extended if the need
> arises in the future.
>
> Notes:
>
> - Adding a new capability set is far from ideal, but trying to reuse the
>   existing capability framework was deemed both impractical and
>   questionable security-wise, so here we are.
>
> - We might want to add new capabilities for some of the checks instead of
>   reusing CAP_SETPCAP every time. Serge mentioned something like
>   CAP_SYS_LIMIT?
>
> - In the last patch, we could decide to have stronger requirements and
>   perform checks inside cap_capable() in case we want to retroactively
>   prevent capabilities in old namespaces, this might be an overreach thou=
gh
>   so I left it out.
>
>   I'm also not fond of the ulong logic for setting the sysctl parameter, =
on
>   the other hand, the usermodhelper code always uses two u32s which makes=
 it
>   very confusing to set in userspace.
>
>
> Jonathan Calmels (3):
>   capabilities: user namespace capabilities
>   capabilities: add securebit for strict userns caps
>   capabilities: add cap userns sysctl mask
>
>  fs/proc/array.c                 |  9 ++++
>  include/linux/cred.h            |  3 ++
>  include/linux/securebits.h      |  1 +
>  include/linux/user_namespace.h  |  7 +++
>  include/uapi/linux/prctl.h      |  7 +++
>  include/uapi/linux/securebits.h | 11 ++++-
>  kernel/cred.c                   |  3 ++
>  kernel/sysctl.c                 | 10 ++++
>  kernel/umh.c                    | 16 +++++++
>  kernel/user_namespace.c         | 83 ++++++++++++++++++++++++++++++---
>  security/commoncap.c            | 59 +++++++++++++++++++++++
>  security/keys/process_keys.c    |  3 ++
>  12 files changed, 204 insertions(+), 8 deletions(-)

--=20
paul-moore.com
