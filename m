Received: from mail-ed1-f52.google.com (mail-ed1-f52.google.com [209.85.208.52])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3B6BA1A00E7
	for <containers@lists.linux.dev>; Fri, 18 Apr 2025 11:33:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.208.52
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1744975983; cv=none; b=Qk/BeWwOJkb0Xpt+qxNn3Ln7ozg4P6K+g84nteQkZ7KUwQCV1O3zapqTPwYcmINGMqM3Pwk5ROzl4/DsGG/On22ARtAcQ2urI351nxgSTJtKtAxv2SrN/9THoOmz6r8MKRG9AgeH9erEkX6z9b9vAVLflfc5rpjo8eSEQS0NgPc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1744975983; c=relaxed/simple;
	bh=WTnrGeFXBjCnzzuEOgvpCFp4CW/g62/iDIbbbUxuCR4=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=oUp+7YzwOZpTFOWzej8vqazOMAk3C529cuP2bBgS0gRJElZXZefMe0/EUnzabD+Cc6Qd6QesLrPzanoK3eZTU6MBA5z2XPaB1lKqIuJPRHYZuYXvsxCRsmWDJdlQZMa1lfsCu2pE86cMSAuPEdaVkR7ahil6WCvpADQBVvwYLrg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=ih/QtggB; arc=none smtp.client-ip=209.85.208.52
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ih/QtggB"
Received: by mail-ed1-f52.google.com with SMTP id 4fb4d7f45d1cf-5efe8d9ebdfso3472251a12.3
        for <containers@lists.linux.dev>; Fri, 18 Apr 2025 04:33:00 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1744975979; x=1745580779; darn=lists.linux.dev;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=27X7S16DYjT/LW2Ezo/SSGnQFg4j0BttjbVMhMujxUI=;
        b=ih/QtggBcYnuFko+ueg0QcPbM3XMzV12ZCJp4agp/xIyRPFXahUubJIvAbIQypi8cV
         18LcEpCV9G30uozv6RYuScCEIYKlLe+3CUZpxFoqnCOStgNnLP3pTKTEgwVMFSMdKYyq
         UvGo5wGoFl7nxFfpjcPUZ9k5odoZcWYge0dY74X/9ep6mY2D01IrULe2YHvO8THPqU13
         3OoJKNpeBtCI1iyRgl1Pf4+zljyvP/NLvRdT2fSYIP8rJKWAj/i76fUcFDJVs1mSL9C0
         rn97Fce6+9CR2jZ3dDcOOG3RWuseDO3XMePBDO+G+yVSWy2YeBWINHMM8YZrDLMRMxKh
         FCyA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1744975979; x=1745580779;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=27X7S16DYjT/LW2Ezo/SSGnQFg4j0BttjbVMhMujxUI=;
        b=cyob5ELB6WSuMRRbbIuwJuc/2goY8pGv1HDjK5NKmjJzRCGLAx5D4rd/mGynCi5zq/
         R2mgi2i3c/+k5uGiODbvf/bTd58n5lKQF5MKhkZwhyDrsN2neoRzlx2y6r1PO4cR0s8G
         xvNU1Dbl13agYaq9LdSFOQeFEfh1n5l9z1/CTfD6a4tWk0/gYRwRv2twiD+zDCEVgfRj
         2iLwNkDylGFAZe6jzqsXiyUOmnLLyInKcCYoJsNmQm80FcDXxnCksKYHw8Gu2JHhECiG
         lyYOVDlT2hN2iypUjNI8VJleFKbg/El9okbq5QaLonxxqYF1GWDvDft2JKOPzIhMexqc
         2OKQ==
X-Forwarded-Encrypted: i=1; AJvYcCWrrZZiFJ8cb+XOOmRfjlsyHXboLhQjpx9Kzp3E3MKgLHyJFChQaDMF9908ZgEXwvoVqyRmwdtj/bqf@lists.linux.dev
X-Gm-Message-State: AOJu0Yw2AV1AKY/7FOBRicrRcqOiaijodT6tPKvDLJwHZwhsrVFQCxNp
	LVeprDx5r7lBZdzAuqjRkJvmIW3THpbSV5fz3qETvWTW1nBglPwqM5hdJ5aQEiTXAgfJjA5DFKH
	reQhZBGe9XekOWSgISv5SyBERnKg=
X-Gm-Gg: ASbGncvsjpAO8uBMFPIU8DPqrbO3ZjJl0F1CHNqhRwYUYR1Ya35YRb0eYEiiEsxvCDO
	6ezwJsPrIZ//tKbEkzSeDnRpo/GDgm3nM8s89dcTyWNtSHcPaOo4sixnaM/c9g6VZBMIci/vzVH
	7cnIUBVM0x3FCWpgNXz7+CRQ==
X-Google-Smtp-Source: AGHT+IEgwzx2e+QsgQJxBA2Ct7E+PXkO+TM2webM4UiPcmvhRotO0DA2Hd8OHEOP6jOOW1+lwrn40MJ3mLqEi4Xdiqg=
X-Received: by 2002:a17:907:9622:b0:aca:df11:c53c with SMTP id
 a640c23a62f3a-acb74dbb5admr210684566b.43.1744975979257; Fri, 18 Apr 2025
 04:32:59 -0700 (PDT)
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
 <CAOQ4uxiwGTg=FeO6iiLEwtsP9eTudw-rsLD_0u3NtG8rz5chFg@mail.gmail.com>
In-Reply-To: <CAOQ4uxiwGTg=FeO6iiLEwtsP9eTudw-rsLD_0u3NtG8rz5chFg@mail.gmail.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Fri, 18 Apr 2025 13:32:48 +0200
X-Gm-Features: ATxdqUGV8yWLv2kq_q7MXkpjUzh-Q3ZHWEcnWjLSHuE2R97cZyLSX9a3qYb89Xg
Message-ID: <CAOQ4uxgwfQNM=cRBJ0BJ-UtZ1R=v3uuFrOfLxWCr5c0WA_Nh3w@mail.gmail.com>
Subject: Re: fanotify sb/mount watch inside userns (Was: [PATCH RFC] :
 fhandle: relax open_by_handle_at() permission checks)
To: Lennart Poettering <lennart@poettering.net>, Jan Kara <jack@suse.cz>, 
	Miklos Szeredi <miklos@szeredi.hu>, Christian Brauner <brauner@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>, Chuck Lever <chuck.lever@oracle.com>, 
	Aleksa Sarai <cyphar@cyphar.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, 
	containers@lists.linux.dev
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, Oct 16, 2024 at 2:53=E2=80=AFPM Amir Goldstein <amir73il@gmail.com>=
 wrote:
>
...
> > > > Christian,
> > > >
> > > > Follow up question:
> > > > Now that open_by_handle_at(2) is supported from non-root userns,
> > > > What about this old patch [1] to allow sb/mount watches from non-ro=
ot userns?
> > > >
> > > >
...
> >
> > My question is whether this is useful, because there are still a few
> > limitations.
> > I will start with what is possible with this patch:
> > 1. Watch an entire tmpfs filesystem that was mounted inside userns
> > 2. Watch an entire overlayfs filesystem that was mounted [*] inside use=
rns
> > 3. Watch an entire mount [**] of any [***] filesystem that was
> > idmapped mounted into userns
> >
> > Now the the fine prints:
> > [*] Overlayfs sb/mount CAN be watched, but decoding file handle in
> > events to path
> >      only works if overlayfs is mounted with mount option
> > nfs_export=3Don, which conflicts
> >      with mount option metacopy=3Don, which is often used in containers
> > (e.g. podman)
> > [**] Watching a mount is only possible with the legacy set of fanotify =
events
> >      (i.e. open,close,access,modify) so this is less useful for
> > directory tree change tracking
> > [***] Watching an idmapped mount has the same limitations as watching
> > an sb/mount
> >      in the root userns, namely, filesystem needs to have a non zero
> > fsid (so not FUSE)
> >      and filesystem needs to have a uniform fsid (so not btrfs
> > subvolume), although
> >      with some stretch, I could make watching an idmapped mount of
> > btrfs subvol work.
> >
> > No support for watching btrfs subvol and overlayfs with metacopy=3Don,
> > reduces the attractiveness for containers, but perhaps there are still =
use cases
> > where watching an idmapped mount or userns private tmpfs are useful?
> >
> > To try out this patch inside your favorite container/userns, you can bu=
ild
> > fsnotifywait with a patch to support watching inside userns [2].
> > It's actually only the one lines O_DIRECTORY patch that is needed for t=
he
> > basic tmpfs userns mount case.
> >
> > Jan,
> >
> > If we do not get any buy-in from potential consumers now, do you think =
that
> > we should go through with the patch and advertise the new supported use=
 cases,
> > so that users may come later on?
> >

Hi guys,

The fine print section in the above "is it useful" question is quite comple=
x.
Maybe that explains why I got no response ;)

I can now ask another flavor of the question:

Is it useful to allow FAN_MARK_MNTNS watches from non-root userns?

Just to make sure that I get it right, the unique mntid that is reported wi=
th
mount attach/detach events is not namespaced right?

Anyway, this functionality has become a priority for me, so I will
work on adapting the old patch [3] to mntns marks and post v2.

Thanks,
Amir.

[1] https://github.com/amir73il/linux/commits/fanotify_userns/
[2] https://github.com/amir73il/inotify-tools/commits/fanotify_userns/
[3] https://lore.kernel.org/linux-fsdevel/20230416060722.1912831-1-amir73il=
@gmail.com/
