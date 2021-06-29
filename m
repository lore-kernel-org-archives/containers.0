Received: from mail-lj1-f173.google.com (mail-lj1-f173.google.com [209.85.208.173])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1D5F870
	for <containers@lists.linux.dev>; Tue, 29 Jun 2021 16:34:35 +0000 (UTC)
Received: by mail-lj1-f173.google.com with SMTP id u25so16252195ljj.11
        for <containers@lists.linux.dev>; Tue, 29 Jun 2021 09:34:35 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=QVxx6zpWtcdsULUPWErKqjtTjlhlStVWEPIt+o6rJzA=;
        b=RQmFW2wmVw+pZcJx5ASMwMtBuR0uIqf1DvohGEj877skEvY7BIALzVK0wZSn85cSgP
         rnVIxAAF4mwSTGnM1fMzlUiP+2hUUukWyxLqSV23B3rr/sbS6B+N/vViuc4nFw87wBca
         Vf7iQHLbxiMR7VnG+qHjquEHs5t0TJ04xAdEI=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=QVxx6zpWtcdsULUPWErKqjtTjlhlStVWEPIt+o6rJzA=;
        b=pNgx+gpCMC2Y4XHOfn8RqL40va5SROjvvg7DLd2YHstsp/kVfjUg2PeXKiJJ0Qa2Xz
         zIIBzqh9gM0Y1DkNqXookgv/Au8swiPU38GXv9YKaGzcoljhn1LeD2rPyRl6Z89xfakd
         EU+w85xTzo8SY9U2EqXXLX4wwXQrq8D2N27OQJ62Os88VP5dQbY5eSVqBrWIPGOHDHsn
         hFDpGCot5fEQciLExyAcUPgsHQ9jRvEyFtzeQNEdR72utr7kODTAv1m41oLbPzNyMOjI
         5xhGFX5r6f8LtbHvmefgkPTTQPAuMfU4Y+bqgLSphCrxDvRN7wGxL1hIBih87VEbUJGV
         jAHg==
X-Gm-Message-State: AOAM532QSLcXDdMUi8xZ97xzIT1/w6IfLRXiUV9G7daQao3ngof8D6pq
	sVF65JmAYVNKde7mgIRH0NB5iGWFAiMWuw5dgrA=
X-Google-Smtp-Source: ABdhPJwqWDVLx+n9GVa1SpGnkImqGMJewfBBfGIrCz6lUiMpZNTd6uEfAQrG2ARc6q30h37RWfQxSA==
X-Received: by 2002:a2e:b1d3:: with SMTP id e19mr4630983lja.362.1624984473933;
        Tue, 29 Jun 2021 09:34:33 -0700 (PDT)
Received: from mail-lf1-f53.google.com (mail-lf1-f53.google.com. [209.85.167.53])
        by smtp.gmail.com with ESMTPSA id v17sm1670274lfp.215.2021.06.29.09.34.33
        for <containers@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 29 Jun 2021 09:34:33 -0700 (PDT)
Received: by mail-lf1-f53.google.com with SMTP id a11so40478140lfg.11
        for <containers@lists.linux.dev>; Tue, 29 Jun 2021 09:34:33 -0700 (PDT)
X-Received: by 2002:ac2:4950:: with SMTP id o16mr16652927lfi.487.1624984473279;
 Tue, 29 Jun 2021 09:34:33 -0700 (PDT)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <87fsx1vcr9.fsf@disp2133> <CAHk-=wj1z-NKxedgZvSS37iH=EKE47PkL=+BYccAUtsuB1sySQ@mail.gmail.com>
 <87czs4u0rm.fsf@disp2133>
In-Reply-To: <87czs4u0rm.fsf@disp2133>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 29 Jun 2021 09:34:17 -0700
X-Gmail-Original-Message-ID: <CAHk-=wgs5+3MLjG_hsQcKdamOcTsJLsk47tV12FfD_0f2h47Rg@mail.gmail.com>
Message-ID: <CAHk-=wgs5+3MLjG_hsQcKdamOcTsJLsk47tV12FfD_0f2h47Rg@mail.gmail.com>
Subject: Re: [GIT PULL] ucounts: Count rlimits in each user namespace
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Alexey Gladkov <legion@kernel.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	Linux Containers <containers@lists.linux.dev>
Content-Type: text/plain; charset="UTF-8"

On Tue, Jun 29, 2021 at 8:52 AM Eric W. Biederman <ebiederm@xmission.com> wrote:
>
> Linus Torvalds <torvalds@linux-foundation.org> writes:
>
> > Why the "sigpending < LONG_MAX" test in that
> >
> >         if (override_rlimit || (sigpending < LONG_MAX && sigpending <=
> > task_rlimit(t, RLIMIT_SIGPENDING))) {
> > thing?
>
> On second look that sigpending < LONG_MAX check is necessary.  When
> inc_rlimit_ucounts detects a problem it returns LONG_MAX.

I saw that, but _without_ that test you'd be left with just that

    sigpending <= task_rlimit(t, RLIMIT_SIGPENDING)

and if task_rlimit() is LONG_MAX, then that means "no limits", so it is all ok.

IOW, afaik even _if_ sigpending ends up being LONG_MAX, the
conditional does the right thing without that "sigpending < LONG_MAX"
test.

                Linus
