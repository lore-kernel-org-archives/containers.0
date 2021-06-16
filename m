Received: from mail-lf1-f44.google.com (mail-lf1-f44.google.com [209.85.167.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E344970
	for <containers@lists.linux.dev>; Wed, 16 Jun 2021 01:10:02 +0000 (UTC)
Received: by mail-lf1-f44.google.com with SMTP id x24so1270136lfr.10
        for <containers@lists.linux.dev>; Tue, 15 Jun 2021 18:10:02 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=WkZWfoezrzK3YqSvjNFpximYFS+zPFkT6j8u2nQEHxw=;
        b=dnZC354fu9ggFFPybBFkrAKpJ+prc+VjiMY0E47wXoZTl70lO0k7nYMjJU+ZV3XOnM
         cSojlxv0PEOIvvodP7EyyNVyBIDb6VpotqSOH8P7zgKeN99TPu2eM8jtTC5q9GkVMOOm
         b8n1LUck5mzKRNIURbRp1PAEmcfLJJ6Oofoato99TY3lGZHKhH5BKFQ7LpvdQaSiY3ks
         8XqJgWXCw95vBde+156oMa/0O8Vezdj3dFRqsmV65VcAY4q1g4/XaEXHKGuGGv4cDCk7
         k59WzkDTvJnW4oE/NZKDqIjt26ezzGMMFYRpxTy8HV6zFdzzlgpdJBhwNO3hKG5oBQ2q
         Zfxg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=WkZWfoezrzK3YqSvjNFpximYFS+zPFkT6j8u2nQEHxw=;
        b=aZPq2RRLDh1yLxnJc62nD92mcOTds/zxrH0E5fknOGr1DC0kRFJAdnDJBZPNuEp2+h
         3fmjPQrSj4JO5rjv8Q7nKFziFrJMGf3nyVVR6MA/Zxf3FjS0oH24qxth4a7sjV/ba2QG
         s/1tGdow85A6CdfHKSzt3Tsz+7vXhPE6iLmZjDFb4Fm82iAkpqwBKsP2gQ08bheys1gy
         8FugWQvdUNyRZwIPh1QnE7u+3aSEdi6J+8j2hPgUgpJu6bcufs9POm0WSBFJcIbnjvQN
         S0xZIiMZmzsR4xDe6MtWqugReR/182eTjQDlzE/qUgxdWUHtLatIuJEZQYWPYfA7nYCw
         4WKg==
X-Gm-Message-State: AOAM530L5a3yRezMnc4Xy154dL5bdCmG4srow9baxCB7Ue+c8AFkVjeW
	gBMornd8KrmGKh2PNvlYl8WhtP+TdH1Zv5LymCh7vg==
X-Google-Smtp-Source: ABdhPJzf4qJT4TeIuhj5pb3/BNFUHv6br3mhdn2UFHbIAcsSFEWV1evx9ybM06Xaj2HksP1lPhVlQir+fHv+GF9WmyE=
X-Received: by 2002:a19:7015:: with SMTP id h21mr1630748lfc.299.1623805800760;
 Tue, 15 Jun 2021 18:10:00 -0700 (PDT)
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <ac070cd90c0d45b7a554366f235262fa5c566435.1622716926.git.legion@kernel.org>
 <20210615113222.edzkaqfvrris4nth@wittgenstein> <20210615124715.nzd5we5tl7xc2n2p@example.org>
In-Reply-To: <20210615124715.nzd5we5tl7xc2n2p@example.org>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 15 Jun 2021 18:09:49 -0700
Message-ID: <CALvZod7po_fK9JpcUNVrN6PyyP9k=hdcyRfZmHjSVE5r_8Laqw@mail.gmail.com>
Subject: Re: [PATCH v1] proc: Implement /proc/self/meminfo
To: Alexey Gladkov <legion@kernel.org>
Cc: Christian Brauner <christian.brauner@ubuntu.com>, LKML <linux-kernel@vger.kernel.org>, 
	Linux Containers <containers@lists.linux.dev>, 
	Linux Containers <containers@lists.linux-foundation.org>, 
	Linux FS Devel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	Andrew Morton <akpm@linux-foundation.org>, "Eric W . Biederman" <ebiederm@xmission.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, 
	Chris Down <chris@chrisdown.name>, Cgroups <cgroups@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"

On Tue, Jun 15, 2021 at 5:47 AM Alexey Gladkov <legion@kernel.org> wrote:
>
[...]
>
> I made the second version of the patch [1], but then I had a conversation
> with Eric W. Biederman offlist. He convinced me that it is a bad idea to
> change all the values in meminfo to accommodate cgroups. But we agreed
> that MemAvailable in /proc/meminfo should respect cgroups limits. This
> field was created to hide implementation details when calculating
> available memory. You can see that it is quite widely used [2].
> So I want to try to move in that direction.
>
> [1] https://git.kernel.org/pub/scm/linux/kernel/git/legion/linux.git/log/?h=patchset/meminfo/v2.0
> [2] https://codesearch.debian.net/search?q=MemAvailable%3A
>

Please see following two links on the previous discussion on having
per-memcg MemAvailable stat.

[1] https://lore.kernel.org/linux-mm/alpine.DEB.2.22.394.2006281445210.855265@chino.kir.corp.google.com/
[2] https://lore.kernel.org/linux-mm/alpine.DEB.2.23.453.2007142018150.2667860@chino.kir.corp.google.com/

MemAvailable itself is an imprecise metric and involving memcg makes
this metric even more weird. The difference of semantics of swap
accounting of v1 and v2 is one source of this weirdness (I have not
checked your patch if it is handling this weirdness). The lazyfree and
deferred split pages are another source.

So, I am not sure if complicating an already imprecise metric will
make it more useful.
