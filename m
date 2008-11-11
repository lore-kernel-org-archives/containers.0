From: sukadev@linux.vnet.ibm.com
Subject: Re: Signals to cinit
Date: Mon, 10 Nov 2008 18:24:05 -0800
Message-ID: <20081111022405.GB20891@us.ibm.com>
References: <20081101180505.GA24268@us.ibm.com> <20081110173839.GA11121@redhat.com> <20081110193228.GA15519@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754818AbYKKC0g@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081110193228.GA15519@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Pavel Emelyanov <xemul@openvz.org>, daniel@hozac.com, Nadia Derbey <Nadia.Derbey@bull.net>, serue@us.ibm.com, clg@fr.ibm.com, Containers <containers@lists.osdl.org>, sukadev@us.ibm.com, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

Oleg Nesterov [oleg@redhat.com] wrote:
| (lkml cced because containers list's archive is not useable)
| 
| On 11/10, Oleg Nesterov wrote:
| >
| > On 11/01, sukadev@linux.vnet.ibm.com wrote:
| > >
| > > Other approaches to try ?
| >
| > I think we should try to do something simple, even if not perfect. Because
| > most users do not care about this problem since they do not use containers
| > at all. It would be very sad to add intrusive changes to the code.
| >
| > I think we should fix another problem first. send_signal()->copy_siginfo()
| > path must be changed anyway, when the signal comes from the parent ns we
| > report the "wrong" si_code/si_pid, yes? So, somehow send_signal() must
| > have "bool from_parent_ns" (or whatever) annyway.

Yes, this was in both the patchsets we reviewed last year :-) I can send
this fix out independently.

| >
| > Now, let's forget forget for a moment that send_signal()->__sigqueue_alloc()
| > can fail.
| >
| > I think we should encode this "from_parent_ns" into "struct siginfo". I do
| > not think it is good idea to extend this structure, I think we can introduce
| > SI_FROM_PARENT_NS or we perhaps can use "SI_FROMUSER(info) && info->si_pid == 0".
| > Or something. yes, sys_rt_sigqueueinfo() is problematic...

Also, what happens if a fatal signal is first received from a descendant 
and while that is still pending, the same signal is received from ancestor
ns ?  Won't the second one be ignored by legacy_queue() for the non-rt case ?

Of course, this is a new scenario, specific to containers, and we may be
able to define the policy without changing semantics.
