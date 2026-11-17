Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.167.50
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1794937054;
	b=vJwxCZ9t+XOewCUTPgMqwAgZMkcGE7p4w0AFWuOSvwu7OwnKNfmpFMhvIh6C2Khhe22l
	 FDvxxdfpEY4DCLjJjkshE9K3RG5eBq7rYwmaQIP0olUTtXEfH0bRZdGoi/Kl5Q2h6u1D2
	 CGHz0/SdbJfWQQ2RXnQXk1CSLgcffLPaKE7RU02uULAkq0Bm0qurKPVWHfCgzDNY9yQFZ
	 Rxq9L4HiejWzKGCML2VXyVVBawZasN2asy1C1CQswEx8FUJoXjgUhp/h5YHNBPAyVEH2g
	 VKsmqazG3ZSRWMae/c3aJdaOqw6wmy6Og2yoqGxTlgxQdrHZIepHPVnfCKOJTcdHTfQ==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794937054;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=uIwpU1G0S/NqSFaGi3+jp2QeKv8+tYQDPWGubJQpaow=;
	b=R5CfPMU3+CcXpIfc2Hw9ibwix6wyMxf6KGxBZPGM6NoCtfTVwWjeDhAZOetMOsWBIEPg
	 P3VydwoNElM19wYzqrTIqT+8uDqkQxkKlb63LfwSgVf37VHVLBJ8V+EahJdq3jxvRYGzO
	 NRglP/PfpuPSHMdXItpZEjqTfSd7bXa/1p5rs/yS5VTyq6uEzeC4DENfKeS6hpm0Ia26c
	 kxbelgqMSq6lHc3+N2SYl308tCO5pPWHuHIdIKWBd1fB64HuR6hn4MXmKL0pjhn+SGbEj
	 LCu3A2FjN4BXULSYgKivvWs92UBToGhwN1E5uIiTAY/UlJkI79u7mjR81Xz4udRDirQ==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=none header.from=amacapital.net;
	spf=pass smtp.mailfrom=amacapital.net;
	dkim=pass header.d=amacapital-net.20260707.gappssmtp.com header.i=@amacapital-net.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=R8tO1xBS;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.167.50
Received: from mail-lf1-f50.google.com (mail-lf1-f50.google.com [209.85.167.50])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 15AE2606A880
	for <containers@lists.linux.dev>; Tue, 17 Nov 2026 17:37:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 15AE2606A880
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amacapital.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=amacapital-net.20260707.gappssmtp.com header.i=@amacapital-net.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=R8tO1xBS
Received: by mail-lf1-f50.google.com with SMTP id 2adb3069b0e04-5c14f3dab0cso2457e87.1
        for <containers@lists.linux.dev>; Tue, 17 Nov 2026 09:37:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1794937052; cv=none;
        d=google.com; s=arc-20260327;
        b=M4yP/4L2x7yEwqPUMOTIb82X8ncqm0q3+BCYdvtxxHXJyqsU1eSI/OSqSJ6y/w8m2x
         d8Bag2BHLgiV2jxacSUon2K+di/FZAcORJ2OCMGw+kfXqch/hNBSqHwwd4ly4xo2uCyH
         8DxDzBKOOTSzFEGWw1StHCzmzLS8vfbshGEl/PMOpNFi92OQCePn1rlmeg2wCqrKp634
         ZR4FV5vW94N0Mo4jEWFUm/82U8qmfzju84RpxaVVIUUuQkqg9v5B7oC430R+lavOHtUK
         SumI8LCyGeKEtVPj+1auCmS9H18JNp+eQgMkbAgDGAMujyWqD8BDx8s4WOdVhmrNTAda
         58kg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=uIwpU1G0S/NqSFaGi3+jp2QeKv8+tYQDPWGubJQpaow=;
        fh=+EXqsUTD9+RtWM3Stwm5M2kZqetsS1QmdPhbDLDdVxo=;
        b=gcnJOfEXHoGY0zhpyQ6YPOg8cj6YsCqH2dBxgnjISNiswGfYnI4qaFCmmBsM9BWD3D
         SS1uVteYni9r4ngLxtX+BLv8W7yYTJXrMSNdaCVp49kzHmKJf8qs4K4g8hAU8gZOTFJQ
         CJ+yqtRPBWn2huozsMV/qK3MC+r7UZZKmA2XHYXIsI4wCvJLZoaLA27QSEh0dAA0T2e+
         U2MRsvlSh5NmhWtYP7kmbNa1I6CsX41o38SQgPl5ZiYsBQJK6fHpwXqWGokSK2E9I4rf
         ygwfv6g6cYeJue1OS6VrUc2+oicA5cNk3KJYRVpUfpWvh2LUOyUjXFgKHSbUOTpGWuf8
         yjwg==;
        darn=lists.linux.dev
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amacapital-net.20260707.gappssmtp.com; s=20260707; t=1794937052; x=1795541852; darn=lists.linux.dev;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=uIwpU1G0S/NqSFaGi3+jp2QeKv8+tYQDPWGubJQpaow=;
        b=R8tO1xBSWM6pH46JoRZ8VoyDKFsIhI3z52Ns1q3zVbPW0MfKo9BMp5xcSs5Wcs9Q4O
         GgYJ/Y7Uxe4ArpnacDJlvDIdl1wNZHJJ+EgcZp+JAccgbN3We9ZKIoIPPLHLxzW2RxFS
         vUo8oJRtuqB19+0kJqmvthVsXyoFJSrsmnusHTUwo/mKadKbbU/60fp04Xgrt7u1q5fW
         KS8Abc8yz/wvmrjxbmfVGxcMfm0ZCjFsoMU2+S01ZUfYi1PhW8H4Ao2OpODetW81kcdG
         /qU/SGAOJgTa4JN7Luj5iRUxXjqYpyMm/Z3qejzjrb52BtRMrZ4FKzIrnYd5eZQ79xJM
         haIw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794937052; x=1795541852;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=uIwpU1G0S/NqSFaGi3+jp2QeKv8+tYQDPWGubJQpaow=;
        b=B2ikRVyV0BNKOzabTpoOroIXvbINMkEB8nlLRB1VCU4VP1J/VUkvBzdBZM4I7mNODl
         vnmh+YN/CPVMp3NUVqETuFcA7FhGdO8qnLLqZOC3M4O3NvC/kK5JqdcKxvoqxSi/BMWb
         mdDFQN4/hKLGP9IIXEXrzTF2Waxw89e4x2GkY3XJ1AVRXlAWxoPhiPidlxelPqnxt9Ix
         cW/87f5W3FiVo19acUfzkqFbZqX6X3g0cXCNMvHsXBhH3QKp20UJXk9WnI9nPwAuTW8y
         gRu8PkBfYEfJ51nWLL4M8drBs2sRRG/i1DdjWiAcu0e5FTI1/MtCmgX3tbmYDzRuxfCF
         2KZg==
X-Forwarded-Encrypted: i=1; AL+hErFbY0L1WisfsMRiXk2qTIY0H3oxfmu/KmxYpO50jSPOz0t3NjOGymzoPi+O6CJldYKc3Zix+4/UNqEn@lists.linux.dev
X-Gm-Message-State: APuU4Z9NmKBPJJaLFV5D/jQvFtxqlChAWdzElGnnnJe1XwJy4c96DGwo
	SoTySGKbH+JfG6vdiddLiP54ySehMF49Uy3wEOoBUHmVc0CWcMlKAjQ3pVt4m6nJQDCLbCuW6RA
	PiwabOOKNxIbbF9HTsulu71II9VZ1XVPV7oR1eXh8
X-Gm-Gg: AYBFou2pUbyHi3oiYwkkjFSr2uZQbHmntbjj6e/3bGtc2hnloM2S4q7J1s6QMM/RAlV
	jKPhtsOqRwVIh5D32sakRCkfAjIo4crdwa4oUN/KDsVSL4qEMhT4hOin3y7/5P4vD2P2wu8Sda9
	qb/c3ydfJLUglvbevJ02+i+aRpvRX7Tt3izy8TqUjLbzdGum5RwFkjU6noDimtnNUGIKN646IkD
	AaXgjF0d4L1uQKcmptdJW/14xOg7Jfyd+ZZMHL9kgJx08Kwot4NHcDixDKHKV7gG3Mf+VWUw5xU
	9GBdWAPO7gKCLl4g0KpDak2cLbi9TvUOVmSUrECt16SK2M2qZ/W0+t/Qd9BmyrdiSZR9W6iZ04l
	X0FYbytytJb5W2XyI/bSPAEb3foXGtj/ezg==
X-Received: by 2002:a05:6512:33d5:b0:5bf:a4e4:c329 with SMTP id
 2adb3069b0e04-5c170a15b84mr5575263e87.64.1794937052080; Tue, 17 Nov 2026
 09:37:32 -0800 (PST)
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
 <CALCETrUjW=kXxyggDUvEN+Pxc-pE98eVbdW8XBU8JzfqXj_voA@mail.gmail.com> <20261117-rational-ohnehin-unbeugsam-e5c04759a156@brauner>
In-Reply-To: <20261117-rational-ohnehin-unbeugsam-e5c04759a156@brauner>
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 17 Nov 2026 09:37:19 -0800
X-Gm-Features: Aa3M54pEPEuG6xXoA_VcNPLpRvUBxQYv2Rvc07pMupzDgfrZ2jXEXOCCMAfHfMk
Message-ID: <CALCETrWhuOnBy0N0KznmczD4S2XEK0fbr0C=1KFQqTnoTJbQbg@mail.gmail.com>
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

On Tue, Nov 17, 2026 at 9:10=E2=80=AFAM Christian Brauner <brauner@kernel.o=
rg> wrote:
>
> On Mon, Nov 16, 2026 at 09:15:18AM -0800, Andy Lutomirski wrote:
> > On Wed, Nov 11, 2026 at 7:20 AM Christian Brauner <brauner@kernel.org> =
wrote:
> > > * a task that setns()es in later gets
> > >   ns->cap_bset & (cred->cap_userns | cred->cap_permitted)
> >
> > I'm not sure this is ideal.  If a task has cap_userns & CAP_NET_ADMIN,
> > then there is no attack surface issue with allowing it to enter a
> > namespace and be NET_ADMIN there even if the namespace itself has
> > CAP_NET_ADMIN cleared from cap_bset.  But any exemption here would
> > need to be a new API so that it isn't used by accident.
> >
> > I'm mostly saying this because container managers might want to
> > restrict cap_userns within their containers but still have it
> > themselves for management.  But maybe there isn't any need to enter
> > the userns for this purpose.
>
> I don't think there is. A manager that holds the capabilities itself can
> just do most things from the outside. I think it's nice that once you're
> inside a namespace you're bound by its capabiltiy set. Otherwise the set
> isn't a property of the namespace anymore. If someone comes up with a
> real need to enter we can add an explicit opt-in later?

Fair enough.  Also you've written infinitely more nontrivial container
managers than I have (I've written container managers, too, but
they're all special-purpose things that don't do much in the way of
actual managing).

>
> > > * Root in a container has caps as well so for containers the exemptio=
n
> > >   would be wrong.
> > >
> > >   So here we need a a lockable SECURE_NO_USERNS_CAP_RAISE bit thingy.
> > >   This turns off the exemption and prevents raising the mask.
> > >
> > >   Docker lowers the mask, sets and locks the bit, and
> > >   unshare(CLONE_NEWUSER) in the container doesn't hand out CAP_NET_AD=
MIN
> > >   anymore.
> >
> > Can you clarify this part a bit?  I'm not seeing why Docker should be
> > special.  Shouldn't the inside of a Docker container work as much like
> > a normal non-container system as possible?  What's the use case?
>
> I picked Docker because you brought it up, and your goal of allowing
> user namespaces even in Docker is kinda the use case. Docker can only
> drop the CLONE_NEWUSER block from its seccomp profile if nested user
> namespaces can't get more caps than root/Docker wants to give them.
>
> But the bit isn't at all Docker specific. Any privileged task that wants =
the
> mask to apply to itself would benefit. With just the exemption this would=
n't be
> possible:
>
> (1) A runtime that holds full capabilities gives a
>     user namespace it creates all bits.
>     It can just set the bit before creating it.
>
> (2) In a container without a user namespace container root has host-level
>     capabilities. Any user namespace it creates gets them through this
>     exemption thing. So it can also add them back to its mask. And the ma=
sk is
>     inherited. So every process it starts can then create user namespaces=
 with
>     them.
>
>     by raising the bit we stop both. The locked bit keeps container root =
which
>     also has CAP_SETPCAP from clearing it.
>

I'm still not 100% sure I'm following this.  By "exemption" are you
talking about the cred->cap_premitted term here?

ns->cap_bset =3D parent->cap_bset &
                       (cred->cap_userns | cred->cap_permitted);

(As as aside, as formulated, the parent->cap_bset term should be
irrelevant, no?  cred always refers to a task in parent, and this
whole thing is defined so that cap_userns and cap_permitted are always
subsets of parent's cap_bset, right?)

I think I agree that there needs to be a way to turn the cap_permitted
thing on and off (and I'm also not sure whether cap_permitted is
better than cap_effective), but I'm not convinced that an inheritable
and lockable bit is necessary or wise.

How about changing the rule to:

child->cap_bset =3D parent->cap_bset & soft_cap_userns &
(cred->cap_userns | cred->cap_permitted)

a) (ugly but easier) A non-inheritable prctl-controlled mask
soft_cap_userns, changing the rule to parent->cap_bset &
soft_cap_userns & (cred->cap_userns | cred->cap_permitted).
soft_cap_userns would be reset to all ones on on fork and exec to
avoid creating new inheritable security-relevant state.

b) A whole new create-a-namespace API where the caller chooses
soft_cap_userns at the time they create the namespace.

> On the host none of that matters as the mask is root's own policy there.

I'm still not seeing how there's a difference between host vs
init-userns-container vs separate-userns-container.  After all, in
*any* of these contexts, the configuration *of the host or inside the
container* might want to restrict cap_userns for unprivileged users or
for everyone, which it can do with whatever API we add to do this.
And some container manager might run with CAP_NET_ADMIN in such a
context, and it might want to create its own container that has
CAP_NET_ADMIN removed from cap_bset.   But I might just be being dense
here or I might be misunderstanding you.



There is one thing that continues to bother me about all of this.  In
a sane world where privilege elevation on exec was simply not a thing
(no_new_privs =3D true always, nosuid always, no file caps, etc), then
cap_bset is kind of irrelevant, right?  A task either does or does not
have NET_ADMIN, and it either does or does not have the ability to
create *a task in a new userns, including itself, with NET_ADMIN*.
Since our API is based on creating/entering a userns as opposed to
spawning tasks into a userns, the rule should be, upon entering a
userns:

    cap_permitted =3D cap_userns

or something to that effect.  Or maybe:

    cap_permitted =3D ns_enter_requested_caps & cap_userns

and cap_effective and ambient get clamped to cap_permitted.

Unfortunately we don't live in this world, and I'm not convinced that
can credibly even approximate it, because people really like their
setuid programs working inside a userns.  It still bugs me that we're
designing permission systems designed to work in the POSIX model that
I think we all kind of agree is fundamentally rather messed up.

>
> > In any event, the ptrace access checks also need to be updated.  If
> > we're adding cap_userns, then one should not be able to
> > PTRACE_MODE_ATTACH a task with higher cap_userns.
>
> Yeah, I mentioned that in my reply earlier.
