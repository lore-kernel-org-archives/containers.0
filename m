Received: from mail-wr1-f47.google.com (mail-wr1-f47.google.com [209.85.221.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1256DEA6
	for <containers@lists.linux.dev>; Fri, 13 Oct 2023 02:44:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=bytedance.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=bytedance.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=bytedance.com header.i=@bytedance.com header.b="BMRHjRg+"
Received: by mail-wr1-f47.google.com with SMTP id ffacd0b85a97d-307d20548adso1499470f8f.0
        for <containers@lists.linux.dev>; Thu, 12 Oct 2023 19:44:57 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=bytedance.com; s=google; t=1697165096; x=1697769896; darn=lists.linux.dev;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=z1lyC0nih0TRN64tEVRuATNQ7XUg5wsUqTB5uQ4du+Y=;
        b=BMRHjRg+8DnhbB86mC5SXyU9x4Jv+hSxBa6Bw4RZx/SLPWHXFyTMJ0Z0IwqpIuuP6a
         fe32+05/4O/IzTd9vBLI9yKHg7J86C7csevzjPpmsWdZ+LoUpuyQZ5EFL4pmQ0bgn1nS
         LoQonQczrabFzflGLTBx5CH3w+UDm2DDThePRQZ64pqcOiX+76QaQZILVFbaZkbHNvoW
         rIvW16SFTYvJ53Xk13uMd8E66WAAIHGXn1T52QAdFSoFbkXeBB1YUItCE3rzIhFoUFbJ
         oC1LS7UIrclQyGNwT6EMq+E0zYRyZbfco6U/b2TMk1otROBazV/veHa2lJe/tM2avrn8
         DfGQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1697165096; x=1697769896;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=z1lyC0nih0TRN64tEVRuATNQ7XUg5wsUqTB5uQ4du+Y=;
        b=wXkvmDQs8jeRu/O9JDs5NVrkw6FnOu24I2oNfN7tui1/36hiMnzCUb/gbWn9sI42mf
         rqsP/nq8s9DpTRbxbhDQInP0bLD5VZl4wxOKM6v5wktZFLNm2pZnw+nWdb9dfZcBl/U2
         FsQPscLwGCUkJSagETopvlTabz1WJZUFj9cULm+3bvqCiDn+rWAa/45l6cEHRZEr8nLv
         cfzeL4oKglwbP810QxZE/Bk3gkPJshCMe7eDu4fdj1i0LhENDOsirFFIrmlTW2Xz5jgD
         yOdVdb9qUrlQVGaj+SYmoNw2sfngyt0LFsNRIz5EdEjwMqXpTBMu8E5cwIMxa+cvoJx0
         eI+g==
X-Gm-Message-State: AOJu0Ywx9SCeUh4bznWa3efPpd2r72Pu9TOkZW5/igti8VP7d99nEck1
	o5NSRuMclp0eIT9+SYEFhaaA6ps0MlZL8GXfl52Shw==
X-Google-Smtp-Source: AGHT+IFPdinKLbIrsWSAo59uFs4LydzQ3vnVtniSmEYxu/qI1CgqO7VuK62PuQ1KxWSv5gdv5NHcLG3lVIvaQ2VfIqo=
X-Received: by 2002:adf:eb0e:0:b0:31f:afeb:4e7e with SMTP id
 s14-20020adfeb0e000000b0031fafeb4e7emr19069138wrn.37.1697165096139; Thu, 12
 Oct 2023 19:44:56 -0700 (PDT)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <20231011065446.53034-1-cuiyunhui@bytedance.com> <87sf6gcyb3.fsf@email.froward.int.ebiederm.org>
In-Reply-To: <87sf6gcyb3.fsf@email.froward.int.ebiederm.org>
From: yunhui cui <cuiyunhui@bytedance.com>
Date: Fri, 13 Oct 2023 10:44:45 +0800
Message-ID: <CAEEQ3wm8oE1dXo7AuU3gY90oF_G21OqNZwnkqhhd1-_j4wWbYQ@mail.gmail.com>
Subject: Re: [External] Re: [PATCH] pid_ns: support pidns switching between sibling
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: akpm@linux-foundation.org, keescook@chromium.org, brauner@kernel.org, 
	jeffxu@google.com, frederic@kernel.org, mcgrof@kernel.org, cyphar@cyphar.com, 
	rongtao@cestc.cn, linux-kernel@vger.kernel.org, 
	Linux Containers <containers@lists.linux.dev>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Eric,

On Thu, Oct 12, 2023 at 11:31=E2=80=AFAM Eric W. Biederman
<ebiederm@xmission.com> wrote:
>
> Yunhui Cui <cuiyunhui@bytedance.com> writes:
>
> > In the scenario of container acceleration,
>
> What is container acceleration?
>
> Are you perhaps performing what is essentially checkpoint/restart
> from one set of processes to a new set of processes so you can
> get a container starting faster?
Yeah, you are right .

>
> > when a target pstree is cloned from a temp pstree, we hope that the
> > cloned process is inherently in the target's pid namespace.
>
> I am having a hard time figuring out what you are saying here.

I think I need to describe in detail our needs and problems we face.
What we need to do is fork a container into a new container, which
means that all
processes of the original container need to be forked out and added to
the new container.
Then the forked process needs to be added to the namespace and cgroup
of the new container.

What we are talking about here is the pid namespace.

for example:
Assume that there are three processes A, B, and C in the original container=
.
What we need to do is A fork A_new, B fork B_new, C fork C_new.

However, in the existing pidns implementation, the parent process
first joins pidns, and then
the forked child process will get the new pidns (the pid of the child
process is what we expected),
and the parent process's own pidns has not actually changed (at least
pid is still existing).

To make A_new, B_new, and C_new inherently in the pidns of the new containe=
r,
A, B, and C must first switch to the pidns of the new container, right?
From my understanding there is no better way to implement it.

But the existing implementation (the part to be changed in this patch)
is blocking our progress.

>
> > Examples of what we expected:
> >
> > /* switch to target ns first. */
> > setns(target_ns, CLONE_NEWPID);
>   ^-------- Is this the line that fails for you?
>
> > if(!fork()) {
> > /* Child */
> > ...
> > }
> > /* switch back */
> > setns(temp_ns, CLONE_NEWPID);
>
> Assuming that the "switch back" means returning to your
> task_active_pid_ns that should always work.

In the scenario I described, "switch back" would certainly work.

dst_pidns =3D open("/proc/%d/ns/pid");
src_pidns =3D open("/proc/self/ns/pid");

setns(dst_pidns, CLONE_NEWPID);
if(!fork()) {
/* Child */
/* The child process is born in the pidns of the new container. */
...
}
/* switch back */
setns(src_pidns, CLONE_NEWPID);

>
> If I had to guess I think what you are missing is that entire pid
> namespaces can be inside other pid namespaces.
>
> So there is no reason to believe that any random pid namespace
> that happens to pass the CAP_SYS_ADMIN permission check is also in
> your processes task_active_pid_ns.
>
>
> > However, it is limited by the existing implementation, CAP_SYS_ADMIN
> > has been checked in pidns_install(), so remove the limitation that only
> > by traversing parent can switch pidns.
>
> The check you are deleting is what verifies the pid namespaces you are
> attempting to change pid_ns_for_children to is a member of the tasks
> current pid namespace (aka task_active_pid_ns).
>
>
> There is a perfectly good comment describing why what you are attempting
> to do is unsupportable.
>
>         /*
>          * Only allow entering the current active pid namespace
>          * or a child of the current active pid namespace.
>          *
>          * This is required for fork to return a usable pid value and
>          * this maintains the property that processes and their
>          * children can not escape their current pid namespace.
>          */
>
>
> If you pick a pid namespace that does not meet the restrictions you are
> removing the pid of the new child can not be mapped into the pid
> namespace of the parent that called setns.
>
> AKA the following code can not work.
>
> pid =3D fork();
> if (!pid) {
>         /* child */
>         do_something();
>         _exit(0);
> }
> waitpid(pid);

Sorry, I don't understand what you mean here.

>
>
> So no.  The suggested change to pidns_install makes no sense at all.
>
> The whole not being able to escape your current pid namespace is
> also an important invariant when reasoning about pid namespaces.
>
> It would have to be a strong well thought out case for me to agree
> it makes sense to abandon the invariant that a process can not escape
> it's pid namespace.

I think we'd better have a good understanding of the problems we face first=
,
and then think of a more comprehensive way to solve it.
Although the modification of this patch is not perfect, do we have a better=
 way?


Thanks,
Yunhui
