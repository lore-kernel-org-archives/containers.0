Received: from mail-wr1-f49.google.com (mail-wr1-f49.google.com [209.85.221.49])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 70532107A1
	for <containers@lists.linux.dev>; Fri, 13 Oct 2023 08:56:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=bytedance.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=bytedance.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=bytedance.com header.i=@bytedance.com header.b="bjPTOOYc"
Received: by mail-wr1-f49.google.com with SMTP id ffacd0b85a97d-3226cc3e324so1766299f8f.3
        for <containers@lists.linux.dev>; Fri, 13 Oct 2023 01:56:11 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=bytedance.com; s=google; t=1697187370; x=1697792170; darn=lists.linux.dev;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=QsJhIfLsRHiX///0/Oi95cVwlqVzdrWiGNekq6xdLM4=;
        b=bjPTOOYccDWYh6z83Vyqr9AxJo2fwIVpKoZPsWe7eWtnq1MOefmN/OMFhv7n8f5cj6
         J+F1U7c0eCiUpMbqzuygobZEndjLOv0IYN4DLVG4IEP9ZYgkSg27Q46OV2IaMdi90fj+
         BCM9o4hwGTdHL5vtlg9NMJcUTHOLsru2xbhSf7FlxCdkxTu9VUrZpYGEKy+KRR4Ns5Tk
         nNZg4SEWl2gLw1ehDhwnn1cKKtCnkPgCSiy465oOm3H6Eysi7yzUTJII96x4eVtM+gTq
         vwXdLG7H1uNbFSt0niFLsnPNrh5yEM9tLykhKvEYVTh7Q81pAvQqxRzXb4SI4nVm80iJ
         CvFg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1697187370; x=1697792170;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=QsJhIfLsRHiX///0/Oi95cVwlqVzdrWiGNekq6xdLM4=;
        b=cmsAGoDs+9Y2LV+cftZau/R7A2F3uqbBcCzRkitxPVP7QxC2oDGqiPModGWq0T4kJO
         PJp3O4opH/KyS8/xlxWOTwoksg9+BIMyea3530IMwMatrkVs/yTd8Qec7C9mm9FvsWio
         aMHZKaSQMwQuwq/2EVgy8XIHO/Iz91BRMDvoE1InmPIIgaP54lzrTjSeAQr2OAgraeCI
         Snrc1AusgWYNl1yTUOye+f/405LJu8OVLH7koeGtpBQnusZ46bzFlaoQvie93hl4Y51m
         qLpTaeBx+aXvqFneiVIk7ZotOVttdHKb24uIddo/0xKz+uCA5WLRhNvADsROHchc5xmz
         KXWw==
X-Gm-Message-State: AOJu0YyX1CquWu29mupvoz++DCKiadBsPj1zuvNYhuDk+sBfCw2Xzd2x
	+y2CbXlqF3uMIOLX9Fphx20+M5l2AuABTugDroiRXg==
X-Google-Smtp-Source: AGHT+IFQSN80GM1lzdIOwHcS7K2zJXJxnmkZSpKsMAwnHJyUEeL23io86C4Ojqp4lqoCazHUe7nxeCXeoaPBOqeSJsM=
X-Received: by 2002:a5d:4b05:0:b0:32d:8db5:59ff with SMTP id
 v5-20020a5d4b05000000b0032d8db559ffmr3673791wrq.5.1697187369658; Fri, 13 Oct
 2023 01:56:09 -0700 (PDT)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <20231011065446.53034-1-cuiyunhui@bytedance.com>
 <87sf6gcyb3.fsf@email.froward.int.ebiederm.org> <CAEEQ3wm8oE1dXo7AuU3gY90oF_G21OqNZwnkqhhd1-_j4wWbYQ@mail.gmail.com>
In-Reply-To: <CAEEQ3wm8oE1dXo7AuU3gY90oF_G21OqNZwnkqhhd1-_j4wWbYQ@mail.gmail.com>
From: yunhui cui <cuiyunhui@bytedance.com>
Date: Fri, 13 Oct 2023 16:55:58 +0800
Message-ID: <CAEEQ3wk-faMz3pRtc-n_zSTo3B=GjHeDH4PMN0EJT6=HPVGZ=A@mail.gmail.com>
Subject: Re: [External] Re: [PATCH] pid_ns: support pidns switching between sibling
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: akpm@linux-foundation.org, keescook@chromium.org, brauner@kernel.org, 
	jeffxu@google.com, frederic@kernel.org, mcgrof@kernel.org, cyphar@cyphar.com, 
	rongtao@cestc.cn, linux-kernel@vger.kernel.org, 
	Linux Containers <containers@lists.linux.dev>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Eric,

On Fri, Oct 13, 2023 at 10:44=E2=80=AFAM yunhui cui <cuiyunhui@bytedance.co=
m> wrote:
>
> Hi Eric,
>
> On Thu, Oct 12, 2023 at 11:31=E2=80=AFAM Eric W. Biederman
> <ebiederm@xmission.com> wrote:
> >
> > Yunhui Cui <cuiyunhui@bytedance.com> writes:
> >
> > > In the scenario of container acceleration,
> >
> > What is container acceleration?
> >
> > Are you perhaps performing what is essentially checkpoint/restart
> > from one set of processes to a new set of processes so you can
> > get a container starting faster?
> Yeah, you are right .
>
> >
> > > when a target pstree is cloned from a temp pstree, we hope that the
> > > cloned process is inherently in the target's pid namespace.
> >
> > I am having a hard time figuring out what you are saying here.
>
> I think I need to describe in detail our needs and problems we face.
> What we need to do is fork a container into a new container, which
> means that all
> processes of the original container need to be forked out and added to
> the new container.
> Then the forked process needs to be added to the namespace and cgroup
> of the new container.
>
> What we are talking about here is the pid namespace.
>
> for example:
> Assume that there are three processes A, B, and C in the original contain=
er.
> What we need to do is A fork A_new, B fork B_new, C fork C_new.
>
> However, in the existing pidns implementation, the parent process
> first joins pidns, and then
> the forked child process will get the new pidns (the pid of the child
> process is what we expected),
> and the parent process's own pidns has not actually changed (at least
> pid is still existing).
>
> To make A_new, B_new, and C_new inherently in the pidns of the new contai=
ner,
> A, B, and C must first switch to the pidns of the new container, right?
> From my understanding there is no better way to implement it.
>
> But the existing implementation (the part to be changed in this patch)
> is blocking our progress.
>
> >
> > > Examples of what we expected:
> > >
> > > /* switch to target ns first. */
> > > setns(target_ns, CLONE_NEWPID);
> >   ^-------- Is this the line that fails for you?

Yes, it failed here.

Thanks,
Yunhui
