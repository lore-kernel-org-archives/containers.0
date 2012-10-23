From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/7] freezer: add missing mb's to freezer_count() and
	freezer_should_skip()
Date: Tue, 23 Oct 2012 17:39:19 +0200
Message-ID: <20121023153919.GA16201@redhat.com>
References: <1350426526-14254-1-git-send-email-tj@kernel.org>
	<1350426526-14254-3-git-send-email-tj@kernel.org>
	<20121022174404.GA21553@redhat.com>
	<20121022211317.GD5951@atj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121022211317.GD5951-OlzNCW9NnSVy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Tejun,

On 10/22, Tejun Heo wrote:
>
> On Mon, Oct 22, 2012 at 07:44:04PM +0200, Oleg Nesterov wrote:
>
> > We probably have another similar race. If ptrace_stop()->may_ptrace_stop()
> > returns false, the task does
> >
> > 	__set_current_state(TASK_RUNNING);
> > 	// no mb in between
> > 	try_to_freeze();
> >
> > And this can race with task_is_stopped_or_traced() check in the same way.
> > (of course this is only theoretical).
> >
> > do_signal_stop() is probably fine, we can rely on ->siglock.
>
> Hmm....  Guess we should drop __ from set_current_state.

Yes.

Or we can change ptrace_stop() and do_signal_stop() to use freezer_do_not_count/
freezer_count and remove task_is_stopped_or_traced() from update_if_frozen()
and try_to_freeze_tasks(). But this means that do_signal_stop() will call
try_to_freeze() twice, unless we add __freezer_count() which only clears
PF_FREEZER_SKIP.

> I wonder
> whether we should just add mb to freezing()?  What do you think?

Yes, I thought about this too. I just do not know what would be better.

Oleg.
