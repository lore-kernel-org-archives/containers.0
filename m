Received: from mail-lf1-f51.google.com (mail-lf1-f51.google.com [209.85.167.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B887471
	for <containers@lists.linux.dev>; Wed,  5 May 2021 16:43:29 +0000 (UTC)
Received: by mail-lf1-f51.google.com with SMTP id c11so3469852lfi.9
        for <containers@lists.linux.dev>; Wed, 05 May 2021 09:43:29 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=9uYZs26n/wyQy1YB8Ay0KGcQh6u0u3FYwEcGuskdOQ8=;
        b=vuuG/mWR6GfoQ9g+2kdjgPJ71W6uK0U4PA6MFirzClqWduHDBDZ0DcmKif+sj7YM5z
         r4lBFW5HF9yY7cI7fqo7GTg9eSfkPfvdWAQKOu3qwoXtRxmJBMXkAqaWmZ6jM2iWeOaF
         UBUn4Xs/LTmsVAttnxgcsqc/7YRmcioCRFI44pInVVdpYYAYeS+BGlSHNWEWbfhO3URH
         FXmRWSnutnQgkHbjOTwbc9a08CpB8HJxJOP3ntRMH8d4r8MJyBeBb6g9VOwxdF6N0BAW
         8pqDgZx3Xt0QqpiUyC8VIOn82dJTB4xsNEkTKGIFEEkuPiZloQP0G/Pt3QbfVN1TbcIU
         pDXw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=9uYZs26n/wyQy1YB8Ay0KGcQh6u0u3FYwEcGuskdOQ8=;
        b=nkuo4nWY/yXVIM0WHaPwS1bCE+P5xSbMtdbnBnpdd+k0hZgmgdTZpg2MrhQXYErqlz
         ULFqX+u9esYvkLigN7sPEqcNVL1cHcnVFL/AkKtsSJtXiAgkIYH1x+wjUdeb01y7wr0g
         VRnYCYnZNol61u11+t6F/HBzl1skfAUaCbXLJbiVFhsh34jQ96Z74fldZG2xemUWdE8Q
         4QhGNVcioyi0MAFQXpKFYfC3t0bSLaSpUTXquOH2g+aGBEpQ8Uykyl5++gH12PzASJ0s
         thjKflKetIirvQaWyvn3bHEdrREyC586k6YMtEUdZrY2ZsvpNihbkZzFpkJVWKqnzBH8
         ob7w==
X-Gm-Message-State: AOAM533tDV5f4wSphRqFtTzqi5TOb3UzSJwHEsjWRPjvELikpLoUPHAA
	0GW3A009dCoz7lKr9PxtK5Gty7aSYfdXz4A067bsHQ==
X-Google-Smtp-Source: ABdhPJyllJorNZ6luwFuNScOGvpLenqTKW4ZqA6Xuosi/pPgew0JijomWSScNaZ1MK23p0OHI+11hwkVt9qNss0Pjl4=
X-Received: by 2002:a05:6512:1182:: with SMTP id g2mr11732217lfr.117.1620233007859;
 Wed, 05 May 2021 09:43:27 -0700 (PDT)
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <20210503143922.3093755-1-brauner@kernel.org> <20210503143922.3093755-4-brauner@kernel.org>
In-Reply-To: <20210503143922.3093755-4-brauner@kernel.org>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 5 May 2021 09:43:17 -0700
Message-ID: <CALvZod51giGe2_MsHHp=7czY0rKdXBRMi-Ug-oc5avgFwhFaVQ@mail.gmail.com>
Subject: Re: [PATCH v2 4/5] tests/cgroup: move cg_wait_for(), cg_prepare_for_wait()
To: Christian Brauner <brauner@kernel.org>
Cc: Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>, Zefan Li <lizefan.x@bytedance.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, Cgroups <cgroups@vger.kernel.org>, containers@lists.linux.dev, 
	Christian Brauner <christian.brauner@ubuntu.com>
Content-Type: text/plain; charset="UTF-8"

On Mon, May 3, 2021 at 7:40 AM Christian Brauner <brauner@kernel.org> wrote:
>
> From: Christian Brauner <christian.brauner@ubuntu.com>
>
> as they will be used by the tests for cgroup killing.
>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: cgroups@vger.kernel.org
> Acked-by: Roman Gushchin <guro@fb.com>
> Signed-off-by: Christian Brauner <christian.brauner@ubuntu.com>

Reviewed-by: Shakeel Butt <shakeelb@google.com>
