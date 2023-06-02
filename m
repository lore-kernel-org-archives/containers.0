Received: from mail-oa1-f51.google.com (mail-oa1-f51.google.com [209.85.160.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A95CA10E3
	for <containers@lists.linux.dev>; Fri,  2 Jun 2023 01:02:07 +0000 (UTC)
Received: by mail-oa1-f51.google.com with SMTP id 586e51a60fabf-1a28de15c8aso715353fac.2
        for <containers@lists.linux.dev>; Thu, 01 Jun 2023 18:02:07 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=paul-moore.com; s=google; t=1685667726; x=1688259726;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=9o3/2D9pqXQu0Kja08e1hU2rc3ztUxCY4Eps47VldFo=;
        b=KNkEPCsbkJxvJYdvTrUPo8kiFxyN3E0oTIVRNgXzBZ+/0ECQSM+jKwqtWrysFcjw6a
         DZyYom+T006pCCnXmWAqmmb2A5pJTinU18kAUM5QVhz+0QwucHpSGiqUt7p4K5CTp65m
         4/0oyu60fV247yyWntwJKLXfavATpkxPNIOeA9vbm7Wxr6sVcttB9XTUAb9aZebN9FK3
         Y8G09YaYrtHFLmhTVtOijFcYZkKUNBmR+hco1cQ/uP9eEQDxdmofwDaCkTgocKzFRW5Y
         ux4AIt4qlQGTwUnnRMG+GYwJ5Ssnwib6KYmA6fZphSCC2wT60LGkHKkIaq7Fn143dD5r
         X8qg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20221208; t=1685667726; x=1688259726;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=9o3/2D9pqXQu0Kja08e1hU2rc3ztUxCY4Eps47VldFo=;
        b=PRWHw30tHB70BhopeIrjR9l6nZUuyX4o66J3mGFc+7XNqMdqTZRNS9uRhaE7hjhVIk
         gMX0TsHesGlb6ZbFwIf2Jg8KZ9685bs7inzRnMI9Ln/Fn4ly/ZtGQHNixrIXlwqK2fV8
         dth0aqjqFHltwKwRQj2yLaPjPp9BS4K92Nf8eZ+Nw20SpLryzkTi1J01FcKGB5P/0l3I
         i15SfzrK1gp3DgLxQTl3BuUH71dsPeKNbv+02jxpBjVr56TeCYrFYgmR6l7nPz4P5GR6
         xBpcZcAs0NyEGHeyC5Zoa6Ie/QXCyikZifnOyJNkdUPpu3yqwvN5vn/ig8sZkQfDiUji
         soHw==
X-Gm-Message-State: AC+VfDwSWo9dHmmB3Hohxh4U7MezWNMNxg1CsBWtHn2rUAN6flQ5C7ip
	NMUnSywQuLbQq656pcJIa+V/18h4T0KNP2BsBuiz
X-Google-Smtp-Source: ACHHUZ6BFLtcpI/8pyU4ctzfJ+V7wPvO8tH2XND3faYj8YEVhBvhnKC7TofGwk7sr16sLm3J/vAdhLUnJrx8pfgPRGI=
X-Received: by 2002:a05:6870:3491:b0:19f:6711:8dfc with SMTP id
 n17-20020a056870349100b0019f67118dfcmr629339oah.31.1685667726423; Thu, 01 Jun
 2023 18:02:06 -0700 (PDT)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <168547265011.24337.4306067683997517082-0@git.sr.ht>
 <CAHC9VhQhBBPyZE24LM6KvYrET2huW-W_YYsyPndpNkn70Mu3Ug@mail.gmail.com> <87fs7abu0f.fsf@email.froward.int.ebiederm.org>
In-Reply-To: <87fs7abu0f.fsf@email.froward.int.ebiederm.org>
From: Paul Moore <paul@paul-moore.com>
Date: Thu, 1 Jun 2023 21:01:55 -0400
Message-ID: <CAHC9VhRk3WhXh-GTDSKFW3PujXiQCDy3xk4Xb9_Lo4szgQ5G6Q@mail.gmail.com>
Subject: Re: [PATCH linux 0/3] [PATCH] userns: add sysctl "kernel.userns_group_range"
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: "~akihirosuda" <suda.kyoto@gmail.com>, linux-kernel@vger.kernel.org, 
	containers@lists.linux.dev, serge@hallyn.com, brauner@kernel.org, 
	akihiro.suda.cz@hco.ntt.co.jp
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, Jun 1, 2023 at 8:14=E2=80=AFPM Eric W. Biederman <ebiederm@xmission=
.com> wrote:
> Paul Moore <paul@paul-moore.com> writes:
> > On Tue, May 30, 2023 at 2:50=E2=80=AFPM ~akihirosuda <akihirosuda@git.s=
r.ht> wrote:
> >>
> >> This sysctl limits groups who can create a new userns without
> >> CAP_SYS_ADMIN in the current userns, so as to mitigate potential kerne=
l
> >> vulnerabilities around userns.
> >>
> >> The sysctl value format is same as "net.ipv4.ping_group_range".
> >>
> >> To disable creating new unprivileged userns, set the sysctl value to "=
1
> >> 0" in the initial userns.
> >>
> >> To allow everyone to create new userns, set the sysctl value to "0
> >> 4294967294". This is the default value.
> >>
> >> This sysctl replaces "kernel.unprivileged_userns_clone" that is found =
in
> >> Ubuntu [1] and Debian GNU/Linux.
> >>
> >> Link: https://git.launchpad.net/~ubuntu-
> >> kernel/ubuntu/+source/linux/+git/jammy/commit?id=3D3422764 [1]
> >
> > Given the challenges around adding access controls to userns
> > operations, have you considered using the LSM support that was added
> > upstream last year?  The relevant LSM hook can be found in commit
> > 7cd4c5c2101c ("security, lsm: Introduce security_create_user_ns()"),
>
> Paul how have you handled the real world regression I reported against
> chromium?

I don't track chromium development.

> Paul are you aware that the LSM hook can not be used to achieve the
> objective of this patchset?

/me shrugs

I thought one could look into a cred struct using a BPF LSM, which
would allow one to make access control decisions based on group ID,
but I will be the first to admit I'm not a BPF LSM expert.
Regardless, one could introduce a group ID check into a LSM if they
were so inclined.

I also find it slightly amusing that you are arguing against my reply
that was discussing *not* adding another userns control point; of all
people I thought you would be supportive of this ... /me shrugs again.

> > and although only SELinux currently provides an access control
> > implementation, there is no reason you couldn't add support for your
> > favorite LSM, or even just a simple BPF LSM to enforce the group
> > controls as you've described them here.
>
> Is there a publicly available SELinux policy that uses that LSM hook?

I have no idea, I don't track all of the publicly available SELinux
policies because frankly it doesn't matter; the SELinux feature
exists, and it is my role to support and maintain it.  There are
LSM/SELinux features which are not widely exercised in general purpose
SELinux policies for various reasons, but *are* used in specialized
environments that are not often discussed on public mailing lists.

--=20
paul-moore.com
