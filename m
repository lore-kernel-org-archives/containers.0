Received: from mail-lf1-f42.google.com (mail-lf1-f42.google.com [209.85.167.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C763031B839
	for <containers@lists.linux.dev>; Wed, 21 Jan 2026 18:00:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.167.42
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1769018436; cv=pass; b=nYFTIO8Dg6zBDF7Uw1oSTlCkC1I+qX8jOnlEwcwJc1dvDaiSgQKIacRvHAFQfdqG+K0HDA0OJAYy1ycA/iWhWj/Z543lua7IxiYdvrti1s/rbK4enVleLtTIl05bTJh2zVXCkjtRBLvaQ3GHmuJtlG53OKpZy8B+PYPohKirDwk=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1769018436; c=relaxed/simple;
	bh=9fUfO4M1OR0hA17huHEVgs6JgJd2UYGS587dIvnVGRc=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=rgqgSRMlwEVNuSTddKjc3QxDgZ4GFq4JIuEABsI++1mV4wMMpAgSApZ34oKGoV8J8hmKf/Xw3w9fXicB+a9auv+ub/BaBYFllmpNkNeRobSOxp2DuG3MJe8AplL1UiI2DN8IDj5Qqr0rzQMhzlSNkC+TjqHbbvPtguBYYOUqgwE=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net; spf=pass smtp.mailfrom=amacapital.net; dkim=pass (2048-bit key) header.d=amacapital-net.20230601.gappssmtp.com header.i=@amacapital-net.20230601.gappssmtp.com header.b=fsDiPNMK; arc=pass smtp.client-ip=209.85.167.42
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amacapital.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=amacapital-net.20230601.gappssmtp.com header.i=@amacapital-net.20230601.gappssmtp.com header.b="fsDiPNMK"
Received: by mail-lf1-f42.google.com with SMTP id 2adb3069b0e04-59b672f8ec4so44298e87.1
        for <containers@lists.linux.dev>; Wed, 21 Jan 2026 10:00:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1769018432; cv=none;
        d=google.com; s=arc-20240605;
        b=cdFKcaU5527CsEWd0CafQQUKA9Ygqp1+q0BhrDBLQP1cUP8cRQhnv8SY1Ziryu5XDH
         xBBAPjsQWCcEPqsSl8E/iF81i0OmzW1y4iW2fDs/Tc0ODCHMrBywPwDT3C7N5JFC1LXu
         Pla2HV+N/b84UR4cgEe7GZoL9OZWepwMMYtY146P2H/Q328P01ciW+0tulBmUU0mVSWu
         TUyLdnZssaFc4jSO8ttqBf1YXO5njmLKyyuUsg4VaM5Zxec5BgZq91TcVjsREIGBtwz6
         cGR7ht3kN1HrB+R6zS5xlsgitu2g0fTlH75IS0+0yx/EHu1Du0yS9Dif+weyYb/b2Z5s
         7mUg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20240605;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=TnUAur1XuHkI/gglF6Mz+7XnQMlmdnUuVjG0jwsSsno=;
        fh=8aJV1QALsSmPg+GV5A5T567Ij6Pzz3hJfL1ZgSchDow=;
        b=Ueu8VbkXqv3ZwYJW+XWI3JAEE6DLoyh//mKP//I8JcDU2wOR+bm2mStQ2adx3BPVkd
         IEtNRB4fvIUbm4P6Qg67xzhszjDeQ7S9ZQtgNgq9ilsXyVkfsG7QWO5R6GTkwzeWz0h6
         LWXLs7G49uDAN+20MmIN2H58s7FGpdezh++uYTMh7yXwJqPIKThjYbc7zDD+u3IzUABs
         XiMfD+MjBm70xARbExyaMfoyOVRrPJLFpGISZB6gPp4+CGQJFje98aow+wECOQ96QvPi
         EhcdpCz4uyYzPPf32B/+QxsDAs5lWDFAkipfcUgS0qsukSEJn0rPUZ89cTrqcBkYoDVe
         im2g==;
        darn=lists.linux.dev
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amacapital-net.20230601.gappssmtp.com; s=20230601; t=1769018432; x=1769623232; darn=lists.linux.dev;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=TnUAur1XuHkI/gglF6Mz+7XnQMlmdnUuVjG0jwsSsno=;
        b=fsDiPNMKATf8FrHG9as5aTx5DGppbv4OmJqy+oJJT3ZTFPlPdfGRww8KGqOUxf++GE
         lloGUUesarb+/W82wqLtbSdiui+HwM9UPchWlF7KnrLPD2h5Hw/xQeOdPmajdK23r4Aa
         uZKR7BLrjQVo8zwe4QbPTDCNl4A9A/Q2oBwQuIw0IdZgH5XlVqfJ6Eu5D2fi+Xmi2xej
         /CABROYumgjaxr06XKmu3VGUOsGpsJloqwGq+KURfeAqT7gFa/gf0Aer0IVkT/NcEzjz
         oHT8urjr/qVjehqLkhwilVRDYgOcuc6t5Iqx2FGk3/wzv/z+++wX7pELwZsFnZ9hS9Ch
         ZIyQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1769018432; x=1769623232;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to;
        bh=TnUAur1XuHkI/gglF6Mz+7XnQMlmdnUuVjG0jwsSsno=;
        b=rf9cvP1N6beiHlhXAjr003eCvNSKaHs2F0HvY1m1zW+zfmKBLQkw/PrshD53EoIhrz
         cdZswAM/bFNrlW27zOVrJV26bSzFhiz8n9qaaYv95Cx3WHw9rJhEJZh9GBsvwj+Qo8Mp
         xJ6ccq4c6oemEKnfyV0k9kILSwOufLM3lolpUfPTaIbOsni5b7NmX5RZPjqYRLZYgZ3E
         JubPjhkc7UZZj+0nveldzrhqQ6TTk6DCgYWOh79dR7OxxSOt9HQ0b+ZmxSHlwI/zuI0U
         u/UCJ1/eKjdwKwbB0VCdKiZ9YZWsv/868k26jiVDWbi7cG3qVYOQ8I3l/uLijpPO0TsM
         0M0A==
X-Forwarded-Encrypted: i=1; AJvYcCViM23k06e5ZJBeVhc83x2hH2biX4hsuk9CjBh2knuPrvg5rwp6SPoBdVLh1QPSKsR2pFAtBBgiWiOJ@lists.linux.dev
X-Gm-Message-State: AOJu0Yxo6EU2pzeBpdjyfRp5DuIy84Y/P7P6NBXbV3StzHQmKFr6IkQP
	HBqbrtX432hPCOMT/8OWrZg52Q5kJtvQOt2ZRHLCH0TR+7XJxrBJVaBIKDNKtJHV1zPGIS5KjjF
	nTJ+yiPx4Li/yxtNS2W6uxzb/5JGakQE0OpNGgyyc
X-Gm-Gg: AZuq6aIUFdHfB8HhKAzdCA2pL7RsyBhQ0Vda5fA7i7E6m5DeNuyzEWlhqB6v4vbpmxd
	SkS28GT0efpIKPM0FYY7R8NsAa4x5yT/6fDjcZlf/AMiyqLWK43yMWiAmI0dpq3AzazZjLrQHRO
	JNeZfV0tEfP0oLliQ3mr+lstBxuSnkYjWBkaZVYcu1Qtzb+JpgIZY8flFqrWSOdnGcRve76GAC+
	FZXJs/MhTHHWFJKHG3ajQ1HpQf++od3lIt3Nf7aOjLF40AVMXdU6ddnPAN4dkfD0R+h6NRQ7oiH
	PZo=
X-Received: by 2002:a05:6512:3f0d:b0:59b:6c03:74a5 with SMTP id
 2adb3069b0e04-59dc8f11cbamr2090430e87.8.1769018431803; Wed, 21 Jan 2026
 10:00:31 -0800 (PST)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <20251229-work-empty-namespace-v1-0-bfb24c7b061f@kernel.org>
 <20260119171101.3215697-1-safinaskar@gmail.com> <CALCETrWs59ss3ZMdTH54p3=E_jiYXq2SWV1fmm+HSvZ1pnBiJw@mail.gmail.com>
 <acb859e1684122e1a73f30115f2389d2c9897251.camel@kernel.org>
In-Reply-To: <acb859e1684122e1a73f30115f2389d2c9897251.camel@kernel.org>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 21 Jan 2026 10:00:19 -0800
X-Gm-Features: AZwV_Qj4HThaSaYzNn-qIgAjYFvcri9rsxrh7J0CX4Os2pMzxyAuji1p2rkqKzY
Message-ID: <CALCETrUZC+sdfpVqqjeC_pqmd+-W84Rq7ron8Vx9MaSSohhJ2g@mail.gmail.com>
Subject: Re: [PATCH 0/2] mount: add OPEN_TREE_NAMESPACE
To: Jeff Layton <jlayton@kernel.org>
Cc: Askar Safin <safinaskar@gmail.com>, brauner@kernel.org, amir73il@gmail.com, 
	cyphar@cyphar.com, jack@suse.cz, josef@toxicpanda.com, 
	linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk, 
	Lennart Poettering <mzxreary@0pointer.de>, David Howells <dhowells@redhat.com>, 
	Yunkai Zhang <zhang.yunkai@zte.com.cn>, cgel.zte@gmail.com, 
	Menglong Dong <menglong8.dong@gmail.com>, linux-kernel@vger.kernel.org, 
	initramfs@vger.kernel.org, containers@lists.linux.dev, 
	linux-api@vger.kernel.org, news@phoronix.com, lwn@lwn.net, 
	Jonathan Corbet <corbet@lwn.net>, Rob Landley <rob@landley.net>, emily@redcoat.dev, 
	Christoph Hellwig <hch@lst.de>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

> On Jan 19, 2026, at 2:21=E2=80=AFPM, Jeff Layton <jlayton@kernel.org> wro=
te:
>
> =EF=BB=BFOn Mon, 2026-01-19 at 11:05 -0800, Andy Lutomirski wrote:
>>> On Mon, Jan 19, 2026 at 10:56=E2=80=AFAM Askar Safin <safinaskar@gmail.=
com> wrote:
>>>
>>> Christian Brauner <brauner@kernel.org>:
>>>> Extend open_tree() with a new OPEN_TREE_NAMESPACE flag. Similar to
>>>> OPEN_TREE_CLONE only the indicated mount tree is copied. Instead of
>>>> returning a file descriptor referring to that mount tree
>>>> OPEN_TREE_NAMESPACE will cause open_tree() to return a file descriptor
>>>> to a new mount namespace. In that new mount namespace the copied mount
>>>> tree has been mounted on top of a copy of the real rootfs.
>>>
>>> I want to point at security benefits of this.
>>>
>>> [[ TL;DR: [1] and [2] are very big changes to how mount namespaces work=
.
>>> I like them, and I think they should get wider exposure. ]]
>>>
>>> If this patchset ([1]) and [2] both land (they are both in "next" now a=
nd
>>> likely will be submitted to mainline soon) and "nullfs_rootfs" is passe=
d on
>>> command line, then mount namespace created by open_tree(OPEN_TREE_NAMES=
PACE) will
>>> usually contain exactly 2 mounts: nullfs and whatever was passed to
>>> open_tree(OPEN_TREE_NAMESPACE).
>>>
>>> This means that even if attacker somehow is able to unmount its root an=
d
>>> get access to underlying mounts, then the only underlying thing they wi=
ll
>>> get is nullfs.
>>>
>>> Also this means that other mounts are not only hidden in new namespace,=
 they
>>> are fully absent. This prevents attacks discussed here: [3], [4].
>>>
>>> Also this means that (assuming we have both [1] and [2] and "nullfs_roo=
tfs"
>>> is passed), there is no anymore hidden writable mount shared by all con=
tainers,
>>> potentially available to attackers. This is concern raised in [5]:
>>>
>>>> You want rootfs to be a NULLFS instead of ramfs. You don't seem to wan=
t it to
>>>> actually _be_ a filesystem. Even with your "fix", containers could com=
municate
>>>> with each _other_ through it if it becomes accessible. If a container =
can get
>>>> access to an empty initramfs and write into it, it can ask/answer the =
question
>>>> "Are there any other containers on this machine running stux24" and th=
en coordinate.
>>
>> I think this new OPEN_TREE_NAMESPACE is nifty, but I don't think the
>> path that gives it sensible behavior should be conditional like this.
>> Either make it *always* mount on top of nullfs (regardless of boot
>> options) or find some way to have it actually be the root.  I assume
>> the latter is challenging for some reason.
>>
>
> I think that's the plan. I suggested the same to Christian last week,
> and he was amenable to removing the option and just always doing a
> nullfs_rootfs mount.
>
> We think that older runtimes should still "just work" with this scheme.
> Out of an abundance of caution, we _might_ want a command-line option
> to make it go back to old way, in case we find some userland stuff that
> doesn't like this for some reason, but hopefully we won't even need
> that.

What I mean is: even if for some reason the kernel is running in a
mode where the *initial* rootfs is a real fs, I think it would be nice
for OPEN_TREE_NAMESPACE to use nullfs.
