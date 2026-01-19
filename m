Received: from mail-lj1-f170.google.com (mail-lj1-f170.google.com [209.85.208.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 29A79392B84
	for <containers@lists.linux.dev>; Mon, 19 Jan 2026 19:05:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.208.170
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1768849530; cv=pass; b=ADg5gn+mW6jUy3afia0kn8tVrSRqbK9/54bQ5v6DkuCd51vI+6COAF9AcpiIR07T9B3ujD18IR6JXmzE3d7C2Hssukv2qbRZOk/wThWYXwRf2oJdlZzYrONSQWxZeSRobwKs6lY/LQHCDbaNkfUnmPRmPwFM/b7t+ulCTl9Ita8=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1768849530; c=relaxed/simple;
	bh=/ce3dudxc2POARZLcfse5sBstVqNXvQFSe7cYp3NGco=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=azxvSdFvvMhCxhz4BkdYqrzrpfvMDvzcWF5LT+3Ve0nXZ0scCdt4tPYl1Rcr2Ktyzu7PZUDSFdUVG/xGI+8Ln6fBs1zUnT4pVzTmSyU4JZvNIaC59e7TkxbCjNUk81UbXwbKfb5XJIZZBHj1TfsFfGOKk1XkxDfge58hKX55+po=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net; spf=pass smtp.mailfrom=amacapital.net; dkim=pass (2048-bit key) header.d=amacapital-net.20230601.gappssmtp.com header.i=@amacapital-net.20230601.gappssmtp.com header.b=2KzJm6fQ; arc=pass smtp.client-ip=209.85.208.170
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amacapital.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=amacapital-net.20230601.gappssmtp.com header.i=@amacapital-net.20230601.gappssmtp.com header.b="2KzJm6fQ"
Received: by mail-lj1-f170.google.com with SMTP id 38308e7fff4ca-383153e06d1so37845511fa.3
        for <containers@lists.linux.dev>; Mon, 19 Jan 2026 11:05:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1768849526; cv=none;
        d=google.com; s=arc-20240605;
        b=MZGWiBy6q6rq07isPJfhxRyHulQk4Js/4io4bNL//LKZ/vtXYD1JX0rrxznKBpeOAx
         vpL/cRSJCa9PDd3B1TveLe588QhfTES9bIl56O0SOzGV4eyp7+16FXgjff2UO2Vj0vhB
         vMtJURxGiWSij+kyhSmFTNamPqNtG0NL73a1NiEMyUI+P7r6ZBHsoWZHiq+krDFvDgoy
         FDZ8FJLwNXgl3E7Zwi+u+30yLbwal4Bq/kVimZNeAm9tzZHyoQiyJGY+ZL2zZaOYcT5k
         ITqYt/FqYqzmmVdJDiRhsIJNgv0cz8OpEyI2wWCZi6FRd6NbmFor7WSo6OXuX7RSqw2c
         NZ3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20240605;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=uPgi7F8HbiHDXFnHy8+BFZNxNaHpq/Qib+SGUInhGco=;
        fh=LlIMDtUD21l577TOSWbAqDSi//qSpcXveBbT9ceTzc8=;
        b=fdn/0pR8FbZRw5ZxTXf6J+H2j4E56pIATkeyqtjF3h7I1FQA0sb9gAf4Vvc0iP96av
         xNf2FTbMGe+ZUKx+QR4h4XqxJoNtk86G5aUC+Sl58HtY/KxaWrzRSvXhb3qU2JbdsFIC
         pj8vp0qTyZsxsEKjtfjhhaEfgfL6tMspVRjK+yX3HmNtL6G8CmJ0bMRX6A1ukwinQEx4
         /jNXp5mDTv6FrigDn5GLt/kCC6aapfwdMVspN8X7jzVNAOszBNJeiw65hDpVq7TvAMYo
         RPOhNC/l1OHwBy3ZL5do5kFEfUCxFWVGkZW0EHtQ2eexyF9khx1gz1CK8Pzd2J2/ylLw
         q7OQ==;
        darn=lists.linux.dev
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amacapital-net.20230601.gappssmtp.com; s=20230601; t=1768849526; x=1769454326; darn=lists.linux.dev;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=uPgi7F8HbiHDXFnHy8+BFZNxNaHpq/Qib+SGUInhGco=;
        b=2KzJm6fQwXs3iJXXCtDQiZK11iuGKEO18aiNKbIKEz6kEMoL8yQL0n6AWm2tD8Fv6G
         hFRzltN/r513BCJ5w3EOpB7kqd8FULk5OvkrxjpNVQnDMLgGo61Pd3pY2QQvsrNXQ4dq
         QAnGBte8/20Os0KAmKc/GeOSJq7vJIdJyNYqTiGea0z2xZ4PMAmj4TjLAQjosuzXyIgy
         +AZglW0IWxkCRw8S9GxSMziJjxxRiFfYUK7wTgU/lDzDKDkPdA3ryVapVQ5TJk93KHWR
         9SwLUsIcfZ3QNvKC+k8P+kcoi2ZqXPYZ8YtXctntCG0YLKmUasqA1sBqB12xWQpvmuaV
         kcSg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1768849526; x=1769454326;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to;
        bh=uPgi7F8HbiHDXFnHy8+BFZNxNaHpq/Qib+SGUInhGco=;
        b=ZTDb7UU/VnrLWwQQff5oprVQJiUvJlxpV38WgMOBYKFHhLggKEtZaZt5SAnJxoF8vJ
         jWxB4p8ZYDopaegK+XtALv0k9yPpPOw8m001VB1wXdm6QhlkRGNgm75xp0coF4msYcQ6
         amN+phoa+Dl1Tzci/nbtYBMS7S+szul8Ze5AZ23xuRu1hL1tWpgHdeYV/NrV+r44SVwx
         L49bcmgbsvu5EY0esnbtjhmfOf7ZlrhxlXwvH8yVJsmY7Wu02yh33nSyxuhJxM2CYnTC
         drrl0Ywhi/fFZO2KbS1R5ms8moVkxHVNeWXuKEhsQSYYwnxQ84L4qaVZMlIxoW36gFGx
         0vqw==
X-Forwarded-Encrypted: i=1; AJvYcCV9kzm4ktWpzFtwh5A/v4YciFFDxUCF551CfWsGeeyG8DVTs9VE3h6LUVxzTttZ9YD0b9Vtr3XL+79r@lists.linux.dev
X-Gm-Message-State: AOJu0YypYX5lacH4kYCGe8Qhdllv2kDfG14jwBDbBxAsByLk354mgPpK
	0XSBBUnp5hf+nt3mJu5gjgmvV7LEgMfsJoXNP/50Xez/Q2juL1IURxoNuzonLRG/fKQqJLXDAjH
	5zR1nYoTcqB5ytBc/tyVzH38BjpjDY1vaUQx5dZuE
X-Gm-Gg: AY/fxX5r+gO/dJKpsDfPX+VX4GZsyY28sBQNJcgBX50neKuPOQXxmNtMurc3neO+m+5
	tFxDGYRvJS7MBviTIVTq5BsO1SAgxF+SFe9fQHaYwUTu9ICut+MQJcc3dSYQl0UMlsNsrIBoI0d
	KxT+c2/bCFeM5g22CpcAaSQGf/YbeYhnRZhtZrLIAUkU4Ta7R2i3djDDcU3hfbO9zLCPSlZwK+C
	fur+QchUDEV6kRGl6F1OlyNIAm4uaPxge/5mXhPtVTPfwpQTkPB8s4+EDYgIct4Ujds
X-Received: by 2002:a05:6512:3c95:b0:599:289c:67b with SMTP id
 2adb3069b0e04-59baeeadbc3mr4115534e87.21.1768849526113; Mon, 19 Jan 2026
 11:05:26 -0800 (PST)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <20251229-work-empty-namespace-v1-0-bfb24c7b061f@kernel.org> <20260119171101.3215697-1-safinaskar@gmail.com>
In-Reply-To: <20260119171101.3215697-1-safinaskar@gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 19 Jan 2026 11:05:14 -0800
X-Gm-Features: AZwV_Qi9RyaiB91QL-WyEcAJf4X_KdMWwLXZLw6yqaw5pxCOP4suRdhto2Jp-kE
Message-ID: <CALCETrWs59ss3ZMdTH54p3=E_jiYXq2SWV1fmm+HSvZ1pnBiJw@mail.gmail.com>
Subject: Re: [PATCH 0/2] mount: add OPEN_TREE_NAMESPACE
To: Askar Safin <safinaskar@gmail.com>
Cc: brauner@kernel.org, amir73il@gmail.com, cyphar@cyphar.com, jack@suse.cz, 
	jlayton@kernel.org, josef@toxicpanda.com, linux-fsdevel@vger.kernel.org, 
	viro@zeniv.linux.org.uk, Lennart Poettering <mzxreary@0pointer.de>, 
	David Howells <dhowells@redhat.com>, Zhang Yunkai <zhang.yunkai@zte.com.cn>, cgel.zte@gmail.com, 
	Menglong Dong <menglong8.dong@gmail.com>, linux-kernel@vger.kernel.org, 
	initramfs@vger.kernel.org, containers@lists.linux.dev, 
	linux-api@vger.kernel.org, news@phoronix.com, lwn@lwn.net, 
	Jonathan Corbet <corbet@lwn.net>, Rob Landley <rob@landley.net>, emily@redcoat.dev, 
	Christoph Hellwig <hch@lst.de>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, Jan 19, 2026 at 10:56=E2=80=AFAM Askar Safin <safinaskar@gmail.com>=
 wrote:
>
> Christian Brauner <brauner@kernel.org>:
> > Extend open_tree() with a new OPEN_TREE_NAMESPACE flag. Similar to
> > OPEN_TREE_CLONE only the indicated mount tree is copied. Instead of
> > returning a file descriptor referring to that mount tree
> > OPEN_TREE_NAMESPACE will cause open_tree() to return a file descriptor
> > to a new mount namespace. In that new mount namespace the copied mount
> > tree has been mounted on top of a copy of the real rootfs.
>
> I want to point at security benefits of this.
>
> [[ TL;DR: [1] and [2] are very big changes to how mount namespaces work.
> I like them, and I think they should get wider exposure. ]]
>
> If this patchset ([1]) and [2] both land (they are both in "next" now and
> likely will be submitted to mainline soon) and "nullfs_rootfs" is passed =
on
> command line, then mount namespace created by open_tree(OPEN_TREE_NAMESPA=
CE) will
> usually contain exactly 2 mounts: nullfs and whatever was passed to
> open_tree(OPEN_TREE_NAMESPACE).
>
> This means that even if attacker somehow is able to unmount its root and
> get access to underlying mounts, then the only underlying thing they will
> get is nullfs.
>
> Also this means that other mounts are not only hidden in new namespace, t=
hey
> are fully absent. This prevents attacks discussed here: [3], [4].
>
> Also this means that (assuming we have both [1] and [2] and "nullfs_rootf=
s"
> is passed), there is no anymore hidden writable mount shared by all conta=
iners,
> potentially available to attackers. This is concern raised in [5]:
>
> > You want rootfs to be a NULLFS instead of ramfs. You don't seem to want=
 it to
> > actually _be_ a filesystem. Even with your "fix", containers could comm=
unicate
> > with each _other_ through it if it becomes accessible. If a container c=
an get
> > access to an empty initramfs and write into it, it can ask/answer the q=
uestion
> > "Are there any other containers on this machine running stux24" and the=
n coordinate.

I think this new OPEN_TREE_NAMESPACE is nifty, but I don't think the
path that gives it sensible behavior should be conditional like this.
Either make it *always* mount on top of nullfs (regardless of boot
options) or find some way to have it actually be the root.  I assume
the latter is challenging for some reason.

--Andy
