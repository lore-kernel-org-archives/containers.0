Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D993B7A
	for <containers@lists.linux.dev>; Thu,  9 Jun 2022 16:45:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=Sender:In-Reply-To:Content-Type:
	MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=gVI3Ea/l9RerBozp3vD3BZhKp1cPeVbhqnYdNTkFTUE=; b=ueZd8oLTQhOOq2+OTonDgw8aQt
	+p3JalI3+ek/mLSW7qX3pduaIdhafG+uHamo6+Z4WYWSnGq4feHGxAoEAGuf5xjFhOt2QwGiVlj8f
	E12cXHcNNPaCbF80Z1+jSZj7PLLrq1Ybs24VRlE8wv/tEVDyqgynyVdreoZVe6mOE75Ns7jHh0WWW
	Pq2yjGjqgH5bMAeZT4CARnDZIjVJbKwcKITy6FhP/e7OSxr4b7M7tlcHlb15v9s4UIKjIIzgCQNBn
	2uLfk54tc6rUIqonQQBn4gRpbXR3FznYH+fBOtlCV13Q1Rax8eZGXAm4PFU5FkNN3XNQz9l1J7D6a
	qz91+VGA==;
Received: from mcgrof by bombadil.infradead.org with local (Exim 4.94.2 #2 (Red Hat Linux))
	id 1nzLHi-002vFC-Om; Thu, 09 Jun 2022 16:45:26 +0000
Date: Thu, 9 Jun 2022 09:45:26 -0700
From: Luis Chamberlain <mcgrof@kernel.org>
To: Alexey Gladkov <legion@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christian Brauner <brauner@kernel.org>,
	Iurii Zaikin <yzaikin@google.com>,
	Kees Cook <keescook@chromium.org>,
	Linux Containers <containers@lists.linux.dev>,
	linux-fsdevel@vger.kernel.org, Vasily Averin <vvs@virtuozzo.com>
Subject: Re: [RFC PATCH 0/4] API extension for handling sysctl
Message-ID: <YqIjpvyooF8hQQf4@bombadil.infradead.org>
References: <CAHk-=whi2SzU4XT_FsdTCAuK2qtYmH+-hwi1cbSdG8zu0KXL=g@mail.gmail.com>
 <cover.1654086665.git.legion@kernel.org>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1654086665.git.legion@kernel.org>
Sender: Luis Chamberlain <mcgrof@infradead.org>

On Wed, Jun 01, 2022 at 03:20:28PM +0200, Alexey Gladkov wrote:
> On Fri, Apr 22, 2022 at 01:44:50PM -0700, Linus Torvalds wrote:
> > On Fri, Apr 22, 2022 at 5:53 AM Alexey Gladkov <legion@kernel.org> wrote:
> > >
> > > Yes, Linus, these changes are not the refactoring you were talking
> > > about, but I plan to try to do such a refactoring in the my next
> > > patchset.
> > 
> > Heh. Ok, I'm not saying these patches are pretty, and looking up the
> > namespace thing is a bit subtle, but it's certainly prettier than the
> > existing odd "create a new ctl_table entry because of field abuse".
> 
> As I promised, here is one of the possible options for how to get rid of dynamic
> memory allocation.
> 
> We can slightly extend the API and thus be able to save data at the time the
> file is opened. This will not only eliminate the need to allocate memory, but
> also provide access to file struct and f_cred.
> 
> I made an RFC because I'm not sure that I did the permissions check for
> ipc_sysctl. I also did not change all the places where this API can be applied
> to make the patch smaller. As in the case of /proc/sys/kernel/printk where
> CAP_SYS_ADMIN is checked[1] for the current process at the time of write.

Thanks for all this, can you also add respective selftests extensions
for this on lib/test_sysctl.c and tools/testing/selftests/sysctl/sysctl.sh ?

  Luis
