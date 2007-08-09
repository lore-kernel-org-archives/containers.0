From: Daniel Pittman <daniel-zvVxMF7wGoXk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [Devel] [PATCH] Allow signalling container-init
Date: Thu, 09 Aug 2007 10:46:33 +1000
Message-ID: <87vebph6vq.fsf@rimspace.net>
References: <20070808234737.GA18334@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070808234737.GA18334-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org's message
	of "Wed, 8 Aug 2007 16:47:37 -0700")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org writes:

> Should we include this in the patchset ?

[...]

> Only the global-init process must be special - any other
> container-init process must be killable to prevent run-away processes
> in the system.

One problem I hit while using OpenVZ is that some init processes --
notable upstart used by Ubuntu -- depend on the special signal processing
extended to init by the kernel.

The problem here was that a signal the kernel would otherwise have
blocked was sent to upstart, the default handler was invoked and init
was terminated.

> TODO:	Ideally we should allow killing the container-init only from
> 	ancestor containers and prevent it being killed from that or
> 	descendant containers.  But that is a more complex change and
> 	will be addressed by a follow-on patch. For now allow the
> 	container-init to be terminated by any process with sufficient
> 	privileges.

This will break, as far as I can see, by allowing the container root to
send signals to init that it doesn't expect.

Regards,
        Daniel
-- 
Digital Infrastructure Solutions -- making IT simple, stable and secure
Phone: 0401 155 707        email: contact-gyMb1R/nBgM33TBCqt261WVqPpYm49HuKQEueVp/e6I@public.gmane.org
                 http://digital-infrastructure.com.au/
