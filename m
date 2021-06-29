Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CCE7770
	for <containers@lists.linux.dev>; Tue, 29 Jun 2021 17:18:00 +0000 (UTC)
Received: by mail.kernel.org (Postfix) with ESMTPSA id 90DAA61D8A;
	Tue, 29 Jun 2021 17:17:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1624987080;
	bh=jdhnTCjSFMbgWJNtYg1ovwgDV4GrfVsLQusWb5bxADo=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=ePci/+Mxd3oBZLGRl8CN9PzIZwd/679sUnO+uent/1Z9Z/di/cOo49D6V2XO0k85m
	 WBbGsuQB/UQozaVT+tjG/his5xnUx7jEszWJFVNihWW0mNY4i94av094Dg4Gyc3Ciz
	 oyMi5fBikbLx2NAYN33NPZebNzWhu4e+a55lrT8f27+l8h+8DAnhSwLbtdtA6nlsLG
	 Q4gpcHdlzhY3PFA9VP9CnMoHorbQi9gDrO/7zhqRfCjkCbrvBWkplgXAi6YdqRD9y4
	 Oer1K5pczs+I+7YQ8W4CyfPajONutprXtaO6YFVlDNBPMaxJwBBo3yL7GwkqiPUhIt
	 oit6dUzp5/S5A==
Date: Tue, 29 Jun 2021 19:17:57 +0200
From: Alexey Gladkov <legion@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Containers <containers@lists.linux.dev>
Subject: Re: [GIT PULL] ucounts: Count rlimits in each user namespace
Message-ID: <20210629171757.shyr222zjpm6ev5t@example.org>
References: <87fsx1vcr9.fsf@disp2133>
 <CAHk-=wj1z-NKxedgZvSS37iH=EKE47PkL=+BYccAUtsuB1sySQ@mail.gmail.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHk-=wj1z-NKxedgZvSS37iH=EKE47PkL=+BYccAUtsuB1sySQ@mail.gmail.com>

On Mon, Jun 28, 2021 at 08:47:12PM -0700, Linus Torvalds wrote:
> On Mon, Jun 28, 2021 at 3:35 PM Eric W. Biederman <ebiederm@xmission.com> wrote:
> >
> > This is the work mainly by Alexey Gladkov to limit rlimits to the
> > rlimits of the user that created a user namespace, and to allow users to
> > have stricter limits on the resources created within a user namespace.
> 
> I guess all the performance issues got sorted, since I haven't seen
> any reports from the test robots.
> 
> I do end up with two questions, mainly because of looking at the
> result of the conflict resolution.
> 
> In particular, in __sigqueue_alloc(), two oddities..
> 
> Why the "sigpending < LONG_MAX" test in that
> 
>         if (override_rlimit || (sigpending < LONG_MAX && sigpending <=
> task_rlimit(t, RLIMIT_SIGPENDING))) {
> 
> thing?

inc_rlimit_ucounts() returns long and uses LONG_MAX as an overflow flag.
At the same time, we have increased the size of sigpending from int to
long.

> And why test for "ucounts" being non-NULL in
> 
>                 if (ucounts && dec_rlimit_ucounts(ucounts,
> UCOUNT_RLIMIT_SIGPENDING, 1))
>                         put_ucounts(ucounts);
> 
> when afaik both of those should be happy with a NULL 'ucounts' pointer
> (if it was NULL, we certainly already used it for the reverse
> operations for get_ucounts() and inc_rlimit_ucounts()..)

The get_ucount() can theoretically return NULL. It increments the
reference counter and if it overflows, the function will return NULL.

> Hmm?
> 
> And somebody should verify that I didn't screw anything up in my merge
> resolution. It all looked very straightforward, but mistakes happen..

-- 
Rgrds, legion

