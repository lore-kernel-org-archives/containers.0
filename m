From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 3/5] Determine if sender is from ancestor ns
Date: Mon, 1 Dec 2008 12:15:06 -0800
Message-ID: <20081201201506.GB12493@us.ibm.com>
References: <20081126034242.GA23120@us.ibm.com> <20081126034611.GC23238@us.ibm.com> <20081127010101.GA13545@wavehammer.waldi.eu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754074AbYLAUP5@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081127010101.GA13545@wavehammer.waldi.eu.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Bastian Blank <bastian@waldi.eu.org>, oleg@redhat.com, ebiederm@xmission.com, roland@redhat.com, containers@lists.osdl.org, linux-kernel@vger.kernel.org, xemul@openvz.org
List-Id: containers.vger.kernel.org

Bastian Blank [bastian@waldi.eu.org] wrote:
| On Tue, Nov 25, 2008 at 07:46:11PM -0800, Sukadev Bhattiprolu wrote:
| > +#ifdef CONFIG_PID_NS
| > +#define SIG_FROM_USER  INT_MIN         /* MSB */
| 
| Is it really a wise idea to mix this into the signal number?

We have been trying to make this least intrusive and iiuc, extending
siginfo_t is not easy.

| Also this definition looks odd. If you want the highest bit, you should
| mention this explicitely with 1U<<31.

I think that should be fine.

| 
| If I see this correctly this information is already covered in si_code
| with SI_USER and SI_TKILL. SI_KERNEL is used for explicit kernel
| generated signals.

Yes, but si_code from sys_rt_sigqueueinfo() cannot be trusted.  To be sure
we would have to check for "si_code < 0", but that would include cases like
SI_ASYNCIO which can come from interrupt/work-queues. which would require
more complex checks to safely compute namespace of sender.

IOW, we need to find the namespace of the sender only if the sender is
a user process. If signal is originating from kernel, safely checking
namespace becomes more complex.

Yes, current approach is somewhat hacky. We tried other approaches
before and they were either intrusive or required non-trivial changes
to semantics of signals to global init or both.

| 
| > +static inline int siginfo_from_ancestor_ns(struct task_struct *t,
| > +			siginfo_t *info)
| > +{
| > +	if (!is_si_special(info) && (info->si_signo & SIG_FROM_USER)) {
| > +		/* if t can't see us we are from parent ns */
| 
| What?

I assume your question is about the comment :-)

Yes, a process can see all its descendants and processes in descendant
namespaces. But it can only see its ancestors upto the most recent
CLONE_NEWPID. (kind of like chroot in filesystems). So if receiver
can't see sender, sender must be an ancestor.

| 
| >  static int send_signal(int sig, struct siginfo *info, struct task_struct *t,
| >  			int group)
| >  {
| >  	struct sigpending *pending;
| >  	struct sigqueue *q;
| > +	int from_ancestor_ns;
| >  
| >  	trace_sched_signal_send(sig, t);
| >  
| > +	from_ancestor_ns = siginfo_from_ancestor_ns(t, info);
| > +
| 
| This is not used at all here?

Yes, its used in next patch.
