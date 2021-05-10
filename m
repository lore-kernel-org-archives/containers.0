Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ACADF72
	for <containers@lists.linux.dev>; Mon, 10 May 2021 17:47:37 +0000 (UTC)
Received: by mail.kernel.org (Postfix) with ESMTPSA id C29306157E
	for <containers@lists.linux.dev>; Mon, 10 May 2021 17:47:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1620668856;
	bh=LxXDkuPWjPQk4BmdoXaxIQ+fI40u1+HYDgg51chi/dQ=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=FzFrcSOFgyjvVtFkpiu6+C/STNJuhbAaHo/DOw/NYxZvNS6ZGgaVJAqpg9gIKT1Ms
	 VB6gj6QPLcaVh+L7+RFNXnJpvK0m7zTEGGlAAsMytaqWncu1fp0C/IwWmFVxM1jZwA
	 u2ysW4OjGP13tL/9yvCPdVvVH69beEDByCln/iG+oSgAVwfFuNe7HQyGv6itb/eohr
	 Izh/oA20a9kgy4yRBfR24MMtOm7a3Di/007vrMj1ra9aKkxAU7BsuJ3frzzqGIzn0n
	 9llxTT3hAepIrRV2U1TRLD0MnpxE8pPhEr1eazWVXg7SH1/dTar9ltIHgZwWqmwiFK
	 JW73YP9Pr4W6A==
Received: by mail-ej1-f51.google.com with SMTP id s20so20291111ejr.9
        for <containers@lists.linux.dev>; Mon, 10 May 2021 10:47:36 -0700 (PDT)
X-Gm-Message-State: AOAM5311a8OcNcS3uEQmhA7M4b1HvO2KmhXiubT+GbtZql5XksrxjLjR
	hTm3Nou+M0PPBtD63x7AWxaC+rV3+ceWfmMZN/jK8g==
X-Google-Smtp-Source: ABdhPJy2u4NRHO7LXCrZDzVo0MGiSrS4ukdNDyUpYt96TNfdTFbw5aaY0iqnaNSKOQ9xWZbpI6ahZnrIdR2D6q8tRLM=
X-Received: by 2002:a17:907:1629:: with SMTP id hb41mr27755324ejc.316.1620668855059;
 Mon, 10 May 2021 10:47:35 -0700 (PDT)
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <cover.1620499942.git.yifeifz2@illinois.edu>
In-Reply-To: <cover.1620499942.git.yifeifz2@illinois.edu>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 10 May 2021 10:47:22 -0700
X-Gmail-Original-Message-ID: <CALCETrUQBonh5BC4eomTLpEOFHVcQSz9SPcfOqNFTf2TPht4-Q@mail.gmail.com>
Message-ID: <CALCETrUQBonh5BC4eomTLpEOFHVcQSz9SPcfOqNFTf2TPht4-Q@mail.gmail.com>
Subject: Re: [RFC PATCH bpf-next seccomp 00/12] eBPF seccomp filters
To: YiFei Zhu <zhuyifei1999@gmail.com>
Cc: containers@lists.linux.dev, bpf <bpf@vger.kernel.org>, 
	YiFei Zhu <yifeifz2@illinois.edu>, LSM List <linux-security-module@vger.kernel.org>, 
	Alexei Starovoitov <ast@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Austin Kuo <hckuo2@illinois.edu>, 
	Claudio Canella <claudio.canella@iaik.tugraz.at>, Daniel Borkmann <daniel@iogearbox.net>, 
	Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Dimitrios Skarlatos <dskarlat@cs.cmu.edu>, 
	Giuseppe Scrivano <gscrivan@redhat.com>, Hubertus Franke <frankeh@us.ibm.com>, Jann Horn <jannh@google.com>, 
	Jinghao Jia <jinghao7@illinois.edu>, Josep Torrellas <torrella@illinois.edu>, 
	Kees Cook <keescook@chromium.org>, Sargun Dhillon <sargun@sargun.me>, Tianyin Xu <tyxu@illinois.edu>, 
	Tobin Feldman-Fitzthum <tobin@ibm.com>, Tom Hromatka <tom.hromatka@oracle.com>, Will Drewry <wad@chromium.org>
Content-Type: text/plain; charset="UTF-8"

On Mon, May 10, 2021 at 10:22 AM YiFei Zhu <zhuyifei1999@gmail.com> wrote:
>
> From: YiFei Zhu <yifeifz2@illinois.edu>
>
> Based on: https://lists.linux-foundation.org/pipermail/containers/2018-February/038571.html
>
> This patchset enables seccomp filters to be written in eBPF.
> Supporting eBPF filters has been proposed a few times in the past.
> The main concerns were (1) use cases and (2) security. We have
> identified many use cases that can benefit from advanced eBPF
> filters, such as:

I haven't reviewed this carefully, but I think we need to distinguish
a few things:

1. Using the eBPF *language*.

2. Allowing the use of stateful / non-pure eBPF features.

3. Allowing the eBPF programs to read the target process' memory.

I'm generally in favor of (1).  I'm not at all sure about (2), and I'm
even less convinced by (3).

>
>   * exec-only-once filter / apply filter after exec

This is (2).  I'm not sure it's a good idea.

>   * syscall logging (eg. via maps)

This is (2).  Probably useful, but doesn't obviously belong in
seccomp, or at least not as part of the same seccomp feature as
regular filtering.

>   * expressiveness & better tooling (no need for DSLs like easyseccomp)

(1).  Sounds good.

>   * contained syscall fault injection

(2)?  We can already do this with notifiers.

> For security, for an unprivileged caller, our implementation is as
> restrictive as user notifier + ptrace, in regards to capabilities.
> eBPF helpers follow the privilege model of original eBPF helpers.

eBPF doesn't really have a privilege model yet.  There was a long and
disappointing thread about this awhile back.

> Moreover, a mechanism for reading user memory is added. The same
> prototypes of bpf_probe_read_user{,str} from tracing are used. However,
> when the loader of bpf program does not have CAP_PTRACE, the helper
> will return -EPERM if the task under seccomp filter is non-dumpable.
> The reason for this is that if we perform reduction from seccomp-eBPF
> to user notifier + ptrace, ptrace requires CAP_PTRACE to read from
> a non-dumpable process. However, eBPF does not solve the TOCTOU problem
> of user notifier, so users should not use this to enforce a policy
> based on memory contents.

What is this for?
