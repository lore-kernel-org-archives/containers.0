Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.72
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795085236;
	b=vDGMxYK+T/6AsdhheJoDTfzOIfJOqvj4ojFHrH8JmwknG72djNNw5WooMBTKrpVFfIUY
	 r2jMdwhRuiQttG4qAL4UoDopYskJNFJitgupflO87w5PR2L+eyR6vtLeoMgVDJOKH8NDt
	 zOMqRm2ESO6vCLr3DDm+6pwGgax85R+CX1Y9RyXDaAlB0MjdYYR8ZuEmBGWu1L6FFnlI5
	 tv5unbAJEV309bsvGIyythHfme/bWRpEpxkudoJhBN0VlOezWWV+U19mMxp4ZBp8Aab0w
	 losMV2C6g+By4leotJ1YgT/4r/GslTy+3YriOBYztMdlXRIpQF+ti+0yIa/ccF15ijw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795085236;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Received:Date:In-Reply-To:
	 Mime-Version:References:Message-ID:Subject:From:To:Cc:Content-Type:
	 Content-Transfer-Encoding;
	bh=67I3bNEfcu+N7yXs6EAi+/lBjbBrobM44S6SPv9jyFg=;
	b=zUjG+bk33oVfDYAMjiPDu31fKFQ1sgH0wtMDPwBqODTelxF/oOuuYjskyLuRWeQ09JiJ
	 sOifihPA0K44LNyk8aIYaDWC3WO+boz1Q8YAhZCLTyLdEGoGsID3MdZid0alT4RuEjSZN
	 dFyxSPSQUpJj1HjxWwapV9q4uxQghJAk1veL5XqIRtCFdJjIPvoW9i+ZFhfcs7U00/OE0
	 qKdL7jz3IYdK/zFT+w3xUDRdltXLbzFY0AJ7YQ1bXm2Ml3rZSc6R/z/OG2Pd/LpEMMbAO
	 wcj9j3Aupjx6k2e3XZy+RCNBe5ozNPudtiR0F8fjWWWnnz/KGpkw4EQ2jvYMnTT7mEw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=google.com;
	spf=pass smtp.mailfrom=flex--halg.bounces.google.com;
	dkim=pass header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=DurusoPk;
	arc=none smtp.remote-ip=209.85.128.72
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5A7AD606A326
	for <containers@lists.linux.dev>; Thu, 19 Nov 2026 10:47:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 5A7AD606A326
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--halg.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=DurusoPk
Received: by mail-wm1-f72.google.com with SMTP id 5b1f17b1804b1-4ba078abd78so15330905e9.1
        for <containers@lists.linux.dev>; Thu, 19 Nov 2026 02:47:16 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20260707; t=1795085235; x=1795690035; darn=lists.linux.dev;
        h=content-transfer-encoding:content-type:cc:to:from:subject
         :message-id:references:mime-version:in-reply-to:date:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=67I3bNEfcu+N7yXs6EAi+/lBjbBrobM44S6SPv9jyFg=;
        b=DurusoPkBFMam/pM7ZYoDob+n/eRtem5K3P4LrtTjTMT2mEo3kDrk0YXWgBC2kM+NS
         p19MknBWOJzwDXnNm5GivlFvfPnRttwJoaHqxgk4j6WJnONGqtLuK+y3HtwMNRtKriE4
         cSuxQfjf8O+gin7oCDsV97arhqGIaUJ76YOMOxJnklNyKTnnTbxuN0m0Yyi2wyH7ORXL
         1DfjvR9zzyRvKxZlm2wVT3vH/FM6l4xBAgMABSK3cH5kDtI+SOsEsxA0IaVEcEPLSiPr
         czo73pmSWxEahJDsg+w8SKn/XUfA4EIcSYBBE5pnTZQK4FGHAHU4LsCrs3WyiC6MFbJG
         X9Lg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795085235; x=1795690035;
        h=content-transfer-encoding:content-type:cc:to:from:subject
         :message-id:references:mime-version:in-reply-to:date
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=67I3bNEfcu+N7yXs6EAi+/lBjbBrobM44S6SPv9jyFg=;
        b=hOos1onq84wffzxCA/wr+XinE105ZVJx3n25eJC+rCqoxUqqJREe6Eg/hxQmRIzi0P
         lhf4bOVJ+prfFkxQeHow4TTDLSylAYYmu3ssUGkZ1W7fVV3RiXIACstlegrCI7DLZq87
         OB3h5eQSbX/ToU0x9gcdkX1yO8FL4HyJhV0adZFe9L7Adg4X1wJeUcaqt8ASbksYth3E
         A9zdYeyjDEvoZ3xdXRZoE9cJ0YE4eBtSV7ELoQBg4kRBWxAhzbcoii0ZYAtU6+n15TWX
         WWDajfX3EBX2ExR1SLSzsfwFvBHEvT9+LLUnRpEBUedN62vcztjVDo2ceYcsDmdEPs7K
         +YKA==
X-Forwarded-Encrypted: i=1; AL+hErELoM0YlPj/mgjjn5DaIHLY6k8VR8j/1b1S1oSHiAdOM1HGZXxCantMtOuHyOxDvxWnukKUmJYXk0wC@lists.linux.dev
X-Gm-Message-State: APuU4Z/4u8bPEonJ76OzL/XRWx3f/2ZsFYXW6a0VxNAdQOcKGIkxIdXH
	VZvyozjX79anHLff+AMcz47r3nR6dQlCdkunTW34hao6E9mZNhyE4z9DHuxpCqZEZLOlD1w2HA=
	=
X-Received: from wmwb7-n1.prod.google.com ([2002:a05:600d:4447:10b0:4a1:a2ef:38dc])
 (user=halg job=prod-delivery.src-stubby-dispatcher) by 2002:a05:600c:4e56:b0:4bb:7581:2bb9
 with SMTP id 5b1f17b1804b1-4bb7da3003emr104763395e9.22.1795085234352; Thu, 19
 Nov 2026 02:47:14 -0800 (PST)
Date: Thu, 19 Nov 2026 10:47:13 +0000
In-Reply-To: <20261118.faiBee9Taigh@digikod.net>
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Post: <mailto:containers@lists.linux.dev>
List-Help: <mailto:containers+help@lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
List-Owner: <mailto:containers+owner@lists.linux.dev>
Precedence: list
Mime-Version: 1.0
References: <20261028221705.3915340-1-halg@google.com> <20261107.aighieG4Ami1@digikod.net>
 <20261118.faiBee9Taigh@digikod.net>
Message-ID: <av7TsXKUE69lyiWl@google.com>
Subject: Re: [PATCH 0/8] userns: per-namespace capability bounding set and
 opt-in netns loopback
From: "Hallgrimur H. Gunnarsson" <halg@google.com>
To: "=?utf-8?Q?Micka=C3=ABl_Sala=C3=BCn?=" <mic@digikod.net>
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

On Wed, Nov 18, 2026 at 03:43:03PM +0100, Micka=C3=ABl Sala=C3=BCn wrote:
> Hallgrimur, could you please explain why your use case would not work
> with Landlock?  The capability split or new clone flags would be
> complementary of course.

Apologies for the late reply.

Landlock's capability restrictions work well for self-sandboxing
applications and launchers. The main gap for our use case is setting a
host-wide default for unprivileged user namespaces while still permitting
exceptions. Because Landlock restricts all capability use (not just
capabilities acquired via user namespaces) and its domains are strictly
irrevocable, PID 1 cannot apply a default policy at boot without
locking out privileged services, file-capability helpers, and authorized
workloads. Using Landlock here would require explicit opt-in enforcement
at every unprivileged transition boundary (SSH, container/job launchers,
etc.), where missing any entrypoint leaves unprivileged user namespaces
unrestricted.

In v1 we had the global sysctl to tackle this. In v2 (based on Christian
and Andy's feedback), we combine per-cred cap_userns with per-userns
cap_bset), and PID 1 or a service manager can lower the default userns
ceiling once at the root of the process tree, while privileged tasks
automatically retain capabilities held in cap_permitted and can
explicitly raise cap_userns for authorized workloads unless locked.

Another minor difference is visibility. Clamping the task's capability
sets on userns entry (and exposing CapUns in /proc/<pid>/status in v2)
makes it easy for userspace to inspect what is actually restricted.

