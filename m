Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.167.50
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1794849333;
	b=N+gRoA/HRbmwXmfkGy6WW/AByh6RX773en/ha0SnmdB8umshZeOL5lWZ1BKNjA9wnmHG
	 pYEHu5IcMU9Lace+etdKbfU0c5vFgHo9oWZQ4p0niQNmEfvhe73VF736WIQA8+MmrFf9C
	 TjCW20UxJt6wUQB8eraWFkDxqvSFasqC8ZGFEE7x6Eujo9cnpl7miv2TX0K+PvLkI+pE+
	 IoP3odJmZp7+VfH8rW8Yv6iPBZkAmrBt2uK9s8neP0kQQ2BPXUJttZ+YAA1ObUqyLdPxm
	 1mldM7ArIZ86DfCqTxEv5qNpb0pp3yYl55jR5jVD61MgNOFhc3ItAv1GifPUfGFO7sw==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794849333;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=TeTKNjRbgGCPVD9Hh4J0uSo4q2UCRSd3rU9Pr4FPh88=;
	b=Wsmk2qVCqYMzju2E8bJnl6hNAWc4y/0SnBlELRwfy7udMMewi2HhjK6FqRhUreq0SBdz
	 gwPfsPkgwkFPP6Cg9ESnRd8ocTidvSmNQ4XUlbQBz3xm3I7Ruoxptv8A7F8ww4IU4zyw3
	 olvMx3G5IsPPmZfaUKAjzk3dRLt2v5ZZsMf8LEmObTDUi+MxIGSONnhdPWzQd+9X1xmjx
	 tPvuJQcO7qGPMijBSumH9PUjzPDqKqTZPDdhn0QA24fUlP4LOjaZmJHIjc4iNCcafKe/U
	 e4lgG+FU8/5+W63vY3bjcObIY2X0Dk7mtUKINm+veaA5n9GuGTK3gKr2QHeapzqBjfQ==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=none header.from=amacapital.net;
	spf=pass smtp.mailfrom=amacapital.net;
	dkim=pass header.d=amacapital-net.20260707.gappssmtp.com header.i=@amacapital-net.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=o87qzBUR;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.167.50
Received: from mail-lf1-f50.google.com (mail-lf1-f50.google.com [209.85.167.50])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AA33C606A330
	for <containers@lists.linux.dev>; Mon, 16 Nov 2026 17:15:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org AA33C606A330
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amacapital.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=amacapital-net.20260707.gappssmtp.com header.i=@amacapital-net.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=o87qzBUR
Received: by mail-lf1-f50.google.com with SMTP id 2adb3069b0e04-5be4a2d94adso3457068e87.0
        for <containers@lists.linux.dev>; Mon, 16 Nov 2026 09:15:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1794849331; cv=none;
        d=google.com; s=arc-20260327;
        b=i/HpdwmulnHsF1LItVnKlhvXips+kZh02FtkIPg5hPK6QWGS2RsMudVCpxxvjx0Rzl
         CDi7RZwonVLaRh37/z6HrghTums/jq1XsD04xNzbVIGuO1/QsB5eFDgDAcHyBfnyDS54
         c2u7VM4Q9FcUCw+rGJUbwWWOB0XNtKVYiCVDXHBp11T8JfyeI0XyzivA2oRLDuV4n8pf
         9Y73w7/QH+Sod9peSigLEY7QoBO/LdDp/tiyZkCBqe4CItrcaHVzNfQc55oJ2drsdPMh
         WRePKq2Ugm1OsoTpo5wnyrgtSapwwYYqATkbkkG1t6aziA0RXi/oS84clL/YDFjFif18
         SV3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=TeTKNjRbgGCPVD9Hh4J0uSo4q2UCRSd3rU9Pr4FPh88=;
        fh=BxMlxddcyxCvcAVyDyAUEV57DIU+ehqPnCljudORRxw=;
        b=aEInkEbvKq0cIvDZvmwpc+SmrH2mBo5q/7kksjST9J19nWJf6EVbsUrNYkQdsNT4aC
         88Wq1Xfebe+YjmsZOUrBZzX4ohR4ykI7xEdqKPKH1UFBXdGIegDg7c1SvNEv0Tu+z/0O
         mMsK2rdDJrmZUP1oD+v0iSyIvd/v2VruV1/hdMwETS6xOAgP8384iLw0iTfQKwZT6ILd
         9pGuRHQ9edvWMdXis5TGOgJWEhIXrVyppFR6ufo7GKjtY8p3JshlHjRXTT9TZO5UnwAR
         IZHmjRAu3CTxq7Mu/7jQCc+T0V5aBpXy+hRyju2T0ac3pYvwK64vI0V/toia4zYrMFJf
         3Kjw==;
        darn=lists.linux.dev
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amacapital-net.20260707.gappssmtp.com; s=20260707; t=1794849331; x=1795454131; darn=lists.linux.dev;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=TeTKNjRbgGCPVD9Hh4J0uSo4q2UCRSd3rU9Pr4FPh88=;
        b=o87qzBURrqhzUaMdHi/jkWozfCWhbOKjviHSWgOZ0NXuibq3E9Nt5qjv5ShylhqXz9
         FM8Wgwxrfb1K9qaUVvbQiLSXQtAgDE8pJvkqV9yAy1F2Ty97x+8Bs21vVgsXfodFvyOQ
         cwHd4C+ftEKS/Z5R53cz/VYksMI3Y7zYRr8O5L1CmNxMFvX1IaBqapcbdmZHc7xfKWic
         5yFFk2GCRtLkEb7hJsCSZG1WCfdqGRnXoJTwhaFk8IrSXoKC/HIrNthNzbKv+0lblo0w
         y50TiaHt5QX3q+Yg7rmOm1F1cAJ4qokMvh5zW23Awr0PP0FdYwGfMm+K2Eq0hLECa2kq
         HmuQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794849331; x=1795454131;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=TeTKNjRbgGCPVD9Hh4J0uSo4q2UCRSd3rU9Pr4FPh88=;
        b=r1qXEI1QTYqhiltJF/zt98Q9HjRXMeBF7s4W3fAiLJUqJDS1kxXgk4PXvHSsCID9Pj
         9z5lJkKhEP84xiUWvOerYqmCZ56iRSTfIrMQICJoZWmaL0iBV35dWSOxGUIIbOAugp5c
         6z3Xw6eXSq38Pva+j5vmLshbGcWI+mj1K3EdmYdnAtFyp2QhiViERGUdoGsr6jTPNzCG
         gvnuTEjHfZGd5SIHBYnufN3F+FfKiiU+UXSZ2NHmclO2xBSt7hvtHT76MN0xVbXCHoD0
         iqxD/xeSBy3x+JfOrl2A+aBsPi/AiHOL7yhrDUrlg0obXb75Zv2XlOF4wrqk/TWNg6vC
         y1kw==
X-Forwarded-Encrypted: i=1; AL+hErF5W3t+W3yRYpzcc3GBl+3rL3uqHvdU3AAysqoL0U1lEjHwPGhRMEbfSjbb5UO5FzvtnHjtJJMWzciM@lists.linux.dev
X-Gm-Message-State: APuU4Z+n3arffrRVi+KuTPI3tiKCwgB8sDIhO+XIbglrxTjOJX1aQILj
	fxNDwIzrkdNZHcC8d8WKrLYWBubflAwOgAWcv93E4MDSeg8qmOVNts1OT1kGPb70jRd5dr7UWZN
	xyouEhkvBF11+DA0TEPuHIgYVyZQTITxe8tn45ZOF
X-Gm-Gg: AYBFou2IE+vDcg6s1xRI0VkV9AhvHbyeWuoW3Rfv14IK2Ew1l2OoIYTcCqS+jLaalAX
	UWpy+o/hQOmU3kqaIVhM4V+GYRptuM6PQEhjO661IaoOoE9VHrt+2CNjL7FwOcxEDdSe/FG/WpA
	e74WY/g3KcHNpquqdY6ATt2vsQ0/OuRV8Rex2qoedKn/ROjqIZsS4L0THNsHgBPBB5zaKtj0i47
	YR0rfYKJ8oTawxboo0kH+qGr7plKLJKr+Pu5BoOwpRTaPlx4TAlQU5pxJ1ymYQFmJHLoVU4Lzos
	XUe0TlgWUnhMEnhJpwh6EbAbCeLhFOHVNUYM+6ZxqEMeg6GHvDc+KJacp+8pSROnWsi4xi3L2eu
	7VJJ/K/EsRahd3t3D9Cpnqu0f4EEkhFzF2g==
X-Received: by 2002:a05:6512:132a:b0:5c1:57cd:507 with SMTP id
 2adb3069b0e04-5c1705d8c18mr4112436e87.8.1794849330616; Mon, 16 Nov 2026
 09:15:30 -0800 (PST)
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
 <20261106-befreien-addieren-eislauf-e09212803534@brauner> <CALCETrWa1SBLcb5oWjqjgzZvKvCoHjmYFk=Lf5ytEM9uqm5jYA@mail.gmail.com>
 <avM41a80aig2de-R@google.com> <20261111-behagen-faktisch-entgegen-e2e714373895@brauner>
In-Reply-To: <20261111-behagen-faktisch-entgegen-e2e714373895@brauner>
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 16 Nov 2026 09:15:18 -0800
X-Gm-Features: Aa3M54qwWxMtxsZDh2vrMHB0wizt5RpGMmIfg1U4U0aXsb9fKiA9QIK00CYod18
Message-ID: <CALCETrUjW=kXxyggDUvEN+Pxc-pE98eVbdW8XBU8JzfqXj_voA@mail.gmail.com>
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

On Wed, Nov 11, 2026 at 7:20=E2=80=AFAM Christian Brauner <brauner@kernel.o=
rg> wrote:
>
> On Tue, Nov 10, 2026 at 03:31:33PM +0000, Hallgrimur H. Gunnarsson wrote:
> > If we drop CLONE_NEWNET_LOOPBACK / UNSHARE_NEWNET_LOOPBACK from this
> > series and handle loopback separately, do you think the per-userns
> > bounding set is a reasonable approach for withholding capabilities
> > (e.g. CAP_NET_ADMIN and CAP_NET_RAW) from unprivileged userns, or
> > would you prefer a different mechanism?
>
> Seems ok to me.
>
> > To address the concern about the number of moving parts, I am also
> > happy to simplify the control interfaces. If we decide a per-task
> > securebit is the cleanest way to drive this configuration for both
> > single-deep and nested cases, we could focus on that and drop the
> > clone3() and sysctl from this series entirely, or only expose whatever
> > subset you prefer.
>
> Just a note on the essay I cut off. I really object to any arguments
> that amount to "it's too much work" propped up by a few thin arguments
> sprinkled in such as rtnetlink.
>
> I also reject any arguments that amount to underscoping and overscoping
> of the new capability. The scope is clear: empty netns with brought up
> loop device.
>
> I'm 180 patches deep into fixing procfs and 41 patches deep into
> preventing loop devices from abuse. Either we do the work and get
> something better or we do the same thing we've always done and hope we
> end up happily ever after.
>
> But again, I'm more focussed on cells so here's what I find acceptable:
>
> I'd rather go back to what Jonathan proposed in 2024 (cf. [1]). A
> per-task userns capability mask. Serge acked the core of it back
> then. It's at least generic and not just the single securebit capability
> thing. And we'd burn a new bit for every capability that turns out to be
> a problem later.
>
> Jonathan's version had holes though. The restriction only lived in the
> task's creds so the owner rule and setns() blew this up. So it needs to
> be combined with your per-namespace set. Roughly:
>
> * every task carries a mask, cred->cap_userns, full by default
>   fork, exec, setuid and entering a namespace never change it
> * a new user namespace records
>
>         ns->cap_bset =3D parent->cap_bset &
>                        (cred->cap_userns | cred->cap_permitted);
>
>   once at creation and never changes it again =3D> it's monotonic downwar=
ds
> * the creator gets ns->cap_bset instead of CAP_FULL_SET
> * a task that setns()es in later gets
>   ns->cap_bset & (cred->cap_userns | cred->cap_permitted)

I'm not sure this is ideal.  If a task has cap_userns & CAP_NET_ADMIN,
then there is no attack surface issue with allowing it to enter a
namespace and be NET_ADMIN there even if the namespace itself has
CAP_NET_ADMIN cleared from cap_bset.  But any exemption here would
need to be a new API so that it isn't used by accident.

I'm mostly saying this because container managers might want to
restrict cap_userns within their containers but still have it
themselves for management.  But maybe there isn't any need to enter
the userns for this purpose.

> * the owner rule in cap_capable_helper() grants exactly what entering
>   would and otherwise falls through to what the owner has
>
> So caps a task actually has always count as allowed
> =3D> should check Andy's "only restrict creators that don't have
>    CAP_NET_ADMIN themselves" per capability.
>
>    This amounts to a host-wide default without a sysctl.
>    PID 1 drops CAP_NET_ADMIN and CAP_NET_RAW from its own mask at boot
>    and everything inherits that.
>
>    Root, sudo and setuid-root binaries have those capabilities so
>    nothing changes for them. A regular user doesn't and so their user
>    namespaces come without CAP_NET_ADMIN and CAP_NET_RAW.
>
>    This also covers newgrp, su and sudo -u shells which is where
>    resetting the mask on setuid exec (Which was raised by Serge in the
>    other thread.).
>
> * Root in a container has caps as well so for containers the exemption
>   would be wrong.
>
>   So here we need a a lockable SECURE_NO_USERNS_CAP_RAISE bit thingy.
>   This turns off the exemption and prevents raising the mask.
>
>   Docker lowers the mask, sets and locks the bit, and
>   unshare(CLONE_NEWUSER) in the container doesn't hand out CAP_NET_ADMIN
>   anymore.

Can you clarify this part a bit?  I'm not seeing why Docker should be
special.  Shouldn't the inside of a Docker container work as much like
a normal non-container system as possible?  What's the use case?


In any event, the ptrace access checks also need to be updated.  If
we're adding cap_userns, then one should not be able to
PTRACE_MODE_ATTACH a task with higher cap_userns.
