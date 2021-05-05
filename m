Received: from mail-lf1-f48.google.com (mail-lf1-f48.google.com [209.85.167.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 02F4F71
	for <containers@lists.linux.dev>; Wed,  5 May 2021 16:42:21 +0000 (UTC)
Received: by mail-lf1-f48.google.com with SMTP id x19so3512156lfa.2
        for <containers@lists.linux.dev>; Wed, 05 May 2021 09:42:21 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=CZSxOum7tgcfufyRQ0ud4aq7JR1hA71f4tT5tJF5bAk=;
        b=Y2ETgANl3oMRKwl6lTT7wNph2JFAn/CkXrVJyf9nplhyQV+ERSGAfGrbICtcc3Pk79
         p2lfZZY816/lXdrvktWAGAerrc2sqMixaIzcCbHqZlhG2vnfMHN3hxvQaQxYdrwN1Koh
         Bw3HP2t+fmXF+uwtKQBJbzcf7Ptu6pFNTKjXuglYMC6Z/Eay9e/08lohNc8Z2CqoMzJw
         zcfBlcg828zoW052cHxSeu4wfWtk+WqxjJJ3d723hYhGLmSiQR0+rk207FC34o3W512D
         ToH8DVmgr3e/xYORr361TMepy4sigreWXlGhxRR58UffKENoodP/rjeBmd7L4spy/DC3
         Mr/g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=CZSxOum7tgcfufyRQ0ud4aq7JR1hA71f4tT5tJF5bAk=;
        b=pZnuAEpHMVUXjCMIAipgkgvuY0TgWtZjKc4/GStFzI4oy2ZrEvT9aSa0DN4Hs7OIUj
         roZvfHXWr/119jAkMf6g2THHQJIbtjPTBfNRfoh7dXdq2XY2SJvz9BlLi7MPIMUhDV71
         RrD5WpOjO9HSVS0KNFJCerWHpNSYn4JBOp5l8hFpm0e2OtdxV6eq59b2mPg7JRVNSRiy
         vOJO+SVPCVOKN2IYNwJEPeGIrv5w60wfkXBkhzR8p4kBWKzXvgltQAjasMRSycb2Q5jk
         /OJ/KfPAz1vxgNG+7HsUpW0exG73UG6KyglujsfjR7rZLmGvewXaZluwLE8Q/AB0yUtL
         3AbQ==
X-Gm-Message-State: AOAM530V5pAV4NLcUDJRDiw6FT+HGlPuZUBsPAt/JLsduqzs+PpR5HF7
	BLuMXtH+kFUHOZSc469Ats7YjWNPIZsKPnerhNLZ1g==
X-Google-Smtp-Source: ABdhPJxbzHN0Rtp018rkdGVcvDz8gBPLtH2b/ifzGoeUYRWEhbAmbH0ymXkaFDceBvhiyhHwZ/BluJrulOoyqWmLlCI=
X-Received: by 2002:a05:6512:2344:: with SMTP id p4mr6061761lfu.299.1620232939951;
 Wed, 05 May 2021 09:42:19 -0700 (PDT)
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <20210503143922.3093755-1-brauner@kernel.org> <20210503143922.3093755-3-brauner@kernel.org>
In-Reply-To: <20210503143922.3093755-3-brauner@kernel.org>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 5 May 2021 09:42:08 -0700
Message-ID: <CALvZod6nTDc4Jx4UG3HKaugA1F_2N-rG+xqACAKVkKJjqxWOXg@mail.gmail.com>
Subject: Re: [PATCH v2 3/5] tests/cgroup: use cgroup.kill in cg_killall()
To: Christian Brauner <brauner@kernel.org>
Cc: Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>, Zefan Li <lizefan.x@bytedance.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, Cgroups <cgroups@vger.kernel.org>, containers@lists.linux.dev, 
	Christian Brauner <christian.brauner@ubuntu.com>
Content-Type: text/plain; charset="UTF-8"

On Mon, May 3, 2021 at 7:40 AM Christian Brauner <brauner@kernel.org> wrote:
>
> From: Christian Brauner <christian.brauner@ubuntu.com>
>
> If cgroup.kill file is supported make use of it.
>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: cgroups@vger.kernel.org
> Acked-by: Roman Gushchin <guro@fb.com>
> Signed-off-by: Christian Brauner <christian.brauner@ubuntu.com>

Reviewed-by: Shakeel Butt <shakeelb@google.com>

> ---
> /* v2 */
> - Roman Gushchin <guro@fb.com>:
>   - Fix whitespace.
> ---
>  tools/testing/selftests/cgroup/cgroup_util.c | 4 ++++
>  1 file changed, 4 insertions(+)
>
> diff --git a/tools/testing/selftests/cgroup/cgroup_util.c b/tools/testing/selftests/cgroup/cgroup_util.c
> index 027014662fb2..f60f7d764690 100644
> --- a/tools/testing/selftests/cgroup/cgroup_util.c
> +++ b/tools/testing/selftests/cgroup/cgroup_util.c
> @@ -252,6 +252,10 @@ int cg_killall(const char *cgroup)
>         char buf[PAGE_SIZE];
>         char *ptr = buf;
>
> +       /* If cgroup.kill exists use it. */
> +       if (!cg_write(cgroup, "cgroup.kill", "1"))
> +               return 0;

Now cg_killall will kill all the processes in the tree rooted at
cgroup which I think is fine.

> +
>         if (cg_read(cgroup, "cgroup.procs", buf, sizeof(buf)))
>                 return -1;
>
> --
> 2.27.0
>
