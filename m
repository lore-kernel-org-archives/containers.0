Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 54E72168
	for <containers@lists.linux.dev>; Tue, 29 Jun 2021 21:22:24 +0000 (UTC)
Received: by mail.kernel.org (Postfix) with ESMTPSA id A0F8261DA0;
	Tue, 29 Jun 2021 21:22:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1625001743;
	bh=DASKGpMIPrP2jFKLyy4+IOkW669wEy21u5wK1pFUSt0=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=DKxc6PAR5H2fNFB1FwSxjgTDm9aqiE0K/UepIySbYe/1vPLUhsNrG8okJnJgI5uJW
	 gKwnWrLizzHaGxmIl9uZh7gLOGvuBT6YUF4ZiM/B2MMz3pkOS8JBrAtoYbk8Ngiwb1
	 U9C81E2JLMWCns3rmrwp+TH71C3QKa3ymYAyoIfr8s70cKtOynqxSC0DZYdlw8u6l2
	 UYvO+xqiqmMECBsnfz09BkbN5HfGhmkYRqRykPQpUOAkTxv4Fk8gl5hyLB9jbpRR08
	 TWNS+yyXI2XeFS7e/KQTyelcCCpWD4mNF/v0k9XAPIM1+8zb5UqAuW8bU8dmiThAqH
	 21IGPypj97MiQ==
Date: Tue, 29 Jun 2021 23:22:20 +0200
From: Alexey Gladkov <legion@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Containers <containers@lists.linux.dev>
Subject: Re: [GIT PULL] ucounts: Count rlimits in each user namespace
Message-ID: <20210629212220.itvtsqls4tnmrei7@example.org>
References: <87fsx1vcr9.fsf@disp2133>
 <CAHk-=wj1z-NKxedgZvSS37iH=EKE47PkL=+BYccAUtsuB1sySQ@mail.gmail.com>
 <20210629171757.shyr222zjpm6ev5t@example.org>
 <CAHk-=wgcpK3XdFKJ98b_YucXbQMJMgJssAk=sQ-XUo-tyiMjVg@mail.gmail.com>
 <20210629202028.gduluywejae75icj@example.org>
 <CAHk-=wjQks3o_3=WewaXw++h+a318B3LTLSFER9Ee4n1pLCZLw@mail.gmail.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHk-=wjQks3o_3=WewaXw++h+a318B3LTLSFER9Ee4n1pLCZLw@mail.gmail.com>

On Tue, Jun 29, 2021 at 01:33:39PM -0700, Linus Torvalds wrote:
> On Tue, Jun 29, 2021 at 1:20 PM Alexey Gladkov <legion@kernel.org> wrote:
> >
> > Waaaait. task_ucounts() is a different thing. This function only gets a
> > field from the task structure without any reference counting. But the
> > get_ucounts() is more like get_user_ns() or get_uid(), but does not ignore
> > counter overflow.
> 
> Alexey, that code cannot be right.
> 
> Look here:
> 
>         rcu_read_lock();
>         ucounts = task_ucounts(t);
>         sigpending = inc_rlimit_ucounts(ucounts, UCOUNT_RLIMIT_SIGPENDING, 1);
>         if (sigpending == 1)
>                 ucounts = get_ucounts(ucounts);
>         rcu_read_unlock();
> 
> so now we've done that inc_rlimit_ucounts() unconditionally on that
> task_ucounts() thing.
> 
> And then if the allocation fails (or the limit is hit) the code does
> 
>         if (ucounts && dec_rlimit_ucounts(ucounts, UCOUNT_RLIMIT_SIGPENDING, 1))
>                 put_ucounts(ucounts);
> 
> ie now it does the dec_rlimit_ucounts _conditionally_.
> 
> See what I'm complaining about? This is not logical, AND IT CANNOT
> POSSIBLY BE RIGHT.
> 
> My argument is that
> 
>  (a) the dec_rlimit_ucounts() has to pair up with
> inc_rlimit_ucounts(), or you're leaking counts
> 
>  (b) get_ucounts() has to pair up with put_ucounts().
> 
> Note that (a) has to be REGARDLESS of whether get_ucounts() was
> successful or not.
> 
> > Earlier I tried to use refcount_t which never returns errors [1]. We
> > talked and you said that ignoring counter overflow errors is bad
> > design for this case.
> 
> You can't ignore counter overflow errors, no. But that's exactly what
> that code is doing.
> 
> If get_ucount() fails due to overflow, you don't return an error. You
> just miscount the end result!
> 
> So yeah, its' "testing" the overflow condition, but that's not an
> argument, when it then DOES EXPLICITLY THE WRONG THING.
> 
> At that point, the test is actively harmful and wrong. See?

Yes. Please, give me some time to fix it.

-- 
Rgrds, legion

