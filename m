From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: Signals to cinit
Date: Wed, 12 Nov 2008 17:12:34 +0100
Message-ID: <20081112161234.GC13269@redhat.com>
References: <20081101180505.GA24268@us.ibm.com> <20081110173839.GA11121@redhat.com> <20081110193228.GA15519@redhat.com> <20081110232735.GA20891@us.ibm.com> <20081112145226.GA13269@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753523AbYKLPMl@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081112145226.GA13269@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: sukadev@linux.vnet.ibm.com
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Pavel Emelyanov <xemul@openvz.org>, daniel@hozac.com, Nadia Derbey <Nadia.Derbey@bull.net>, serue@us.ibm.com, clg@fr.ibm.com, Containers <containers@lists.osdl.org>, sukadev@us.ibm.com, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

On 11/12, Oleg Nesterov wrote:
>
> On 11/10, sukadev@linux.vnet.ibm.com wrote:
> >
> > Oleg Nesterov [oleg@redhat.com] wrote:
> > | > Or something. yes, sys_rt_sigqueueinfo() is problematic...
> >
> > Yes, if user-space sets si_pid to 0.
> >
> > Can we change sys_rt_sigqueueinfo() to:
> >
> > 	if (!info->si_pid)
> > 		info->si_pid = getpid();
>
> I doubt very much we can do this. This can break the existing applications
> which can overload ->si_pid. I think it is better to pass ->si_pid as is.
> If user-space sends siginfo_t so sub-namespace, it must know what it does.
> I don't think the kernel can help, it just can't know what ->si_pid actually
> means. Unless this is documented somewhere, but I don't know.

On the second thought, I think perhaps we should do the following.

if sys_rt_sigqueueinfo() sends the signal to the sub-namespace, then clear
always ->sid_pid. Otherwise do not touch it.

This way we can't break the existing apps, and this simplifies send_signal()
which should take "is_it_from_ancestor_ns" into account.

What do you think?

Oleg.
