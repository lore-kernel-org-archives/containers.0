From: Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
Subject: Re: [RFC][PATCH] Make access to taks's nsproxy liter
Date: Wed, 8 Aug 2007 20:58:17 +0400
Message-ID: <20070808165817.GA631@tv-sign.ru>
References: <46B9E321.6070602@openvz.org>
	<20070808164854.GB28455@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070808164854.GB28455-6s5zFf/epYLPQpwDFJZrxKsjOiXwFzmk@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On 08/08, Serge E. Hallyn wrote:
>
> Quoting Pavel Emelyanov (xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org):
> > +void switch_task_namespaces(struct task_struct *p, struct nsproxy *new)
> > +{
> > +	struct nsproxy *ns;
> > +
> > +	might_sleep();
> > +
> > +	ns = p->nsproxy;
> > +	if (ns == new)
> > +		return;
> > +
> > +	if (new)
> > +		get_nsproxy(new);
> > +	rcu_assign_pointer(p->nsproxy, new);
> > +
> > +	if (ns && atomic_dec_and_test(&ns->count)) {
> > +		/*
> > +		 * wait for others to get what they want from this
> > +		 * nsproxy. cannot release this nsproxy via the
> > +		 * call_rcu() since put_mnt_ns will want to sleep
> > +		 */
> > +		synchronize_rcu();
> > +		free_nsproxy(ns);
> > +	}
> > +}
> 
> Also a comment above switch_task_namespaces() that it must be called
> with task_lock held.

Heh, indeed, sys_unshare() does this. might_sleep() won't be happy.

Oleg.
