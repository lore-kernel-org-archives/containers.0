Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.167.51
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1793731083;
	b=B8Kn30dxR62L7z1OSKzjnxwRgtcZz1nYPq89NqTYuxYYKDAA+MobXYo4ntm0vCV+2ITa
	 lJ30Uh6gk+eGaBozBPOp6HWVAZLW/aFzY3pZD6FJGMm2EHBKHjnb80fVGdfo961BguGxy
	 JFvDrDFt2AeNXWdmee0VTfJjKJAqfIDD2P1dkkUL1P5zdVjWiydP/vZkHoStAWC4k7Wo7
	 K2KKM4IOhd4hcYdTycp/irUWovMswvDcp5ok6ViO8VRZrNSq4Zd3AiTr6X5yBIIC0BAMx
	 lJu18jcB17f+noJSyor2MHkl8ujClFivWppj/jVq2PnVUSFQPoaWW+9qht3ZKlxAJBA==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793731083;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=fviwjroG//qntBAn39plNVA6JSIngXI7akYS02td+eA=;
	b=gu5QiXSqGtOw+8RhKq6SKz88MyqFA3EBgltYF8Ga2oXV4M5nLrmOAXqyjo04/OSUrepm
	 IVTMt7kcGmP+VhldfoorOubpO1Fg8rqgDj4ToewmmkyQ8uMF55DkkILNTZjmbXSFXFIzL
	 tOfGxilpgMv9j/egSfcUZtyGO3geM1YAIT1oZ4vPvx+PJBDh9fnVC08yHXtE34cWQJzNX
	 LckTeNEmQvzuN7JtWSc89V51PkOisJsfNBU/DQZk/dMmP2IsaFd1FfjSi+ye2cEkMqu8u
	 ITvVvyvgcPdNvjvfsPjzd82leKkyf1iPJX9Q+VfauEO/QJH5YUH6fI3eUytRnmRH1zA==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=none header.from=amacapital.net;
	spf=pass smtp.mailfrom=amacapital.net;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.167.51
Received: from mail-lf1-f51.google.com (mail-lf1-f51.google.com [209.85.167.51])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D7266606A32D
	for <containers@lists.linux.dev>; Tue,  3 Nov 2026 18:38:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org D7266606A32D
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amacapital.net
Received: by mail-lf1-f51.google.com with SMTP id 2adb3069b0e04-5be3ed646a5so4779414e87.1
        for <containers@lists.linux.dev>; Tue, 03 Nov 2026 10:38:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1793731081; cv=none;
        d=google.com; s=arc-20260327;
        b=CQQMC5uK/AR0ViG1/bLvylr7J2k5ixfMSIa9PJCgv2eoCWEaDYyEaWij5s4ny1jtJy
         njY0X+EaXzcY//1RuUZbMYPtRdwLX98uFemd5d0IDXyZaJbLPVsQ9HfCYtgXy9ywAdXl
         UB153dUuFPEnpvu7JETFXK5b6I90eA0uG1cgTAj6//RlaNSQDHYmNESGWaLWRyKN80jz
         H8ip3G5MQj3vxVr2IayhGxiap8P5p2JKh/rDkL7YeVkaGx5tTxQbMAI+eLqKTBUYGXAe
         5jX277eeV1lYaBuKFh2CKQZATqEXMcrdARLisa1JBDnJfzDcINV7UB2iOPsHB2g5eKLJ
         AVzA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=fviwjroG//qntBAn39plNVA6JSIngXI7akYS02td+eA=;
        fh=8+Wuy6wrjOsLQZulRLpRZi5uVMrB08THbdCSo1IvGkg=;
        b=WUajbQR5aCISnUl0Ga85nzCVYQfIrf6szkUT8g69L/dH7Qz+BFpxmuNDSLXqVYeLcK
         lquVhfsFQfFT0gqvL5vby8/Gj4X9w6+UiIfmt6+Gi/oXdC0GyXsdFOSYNKBam6YzW3y+
         HYikqzEK7+Uvik+6x9Xk5sT9bP5f8WWH4/zPFonSXafo3UMN2vjOeEUGp5cpHtRFeOJa
         ZWm88moMBh/5hHQQ2HNn9ZPburcQi+apPV6wvhOXHbcKydk++PoL/hPY6G0bAunC23q6
         n7bJEzKX+FnPvvtgcdRQMRqCDzIt/ZNMvBlAIcC5oN0IGGeQAt/ijhwq+Iy2y6RRJwsx
         CrHg==;
        darn=lists.linux.dev
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amacapital-net.20260707.gappssmtp.com; s=20260707; t=1793731081; x=1794335881; darn=lists.linux.dev;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=fviwjroG//qntBAn39plNVA6JSIngXI7akYS02td+eA=;
        b=mN6mZAJEZx6xsPj7E9KQrt8eGr9lGHU3whIK9oAjBw2Q4S9D1xsjC9zgrT08OCnst6
         pmtMjKLwlRvyLkzTxDiD2wAFTXFIZe6mczxslp5B9i3XyINHjrPskibjpWx5WaEoEZCz
         /C+8jf1cn29Nl/1YtFGQV+7fbYJhN6l7ruTVFQ4caZI/fRpaD871yIFqo0sYWI4+bzTB
         xHSy1tq5jQzFkTcAPedkdQ+377Lczd+Ard+9W89Ag2O2+TpBErMsLRBewkAkyj+uUosX
         Jxo0Wo5k439fSqn9SfUtItdSgPGvs0s6EInQp94n6lcTP7a7nwvItgSHMJxJHbgdVFZQ
         Q9Nw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793731081; x=1794335881;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=fviwjroG//qntBAn39plNVA6JSIngXI7akYS02td+eA=;
        b=i/JqFqIz/O84I3yYiylZ6bdyCfgimfbrBfu6XmFGL9NdbRL7OXiiYmc4AUD9w/SbNP
         /T5hrd8/qOVUsHMaUJpttDc/prd0vNlrBiN/CLEHPINcQpi5YiAPCH7rKFItlQhVLVKN
         VAd/K3UCq60hIP6sdMFFye6Q7Pr+WR/7fvMk4YN+ka+4HnI3t+IjfCYidezZa1i4C31n
         rTAEgiiMb0Mn2JYI1ipAHJptQmYG8/Yj5mZKzOM7I+fX7DS6PO8vZLWbDAc1rEiQGss8
         15m+IKofmMb/dGb5w43AsqVgAd17m83boirmLFu1nDUn65PuDKflKeChb3xJclz7w6qC
         APiw==
X-Forwarded-Encrypted: i=1; AKwUvBzRINFqbLyb0BNLYC3DzhwV61LtZaSlHnhjxpIFBOxuU0CfWsDCaLZ9mvMojIpA3AvW+dbHGToL0Qpm@lists.linux.dev
X-Gm-Message-State: APuU4Z9gUMU8CP8Y+JHhuD7sv6hQTTp4XMPEG9ICan6A5+ojgCHSxYMM
	gW+7dUa2DUrFOnXe70SRr0sElPPbs/ITca9748v+NYl2bEXE7P2eFGkHe+Ow9j4sdclzzQNHjkI
	fi5gPi/dK/YPE357A3rQcFidv3AZ7ZQHze2Btvek0
X-Gm-Gg: AYBFou2G2/Qb+iXvxF5ijL1aR9DeyucAo22qQpeit4nsu2MIydbI9IoYy33dDbhcDzj
	PaxawoUn1scqa1DdjhC+dU6Z9v2IHs50uTkV3GvhyjUixiETbidbRQ3ecZyMcfGBoxqoUqYkajP
	Qxie0zuCZCQu4Qub3WEV34+y0lmhSEgNLHgy7Fz6WSKBrUlUGZPbaPwRX6xyiQh8ARtkTnF/QW7
	k9AcVr/5S64Xuy/7sJyQktgDxLDiEjL+DUFNeZC+19DlSvPJFFcy/GE29SbsDGX5vbsIVCQQDp1
	1sy2K1JToHo92T8y8oPXcNGvlROlifYWRPNxILPGIzIduIiw0isfcAC1AgujCWRxi+y0u9qmrIr
	OPY3F8kMXnMAF9oD/MqnQ5I4bbry90105aw==
X-Received: by 2002:a05:6512:3ca7:b0:5bc:e8b0:5652 with SMTP id
 2adb3069b0e04-5bfd9589099mr5147409e87.63.1793731080985; Tue, 03 Nov 2026
 10:38:00 -0800 (PST)
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
 <auM32mOlBLu6ZUlt@google.com>
In-Reply-To: <auM32mOlBLu6ZUlt@google.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 3 Nov 2026 10:37:48 -0800
X-Gm-Features: AclHuK_sfbKF658HbwyCTsOToNn9cXs0qzXn8uaPUG4vxi_nXA5hXmjvbt4jwHQ
Message-ID: <CALCETrUD4vh_iSHV7G0bprUFU8=c+ECo701-tXcbQ3UXBWC1ig@mail.gmail.com>
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

On Thu, Oct 29, 2026 at 5:11=E2=80=AFAM Hallgrimur H. Gunnarsson
<halg@google.com> wrote:
>
> On Wed, Oct 28, 2026 at 03:56:11PM -0700, Andy Lutomirski wrote:

> >
> > Why should the task's cap masks affect this?  *Maybe* cap_bset makes
> > sense, but I'm struggling a bit to see why cap_permitted and
> > cap_effective should matter.
>
> Sorry, the phrasing here may have been misleading. Just to clarify:
> none of the creating task's capability sets (cap_bset, cap_permitted
> or cap_effective) are used to restrict the new user namespace.
>
> When I wrote "reusing the existing task cap_bset, cap_permitted and
> cap_effective sets on namespace entry", I was contrasting this with
> the prior series from 2024 [1], which proposed adding a 6th per-thread
> capability set to struct cred.
>
> In this series, when a task creates or enters a user namespace, we
> simply initialize its new cred->cap_{bset,permitted,effective} in
> that namespace to user_ns->cap_bset instead of CAP_FULL_SET.
>

Okay, this makes *more* sense, but I think it's too weak.

I have a sort-of goal of having the creation of unprivileged
namespaces be allowed in most contexts by default, *even in Docker*
(which would involve the Docker team changing their default seccomp
rules, but that bridge can be crossed later).  (In furtherance of this
goal, I fixed an ancient bug in newuidmap that gets us quite a bit
closer a couple weeks ago.)

But tying this mitigation to a parent userns means that it's
completely unusable in the single-deep case.

I do have a question about this whole scheme, though: are we talking
*just* about CAP_NET_ADMIN?  That is, is there any other bit that has
anywhere near enough security relevance to make this kind of thing
worthwhile?  Because if it's really just a single bit control, maybe
we can come up with a nicer scheme.

--=20
Andy Lutomirski
AMA Capital Management, LLC
