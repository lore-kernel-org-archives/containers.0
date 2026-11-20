Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.218.72
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795174506;
	b=Ofob+8koiOm+DEc6tITre+ZERvqAkR0Xheq+MrO4YvUWXYcSPATg1gh6xvf3qvAJ34i+
	 75HOmfxKXGhg8Y4Cy0P/WXDvLyiwBm0Wiy1jcBcEQG1xbwnXNoRh+zccxjwa70KQZK9cK
	 Yl4C7TMX45MBxZEN/M1inD6ksXrpnjIP3pJaUf4GoHJlt9iYka+h4r1ZBRJy82bO2Atex
	 KnVXjiKYzeBS1C5PXqcWkBKrz2H4vMM0qtxsc34p6jyo2rXy0rlSHV+NMXVxfkchtCfEs
	 O2Lf1VfBYkAP3yNq1dO12lzoKlFvN/DKfq+2FoQ1P+Uc8eEYaMcod8CwUinwkq6CnhA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795174506;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Received:Date:In-Reply-To:
	 Mime-Version:References:Message-ID:Subject:From:To:Cc:Content-Type;
	bh=bkrqVl4fOtFiXo/UNE5/tK7V61bZnqlZiu3NzPQivMI=;
	b=cSNoDx3uMhML/2XVVVHG8dBi26FEMq6cULTcqqKcGAcwMPHr6uzZEfSqcGVQD4EqqSIq
	 aO4Atg5Mksi8Xz2jRR08EMRn0M8LgG1tcwDs1Qs+6MbSrN/8xhLZaYrY8zzUFKMr3/X1K
	 OW/tWOW3yL7mKF1m0vHLUxuXPaxLuE62RumWVThds9dV+pXKpiMxsxmfBT6qKlqgv2chH
	 YykE7kXZ8yHfV+Zi8fvWB87NAoXHElFAP9hQ5oSqitXVyGGv/swJB7KUEE4kscIMYqqbu
	 q3h2XgteZ8UpAi0JP9fFI1KHFeUhOcSWIYn8G0lGf1WG2+npaQSkQPDRQegjBK+zuVw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=google.com;
	spf=pass smtp.mailfrom=flex--halg.bounces.google.com;
	dkim=pass header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=YIMBgsjn;
	arc=none smtp.remote-ip=209.85.218.72
Received: from mail-ej1-f72.google.com (mail-ej1-f72.google.com [209.85.218.72])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7D1EB606A325
	for <containers@lists.linux.dev>; Fri, 20 Nov 2026 11:35:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 7D1EB606A325
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--halg.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=YIMBgsjn
Received: by mail-ej1-f72.google.com with SMTP id a640c23a62f3a-c505eecba6cso88768466b.1
        for <containers@lists.linux.dev>; Fri, 20 Nov 2026 03:35:06 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20260707; t=1795174505; x=1795779305; darn=lists.linux.dev;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=bkrqVl4fOtFiXo/UNE5/tK7V61bZnqlZiu3NzPQivMI=;
        b=YIMBgsjn2mat4IMpcMLDoVnL+VrvK4ZWKpSpkGgB/bwk8+mEn+o+2m3mD1O2AhjCYG
         UOrzoJ2SVAlyEcRmyyH9tsOsczv5Y0MYh3EL6HftrHwgW95xIo5i12cHulvcbCt/3ys4
         9GlAUUQ34ZUuQJsu/fUuQteAvAZTfVtNAhAYZ/di4v7QFFxtOxTECkQV5pyAXESHQxGS
         OmcmBdwnE74P/NPF3VhpPioOE+aAiHfyUCs2ZG/15r5GvDQlksVwQfO7Jc8SSzZRhP/f
         Hmt02gdh/HtKwkFQm4fN47P0Hq0RZiC/Q7s42lncO5C3YQShazdyoGFVKGKE+DEFfE07
         /sjg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795174505; x=1795779305;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=bkrqVl4fOtFiXo/UNE5/tK7V61bZnqlZiu3NzPQivMI=;
        b=pGiyyPuwLwevwUrvfiiAWJqEdsJdUqcW9M/1tThZ5/cYdfM0U4ysKKi1T2g2jxHiZS
         YtL2GXI5dNxd6CYGRcOKrE9Oe2bAeyiCLAV9RHhVJP9xpJjLYXJ/i6FZ0hmBGUaRyAgL
         7EJvwF1rrdACdY7EfC8ggsAXooinTLLGvRrlIv1zsKe2DFkoJGoY91a7RiDnDQwPGWDc
         ANXp3vszYcprvdx779YTfhYv3eRH70M4Vbh0Ckj8KDQjEFvtvp9DKnx5uKf4Ix8kDOAp
         KPSJs1+RUZtu5dBrMU5pIDyDZ0SdgMZZfn4BFZptm5ZGjJifoc43n+yARNJkMFsgPM/e
         e+lA==
X-Forwarded-Encrypted: i=1; AL+hErFVGNCxIoA4DK9evwK1yMtK8j9+xB7XzMBjaWRqO4Ni4vPKEEjeQnxxYT3GP6y/A4FScuLK2TTlUhMm@lists.linux.dev
X-Gm-Message-State: APuU4Z8Zosn30Pbz8DwyrobTbmAUTjTgQ8oVH73+GdWlbMqzHnLw4y+E
	JehI/I8IiIa81Evf729yxpZG432NGjEbU+7R0hYspP1O09A1si/5UX11Je02DoYDQYBY727A3w=
	=
X-Received: from ejcmy22.prod.google.com ([2002:a17:906:5a56:b0:c50:5767:f11e])
 (user=halg job=prod-delivery.src-stubby-dispatcher) by 2002:a17:907:3e28:b0:c41:7e99:c6c2
 with SMTP id a640c23a62f3a-c513ac99405mr295016666b.44.1795174504655; Fri, 20
 Nov 2026 03:35:04 -0800 (PST)
Date: Fri, 20 Nov 2026 11:35:04 +0000
In-Reply-To: <sashiko-outbox-223014@kernel.org>
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Post: <mailto:containers@lists.linux.dev>
List-Help: <mailto:containers+help@lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
List-Owner: <mailto:containers+owner@lists.linux.dev>
Precedence: list
Mime-Version: 1.0
References: <20261119104208.782900-1-halg@google.com> <20261119104208.782900-2-halg@google.com>
 <sashiko-outbox-223014@kernel.org>
Message-ID: <awAwaJugal622uZf@google.com>
Subject: Re: [PATCH v2 1/4] userns: introduce capability bounding set for user namespaces
From: "Hallgrimur H. Gunnarsson" <halg@google.com>
To: sashiko-reviews@lists.linux.dev, Christian Brauner <brauner@kernel.org>, 
	Serge Hallyn <sergeh@kernel.org>, Andy Lutomirski <luto@kernel.org>
Cc: Paul Moore <paul@paul-moore.com>, James Morris <jmorris@namei.org>, 
	David Howells <dhowells@redhat.com>, Jarkko Sakkinen <jarkko@kernel.org>, Kees Cook <kees@kernel.org>, 
	Jonathan Corbet <corbet@lwn.net>, Shuah Khan <skhan@linuxfoundation.org>, 
	Randy Dunlap <rdunlap@infradead.org>, 
	"=?utf-8?Q?Micka=C3=ABl_Sala=C3=BCn?=" <mic@digikod.net>, Jonathan Calmels <jcalmels@3xx0.net>, Jann Horn <jannh@google.com>, 
	"=?utf-8?Q?G=C3=BCnther?= Noack" <gnoack@google.com>, KP Singh <kpsingh@kernel.org>, 
	Casey Schaufler <casey@schaufler-ca.com>, linux-security-module@vger.kernel.org, 
	keyrings@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
	containers@lists.linux.dev, linux-api@vger.kernel.org, 
	linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="utf-8"

On Thu, Nov 19, 2026 at 11:11:50AM +0000, sashiko-bot@kernel.org wrote:
> [Severity: Medium]
> Does bounding implicit owner capabilities by userns_has_cap(ns, cap) break
> cap_ptrace_access_check() and cap_ptrace_traceme() for a parent namespace
> owner when CAP_SYS_PTRACE is excluded from the child namespace's cap_bset?

This is working as intended. Implicit parent-owner capabilities in
cap_capable_helper() are uniformly bounded by the owned namespace's
cap_bset.

Concretely, this only prevents an unprivileged parent task from
getting implicit CAP_SYS_PTRACE via ownership of a child userns
where CAP_SYS_PTRACE was explicitly stripped. Holding explicit
CAP_SYS_PTRACE in an ancestor userns (or owning an ancestor userns
that still includes CAP_SYS_PTRACE) still allows tracing.

This is also unlikely to come up in practice, since typical denylist
configurations would only strip high-risk capabilities like
CAP_NET_ADMIN and CAP_NET_RAW.

If we wanted to make an exception for ptrace() to still allow
same-UID owner tracing when CAP_SYS_PTRACE is stripped,
cap_ptrace_access_check() and cap_ptrace_traceme() already allow
same-userns tracing without CAP_SYS_PTRACE when the target's
capabilities (and userns ceiling) are a subset of the tracer's.
Extending that check across owned namespaces (similar to
cred_cap_issubset()) would be straightforward, though I'd prefer
to keep the stricter, uniform behavior in v2 unless there are
objections.
