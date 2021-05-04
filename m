Received: from mail-lf1-f41.google.com (mail-lf1-f41.google.com [209.85.167.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 227B070
	for <containers@lists.linux.dev>; Tue,  4 May 2021 18:29:34 +0000 (UTC)
Received: by mail-lf1-f41.google.com with SMTP id c3so10675866lfs.7
        for <containers@lists.linux.dev>; Tue, 04 May 2021 11:29:33 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=JXXBzPVYriNU3AZ8+T/Ep3xDDMXplh3X9mxTUQBN+dA=;
        b=hUIk+ejn4mtB5LxTTxxmX1ZYUMPfRW5P8+zTJMe6n5i7h98wmNOBt3kaTME94977CJ
         68D0w2yrHs/GckpeSze/93uWthbAOqoG77DneKmNQznDB9tNH/eAf+q48A+C1hGuv3XS
         Rm+2A59azRpg2dSEuZk8CxcVx96ggecVZOt+K81EQjGcYjjc4ovtg3pfBUWPStMPYHgS
         byiQHzCg7fyjt/Zb+iswScBHIKYAMPvulGqgFsOESr4b80b0OLp9Zkgld+gC78KlaCyp
         2W6mVjuaY8+77uVUp/t9IZXfQB01ZTjMYKGJ2qCPBNhQphXjt6sPcZrLuq96VlK4xleN
         QSMA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=JXXBzPVYriNU3AZ8+T/Ep3xDDMXplh3X9mxTUQBN+dA=;
        b=RbmQJik/30cbCRO2aexMmExvZH3bz3aX5XHxTzztD0JzrdPyq/aXg5sPNJ3scSqHJx
         XHRr6GKQP6307R7czucCzNFXrj5qA4UiL9Rxy9GPf2dpwvYeVu+m5arjFgztwxRc8kWB
         Lt4qKGwNQV/EG45elCAYuh1SoBOucL/L72PCzKvuFhSnzAHQPaMuPIDuu+0gc2svimnG
         hVULOk/pAvLbkFeUmc233kAjZ5VNatQkahlME+apSdEwGAcpXCY0861jdOMYalANG5TO
         mnjzEfXhsYYVrAcC2eiZ5e35jzwOXlpZoUIIu9GQ2ai+7SfET2eeVzRoewodrcD5bm6L
         iyVA==
X-Gm-Message-State: AOAM532iV7gE0q2wGUVtgQ7Qj+fivPiMpMwtbOHDymU8acJc55JkBzza
	L94zRdyuQLrPEwBgqr+sJfWngpnj7XTrrY1OUpUt1A==
X-Google-Smtp-Source: ABdhPJzTFw0ATQzNtH7zRPhI1FS9ArT6LmgJd+cmxH6tIg2VPP6mKUzSJaCoH/lzHoBxhNRCnEZ2Pfb8FX81sFWxseo=
X-Received: by 2002:a05:6512:2344:: with SMTP id p4mr2756781lfu.299.1620152972009;
 Tue, 04 May 2021 11:29:32 -0700 (PDT)
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <20210503143922.3093755-1-brauner@kernel.org>
In-Reply-To: <20210503143922.3093755-1-brauner@kernel.org>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 4 May 2021 11:29:21 -0700
Message-ID: <CALvZod4jsb6bFzTOS4ZRAJGAzBru0oWanAhezToprjACfGm+ew@mail.gmail.com>
Subject: Re: [PATCH v2 1/5] cgroup: introduce cgroup.kill
To: Christian Brauner <brauner@kernel.org>, Michal Hocko <mhocko@kernel.org>
Cc: Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>, Zefan Li <lizefan.x@bytedance.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, Cgroups <cgroups@vger.kernel.org>, containers@lists.linux.dev, 
	Christian Brauner <christian.brauner@ubuntu.com>, Linux MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"

+Michal Hocko

On Mon, May 3, 2021 at 7:40 AM Christian Brauner <brauner@kernel.org> wrote:
>
> From: Christian Brauner <christian.brauner@ubuntu.com>
>
> Introduce the cgroup.kill file. It does what it says on the tin and
> allows a caller to kill a cgroup by writing "1" into cgroup.kill.
> The file is available in non-root cgroups.
>
> Killing cgroups is a process directed operation, i.e. the whole
> thread-group is affected. Consequently trying to write to cgroup.kill in
> threaded cgroups will be rejected and EOPNOTSUPP returned. This behavior
> aligns with cgroup.procs where reads in threaded-cgroups are rejected
> with EOPNOTSUPP.
>
> The cgroup.kill file is write-only since killing a cgroup is an event
> not which makes it different from e.g. freezer where a cgroup
> transitions between the two states.
>
> As with all new cgroup features cgroup.kill is recursive by default.
>
> Killing a cgroup is protected against concurrent migrations through the
> cgroup mutex. To protect against forkbombs and to mitigate the effect of
> racing forks a new CGRP_KILL css set lock protected flag is introduced
> that is set prior to killing a cgroup and unset after the cgroup has
> been killed. We can then check in cgroup_post_fork() where we hold the
> css set lock already whether the cgroup is currently being killed. If so
> we send the child a SIGKILL signal immediately taking it down as soon as
> it returns to userspace. To make the killing of the child semantically
> clean it is killed after all cgroup attachment operations have been
> finalized.
>
> There are various use-cases of this interface:
> - Containers usually have a conservative layout where each container
>   usually has a delegated cgroup. For such layouts there is a 1:1
>   mapping between container and cgroup. If the container in addition
>   uses a separate pid namespace then killing a container usually becomes
>   a simple kill -9 <container-init-pid> from an ancestor pid namespace.
>   However, there are quite a few scenarios where that isn't true. For
>   example, there are containers that share the cgroup with other
>   processes on purpose that are supposed to be bound to the lifetime of
>   the container but are not in the same pidns of the container.
>   Containers that are in a delegated cgroup but share the pid namespace
>   with the host or other containers.
> - Service managers such as systemd use cgroups to group and organize
>   processes belonging to a service. They usually rely on a recursive
>   algorithm now to kill a service. With cgroup.kill this becomes a
>   simple write to cgroup.kill.
> - Userspace OOM implementations can make good use of this feature to
>   efficiently take down whole cgroups quickly.

Just to further add the motivation for userspace oom-killers. Instead
of traversing the tree, opening cgroup.procs and manually killing the
processes under memory pressure, the userspace oom-killer can just
keep the list of cgroup.kill files open and just write '1' when it
decides to trigger the oom-kill.

Michal, what do you think of putting the processes killed through this
interface into the oom_reaper_list as well? Will there be any
concerns?

> - The kill program can gain a new
>   kill --cgroup /sys/fs/cgroup/delegated
>   flag to take down cgroups.
>
> A few observations about the semantics:
> - If parent and child are in the same cgroup and CLONE_INTO_CGROUP is
>   not specified we are not taking cgroup mutex meaning the cgroup can be
>   killed while a process in that cgroup is forking.
>   If the kill request happens right before cgroup_can_fork() and before
>   the parent grabs its siglock the parent is guaranteed to see the
>   pending SIGKILL. In addition we perform another check in
>   cgroup_post_fork() whether the cgroup is being killed and is so take
>   down the child (see above). This is robust enough and protects gainst
>   forkbombs. If userspace really really wants to have stricter
>   protection the simple solution would be to grab the write side of the
>   cgroup threadgroup rwsem which will force all ongoing forks to
>   complete before killing starts. We concluded that this is not
>   necessary as the semantics for concurrent forking should simply align
>   with freezer where a similar check as cgroup_post_fork() is performed.
>
>   For all other cases CLONE_INTO_CGROUP is required. In this case we
>   will grab the cgroup mutex so the cgroup can't be killed while we
>   fork. Once we're done with the fork and have dropped cgroup mutex we
>   are visible and will be found by any subsequent kill request.
> - We obviously don't kill kthreads. This means a cgroup that has a
>   kthread will not become empty after killing and consequently no
>   unpopulated event will be generated. The assumption is that kthreads
>   should be in the root cgroup only anyway so this is not an issue.
> - We skip killing tasks that already have pending fatal signals.
> - Freezer doesn't care about tasks in different pid namespaces, i.e. if
>   you have two tasks in different pid namespaces the cgroup would still
>   be frozen. The cgroup.kill mechanism consequently behaves the same
>   way, i.e. we kill all processes and ignore in which pid namespace they
>   exist.
> - If the caller is located in a cgroup that is killed the caller will
>   obviously be killed as well.
>
> Cc: Shakeel Butt <shakeelb@google.com>
> Cc: Roman Gushchin <guro@fb.com>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: cgroups@vger.kernel.org
> Signed-off-by: Christian Brauner <christian.brauner@ubuntu.com>
[...]
