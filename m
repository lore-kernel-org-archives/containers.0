From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 1/1] s390: actually restart syscalls after sys_restart
Date: Thu, 21 Jan 2010 11:00:02 -0500 (EST)
Message-ID: <Pine.LNX.4.64.1001211048260.10869@takamine.ncl.cs.columbia.edu>
References: <20100121062802.GA2770@us.ibm.com>
	<Pine.LNX.4.64.1001210904210.6064@takamine.ncl.cs.columbia.edu>
	<20100121154332.GE6878@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100121154332.GE6878-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 21 Jan 2010, Serge E. Hallyn wrote:

> Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> > Hi,
> > 
> > I'm not sure thix fix is totally correct. 
> > 
> > First, a reminder of how -ERESTART... errors behave:
> > 
> > 1) If a (user) signal handler was *not* called then:
> >   -ERESTARTSYS:    re-execute syscall
> >   -ERESTARTNOHAND:    re-execute syscall   
> >   -ERESTARTNOINTR:    re-execute syscall
> >   -ERESTART_RESTARTBLOCK:   arrange to call sys_restart_syscall
> > 
> > 2) If a (user) signal handler *was* called then:
> >   -ERESTARTSYS:    re-execute syscall iff SA_RESTART (else EINTR)
> >   -ERESTARTNOHAND:    return -EINTR
> >   -ERESTARTNOINTR:    re-execute syscall
> >   -ERESTART_RESTARTBLOCK:   return -EINTR
> > 
> > The difference between x86 and s390 is _when_ (and how) the task state is
> > altered (to arrange for re-execution), in case of task freezing:
> > 
> > * In x86, changes occur _after_ the task is frozen, and the work is split 
> > between handle_signal() and do_signal().
> > 
> > * In s390, some changes occur _before_ the task is frozen, and possibly 
> > undone after the freeze if a signal handler was called. All work is done 
> > is do_signal(). Because of that, our checkpoint only sees a partial view 
> > of the task's state.
> > 
> > Now back to the proposed fix: it isn't sufficient because:
> > 
> > (a) If the process has a signal pending when checkpointed, then the state 
> > already reflects some changes by do_signal(). If the signal leads to a 
> > (user) signal handler after restart, then do_signal() (after restart) will 
> > _not_ undo the changes originally done before the checkpoint.
> > 
> > This issue holds for ERESTARTSYS, ERESTARTNOHAND and ERESTART_RESTARTBLOCK.
> > 
> > Note that do_signal() after restart will not do the changes again either
> > in case of -ERESTART.... value, because the regs->svcnr was set to 0 and
> > recorded that way.
> > 
> > (b) Same, but also if the process didn't have a signal at checkpoint 
> > time, but will have one during/after restart but before resuming.
> > 
> > (c) Because do_restart() selects its return value from gprs[2] (upon 
> > successful completion), then when it tries to resume userspace and 
> > enters do_signal() it will have -EINTR (which isn't the original return 
> > value!), and therefore not set your new TIF_RESTARTBLOCK bit. If the task 
> > is now checkpointed again, that state will be lost.
> 
> Sorry if I'm misunderstanding what you're saying, but the return value
> after exiting sys_restart() won't be -EINTR now, bc my patch sets it to
> __NR_restart_syscall.

True ... but the consequences are the same:

Consider task A is checkpointed, then restarted, but before it completely
resumes userspace, it is checkpointed again. For the second checkpoint,
do_signal() will see svcnr==0, and even if you set svcnr, then gprs[2]>0.
Therefore, do_signal() will not set (again) the TIF_RESTARTBLOCK flag
because that happens only for svcnr!=0 and gprs[2]=-ERESTART_RESTARTBLOCK.

So the second checkpoint image lost that particular state you were 
interested. Therefore, when you restart from that image, the gprs[2] will
be set correctly (if ignoring issues a, b), but the TIF_RESTART_SVC won't
be set again.

> 
> > As a side note: I noticed that on x86 there are {checkpoint,restore}_thread() 
> > that save the thread flags and restore the necessary flags. They also 
> > check the flags - at checkpoint to ensure the task is checkpointable, and 
> > at restore for sanity.  Is there not a need for something similar for s390?
> > 
> > That would be an appropriate place to svae and restore a TIF_RESTARTBLOCK
> > thread flag and fix (c) above, should you stick to that method.
> 
> We actually want that flag cleared - the flag is only there so that
> checkpoint can tell that it needs to set the 'should_restart' flag in
> the thread info in the checkpoint image.  sys_estart does not then reset
> that flag, it instead does the steps which are done in the last block
> of do_signal(): set gprs[2] to NR_syscall_restart and add the TIF_RESTART_SVC
> thread flag.

The problem is that sys_restart *does not even set* that flag, and 
do_signal() will not set that flag either after restarting from a 
checkpoint that had should_restart set.  Therefore a subsequent checkpoint
that occurs _before_ the process really resumes to userspace will not 
carry that information.

Oren.
