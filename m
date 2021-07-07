Received: from mail-lf1-f43.google.com (mail-lf1-f43.google.com [209.85.167.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 09C4372
	for <containers@lists.linux.dev>; Wed,  7 Jul 2021 17:23:54 +0000 (UTC)
Received: by mail-lf1-f43.google.com with SMTP id t17so5925381lfq.0
        for <containers@lists.linux.dev>; Wed, 07 Jul 2021 10:23:54 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=r7YGSy37fYgov/nu/eHIw5R4NrzDeOEToKWhoVDtJ3Y=;
        b=cb52bxmhnl9yk2czoTUjGteBUzb+GDAVEHPn/4CGxQho2sqt0F1sr4FDWRsdYs5LKb
         Fp/T5Kh9W+LM9kbeJL+L94H+6L0TT3CQySegbIN7K7+Rb5XRLNbgg+KVDtTxE2YFjhjN
         fsOmYItJxVvsHLg+IUeqRHDhcgLQurF/BEUbg=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=r7YGSy37fYgov/nu/eHIw5R4NrzDeOEToKWhoVDtJ3Y=;
        b=JD6b0pR6IQqFvmsCyJ1PhcZngmBK9JQGKC6kcWLd11mAsk9xDufgnkAvc/epqqhgKX
         HgmGWQVpsj8WA7sWV+L29jxJlQwkhKDa4/r2IcnzcRCFth2yeTwAPmeMHaADAHzqE9io
         LVbV9aFgpGHF52BariXwMh5MdxoxzPYBC90G7330zr3oZq1nRLHVQpX7mEekpS1qphaO
         vLI8rn2CXFgtgrHhX8D0j/LSV32Zrv9yYnECim3nRPOxPjNF7p376g9Itoag57MVo3oB
         w6lnFXU5gccaQgacitY5Jf1Vl7bqCGsXx12jTaPTLm9YLXKq8qleVvjfVeK0JhcSTBFY
         DfbQ==
X-Gm-Message-State: AOAM531+06Gh5hJM1QbWuuYQdoIzwKkos8J8fKIdq/Bqj/IGDXHSOwOf
	Nmt3FERjdtJIonYIOKXBj7nyl4tMLqok8Xbt
X-Google-Smtp-Source: ABdhPJzF51nqD/TGXvCocm0sGXpxuqf6Xo4XWLb4nms+CllAQpIXjl4cR3PVLY8BJqR2KuzDtWcPSQ==
X-Received: by 2002:a05:6512:210b:: with SMTP id q11mr19220355lfr.577.1625678632382;
        Wed, 07 Jul 2021 10:23:52 -0700 (PDT)
Received: from mail-lf1-f47.google.com (mail-lf1-f47.google.com. [209.85.167.47])
        by smtp.gmail.com with ESMTPSA id k34sm539558lfv.277.2021.07.07.10.23.51
        for <containers@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 07 Jul 2021 10:23:51 -0700 (PDT)
Received: by mail-lf1-f47.google.com with SMTP id p16so5851439lfc.5
        for <containers@lists.linux.dev>; Wed, 07 Jul 2021 10:23:51 -0700 (PDT)
X-Received: by 2002:a19:7d04:: with SMTP id y4mr19433402lfc.201.1625678631269;
 Wed, 07 Jul 2021 10:23:51 -0700 (PDT)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <CAHk-=wjQks3o_3=WewaXw++h+a318B3LTLSFER9Ee4n1pLCZLw@mail.gmail.com>
 <20210702175442.1603082-1-legion@kernel.org> <CAHk-=whfoVN6wiP5VHekckvqivRhpB+b1FnwyWEjz1SB2FN6HQ@mail.gmail.com>
 <20210707165008.tym4352uw3hu7uwp@example.org>
In-Reply-To: <20210707165008.tym4352uw3hu7uwp@example.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 7 Jul 2021 10:23:35 -0700
X-Gmail-Original-Message-ID: <CAHk-=wirhF8G1XniAfxzJXCYUnuAx23Q1WLi_n4+HGsUXv72KQ@mail.gmail.com>
Message-ID: <CAHk-=wirhF8G1XniAfxzJXCYUnuAx23Q1WLi_n4+HGsUXv72KQ@mail.gmail.com>
Subject: Re: [PATCH] ucounts: Fix UCOUNT_RLIMIT_SIGPENDING counter leak
To: Alexey Gladkov <legion@kernel.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	Linux Containers <containers@lists.linux.dev>
Content-Type: text/plain; charset="UTF-8"

On Wed, Jul 7, 2021 at 9:50 AM Alexey Gladkov <legion@kernel.org> wrote:
>
> >   +             dec_rlimit_ucounts(ucounts, UCOUNT_RLIMIT_SIGPENDING, 1);
> >   +             fallthrough;
> >   +     case LONG_MAX:
>
> I think that the counter should be decreased in this case too.
> inc_rlimit_ucounts() increments the counter in all parent userns. If we
> don't decrease the counter then the parent userns will have a counter
> leak.

Ack. So basically that patch, but move the dec_rlimit_ucounts() into
the LONG_MAX case?

Would you mind making a real patch with a commit message, and trying
whatever test-case you had for that KASAN use-after-free report?

              Linus
