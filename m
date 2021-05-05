Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0E41872
	for <containers@lists.linux.dev>; Wed,  5 May 2021 18:52:31 +0000 (UTC)
Received: by mail.kernel.org (Postfix) with ESMTPSA id 5FDCA610C8;
	Wed,  5 May 2021 18:52:28 +0000 (UTC)
Date: Wed, 5 May 2021 20:52:24 +0200
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Shakeel Butt <shakeelb@google.com>
Cc: Christian Brauner <brauner@kernel.org>, Tejun Heo <tj@kernel.org>,
	Roman Gushchin <guro@fb.com>, Zefan Li <lizefan.x@bytedance.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Cgroups <cgroups@vger.kernel.org>, containers@lists.linux.dev
Subject: Re: [PATCH v2 5/5] tests/cgroup: test cgroup.kill
Message-ID: <20210505185224.zjfunx5wetgp6a2f@wittgenstein>
References: <20210503143922.3093755-1-brauner@kernel.org>
 <20210503143922.3093755-5-brauner@kernel.org>
 <CALvZod58WX-YpX_eSJzDyYknZiV5GzOe1wnKL8Pk4qMkq+oBQQ@mail.gmail.com>
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CALvZod58WX-YpX_eSJzDyYknZiV5GzOe1wnKL8Pk4qMkq+oBQQ@mail.gmail.com>

On Wed, May 05, 2021 at 11:34:41AM -0700, Shakeel Butt wrote:
> On Mon, May 3, 2021 at 7:40 AM Christian Brauner <brauner@kernel.org> wrote:
> >
> [...]
> > +
> > +static int test_cgkill_simple(const char *root)
> > +{
> > +       pid_t pids[100];
> > +       int ret = KSFT_FAIL;
> > +       char *cgroup = NULL;
> > +       int i;
> > +
> > +       cgroup = cg_name(root, "cg_test_simple");
> > +       if (!cgroup)
> > +               goto cleanup;
> > +
> > +       if (cg_create(cgroup))
> > +               goto cleanup;
> > +
> > +       for (i = 0; i < 100; i++)
> > +               pids[i] = cg_run_nowait(cgroup, child_fn, NULL);
> > +
> > +       if (cg_wait_for_proc_count(cgroup, 100))
> > +               goto cleanup;
> > +
> > +        if (cg_write(cgroup, "cgroup.kill", "1"))
> > +               goto cleanup;
> 
> I don't think the above write to cgroup.kill is correct.

Hm, that's a left-over from the port of the similar freezer test. Thanks
for spotting this. It never failed because of the number of procs being
created and then killed most likely.

Thanks, will remove.
Christian
