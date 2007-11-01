From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH] Masquerade sender information
Date: Thu, 01 Nov 2007 10:59:31 -0600
Message-ID: <m1mytxewb0.fsf@ebiederm.dsl.xmission.com>
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
Cc: clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org writes:

> +static void masquerade_sender(struct task_struct *t, struct sigqueue *q)
> +{
> +       /*
> +        * If the sender does not have a pid_t in the receiver's active
> +        * pid namespace, set si_pid to 0 and pretend signal originated
> +        * from the kernel.
> +        */
> +       if (!pid_ns_equal(t)) {
> +               q->info.si_pid = 0;
> +               q->info.si_uid = 0;
> +               q->info.si_code = SI_KERNEL;
> +       }
> +}

It looks like we are hooked in the right place.  However the way we
are handling this appears wrong.

First.  If we have an si_code that does not use si_pid then we should
not be changing si_pid, because the structure is a union and that field
is not always a pid value.


My gut feel says the code should be something like:

switch (q->info->si_code & __SI_MASK) {
case __SI_KILL:
case __SI_CHILD:
case __SI_RT:
case __MESQ:
       q->info->si_pid = task_pid_nr_ns(current, t->nsproxy->pid_ns);
       break;
}

Eric
