Received: from mail-lf1-f54.google.com (mail-lf1-f54.google.com [209.85.167.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AF17370
	for <containers@lists.linux.dev>; Mon,  3 May 2021 17:19:01 +0000 (UTC)
Received: by mail-lf1-f54.google.com with SMTP id x2so9156376lff.10
        for <containers@lists.linux.dev>; Mon, 03 May 2021 10:19:01 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=R+Vb4/GnRKT0G3TyENF1aghjj1j3gbMmpQpEJoj800U=;
        b=c27n9YevnhEL7qhFHSX8WIPq7f9Xf/Vax2kDUH6WQX6IvFhn49FPKTwKQtejaK+7AR
         /rwB2wrVwBq14wkXa5vAed5c8820GAsbdFORm5nRsJfPVnPYBL79m94hhuUEqngxvD/N
         QEgwAIZ0m088luZf/t8sJ73EiyULxbytMEgfAmmeiG5Iw9L8SufvOh3NqEqwJso/NiRh
         akCHql1Erb+4ds4A61aFo9njXjH3KKVjLZ/BNy39h2kIHRJj0Jz9uCLjQbIwXQRfXqbL
         sCVjhi12jalrivFesev4AhaDoSgrOKyoJ1z9npbBpEVNTXbpKwWIz5vnMXs/8tosAx71
         Q7JQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=R+Vb4/GnRKT0G3TyENF1aghjj1j3gbMmpQpEJoj800U=;
        b=gHr/uevcSrlSoQsDrojz7itfFgzjoBag/xWCo0mUmNumSU6YDla/9V4KTmbCnHg+7n
         MyTrJGcnJ8OLuG3MDNyZW4BHW1XdsJXMIlc3R+VqbFdwWPR5ahDgE65O0cJiVh8Bj5rr
         nRygy4J+i40a3Hr/09U9I3BIzQN8wqaoOfhxvLtvrFn4VIYH50wWM02jdygoeQZELv6B
         MlsGis0n41/hZZ/Csv1aaJovco1M5HKz5sS435gYq0+JmhMUaEQzDljErkd3hckFaycR
         7SLEDICZHFzzrEAoY3XsRE0hna83tSDf98Y+otMaMFBjuqxQQAnaL47kq0iJIyVQG6gW
         0r8g==
X-Gm-Message-State: AOAM530EyywQjGyYD2ZTg0dILtVb3YujRFi5TwTEZ5F3ehBMD9p+2NoU
	Q/1sEKMDQTrkD6IVTYQ1HQd5a/YML91YvtnmpuwJzw==
X-Google-Smtp-Source: ABdhPJwaOiCoMX5nrqV/yHZ8HsBRe/LlUNWE4Q/aEklpWcuwCMmxJU4mC4VoW8ssk7rh5EuyB/dUrnLN91P2ZX2cOWY=
X-Received: by 2002:a05:6512:92e:: with SMTP id f14mr13765420lft.347.1620062339702;
 Mon, 03 May 2021 10:18:59 -0700 (PDT)
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <20210503143922.3093755-1-brauner@kernel.org>
In-Reply-To: <20210503143922.3093755-1-brauner@kernel.org>
From: Shakeel Butt <shakeelb@google.com>
Date: Mon, 3 May 2021 10:18:49 -0700
Message-ID: <CALvZod4TsZcOL6Nng4y9H3-CqeCEqn-TRV1sWbt=T5q-57hXUQ@mail.gmail.com>
Subject: Re: [PATCH v2 1/5] cgroup: introduce cgroup.kill
To: Christian Brauner <brauner@kernel.org>
Cc: Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>, Zefan Li <lizefan.x@bytedance.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, Cgroups <cgroups@vger.kernel.org>, containers@lists.linux.dev, 
	Christian Brauner <christian.brauner@ubuntu.com>
Content-Type: text/plain; charset="UTF-8"

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

Reviewed-by: Shakeel Butt <shakeelb@google.com>
