Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9D46670
	for <containers@lists.linux.dev>; Thu,  1 Jul 2021 16:41:47 +0000 (UTC)
Received: by mail.kernel.org (Postfix) with ESMTPSA id 457D2613D9;
	Thu,  1 Jul 2021 16:41:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1625157707;
	bh=in4VU5RIWGG684bNvSMnsw+p9BXQ9s8OKZF7cAC6rHk=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=Oftp7ZdL5tE7BCXQ9XLJaOCuSFxJqXMIudHmTDRPg3s9N/siAL7ardyWWIxe/WIxz
	 eGDaPd+4v0xzauntvznH6SycncZ+gCaNt3/Tf2Xa0VBpSYMBsKCXcRyku/Xx0DZjW2
	 UkhtBkTcZSlwYAlECZDD6ee11ZIZUir6keuWKNbztnyZCTqIAjHJqeB9Htq2sAVyJ4
	 eHBq+9MmLC5+2+BImx1FVX42C4i9M3sIDbnSo5cBFNwkWQz/2LbXjzhLT8qrc4IYqB
	 BaNsDRmnNRfDB6vX90aHL/xBRKO6bIgef7EW8esxcPzmLDTyPA5cWYiGU6FroSuGUt
	 TTRAsxBF9L2IA==
Date: Thu, 1 Jul 2021 18:41:44 +0200
From: Alexey Gladkov <legion@kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Containers <containers@lists.linux.dev>
Subject: Re: [GIT PULL] ucounts: Count rlimits in each user namespace
Message-ID: <20210701164144.u2dod4g2obfj4kit@example.org>
References: <87fsx1vcr9.fsf@disp2133>
 <CAHk-=wj1z-NKxedgZvSS37iH=EKE47PkL=+BYccAUtsuB1sySQ@mail.gmail.com>
 <87czs4u0rm.fsf@disp2133>
 <CAHk-=wgs5+3MLjG_hsQcKdamOcTsJLsk47tV12FfD_0f2h47Rg@mail.gmail.com>
 <87mtr8sjvr.fsf@disp2133>
 <87a6n8simq.fsf@disp2133>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87a6n8simq.fsf@disp2133>

On Tue, Jun 29, 2021 at 12:09:01PM -0500, Eric W. Biederman wrote:
> ebiederm@xmission.com (Eric W. Biederman) writes:
> 
> > Linus Torvalds <torvalds@linux-foundation.org> writes:
> >
> >> On Tue, Jun 29, 2021 at 8:52 AM Eric W. Biederman <ebiederm@xmission.com> wrote:
> >>>
> >>> Linus Torvalds <torvalds@linux-foundation.org> writes:
> >>>
> >>> > Why the "sigpending < LONG_MAX" test in that
> >>> >
> >>> >         if (override_rlimit || (sigpending < LONG_MAX && sigpending <=
> >>> > task_rlimit(t, RLIMIT_SIGPENDING))) {
> >>> > thing?
> >>>
> >>> On second look that sigpending < LONG_MAX check is necessary.  When
> >>> inc_rlimit_ucounts detects a problem it returns LONG_MAX.
> >>
> >> I saw that, but _without_ that test you'd be left with just that
> >>
> >>     sigpending <= task_rlimit(t, RLIMIT_SIGPENDING)
> >>
> >> and if task_rlimit() is LONG_MAX, then that means "no limits", so it is all ok.
> >
> > It means no limits locally.  The creator of your user namespace might
> > have had a limit which you are also bound by.
> >
> > The other possibility is that inc_rlimits_ucounts caused a sigpending
> > counter to overflow.  In which case we need to fail and run
> > dec_rlimit_ucounts to keep the counter from staying overflowed.
> >
> > So I don't see a clever way to avoid the sigpending < LONG_MAX  test.
> 
> Hmm.  I take that back.  There is a simple clever way to satisfy all of
> the tests.
> 
> - sigpending < LONG_MAX && sigpending <= task_rlimit(t, RLIMIT_SIGPENDING)
> + sigpending < task_rlimit(t, RLIMIT_SIGPENDING)
> 
> That would just need a small comment to explain the subtleties.  

Is it because user.sigpending was atomic_t before this patch ?

-- 
Rgrds, legion

