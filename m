From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 2/5] pid: Generalize task_active_pid_ns
Date: Tue, 2 Dec 2008 23:41:03 -0800
Message-ID: <20081203074103.GA8487@us.ibm.com>
References: <20081126034242.GA23120@us.ibm.com> <20081126034528.GB23238@us.ibm.com> <20081127011738.GC13545@wavehammer.waldi.eu.org> <1227820765.5108.20.camel@bahia.kalilou.org> <20081201211518.GB15004@us.ibm.com> <20081202115729.GB1132@wavehammer.waldi.eu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755861AbYLCHls@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081202115729.GB1132@wavehammer.waldi.eu.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Bastian Blank <bastian@waldi.eu.org>, Greg Kurz <gkurz@fr.ibm.com>, linux-kernel@vger.kernel.org, oleg@redhat.com, ebiederm@xmission.com, containers@lists.osdl.org, roland@redhat.com
List-Id: containers.vger.kernel.org

Bastian Blank [bastian@waldi.eu.org] wrote:
| On Mon, Dec 01, 2008 at 01:15:18PM -0800, Sukadev Bhattiprolu wrote:
| > Greg Kurz [gkurz@fr.ibm.com] wrote:
| > | On Thu, 2008-11-27 at 02:17 +0100, Bastian Blank wrote:
| > | > On Tue, Nov 25, 2008 at 07:45:28PM -0800, Sukadev Bhattiprolu wrote:
| > | > > Currently task_active_pid_ns is not safe to call after a
| > | > > task becomes a zombie and exit_task_namespaces is called,
| > | > > as nsproxy becomes NULL.
| > | > Why do you need to be able to get the pid namespace from zombie
| > | > processes?
| > After exiting namespaces, the process notifies parent. With new changes
| > to signals (in this patchset), the signal code may need to determine
| > the namespace of sender (the exiting child in this case).
| 
| So the parent of a process with a new pid namespace will never get a
| SIGCHLD?

I am wondering what I said that leads to that conclusion :-) If parent
has a handler the handler will be called as usual otherwise SIGCHLD
will be ignored.

But anyway, an earlier version of my patches checked the pid namespace
sooner and so I had to generalize task_active_pid_ns().

With the present order of checks in siginfo_from_ancestor_ns(), we don't
need to generalize task_active_pid_ns(). SIG_FROM_USER flag will be clear
when do_notify_parent() calls send_signal().

IOW, while we should eventually generalize task_active_pid_ns(), it is
not required for this signals patchset and we can ignore patches 1 and 2
for now.

| 
| What I read in the kernel source (kernel/signal.c:do_notify_parent,
| include/asm-generic/siginfo.h:CLD_EXITED) is that the exit signals
| (SIGCHLD) are describes as sent by the kernel. 

Yes. Are you suggesting a check like

	if (!is_si_special(info) && !SI_FROMKERNEL(info)) ?
		/* must be from user, safe to check ns */

But SI_ASYNCIO comes from the driver - so its not safe to check pid ns.
(sent a separate query on SI_ASYNCIO).

| 
| > | I agree with Eric and Sukadev that task_active_pid_ns() is unsafe. There
| > | isn't even a /* don't use with zombies */ in pid_namespace.h...
| > Hmm. Its not unsafe at present. It would become unsafe if the signals code
| > tries to determine the namespace of sender.
| 
| Why? Even now it may be used on zombie tasks.

It used to be unsafe, and iirc was fixed a while ago(in part by moving
exit_task_namespaces() into exit_notify()).

Are you saying there is another path (outside these signals patches) where
task_active_pid_ns() is called for zombies ?
