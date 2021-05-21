Received: from mail-il1-f169.google.com (mail-il1-f169.google.com [209.85.166.169])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 95A7670
	for <containers@lists.linux.dev>; Fri, 21 May 2021 16:24:30 +0000 (UTC)
Received: by mail-il1-f169.google.com with SMTP id o9so18722548ilh.6
        for <containers@lists.linux.dev>; Fri, 21 May 2021 09:24:30 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=sargun.me; s=google;
        h=mime-version:from:date:message-id:subject:to:cc;
        bh=s3TiO4SClJyDInCdOXMYVyRwBESE/9XdyYKBr/TBRzw=;
        b=xD9f/jwqLhWfHwiZxlTKH7cwVlWbuFa6PW7DSiogWZJeTgg3Wfvdvd++MQb0g3Ln74
         iQE98/GHLAw6wtdrzSFU8NpCdI3hoUT32o6aX2X7lDvo+p9S2OH1wZ5wsI0lktjNwemA
         op6jiStYDsM1u0XK68/0NHuL1WFB1Q5fCetT0=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:from:date:message-id:subject:to:cc;
        bh=s3TiO4SClJyDInCdOXMYVyRwBESE/9XdyYKBr/TBRzw=;
        b=OHruqh42Y/LJYsk9ZQUr848YAlsl3+2zyjpkx+GoCIbyYriruak6QkYr1zvulJr/1I
         tRomY5uMngRJqXiNhHBX8tZ1X4ndFnY5xdAJ9dnRdPRRe3liZ2rmbRbUETP1BMt1To5+
         ketDuRl6wdGqia1jHnkaZ6ewpv8n+Rd/LYlZYTDOyp6y/srd9RnUGlqCQbLFF9rxDXUb
         THVm6SiAwMwgDsBmn8Kf2OyZqo/GYPN3pIuLcdRC9hIxn9YSRjK3BDyWRrrSe9NTuGmE
         iaErIoa31duNCEi+qdQpAQnpOSN7GjHE4UnHgnDSw8llCLUU/Dwjm3GG4eRcRyVZvkHx
         fYHw==
X-Gm-Message-State: AOAM533WuciptkjQTKvK/ZuifB9E2pML1cvqolVnRBYdWPU75Sj5ow3k
	zDsb4GD4vTv7tq+Dd7M2l19mxln5gFSDdh+5YArrlBmiqbNZxQ==
X-Google-Smtp-Source: ABdhPJwYWl9iDZt5RNQ+BQ3SUq1rsxOI4G0oVZhviIvZbj3YffXMXuSOg3ayJSV5/q+aLFyD5F2e1uzHjvQnzhtXnTk=
X-Received: by 2002:a92:c56a:: with SMTP id b10mr11327888ilj.17.1621614268707;
 Fri, 21 May 2021 09:24:28 -0700 (PDT)
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
From: Sargun Dhillon <sargun@sargun.me>
Date: Fri, 21 May 2021 09:23:52 -0700
Message-ID: <CAMp4zn93WRF5u=et=detunN7exhQNoFctr-7Qb8-a9=As8vaQw@mail.gmail.com>
Subject: Preemption Signal Management
To: Linux Containers <containers@lists.linux.dev>, LKML <linux-kernel@vger.kernel.org>
Cc: Kees Cook <keescook@chromium.org>, Christian Brauner <christian.brauner@ubuntu.com>, 
	Andy Lutomirski <luto@kernel.org>, Tycho Andersen <tycho@tycho.pizza>, 
	Giuseppe Scrivano <gscrivan@redhat.com>, Rodrigo Campos <rodrigo@kinvolk.io>, 
	=?UTF-8?Q?Mauricio_V=C3=A1squez_Bernal?= <mauricio@kinvolk.io>
Content-Type: text/plain; charset="UTF-8"

Andy pointed out that we need a mechanism to determine whether or
notifications are preempted. He suggested we use EPOLLPRI to indicate
whether or not notifications are preempted. My outstanding question is
whether or not we need to be able to get insight of what caused the
preemption, and to which notification.

In the past, Christian has suggested just background polling
notification IDs for validity, which is a fine mechanism to determine
that preemption has occurred. We could raise EPOLLPRI whenever a
notification has changed into the preempted state, but that would
require an O(n) operations across all outstanding notifications to
determine which one was preempted, and in addition, it doesn't give a
lot of information as to why the preemption occurred (fatal signal,
preemption?).

In order to try to break this into small parts, I suggest:
1. We make it so EPOLLPRI is raised (always) on preempted notifications
2. We allow the user to set a flag to "track" notifications. If they
specify this flag, they can then run a "stronger" ioctl -- let's say
SECCOMP_IOCTL_NOTIF_STATUS, which, if the flag was specified upon
receiving the notification will return the current state of the
notification and if a signal preempted it, it will always do that.

---
Alternatively (and this is my preference), we add another filter flag,
like SECCOMP_FILTER_FLAG_NOTIF_PREEMPT, which changes the behaviour
to:
1. Raise EPOLLPRI on preempted notifications
2. All preemption notifications must be cleared via
SECCOMP_IOCTL_NOTIF_RECV_STATUS.

Opinions?
