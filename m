Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 95F2572
	for <containers@lists.linux.dev>; Tue, 15 Jun 2021 11:33:14 +0000 (UTC)
Received: by mail.kernel.org (Postfix) with ESMTPSA id 3A17861107;
	Tue, 15 Jun 2021 11:33:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=linuxfoundation.org;
	s=korg; t=1623756793;
	bh=9+5iyCctCQAgAcMSlpqZHL0gJCffhwjZ3OGMh8bKo40=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=N8n6QFnmPCBQJLYEwXZU4Th9ZC5sPFSgloEeM8cVIXRvvy4duwk/mcF+BQ/0vimUB
	 /76YgsgTvguKFo/Ca0eAn7Iv+vzx4cugVCczPOGQw9c6c/1ax+jaxS15zB15aVAguH
	 url8LPWa2zGRURNYcoQyjDvY5YX2oMD7gXwekV4U=
Date: Tue, 15 Jun 2021 13:33:11 +0200
From: Greg KH <gregkh@linuxfoundation.org>
To: "Enrico Weigelt, metux IT consult" <lkml@metux.net>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Christian Brauner <christian.brauner@ubuntu.com>,
	Hannes Reinecke <hare@suse.de>, containers@lists.linux.dev,
	linux-kernel@vger.kernel.org
Subject: Re: device namespaces
Message-ID: <YMiP90KPQhpOyvlN@kroah.com>
References: <877dj4ff9g.fsf@disp2133>
 <20210609063818.xnod4rzvti3ujkvn@wittgenstein>
 <b9ea9116-7120-b0a7-b739-dd8513e12c5e@suse.de>
 <20210609072108.ldhsxfnfql4pacqx@wittgenstein>
 <85a0d777-dea6-9574-8946-9fc8f912c1af@suse.de>
 <20210609080918.ma2klvxkjad4pjrn@wittgenstein>
 <87v96k1d65.fsf@disp2133>
 <c504a8c6-73f8-b45c-6d6b-6f5a1300ab3a@metux.net>
 <874ke0s60c.fsf@disp2133>
 <2bee9206-ca4a-8456-fabf-9557db599545@metux.net>
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2bee9206-ca4a-8456-fabf-9557db599545@metux.net>

On Tue, Jun 15, 2021 at 01:24:24PM +0200, Enrico Weigelt, metux IT consult wrote:
> @Greg: what's your take on that iterator idea ?

I want you to stop talking about ideas, and try to implement them before
this conversation wastes anyone else's time and energy.

There is a good reason we do not do this type of "let's discuss things!"
in the kernel community, and that is because almost none of it matters
without working code.

So please, let's see some patches that implement your ideas and then we
can discuss them.

Until then, consider this thread ignored from me.

greg k-h
