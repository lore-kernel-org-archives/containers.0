Received: from mail-oo2-f38.google.com (mail-oo2-f38.google.com [74.125.231.166])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AD39B50AC0E
	for <containers@lists.linux.dev>; Wed, 30 Sep 2026 17:22:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=74.125.231.166
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790788946; cv=pass; b=AOi86WFix2qAuss3Y/Fx0aG/RvtpNJP/ARMg8JR1npVENChMxMhYP8cTWwAtRfjH4YPxBEswI2yMyduZSMknWHW1eqTSl+zGhcpAsHlE2WekaZtt02FPVbXUyZXG4b6h/YQgt0xkldIuMG7FEdR1k9UOjiJSi34aZOGIav+8dcQ=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790788946; c=relaxed/simple;
	bh=zRVMMlc5fCEgysqgVDUi/YSuX/Ogj7bmJUVr37RK9ug=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=qKm+MGpVres/hnVZqxCQMiXR3Hpufbw3GiNgZyZSZPDF9QqnfLDMUp4v/0QPRwfiPRY2Os5X2MfcMTC4mR/0XwXe/b1Rz3C6+S2I7GhaQg4GgcqsWhvUXEP/puiU27KEffTSS8DC0eo+cNsnfF8ZW9qnW1iPs9koliLYrtO1gWQ=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Q+RE+LGI; arc=pass smtp.client-ip=74.125.231.166
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Q+RE+LGI"
Received: by mail-oo2-f38.google.com with SMTP id 46e09a7af769-820532e4ac4so469614a34.1
        for <containers@lists.linux.dev>; Wed, 30 Sep 2026 10:22:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1790788943; cv=none;
        d=google.com; s=arc-20260327;
        b=s8PSjAEaoamSi5nIjnoE1rehHpd00qyDaNSKSdrSJ9zmuFrf6KdXQcAkKvYMnPcJNg
         NGkRthn2LJkjAdc8vYtFHI3cBe8ncofHt4rANXLQFbUfZaYqTntvF7LLmFEE9zjmCvEK
         oGeOI4u+0r/OL42lBX2zc7URKlcNFhG6zH9Yn073/sp9nMo1upeqn0d3LpBvXoT1c/97
         /jE+nairzHXzpmNjuBOGejvMVmbUEpkpMJpnyHvgGajp7lrwKpT1gfUVsh+4eUgiDLYw
         49vrttocMtFkbUQAd0u6Y2aU+rccHM70BhmNcqlr42cd1mjpWu2UN9eRY5XcF6GMjrxm
         m0IA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=yu5vPNZRGHwBy2ovp25s5yW4Pu1HCw1xplpSec6o1bA=;
        fh=9g1eULvTxs+S33TbUj8k9czuDrAat6OK5N7lxZxp0jQ=;
        b=qa7vjTAZUCnlmsm9Uyyt4SqJfPjKfBItk5IUXoaCwCZb6zTe20IS4lVIDQNIuuiJ99
         eP1ycBXqMLYOepSvqwLVBvFqPFBN8Uw2ielkkomfTSLV18D4TLDtOi4l8Rf4YrCkJy0B
         EJt1ldkgjzf0uK/wqDZ3MJ2PkS45OPvl1YajU4a17a6pEWPFqNNkyDoZ4io2kzHqJWZQ
         V8i63xKaXhv8SF4hMwzawG6p2pRRsjPu3BhZdI1WfLqR2yCheDXJ2phMc80A3c/MpVPP
         owvTPrCTrQjaLUzcGHJhHlD8r/+9aRJnVot0AHhFeY/PwoCFLzMRKpb/fQu06ivYWtdV
         qB6A==;
        darn=lists.linux.dev
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1790788943; x=1791393743; darn=lists.linux.dev;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=yu5vPNZRGHwBy2ovp25s5yW4Pu1HCw1xplpSec6o1bA=;
        b=Q+RE+LGIii8wVZRnxdQcldsdiDtcSqKp8H+p3aPvzsqljAZTM4YnbytpmVb5NGrYEL
         z77G8+3NCRAAL3IJpn7iQvFP0Pke7gFAxQzD2I2oWdiuYHNoAPvNXF53QfWAhhbHwdHT
         vfXPHZCH9A/VGsKJBjg6KIKsVFKB7PjWs++5gqyQzuQb50uN2tWTeO+pVkKLjMEwRRSJ
         9RwPoRSWgRQmPorH5v1re/XsB4K8iy0jupnKh22XZnY7V4LTc3AfBmrfCPMxrrn787MZ
         xI2TTxE5pVerHKhGQMakQLUcBiMcy3/uNwmiyPhmD1uOBTDGkK3cesrY8NNmRp920mpq
         zEIQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790788943; x=1791393743;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=yu5vPNZRGHwBy2ovp25s5yW4Pu1HCw1xplpSec6o1bA=;
        b=mDYvCQG/7CJNWENIlpDOZtHi3d531heqpABL9wH0HnEZi2y8Bc0OTrPaDJbrqtKYYY
         myb1/dqWnn58psyAIOoM7SLVvz0MftnnvH+obK+7U92qr2I0i89DCgqQXSqkdRZSQIQI
         L4Yd40Pi9umaq+fafFOJnIqkwmOJMWReIEKwiwfrnQ/jwSwgYYBjdDn18x2eJpkaLYza
         4krhj4ZCWY8ZUEiFX0YtFA+2V/khhpepGQGn4+w+jXVtSo73lG4sAFfIiy4TQK68E4tJ
         zzjFVcTPSZvH8ct4+Wbbe22W6O8sKbe/AsKU6MdxUkkAW9tTt6qk8QOw/ZhuwhfBygho
         yBwQ==
X-Forwarded-Encrypted: i=1; AKwUvBy70xok1y3wqmamM/FlJmODq8vYdT1/bLo+48X9ilR1LXHqvtOucOcixGCowEzaCJYGK12kis1ywS29@lists.linux.dev
X-Gm-Message-State: AFuF++meLLdVOaV/UbeG25+1g+HUdcFirsgqYCxPlbeNVx5jPtU/Mime
	6NtdqBMDYJzxqMV8CyrrVXRR7c1a1cAKSMcZ35NKUdFrLef1SjHuhtseCp/8xIUhHs6a5s6Wz6a
	FVNC4pDz48EcNOIhaZHs9sfcMMPEZ8EU=
X-Gm-Gg: AYBFou2KTLPQgDfKh9NCNrKHTkV4a2430PMWTAmj5YBoiAomBbu2Iy4dUIboKcx/DBZ
	zO4t9d7OlFT+jMWXfBAAGxDTLUMDvwfAF2DI4QOfoM4vM/H+DxNY4+SYRrNM0/ALP6DPzs7l3PC
	rxmqjj6bgcrzZ8L79Ov9eqCP+ZvDomBwWaIWpBlPeBRonZTtprBB+zUpU6ThguOPMRBlpP+hBCr
	X4e/qD+GXyMT9iiGORChN20imWcUZ1bCDy2yGzvhGh55N2x4MOyCG3dxYey7r4b3ct0uAzXJ+Vi
	jl5HNRl6LvFZLSfAgBf7A0Lte5iCkOSsDGGq9OmxAhUjnPlkcwmsKx4UQ5vACqAI
X-Received: by 2002:a05:6830:2a0d:b0:81c:37e2:2012 with SMTP id
 46e09a7af769-82049efa6ffmr2348274a34.15.1790788941936; Wed, 30 Sep 2026
 10:22:21 -0700 (PDT)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <20260926-nsfs-prune-rfc-v2-0-53509260e4e7@gmail.com> <20260926-nsfs-prune-rfc-v2-1-53509260e4e7@gmail.com>
In-Reply-To: <20260926-nsfs-prune-rfc-v2-1-53509260e4e7@gmail.com>
From: Andrei Vagin <avagin@gmail.com>
Date: Wed, 30 Sep 2026 10:22:10 -0700
X-Gm-Features: AclHuK_q_WkZKtIVvL2_JZxQzOyxiVzzsuWi72MjhRzmIxNO0_froXd1yw4BveA
Message-ID: <CANaxB-yj2QV183nk3UC-2PD6qh6hh-_iLRuryTdUsebd+RqxdA@mail.gmail.com>
Subject: Re: [PATCH v2 1/2] mount: add OPEN_TREE_DROP_MNTNS_MOUNTS
To: Kir Kolyshkin <kolyshkin@gmail.com>
Cc: Christian Brauner <brauner@kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, 
	Aleksa Sarai <cyphar@cyphar.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@kernel.org>, 
	"Eric W . Biederman" <ebiederm@xmission.com>, David Howells <dhowells@redhat.com>, 
	Amir Goldstein <amir73il@gmail.com>, Andrei Vagin <avagin@google.com>, Shuah Khan <shuah@kernel.org>, 
	Giuseppe Scrivano <giuseppe@scrivano.org>, linux-fsdevel@vger.kernel.org, 
	linux-kernel@vger.kernel.org, linux-kselftest@vger.kernel.org, 
	containers@lists.linux.dev
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, Sep 26, 2026 at 12:01=E2=80=AFAM Kir Kolyshkin <kolyshkin@gmail.com=
> wrote:
>
> A recursive open_tree(OPEN_TREE_CLONE) copies the nsfs mounts of any
> mount namespaces pinned below the source.  When the clone is attached
> inside a mount namespace younger than a pinned one, move_mount(2) fails
> with ELOOP from check_for_nsfs_mounts(), per the rule from commit
> 8823c079ba71 ("vfs: Add setns support for the mount namespace") that
> prevents mount namespace reference loops.
>
> This breaks container runtimes that use OPEN_TREE_NAMESPACE, such as
> crun [1].  The new namespace is younger than everything else, so bind
> mounting e.g. the host root fails on any host that pins a mount namespace
> (snapd does, under /run/snapd/ns).  By the time it fails, setns() has
> already run and userspace cannot recover: the host tree is out of reach,
> and the offending mounts cannot be unmounted from the detached copy.
>
> copy_mnt_ns() and create_new_namespace() already leave these mounts
> behind; only get_detached_copy() copies them.  Add an open_tree() flag to
> drop them from the clone, as suggested by Aleksa [2].  Locked nsfs mounts
> are dropped the same way copy_mnt_ns() does it, so nothing new is exposed=
.
>
> Keep it opt-in: open_tree(OPEN_TREE_CLONE) plus move_mount(2) is how
> mount --rbind works through a file descriptor, and in the caller's own
> or an older namespace such mounts remain usable.
>
> The flag requires OPEN_TREE_CLONE or OPEN_TREE_NAMESPACE.  With the
> latter it is a no-op, so a runtime can pass it unconditionally.
>
> Link: https://github.com/containers/crun/issues/2262 [1]
> Link: https://lore.kernel.org/all/2026-01-07-oldest-grim-captions-spills-=
ywC2O3@cyphar.com/ [2]
> Assisted-by: Claude:claude-opus-5
> Signed-off-by: Kir Kolyshkin <kolyshkin@gmail.com>
> ---
>  fs/namespace.c             | 14 ++++++++++++--
>  include/uapi/linux/mount.h |  1 +
>  2 files changed, 13 insertions(+), 2 deletions(-)
>
> diff --git a/fs/namespace.c b/fs/namespace.c
> index ae5dc64f8b45..a95173996a8f 100644
> --- a/fs/namespace.c
> +++ b/fs/namespace.c
> @@ -3062,7 +3062,8 @@ static struct mnt_namespace *get_detached_copy(cons=
t struct path *path, unsigned
>                         ns->seq_origin =3D src_mnt_ns->ns.ns_id;
>         }
>
> -       mnt =3D __do_loopback(path, (flags & AT_RECURSIVE), CL_COPY_MNT_N=
S_FILE);
> +       mnt =3D __do_loopback(path, (flags & AT_RECURSIVE),
> +                           (flags & OPEN_TREE_DROP_MNTNS_MOUNTS) ? 0 : C=
L_COPY_MNT_NS_FILE);

Overall, the patch looks good. One small thing is that open_tree() with
OPEN_TREE_DROP_MNTNS_MOUNTS doesn't fail on a mntns file if AT_RECURSIVE
isn't set:

  open_tree(AT_FDCWD, "/proc/self/ns/mnt",
            OPEN_TREE_CLONE|OPEN_TREE_CLOEXEC|0x4) =3D 3

With AT_RECURSIVE, __do_loopback() calls copy_tree(), which checks
!(flag & CL_COPY_MNT_NS_FILE) && is_mnt_ns_file(dentry) and returns
-EINVAL, but without AT_RECURSIVE it calls clone_mnt(), which doesn't
have such check.

Thanks,
Andrei
