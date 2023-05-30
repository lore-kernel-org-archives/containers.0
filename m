Received: from mail-yb1-f179.google.com (mail-yb1-f179.google.com [209.85.219.179])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0AD56200BC
	for <containers@lists.linux.dev>; Tue, 30 May 2023 21:58:59 +0000 (UTC)
Received: by mail-yb1-f179.google.com with SMTP id 3f1490d57ef6-bad010e1e50so7481082276.1
        for <containers@lists.linux.dev>; Tue, 30 May 2023 14:58:59 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=paul-moore.com; s=google; t=1685483939; x=1688075939;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=LQoGchsSYLFgDGtKxP1mVS/CZXkXh4qFE/pv/LNSQuo=;
        b=I58pVp5UoG7JekWqlQgu9H7gbDWzorvSFEIR88RHP+5qm8Deb3oL1y8Fl5ODG9agIt
         OMr8/kUENChrpol77H+hXxUqN4cIGnbSfIV5aXmVfEnmKNvLfJI8xD8ld334JjUUg8Ni
         CxJF/6DIA+yE3SRqroGNwNjPhetCB+AmLq9KjrOZEjBzQ0W8zpKV/hnn6TBSYBBtdqzv
         SHJmdjMJznZZp4Pgs2UHQpFK/alP+KIbF44u0EFdK8U32srHi1MzZml8K6IMCFzrgGrU
         ehzSXLkk7KX8xkbnWOkKEhUrOiRuluFsglwCXrFm8xTUeIYtLgc2YprnJU24apRzQn/5
         /FJQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20221208; t=1685483939; x=1688075939;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=LQoGchsSYLFgDGtKxP1mVS/CZXkXh4qFE/pv/LNSQuo=;
        b=bx0ruOZTSfVJAw3q3KXY0agCt6dmqBui+mfD4fEMx/nppssCovZhyzwNn1oWbDl3w3
         jPaW1idFtOHpTaqcDcwShsVWwultsmMepD3nJ3KsZXOm0q5H98OevdkeZde17CP2r9RP
         10Hs1STjTgDll3EGTLTRLT5gPN7m+Cy14XIDUm8/Y4uupTXsziiE1wFkl3FOA4ahwviy
         cuXgqZUgsHyf3WXlilFnnDBml/InHQeZZtsaZmgmGHzKwavwpNTRU8a3jIUg2h6S1Mig
         5Uo77WhlZzOeHU+qyUGdUG9wl07BEjtmex3GaAGQO/A+Dk5C+CmNHw52enVc5+54oKty
         2bzw==
X-Gm-Message-State: AC+VfDzeR/FcsWJ6DNaUcH6RUthslEhd8z/0aGklBvukicF75KsYjeCQ
	1VQIxdMZUJ9pzdH0ghxZDHFtHSj0nzL4nYERDZjc
X-Google-Smtp-Source: ACHHUZ5Rr4U8IiQqr1FQQUIU42pfTWPDmHu8puY69Kll0+NCN2xgzBGgAkp4/xkEiMk3hsrQPlRJxUHkAyap/0f9ZB8=
X-Received: by 2002:a0d:db92:0:b0:559:e180:2197 with SMTP id
 d140-20020a0ddb92000000b00559e1802197mr4160911ywe.21.1685483938843; Tue, 30
 May 2023 14:58:58 -0700 (PDT)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <168547265011.24337.4306067683997517082-0@git.sr.ht>
In-Reply-To: <168547265011.24337.4306067683997517082-0@git.sr.ht>
From: Paul Moore <paul@paul-moore.com>
Date: Tue, 30 May 2023 17:58:48 -0400
Message-ID: <CAHC9VhQhBBPyZE24LM6KvYrET2huW-W_YYsyPndpNkn70Mu3Ug@mail.gmail.com>
Subject: Re: [PATCH linux 0/3] [PATCH] userns: add sysctl "kernel.userns_group_range"
To: "~akihirosuda" <suda.kyoto@gmail.com>
Cc: linux-kernel@vger.kernel.org, containers@lists.linux.dev, serge@hallyn.com, 
	brauner@kernel.org, ebiederm@xmission.com, akihiro.suda.cz@hco.ntt.co.jp
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, May 30, 2023 at 2:50=E2=80=AFPM ~akihirosuda <akihirosuda@git.sr.ht=
> wrote:
>
> This sysctl limits groups who can create a new userns without
> CAP_SYS_ADMIN in the current userns, so as to mitigate potential kernel
> vulnerabilities around userns.
>
> The sysctl value format is same as "net.ipv4.ping_group_range".
>
> To disable creating new unprivileged userns, set the sysctl value to "1
> 0" in the initial userns.
>
> To allow everyone to create new userns, set the sysctl value to "0
> 4294967294". This is the default value.
>
> This sysctl replaces "kernel.unprivileged_userns_clone" that is found in
> Ubuntu [1] and Debian GNU/Linux.
>
> Link: https://git.launchpad.net/~ubuntu-
> kernel/ubuntu/+source/linux/+git/jammy/commit?id=3D3422764 [1]

Given the challenges around adding access controls to userns
operations, have you considered using the LSM support that was added
upstream last year?  The relevant LSM hook can be found in commit
7cd4c5c2101c ("security, lsm: Introduce security_create_user_ns()"),
and although only SELinux currently provides an access control
implementation, there is no reason you couldn't add support for your
favorite LSM, or even just a simple BPF LSM to enforce the group
controls as you've described them here.

> Akihiro Suda (3):
>   net/ipv4: split group_range logic to kernel/group_range.c
>   group_range: allow GID from 2147483648 to 4294967294
>   userns: add sysctl "kernel.userns_group_range"
>
>  include/linux/group_range.h    |  18 +++++
>  include/linux/user_namespace.h |   5 ++
>  include/net/netns/ipv4.h       |   9 +--
>  include/net/ping.h             |   6 --
>  kernel/Makefile                |   2 +-
>  kernel/fork.c                  |  24 +++++++
>  kernel/group_range.c           | 123 +++++++++++++++++++++++++++++++++
>  kernel/sysctl.c                |  30 ++++++++
>  kernel/user.c                  |   9 +++
>  net/ipv4/ping.c                |  39 +----------
>  net/ipv4/sysctl_net_ipv4.c     |  56 ++-------------
>  11 files changed, 219 insertions(+), 102 deletions(-)
>  create mode 100644 include/linux/group_range.h
>  create mode 100644 kernel/group_range.c

--=20
paul-moore.com
