From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [Devel] [PATCH] pidns: Place under CONFIG_EXPERIMENTAL (take 2)
Date: Fri, 26 Oct 2007 21:40:46 -0700
Message-ID: <20071026214046.c61e248d.akpm@linux-foundation.org>
References: <CBC546DD07068244AEC110EFEDA58B7235893F@excite.int.sw-soft.com>
	<m1ve8ty1tq.fsf@ebiederm.dsl.xmission.com>
	<20071027002448.GH30533@stusta.de>
	<m18x5puyw7.fsf@ebiederm.dsl.xmission.com>
	<20071027020408.GO30533@stusta.de>
	<20071026191845.fd0f75c8.akpm@linux-foundation.org>
	<m18x5pte18.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m18x5pte18.fsf-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: kir-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, kir-66LJJ20gB3DQT0dZR+AlfA@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, 26 Oct 2007 21:46:59 -0600 ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman) wrote:

> Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> writes:
> 
> >> On Sat, 27 Oct 2007 04:04:08 +0200 Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
> >> > be happy to hear if someone has a better idea.
> >> 
> >> There is a difference between "complete the feature" and "early adopters 
> >> to start playing with the feature" on the one side, and making something 
> >> available in a released kernel on the other side.
> >> 
> >> For development and playing with it it can depend on BROKEN (perhaps 
> >> with the dependency removed through the first -rc kernels), but as soon 
> >> as it's available in a -final kernel the ABI is fixed.
> >> 
> >
> > Yes, if we're not 100% certain that the interfaces are correnct and unchanging
> > and that the implementation is solid, we should disable the feature at Kconfig
> > time.
> 
> Reasonable.  So far things look good for a single pid namespace.  Multiple
> pid namespaces look iffy.
> 
> > The best option would be to fix things asap.  But assuming that option isn't
> > reasonable and/or safe, we can slip a `depends on BROKEN' into -rc6 then
> > resume development for 2.6.25.
> 
> I think we can make a lot of progress but there is enough development
> yet to do to reach the target of correct and unchanging interfaces,
> with a solid interface.  That unless we achieve a breakthrough I
> don't see us achieving that target for 2.6.24.
> 
> The outstanding issues I can think of off the top of my head:
> - signal handling for init on secondary pid namespaces.
> - Properly setting si_pid on signals that cross namespaces.
> - The kthread API conversion so we don't get kernel threads
>   trapped in pid namespaces and make them unfreeable.
> - At fork time I think we are doing a little bit too much work
>   in setting the session and the pgrp, and removing the controlling
>   tty.
> - AF_unix domain credential passing.
> - misc pid vs vpid sorting out (autofs autofs4, coda, arch specific
>   syscalls, others?)
> - Removal of task->pid, task->tgid, task->signal->__pgrp,
>   tsk->signal->__session or some other way to ensure that we have
>   touched and converted all of the kernel pid handling.
> - flock pid handling.

Given that a lot of this development will hopefully happen over the next
two months, ...

> It hurts me to even ponder what thinking makes it that 
> CONFIG_EXPERIMENTAL isn't enough to keep a stable distro
> from shipping the code in their stable kernel, and locking us into
> trouble.
> 
> With that said.  I think I should just respin the patchset now and add
> the "depends on BROKEN".  

it doesn't make sense to make it all dependent upon BROKEN now.  Better
would be to make it dependant upon CONFIG_SOMETHING_ELSE now, which depends
upon EXPERIMENTAL and which will, around -rc6, be changed to depend upon
BROKEN.

If that makes sense.

It's all a bit unusual and complex, but this is an exceptional set of
features - let's hang in there.
