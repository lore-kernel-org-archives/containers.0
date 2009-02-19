From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 7/7][v8] SI_USER: Masquerade si_pid when crossing pid
	ns boundary
Date: Thu, 19 Feb 2009 19:51:59 +0100
Message-ID: <20090219185159.GA374@redhat.com>
References: <20090219030207.GA18783@us.ibm.com>
	<20090219030743.GG18990@us.ibm.com>
	<m1y6w21k6d.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m1y6w21k6d.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
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
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On 02/19, Eric W. Biederman wrote:
>
> Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> writes:
>
> > From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> > Date: Wed, 24 Dec 2008 14:14:18 -0800
> > Subject: [PATCH 7/7][v8] SI_USER: Masquerade si_pid when crossing pid ns
> > boundary
> >
> > When sending a signal to a descendant namespace, set ->si_pid to 0 since
> > the sender does not have a pid in the receiver's namespace.
> >
> > Note:
> > 	- If rt_sigqueueinfo() sets si_code to SI_USER when sending a
> > 	  signal across a pid namespace boundary, the value in ->si_pid
> > 	  will be cleared to 0.
> >
> > Changelog[v5]:
> > 	- (Oleg Nesterov) Address both sys_kill() and sys_tkill() cases
> > 	  in send_signal() to simplify code (this drops patch 7/7 from
> > 	  earlier version of patchset).
> >
> > Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> > ---
> >  kernel/signal.c |    2 ++
> >  1 files changed, 2 insertions(+), 0 deletions(-)
> >
> > diff --git a/kernel/signal.c b/kernel/signal.c
> > index c94355b..a416d77 100644
> > --- a/kernel/signal.c
> > +++ b/kernel/signal.c
> > @@ -883,6 +883,8 @@ static int __send_signal(int sig, struct siginfo *info,
> > struct task_struct *t,
> >  			break;
> >  		default:
> >  			copy_siginfo(&q->info, info);
> > +			if (from_ancestor_ns)
> > +				q->info.si_pid = 0;
>
> This is wrong.  siginfo is a union and you need to inspect
> code to see if si_pid is present in the current union.

SI_FROMUSER() == T, unless we have more (hopefully not) in-kernel
users which send SI_FROMUSER() signals, .si_pid must be valid?

kill_pid_info_as_uid() was the only known sender of SI_FROMUSER
signal, it was converted to use __send_signal(from_ancestor_ns => 0).

Oleg.
