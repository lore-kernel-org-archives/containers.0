Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 680843205
	for <containers@lists.linux.dev>; Wed,  1 Jun 2022 19:32:42 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 86751C385A5;
	Wed,  1 Jun 2022 19:32:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1654111962;
	bh=v9toHBa5TmDfdKsgDldwIfhdrCTl/2WwCykRfxoO4MQ=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=V3kanJeeGe3k4gb6Vh7lh2ApF/PlQ6NX9yY4cSw1b1HUXf5tUYr2Nh1gEXeVwk5Qq
	 atk7e3neaHszNz1sTnqzBEOVVLj3suwa34zmDXub6PRF5/0msdNxR72h2+tf2oZvcA
	 EiZbk1BNqA+2YMdemOqTtp/mUaVTZRO/Z6uEzR8FnBlpiQdeiUh3DgFcinrPo/sI9Q
	 Hkm24bpe3hJcMHwgn2I1AjnoQuNjpkSmVSRCd5mQTdZ1x4wvoWTp/ufPB5uPUh/5jO
	 /k8E+HnngmOC57ylnslsksW3bWpBJp0r4TGMkT372cTQ/Ss8X8BFvmteGaA7zYRLay
	 WbQVg8TDvp71w==
Date: Wed, 1 Jun 2022 21:32:35 +0200
From: Alexey Gladkov <legion@kernel.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: LKML <linux-kernel@vger.kernel.org>,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christian Brauner <brauner@kernel.org>,
	Iurii Zaikin <yzaikin@google.com>,
	Kees Cook <keescook@chromium.org>,
	Linux Containers <containers@lists.linux.dev>,
	linux-fsdevel@vger.kernel.org, Luis Chamberlain <mcgrof@kernel.org>,
	Vasily Averin <vvs@virtuozzo.com>
Subject: Re: [RFC PATCH 1/4] sysctl: API extension for handling sysctl
Message-ID: <Ype+08iXbbWghf3i@example.org>
References: <CAHk-=whi2SzU4XT_FsdTCAuK2qtYmH+-hwi1cbSdG8zu0KXL=g@mail.gmail.com>
 <cover.1654086665.git.legion@kernel.org>
 <5ec6759ab3b617f9c12449a9606b6f0b5a7582d0.1654086665.git.legion@kernel.org>
 <Ype7skNJzEQ1W96v@casper.infradead.org>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Ype7skNJzEQ1W96v@casper.infradead.org>

On Wed, Jun 01, 2022 at 08:19:14PM +0100, Matthew Wilcox wrote:
> On Wed, Jun 01, 2022 at 03:20:29PM +0200, Alexey Gladkov wrote:
> > +struct ctl_fops {
> > +	int (*open) (struct ctl_context *, struct inode *, struct file *);
> > +	int (*release) (struct ctl_context *, struct inode *, struct file *);
> > +	ssize_t (*read) (struct ctl_context *, struct file *, char *, size_t *, loff_t *);
> > +	ssize_t (*write) (struct ctl_context *, struct file *, char *, size_t *, loff_t *);
> > +};
> 
> Why not pass the iocb in ->read and ->write?  We're still regretting not
> doing that with file_operations.

Because buf and len can be modified in BPF_CGROUP_RUN_PROG_SYSCTL.
We need to pass the result of this hook to read/write callback.

https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/fs/proc/proc_sysctl.c#n605
https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/bpf/cgroup.c#n1441

-- 
Rgrds, legion

