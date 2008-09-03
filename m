From: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [Devel] Re: [PATCH 0/9] OpenVZ kernel based checkpointing/restart
Date: Wed, 3 Sep 2008 17:59:27 +0400
Message-ID: <200809031759.29132.major__47913.3361638107$1220450395$gmane$org@openvz.org>
References: <1220439476-16465-1-git-send-email-major@openvz.org>
	<48BE82F9.4020808@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48BE82F9.4020808-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wednesday 03 September 2008 16:28 Cedric Le Goater wrote:
> Andrey Mirkin wrote:
> > This patchset introduces kernel based checkpointing/restart as it is
> > implemented in OpenVZ project. This patchset has limited functionality
> > and are able to checkpoint/restart only single process. Recently Oren
> > Laaden sent another kernel based implementation of checkpoint/restart.
> > The main differences between this patchset and Oren's patchset are:
> >
> > * In this patchset checkpointing initiated not from the process
> > (right now we do not have a container, only namespaces), Oren's patchset
> > performs checkpointing from the process context.
> >
> > * Restart in this patchset is initiated from process, which restarts a
> > new process (in new namespaces) with saved state. Oren's patchset uses
> > the same process from which restart was initiated and restore saved state
> > over it.
> >
> > * Checkpoint/restart functionality in this patchset is implemented as a
> > kernel module
>
> why ? Do we really think that C/R implementations will be so different that
> we will need C/R ops to support all of them ? I imagine that there could be
> different models :
>
> 	1. brute force : dump it all and kill
> 	2. incremental
> 	3. live migration
> 	...
>
> But I see all of them really tied to the kernel internals.
>
> The first issues I see with this direction are some EXPORT_SYMBOL() that
> would be useless without a module.

Checkpoint/restart functionality is implemented as a kernel module to provide 
more flexibility during development process - you can easily unload module, 
fix what you need and load module again, you do not need to reboot you server 
in this case. We have discussed this question during Container's mini summit 
on OLS-2008 and we have found out that it will be convenient to have such an 
ability.

>
> > As checkpointing is initiated not from the process which state should be
> > saved we should freeze a process before saving its state. Right now
> > Container Freezer from Matt Helsley can be used for this.
>
> OK that's integrated and Daniel's tools :
>
> http://lxc.cvs.sourceforge.net/lxc/
>
> one more reason to work on integration :)

Yes, you're right :)

Regards,
Andrey

>
> > This patchset introduce only a concept how kernel based
> > checkpointing/restart can be implemented and are able to
> > checkpoint/restart only a single process with simple VMAs.
> >
> > I've tried to split my patchset in small patches to make review more
> > easier. _______________________________________________
> > Containers mailing list
> > Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> > https://lists.linux-foundation.org/mailman/listinfo/containers
>
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
>
> _______________________________________________
> Devel mailing list
> Devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
> https://openvz.org/mailman/listinfo/devel
