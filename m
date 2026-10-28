Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.167.48
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1793228190;
	b=lYtZ4rtuRwSo1gj7HRoi3c/lZthYMZI+faKm4/X1zjmUMhyU1RZTVMyUi8EBL9jVLm+J
	 g8nUEtTo8nrJd44TfdGgukBq3KVLDC75rlUMwph9qet/18alijwgHqWu9QsKhU4BXFzXp
	 7rSJEGsFiC6JbpOmzh9pPa1vFmv/i3AhgiSz3vEl9+pyIHnSURKfVGznE10OFOn1UYeOM
	 XKpeR5DtecDuQ2GprpM/hiY5zLcaM68C2EIDcCaWaGysmDQOPqBt9GP6MM+PUFrb+SAn/
	 22O7G+vUlsQCzh/1K39TsOfMaJXvwM4OwWRcupS1NYL+JrjejbRzxQ9ZOH5SYZFVhQg==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793228190;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=V0MpBzACJCm623um40rfrBkC0GCIrNAzwGLFIF9vVVM=;
	b=3VVBt9AN7FHbBhTn/wS6Scm9+zq2jVA/hVGh3gWysKx9BVnqi9ZescpH1im3AImWvOIK
	 ngc6C6pmoUEIS/1zunOTiXI6WTH+jiViRkodtIxlh5w3lJ07sk12w3BCw4dnOVVzRaZsW
	 0QvmXfgBjqrhvlw8o/yFND9l1zCELxp6eg9MmlxrnADsCRuCGjoRDIWz+jszyFdlByhFE
	 e+5D0Xutk+2YKXOJoVeN5jQVzgpTGEYaB7sAlqgGnNyEPSb04g4mNbJ4GzEshpvmMyfvQ
	 RhcK+aeqMAFsGo9LbTOFZACXxmk574HyeFnY9VuZMypKhChywf4Rzk+EEjPvPlnliDQ==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=none header.from=amacapital.net;
	spf=pass smtp.mailfrom=amacapital.net;
	dkim=pass header.d=amacapital-net.20260707.gappssmtp.com header.i=@amacapital-net.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=cJEtzxCQ;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.167.48
Received: from mail-lf1-f48.google.com (mail-lf1-f48.google.com [209.85.167.48])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F221C606A31D
	for <containers@lists.linux.dev>; Wed, 28 Oct 2026 22:56:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org F221C606A31D
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amacapital.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=amacapital-net.20260707.gappssmtp.com header.i=@amacapital-net.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=cJEtzxCQ
Received: by mail-lf1-f48.google.com with SMTP id 2adb3069b0e04-5bcb6faf862so1634865e87.2
        for <containers@lists.linux.dev>; Wed, 28 Oct 2026 15:56:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1793228183; cv=none;
        d=google.com; s=arc-20260327;
        b=hcBz4++M1P9KYqGU9aVT2ADcLxcsTU/OzFcwMDJXwIby4DHHAeUeMPpNuReaNhaV4r
         Mrf2uh9+tIseIWhWewvTOCoHENdfKXjxoWh41BrByLgbKNJf+ln92HrWhEb2E0Urpl3E
         +/TfRwcEFYsyJsLHDmVI30w8O6xm0THWo6mIZn6mx8dYn0Vh7Vw2efPMwVqtT5N78Psh
         jmJ+Q9QrU0Wkrl0qYWIwv3mBx8wE9bYx9hOIA0BLNrXahYQ4W6RTLUdEVsr9k3YFERjk
         ML05k1qMNIDxZJk+8w50eBqIUrxwoxou6eifwP8BTV+lsSFxlRrszerH1JFu34lNM4j9
         tKTA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=V0MpBzACJCm623um40rfrBkC0GCIrNAzwGLFIF9vVVM=;
        fh=FR8Ymx3zehDpqAmygw3HC46ZemEVjQdma5htCev/Wsk=;
        b=Uow/xHDWtztJ3d5gMY6H9F+HZ4syAnkZuyQZEEoGrWWS5KHXG8Tt8SlHOuz/z839I2
         KazbLM6C7dQuAflf4mwHOYiFPHxDOHGsSPO/eEIiQMNBl85Tw6DSNZC7wC/1Y/Hm42cX
         X5CSXfHe6jj+IoBnquM8PGixnmh8qrv2JhVsgu8RdF/kOoePR5ItrRaGXuPoHQGbSDb6
         jTQtoArHYdMjKzrs9wXOThhNeyTcUc/K/NrckhzhmC7usXwfydRKcftakHQ2DWdtERti
         vP6xlY9uk6UQWzAzp6Tle1fURKFVU7HLM8bu+QKG+o4lShqKbtZZxCuid0sKbAAz+jnU
         qUyg==;
        darn=lists.linux.dev
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amacapital-net.20260707.gappssmtp.com; s=20260707; t=1793228183; x=1793832983; darn=lists.linux.dev;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=V0MpBzACJCm623um40rfrBkC0GCIrNAzwGLFIF9vVVM=;
        b=cJEtzxCQUKhWmoLfd869Jgb7IioClRZdvGy8QzpxVjlBra3pMBdqlqaQW7do6H8rnL
         TADJdYmwLLoerdg1Egk8xaoLHSBPd5qBarH2lPqCvVQdFmpSiqZc9amiJCy8oAzPaQBX
         piuadPq94LK2nZKkzCLm7/3eBEF3HE3Ax1H7MsFz+zsbSMBIibmmueyDi1+kXLyPOZBJ
         0oueSjR0ZVhxrFGwcjvlwChViAq6pmrdUMoytJRCJS9m/PzFGC4yey7SJCnqG6xybvVq
         U0B+MdMYHcGT0xAyi4lChmYKxQSUc6g8HPVnB5UXDhe7F8caDUmIWS+0DP9Aa5Z2ZsE8
         H6iQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793228183; x=1793832983;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=V0MpBzACJCm623um40rfrBkC0GCIrNAzwGLFIF9vVVM=;
        b=yTZLGzaSA59AqBfcwZamvHb7YSuOVNpAGkzSFY359bUhyA6mE/h36T++6jD6wQQ2Hj
         KMX+6Wv/kd8cXC+83IS3c9dJ3IiOm1ytRAgbwqAbXtBnTfE/6Cpa4nrbLBvRYaaUTZ6H
         iUgEJqX7ncr8W29h1XKTaqjF3iojHDuwRftJvq4TQCkPTCXXJu3HQRLAwi1swfH0JN3Q
         Jv05TplG832wGxUShXFB6GdSE0QmxSr/4t0+6TGJNyxJnGkKW0lb0iVMWbdoFz+llsrG
         n+bEJStMxbiQN37fFhMS0bVrgaakqCm2tQpZJjbUrTv2HMIFqnjPnw5pyavOb24hZyqQ
         uFnw==
X-Forwarded-Encrypted: i=1; AKwUvBzztGHhCeDaiHNQecAGa+hVJedMKEFkAUkRnpRUmeoHlBUjSMXQl/7zlatxw+X36FLSqkd55J4L97aS@lists.linux.dev
X-Gm-Message-State: AFq9FYJRlkYwWn4+8B7qG9QG0MlSZXn9vhN2uiqv4Z7c4kCRq0urdq7r
	1icKAY5QeRYnXxHMucjZTKHp9RIkfkPY97akzsFp9TSKoJl4HkK/7ez0T3ftHg+cjMlSePvfHeq
	RE23k4Tz6/wMsIBPiNfuQVgsLzlo1KY/qbD35go3I
X-Gm-Gg: AYBFou2Dc/+9meAoJ+Y7HmZeqmqeq9E69pSvWJG383f8Y8FR6TlLcxyblb5wjOvG+HZ
	Fgm44WQ4EnQEZg+ulvTUEeO8zqpKanIlFH5f41cJ0FiSNvcszTRN4F0kF7JkiKiEr0uojP13jgP
	zU/DQwdBrK8JCbBoNMVjrnqMv+2xyRLCDA+xkx1QVz2Kf53KU4S9p54wkdw/Gdh5bNVzvx0iTzG
	m9ieaEb/Xl/Kp8ds1at9doUYJ6f/bh2hNFDMyKZJ6uYD9D6gIcml7EZWp0+EAPOxkO50UGuo1DC
	ckdDuH28ZGOPxgrZsvi0dO5M3rjstI+A7R8iPDJLhu1aRGvSfpP4wwivIDAGlxu0a72yWfzBpg7
	8RexHRpiKZzx0ub8jvssJhlvuljJTt87ariFZPw==
X-Received: by 2002:a05:6512:3e19:b0:5bf:c239:71ad with SMTP id
 2adb3069b0e04-5bfcad69127mr1282221e87.38.1793228183136; Wed, 28 Oct 2026
 15:56:23 -0700 (PDT)
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Post: <mailto:containers@lists.linux.dev>
List-Help: <mailto:containers+help@lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
List-Owner: <mailto:containers+owner@lists.linux.dev>
Precedence: list
MIME-Version: 1.0
References: <20261028221705.3915340-1-halg@google.com>
In-Reply-To: <20261028221705.3915340-1-halg@google.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 28 Oct 2026 15:56:11 -0700
X-Gm-Features: AclHuK_P2NrO86m_OPGwNSCuxqmiVp7fbTt4tlVfFApQPbneLnvcqCjpUTpk6N8
Message-ID: <CALCETrW9ygriu54gxiHFLEd5+hJminQo0r8Jwd63wR69Dj4W7w@mail.gmail.com>
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

On Wed, Oct 28, 2026 at 3:18=E2=80=AFPM Hallgrimur H. Gunnarsson
<halg@google.com> wrote:
>
> When an unprivileged process creates a new user namespace, it is granted
> a full set of capabilities (CAP_FULL_SET) scoped to that namespace.
> While these capabilities are isolated to the namespace, they allow
> unprivileged local users to reach deep kernel subsystems (most notably
> networking configuration and raw sockets via CAP_NET_ADMIN and
> CAP_NET_RAW) that historically assumed a trusted caller and have
> accounted for a large share of local privilege escalation
> vulnerabilities.
>
> Many workloads and sandboxes use unprivileged user namespaces strictly
> for basic UID/GID, mount, PID, or network isolation and never need
> high-risk capabilities like CAP_NET_ADMIN or CAP_NET_RAW. Likewise,
> system administrators often want a host-wide policy ceiling restricting
> which capabilities unprivileged user namespaces may acquire, without
> disabling unprivileged user namespaces altogether.
>
> Prior work by Jonathan Calmels [1] proposed addressing this via a sixth
> per-thread capability set (cap_userns) alongside a global sysctl mask.
> During that discussion [1, 2], feedback (e.g. from Casey Schaufler)
> suggested that rather than adding another per-thread capability set and
> prctl() interface, capability restrictions could be integrated directly
> into struct user_namespace and configured via clone3(). At the same
> time, as noted in [1], a clone3() flag alone is not sufficient for
> administrators who need to enforce a host-wide ceiling on unprivileged
> user namespaces without modifying every userspace callsite.
>
> This series combines both pieces of feedback: it embeds a capability
> bounding set (cap_bset) directly into struct user_namespace, reusing
> the existing task cap_bset, cap_permitted, and cap_effective sets on
> namespace entry, and provides both a system-wide sysctl ceiling for
> unprivileged user namespaces and a CLONE_NEWUSER_BSET flag for
> voluntary per-namespace restriction via clone3().

Why should the task's cap masks affect this?  *Maybe* cap_bset makes
sense, but I'm struggling a bit to see why cap_permitted and
cap_effective should matter.

Also, I think that Docker in non-userns mode restricts cap_bset, and
the purpose of that restriction is rather at odds with interpreting it
as a restriction on newly created user namespaces for purposes of
vulnerability mitigation.

>
> In addition, because restricting CAP_NET_ADMIN at user namespace
> creation time prevents userspace from bringing up the loopback
> interface in new network namespaces, the series first introduces
> an opt-in flag to automatically enable loopback on network namespace
> creation:
>
> 1. Opt-in loopback activation on netns creation (Patch 1)
>
>   New network namespaces start with the loopback interface (lo) DOWN by
>   default, requiring CAP_NET_ADMIN over the owning user namespace to
>   bring it up. To block external network access while preserving
>   localhost networking, sandboxes commonly create an isolated network
>   namespace with only the loopback interface enabled.
>

The whole unshare/clone flag situation is getting out of hand, IMO.
And this new thing makes logical sense but is really about reducing
exposure.

Perhaps we should instead have a small list associated with a userns
(extensible in the future) of things that the ns's admin (i.e. whoever
has CAP_SYS_ADMIN relative to the ns) may do.  That list could
include:

- Create loopback with sensible defaults for ipv4 and/or ipv6 (i see
no obvious reason to separate them)
- Create tun/tap interfaces in that ns (and attach them, etc)

And add a very simple new API to do these things.  Actually, the
tun/tap could just use the normal mechanism.

Thoughts?

--=20
Andy Lutomirski
AMA Capital Management, LLC
