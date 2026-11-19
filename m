Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.218.71
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795115996;
	b=2sYvYg7Z5NlOWz5ZbCsCKfAMI0HVTOD/DOWNz25rHiP6UPa+2QYFsqNHLWiMwSPwHPvM
	 TS3KI5yETcitnG01zmt2u/VRCFev4TUe1IRDatdADLePFg8Q2LgV7riPh7KASjDw29Ph6
	 UktzYzwdnpmA/x/lnG8udowGIq3E6DAEQDpc8WEQaX++YG/G9l4w6rFk20uRjbWfkQgRu
	 HrwKaIR3+B0Pf7hpiLkgGYo39RCxgWwLZOR6zRSxcB/9QsUNvEvZnu81Wtaqxiit7DvLp
	 2YjjO2BcR1kuaMj5ugUZ2X9LCn9rmSt4oisdHMDecVZ3Jgrtr6J2PZyEPMavLXfWxyg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795115996;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Received:Date:In-Reply-To:
	 Mime-Version:References:Message-ID:Subject:From:To:Cc:Content-Type;
	bh=B3fPYwtnhJtRTzUId1FsxU5BbcK59iDRRgRTHG4g8TM=;
	b=QG5c1Pa8RoRLd1iHO3ZfOYoeZ7e+24OtqgZdgvZPpMqa50iWzu8w9DmhcQ87WGteKt9A
	 AVEmSuvXL9DsD9waELGmZnyrui9ktJVBEfoIVPAAYCTT+bN2StSG0Exk8cy4wEWOQt53K
	 GgD6IY89XbLZ57HB4hL2s2Jrlq3KwD888z7oY26xqWHdsQLfOUrqQX7+YNqODE25V3cx5
	 Q4rH7Ixpkdn/27/edC9eLzXsht+x6wxY+TM9KA/XEgmZS0iDAo7f4Fki/sjILe3XAh/7P
	 aHGn9tnU2ROaFH5NLF21pRQqD3FVbBOqMtFe8xHIy3Ylpgqsskio6LDboxM14aAU+PQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=google.com;
	spf=pass smtp.mailfrom=flex--halg.bounces.google.com;
	dkim=pass header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=gSOVx2XE;
	arc=none smtp.remote-ip=209.85.218.71
Received: from mail-ej1-f71.google.com (mail-ej1-f71.google.com [209.85.218.71])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8EBF0606A334
	for <containers@lists.linux.dev>; Thu, 19 Nov 2026 19:19:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 8EBF0606A334
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--halg.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=gSOVx2XE
Received: by mail-ej1-f71.google.com with SMTP id a640c23a62f3a-c4d58203e40so9527966b.1
        for <containers@lists.linux.dev>; Thu, 19 Nov 2026 11:19:56 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20260707; t=1795115995; x=1795720795; darn=lists.linux.dev;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=B3fPYwtnhJtRTzUId1FsxU5BbcK59iDRRgRTHG4g8TM=;
        b=gSOVx2XERo4Mvj/L5uWb7Yw1u8A4x2ynIwsWfV4BjPNLvrY719YeV0Ttnw4rlHF0SE
         +QdoNJbgndLxBW2KaoVIDBeES2ozR1/QUoOtXTPQvld7PX3rOgo3luF55nGLKEW2FEIG
         G5i+gugX2hECW3jndBi4mC6zYcqtixAW3eXQlLtztBVJhBX05b3bKN4HWmMxnPGBMmdd
         8l2OVBaXxtUnf+Tf72/HQ3jzw4UGiOBci52naUz/vykNOav15jTCC7bAXHjW7Ooz9APO
         pmGogW5wjDXYyKiV88+V3iEcSK5Chyv4ZeQB3MjZllGAk2TotLa7/cNOB+6pa1s4uJNu
         21Gw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795115995; x=1795720795;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=B3fPYwtnhJtRTzUId1FsxU5BbcK59iDRRgRTHG4g8TM=;
        b=xEMM9dVmLK0DkiNKEhIQR5piivpOlDXMFRI/Cfv7bdU0kFaF1wfbrFac52GZpSTSNu
         zejyGgXiNcPTOGlnm4QKgFpEJk3ZihcWhdZ5K3nNRI/ci+iSbiFKNmAmuMsqlQSPf6I2
         KGDuAoCX/d4zxH6NhAk43hkJ/P6IAi82/VxD8yiuoPiPXHJ8iSOlDJvSnCQQG4VuvPcb
         qsHfEkMJYdwDXTiIuLMH4nrWO3EKwaB4RRrAayLTYksn7h4g8qawxs3OmyVHvQfJ62EU
         03kMaq3mHxwsMH8VxMjj3HlR7OLADcA0MTWA5yWmMM9uUA5QY7QMqDhzP2QSSqqjyIQg
         QKMw==
X-Forwarded-Encrypted: i=1; AL+hErEVtLoIHmq5kuW/FqAvpBj1RW3lsTJEnI2Q2oLcrpCfLM7nOje/rfvXjU3XT+HvUeR5fCKZim7ftc//@lists.linux.dev
X-Gm-Message-State: APuU4Z8qyGHEQtp7Gpjh3ovBdG550zlviFfFqpgDRZvSRtYTfjK7cCBC
	GoK2glp8IG7t9FBwn51C+yag5KDVCzw7zbqj/2gfk1uu+SzfOWRK+JCfWeWR+S/cw4Sdb/9qKg=
	=
X-Received: from ejbgt15.prod.google.com ([2002:a17:906:f20f:b0:c2e:1bc5:6c6c])
 (user=halg job=prod-delivery.src-stubby-dispatcher) by 2002:a17:906:9fd0:b0:c50:a2f1:f200
 with SMTP id a640c23a62f3a-c513a5da8e7mr99034666b.16.1795115994327; Thu, 19
 Nov 2026 11:19:54 -0800 (PST)
Date: Thu, 19 Nov 2026 19:19:53 +0000
In-Reply-To: <av8QNiFcnGWocORy@kernel.org>
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
 <av8QNiFcnGWocORy@kernel.org>
Message-ID: <av9L2ez51erKkQNo@google.com>
Subject: Re: [PATCH v2 1/4] userns: introduce capability bounding set for user namespaces
From: "Hallgrimur H. Gunnarsson" <halg@google.com>
To: Jarkko Sakkinen <jarkko@kernel.org>
Cc: Christian Brauner <brauner@kernel.org>, Serge Hallyn <sergeh@kernel.org>, 
	Andy Lutomirski <luto@kernel.org>, Paul Moore <paul@paul-moore.com>, James Morris <jmorris@namei.org>, 
	David Howells <dhowells@redhat.com>, Kees Cook <kees@kernel.org>, Jonathan Corbet <corbet@lwn.net>, 
	Shuah Khan <skhan@linuxfoundation.org>, Randy Dunlap <rdunlap@infradead.org>, 
	"=?utf-8?Q?Micka=C3=ABl_Sala=C3=BCn?=" <mic@digikod.net>, Jonathan Calmels <jcalmels@3xx0.net>, Jann Horn <jannh@google.com>, 
	"=?utf-8?Q?G=C3=BCnther?= Noack" <gnoack@google.com>, KP Singh <kpsingh@kernel.org>, 
	Casey Schaufler <casey@schaufler-ca.com>, linux-fsdevel@vger.kernel.org, 
	linux-security-module@vger.kernel.org, linux-api@vger.kernel.org, 
	containers@lists.linux.dev, keyrings@vger.kernel.org, 
	linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, 
	linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="utf-8"

On Thu, Nov 19, 2026 at 05:05:26PM +0200, Jarkko Sakkinen wrote:
> On Thu, Nov 19, 2026 at 10:42:05AM +0000, Hallgrimur H. Gunnarsson wrote:
> >  static void set_cred_user_ns(struct cred *cred, struct user_namespace *user_ns)
> 
> I read the diff through but this led me to dead end. Cannot find this
> function from anywhere. I look the changes again once this is sorted
> out becaus this is interesting.
> 
> I wanted to look at the call site to understand how cap_bset gets set,
> which is not now possible but I do get the gist and agree with it.

Thanks for taking a look. The series is based on v7.4-rc1 and
set_cred_user_ns() lives in kernel/user_namespace.c, where it is called
from create_user_ns() and userns_install(). ns->cap_bset itself is
initialized in create_user_ns() right before calling set_cred_user_ns().

> I'd figure getting this relates to my rootns patches (perhas). One key
> mechanism for me resolving the unprivileged in my use case is
> MOVE_MOUNT_T_MNTNS [1], which is orthogonal but just pointing out
> the problem space.

From a quick look, they appear complementary. Being able to do more
setup operations from the outside generally aligns with bounding
capabilities inside the user namespace.

> I read through https://lwn.net/Articles/978846/ to understand the topic
> overall. Just mentionining as a possible addition to the cover letter
> (not a priority/necessity).

That LWN article is actually linked in the cover letter as [2].

> Hope these help and can be kept in the loop :-)

Will do, I'll keep you CC'd on future revisions.
