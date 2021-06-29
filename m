Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5F3DC177
	for <containers@lists.linux.dev>; Tue, 29 Jun 2021 20:20:31 +0000 (UTC)
Received: by mail.kernel.org (Postfix) with ESMTPSA id 1BA3861D8C;
	Tue, 29 Jun 2021 20:20:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1624998031;
	bh=bICSGDYFeSkCNUGnuvKNS7/wSSeOYM2U/FpPXiDmJgA=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=RATlm6Zf8tzxMTcLPSAQjL1NtGvovqj51un+T+TbgGoACI9EJPlJUydfCOQhAoOve
	 LImjE5NNPEnrwC5jrxEUiXw1epfAXG9ErX91m/i+kpuAZsiVmAmmOt1Q+x7oS54KcS
	 h9zBSm9hzgc5gFg70POaQeuzH3B1hIQRu2wHoESrx30VR+utvNP/bO8O1Vf7dUm9bH
	 mAKYFMvykaXSLjuKgSVXO1xxNakdIiqT8ySa9dx9uBJFeoJHR4daQQwR7mFN/UAbCD
	 +qoBiaiB4ha2p1dwAbt/7h3TDpQypg9SjaK+dZtGttgky96ubTzgLm0Zpn3y/EXUp1
	 rcrtXGKGWOgUw==
Date: Tue, 29 Jun 2021 22:20:28 +0200
From: Alexey Gladkov <legion@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Containers <containers@lists.linux.dev>
Subject: Re: [GIT PULL] ucounts: Count rlimits in each user namespace
Message-ID: <20210629202028.gduluywejae75icj@example.org>
References: <87fsx1vcr9.fsf@disp2133>
 <CAHk-=wj1z-NKxedgZvSS37iH=EKE47PkL=+BYccAUtsuB1sySQ@mail.gmail.com>
 <20210629171757.shyr222zjpm6ev5t@example.org>
 <CAHk-=wgcpK3XdFKJ98b_YucXbQMJMgJssAk=sQ-XUo-tyiMjVg@mail.gmail.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHk-=wgcpK3XdFKJ98b_YucXbQMJMgJssAk=sQ-XUo-tyiMjVg@mail.gmail.com>

On Tue, Jun 29, 2021 at 11:07:11AM -0700, Linus Torvalds wrote:
> On Tue, Jun 29, 2021 at 10:18 AM Alexey Gladkov <legion@kernel.org> wrote:
> >
> >
> > > And why test for "ucounts" being non-NULL in
> > >
> > >                 if (ucounts && dec_rlimit_ucounts(ucounts,
> > > UCOUNT_RLIMIT_SIGPENDING, 1))
> > >                         put_ucounts(ucounts);
> > >
> > > when afaik both of those should be happy with a NULL 'ucounts' pointer
> > > (if it was NULL, we certainly already used it for the reverse
> > > operations for get_ucounts() and inc_rlimit_ucounts()..)
> >
> > The get_ucount() can theoretically return NULL. It increments the
> > reference counter and if it overflows, the function will return NULL.
> 
> .. but my point is that dec_rlimit_ucounts() and put_ucounts() should
> be fine with whatever get_ucounts() returned. No
> 
> It looks like put_ucounts() is unhappy with a NULL ucounts argument,
> but I think _that_ is what should get fixed.
> 
> I think that conceptually we should have two clear alternatives:
> 
>  (a) either "get_ucounts()" returning NULL should be an error, and we
> would have returned long before

get_ucounts() in the __sigqueue_alloc() performs the get_uid() function
but does not ignore the counter overflow. Basically get_uid() can fail in
same way as get_ucounts(), but we just ignore it.

> or
> 
>  (b) a NULL uncounts is usable, and a sequence like
> put_ucounts(get_ucounts()) should just always work.
> 
> And honestly, a lot of the other ucounts funcrtions seem to take that
> (b) approach. Example in that very function:
> 
>         ucounts = task_ucounts(t);
>         sigpending = inc_rlimit_ucounts(ucounts, UCOUNT_RLIMIT_SIGPENDING, 1);
> 
> which at no point tested for NULL or returned an error.

Waaaait. task_ucounts() is a different thing. This function only gets a
field from the task structure without any reference counting. But the
get_ucounts() is more like get_user_ns() or get_uid(), but does not ignore
counter overflow.

Earlier I tried to use refcount_t which never returns errors [1]. We
talked and you said that ignoring counter overflow errors is bad
design for this case.

> (And that also implies that the comment in dec_rlimit_ucounts() about
> "Silence compiler warning" should just go away, because it's not just
> a compiler warning, it's a required initialization).
> 
>               Linus

[1] https://lore.kernel.org/lkml/CAHk-%3dwjYOCgM%2bmKzwTZwkDDg12DdYjFFkmoFKYLim7NFmR9HBg@mail.gmail.com/

-- 
Rgrds, legion

