Received: from mail-lj1-f178.google.com (mail-lj1-f178.google.com [209.85.208.178])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B0D6872
	for <containers@lists.linux.dev>; Wed,  5 May 2021 18:34:54 +0000 (UTC)
Received: by mail-lj1-f178.google.com with SMTP id u20so3726216lja.13
        for <containers@lists.linux.dev>; Wed, 05 May 2021 11:34:54 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=K5BbP+PQbZDrsW3Z0I2K54qvJu7T8OT3Rig60hvbO1U=;
        b=vsqKdvcVbJzePaO2Rdkii7+aVDG4GsKFVmMNGiJb3HJ/5dEyks73H4moEQib1EV6+A
         iHzoGwnjHsbOh0Fx60YpVgWrLdjLsXZozOLaCv2o9F+RvKD5gM3ENd+K7zwidkabXiQO
         ZcLZVb1qh9Q3myp39yWjYo34ivvZWA1CXzpBqsomjfPx0nAFVzPOLLTmomuP7FGIZu0y
         N+Uv01Eanyf2MW5nTNqzBKWf4wJKELwo/6qUM12Ffienqd/MdEtWZ6+/zXHCsHLOCVIv
         cqwGpNFnkJq588E3Wo9tvTByYl3d+DETyi/C3tG3NvDk8sXW0i0OrMA9Z+uPM14dhoL7
         ltPw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=K5BbP+PQbZDrsW3Z0I2K54qvJu7T8OT3Rig60hvbO1U=;
        b=B2jBhBTEv522/9VaVPnCeD1G5wpT1HsKlwGJZ+RzfMXUKrx2I80RFA9Uq+3SLKh43b
         n3ztO28viDb/Cq0gtHX1CKehUhsJItzSyJjIMbcDig5H0nKefFwawgy4QjRHiiSm2y5j
         vYN4shxZzitxTaRisdOuXgU70kTOQoQ7q7540g7YnLuMahVx8PTSrl65fItlN2mTrZFi
         Ahcy0GBTnSy0i/9XtV9/q9HhF1BUTf8h+EatSaBtg3QpJCnL/COLxfp3p7YTxJ74Q8Ph
         71whZp6Jl/mEQ2p81Ddn4H4ZFEXrLx56UGCB+F9n+XxssjtA01UX4aXXWMWIAWAEJKvf
         JUtg==
X-Gm-Message-State: AOAM531tW65j7V5BfUphNQIB7HqVaMBsN3dGUrhYjCLKisdyR8PEKZze
	1Z5KS2VCU5Toalf+m0cc9y2oynQtCglTaTdFJHRHBw==
X-Google-Smtp-Source: ABdhPJz3lGLBPV/4oLmS+bGIyVdlZtU+Arlag7ythkobyL2FIaBIb3EWl0k3+KFXHEcIuYfSFDkRXBgjSKUIYV6Y8S4=
X-Received: by 2002:a2e:8295:: with SMTP id y21mr144786ljg.279.1620239692760;
 Wed, 05 May 2021 11:34:52 -0700 (PDT)
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <20210503143922.3093755-1-brauner@kernel.org> <20210503143922.3093755-5-brauner@kernel.org>
In-Reply-To: <20210503143922.3093755-5-brauner@kernel.org>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 5 May 2021 11:34:41 -0700
Message-ID: <CALvZod58WX-YpX_eSJzDyYknZiV5GzOe1wnKL8Pk4qMkq+oBQQ@mail.gmail.com>
Subject: Re: [PATCH v2 5/5] tests/cgroup: test cgroup.kill
To: Christian Brauner <brauner@kernel.org>
Cc: Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>, Zefan Li <lizefan.x@bytedance.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, Cgroups <cgroups@vger.kernel.org>, containers@lists.linux.dev, 
	Christian Brauner <christian.brauner@ubuntu.com>
Content-Type: text/plain; charset="UTF-8"

On Mon, May 3, 2021 at 7:40 AM Christian Brauner <brauner@kernel.org> wrote:
>
[...]
> +
> +static int test_cgkill_simple(const char *root)
> +{
> +       pid_t pids[100];
> +       int ret = KSFT_FAIL;
> +       char *cgroup = NULL;
> +       int i;
> +
> +       cgroup = cg_name(root, "cg_test_simple");
> +       if (!cgroup)
> +               goto cleanup;
> +
> +       if (cg_create(cgroup))
> +               goto cleanup;
> +
> +       for (i = 0; i < 100; i++)
> +               pids[i] = cg_run_nowait(cgroup, child_fn, NULL);
> +
> +       if (cg_wait_for_proc_count(cgroup, 100))
> +               goto cleanup;
> +
> +        if (cg_write(cgroup, "cgroup.kill", "1"))
> +               goto cleanup;

I don't think the above write to cgroup.kill is correct.

> +
> +       if (cg_read_strcmp(cgroup, "cgroup.events", "populated 1\n"))
> +               goto cleanup;
> +
> +       if (cg_kill_wait(cgroup))
> +               goto cleanup;
> +
> +       if (cg_read_strcmp(cgroup, "cgroup.events", "populated 0\n"))
> +               goto cleanup;
> +
> +       ret = KSFT_PASS;
> +
> +cleanup:
> +       for (i = 0; i < 100; i++)
> +               wait_for_pid(pids[i]);
> +
> +       if (cgroup)
> +               cg_destroy(cgroup);
> +       free(cgroup);
> +       return ret;
> +}
