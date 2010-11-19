From: Serge Hallyn <serge.hallyn@canonical.com>
Subject: Re: [Ksummit-2010-discuss] checkpoint-restart: naked patch
Date: Thu, 18 Nov 2010 21:54:03 -0600
Message-ID: <20101119035403.GA24031@hallyn.com>
References: <20101106053204.GB12449@count0.beaverton.ibm.com>
 <20101106204008.GA31077@sundance.ccs.neu.edu>
 <4CD5D99A.8000402@cs.columbia.edu>
 <20101107184927.GF31077@sundance.ccs.neu.edu>
 <4CD72150.9070705@cs.columbia.edu>
 <4CE3C334.9080401@kernel.org>
 <20101117153902.GA1155@hallyn.com>
 <4CE3F8D1.10003@kernel.org>
 <4CE4EE21.6050305@parallels.com>
 <4CE4F672.1030904@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4CE4F672.1030904@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Cc: Pavel Emelyanov <xemul@parallels.com>, Kapil Arya <kapil@ccs.neu.edu>, Gene Cooperman <gene@ccs.neu.edu>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Quoting Tejun Heo (tj@kernel.org):
> * And, most of all, there are userland implementation and
>   virtualization, making the benefit to overhead ratio completely off.
>   Userland implementation _already_ achieves most of what's necessary

Guess I'll just be offensive here and say, straight-out:  I don't
believe it.  Can I see the userspace implementation of c/r?

If it's as good as the kernel level c/r, then aweseome - we don't
need the kernel patches.

If it's not as good, then the thing is, we're not drawing arbitrary
lines saying "is this good enough", rather we want completely
reliable and transparent c/r.  IOW, the running task and the other
end can't tell that a migration happened, and, if checkpoint says
it worked, then restart must succeed.

-serge
