From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] Make access to task's nsproxy liter
Date: Mon, 13 Aug 2007 10:01:54 -0500
Message-ID: <20070813150154.GA29883@sergelap.austin.ibm.com>
References: <46BAE3A3.7030608@openvz.org>
	<20070810134003.GA22368@sergelap.austin.ibm.com>
	<20070810140545.GA74@tv-sign.ru> <46BC7FAC.2080208@openvz.org>
	<20070810164546.GA273@tv-sign.ru>
	<m13ayrxo60.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m13ayrxo60.fsf-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org>
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
Cc: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org> writes:
> 
> > On 08/10, Pavel Emelyanov wrote:
> >>
> >> Oleg Nesterov wrote:
> >> >On 08/10, Serge E. Hallyn wrote:
> >> >>Quoting Pavel Emelyanov (xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org):
> >> >>>+/*
> >> >>>+ * the namespaces access rules are:
> >> >>>+ *
> >> >>>+ *  1. only current task is allowed to change tsk->nsproxy pointer or
> >> >>>+ *     any pointer on the nsproxy itself
> >> >>>+ *
> >> >>>+ *  2. when accessing (i.e. reading) current task's namespaces - no
> >> >>>+ *     precautions should be taken - just dereference the pointers
> >> >>>+ *
> >> >>>+ *  3. the access to other task namespaces is performed like this
> >> >>>+ *     rcu_read_lock();
> >> >>>+ *     nsproxy = task_nsproxy(tsk);
> >> >>>+ *     if (nsproxy != NULL) {
> >> >>>+ *             / *
> >> >>>+ *               * work with the namespaces here
> >> >>>+ *               * e.g. get the reference on one of them
> >> >>>+ *               * /
> >> >>>+ *     } / *
> >> >>>+ *         * NULL task_nsproxy() means that this task is
> >> >>>+ *         * almost dead (zombie)
> >> >>>+ *         * /
> >> >>>+ *     rcu_read_unlock();
> >> >>And lastly, I guess that the caller to switch_task_namespaces() has
> >> >>to ensure that new_nsproxy either (1) is the init namespace, (2) is a
> >> >>brand-new namespace to which noone else has a reference, or (3) the
> >> >>caller has to hold a reference to the new_nsproxy across the call to
> >> >>switch_task_namespaces().
> >> >>
> >> >>As it happens the current calls fit (1) or (2).  Again if we happen to
> >> >>jump into the game of switching a task into another task's nsproxy,
> >> >>we'll need to be mindful of (3) so that new_nsproxy can't be tossed into
> >> >>the bin between
> >> >>
> >> >>	if (new)
> >> >>		get_nsproxy(new);
> >> >
> >> >4) Unless tsk == current, get_task_namespaces(tsk) and get_nsproxy(tsk)
> >> >   are racy even if done under rcu_read_lock().
> >> 
> >> Yup :)
> >> 
> >> It is already written in comment that only the current is allowed
> >> to change its nsproxy. I.e. when switch_task_nsproxy() is called
> >> for tsk other than current it's a BUG
> >
> > Yes, but what I meant is that this code
> >
> >         rcu_read_lock();
> >         nsproxy = task_nsproxy(tsk);
> >         if (nsproxy != NULL)
> >                 get_nsproxy(nsproxy);
> >         rcu_read_unlock();
> >
> > 	if (nsproxy) {
> > 		use_it(nsproxy);
> > 		put_nsproxy(nsproxy);
> > 	}
> >
> > is not safe despite the fact we are _not_ changing tsk->nsproxy.
> >
> > The patch itself is correct because we don't do that, and the comment
> > is right. Just it is not immediately obvious.
> 
> Ugh.  That is nasty, non obvious and almost a problem.  I don't want
> to do get_net(nsproxy->net_ns) from another task so I can migrate
> network between namespaces.
> 
> But thinking about it because we don't do the other decrements
> until later we can still increment the counts on the individual
> namespaces.  We just can't share nsproxy.
> 
> So if you did want to do an enter thing you could copy the
> nsproxy object of a task under the rcu_read_lock(), and
> you would be fine.

Yup, that makes sense, good idea.

-serge
