Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6FE1A29CA
	for <containers@lists.linux.dev>; Tue,  8 Jun 2021 12:41:48 +0000 (UTC)
Received: by mail.kernel.org (Postfix) with ESMTPSA id 860996023E;
	Tue,  8 Jun 2021 12:41:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=linuxfoundation.org;
	s=korg; t=1623156108;
	bh=I/9UjWyXkJ418fvvcVmVgnBgL8SqzouPAlgJ5NltetU=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=xMYpznH6b6aI8a+h4qyaS9D+TGDXsNNUFsLJK1gB3VxS5nuwJDG0z1xtz47tu+mpx
	 JIC4b1xAUbSvLD7R9of+EdElzeUwvgKKCsqSXhTjx3GWlBq3GBXC/kdHghiaafVlC+
	 Mdbfph8/sCTVveGu5QNce48Qy8Y3tMu3vQKxICDA=
Date: Tue, 8 Jun 2021 14:41:45 +0200
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: "Enrico Weigelt, metux IT consult" <lkml@metux.net>
Cc: Christian Brauner <christian.brauner@ubuntu.com>,
	containers@lists.linux.dev,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: device namespaces
Message-ID: <YL9liW99Ytf6uBlu@kroah.com>
References: <ca7520c9-d260-6c87-43b9-f9be24ded50c@metux.net>
 <20210608123050.zde5lwmovjr4yhiy@wittgenstein>
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20210608123050.zde5lwmovjr4yhiy@wittgenstein>

On Tue, Jun 08, 2021 at 02:30:50PM +0200, Christian Brauner wrote:
> On Tue, Jun 08, 2021 at 11:38:16AM +0200, Enrico Weigelt, metux IT consult wrote:
> > Hello folks,
> > 
> > 
> > I'm going to implement device namespaces, where containers can get an
> > entirely different view of the devices in the machine (usually just a
> > specific subset, but possibly additional virtual devices).
> > 
> > For start I'd like to add a simple mapping of dev maj/min (leaving aside
> > sysfs, udev, etc). An important requirement for me is that the parent ns
> > can choose to delegate devices from those it full access too (child
> > namespaces can do the same to their childs), and the assignment can
> > change (for simplicity ignoring the case of removing devices that are
> > already opened by some process - haven't decided yet whether they should
> > be forcefully closed or whether keeping them open is a valid use case).
> > 
> > The big question for me now is how exactly to do the table maintenance
> > from userland. We already have entries in /proc/<pid>/ns/*. I'm thinking
> > about using them as command channel, like this:
> > 
> > * new child namespaces are created with empty mapping
> > * mapping manipulation is done by just writing commands to the ns file
> > * access is only granted if the writing process itself is in the
> >  parent's device ns and has CAP_SYS_ADMIN (or maybe their could be some
> >  admin user for the ns ? or the 'root' of the corresponding user_ns ?)
> > * if the caller has some restrictions on some particular device, these
> >  are automatically added (eg. if you're restricted to readonly, you
> >  can't give rw to the child ns).
> > 
> > Is this a good way to go ? Or what would be a better one ?
> 
> Ccing Greg. Without adressing specific problems, I should warn you that
> this idea is not new and the plan is unlikely to go anywhere. Especially
> not without support from Greg.

Hah, yeah, this is a non-starter.

Enrico, what real problem are you trying to solve by doing this?  And
have you tried anything with this yet?  We almost never talk about
"proposals" without seeing real code as it's pointless to discuss things
when you haven't even proven that it can work.

So let's see code before even talking about this...

And as Christian points out, you can do this today without any kernel
changes, so to think you need to modify the kernel means that you
haven't even tried this at all?

greg k-h
