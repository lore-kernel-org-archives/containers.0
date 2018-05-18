From: Tycho Andersen <tycho-E0fblnxP3wo@public.gmane.org>
Subject: Re: [PATCH v2 1/4] seccomp: add a return code to trap to userspace
Date: Fri, 18 May 2018 09:21:45 -0600
Message-ID: <20180518152145.GB7699@cisco>
References: <20180517151218.12850-1-tycho@tycho.ws>
	<20180517151218.12850-2-tycho@tycho.ws>
	<20180518140415.GB26297@mailbox.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20180518140415.GB26297-cl+VPiYnx/1AfugRpC6u6w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Christian Brauner <christian-STijNZzMWpgWenYVfaLwtA@public.gmane.org>
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Akihiro Suda <suda.akihiro-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>, "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Tyler Hicks <tyhicks-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, "Tobin C . Harding" <me-xzjC0nNlxno@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, May 18, 2018 at 04:04:16PM +0200, Christian Brauner wrote:
> On Thu, May 17, 2018 at 09:12:15AM -0600, Tycho Andersen wrote:
> > +#ifdef CONFIG_SECCOMP_USER_NOTIFICATION
> > +static u64 seccomp_next_notify_id(struct seccomp_filter *filter)
> > +{
> > +	u64 ret = filter->next_id;
> > +
> > +	/* Note: overflow is ok here, the id just needs to be unique */
> > +	filter->next_id++;
> > +
> > +	return ret;
> > +}
> 
> Nit: Depending on how averse people are to relying on side-effects this
> could be simplified to:
> 
> static inline u64 seccomp_next_notify_id(struct seccomp_filter *filter)
> {
>         /* Note: Overflow is ok. The id just needs to be unique. */
>         return filter->next_id++;
> }

Oh, yes, definitely. I think this is leftover from when this function
worked a different way.

> > +
> > +static void seccomp_do_user_notification(int this_syscall,
> > +					 struct seccomp_filter *match,
> > +					 const struct seccomp_data *sd)
> > +{
> > +	int err;
> > +	long ret = 0;
> > +	struct seccomp_knotif n = {};
> > +
> > +	mutex_lock(&match->notify_lock);
> > +	if (!match->has_listener) {
> > +		err = -ENOSYS;
> > +		goto out;
> > +	}
> 
> Nit:
> 
> err = -ENOSYS;
> mutex_lock(&match->notify_lock);
> if (!match->has_listener)
>         goto out;
> 
> looks cleaner to me or you do the err initalization at the top of the
> function. :)

Ok :)

> > +
> > +	n.pid = current->pid;
> > +	n.state = SECCOMP_NOTIFY_INIT;
> > +	n.data = sd;
> > +	n.id = seccomp_next_notify_id(match);
> > +	init_completion(&n.ready);
> > +
> > +	list_add(&n.list, &match->notifications);
> > +
> > +	mutex_unlock(&match->notify_lock);
> > +	up(&match->request);
> > +
> > +	err = wait_for_completion_interruptible(&n.ready);
> > +	mutex_lock(&match->notify_lock);
> > +
> > +	/*
> > +	 * Here it's possible we got a signal and then had to wait on the mutex
> > +	 * while the reply was sent, so let's be sure there wasn't a response
> > +	 * in the meantime.
> > +	 */
> > +	if (err < 0 && n.state != SECCOMP_NOTIFY_REPLIED) {
> > +		/*
> > +		 * We got a signal. Let's tell userspace about it (potentially
> > +		 * again, if we had already notified them about the first one).
> > +		 */
> > +		if (n.state == SECCOMP_NOTIFY_SENT) {
> > +			n.state = SECCOMP_NOTIFY_INIT;
> > +			up(&match->request);
> > +		}
> > +		mutex_unlock(&match->notify_lock);
> > +		err = wait_for_completion_killable(&n.ready);
> > +		mutex_lock(&match->notify_lock);
> > +		if (err < 0)
> > +			goto remove_list;
> > +	}
> > +
> > +	ret = n.val;
> > +	err = n.error;
> > +
> > +	WARN(n.state != SECCOMP_NOTIFY_REPLIED,
> > +	     "notified about write complete when state is not write");
> 
> Nit: That message seems a little cryptic.

Perhaps we can just drop it. It's just a sanity check, but given the
tests above, it doesn't seem likely.

> > +
> > +remove_list:
> > +	list_del(&n.list);
> > +out:
> > +	mutex_unlock(&match->notify_lock);
> > +	syscall_set_return_value(current, task_pt_regs(current),
> > +				 err, ret);
> > +}
> > +#else
> > +static void seccomp_do_user_notification(int this_syscall,
> > +					 u32 action,
> > +					 struct seccomp_filter *match,
> > +					 const struct seccomp_data *sd)
> > +{
> > +	WARN(1, "user notification received, but disabled");
> 
> Nit: "received unexpected user notification" might be clearer

Yes, I wonder if we shouldn't just drop this too -- it's not a kernel
bug, but a userspace bug that they're using features that aren't
enabled.

We could enhance the verifier with a static check for
BPF_RET | BPF_K == SECCOMPO_RET_USER_NOTIF and reject such programs if
user notification isn't enabled. Of course, it wouldn't handle the
dynamic case, but it might be useful.

Tycho
