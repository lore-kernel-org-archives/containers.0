From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Devel] [PATCH] Allow signalling container-init
Date: Thu, 9 Aug 2007 09:42:14 -0500
Message-ID: <20070809144214.GG23030@sergelap.austin.ibm.com>
References: <20070808234737.GA18334@us.ibm.com> <87vebph6vq.fsf@rimspace.net>
	<20070809012128.GA16391@sergelap.austin.ibm.com>
	<87myx1h4wt.fsf@rimspace.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87myx1h4wt.fsf-zvVxMF7wGoXk1uMJSBkQmQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Pittman <daniel-zvVxMF7wGoXk1uMJSBkQmQ@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Daniel Pittman (daniel-zvVxMF7wGoXk1uMJSBkQmQ@public.gmane.org):
> "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:
> > Quoting Daniel Pittman (daniel-zvVxMF7wGoXk1uMJSBkQmQ@public.gmane.org):
> >> sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org writes:
> 
> [...]
> 
> >> > TODO:	Ideally we should allow killing the container-init only from
> >> > 	ancestor containers and prevent it being killed from that or
> >> > 	descendant containers.  But that is a more complex change and
> >> > 	will be addressed by a follow-on patch. For now allow the
> >> > 	container-init to be terminated by any process with sufficient
> >> > 	privileges.
> >> 
> >> This will break, as far as I can see, by allowing the container root to
> >> send signals to init that it doesn't expect.
> >
> > Yes, in the end what we want is for a container init to receive
> >
> > 	1. all signals from a (authorized) process in a parent
> > 	   pid namespace.
> > 	2. for signals sent from inside it's pid namespace, only
> > 	   exactly those signals for which it has installed a
> > 	   custom signal handler, no others.
> >
> > In other words to a process in an ancestor pid namespace, the init of a
> > container is like any other process.  To a process inside the namespace
> > for which it is init, it is as /sbin/init is to the system now.
> 
> That makes sense.
> 
> > Actually achieving that without affecting performance for all
> > signalers is nontrivial.  The current patchset is complex enough that
> > I'd like to see us settle on non-optimal semantics for now, and once
> > these patches have settled implement the ideal signaling.
> 
> I appreciate that.  I figured to make you aware that this will make it
> impossible to run upstart and, probably, other versions of init in your
> container as expected.
> 
> Since this was a somewhat subtle bug to track down it is, I think, work
> documenting so that people trying to use this code are aware of the
> limitation.

Agreed.  I do think it is documented in the code and in changelogs.
Maybe it's worth adding a Documentation/ file describing how to use the
pid namespaces, ideal semantics, and current shortcomings, for people
who want to use+test the feature rather than work with the kernel code.

-serge
