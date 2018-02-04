From: Tycho Andersen <tycho-E0fblnxP3wo@public.gmane.org>
Subject: Re: [RFC 1/3] seccomp: add a return code to trap to userspace
Date: Sun, 4 Feb 2018 21:01:29 +0100
Message-ID: <20180204200129.2bgq5yfaimg6xdg5@cisco>
References: <20180204104946.25559-1-tycho@tycho.ws>
	<20180204104946.25559-2-tycho@tycho.ws>
	<CALCETrWgu5n+SMqrsZQ7MVYPtzs8otuc7hpA5uPH+JNtFrMBkQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CALCETrWgu5n+SMqrsZQ7MVYPtzs8otuc7hpA5uPH+JNtFrMBkQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Akihiro Suda <suda.akihiro-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, Tyler Hicks <tyhicks-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi Andy,

On Sun, Feb 04, 2018 at 05:36:33PM +0000, Andy Lutomirski wrote:
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
> 
> I'm slightly confused.  I thought the id was never reused for a given
> struct seccomp_filter.  (Also, shouldn't the id be u64, not u32?)

Well, what happens when u32/64 overflows? Eventually it will wrap.

> On very quick reading, I have a question.  What happens if a process
> has two seccomp_filters attached, one of them returns
> SECCOMP_RET_USER_NOTIF, and the *other* one has a listener?

Good question, in seccomp_run_filters(), the first (lowest, last
applied) filter who returns SECCOMP_RET_USER_NOTIF is the one that
gets the notification and the other receives nothing.

I don't really have any reason to prefer this behavior, it's just what
happened without much thought.

Cheers,

Tycho
