From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/9] OpenVZ kernel based checkpointing/restart
Date: Wed, 3 Sep 2008 09:18:41 -0500
Message-ID: <20080903141841.GA13425__9253.59217585555$1220452001$gmane$org@us.ibm.com>
References: <1220439476-16465-1-git-send-email-major@openvz.org>
	<48BE82F9.4020808@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <48BE82F9.4020808-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Cedric Le Goater (clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org):
> Andrey Mirkin wrote:
> > This patchset introduces kernel based checkpointing/restart as it is
> > implemented in OpenVZ project. This patchset has limited functionality and
> > are able to checkpoint/restart only single process. Recently Oren Laaden
> > sent another kernel based implementation of checkpoint/restart. The main
> > differences between this patchset and Oren's patchset are:
> > 
> > * In this patchset checkpointing initiated not from the process
> > (right now we do not have a container, only namespaces), Oren's patchset
> > performs checkpointing from the process context.
> > 
> > * Restart in this patchset is initiated from process, which restarts a new
> > process (in new namespaces) with saved state. Oren's patchset uses the same
> > process from which restart was initiated and restore saved state over it.
> > 
> > * Checkpoint/restart functionality in this patchset is implemented as a kernel
> > module
> 
> why ? Do we really think that C/R implementations will be so different that
> we will need C/R ops to support all of them ? I imagine that there could be 
> different models :

At the mini-summit two reasons were brought up to make it a module:

	1. So sysadmins worried about security implications can
	completely unload the module

	2. So developers can unload and reload the module while
	testing.

> 	1. brute force : dump it all and kill
> 	2. incremental
> 	3. live migration 
> 	...

Actually I don't think we expected to use different implementations for
those.

> But I see all of them really tied to the kernel internals.
> 
> The first issues I see with this direction are some EXPORT_SYMBOL() that would 
> be useless without a module.
>
> > As checkpointing is initiated not from the process which state should be saved
> > we should freeze a process before saving its state. Right now Container Freezer
> > from Matt Helsley can be used for this.
> 
> OK that's integrated and Daniel's tools :
> 
> http://lxc.cvs.sourceforge.net/lxc/
> 
> one more reason to work on integration :)
> 
> C. 
> 
> 
> > This patchset introduce only a concept how kernel based checkpointing/restart
> > can be implemented and are able to checkpoint/restart only a single process
> > with simple VMAs. 
> > 
> > I've tried to split my patchset in small patches to make review more easier.
> > _______________________________________________
> > Containers mailing list
> > Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> > https://lists.linux-foundation.org/mailman/listinfo/containers
> > 
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
