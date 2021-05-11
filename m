Received: from mail-pj1-f44.google.com (mail-pj1-f44.google.com [209.85.216.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1CAAD72
	for <containers@lists.linux.dev>; Tue, 11 May 2021 05:44:58 +0000 (UTC)
Received: by mail-pj1-f44.google.com with SMTP id ge1so11070799pjb.2
        for <containers@lists.linux.dev>; Mon, 10 May 2021 22:44:58 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=7XVavgeSmV2+7ZuA8AScQGjekCrXRJjlh8qmTF2ezzQ=;
        b=cYGXc/2ggSmY5+d1AujXwZwOLXQBpQggw62i01cWJViiFl+r+5/T4guXJ1GW1okCq5
         TF/Gzr8G6u70GyyQsx0BBDw5UxaRb0BwcWdu4hs/sYNK5IPUpr6bESivGYJGst4nYn0o
         vlYdjkNYrYVfVJZFAo6IHbDQX1b5kxz1s6qx8HXvd2tsZvzKXgQZVGMRT2FHj0b5z7Sh
         PxSAgkrObVGb0svSop5w4ZF0OgnaFSci/tzJqH/s1Ce2dZ1skQoh9dgFZbGHvHQwXTOL
         rJGiBtNeM5s7hspIyi0z5eAyjjg4L+L8hvc8fdYKoUCsVnLKLCH1i7Duu8xHL5F4+Tdf
         nTKg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=7XVavgeSmV2+7ZuA8AScQGjekCrXRJjlh8qmTF2ezzQ=;
        b=PJuxTYdgA4/FaC2isImBGw9knQv3FQiKeKiwGPR5b9iJTTxjL/i6sshjtOphaG08Hs
         yl766FzuBAjzIqpOfd7+6JschzzNzyjB2pbpuM7dYMRpRN1S9+/3Y9b/5PXavvfwY1A5
         SCDwbfLOEuY9vswR5cyZ+hy/Vrca4IXDrn8ROtnGyQf6xlnbXTMFtbBPF+P6ibcASAbA
         hzZPX/dOCGwscK8QpG1WXfG4uvJhxkXo+7aMYYfRMp84O0BrhvNjp34x+P+q7ZNrviUT
         p/152oINVywK/OwQ6C7ryrS2YMHt30bJ8yqcmTYWW1PZzbxklEeWoGUAe0U7ZQe/x8ES
         w4Tw==
X-Gm-Message-State: AOAM532+vLWXYiyBihctjtpGa5OakcMdDdrldyu8dlC3io2M0fvG/2Fu
	B5FfExC6UW2OEm7LgUi2IF/n/XY+rQ9sEHSY+7A=
X-Google-Smtp-Source: ABdhPJzScQ+ejW/lypbqMNzTBKNKVnN/6N4w1C3tVb4NxjroBcA9XNlX51+Z0Z3wuTOCRQmS6BrJeedWL165YjdWZr8=
X-Received: by 2002:a17:90a:d512:: with SMTP id t18mr3194031pju.108.1620711897656;
 Mon, 10 May 2021 22:44:57 -0700 (PDT)
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <cover.1620499942.git.yifeifz2@illinois.edu> <db41ad3924d01374d08984d20ad6678f91b82cde.1620499942.git.yifeifz2@illinois.edu>
 <20210511015814.5sr37y4ogf5cr7c5@ast-mbp.dhcp.thefacebook.com>
In-Reply-To: <20210511015814.5sr37y4ogf5cr7c5@ast-mbp.dhcp.thefacebook.com>
From: YiFei Zhu <zhuyifei1999@gmail.com>
Date: Tue, 11 May 2021 00:44:46 -0500
Message-ID: <CABqSeARf03BsdWJJO-w=Bb+goHB6nmBaErz8Qmpgden_Q4Txeg@mail.gmail.com>
Subject: Re: [RFC PATCH bpf-next seccomp 12/12] seccomp-ebpf: support task
 storage from BPF-LSM, defaulting to group leader
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Cc: containers@lists.linux.dev, bpf <bpf@vger.kernel.org>, 
	YiFei Zhu <yifeifz2@illinois.edu>, LSM List <linux-security-module@vger.kernel.org>, 
	Alexei Starovoitov <ast@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, 
	Andy Lutomirski <luto@amacapital.net>, Austin Kuo <hckuo2@illinois.edu>, 
	Claudio Canella <claudio.canella@iaik.tugraz.at>, Daniel Borkmann <daniel@iogearbox.net>, 
	Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Dimitrios Skarlatos <dskarlat@cs.cmu.edu>, 
	Giuseppe Scrivano <gscrivan@redhat.com>, Hubertus Franke <frankeh@us.ibm.com>, Jann Horn <jannh@google.com>, 
	Jinghao Jia <jinghao7@illinois.edu>, Josep Torrellas <torrella@illinois.edu>, 
	Kees Cook <keescook@chromium.org>, Sargun Dhillon <sargun@sargun.me>, Tianyin Xu <tyxu@illinois.edu>, 
	Tobin Feldman-Fitzthum <tobin@ibm.com>, Tom Hromatka <tom.hromatka@oracle.com>, Will Drewry <wad@chromium.org>
Content-Type: text/plain; charset="UTF-8"

On Mon, May 10, 2021 at 8:58 PM Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
>
> On Mon, May 10, 2021 at 12:22:49PM -0500, YiFei Zhu wrote:
> > +
> > +BPF_CALL_4(bpf_task_storage_get_default_leader, struct bpf_map *, map,
> > +        struct task_struct *, task, void *, value, u64, flags)
> > +{
> > +     if (!task)
> > +             task = current->group_leader;
>
> Did you actually need it to be group_leader or current is enough?
> If so loading BTF is not necessary.

I think if task_storage were to be used to apply a policy onto a set
of tasks, there are probably more use cases to perform the state
transitions across an entire process than state transitions across a
single thread. Though, since seccomp only applies to the process tree
a lot of use cases of a per-process storage would be covered by a
global datasec too.

> You could have exposed it bpf_get_current_task_btf() and passed its
> return value into bpf_task_storage_get.
>
> On the other side loading BTF can be relaxed to unpriv,
> but doing current->group_leader deref will make it priv only anyway.

Yeah, that deref is what I was concerned about. It seems that if I
expose BTF structs to a prog type it gains the ability to deref it,
and I definitely don't want unpriv reading task_structs. Though yeah
we could potentially change the verifier to prohibit PTR_TO_BTF_ID
deref and any pointer arithmetic on it...

How about, we expose bpf_get_current_task_btf to unpriv, prohibit
unpriv deref and pointer arithmetic, and have NULL be
current->group_leader? This way, unpriv has access to both per-thread
and per-process.

YiFei Zhu
