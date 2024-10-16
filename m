Received: from mail-qk1-f173.google.com (mail-qk1-f173.google.com [209.85.222.173])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 02DCE20969E
	for <containers@lists.linux.dev>; Wed, 16 Oct 2024 12:53:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.222.173
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1729083238; cv=none; b=pVF7g1umgwdCXVh949jmVj/O+b6iHSETFDjagW1DGreh5uQsMrYCXWXI5eiZzH/hRxj2T7x2OotG+HCuV8qqq3xq2it3WJ1opJ/j6YdidbD6NTLZLxR4yh7dvCMzNXIl8qy3r0VUNNae1+UHM4gStEcL32vPSJt7tiQ4Xi0alj0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1729083238; c=relaxed/simple;
	bh=JberB9FQaW9006JRnitxmiG7NJo7GIR48+9qkvupKso=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=gNP4JwwE2Y922Rl71XpWti2B2WPdG4GaoAj2bupLSGWVYa6eqyOR7D6rB3s9+10tGLNl+DeQokEW2jFCTE677X4u5XgidHj8i/D4mYDSsB+PWNfeMKj4UFlJ/kzG7h85wCMvvwHSL0OpVy17gY00ed/q/SrTX8qOZDhHEHZqLEs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=WPNZp4LB; arc=none smtp.client-ip=209.85.222.173
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WPNZp4LB"
Received: by mail-qk1-f173.google.com with SMTP id af79cd13be357-7b148919e82so21480785a.0
        for <containers@lists.linux.dev>; Wed, 16 Oct 2024 05:53:56 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1729083236; x=1729688036; darn=lists.linux.dev;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=2DqNVBnBLcYUKGgGsKMIT+a+OqsGOHkFJ2kO1T6sXPQ=;
        b=WPNZp4LBubArPVgikwLBJwh4v8hHqBTUSsvZKqE7ItKkreUjnX+mv8UyrVsd1nU6DG
         ldbuqdli+mebNR0n8gVv0sV14Juhb3J6xkifAEeT4Z9EBmK2R0RFikDjrBcr6rfl4O1N
         T/zZsneN8cWZ2PCdmL9rbrsCQQbWRy3MZivNCJ4nCh8ps05ROVNZ8rBf/zNuturBbyXq
         Xf3g50kIanakRRq4PuZ+qEMVDH/97MmQBH2Fv2QDp4siF1jbPZGQB6gCl4gnsuIuBAa6
         hl0vwRdVjRwIT3ZnsL2rgdOraQKUJTqFKNlEbb8gUVKTCPnJsC0HP1FgYCi1D6rGF0Ax
         DoNA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1729083236; x=1729688036;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=2DqNVBnBLcYUKGgGsKMIT+a+OqsGOHkFJ2kO1T6sXPQ=;
        b=kese7/OCDmYCvVOwrjdlx+Rm0yZlCLbKiqgHJeQwYrbGPl+3tbbVQMe16hZzCtBp/F
         OlEj4mFfZ/ow1TOTp8I4TLC2s0j91NDHHRNtquIxqswlhYmb2hMr5kFVdo5VcCjaS9V/
         0gy7zbhA2SbumDQBxZ0EQ3Sc7DNH6AvAi7xP1UqTcMI2B3EmK1pixV15z+vXWbN6mG6K
         FKUaA3pIcONeoL9xvP6h91fZoSvZ24tuoTViatIQM6eSd4RiA59fpfGhUJ9rIrf4S4wX
         9/Fkx4H6kB9/rvZlCXqTCCHucLtCMe6X/rPaCPPn7RV934XuxhJJGqehew34+cCm+/8o
         iDrw==
X-Forwarded-Encrypted: i=1; AJvYcCXvvgYn7FsCIE1TWndih1bqQ/4lh/cIVVGNaN2CgP1zbXcXWCyJdsG9q9My4hpe2xOza5neGS0M1l0O@lists.linux.dev
X-Gm-Message-State: AOJu0Yzkf/6xk5Hmdvhd8pLcftVTL+76ddOQZ89kWiKBJDFEKm/G4hxa
	WDX9IQqGDzuwXNchRfIL0V7cSkNKz37f3EeGZ1B4NQqW6pkgyeLlWxAfHYLxNOi+bGgW87eT+FR
	UqJ0w+dHyBrsZku8u/uMy8ke0i9s=
X-Google-Smtp-Source: AGHT+IFlZNZ9b2fTtzrg0utIW/Yfdyw4VrLKpdJC9W9Kdj3aKxjox5fknHaN4kiBhOxyxLB4E93HLY+QuhbI7jo3dUE=
X-Received: by 2002:a05:620a:4509:b0:7b1:1352:66fb with SMTP id
 af79cd13be357-7b11a36b4f0mr2420396985a.29.1729083235793; Wed, 16 Oct 2024
 05:53:55 -0700 (PDT)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <20240524-vfs-open_by_handle_at-v1-1-3d4b7d22736b@kernel.org>
 <CAOQ4uxhjQwvJZEcuPyOg02rcDgcLfHQL-zhUGUmTf1VD8cCg4w@mail.gmail.com>
 <CAOQ4uxgjY=upKo7Ry9NxahJHhU8jV193EjsRbK80=yXd5yikYg@mail.gmail.com>
 <20241015-geehrt-kaution-c9b3f1381b6f@brauner> <CAOQ4uxj6ja4PN3=S9WxmZG0pLQOjBS-hNdwmGBzFjJ4GX64WCA@mail.gmail.com>
In-Reply-To: <CAOQ4uxj6ja4PN3=S9WxmZG0pLQOjBS-hNdwmGBzFjJ4GX64WCA@mail.gmail.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Wed, 16 Oct 2024 14:53:44 +0200
Message-ID: <CAOQ4uxiwGTg=FeO6iiLEwtsP9eTudw-rsLD_0u3NtG8rz5chFg@mail.gmail.com>
Subject: Re: fanotify sb/mount watch inside userns (Was: [PATCH RFC] :
 fhandle: relax open_by_handle_at() permission checks)
To: Lennart Poettering <lennart@poettering.net>, Jan Kara <jack@suse.cz>
Cc: Jeff Layton <jlayton@kernel.org>, Chuck Lever <chuck.lever@oracle.com>, 
	Aleksa Sarai <cyphar@cyphar.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, 
	Christian Brauner <brauner@kernel.org>, containers@lists.linux.dev
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

[cc the correct containers list]

On Wed, Oct 16, 2024 at 2:45=E2=80=AFPM Amir Goldstein <amir73il@gmail.com>=
 wrote:
>
> On Tue, Oct 15, 2024 at 4:01=E2=80=AFPM Christian Brauner <brauner@kernel=
.org> wrote:
> >
> > On Sun, Oct 13, 2024 at 06:34:18PM +0200, Amir Goldstein wrote:
> > > On Fri, May 24, 2024 at 2:35=E2=80=AFPM Amir Goldstein <amir73il@gmai=
l.com> wrote:
> > > >
> > > > On Fri, May 24, 2024 at 1:19=E2=80=AFPM Christian Brauner <brauner@=
kernel.org> wrote:
> > > > >
> > > > > A current limitation of open_by_handle_at() is that it's currentl=
y not possible
> > > > > to use it from within containers at all because we require CAP_DA=
C_READ_SEARCH
> > > > > in the initial namespace. That's unfortunate because there are sc=
enarios where
> > > > > using open_by_handle_at() from within containers.
> > > > >
> > > > > Two examples:
> > > > >
> > > > > (1) cgroupfs allows to encode cgroups to file handles and reopen =
them with
> > > > >     open_by_handle_at().
> > > > > (2) Fanotify allows placing filesystem watches they currently are=
n't usable in
> > > > >     containers because the returned file handles cannot be used.
> > > > >
> > >
> > > Christian,
> > >
> > > Follow up question:
> > > Now that open_by_handle_at(2) is supported from non-root userns,
> > > What about this old patch to allow sb/mount watches from non-root use=
rns?
> > > https://lore.kernel.org/linux-fsdevel/20230416060722.1912831-1-amir73=
il@gmail.com/
> > >
> > > Is it useful for any of your use cases?
> > > Should I push it forward?
> >
> > Dammit, I answered that message already yesterday but somehow it didn't
> > get sent or lost in some other way.
> >
> > I personally don't have a use-case for it but the systemd folks might
> > and it would be best to just rope them in.
>
> Lennart,
>
> I must have asked this question before, but enough time has passed so
> I am going to ask it again.
>
> Now that Christian has added support for open_by_handle_at(2) by non-root
> userns admin, it is a very low hanging fruit to support fanotify sb/mount
> watches inside userns with this simple patch [1], that was last posted in=
 2011.
>
> My question is whether this is useful, because there are still a few
> limitations.
> I will start with what is possible with this patch:
> 1. Watch an entire tmpfs filesystem that was mounted inside userns
> 2. Watch an entire overlayfs filesystem that was mounted [*] inside usern=
s
> 3. Watch an entire mount [**] of any [***] filesystem that was
> idmapped mounted into userns
>
> Now the the fine prints:
> [*] Overlayfs sb/mount CAN be watched, but decoding file handle in
> events to path
>      only works if overlayfs is mounted with mount option
> nfs_export=3Don, which conflicts
>      with mount option metacopy=3Don, which is often used in containers
> (e.g. podman)
> [**] Watching a mount is only possible with the legacy set of fanotify ev=
ents
>      (i.e. open,close,access,modify) so this is less useful for
> directory tree change tracking
> [***] Watching an idmapped mount has the same limitations as watching
> an sb/mount
>      in the root userns, namely, filesystem needs to have a non zero
> fsid (so not FUSE)
>      and filesystem needs to have a uniform fsid (so not btrfs
> subvolume), although
>      with some stretch, I could make watching an idmapped mount of
> btrfs subvol work.
>
> No support for watching btrfs subvol and overlayfs with metacopy=3Don,
> reduces the attractiveness for containers, but perhaps there are still us=
e cases
> where watching an idmapped mount or userns private tmpfs are useful?
>
> To try out this patch inside your favorite container/userns, you can buil=
d
> fsnotifywait with a patch to support watching inside userns [2].
> It's actually only the one lines O_DIRECTORY patch that is needed for the
> basic tmpfs userns mount case.
>
> Jan,
>
> If we do not get any buy-in from potential consumers now, do you think th=
at
> we should go through with the patch and advertise the new supported use c=
ases,
> so that users may come later on?
>
> Thanks,
> Amir.
>
> [1] https://github.com/amir73il/linux/commits/fanotify_userns/
> [2] https://github.com/amir73il/inotify-tools/commits/fanotify_userns/
