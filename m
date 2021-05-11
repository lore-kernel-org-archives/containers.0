Received: from mail-pj1-f51.google.com (mail-pj1-f51.google.com [209.85.216.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C80CA72
	for <containers@lists.linux.dev>; Tue, 11 May 2021 05:21:29 +0000 (UTC)
Received: by mail-pj1-f51.google.com with SMTP id cl24-20020a17090af698b0290157efd14899so681997pjb.2
        for <containers@lists.linux.dev>; Mon, 10 May 2021 22:21:29 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=caF/eq5CvK+86qA7I6X4w/ANOi8/0zsUMt7O4FtGC4A=;
        b=TTRILg4heD84x2HzdgreC8IX/InWXGMAJ7Wd7w4LOT3egaAqfkqCFUJLDlMq91IQha
         aSqmTWETGdCQqkOoZjrFbDM7lJNKYyuf0MgZzo/3gTBl4lhnLG7cMOOqzQLqSyCFUDf8
         6+TeG6s6jm42HY7mjEW0SFTwXc7iSp8+lXhHm2y7hznHM725tfNZWWSM25rmvSIoQ+UF
         bO/g9Uoy09IjzE1/S7AKdDMZrE9Q/s1JCa4A02S2T0HH/ysUit7Pj4dbMfLV3Pj6RlJn
         /jerHTIMPGyDlXDsk32uvFSZ11QD3u5t+3k6Bq1SZtTUs9XwZQl799CIDM+FrR6WIlJh
         VoVQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc:content-transfer-encoding;
        bh=caF/eq5CvK+86qA7I6X4w/ANOi8/0zsUMt7O4FtGC4A=;
        b=eEdSSGebbbFVEdMvKl344YcdmrP5DEqMByozck6PfhEw/+ms740/w+pOHIbByKf+Wr
         1kwa33g4QbOqzBO4QY7oGvLlzHAxuwrs+eEuE4U6pUX5bo9TO0dbFUI6j2I6ichBQEkp
         EKPBslxrsV8VMQs3EbsuFSiHrF/7NmRkbLjc9KuvfFDFCiV/tvZwv2mh2vqVhdiC0fhY
         ABxMQ9MJapVIj7Ek0MdJ7drns1C6/xdVOQFiYoYv0k7XmxpnNedcsguDj0QjbA2lqflL
         nAPyL5kjITwIPvmIhqIasyTpGZeV29N1mvBYEvU1guiG/LWbthXY991slSl+6zMwSabn
         famQ==
X-Gm-Message-State: AOAM532ou1dVbjuf/kYauLzUa6CWePbRGrJNDeRaxbSDxyOBTL8vrG2w
	OBhqnGKm2v2rdBTFyUwAv9hVreLAM5nOngXSS4s=
X-Google-Smtp-Source: ABdhPJz7DqIjKAj/p67LK4bNp1O0568mtcXcGoJyFm8AAHL3JTQZX+EJrydjwfg/iik+nuMwDe7HVWnlcgT5ViFkL04=
X-Received: by 2002:a17:902:f686:b029:ee:fa93:95af with SMTP id
 l6-20020a170902f686b02900eefa9395afmr27928376plg.83.1620710489110; Mon, 10
 May 2021 22:21:29 -0700 (PDT)
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <cover.1620499942.git.yifeifz2@illinois.edu> <CALCETrUQBonh5BC4eomTLpEOFHVcQSz9SPcfOqNFTf2TPht4-Q@mail.gmail.com>
In-Reply-To: <CALCETrUQBonh5BC4eomTLpEOFHVcQSz9SPcfOqNFTf2TPht4-Q@mail.gmail.com>
From: YiFei Zhu <zhuyifei1999@gmail.com>
Date: Tue, 11 May 2021 00:21:17 -0500
Message-ID: <CABqSeASYRXMwTQwLfm_Tapg45VUy9sPfV7BeeV8p7XJrDoLf+Q@mail.gmail.com>
Subject: Re: [RFC PATCH bpf-next seccomp 00/12] eBPF seccomp filters
To: Andy Lutomirski <luto@kernel.org>
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
Content-Transfer-Encoding: quoted-printable

On Mon, May 10, 2021 at 12:47 PM Andy Lutomirski <luto@kernel.org> wrote:
> On Mon, May 10, 2021 at 10:22 AM YiFei Zhu <zhuyifei1999@gmail.com> wrote=
:
> >
> > From: YiFei Zhu <yifeifz2@illinois.edu>
> >
> > Based on: https://lists.linux-foundation.org/pipermail/containers/2018-=
February/038571.html
> >
> > This patchset enables seccomp filters to be written in eBPF.
> > Supporting eBPF filters has been proposed a few times in the past.
> > The main concerns were (1) use cases and (2) security. We have
> > identified many use cases that can benefit from advanced eBPF
> > filters, such as:
>
> I haven't reviewed this carefully, but I think we need to distinguish
> a few things:
>
> 1. Using the eBPF *language*.
>
> 2. Allowing the use of stateful / non-pure eBPF features.
>
> 3. Allowing the eBPF programs to read the target process' memory.
>
> I'm generally in favor of (1).  I'm not at all sure about (2), and I'm
> even less convinced by (3).
>
> >
> >   * exec-only-once filter / apply filter after exec
>
> This is (2).  I'm not sure it's a good idea.

The basic idea is that for a container runtime it may wait to execute
a program in a container without that program being able to execve
another program, stopping any attack that involves loading another
binary. The container runtime can block any syscall but execve in the
exec-ed process by using only cBPF.

The use case is suggested by Andrea Arcangeli and Giuseppe Scrivano.
@Andrea and @Giuseppe, could you clarify more in case I missed
something?

> >   * syscall logging (eg. via maps)
>
> This is (2).  Probably useful, but doesn't obviously belong in
> seccomp, or at least not as part of the same seccomp feature as
> regular filtering.
>
> >   * expressiveness & better tooling (no need for DSLs like easyseccomp)
>
> (1).  Sounds good.
>
> >   * contained syscall fault injection
>
> (2)?  We can already do this with notifiers.

To clarify, =E2=80=9Cwe can already do with notifiers=E2=80=9D isn=E2=80=99=
t the point here.
We can do almost everything if you have notifiers and ptrace, but it
may impose significant overhead (see the microbenchmark results).

The reason I=E2=80=99m saying the overhead is important is for the
reproduction / testing of certain race conditions. A syscall failing
quickly in a userspace application could, from a race condition, have
a completely different trace as a syscall failing after a few context
switches. eBPF makes quick fault injection possible.

> > For security, for an unprivileged caller, our implementation is as
> > restrictive as user notifier + ptrace, in regards to capabilities.
> > eBPF helpers follow the privilege model of original eBPF helpers.
>
> eBPF doesn't really have a privilege model yet.  There was a long and
> disappointing thread about this awhile back.

The idea is that =E2=80=9Cseccomp-eBPF does not make life easier for an
adversary=E2=80=9D. Any attack an adversary could potentially utilize
seccomp-eBPF, they can do the same with other eBPF features, i.e. it
would be an issue with eBPF in general rather than specifically
seccomp=E2=80=99s use of eBPF.

Here it is referring to the helpers goes to the base
bpf_base_func_proto if the caller is unprivileged (!bpf_capable ||
!perfmon_capable). In this case, if the adversary would utilize eBPF
helpers to perform an attack, they could do it via another
unprivileged prog type.

That said, there are a few additional helpers this patchset is adding:
* get_current_uid_gid
* get_current_pid_tgid
  These two provide public information (are namespaces a concern?). I
have no idea what kind of exploit it could add unless the adversary
somehow side-channels the task_struct? But in that case, how is the
reading of task_struct different from how the rest of the kernel is
reading task_struct?
  Though, if knowing the global uid / pid is a concern then the eBPF
progs will need to keep track of namespaces, and that might not be
trivial.
* probe_read_user
* probe_read_user_str
  Reduction to ptrace. The privilege model of reading another
process=E2=80=99s data (via process_vm_readv or
ptrace(PTRACE_PEEK{TEXT,DATA})) is guarded by
PTRACE_MODE_ATTACH_REALCREDS. However, unprivileged seccomp is
safeguarded by no_new_privs, so, unless the caller have a non-uniform
resuid & fsuid, in which case it=E2=80=99s the caller=E2=80=99s failure to =
relinquish
privileges, ruid of the seccomp-eBPF executor (which is task whose
syscalls is being filtered) would be the save as the ruid of the
applier (the task that set the seccomp mode, at the time of setting
it).
  The main concern here is LSMs. LSMs can further restrict the scope
of ptrace hence I also allow LSMs to deny all =E2=80=9Cthe use of stateful =
/
non-pure eBPF features=E2=80=9D.
  As for side channels... the copy_from_user_nofault may allow an
adversary to observe what=E2=80=99s in resident memory and what=E2=80=99s s=
wapped out,
but the adversary can already do this by observing the timing of
memory accesses. The non-nofault variant copy_from_user is used
everywhere in the kernel, so if an adversary were to side channel the
kernel by copy_from_user against an address, they can already do it by
using a syscall with a pointer that would be used by copy_from_user.
* task_storage_get
* task_storage_delete
  This is what I=E2=80=99m least sure about. The implementation of
task_storage is more complex than the other helpers, and also assumes
a privileged eBPF loader. It would slightly extend the attack surface.
If this is a big issue then eBPF can emulate such a map by using some
hashmap and having PID as key...

> > Moreover, a mechanism for reading user memory is added. The same
> > prototypes of bpf_probe_read_user{,str} from tracing are used. However,
> > when the loader of bpf program does not have CAP_PTRACE, the helper
> > will return -EPERM if the task under seccomp filter is non-dumpable.
> > The reason for this is that if we perform reduction from seccomp-eBPF
> > to user notifier + ptrace, ptrace requires CAP_PTRACE to read from
> > a non-dumpable process. However, eBPF does not solve the TOCTOU problem
> > of user notifier, so users should not use this to enforce a policy
> > based on memory contents.
>
> What is this for?

Memory reading opens up lots of use cases. For example, logging what
files are being opened without imposing too much performance penalty
from strace. Or as an accelerator for user notify emulation, where
syscalls can be rejected on a fast path if we know the memory contents
does not satisfy certain conditions that user notify will check.

YiFei Zhu
