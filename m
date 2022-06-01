Received: from casper.infradead.org (casper.infradead.org [90.155.50.34])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F0A543205
	for <containers@lists.linux.dev>; Wed,  1 Jun 2022 19:25:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=casper.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=4Ozc3WmHm81wghcNONugG5hk9vFuG2z5HhSD0Snaras=; b=i+++ReQnDqzP0P6p8kS4NN2U7O
	ojdpFSmBOMPcjzwyy2Q3sniEbBJQOupIthIpOhs4EWUAdBdzhgj5kwCbSnp8dZUuO+NDQDrSaDLIK
	AeGjtgP+9RXIl5ERC7FiHris096j7auGtitS7vSZxp1EQIiJmHYdPyQ0gBla8DcHt2Yh2XHJvvkRV
	EfawBfVZV6nhbOgvVPRevzk596tgaHebq9zlysJ1jzSqwp6MBJFcqU+giDMT8J4XZJaH7Tr9QzW7U
	6O/yH44QGbNDIFLpEjDSu8o89ELFU7Eb8ffiTx6/9erZq8ZNmjVfa4ymjf2niy3dFZnfJYS911QPN
	HWIyFqwg==;
Received: from willy by casper.infradead.org with local (Exim 4.94.2 #2 (Red Hat Linux))
	id 1nwTy4-006Y6S-Te; Wed, 01 Jun 2022 19:25:20 +0000
Date: Wed, 1 Jun 2022 20:25:20 +0100
From: Matthew Wilcox <willy@infradead.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Alexey Gladkov <legion@kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christian Brauner <brauner@kernel.org>,
	Iurii Zaikin <yzaikin@google.com>,
	Kees Cook <keescook@chromium.org>,
	Linux Containers <containers@lists.linux.dev>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Vasily Averin <vvs@virtuozzo.com>
Subject: Re: [RFC PATCH 1/4] sysctl: API extension for handling sysctl
Message-ID: <Ype9ILKm+8WLOq9W@casper.infradead.org>
References: <CAHk-=whi2SzU4XT_FsdTCAuK2qtYmH+-hwi1cbSdG8zu0KXL=g@mail.gmail.com>
 <cover.1654086665.git.legion@kernel.org>
 <5ec6759ab3b617f9c12449a9606b6f0b5a7582d0.1654086665.git.legion@kernel.org>
 <Ype7skNJzEQ1W96v@casper.infradead.org>
 <CAHk-=wiTtYMia0FR4h7_nV2RZ5pq=wR-7oMMK3o8o=EgAxMsmg@mail.gmail.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHk-=wiTtYMia0FR4h7_nV2RZ5pq=wR-7oMMK3o8o=EgAxMsmg@mail.gmail.com>

On Wed, Jun 01, 2022 at 12:23:06PM -0700, Linus Torvalds wrote:
> On Wed, Jun 1, 2022 at 12:19 PM Matthew Wilcox <willy@infradead.org> wrote:
> >
> > Why not pass the iocb in ->read and ->write?  We're still regretting not
> > doing that with file_operations.
> 
> No, all the actual "io" is done by the caller.
> 
> There is no way in hell I want the sysctl callbacks to actually
> possibly do user space accesses etc.
> 
> They get a kernel buffer that has already been set up. There is no
> iocb or iovec left for them.

I wasn't suggesting the iovec.  Just the iocb, instead of passing in the
ki_filp and the ki_pos.

> (That also means that they can take whatever locks they need,
> including spinlocks, because there's not going to be any random user
> accesses or complex pipe buffer lookups or whatever).
> 
>                 Linus
