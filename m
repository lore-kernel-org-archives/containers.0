Received: from mail-pj2-f37.google.com (mail-pj2-f37.google.com [74.125.227.165])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 482EE443E28
	for <containers@lists.linux.dev>; Wed, 30 Sep 2026 19:49:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=74.125.227.165
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790797776; cv=pass; b=E/NaOf9Uqcmmzd+GknLlLvazP4cTkh/djzHgmO9Kp4a34Cl2o7W8ymxOWmeXq0JM7T1W3Bw3SWneKcbF69Hh+4MF4mdJPI+i5ePXgRyBsxWd9J2bOu6n3vtFSwan60IfBUKOEQJ5T9/RkMrJa38wmnJ7pxUwEO4vuAhnTCFhZik=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790797776; c=relaxed/simple;
	bh=F3Dung+nzJVGL2YRHUmvwY+adZaiJpqAN9OQIrYPVJg=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=dxtan3GlGBG9wrOU5XjWMY/vYm9Lxz0JqY98ezgotvozI7n/GMv6GS1c4r+rSULCckOvMC21SzHMXYR0Ke3lFVqCHdB2gZFf50qxy5DS3ayKotTSIB6O8V8MqcCnxo43IcrW4hlNyFMQlForPh3Y62JDh1GSweCsHr69leBg9OA=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Onq8DSSl; arc=pass smtp.client-ip=74.125.227.165
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Onq8DSSl"
Received: by mail-pj2-f37.google.com with SMTP id 98e67ed59e1d1-3a4eda6744bso450361a91.1
        for <containers@lists.linux.dev>; Wed, 30 Sep 2026 12:49:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1790797769; cv=none;
        d=google.com; s=arc-20260327;
        b=JXDEHF6j3mWXNndExnHB7uAIbp8t3b0U5Be+RZZmtOadOSFdZmY+KkN43KhLXxbgQL
         lkrSDnnRfqgYoI2Ht72ETBVXKFyg1yFol0uixHbJbdzHpFuplcdkkiXx/vBqjXcJTHkA
         RPKeQWJn6tSj16k405dBxAMxjfZ4ypXHIZO2Rh9qZe+YXVk7gbBEooGfF1GgH4YX/L1h
         7vxfC36sh17xqJiHgHi31JfHsrfflnq6YL22bib8rflwu8/G8oP1qNt1Dy8KFvfXxKMa
         YMArD/fEhIxXih63EWg8v9j8CMWmBTChkPLszRPuxbU6NT4BANnLoic/e36uqgWD4PTV
         EEKw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=vYuuNb8fsv3iPf0xhDXc4/1qYP3hZrQ9mcUnQuSOi8Q=;
        fh=pDFvG2c07vVNubsyUFbDOkqQHv3U84KBSFaF17LKNNM=;
        b=oSuNRr85tGLLnM73ihdYzMfC2cmvHo9DLfnSkbklrdWDj8A8ZjRFfxPdfMnJn+VmhW
         ta7+s1LtHm65IggXupujEKMzkVFh2MuComfGPJVLKZMepp/Job1r4LhF1vazpIA/ElGF
         yzuiVljhbX14/jG7iYcV/SBb5EMJp4+Y6QncaTFSGoUHw+yzBqMHl6Tqyn7dEuRpqQl/
         5PPv+53zUrgQwNHnA3EhTVcyXm7SEncBYLMECJyHWFV9CfuejmneuQ3PR1LQk9Csf+Vu
         uo+8ZurIF0xKq5+lJORaEN6lADA6zB455V3CAUywcFmMvDTBH8hGqhBVwE98fi7SWvyX
         6YqA==;
        darn=lists.linux.dev
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1790797769; x=1791402569; darn=lists.linux.dev;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=vYuuNb8fsv3iPf0xhDXc4/1qYP3hZrQ9mcUnQuSOi8Q=;
        b=Onq8DSSlAFZTgi0S9x3DLH0Qf5pFUI7XjNMWbTz5c3Ohj8S7PV+ZzaAVMEZSc7ep7B
         uNrzyy0KcoOXLqDmYCwKsuB3rmBgLxEVvAk4spLgrwORIhDr0b8A4GYMLtW+xxWJJUul
         89J2vCW1gBRmFLHp0WSj972gpQt+g2hEUtStLmBIHd0GnsOJBGIdg5lNehYrcVfK+usy
         BoGcfn+2uGP/wGZ1Bbd1jSIYfkCSvw7eCMFk17Pb/XgITDeuY0PCWr45EZj/NAsWRIyQ
         QdbCYw6EjIsE0uLgt9BRZBYl04fRIa+b8Vj0gxoIuxjYHBAdG5s0JUfQvgvBajLuG0cb
         yITw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790797769; x=1791402569;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=vYuuNb8fsv3iPf0xhDXc4/1qYP3hZrQ9mcUnQuSOi8Q=;
        b=dbwTs5TYohgi3EEvpBlN5uWmOOyaGKz+zn314DKv0C0HLaHxY0v5hXFMOxyaCYsVv6
         ZuJXgtQksBWxr1Sc7vtiJ/OJYrJ9+TTGl8J1bWpUoRGTv6GAsJzmWJpMzOWCg6oJMKcx
         SuSUtWEjBByMjXqk7zDotOLzYew+3HkER/IXabOyKGxvaOkAP4FPrmCWcZOMuUDwOJ7i
         HbF2w2J6H5oFW59XfkQqGJfEBawxIce2fXcq2+Kc42pC7CHjEEp1OIgC5/a1I7ldpinq
         1Y5e2WlQIxd8dOq/GuPCiz7ZW2E8Bpeb6R2NWU2kc8ZwKQYUEsVD7Ix/bromlWhnIjGU
         xoYA==
X-Forwarded-Encrypted: i=1; AKwUvBz/Xng2p4oH8Q3MnrP5kCTVW7/IPV4jiSe6GUoa7OSsNYxOf3tpl6JsysrvOQ6c7dV/BOp4MZG7AgW/@lists.linux.dev
X-Gm-Message-State: AFq9FYLWyqC0jl2x3qh4MRYHC22ozjdcMqwYPQzWjorkM9mL2dR4r7xQ
	VzbZDWCwC1MxTk3dN1SzRexuTZNI3GSANokYN0fpjDSovkc3EHp9g46x4FAdr4xpJScm+W/3oJA
	95gRUvTqhCseWWsqJDYbVdEbpNRlG4U8=
X-Gm-Gg: AYBFou0ta2pqLk+6lxeJRX3QPoGSUGnko+KZewCOQCOuGeVbKvH4gYK1u4Ou/Ly8iY1
	Y8HbBNnp6BFOOlAHOvZFI2OcCVufRl2xf19/lyNkIvYPN8sQVjoqC+e+IxKWUHXAOe2SmdtY5C9
	aKfFjPGdlJiUOXMQQDUt1H5Z1mxKDm1/tdilOzgi99BxEqNBFAa020rxkcRIJLAxRMXkm1erKoh
	0evIeQhWossMxNhaCKPtgKp9SJzHAt+Alv4dTcDaezqy/hXgTKTSPYjq7fHIqG1Lpu4VZXgoZeB
	24ZkUaOwwJsfA/+Agmr+oTYLRW1vxIM/joGduy6R4imM27mpS/dFt30=
X-Received: by 2002:a17:90a:e7c9:b0:3a4:85c4:68fc with SMTP id
 98e67ed59e1d1-3a4d1545a03mr2271482a91.29.1790797769174; Wed, 30 Sep 2026
 12:49:29 -0700 (PDT)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <20260926-nsfs-prune-rfc-v2-0-53509260e4e7@gmail.com>
 <20260926-nsfs-prune-rfc-v2-1-53509260e4e7@gmail.com> <CANaxB-yj2QV183nk3UC-2PD6qh6hh-_iLRuryTdUsebd+RqxdA@mail.gmail.com>
In-Reply-To: <CANaxB-yj2QV183nk3UC-2PD6qh6hh-_iLRuryTdUsebd+RqxdA@mail.gmail.com>
From: Kirill Kolyshkin <kolyshkin@gmail.com>
Date: Wed, 30 Sep 2026 12:49:18 -0700
X-Gm-Features: AclHuK_hWd00XXCC76l8VVWW4Hx6PvZ0qFMn_sLHCwFO53Dqn518ibmeNSsj6yg
Message-ID: <CAGmPdrwOnNRHJqk1mZVB+tFCnJBr3ZTaSZqbiGu54kXPkMtRoQ@mail.gmail.com>
Subject: Re: [PATCH v2 1/2] mount: add OPEN_TREE_DROP_MNTNS_MOUNTS
To: Andrei Vagin <avagin@gmail.com>
Cc: Christian Brauner <brauner@kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, 
	Aleksa Sarai <cyphar@cyphar.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@kernel.org>, 
	"Eric W . Biederman" <ebiederm@xmission.com>, David Howells <dhowells@redhat.com>, 
	Amir Goldstein <amir73il@gmail.com>, Andrei Vagin <avagin@google.com>, Shuah Khan <shuah@kernel.org>, 
	Giuseppe Scrivano <giuseppe@scrivano.org>, linux-fsdevel@vger.kernel.org, 
	linux-kernel@vger.kernel.org, linux-kselftest@vger.kernel.org, 
	containers@lists.linux.dev
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, Sep 30, 2026 at 10:22=E2=80=AFAM Andrei Vagin <avagin@gmail.com> wr=
ote:
>
> On Sat, Sep 26, 2026 at 12:01=E2=80=AFAM Kir Kolyshkin <kolyshkin@gmail.c=
om> wrote:
> >
> > A recursive open_tree(OPEN_TREE_CLONE) copies the nsfs mounts of any
> > mount namespaces pinned below the source.  When the clone is attached
> > inside a mount namespace younger than a pinned one, move_mount(2) fails
> > with ELOOP from check_for_nsfs_mounts(), per the rule from commit
> > 8823c079ba71 ("vfs: Add setns support for the mount namespace") that
> > prevents mount namespace reference loops.
> >
> > This breaks container runtimes that use OPEN_TREE_NAMESPACE, such as
> > crun [1].  The new namespace is younger than everything else, so bind
> > mounting e.g. the host root fails on any host that pins a mount namespa=
ce
> > (snapd does, under /run/snapd/ns).  By the time it fails, setns() has
> > already run and userspace cannot recover: the host tree is out of reach=
,
> > and the offending mounts cannot be unmounted from the detached copy.
> >
> > copy_mnt_ns() and create_new_namespace() already leave these mounts
> > behind; only get_detached_copy() copies them.  Add an open_tree() flag =
to
> > drop them from the clone, as suggested by Aleksa [2].  Locked nsfs moun=
ts
> > are dropped the same way copy_mnt_ns() does it, so nothing new is expos=
ed.
> >
> > Keep it opt-in: open_tree(OPEN_TREE_CLONE) plus move_mount(2) is how
> > mount --rbind works through a file descriptor, and in the caller's own
> > or an older namespace such mounts remain usable.
> >
> > The flag requires OPEN_TREE_CLONE or OPEN_TREE_NAMESPACE.  With the
> > latter it is a no-op, so a runtime can pass it unconditionally.
> >
> > Link: https://github.com/containers/crun/issues/2262 [1]
> > Link: https://lore.kernel.org/all/2026-01-07-oldest-grim-captions-spill=
s-ywC2O3@cyphar.com/ [2]
> > Assisted-by: Claude:claude-opus-5
> > Signed-off-by: Kir Kolyshkin <kolyshkin@gmail.com>
> > ---
> >  fs/namespace.c             | 14 ++++++++++++--
> >  include/uapi/linux/mount.h |  1 +
> >  2 files changed, 13 insertions(+), 2 deletions(-)
> >
> > diff --git a/fs/namespace.c b/fs/namespace.c
> > index ae5dc64f8b45..a95173996a8f 100644
> > --- a/fs/namespace.c
> > +++ b/fs/namespace.c
> > @@ -3062,7 +3062,8 @@ static struct mnt_namespace *get_detached_copy(co=
nst struct path *path, unsigned
> >                         ns->seq_origin =3D src_mnt_ns->ns.ns_id;
> >         }
> >
> > -       mnt =3D __do_loopback(path, (flags & AT_RECURSIVE), CL_COPY_MNT=
_NS_FILE);
> > +       mnt =3D __do_loopback(path, (flags & AT_RECURSIVE),
> > +                           (flags & OPEN_TREE_DROP_MNTNS_MOUNTS) ? 0 :=
 CL_COPY_MNT_NS_FILE);
>
> Overall, the patch looks good. One small thing is that open_tree() with
> OPEN_TREE_DROP_MNTNS_MOUNTS doesn't fail on a mntns file if AT_RECURSIVE
> isn't set:
>
>   open_tree(AT_FDCWD, "/proc/self/ns/mnt",
>             OPEN_TREE_CLONE|OPEN_TREE_CLOEXEC|0x4) =3D 3
>
> With AT_RECURSIVE, __do_loopback() calls copy_tree(), which checks
> !(flag & CL_COPY_MNT_NS_FILE) && is_mnt_ns_file(dentry) and returns
> -EINVAL, but without AT_RECURSIVE it calls clone_mnt(), which doesn't
> have such check.

Thanks! A call with arguments like this does not make any sense*, as you're
asking to clone a pinned mount namespace while skipping it.

* except maybe to check if the path is indeed a pinned mount namespace,
but there are cheaper ways to do it.

That said, we can either keep things as is, or
1. require AT_RECURSIVE with OPEN_TREE_DROP_MNTNS_MOUNTS
    when checking valid flags; probably the easiest thing to do;
2. add a check to a non-recursive path in __do_loopback, something like:
    if (!(copy_flags & CL_COPY_MNT_NS_FILE) && is_mnt_ns_file(old_path->den=
try))
       return ERR_PTR(-EINVAL);

I'm going to implement either one in the next iteration (v3); do you have
a preference?

Kir.

>
> Thanks,
> Andrei
