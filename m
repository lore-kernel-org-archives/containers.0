From: Tycho Andersen <tycho-E0fblnxP3wo@public.gmane.org>
Subject: Re: [PATCH v2 1/4] seccomp: add a return code to trap to userspace
Date: Thu, 17 May 2018 09:39:57 -0600
Message-ID: <20180517153957.GA3831__4301.19178859076$1526571505$gmane$org@cisco>
References: <20180517151218.12850-1-tycho@tycho.ws>
	<20180517151218.12850-2-tycho@tycho.ws>
	<20180517153323.GA8586@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20180517153323.GA8586-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: "Tobin C . Harding" <me-xzjC0nNlxno@public.gmane.org>, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Akihiro Suda <suda.akihiro-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, Tyler Hicks <tyhicks-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi Oleg,

Thanks for taking a look!

On Thu, May 17, 2018 at 05:33:24PM +0200, Oleg Nesterov wrote:
> I didn't read this series yet, and I don't even understand what are you
> trying to do, just one question...
> 
> On 05/17, Tycho Andersen wrote:
> >
> > +static struct file *init_listener(struct task_struct *task,
> > +				  struct seccomp_filter *filter)
> > +{
> > +	struct file *ret = ERR_PTR(-EBUSY);
> > +	struct seccomp_filter *cur;
> > +	bool have_listener = false;
> > +
> > +	for (cur = task->seccomp.filter; cur; cur = cur->prev) {
> > +		mutex_lock(&cur->notify_lock);
> 
> Did you test this patch with CONFIG_LOCKDEP ?

Yes, with,

CONFIG_LOCKDEP=y
CONFIG_DEBUG_LOCKDEP=y
CONFIG_DEBUG_ATOMIC_SLEEP=y

> From lockdep pov this loop tries to take the same lock twice or more, it shoul
> complain.

I didn't, but I guess that's because it's not trying to take the same lock
twice -- the pointer cur is changing in the loop. Unless I'm misunderstanding
what you're saying.

The idea behind this code is to lock the entire chain of filters up to the
parent so that we can ensure none of them have a listener installed. This is
based on a suggestion from Andy last review cycle to not allow two listeners,
since nesting would be confusing.

Tycho
