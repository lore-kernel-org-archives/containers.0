Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.218.72
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793893025;
	b=rGDPwAbahIl1Ubesu7vcKtn7/cZLtcD4GLWKiYHrvBC6iDBEK7yy/QPTiHxeev2D6YeH
	 4QA9C4VwVSxrZaZ2ch75M3DH7w1uBZF3w1ChAuBTK7X6d8ehpwVn2pQkbD8hg1KnPE70p
	 pspgnT5cOpvuHJiX0fq+1pzFnzfVtLdZkOqx5QIAviwL8SdweIoMX6HDEznNWm7Lk7lLI
	 RKQNJknTuaEuEMRFyGqM099CT0EpKw0yorwtuvaCwnNytGk13FFgfVjoTdMKPx1NxP8qW
	 nsx4vVqhL/4PDlJWs8g+QddHreJll3vr1rpfCEl5JJ4iBU6rwyupAjrPCH7oiKnOrqA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793893025;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Received:Date:In-Reply-To:
	 Mime-Version:References:Message-ID:Subject:From:To:Cc:Content-Type;
	bh=kvailjwqfOmhbJJjcy8TbvowePxzON+06QO6Up9gGT0=;
	b=UMtXJ8RV9VpX6orAZ/tDmN59thLw0zlcsG0gX71SQ/kNodLhAfma49p+XHzk3q48EGjb
	 CrNYfRrHTyn3cYni0+KCs9DhxZ23BELMa3L22Tz7EbqEdLtPPBTBummsTmN1WpXRyBUxg
	 26IjF8fxEdy+l8Bt423sFjwODyHJn4xJQO+mKd6TG/lqANrt+slZGVgEfJRcoecFqtNX5
	 vQ/tQtdpVMlQ4eamacrUuWpvOLq32M1slu4TrTfsV7kkMpMZ5mHrgagzU1VRjA5ezvtHt
	 4k8X+kXpOKUe+ge/qWeBan1BVbCcUMBBHEJVjJhQndG9Rm6tXykjVduD+utSe3qlMWQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=google.com;
	spf=pass smtp.mailfrom=flex--halg.bounces.google.com;
	dkim=pass header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=mhhfLmo2;
	arc=none smtp.remote-ip=209.85.218.72
Received: from mail-ej1-f72.google.com (mail-ej1-f72.google.com [209.85.218.72])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 40342606A326
	for <containers@lists.linux.dev>; Thu,  5 Nov 2026 15:37:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 40342606A326
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--halg.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=mhhfLmo2
Received: by mail-ej1-f72.google.com with SMTP id a640c23a62f3a-c40bbd26f74so214855966b.0
        for <containers@lists.linux.dev>; Thu, 05 Nov 2026 07:37:05 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20260707; t=1793893024; x=1794497824; darn=lists.linux.dev;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=kvailjwqfOmhbJJjcy8TbvowePxzON+06QO6Up9gGT0=;
        b=mhhfLmo2aJc649NBzBJfL2gbxKMXoijMr1YC4gX+bgNMK0vgT3MxN1EYBat+ZkoRwZ
         6nLpe1qeVoKF5CBzxw0DFqBUPfAprMCh8ggkG5/x+dXjhOe9F1k4E9lkV5Y9hujN//15
         JyqJqODKJPp4FIqfM6BqTur/ui+ttsaYOspbhHA9sUMmBjSwu0L1KYEYBE7lumrVbGEr
         qOH7q25c9UKMYawHVFa5qlSA751TVVnP+YjttlwIX8jjmyfmrs17rMbOCMjhVF34v79Y
         k00NAVqOJQR4crpA4hmAXL13QyvyT+yob/CydayUz7NyCpF+DA7gZr2ANKI+k2nQbrAs
         kHpA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793893024; x=1794497824;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=kvailjwqfOmhbJJjcy8TbvowePxzON+06QO6Up9gGT0=;
        b=TmfX1/Mp1aS1Gw1OCc1KowBRUD9V8jhRH+J5cB3Z13tlVmIdytFWYHUHQ46xN7fDX7
         rfryl7kTiWQDNj0pio5KvoSuRAhcr8nVoftuZBg0OHqZt52j31qnrs1iHiHy7yUM4g4E
         NWsxHTVbS4II3oN3SIF6dLc5S4PzQnWG80yur9XzygzOUKw7Ac2b1EzvuT7Xpa9LJ8BU
         4sN2dfAQKYNz7NdIC7lEePX7B/iQy/dpYv3CceD4w7Gr5kiw+1pG9ZGoiAXen3RBdqZX
         71MiyXLTqE9CsfyqvMY+usW9Ci4RgJFHEg8va3lIAZsC9x3nIRz5DFcshEBPNBOgreL2
         wh4w==
X-Forwarded-Encrypted: i=1; AKwUvBxMqtsOIfMXHiYqnJeeQ8bUF72RkhfyT6AnY0jHnuVyfthSEJp3oqe0ICM9ByaN7s4oG+ouzHkUJY0I@lists.linux.dev
X-Gm-Message-State: APuU4Z/B0+wgrmmJD6RBooQN6/JQET6yF65eGe+iprWeMViLruIf9e6A
	u+MteYeTb8/telFjCwqrAi+87jJ+OjlAj6HRRv4b2aXfhVSB+f3x177I/A3tP8jLX+KYKE48Aw=
	=
X-Received: from ejcwz8-n2.prod.google.com ([2002:a17:907:b048:20b0:c4d:23d9:b0d9])
 (user=halg job=prod-delivery.src-stubby-dispatcher) by 2002:a17:907:cb88:b0:c26:19e3:e98d
 with SMTP id a640c23a62f3a-c4ca7af17a5mr1750569566b.45.1793893023363; Thu, 05
 Nov 2026 07:37:03 -0800 (PST)
Date: Thu, 5 Nov 2026 15:37:02 +0000
In-Reply-To: <aunVmg42/S2uUDWR@hallyn.com>
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Post: <mailto:containers@lists.linux.dev>
List-Help: <mailto:containers+help@lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
List-Owner: <mailto:containers+owner@lists.linux.dev>
Precedence: list
Mime-Version: 1.0
References: <20261028221705.3915340-1-halg@google.com> <aunVmg42/S2uUDWR@hallyn.com>
Message-ID: <auyink594bxptAPN@google.com>
Subject: Re: [PATCH 0/8] userns: per-namespace capability bounding set and
 opt-in netns loopback
From: "Hallgrimur H. Gunnarsson" <halg@google.com>
To: "Serge E. Hallyn" <serge@hallyn.com>
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

On Tue, Nov 03, 2026 at 06:37:46AM -0600, Serge E. Hallyn wrote:
> Generally, if I, or some users I support, need to use unprivileged containers
> or user namespaces, then when an 0day comes along, I can hopefully trust them
> not to exploit it.  The biggest danger comes from the fact that, right now, if
> they can use them, anyone can.  So if someone can trigger some other code running
> as user nginx or something, that can become a root vector.
> 
> So what if we had a built-in feature or LSM which implemented a credential based
> whitelist, entered at firstboot?  Something like
> 
> ```
> # Default deny
> uid == 1000  # approved
> 1005 < uid < 1010  # approved
> gid == 1005
> security_label = lxc_user_t  # Not sure how far we want to go with this
> tty # must have a session
> ```
> 
> Now, if you want to use user namespaces for generic sandboxes for all
> users, e.g. to confine browser activity or nginx modules, then this model
> may not fit.  Or rather, it might need a few tweaks.

Thanks for taking a look and sharing the credential-based allowlist.

The latter scenario (generic sandboxes for all users) is actually the
primary use case that I'm targeting. I want to allow unprivileged users to
create user namespaces, e.g. for sandboxing, but without granting them
security-sensitive network capabilities (CAP_NET_ADMIN/CAP_NET_RAW) when
they are not strictly needed, given the historically high risk of local
privilege escalation associated with them.

The two approaches target complementary layers of the problem. A credential
allowlist at creation time controls who can create a user namespace, while
this patch series controls what capabilities are available inside that
namespace (and its descendants) once it is created.

Gating creation works well when there is a clear boundary between trusted
and untrusted users. However, in a multi-tenant environment (like a large
container fleet), we generally treat workloads as untrusted by default.
Because we still want to allow these untrusted workloads to use unprivileged
user namespaces for sandboxing, it is essential to keep the attack surface
small and follow the principle of least privilege whenever possible.

More specifically, this patch series enables that model of safe sandboxing
across three key use cases:

1. Configurable capability stripping: Administrators can enable unprivileged
   user namespaces for all users to support sandboxing, but configure the
   system to strip CAP_NET_ADMIN and CAP_NET_RAW by default in new user
   namespaces created by unprivileged users. Basic sandboxing rarely needs
   these (except to bring up loopback, which Patch 1 addresses via
   CLONE_NEWNET_LOOPBACK).

   The per-namespace bounding set can enforce this either globally via the
   sysctl, or explicitly via clone3() at the container manager level. This
   restriction is monotonic and persists down the namespace hierarchy.

2. Selectively granting CAP_NET_ADMIN: Some containerized workloads
   legitimately need CAP_NET_ADMIN to configure advanced networking for
   sub-containers. Because an unprivileged creator's child namespace is
   bounded by:

     parent_bset & (sysctl_ceiling | creator_effective)

   a container that is explicitly granted CAP_NET_ADMIN in its own user
   namespace automatically propagates that capability into the bounding
   set of any child namespace it creates (unless it is explicitly
   dropped).

3. Dropping capabilities for nested namespaces: If a container with
   CAP_NET_ADMIN needs to spawn an inner user namespace to run untrusted
   code in a nested sandbox, it can use CLONE_NEWUSER_BSET to voluntarily
   drop CAP_NET_ADMIN from the inner namespace's bounding set. This
   guarantees the nested sandbox cannot access the capability and the
   restriction persists for all further descendants.

As a quick clarification on how this interacts with the hierarchy: the
bounding set restricts tasks inside the namespace and parent tasks
relying purely on the parent-ownership check. It does not restrict
tasks in an ancestor userns that inherently hold the capability.
Therefore, in the nested sandbox scenario above (#3), the parent
container with CAP_NET_ADMIN can still configure the sandbox's network
from the outside (by using setns() to enter the nested netns directly)
even though CAP_NET_ADMIN is stripped inside the sandbox userns.

