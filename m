Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C56A5173
	for <containers@lists.linux.dev>; Mon, 14 Jun 2021 08:22:54 +0000 (UTC)
Received: by mail.kernel.org (Postfix) with ESMTPSA id B6C2C61370;
	Mon, 14 Jun 2021 08:22:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=linuxfoundation.org;
	s=korg; t=1623658974;
	bh=fKEG1QQdsee0y5BUfnFwrYpg138QJfLVS/JCvDtXSNw=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=BYPCCet+A5JIifh7UMTn1H1tGYFUHr2l14ShJ65eT+860NNtuiR8stnL96zddKq9e
	 d0tX+xqvB22TODvwTwhTwl+6Jbo17g/R7iqcuj8LjsI5Wa8FUw96ByqYv662+axxB8
	 9Pw4rHtzu3V0FPjRQAcClKEkaSPvGVqq4+l2Brbw=
Date: Mon, 14 Jun 2021 10:22:51 +0200
From: Greg KH <gregkh@linuxfoundation.org>
To: "Enrico Weigelt, metux IT consult" <lkml@metux.net>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Christian Brauner <christian.brauner@ubuntu.com>,
	Hannes Reinecke <hare@suse.de>, containers@lists.linux.dev,
	linux-kernel@vger.kernel.org
Subject: Re: device namespaces
Message-ID: <YMcR2982KSjFu8kM@kroah.com>
References: <20210608142911.ievp2rpuquxjuyus@wittgenstein>
 <d956398e-7ee6-ba36-43cc-4cdcea34b5b9@suse.de>
 <877dj4ff9g.fsf@disp2133>
 <20210609063818.xnod4rzvti3ujkvn@wittgenstein>
 <b9ea9116-7120-b0a7-b739-dd8513e12c5e@suse.de>
 <20210609072108.ldhsxfnfql4pacqx@wittgenstein>
 <85a0d777-dea6-9574-8946-9fc8f912c1af@suse.de>
 <20210609080918.ma2klvxkjad4pjrn@wittgenstein>
 <87v96k1d65.fsf@disp2133>
 <c504a8c6-73f8-b45c-6d6b-6f5a1300ab3a@metux.net>
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c504a8c6-73f8-b45c-6d6b-6f5a1300ab3a@metux.net>

On Mon, Jun 14, 2021 at 09:49:22AM +0200, Enrico Weigelt, metux IT consult wrote:
> On 11.06.21 20:14, Eric W. Biederman wrote:
> 
> Hi,
> 
> > I favor none of the virtual devices showing up in sysfs.  Maybe existing
> > userspace needs the devices in sysfs, but if the solution is simply to
> > skip sysfs for virtual devices that is much simpler.
> 
> Sorry for being a little bit confused, but by virtual devices you mean
> things like pty's or all the other stuff we already see under
> /sys/device/virtual ?
> 
> I'm yet unsure what the better way is. If we're just talking about pty's
> specifically, I maybe could live with threating them like "special sort
> of pipes", but I guess that would require some extra magic.
> 
> If I'm not mistaken, the whole sysfs stuff is automatically handled
> device classes and bus'es - seems that tty's are also class devs.
> 
> How would you skip the virtual devices from sysfs ? Adding some filter
> into sysfs that looks at the device class (or some flag within it) ?

Wait, step back.  What _EXACTLY_ are you wanting to do here?  If you
have not looked at how sysfs handles devices today, that leads me to
believe that you do not have a real model in place.

Again, spend some time and write some code please before continuing this
thread.  We don't like to talk about vague things when you do not even
have an idea of what you want.

good luck!

greg k-h
