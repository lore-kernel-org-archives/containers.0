Received: from mail-lj1-f172.google.com (mail-lj1-f172.google.com [209.85.208.172])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E458E71
	for <containers@lists.linux.dev>; Mon, 10 May 2021 22:03:03 +0000 (UTC)
Received: by mail-lj1-f172.google.com with SMTP id q186so3041194ljq.8
        for <containers@lists.linux.dev>; Mon, 10 May 2021 15:03:03 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=xEEZ8t7f0Q20wXtDGcovj3/jFYFaAmR7f82EcXq4W5E=;
        b=Hf/Y6EU13veGHo0Ee/3Us0ThFP69fYhIWpWPeEAEnFGaowsbpvX0f3mNwLvfKkh5Cd
         GyWiWrN6TuNOaqFOq+H8VApUy0CL3ov965gx81tmgJ1z/21CSMMHodjtmOrHfV5o5JkU
         jjgez6QzICn/DZqYB8VEg16OonQiMpXhqDNebyVd4weEOVG78LhqJNPVpoCD7XBYa+uA
         Jpj2GT7mcB5er8odCcjADqa/835doJ3jp2st3CCnPnoayDiuWi9WOoPBCy34PVIaSsGm
         5P0eyqCAcykTddALOI2aBXjXNB+FNrjk36Hqt2pZKoPvHVAozX6CDSXrrD8nHFMy3p7N
         hCLQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=xEEZ8t7f0Q20wXtDGcovj3/jFYFaAmR7f82EcXq4W5E=;
        b=hxC7guHijSDiV+9Sy8cGT+9HAybPLnTzgsNSWmOpdseGVJ6UGdoatq9u15nk1E2FsU
         sTWIjxDw15lyaMPen6VGROnZh6bE7B7PTQlZQqJ1bPqz0pPMKfhDO+W707iRxEec11DK
         XdgCtJKFVm/R7Ug8FlkpAg9OCmy0dzbw3+qTbRNrb4a52IhnxmecaWP0ujCyI/SEupte
         zNsXpmx9AD6f/oXr1D6Z8qpdruszeLaRenLN94amehrr7rwQrkzeSwntZySkkQhnE9ww
         TvFQgZTVf5Gq8oHjYckxUjFWySMiA/YeoIEYo+3pF64hKsuDrYRiYzESEvCW0/K8uDA6
         s6PA==
X-Gm-Message-State: AOAM531A2UU5CPkvAx0yr+YfVP4Q9mhd4LYCL2Ayf6f4yDBLWdRKjghI
	8rSpHBWGio+Hj/daZQAQM/VLXZG24wujlAgz7G0MnA==
X-Google-Smtp-Source: ABdhPJx+u9RuRo22VMZhaiasP1ubQyf0AjHX0Q/UuWEF7ZR+H9hQnDZNMOf/z3bR++hDwZPaaIkEX8R3q5b6IoYH5j8=
X-Received: by 2002:a05:651c:210f:: with SMTP id a15mr21026933ljq.160.1620684181812;
 Mon, 10 May 2021 15:03:01 -0700 (PDT)
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <20210508121542.1269256-1-brauner@kernel.org> <20210508121542.1269256-5-brauner@kernel.org>
In-Reply-To: <20210508121542.1269256-5-brauner@kernel.org>
From: Shakeel Butt <shakeelb@google.com>
Date: Mon, 10 May 2021 15:02:51 -0700
Message-ID: <CALvZod4mOdiPzHzCi3LKoNheKY7j4rDfYipeuXQa7tCUpDi1cQ@mail.gmail.com>
Subject: Re: [PATCH v3 5/5] tests/cgroup: test cgroup.kill
To: Christian Brauner <brauner@kernel.org>
Cc: Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>, Zefan Li <lizefan.x@bytedance.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, Cgroups <cgroups@vger.kernel.org>, containers@lists.linux.dev, 
	Christian Brauner <christian.brauner@ubuntu.com>
Content-Type: text/plain; charset="UTF-8"

On Sat, May 8, 2021 at 5:16 AM Christian Brauner <brauner@kernel.org> wrote:
>
> From: Christian Brauner <christian.brauner@ubuntu.com>
>
> Test that the new cgroup.kill feature works as intended.
>
> Link: https://lore.kernel.org/r/20210503143922.3093755-5-brauner@kernel.org
> Cc: Shakeel Butt <shakeelb@google.com>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: cgroups@vger.kernel.org
> Acked-by: Roman Gushchin <guro@fb.com>
> Signed-off-by: Christian Brauner <christian.brauner@ubuntu.com>

Reviewed-by: Shakeel Butt <shakeelb@google.com>
