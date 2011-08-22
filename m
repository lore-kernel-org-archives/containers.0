From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [PATCH 0/2] Send a SIGCHLD to the init's pid namespace parent
	when reboot
Date: Mon, 22 Aug 2011 14:28:35 +0200
Message-ID: <4E524B73.3050704__3131.89765806801$1314016218$gmane$org@free.fr>
References: <1313094241-3674-1-git-send-email-daniel.lezcano@free.fr>
	<20110814161707.GB30846@redhat.com>
	<20110814213642.GB13799@hallyn.com>
	<20110815144744.GA9660@redhat.com> <4E4DA461.8030006@free.fr>
	<20110819152416.GA17034@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110819152416.GA17034-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, bonbons-ud5FBsm0p/xEiooADzr8i9i2O/JbrIOy@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 08/19/2011 05:24 PM, Oleg Nesterov wrote:
> On 08/19, Daniel Lezcano wrote:
>> On 08/15/2011 04:47 PM, Oleg Nesterov wrote:
>>> 	- sys_reboot(cmd) does
>>>
>>> 		if (!global_namespace) {
>>> 			task_active_pid_ns(current)->reboot_cmd = cmd;
>>> 			sigkill_my_init();
>>> 		}
>> Hi Oleg,
>>
>> what would be your advice to get rid of from_ancestor_ns which prevent
>> the signal to be delivered to the init process ?
> Sure, a plain kill can't work. You can do force_sig_info(), this clears
> SIGNAL_UNKILLABLE.
>
> Hmm. But now I seem to recall we have other reasons to make the new
> sigkill_task() helper... We will see. Anyway, force_ should work afaics.

Thanks Oleg.

I wrote the patch by sending a signal to the init process of the pid
namespace using force_sig_info.
That works fine, thanks for the hint.

I am wondering what is the best way to transmit the reason of the reboot
to the parent of the container's init.

If we pass the reason to the exit_code of the init process, that will be
a bit weird as the process is signaled and did not exited  no ?
Furthermore, how to differentiate an application container (eg. a
script) exiting with an error with the same value of a reboot reason ?

Wouldn't make sense to let the user to specify a signal via prctl where
the si_code is filled with the reason ?

Without invoking the prctl, the init process is simply killed by the
kernel, otherwise we send the signal to the container's init.

From userspace:

void sigreboot(int sig, siginfo_t *si, void *private)
{
    switch(si->si_code) {
       case LINUX_REBOOT_CMD_RESTART:
        reboot_container();
        break;

      case LINUX_REBOOT_CMD_HALT:
        halt_container();
        break;

     ...
    }
}

  struct sigaction sa = {
    .sa_sigaction = sigreboot,
    .sa_flags =  SA_SIGINFO;  
 }
 
 sigaction(SIGUSR1, &sa, NULL);

 prctl(PR_SIGREBOOT, SIGUSR1);

 -----

 and from the kernel (called from sys_reboot):

 int kill_pid_ns(struct pid_namespace *pid_ns, int reason)
{
        struct task_struct *tsk;
        struct siginfo info;

        if (pid_ns->notifier) {

                         info.si_signo = SIGKILL;
                         info.si_errno = 0;
                         info.si_code = reason;
                         info.si_pid = 0;
                         info.si_uid = 0;

                         return force_sig_info(notifier->sig, &info,
notifier->tsk);
        }

        write_lock_irq(&tasklist_lock);
        tsk = pid_ns->child_reaper;
        write_unlock_irq(&tasklist_lock);

        info.si_signo = SIGKILL;
        info.si_errno = 0;
        info.si_code = SI_KERNEL;
        info.si_pid = 0;
        info.si_uid = 0;

        return force_sig_info(SIGKILL, &info, tsk);
}

Roughly, assuming pid_ns->notifier is reseted when we reparent to the
init_pid_ns.init.

What do you think ?

Thanks
  -- Daniel
