Received: from mail-qt1-f176.google.com (mail-qt1-f176.google.com [209.85.160.176])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C985A42668E
	for <containers@lists.linux.dev>; Wed, 30 Sep 2026 19:53:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.160.176
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790798006; cv=pass; b=L4Bzj3O3KcKywAD+PTeN/x8avu7058elR+pS3qeWMrKfudfsEaY+nHaxYoxZ+QUso1vQW+mfqaKwJ0MjW768M0iqnd4hU0531MHHFCV3893RId593DjJVIQ5SIRsSsKZgaA3fC4fXbhgcIZ6THIlUzYJOah6OV10HZUYDGtJ8VE=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790798006; c=relaxed/simple;
	bh=jEjOJJgnQ8TLl1NXrjU0PSvQC15w6bG/fD+IpOaPESg=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=nt+KaqO46fJSiDnOYaBV2nhHFW5gx7y41qoiVWYhwiFDJ+w01G4ieWNmWS2NK/LnsP/3irvlDioAdyGHUd67zp9yW63y9qv69SSkFEaylR94pO3k7chiwEMlEiAWDoqfPp3o1Bdg2aGuKmwXVhXdsxG77hpVGvSKptbUpYEX/aY=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com; spf=pass smtp.mailfrom=google.com; dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b=TRax1Ykz; arc=pass smtp.client-ip=209.85.160.176
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="TRax1Ykz"
Received: by mail-qt1-f176.google.com with SMTP id d75a77b69052e-5337c7b9937so63621cf.0
        for <containers@lists.linux.dev>; Wed, 30 Sep 2026 12:53:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1790798004; cv=none;
        d=google.com; s=arc-20260327;
        b=WXcFH7hyWxY+pqY/o5delhywI0ZcWEHaxCI//vrP0/UNx3N9Co3ZzVZWcLWrIKvwic
         cKAHFtCw2Rk4XkWCP7js0F9+F1pUCT8yDBRfhk61g9g70Q+ZZmINiZecFW3E0cmNdEPd
         rqSQZIueT1lrIE9GP9rFgTSCT2Jd38Cnn5jMubVXw0HbXfZP3dpExgGCzT38ojz1HjjV
         EBaAhlKdc8Wq2KG1LYhR8x3kTlw5+vPTJTC464RwcslwLag9Ci8xdGdVrl68FM8ofGQ0
         oCmY/P82xeMTYq11mRxr5HGfAIKEf+n17T4JS3i5brOfdt8CcZYsaHvUFU11hZmGrkn0
         VXyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=0eIq1qnomZnnsUKsF5xFhZ0yFWtEcE3Qo/pF8vzCbBI=;
        fh=plXQ48yPOSbmYyYqwiYW6l3dYfrqkTcNbh7RpK4GZVI=;
        b=ihNmrObv7MTbgRtS1sNXy2fGwR8LcJZ+BxnCkdRI0XQnCOj8UW9BWjpgvV/ENrg6+I
         Rwn3fc2Be2bL3RqjvtcAuzfU8V9DuvUCmRkDLYnfC6UaFeKgHKoNE39QZNU/O3nJWR0N
         NPZ5wvwIwTawThxyf5tJywAumVhRTHuWLmTutd6tnmXaBaCl0YrPFZuiy3jpOAbUo4Se
         svkSkQFzBwYgfm95AkXGpqjRqkPnKBEEBW18hXDMZ5qJDrkXc16ENVK7Wu0+PnUAJG19
         59lb41RTUWhLFg6vXKIsCjEgmU7O2AZJHfMufiRAu+f+WM0oCXNHW/sKfrNsdoeNffQG
         yISQ==;
        darn=lists.linux.dev
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20251104; t=1790798004; x=1791402804; darn=lists.linux.dev;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=0eIq1qnomZnnsUKsF5xFhZ0yFWtEcE3Qo/pF8vzCbBI=;
        b=TRax1YkzaIRU7eRTrtEDHqH32Xw2FB2ClRQ2Kf0H4upBPy9bEpsLLscZk2tMT+srp8
         AhQiKcOGSRu5Frq5YWJB5vxhys/bzq9P0VVkFCxkcg+19672ePNY2GEMZvxsLkxXoSWQ
         +2tJKUl5ypeBtT1Om7JdL4DY4DXmxDP0ZMT+SdP5Uh7zCRjDXoCKvmWENslu9+CuujeC
         NoC/k3Krm0r1pkpVauzd23z24qhTLFYY1BXx0VFRo5vavbKOcisLLlM23vuuMh72EfX5
         YXXP1cnDVfvX7GtSZmdWpXXG5Kv0E7b0Vb0dwha7GJiLQgyLvdu+wpFa5KfK02Z4J6nD
         Uu4g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790798004; x=1791402804;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=0eIq1qnomZnnsUKsF5xFhZ0yFWtEcE3Qo/pF8vzCbBI=;
        b=BYYuFNpOdUuoPesC1oYupM51U1ZI1SxMf3f42r4oaMOEofclq9wlIHct6PGfWUFE6k
         ryj63mJlgP5wH3uQgVTOn07wsxTGinZNiEv8dVOKCZp/rcFNfvggd7T+C6akeUHWfXzQ
         m08v9Q65M8Rc10lAsfZVdvOiLUFo5K+0XN7XZku5rTatTlwjFfa1msrXrc/xu5HgHL4Y
         01Ga/ziJyGkt6rxNiWHylUURa94Gu0/jSlYx6/hmS28+7y2cWRkQTlugYgoH9Gla9+sd
         1I1Cf+j3qM1kLvTzNNSqYxAy8SLsoBstIZUaFBsgaxfOj3hvTLwra+zI9I7v9jXXMwUU
         X0RA==
X-Forwarded-Encrypted: i=1; AKwUvByS61FkhXQVa9uTT5C6+xFRlbiEsmV6nFhg/H1Tei4eO7Qpl1agmZaLbtNyQRtnV7HDHhLoRoOEcNwJ@lists.linux.dev
X-Gm-Message-State: AFuF++l303suwp/yNfBMwbgrlh9Dyhk7unHfMjjcBgo3jAbtQxtRUQwV
	z3+W21QZyI2oAGQgOXdsezGRxlPFI+c0M91x13+xK7m6dGfd7SGkCldedhT8FuG371v/RxTD23/
	6b5F6jmsnl5QP5g58G4ANeDOb/7LU7JfqlPdCF4F2
X-Gm-Gg: AYBFou3ZEubN+X/3Gd6tX1q96IzCt9kEWGznGHAnG0bkECAsgr96/JH6WXKm1enTW++
	DPA/5ub+xIXGxXAPzTJ2UZ7RQefiT1J4HhpDacpiW3iRrD0l7A2cnNSj5dq8jhkfuhVGLywjO6M
	6GK2rnoqfvB5XfOeZYtZIZsiD5Z+oOvf6XdzkoQv/VO1sKGJwfRjFu37Dhz21VVHJ7cJpqqwvn2
	EyLBojnkYHLmKuf2Slh41qzlrsZ+sLUk5bQO2lmQKZ4bBQGL/kc7CPtXNNgF5HjRKU6UdLt9sjw
	tahymo3nSjgMgAUO4R7S1PoRx6siwid/r7cN2qRnuBTfHpGBoNYSbA==
X-Received: by 2002:a05:622a:610:b0:531:6de:6028 with SMTP id
 d75a77b69052e-53386815ca8mr222861cf.13.1790798002634; Wed, 30 Sep 2026
 12:53:22 -0700 (PDT)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <20260926-nsfs-prune-rfc-v2-0-53509260e4e7@gmail.com>
 <20260926-nsfs-prune-rfc-v2-1-53509260e4e7@gmail.com> <CANaxB-yj2QV183nk3UC-2PD6qh6hh-_iLRuryTdUsebd+RqxdA@mail.gmail.com>
 <CAGmPdrwOnNRHJqk1mZVB+tFCnJBr3ZTaSZqbiGu54kXPkMtRoQ@mail.gmail.com>
In-Reply-To: <CAGmPdrwOnNRHJqk1mZVB+tFCnJBr3ZTaSZqbiGu54kXPkMtRoQ@mail.gmail.com>
From: Andrei Vagin <avagin@google.com>
Date: Wed, 30 Sep 2026 12:53:11 -0700
X-Gm-Features: AclHuK9MG__TVWG37WqPhPUQdYK5bsOXfsAt-eoCDlcKjWQdQUjwS0-jBycCRa0
Message-ID: <CAEWA0a5OjmjE-CVhiUcLXqrpE4xSd3-L5OszDd41DFDqUgcp1g@mail.gmail.com>
Subject: Re: [PATCH v2 1/2] mount: add OPEN_TREE_DROP_MNTNS_MOUNTS
To: Kirill Kolyshkin <kolyshkin@gmail.com>
Cc: Andrei Vagin <avagin@gmail.com>, Christian Brauner <brauner@kernel.org>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Aleksa Sarai <cyphar@cyphar.com>, Jan Kara <jack@suse.cz>, 
	Jeff Layton <jlayton@kernel.org>, "Eric W . Biederman" <ebiederm@xmission.com>, 
	David Howells <dhowells@redhat.com>, Amir Goldstein <amir73il@gmail.com>, Shuah Khan <shuah@kernel.org>, 
	Giuseppe Scrivano <giuseppe@scrivano.org>, linux-fsdevel@vger.kernel.org, 
	linux-kernel@vger.kernel.org, linux-kselftest@vger.kernel.org, 
	containers@lists.linux.dev
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, Sep 30, 2026 at 12:49=E2=80=AFPM Kirill Kolyshkin <kolyshkin@gmail.=
com> wrote:
>
> On Wed, Sep 30, 2026 at 10:22=E2=80=AFAM Andrei Vagin <avagin@gmail.com> =
wrote:
> >
> > On Sat, Sep 26, 2026 at 12:01=E2=80=AFAM Kir Kolyshkin <kolyshkin@gmail=
.com> wrote:
> > >
> > > A recursive open_tree(OPEN_TREE_CLONE) copies the nsfs mounts of any
> > > mount namespaces pinned below the source.  When the clone is attached
> > > inside a mount namespace younger than a pinned one, move_mount(2) fai=
ls
> > > with ELOOP from check_for_nsfs_mounts(), per the rule from commit
> > > 8823c079ba71 ("vfs: Add setns support for the mount namespace") that
> > > prevents mount namespace reference loops.
> > >
> > > This breaks container runtimes that use OPEN_TREE_NAMESPACE, such as
> > > crun [1].  The new namespace is younger than everything else, so bind
> > > mounting e.g. the host root fails on any host that pins a mount names=
pace
> > > (snapd does, under /run/snapd/ns).  By the time it fails, setns() has
> > > already run and userspace cannot recover: the host tree is out of rea=
ch,
> > > and the offending mounts cannot be unmounted from the detached copy.
> > >
> > > copy_mnt_ns() and create_new_namespace() already leave these mounts
> > > behind; only get_detached_copy() copies them.  Add an open_tree() fla=
g to
> > > drop them from the clone, as suggested by Aleksa [2].  Locked nsfs mo=
unts
> > > are dropped the same way copy_mnt_ns() does it, so nothing new is exp=
osed.
> > >
> > > Keep it opt-in: open_tree(OPEN_TREE_CLONE) plus move_mount(2) is how
> > > mount --rbind works through a file descriptor, and in the caller's ow=
n
> > > or an older namespace such mounts remain usable.
> > >
> > > The flag requires OPEN_TREE_CLONE or OPEN_TREE_NAMESPACE.  With the
> > > latter it is a no-op, so a runtime can pass it unconditionally.
> > >
> > > Link: https://github.com/containers/crun/issues/2262 [1]
> > > Link: https://lore.kernel.org/all/2026-01-07-oldest-grim-captions-spi=
lls-ywC2O3@cyphar.com/ [2]
> > > Assisted-by: Claude:claude-opus-5
> > > Signed-off-by: Kir Kolyshkin <kolyshkin@gmail.com>
> > > ---
> > >  fs/namespace.c             | 14 ++++++++++++--
> > >  include/uapi/linux/mount.h |  1 +
> > >  2 files changed, 13 insertions(+), 2 deletions(-)
> > >
> > > diff --git a/fs/namespace.c b/fs/namespace.c
> > > index ae5dc64f8b45..a95173996a8f 100644
> > > --- a/fs/namespace.c
> > > +++ b/fs/namespace.c
> > > @@ -3062,7 +3062,8 @@ static struct mnt_namespace *get_detached_copy(=
const struct path *path, unsigned
> > >                         ns->seq_origin =3D src_mnt_ns->ns.ns_id;
> > >         }
> > >
> > > -       mnt =3D __do_loopback(path, (flags & AT_RECURSIVE), CL_COPY_M=
NT_NS_FILE);
> > > +       mnt =3D __do_loopback(path, (flags & AT_RECURSIVE),
> > > +                           (flags & OPEN_TREE_DROP_MNTNS_MOUNTS) ? 0=
 : CL_COPY_MNT_NS_FILE);
> >
> > Overall, the patch looks good. One small thing is that open_tree() with
> > OPEN_TREE_DROP_MNTNS_MOUNTS doesn't fail on a mntns file if AT_RECURSIV=
E
> > isn't set:
> >
> >   open_tree(AT_FDCWD, "/proc/self/ns/mnt",
> >             OPEN_TREE_CLONE|OPEN_TREE_CLOEXEC|0x4) =3D 3
> >
> > With AT_RECURSIVE, __do_loopback() calls copy_tree(), which checks
> > !(flag & CL_COPY_MNT_NS_FILE) && is_mnt_ns_file(dentry) and returns
> > -EINVAL, but without AT_RECURSIVE it calls clone_mnt(), which doesn't
> > have such check.
>
> Thanks! A call with arguments like this does not make any sense*, as you'=
re
> asking to clone a pinned mount namespace while skipping it.
>
> * except maybe to check if the path is indeed a pinned mount namespace,
> but there are cheaper ways to do it.
>
> That said, we can either keep things as is, or
> 1. require AT_RECURSIVE with OPEN_TREE_DROP_MNTNS_MOUNTS
>     when checking valid flags; probably the easiest thing to do;
> 2. add a check to a non-recursive path in __do_loopback, something like:
>     if (!(copy_flags & CL_COPY_MNT_NS_FILE) && is_mnt_ns_file(old_path->d=
entry))
>        return ERR_PTR(-EINVAL);
>
> I'm going to implement either one in the next iteration (v3); do you have
> a preference?

I prefer the first option.

Thanks,
Andrei
