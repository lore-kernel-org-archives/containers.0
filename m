Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.218.71
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794847388;
	b=b+81RdqocTH8WW2finGWjTJcWQAvCDp34j/bgJAm5kz1QsiOaePDHKOl3LBftwA+MIOu
	 OWClzC+Ld4jksoEupSJeXRvvkd9fuBqm3t999SMcDeQFTlKzh9tjntcsSJ9Lta8zRfSgb
	 teLnXyISG1OY/xTCUTsgL2UtrNhwJkQis25UiEBgOZAIJpII7mi+2LykdQCici5kvdn9E
	 nXUQ699b8Q0lB/fPBnfMj/r51E3ByL08ooy0oDoxPemiBrg64vmNP+BJX9VI3vrCq5Pf4
	 51SpjZf3AvvrCNuYyuuRAt7ljW54N4bGZE3259VhKXTrXJp0af8tBtr4rRieZBeDpBA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794847388;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Received:Date:In-Reply-To:
	 Mime-Version:References:Message-ID:Subject:From:To:Cc:Content-Type;
	bh=mDfU+sS9f1CGfQAVDBxxcGKeVZ+qJ/3ua+e3uJH5HXA=;
	b=0f8GbYugN0WSwgQ/7m47j0FLT9DDYKxj9GR7C+YGeRMN+YERZRStKLxmG6OLBtYFLXGl
	 8SFgjEGeKNIZPXG4eNOo7aqEWyXwX2K+9sWRDHDA/KOhtkFz1j0dkBTH3XyImyYeL8jNK
	 z77ESRVwvioyWRlFIS1euKe599hVfkZsYj6fAWVoxMFOxAJ4xBCVMA7JR3AQEPrxnBewd
	 h1WAefqllYZ+xWoxbW1jgAzlB3MyH4S6FU7TYzjO9Htm0Ql5xf78NPhsKG0w4+8gxUaUk
	 9ob24qd+CY9qKSZeEkvyKMGyXi8GiJvO7UHDk5Mu+F4k8t4oYzCzQ4YZTazv7OlBHNw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=google.com;
	spf=pass smtp.mailfrom=flex--halg.bounces.google.com;
	dkim=pass header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=NdrVgvgF;
	arc=none smtp.remote-ip=209.85.218.71
Received: from mail-ej1-f71.google.com (mail-ej1-f71.google.com [209.85.218.71])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7264F606A333
	for <containers@lists.linux.dev>; Mon, 16 Nov 2026 16:43:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 7264F606A333
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--halg.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=NdrVgvgF
Received: by mail-ej1-f71.google.com with SMTP id a640c23a62f3a-c50657eaef0so369700866b.3
        for <containers@lists.linux.dev>; Mon, 16 Nov 2026 08:43:08 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20260707; t=1794847387; x=1795452187; darn=lists.linux.dev;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=mDfU+sS9f1CGfQAVDBxxcGKeVZ+qJ/3ua+e3uJH5HXA=;
        b=NdrVgvgFKc0f2gsnFJ0dx7UrD9ZAyyXWzbwCR2+V1my0oLmjKYvZI58qVkWsaD4ARx
         Zgtn6aHIp3mUwrwzBrZ2hmuheC4Aeuzh7+wN6rW6Z/m2T1wqJ9FuQ4h9oEHizeFF+hxN
         aGxwwWGs4DJiEjjCkiHZ+rju52xuGupjLQTl2kjXIhfHb2wKY9lcEYtpZaMd7Fcolzk9
         qQhYFXNy5ooOCJzrb5Ix2z1HfxGsDxk8wWdUCEwIrqJtlNiysDikLM5X2q6G5W/aDkYw
         mWLZE63gHN9aXKvBrWArf04a7jHE3xvVZsHCUsMolRrgLT+D1wrMJUvcrvj4rMssqYsD
         Pfzg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794847387; x=1795452187;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=mDfU+sS9f1CGfQAVDBxxcGKeVZ+qJ/3ua+e3uJH5HXA=;
        b=hcHRtM4a1Uj8p0+w2HnZzp1ZICh7i5vyWJGIH57M/Gp3XDWSl2HUcZFeUaXYussTKa
         srroLrvm4/ty5q7tVtfaFLKOhfAgcVzMjkKzP6JaJB5B6CNiZfzj8/iwyWId74wzHILi
         S7C0iQXi14XSvFopoECCcfnxkDYJDu2RcO9Qz/B75kpwx/5VxaISATU5VGg2SLlBLt5h
         e2EwEEwtu/BT58hAkpLUn7q1xynW/wBcSvjPAGoqie3ybhE34XnnxkIPuG7X71thQPOs
         7A5eRwihTolUWnE7u4B7pVX6YpJGEQn5I4KdZSpfJozcE4Kswqapts935o5BoYdSf2m4
         Fc7A==
X-Forwarded-Encrypted: i=1; AL+hErELBlcqmS7TTVW/5FE/YdwBpEYt5Z8ylgkyXapL8DCVkYIgtVP6Ef6GL8V3boZZX8rW5VYWSeKI7lNo@lists.linux.dev
X-Gm-Message-State: APuU4Z97zC8HYOmXy615r4evA4yOoMocVutLdqef2XgIVZp3dYX21AWU
	6upORMerManz4du0b9wU/8FYWkgL86Gp/bJNa+7fNbjI3NXdDf1iMHb2Tly9LVG0p/PtyPxXKw=
	=
X-Received: from ejja21.prod.google.com ([2002:a17:906:3e95:b0:c3e:edc5:36b1])
 (user=halg job=prod-delivery.src-stubby-dispatcher) by 2002:a17:907:6d08:b0:c34:e9fe:82ed
 with SMTP id a640c23a62f3a-c50963d803amr901765866b.28.1794847386433; Mon, 16
 Nov 2026 08:43:06 -0800 (PST)
Date: Mon, 16 Nov 2026 16:43:05 +0000
In-Reply-To: <20261111-behagen-faktisch-entgegen-e2e714373895@brauner>
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
 <20261106-befreien-addieren-eislauf-e09212803534@brauner> <CALCETrWa1SBLcb5oWjqjgzZvKvCoHjmYFk=Lf5ytEM9uqm5jYA@mail.gmail.com>
 <avM41a80aig2de-R@google.com> <20261111-behagen-faktisch-entgegen-e2e714373895@brauner>
Message-ID: <avsymRBSulVZfouF@google.com>
Subject: Re: [PATCH 0/8] userns: per-namespace capability bounding set and
 opt-in netns loopback
From: "Hallgrimur H. Gunnarsson" <halg@google.com>
To: Christian Brauner <brauner@kernel.org>
Cc: Andy Lutomirski <luto@amacapital.net>, Alexander Viro <viro@zeniv.linux.org.uk>, 
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

On Wed, Nov 11, 2026 at 04:20:02PM +0100, Christian Brauner wrote:
> Just a note on the essay I cut off. I really object to any arguments
> that amount to "it's too much work" propped up by a few thin arguments
> sprinkled in such as rtnetlink.
> 
> I also reject any arguments that amount to underscoping and overscoping
> of the new capability. The scope is clear: empty netns with brought up
> loop device.

Understood, thanks. I'll split the loopback work out into its own
standalone series and handle it separately, keeping the scope strictly
defined as you described.

> But again, I'm more focussed on cells so here's what I find acceptable:
[snip]
> * a new CapUns: line in /proc/<pid>/status
> * new audit mask in AUDIT_CAPSET record

Quick question on AUDIT_CAPSET: today it's only emitted on capset() and
only logs capability sets that capset() can modify (explicitly or
implicitly like cap_ambient). It does not include cap_bset which is
modified via prctl(). Since capset() never modifies cap_userns either,
does it make sense to treat it like cap_bset and leave it out of
AUDIT_CAPSET, relying on prctl auditing instead?

[snip]
> That gets rid of the sysctl, the clone3() field and the clone flags,
> doesn't need a new capability bit, and nothing changes for anyone who
> doesn't opt in, I think.
> 
> And that loopback thing should be its own series. Not as an nsfs ioctl
> though. All nsfs ioctls only report namespace state and I'd like to keep
> it that way.
> 
> Pipe this through an LLM and make sure it makes sense and covers all
> holes.
> 
> Thoughts?

Thanks for the feedback and the detailed proposal. It looks good to me
and nicely ties everything together. I'll prepare a V2 for review based
on this hybrid design.
