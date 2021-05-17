Received: from mail-io1-f48.google.com (mail-io1-f48.google.com [209.85.166.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6205E70
	for <containers@lists.linux.dev>; Mon, 17 May 2021 17:08:35 +0000 (UTC)
Received: by mail-io1-f48.google.com with SMTP id i7so6516157ioa.12
        for <containers@lists.linux.dev>; Mon, 17 May 2021 10:08:35 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=sargun.me; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=hN1fiA1phqGUjL4yu5RPTW49+OWuWPqOhTclUxcTVTM=;
        b=stvBT95tmJr9ijwlzfUrpbqTeGdjjqzLDbsC1KySG1+IwC4oOU3lk0OhRAPjqM+QIK
         NISJeFGF4Bc3IN9KlaBuuKAvNaWhy8mQ0Qw1Vsv1olKD4D49m+WADyzLiS0+Yg+e0YgS
         fdf+5jNwgljDMOCt43k0bYZSvGmf+NPMPi768=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc:content-transfer-encoding;
        bh=hN1fiA1phqGUjL4yu5RPTW49+OWuWPqOhTclUxcTVTM=;
        b=hBiWEKTe4LIbT427ys1ZJySUmpdleEu1sAHizVELWglEXGpoQnIu3tydrowRzvYxDZ
         KM0X8OnnUPVSr60LN+xtcWRx05dfpZxUo+rSt+ijlMdd9IDKOoc2/QOLUZ3ZlTO2JDRB
         XZ2dj1gddiGtd1sWv5sKnaxNveAbLBjSWh7vAXOsJu+FWH2MjKHBIWTVHu3j1GHttVMP
         0vMQZDNjR1q69kgsOimfeCdTVSX25jF3LDNDhJn5eTooGK/JCmL3W3LixxbuGlsKs6z9
         bmft+O7NawCsT3JviIoPnyO9oo9KB73ZlL1kOs0aXmY/tA3az3vErFdmT/kO/QXd5Vq1
         FAXw==
X-Gm-Message-State: AOAM5327ykhwDrlkgBVs1GitKtdn+a+UMx4r9x8pGKQVSw9JR6ofI44n
	LDluyFZ2jOcBzpG/Lzr4+C4eflrsp8BvkRwHy7gUJA==
X-Google-Smtp-Source: ABdhPJyxx1VOxJo+YjtzQesx0ri4JWpHUTsm/VBLiwbJ8L3CSi75xkRZ3+Sx1dQPhNxWcFsB+t6M+Hw5iNklVL4sGp8=
X-Received: by 2002:a05:6638:10c4:: with SMTP id q4mr977779jad.29.1621271314217;
 Mon, 17 May 2021 10:08:34 -0700 (PDT)
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <cover.1620499942.git.yifeifz2@illinois.edu> <CALCETrUQBonh5BC4eomTLpEOFHVcQSz9SPcfOqNFTf2TPht4-Q@mail.gmail.com>
 <CABqSeASYRXMwTQwLfm_Tapg45VUy9sPfV7BeeV8p7XJrDoLf+Q@mail.gmail.com>
 <fffbea8189794a8da539f6082af3de8e@DM5PR11MB1692.namprd11.prod.outlook.com> <CAGMVDEGzGB4+6gJPTw6Tdng5ur9Jua+mCbqwPoNZ16EFaDcmjA@mail.gmail.com>
In-Reply-To: <CAGMVDEGzGB4+6gJPTw6Tdng5ur9Jua+mCbqwPoNZ16EFaDcmjA@mail.gmail.com>
From: Sargun Dhillon <sargun@sargun.me>
Date: Mon, 17 May 2021 10:07:58 -0700
Message-ID: <CAMp4zn86JwT-p8-unev9rOBeeyfm4KNxkDzygCqYjX=duBMywg@mail.gmail.com>
Subject: Re: [RFC PATCH bpf-next seccomp 00/12] eBPF seccomp filters
To: Tianyin Xu <tyxu@illinois.edu>
Cc: Andy Lutomirski <luto@kernel.org>, YiFei Zhu <zhuyifei1999@gmail.com>, 
	"containers@lists.linux.dev" <containers@lists.linux.dev>, bpf <bpf@vger.kernel.org>, 
	"Zhu, YiFei" <yifeifz2@illinois.edu>, LSM List <linux-security-module@vger.kernel.org>, 
	Alexei Starovoitov <ast@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, 
	"Kuo, Hsuan-Chi" <hckuo2@illinois.edu>, Claudio Canella <claudio.canella@iaik.tugraz.at>, 
	Daniel Borkmann <daniel@iogearbox.net>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, 
	Dimitrios Skarlatos <dskarlat@cs.cmu.edu>, Giuseppe Scrivano <gscrivan@redhat.com>, 
	Hubertus Franke <frankeh@us.ibm.com>, Jann Horn <jannh@google.com>, 
	"Jia, Jinghao" <jinghao7@illinois.edu>, "Torrellas, Josep" <torrella@illinois.edu>, 
	Kees Cook <keescook@chromium.org>, Tobin Feldman-Fitzthum <tobin@ibm.com>, 
	Tom Hromatka <tom.hromatka@oracle.com>, Will Drewry <wad@chromium.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, May 16, 2021 at 1:39 AM Tianyin Xu <tyxu@illinois.edu> wrote:
>
> On Sat, May 15, 2021 at 10:49 AM Andy Lutomirski <luto@kernel.org> wrote:
> >
> > On 5/10/21 10:21 PM, YiFei Zhu wrote:
> > > On Mon, May 10, 2021 at 12:47 PM Andy Lutomirski <luto@kernel.org> wr=
ote:
> > >> On Mon, May 10, 2021 at 10:22 AM YiFei Zhu <zhuyifei1999@gmail.com> =
wrote:
> > >>>
> > >>> From: YiFei Zhu <yifeifz2@illinois.edu>
> > >>>
> > >>> Based on: https://urldefense.com/v3/__https://lists.linux-foundatio=
n.org/pipermail/containers/2018-February/038571.html__;!!DZ3fjg!thbAoRgmCeW=
jlv0qPDndNZW1j6Y2Kl_huVyUffr4wVbISf-aUiULaWHwkKJrNJyo$
> > >>>
> > >>> This patchset enables seccomp filters to be written in eBPF.
> > >>> Supporting eBPF filters has been proposed a few times in the past.
> > >>> The main concerns were (1) use cases and (2) security. We have
> > >>> identified many use cases that can benefit from advanced eBPF
> > >>> filters, such as:
> > >>
> > >> I haven't reviewed this carefully, but I think we need to distinguis=
h
> > >> a few things:
> > >>
> > >> 1. Using the eBPF *language*.
> > >>
> > >> 2. Allowing the use of stateful / non-pure eBPF features.
> > >>
> > >> 3. Allowing the eBPF programs to read the target process' memory.
> > >>
> > >> I'm generally in favor of (1).  I'm not at all sure about (2), and I=
'm
> > >> even less convinced by (3).
> > >>
> > >>>
> > >>>   * exec-only-once filter / apply filter after exec
> > >>
> > >> This is (2).  I'm not sure it's a good idea.
> > >
> > > The basic idea is that for a container runtime it may wait to execute
> > > a program in a container without that program being able to execve
> > > another program, stopping any attack that involves loading another
> > > binary. The container runtime can block any syscall but execve in the
> > > exec-ed process by using only cBPF.
> > >
> > > The use case is suggested by Andrea Arcangeli and Giuseppe Scrivano.
> > > @Andrea and @Giuseppe, could you clarify more in case I missed
> > > something?
> >
> > We've discussed having a notifier-using filter be able to replace its
> > filter.  This would allow this and other use cases without any
> > additional eBPF or cBPF code.
> >
>
> A notifier is not always a solution (even ignoring its perf overhead).
>
> One problem, pointed out by Andrea Arcangeli, is that notifiers need
> userspace daemons. So, it can hardly be used by daemonless container
> engines like Podman.
>
> And, /* sorry for repeating.. */ the performance overhead of notifiers
> is not close to ebpf, which prevents use cases that require native
> performance.

While I agree with you that this is the case right now, there's no reason i=
t
has to be the case. There's a variety of mechanisms that can be employed
to significantly speed up the performance of the notifier. For example, rig=
ht
now the notifier is behind one large per-filter lock. That could be removed
allowing for better concurrency. There are a large number of mechanisms
that scale O(n) with the outstanding notifications -- again, something
that could be improved.

The other big improvement that could be made is being able to use something
like io_uring with the notifier interface, but it would require a
fairly significant
user API change -- and a move away from ioctl. I'm not sure if people are
excited about that idea at the moment.

>
>
> > >> eBPF doesn't really have a privilege model yet.  There was a long an=
d
> > >> disappointing thread about this awhile back.
> > >
> > > The idea is that =E2=80=9Cseccomp-eBPF does not make life easier for =
an
> > > adversary=E2=80=9D. Any attack an adversary could potentially utilize
> > > seccomp-eBPF, they can do the same with other eBPF features, i.e. it
> > > would be an issue with eBPF in general rather than specifically
> > > seccomp=E2=80=99s use of eBPF.
> > >
> > > Here it is referring to the helpers goes to the base
> > > bpf_base_func_proto if the caller is unprivileged (!bpf_capable ||
> > > !perfmon_capable). In this case, if the adversary would utilize eBPF
> > > helpers to perform an attack, they could do it via another
> > > unprivileged prog type.
> > >
> > > That said, there are a few additional helpers this patchset is adding=
:
> > > * get_current_uid_gid
> > > * get_current_pid_tgid
> > >   These two provide public information (are namespaces a concern?). I
> > > have no idea what kind of exploit it could add unless the adversary
> > > somehow side-channels the task_struct? But in that case, how is the
> > > reading of task_struct different from how the rest of the kernel is
> > > reading task_struct?
> >
> > Yes, namespaces are a concern.  This idea got mostly shot down for kdbu=
s
> > (what ever happened to that?), and it likely has the same problems for
> > seccomp.
> >
> > >>
> > >> What is this for?
> > >
> > > Memory reading opens up lots of use cases. For example, logging what
> > > files are being opened without imposing too much performance penalty
> > > from strace. Or as an accelerator for user notify emulation, where
> > > syscalls can be rejected on a fast path if we know the memory content=
s
> > > does not satisfy certain conditions that user notify will check.
> > >
> >
> > This has all kinds of race conditions.
> >
> >
> > I hate to be a party pooper, but this patchset is going to very high ba=
r
> > to acceptance.  Right now, seccomp has a couple of excellent properties=
:
> >
> > First, while it has limited expressiveness, it is simple enough that th=
e
> > implementation can be easily understood and the scope for
> > vulnerabilities that fall through the cracks of the seccomp sandbox
> > model is low.  Compare this to Windows' low-integrity/high-integrity
> > sandbox system: there is a never ending string of sandbox escapes due t=
o
> > token misuse, unexpected things at various integrity levels, etc.
> > Seccomp doesn't have tokens or integrity levels, and these bugs don't
> > happen.
> >
> > Second, seccomp works, almost unchanged, in a completely unprivileged
> > context.  The last time making eBPF work sensibly in a less- or
> > -unprivileged context, the maintainers mostly rejected the idea of
> > developing/debugging a permission model for maps, cleaning up the bpf
> > object id system, etc.  You are going to have a very hard time
> > convincing the seccomp maintainers to let any of these mechanism
> > interact with seccomp until the underlying permission model is in place=
.
> >
> > --Andy
>
> Thanks for pointing out the tradeoff between expressiveness vs. simplicit=
y.
>
> Note that we are _not_ proposing to replace cbpf, but propose to also
> support ebpf filters. There certainly are use cases where cbpf is
> sufficient, but there are also important use cases ebpf could make
> life much easier.
>
> Most importantly, we strongly believe that ebpf filters can be
> supported without reducing security.
>
> No worries about =E2=80=9Cparty pooping=E2=80=9D and we appreciate the fe=
edback. We=E2=80=99d
> love to hear concerns and collect feedback so we can address them to
> hit that very high bar.
>
>
> ~t
>
> --
> Tianyin Xu
> University of Illinois at Urbana-Champaign
> https://tianyin.github.io/
