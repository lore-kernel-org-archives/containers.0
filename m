Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6068033EF
	for <containers@lists.linux.dev>; Thu,  9 Jun 2022 18:51:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=Sender:In-Reply-To:Content-Type:
	MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=9J+iIL5J9JY8vshmtS+g/ORNXJXMR4XrfE8PbSkbk6s=; b=W1srEC3JSquGQAXYIpQOfooL5Q
	0qnK3UQGTm7TOZalgOreMteXYXtBvz/PCV2XLyWJIgVmrsshJlqQbTcW3uY0CNXiqVhv1wg4TKxpP
	tTIvdGbRGStHpaxPNRvtvsGWjNxJ+NjdBipsrs8hI/Jf4v44iR7XMQV/3+h9EAiXPqrQofKpI/dkG
	wxgitzkn5yaObK7ga9WtPu88Pe9+3mBwIUltZwT0qK/Qcwz3fHgQF4eSPJS/Biw6PTvXr9hnqrsRt
	ZswBsVbZIsrD7sZBuwyZ8WKW6fNRKdq9xDzZw2R2vjPiWtZ198VxDgGfPPf7fPXeF3hob5A70I9Gk
	BZ4gEWzg==;
Received: from mcgrof by bombadil.infradead.org with local (Exim 4.94.2 #2 (Red Hat Linux))
	id 1nzNFu-003jc3-QS; Thu, 09 Jun 2022 18:51:42 +0000
Date: Thu, 9 Jun 2022 11:51:42 -0700
From: Luis Chamberlain <mcgrof@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Alexey Gladkov <legion@kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christian Brauner <brauner@kernel.org>,
	Iurii Zaikin <yzaikin@google.com>,
	Kees Cook <keescook@chromium.org>,
	Linux Containers <containers@lists.linux.dev>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Vasily Averin <vvs@virtuozzo.com>,
	Muchun Song <songmuchun@bytedance.com>, Jia He <hejianet@gmail.com>,
	Pan Xinhui <xinhui@linux.vnet.ibm.com>,
	Thomas Huth <thuth@redhat.com>, ChuckLever <chuck.lever@oracle.com>
Subject: Re: [RFC PATCH 2/4] sysctl: ipc: Do not use dynamic memory
Message-ID: <YqJBPhCwPE1Pk1f7@bombadil.infradead.org>
References: <CAHk-=whi2SzU4XT_FsdTCAuK2qtYmH+-hwi1cbSdG8zu0KXL=g@mail.gmail.com>
 <cover.1654086665.git.legion@kernel.org>
 <857cb160a981b5719d8ed6a3e5e7c456915c64fa.1654086665.git.legion@kernel.org>
 <CAHk-=wjJ2CP0ugbOnwAd-=Cw0i-q_xC1PbJ-_1jrvR-aisiAAA@mail.gmail.com>
 <Ypeu97GDg6mNiKQ8@example.org>
 <CAHk-=wgBeQafNgw6DNUwM4vvw4snb83Tb65m_QH9XSic2JSJaQ@mail.gmail.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHk-=wgBeQafNgw6DNUwM4vvw4snb83Tb65m_QH9XSic2JSJaQ@mail.gmail.com>
Sender: Luis Chamberlain <mcgrof@infradead.org>

On Wed, Jun 01, 2022 at 11:34:18AM -0700, Linus Torvalds wrote:
> On Wed, Jun 1, 2022 at 11:25 AM Alexey Gladkov <legion@kernel.org> wrote:
> >
> > I'm not sure how to get rid of ctl_table since net sysctls are heavily
> > dependent on it.
> 
> Anyway, I think all of this is "I think there is more room for cleanup
> in this area", and maybe we'll never have enough motivation to
> actually do that.

That's a good summary of the cleanup with sysctls so I appreciate the nudges
in the right directions.

  Luis
