Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D60272FAD
	for <containers@lists.linux.dev>; Wed, 26 May 2021 17:52:46 +0000 (UTC)
Received: by mail.kernel.org (Postfix) with ESMTPSA id 675D26139A;
	Wed, 26 May 2021 17:52:43 +0000 (UTC)
Date: Wed, 26 May 2021 19:52:40 +0200
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Andy Lutomirski <luto@kernel.org>
Cc: Sargun Dhillon <sargun@sargun.me>,
	Linux Containers <containers@lists.linux.dev>,
	LKML <linux-kernel@vger.kernel.org>,
	Kees Cook <keescook@chromium.org>,
	Tycho Andersen <tycho@tycho.pizza>,
	Giuseppe Scrivano <gscrivan@redhat.com>,
	Rodrigo Campos <rodrigo@kinvolk.io>,
	Mauricio =?utf-8?Q?V=C3=A1squez?= Bernal <mauricio@kinvolk.io>
Subject: Re: Preemption Signal Management
Message-ID: <20210526175240.dyyvnxcvyuauah7h@wittgenstein>
References: <CAMp4zn93WRF5u=et=detunN7exhQNoFctr-7Qb8-a9=As8vaQw@mail.gmail.com>
 <f9e0126e-2bd4-eda4-0c07-9393d56d1421@kernel.org>
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <f9e0126e-2bd4-eda4-0c07-9393d56d1421@kernel.org>

On Tue, May 25, 2021 at 05:39:49PM -0700, Andy Lutomirski wrote:
> On 5/21/21 9:23 AM, Sargun Dhillon wrote:
> > Andy pointed out that we need a mechanism to determine whether or
> > notifications are preempted. He suggested we use EPOLLPRI to indicate
> > whether or not notifications are preempted. My outstanding question is
> > whether or not we need to be able to get insight of what caused the
> > preemption, and to which notification.
> > 
> > In the past, Christian has suggested just background polling
> > notification IDs for validity, which is a fine mechanism to determine
> > that preemption has occurred. We could raise EPOLLPRI whenever a
> > notification has changed into the preempted state, but that would
> > require an O(n) operations across all outstanding notifications to
> > determine which one was preempted, and in addition, it doesn't give a
> > lot of information as to why the preemption occurred (fatal signal,
> > preemption?).
> > 
> > In order to try to break this into small parts, I suggest:
> > 1. We make it so EPOLLPRI is raised (always) on preempted notifications
> > 2. We allow the user to set a flag to "track" notifications. If they
> > specify this flag, they can then run a "stronger" ioctl -- let's say
> > SECCOMP_IOCTL_NOTIF_STATUS, which, if the flag was specified upon
> > receiving the notification will return the current state of the
> > notification and if a signal preempted it, it will always do that.
> > 
> > ---
> > Alternatively (and this is my preference), we add another filter flag,

In general this sounds good to me.

> > like SECCOMP_FILTER_FLAG_NOTIF_PREEMPT, which changes the behaviour

And make it combinable with SECCOMP_FILTER_FLAG_NEW_LISTENER, I like that.

> > to:
> > 1. Raise EPOLLPRI on preempted notifications
> > 2. All preemption notifications must be cleared via
> > SECCOMP_IOCTL_NOTIF_RECV_STATUS.
> 
> This seems sensible, except I don't think "preempted" is the right word.
>  The state machine is pretty simple:
> 
> live -> signaled -> killed
> 
> (and we can go straight from live to killed, too.)  So EPOLLPRI could be
> signaled if any notification changes state, and a new ioctl could read
> the list of notifications that have changed state.

A common case is will likely be to just rely the status to the
supervised task and not even perform some complicated action in the
supervisor.
So I think a way to optionally combine recv+send at the same time might
be a good idea. Either another ioctl which is a combined recv+send or a
flag on the SECCOMP_IOCTL_NOTIF_RECV_STATUS.

Christian
