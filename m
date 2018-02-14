From: Tycho Andersen <tycho-E0fblnxP3wo@public.gmane.org>
Subject: Re: [RFC 1/3] seccomp: add a return code to trap to userspace
Date: Wed, 14 Feb 2018 08:29:58 -0700
Message-ID: <20180214152958.cjgwh2k52zji2jxk@cisco>
References: <20180204104946.25559-1-tycho@tycho.ws>
	<20180204104946.25559-2-tycho@tycho.ws>
	<CAGXu5jLAAKY19a9iC1PmXRyuwdn1Zxr2Cb318zdzkqgYt8vtdg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAGXu5jLAAKY19a9iC1PmXRyuwdn1Zxr2Cb318zdzkqgYt8vtdg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Akihiro Suda <suda.akihiro-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Paul Moore <pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Tyler Hicks <tyhicks-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>, Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
List-Id: containers.vger.kernel.org

Hey Kees,

Thanks for taking a look!

On Tue, Feb 13, 2018 at 01:09:20PM -0800, Kees Cook wrote:
> On Sun, Feb 4, 2018 at 2:49 AM, Tycho Andersen <tycho-E0fblnxP3wo@public.gmane.org> wrote:
> > This patch introduces a means for syscalls matched in seccomp to notify
> > some other task that a particular filter has been triggered.
> >
> > The motivation for this is primarily for use with containers. For example,
> > if a container does an init_module(), we obviously don't want to load this
> > untrusted code, which may be compiled for the wrong version of the kernel
> > anyway. Instead, we could parse the module image, figure out which module
> > the container is trying to load and load it on the host.
> >
> > As another example, containers cannot mknod(), since this checks
> > capable(CAP_SYS_ADMIN). However, harmless devices like /dev/null or
> > /dev/zero should be ok for containers to mknod, but we'd like to avoid hard
> > coding some whitelist in the kernel. Another example is mount(), which has
> > many security restrictions for good reason, but configuration or runtime
> > knowledge could potentially be used to relax these restrictions.
> 
> Related to the eBPF seccomp thread, can the logic for these things be
> handled entirely by eBPF? My assumption is that you still need to stop
> the process to do something (i.e. do a mknod, or a mount) before
> letting it continue. Is there some "wait for notification" system in
> eBPF?

I replied in the other thread
(https://patchwork.ozlabs.org/cover/872938/#1856642 for those
following along at home), but no, at least not that I know of.

> > The actual implementation of this is fairly small, although getting the
> > synchronization right was/is slightly complex. Also worth noting that there
> > is one race still present:
> >
> >   1. a task does a SECCOMP_RET_USER_NOTIF
> >   2. the userspace handler reads this notification
> >   3. the task dies
> >   4. a new task with the same pid starts
> >   5. this new task does a SECCOMP_RET_USER_NOTIF, gets the same cookie id
> >      that the previous one did
> >   6. the userspace handler writes a response
> >
> > There's no way to distinguish this case right now. Maybe we care, maybe we
> > don't, but it's worth noting.
> 
> So, I'd like to avoid the cookie if possible (surprise). Why isn't it
> possible to close the kernel-side of the fd to indicate that it lost
> the pid it was attached to?

Because the fd is for a filter, not a task.

> Is this just that the reader has no idea
> who is sending messages? So the risk is a fork/die loop within the
> same process tree (i.e. attached to the same filter)? Hrmpf. I can't
> think of a better way to handle the
> one(fd)-to-many(task-with-that-filter-attached) situation...

Yes, exactly. The cookie just adds uniqueness, and as Andy pointed out
if we switch to u64, the race above basically ("u64 should be enough
for anybody") goes away.

> > Right now the interface is a simple structure copy across a file
> > descriptor. We could potentially invent something fancier.
> 
> I wonder if this communication should be netlink, which gives a more
> well-structured way to describe what's on the wire? The reason I ask
> is because if we ever change the seccomp_data structure, we'll now
> have two places where we need to deal with it (the first being within
> the BPF itself). My initial idea was to prefix the communication with
> a size field, then send the structure, and then I had nightmares, and
> realized this was basically netlink reinvented.

I suggested netlink in LA, and everyone (especially Andy) groaned very
loudly :). I'm happy to switch it to netlink if you like, although i
think memcpy() of structs should be safe here, since the return value
from read or write can indicate the size of things.

> > Finally, it's worth noting that the classic seccomp TOCTOU of reading
> > memory data from the task still applies here, but can be avoided with
> > careful design of the userspace handler: if the userspace handler reads all
> > of the task memory that is necessary before applying its security policy,
> > the tracee's subsequent memory edits will not be read by the tracer.
> 
> Is this really true? Couldn't a multi-threaded process muck with
> memory out from under both the manager and the stopped process?

Sure, but as long as the manager copies the relevant arguments out of
the tracee's memory *before* evaluating whether it's safe to do the
thing the tracee wants to do, it's ok. The assumption here is that the
tracee can't corrupt the manager's memory (because if it could, lots
of other things would already be broken).

> >  /*
> >   * All BPF programs must return a 32-bit value.
> > @@ -34,6 +35,7 @@
> >  #define SECCOMP_RET_KILL        SECCOMP_RET_KILL_THREAD
> >  #define SECCOMP_RET_TRAP        0x00030000U /* disallow and force a SIGSYS */
> >  #define SECCOMP_RET_ERRNO       0x00050000U /* returns an errno */
> > +#define SECCOMP_RET_USER_NOTIF   0x7fc00000U /* notifies userspace */
> >  #define SECCOMP_RET_TRACE       0x7ff00000U /* pass to a tracer or disallow */
> 
> /me tries to come up with an ordering rationale here and fails.
> 
> An ERRNO filter would block a USER_NOTIF because it's unconditional.
> TRACE could be either, USER_NOTIF could be either.
> 
> This means TRACE rules would be bumped by a USER_NOTIF... hmm.

Yes, I didn't exactly know what to do here. ERRNO, TRAP, and KILL all
seemed more important than USER_NOTIF, but TRACE didn't. I don't have
a strong opinion about what to do here, because users can adjust their
filters accordingly. Let me know what you prefer.

> > +#ifdef CONFIG_SECCOMP_USER_NOTIFICATION
> 
> I wonder if it's time to split up seccomp.c ... probably not, but I've
> always been unhappy with the #ifdefs even for just regular _FILTER. ;)

A reasonable question. I'm happy to do that as a separate series
before this one goes in if you want.

> > +static ssize_t seccomp_notify_write(struct file *file, const char __user *buf,
> > +                                   size_t size, loff_t *ppos)
> > +{
> > +       struct seccomp_filter *filter = file->private_data;
> > +       struct seccomp_notif_resp resp = {};
> > +       struct seccomp_knotif *knotif = NULL;
> > +       struct list_head *cur;
> > +       ssize_t ret = -EINVAL;
> > +
> > +       /* No partial writes. */
> > +       if (*ppos != 0)
> > +               return -EINVAL;
> > +
> > +       size = min_t(size_t, size, sizeof(resp));
> 
> In this case, we can't use min_t, size _must_ be == sizeof(resp),
> otherwise we're operating on what's in the stack (which is zeroed, but
> still).

I'm not sure I follow. If the user passes in an old (smaller) struct
seccomp_notif_resp, we don't want to copy more than they specified. If
they pass in a bigger one, this will be sizeof(resp).

> > +       if (copy_from_user(&resp, buf, size))
> > +               return -EFAULT;
> > +
> > +       ret = mutex_lock_interruptible(&filter->notify_lock);
> > +       if (ret < 0)
> > +               return ret;
> > +
> > +       list_for_each(cur, &filter->notifications) {
> > +               knotif = list_entry(cur, struct seccomp_knotif, list);
> > +
> > +               if (knotif->id == resp.id)
> > +                       break;
> 
> So we're finding the matching id here. Now, I'm trying to think about
> how this will look in real-world use: the pid will be _blocked_ while
> this happening. And all the other pids that trip this filter will
> _also_ be blocked, since they're all waiting for the reader to read
> and respond. The risk is pid death while waiting, and having another
> appear with the same pid, trigger the same filter, get blocked, and
> then the reader replies for the old pid, and the new pid gets the
> results?

Yep, exactly.

> Since this notification queue is already linear, can't we use ordering
> to enforce this? i.e. only the pid at the head of the filter
> notification queue is going to have anything happening to it. Or is
> the idea to have multiple readers/writers of the fd?

I'm not really sure how we prevent multiple readers/writers of the fd.
But even with a single writer, the case you described "could" happen
(although again, with u64 cookies it shouldn't be a problem).

I'm not sure how ordering helps us though; the problem is really that
one entry for a pid was deleted, and a whole new one was created. So
ordering will look ok, but the response will go to the wrong pid.

> > +       }
> > +
> > +       if (!knotif || knotif->id != resp.id) {
> > +               ret = -EINVAL;
> > +               goto out;
> > +       }
> > +
> > +       ret = size;
> > +       knotif->state = SECCOMP_NOTIFY_WRITE;
> > +       knotif->error = resp.error;
> > +       knotif->val = resp.val;
> > +       complete(&knotif->ready);
> > +out:
> > +       mutex_unlock(&filter->notify_lock);
> > +       return ret;
> > +}
> > +
> > +static const struct file_operations seccomp_notify_ops = {
> > +       .read = seccomp_notify_read,
> > +       .write = seccomp_notify_write,
> > +       /* TODO: poll */
> 
> What's needed for poll? I think you've got all the pieces you need
> already, i.e. wait queue, notifications, etc.

Nothing, I just didn't implement it. I will do so for v2.

> > +       .release = seccomp_notify_release,
> > +};
> > +
> > +static struct file *init_listener(struct seccomp_filter *filter)
> > +{
> > +       struct file *ret;
> > +
> > +       mutex_lock(&filter->notify_lock);
> > +       if (filter->has_listener) {
> > +               mutex_unlock(&filter->notify_lock);
> > +               return ERR_PTR(-EBUSY);
> > +       }
> > +
> > +       ret = anon_inode_getfile("seccomp notify", &seccomp_notify_ops,
> > +                                filter, O_RDWR);
> > +       if (IS_ERR(ret)) {
> > +               __put_seccomp_filter(filter);
> > +       } else {
> > +               /*
> > +                * Intentionally don't put_seccomp_filter(). The file
> > +                * has a reference to it now.
> > +                */
> > +               filter->has_listener = true;
> > +       }
> 
> I spent some time staring at this, and I don't see it: where is the
> get_() for this? The caller of init_listener() already does a put() on
> the failure path. It seems like there is a get() missing near the
> start of init_listener(), or I've entirely missed something.

Ugh, yes. For the SECCOMP_FILTER_FLAG_GET_LISTENER case, you're right.
Originally I only had the ptrace-based one, and that has a get() in
get_nth_filter(), so the comment makes sense in that case.

I'll straighten this out for v2 and

> (Regardless, I think the usage counting need a comment somewhere,
> maybe near the top of seccomp.c with the field?)

...add a comment.

> > +#define USER_NOTIF_MAGIC 116983961184613L
> 
> Is this just you mashing the numpad? :)

Is there some better way to generate magic numbers? :)

Cheers,

Tycho
