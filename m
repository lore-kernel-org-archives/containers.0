Received: from mail-yw1-f177.google.com (mail-yw1-f177.google.com [209.85.128.177])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 222A710796
	for <containers@lists.linux.dev>; Fri,  2 Jun 2023 14:50:45 +0000 (UTC)
Received: by mail-yw1-f177.google.com with SMTP id 00721157ae682-565cdb77b01so20061877b3.0
        for <containers@lists.linux.dev>; Fri, 02 Jun 2023 07:50:45 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=paul-moore.com; s=google; t=1685717445; x=1688309445;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=ivYvW+G6u6YuIsqJJ45hUG/wpL22M96qcNdUDhQyURA=;
        b=Z+SDdSc0mU9OOIKOIJ2KuGz9G7UhcLwMOjchy0pgHmbQ+oCYCSlk9d2pLULomjCzcl
         ZRigYdUJE4r6pMZDjXY7XUOmERgZb46QJve7FVd41V6Gs+lfObaFLONdKiSWc36M2bGo
         LeQE73Z5dQz7eB2tn8/4bSrhmFO9GHcK/g7Rdel9Y2tYj7a+J3agGVcV3T7UQxnPmrLY
         jQvCYDlciQfPy9YQ7OX6aG+6J+N85z2T9b2+i8151wNRzLfsGkBLfw7q72uGzhCb129S
         DV3YSC6XaacAPNq2x0MfDpklPCVqxaLlVjKYUyaiPc/pfl7KC4S3Vxxn0O4rmr8duoDs
         LvBQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20221208; t=1685717445; x=1688309445;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=ivYvW+G6u6YuIsqJJ45hUG/wpL22M96qcNdUDhQyURA=;
        b=AtOmlVm396joN+/IuLMVnPuHIb4GWMFiD79PVs+8dGXkgG9j4ZW2MKWBcQWAjkzrjj
         bJU0isVM2KrpG7UBNu9mvaq2ZgsZJR1zEduVOaAhfnyV2q+2GCef7mZ75YoX/+aqV2Zm
         bsoMhQZqaPmi+nCcTpEbYddRpDI7zjDPa/weyxyza7yWVIdqTCGppLcMKv7sYHfDt0mP
         5J6ffboUiwGK4Pm7Bf0BRkJEQhzwOevh4Pn2jnVBFsfKkf7iUalLDC+qlDGGT3JXnUbo
         y/rd3BjzzzQgb0lXeVs2LrgKdwjW1vtibOaBjKpfThCRkaZe7bD2ofSn3z/fasSYxLGp
         eA8g==
X-Gm-Message-State: AC+VfDxDbBx3vmYFzKsebYmDRhSyPHWyxD8n4ZSiQH9XK0/tK8p4yPtP
	PZhBhrsBfVO3w3F/1asKLvOyDPA6yppj0E1l52s2
X-Google-Smtp-Source: ACHHUZ4lYbZLcY6E5sPAYiv/CQasbi0XlBdzKI0j5yNqJ4GSyCIm969LlGIR2lWS1J22iwEw/DZKkBf8tEX7Pvzq9JM=
X-Received: by 2002:a0d:d854:0:b0:559:f029:992d with SMTP id
 a81-20020a0dd854000000b00559f029992dmr173275ywe.24.1685717444882; Fri, 02 Jun
 2023 07:50:44 -0700 (PDT)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <168547265011.24337.4306067683997517082-0@git.sr.ht>
 <CAHC9VhQhBBPyZE24LM6KvYrET2huW-W_YYsyPndpNkn70Mu3Ug@mail.gmail.com>
 <87fs7abu0f.fsf@email.froward.int.ebiederm.org> <CAHC9VhRk3WhXh-GTDSKFW3PujXiQCDy3xk4Xb9_Lo4szgQ5G6Q@mail.gmail.com>
 <87ilc67i95.fsf@email.froward.int.ebiederm.org>
In-Reply-To: <87ilc67i95.fsf@email.froward.int.ebiederm.org>
From: Paul Moore <paul@paul-moore.com>
Date: Fri, 2 Jun 2023 10:50:34 -0400
Message-ID: <CAHC9VhT_D9qc3Od-DTZ52q_7bySOX1FWLTXha_OJUyHK5woq5w@mail.gmail.com>
Subject: Re: [PATCH linux 0/3] [PATCH] userns: add sysctl "kernel.userns_group_range"
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: "~akihirosuda" <suda.kyoto@gmail.com>, linux-kernel@vger.kernel.org, 
	containers@lists.linux.dev, serge@hallyn.com, brauner@kernel.org, 
	akihiro.suda.cz@hco.ntt.co.jp
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, Jun 1, 2023 at 9:41=E2=80=AFPM Eric W. Biederman <ebiederm@xmission=
.com> wrote:
> Paul Moore <paul@paul-moore.com> writes:
> > On Thu, Jun 1, 2023 at 8:14=E2=80=AFPM Eric W. Biederman <ebiederm@xmis=
sion.com> wrote:
> >> Paul Moore <paul@paul-moore.com> writes:
> >> >
> >> > Given the challenges around adding access controls to userns
> >> > operations, have you considered using the LSM support that was added
> >> > upstream last year?  The relevant LSM hook can be found in commit
> >> > 7cd4c5c2101c ("security, lsm: Introduce security_create_user_ns()"),
> >>
> >> Paul how have you handled the real world regression I reported against
> >> chromium?
> >
> > I don't track chromium development.
>
> You have chosen to be the maintainer and I reported it to you.

I just dug through all of the mail I've received from you over the
past two (?) years, as well as checking the LSM archive on lore and I
don't see any bug reports from you directed at the upstream LSM or
SELinux code ... perhaps I missed something, do you have a pointer?

Also, for the sake of clarification, I do not maintain any part of
Chromium or Chrome OS.  I do maintain the upstream LSM, SELinux,
audit, and labeled networking subsystems in the Linux Kernel as well
as a couple of userspace packages.

> >> Paul are you aware that the LSM hook can not be used to achieve the
> >> objective of this patchset?
> >
> > /me shrugs
>
> [snip parts about performing a group id check]

My comments here were only discussing the possibility of performing a
group ID based access control check; I made no claims about the
desirability of such a check, and I have no interest in rehashing our
old debates.

--=20
paul-moore.com
