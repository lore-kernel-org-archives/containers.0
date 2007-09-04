From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Devel] [RFC] [PATCH 2/2] namespace enter: introduce
	sys_hijack (v3)
Date: Tue, 4 Sep 2007 07:50:19 -0500
Message-ID: <20070904125019.GA22410@sergelap.austin.ibm.com>
References: <20070829200420.GA4870@sergelap.austin.ibm.com>
	<20070829200515.GC4870@sergelap.austin.ibm.com>
	<6599ad830709030102w6b5084d4w4a8a9a654e421527@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <6599ad830709030102w6b5084d4w4a8a9a654e421527-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Paul Menage (menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org):
> On 8/29/07, Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> > >From aec05999084bf3a94add66e98462652ed9408f86 Mon Sep 17 00:00:00 2001
> > From: sergeh-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org <sergeh-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > Date: Wed, 22 Aug 2007 15:03:57 -0700
> > Subject: [RFC] [PATCH 2/2] namespace enter: introduce sys_hijack (v3)
> >
> > Introduce sys_hijack (for x86 only).  It is like clone, but in
> > place of a stack pointer (which is assumed null) it accepts a
> > pid.  The process identified by that pid is the one which is
> > actually cloned.  Some state - include the file table, the signals
> > and sighand (and hence tty), and the ->parent are taken from the
> > calling process.
> 
> What do you do if there are no processes in a particular container?

The nsproxy will have been released so you couldn't enter it anyway.

> I prefer your suggestion of tying this to the nsproxy subsystem - that
> would allow you to spawn a child with a given set of namespaces, even
> if there were no appropriate process to hijack.

I can resend my original ns_container entering patchset (maybe next week
when everyone is back from summits) and we can discuss whether or not it
is safe, or how to improve it if it is not.

thanks,
-serge
