From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH] Masquerade sender information
Date: Mon, 29 Oct 2007 14:06:20 -0600
Message-ID: <m1hck9ofcz.fsf@ebiederm.dsl.xmission.com>
References: <20071027190216.GB10397@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071027190216.GB10397-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org's message
	of "Sat, 27 Oct 2007 12:02:16 -0700")
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
Cc: clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org, Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org writes:

> From: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Subject: [PATCH] Masquerade sender information
>
> With multiple pid namespaces, sender of a signal could be in an ancestor
> namespace of the receiver and so the sender will not have a valid 'pid_t'
> in the receiver's namespace.
>
> In this case, masquerade the 'siginfo' for the signal to pretend that the
> signal originated from the kernel.

At first glance this looks ok.  I think the only case where we can
be sending a signal from inside a pid namespace to something not
in a child pid namespace is if we are the kernel.  In which case
we also want si_pid = 0.

If that holds this problem is easier then I was thinking it would
be.

Eric
