From: Paul Jackson <pj@sgi.com>
Subject: Re: [RFC] cpuset update_cgroup_cpus_allowed
Date: Mon, 15 Oct 2007 19:32:59 -0700
Message-ID: <20071015193259.f9eb51b2.pj@sgi.com>
References: <20071015071115.16057.72116.sendpatchset@jackhammer.engr.sgi.com>
	<alpine.DEB.0.9999.0710151135150.24837@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763072AbXJPCdU@vger.kernel.org>
In-Reply-To: <alpine.DEB.0.9999.0710151135150.24837@chino.kir.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
To: David Rientjes <rientjes@google.com>
Cc: menage@google.com, nickpiggin@yahoo.com.au, a.p.zijlstra@chello.nl, balbir@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, clg@fr.ibm.com, ebiederm@xmission.com, containers@lists.osdl.org, serue@us.ibm.com, svaidy@linux.vnet.ibm.com, akpm@linux-foundation.org, xemul@openvz.org
List-Id: containers.vger.kernel.org

> Yet by not doing any locking here to prevent a cpu from being 
> hot-unplugged, you can race and allow the hot-unplug event to happen 
> before calling set_cpus_allowed().  That makes this entire function a 
> no-op with set_cpus_allowed() returning -EINVAL for every call, which 
> isn't caught, and no error is reported to userspace.

Good point ... hmmm ...

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401
