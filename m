From: Paul Jackson <pj@sgi.com>
Subject: Re: [RFC] cpuset update_cgroup_cpus_allowed
Date: Mon, 15 Oct 2007 23:07:29 -0700
Message-ID: <20071015230729.53fcbaf7.pj@sgi.com>
References: <20071015071115.16057.72116.sendpatchset@jackhammer.engr.sgi.com>
	<alpine.DEB.0.9999.0710151135150.24837@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932521AbXJPGHr@vger.kernel.org>
In-Reply-To: <alpine.DEB.0.9999.0710151135150.24837@chino.kir.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
To: David Rientjes <rientjes@google.com>
Cc: menage@google.com, nickpiggin@yahoo.com.au, a.p.zijlstra@chello.nl, balbir@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, clg@fr.ibm.com, ebiederm@xmission.com, containers@lists.osdl.org, serue@us.ibm.com, svaidy@linux.vnet.ibm.com, akpm@linux-foundation.org, xemul@openvz.org
List-Id: containers.vger.kernel.org

> > +			if (cpus_equal(*cpus, t->cpus_allowed))
> > +				continue;
> > ...
> > +		for (q = tasks; q < p; q++) {
> > +			set_cpus_allowed(*q, *cpus);
> > +			put_task_struct(*q);
> > +		}
> > +	}
> > +}
> 
> Yet by not doing any locking here to prevent a cpu from being 
> hot-unplugged, you can race and allow the hot-unplug event to happen 
> before calling set_cpus_allowed().  That makes this entire function a 
> no-op with set_cpus_allowed() returning -EINVAL for every call, which 
> isn't caught, and no error is reported to userspace.
> 
> Now all the tasks in the cpuset have an inconsistent state with respect to 
> their p->cpuset->cpus_allowed, because that was already updated in 
> update_cpumask().

My solution may be worse than that.  Because set_cpus_allowed() will
fail if asked to set a non-overlapping cpumask, my solution could never
terminate.  If asked to set a cpusets cpus to something that went off
line right then, this I'd guess this code could keep looping forever,
looking for cpumasks that didn't match, and then not noticing that it
was failing to set them so as they would match.

... it needs work ... or the alternative solution from Paul M.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401
