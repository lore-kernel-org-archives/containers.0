Received: from mail-lf1-f45.google.com (mail-lf1-f45.google.com [209.85.167.45])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F146670
	for <containers@lists.linux.dev>; Wed,  5 May 2021 16:29:54 +0000 (UTC)
Received: by mail-lf1-f45.google.com with SMTP id t11so3393844lfl.11
        for <containers@lists.linux.dev>; Wed, 05 May 2021 09:29:54 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=sfw/1w27jQ+1kd1/o/ZKaoNFZdw2wrWkGNYntufubLI=;
        b=p2YSe1DV6VXC/+ln1rLPRfAlfTm62ZNdRtOCU0nslBEclFn5Fp/bYbHR/nXYzbreux
         mv/IKUSDCqW7kj8vpqfqNBnpkrv9R4J5YCwH8ZXd6/y18H6i9aByJpnFYGeqKGYaEsQn
         SRkvZgT0AKMy6fH8YDFi9j6ILxrgb8r1DYabgBm+Bl59frUOIGeHb5Hh/2uXfMknazDY
         bmofNuYL58HukPXDiTfHiRXcN5byb632bh3fmfcHwEAbimoddGeo5oF5yXnkOe0IoTEW
         IYZviC7CHHZP9VeRDm0QLIYQsVut+8uxSeslIel/nP6p9rH6w722p7iD+UVV608St+2O
         KbSQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=sfw/1w27jQ+1kd1/o/ZKaoNFZdw2wrWkGNYntufubLI=;
        b=WnuZGI7CYB3fAhgvUqum7SpaOOB8q2OeTOyP4gqUr8ZLAlm08v+nONvFYL1blJPADE
         Gb3MDZ3ywAo2Jed/SEaEtA3RA68+CSo5G0cap6Qs2XsmZnjZnmaOYQyjmxh6hdMjxEaC
         ESys7GYgT896IMGRoBUxZzuC7goWH+D3cCzF75uKZmsd2hkkna3/jjXqHimhsXXlL7Bb
         yWuLDTukVgNoBbeLq+WaTBDKX87gWFjN2bAkzmhBLwOwgDTaoovfudcefp26iycVILvm
         zb1ryi2yvWdJgDuA6pOQZS93P9yUQdZcCJ/sSi4sfkBf+f2A0qkfzAoWP2c1EgCSy6X8
         qbCA==
X-Gm-Message-State: AOAM5325Vob0MBGjEuXShiy/IVXhnUmULwWrjlhRRKdtFnjyVBHmUQG0
	T8k0iLILzP/BAREniNleNDXKXAaHsxITBgVa6VhlSQ==
X-Google-Smtp-Source: ABdhPJxm4uLWiJAhYHP6r7fuGi6V+P2PdeM4hrI06DMAhVPoEoY1KSYXN3hhZSC0lao2L0mHxrdaFdPfcmM7XyXEpIQ=
X-Received: by 2002:ac2:5b1b:: with SMTP id v27mr7384269lfn.549.1620232192955;
 Wed, 05 May 2021 09:29:52 -0700 (PDT)
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <20210503143922.3093755-1-brauner@kernel.org> <20210503143922.3093755-2-brauner@kernel.org>
In-Reply-To: <20210503143922.3093755-2-brauner@kernel.org>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 5 May 2021 09:29:42 -0700
Message-ID: <CALvZod5H4Gsm+KFyd5NtCvZL8xYfYDU2qDsvDr+-xnqoNgog=A@mail.gmail.com>
Subject: Re: [PATCH v2 2/5] docs/cgroup: add entry for cgroup.kill
To: Christian Brauner <brauner@kernel.org>
Cc: Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>, Zefan Li <lizefan.x@bytedance.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, Cgroups <cgroups@vger.kernel.org>, containers@lists.linux.dev, 
	Christian Brauner <christian.brauner@ubuntu.com>
Content-Type: text/plain; charset="UTF-8"

On Mon, May 3, 2021 at 7:40 AM Christian Brauner <brauner@kernel.org> wrote:
>
> From: Christian Brauner <christian.brauner@ubuntu.com>
>
> Give a brief overview of the cgroup.kill functionality.
>
> Cc: Roman Gushchin <guro@fb.com>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: cgroups@vger.kernel.org
> Signed-off-by: Christian Brauner <christian.brauner@ubuntu.com>

Reviewed-by: Shakeel Butt <shakeelb@google.com>
