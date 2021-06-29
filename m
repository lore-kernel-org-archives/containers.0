Received: from mail-lj1-f180.google.com (mail-lj1-f180.google.com [209.85.208.180])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9A6D870
	for <containers@lists.linux.dev>; Tue, 29 Jun 2021 18:07:31 +0000 (UTC)
Received: by mail-lj1-f180.google.com with SMTP id d25so32232042lji.7
        for <containers@lists.linux.dev>; Tue, 29 Jun 2021 11:07:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=RrPyRQ5IO5eewgSwjbnscAxAW9L+6cXFp6QTzBqY4/w=;
        b=DwLkNq7SHWRjgUjXov7smOgfFqoIqfdHao/1+I+k6kXqTB0ouzJ2e3lTxDYIKpVJtx
         36G6M4NcrwNK/ZnKdheqPNTEAHi9hS4WBY4wAUpV8OHUzqzjYLXvUEa2URrzj4q0A4gL
         GDI1gvURikS6TbLfSGHymcR86Fx1v041Ly1Co=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=RrPyRQ5IO5eewgSwjbnscAxAW9L+6cXFp6QTzBqY4/w=;
        b=bBvrfke9kcdWiasahcvLrTBFGQkht3UF3YYRnoqn8JeXF9CNvHSU4+ISYUQ9jaV/NU
         XfOz5D2Iprp9GO/D7J2/i9l4bVkkMM7OotY/eRoLJ/qi7zVS85AJOP2YqSDR0Rmpkw5M
         hKyWje7l2HPuXtCtouAY7YiO+kTki6/mGyoYDxLOrZIfMcPUHPJoRgGUKTD55cqYQHuc
         VCrQrf7bRtvaRDM9tt+aJDPqG/hsLAGNWtzWcZ+QudfpusAQk/9JGxk4WrfoO6bD8iDB
         JD4hV69WSdRBM+EUAtldxX2jjsN/nkh1XL1ic1qEx0KEl7Mj9FP3Oh7+F2vJxTGNK3W/
         5Xrg==
X-Gm-Message-State: AOAM530Vh0WzPic2Zh9epjwLfWbTZD4NPMZWMfDehmkaauEfU0trEGfR
	7l98G1O22CLPvzaYYcaLIsg3Zj6TqdQE0TM5LT4=
X-Google-Smtp-Source: ABdhPJz2pgH7u7LVGME/HKq/1pkcEQWA+4q3/bjgL/LFuJ/6Ls1ukbm6BgOS+NAAIgGOgIcx1KUvhQ==
X-Received: by 2002:a05:651c:130f:: with SMTP id u15mr4952598lja.269.1624990049526;
        Tue, 29 Jun 2021 11:07:29 -0700 (PDT)
Received: from mail-lj1-f180.google.com (mail-lj1-f180.google.com. [209.85.208.180])
        by smtp.gmail.com with ESMTPSA id d10sm46866lfn.84.2021.06.29.11.07.27
        for <containers@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 29 Jun 2021 11:07:27 -0700 (PDT)
Received: by mail-lj1-f180.google.com with SMTP id w11so11626317ljh.0
        for <containers@lists.linux.dev>; Tue, 29 Jun 2021 11:07:27 -0700 (PDT)
X-Received: by 2002:a2e:b553:: with SMTP id a19mr4820656ljn.507.1624990047466;
 Tue, 29 Jun 2021 11:07:27 -0700 (PDT)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <87fsx1vcr9.fsf@disp2133> <CAHk-=wj1z-NKxedgZvSS37iH=EKE47PkL=+BYccAUtsuB1sySQ@mail.gmail.com>
 <20210629171757.shyr222zjpm6ev5t@example.org>
In-Reply-To: <20210629171757.shyr222zjpm6ev5t@example.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 29 Jun 2021 11:07:11 -0700
X-Gmail-Original-Message-ID: <CAHk-=wgcpK3XdFKJ98b_YucXbQMJMgJssAk=sQ-XUo-tyiMjVg@mail.gmail.com>
Message-ID: <CAHk-=wgcpK3XdFKJ98b_YucXbQMJMgJssAk=sQ-XUo-tyiMjVg@mail.gmail.com>
Subject: Re: [GIT PULL] ucounts: Count rlimits in each user namespace
To: Alexey Gladkov <legion@kernel.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	Linux Containers <containers@lists.linux.dev>
Content-Type: text/plain; charset="UTF-8"

On Tue, Jun 29, 2021 at 10:18 AM Alexey Gladkov <legion@kernel.org> wrote:
>
>
> > And why test for "ucounts" being non-NULL in
> >
> >                 if (ucounts && dec_rlimit_ucounts(ucounts,
> > UCOUNT_RLIMIT_SIGPENDING, 1))
> >                         put_ucounts(ucounts);
> >
> > when afaik both of those should be happy with a NULL 'ucounts' pointer
> > (if it was NULL, we certainly already used it for the reverse
> > operations for get_ucounts() and inc_rlimit_ucounts()..)
>
> The get_ucount() can theoretically return NULL. It increments the
> reference counter and if it overflows, the function will return NULL.

.. but my point is that dec_rlimit_ucounts() and put_ucounts() should
be fine with whatever get_ucounts() returned. No

It looks like put_ucounts() is unhappy with a NULL ucounts argument,
but I think _that_ is what should get fixed.

I think that conceptually we should have two clear alternatives:

 (a) either "get_ucounts()" returning NULL should be an error, and we
would have returned long before

or

 (b) a NULL uncounts is usable, and a sequence like
put_ucounts(get_ucounts()) should just always work.

And honestly, a lot of the other ucounts funcrtions seem to take that
(b) approach. Example in that very function:

        ucounts = task_ucounts(t);
        sigpending = inc_rlimit_ucounts(ucounts, UCOUNT_RLIMIT_SIGPENDING, 1);

which at no point tested for NULL or returned an error.

(And that also implies that the comment in dec_rlimit_ucounts() about
"Silence compiler warning" should just go away, because it's not just
a compiler warning, it's a required initialization).

              Linus
