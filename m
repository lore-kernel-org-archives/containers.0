From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: bugs with ckpt-v15-dev
Date: Mon, 18 May 2009 15:51:00 -0700
Message-ID: <20090518225100.GC28083@us.ibm.com>
References: <m3my9amczw.fsf@pobox.com> <20090518211041.GA20781@us.ibm.com>
	<m3y6suhz5g.fsf@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m3y6suhz5g.fsf-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, May 18, 2009 at 04:36:11PM -0500, Nathan Lynch wrote:
> "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:
> 
> > Quoting Nathan Lynch (ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org):
> >> Last commit is ed3b275 "allow error string during checkpoint while
> >> holding a spinlock".
> >> 
> >> # bash -c 'exec <&- >&- 2>&- ; while : ; do : ; done' &
> >> [1] 2269
> >> # ckpt $! > /tmp/bash.ckpt
> >> 
> >> BUG: sleeping function called from invalid context at mm/slub.c:1595
> >
> > Yeah, not only does ckpt_write_err() get called under task_lock, but
> > the fn returns without ver doing put_task_struct.  (I'd generate and
> > send the quick trivial patch, but my git tree is in a bit of a debugme
> > state right now)
> 
> Would prefer to just rip that thing out, it's cost me more trouble then
> it's worth.
> 
> 
> > Now mind you this shows that your ckpt program isn't sending
> > CHECKPOINT_SUBTREE with flags.
> 
> I don't follow.  There is "user error" here in that I'm not freezing the
> task before checkpointing[1], but my ckpt command is passing the subtree
> flag (0x4) afaict:
> 
> SYS_335(0x9ec, 0x1, 0x4, 0xbfdc6200, 0[2542:c/r:may_checkpoint_task] check 2540
> 
> 
> > This in turns means you are probably
> > not using the ckpt-v15-dev version of user-cr, and if that is
> > the case it makes your problems with gconf shared file mapping more
> > suspect ask well...?
> 
> After updating to the latest user-cr I get the same BUGs.
> 
> [1] Should CONFIG_CHECKPOINT depend on CONFIG_CGROUPS and/or
> CONFIG_CGROUPS_FREEZER?  We require tasks to be put in frozen state
> before checkpoint, is there any mechanism apart from
> cgroup/freezer.state to do this?

Have you tried sending all of the tasks SIGSTOP? It won't 100% freeze the tasks
-- they'd still be capable of responding to some signals (CONT, TERM..). Also 
they'd presumably be placed in the stopped state upon restart so a SIGCONT will
be needed. In the case of bash, at least, that will technically change what
happens upon restart. My guess is that in many cases it won't matter but there
are some where it will. 

The freezer documentation shows an example of what happens with bash
when attempting to use only STOP/CONT rather than the freezer. gdb might
also present interesting cases when just utilizing STOP/CONT signals..

Cheers,
	-Matt Helsley
