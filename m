From: Paul Jackson <pj@sgi.com>
Subject: Re: [RFC] cpuset update_cgroup_cpus_allowed
Date: Mon, 15 Oct 2007 22:20:17 -0700
Message-ID: <20071015222017.6e9e95a6.pj@sgi.com>
References: <20071015071115.16057.72116.sendpatchset@jackhammer.engr.sgi.com>
	<4713DA85.3020208@google.com>
	<20071015171636.6213bf43.pj@sgi.com>
	<471403BF.4090203@google.com>
	<20071015193439.fe67bc4d.pj@sgi.com>
	<6599ad830710152212n646bcepfdebaea0b7fb1678@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1766004AbXJPFUd@vger.kernel.org>
In-Reply-To: <6599ad830710152212n646bcepfdebaea0b7fb1678@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Menage <menage@google.com>
Cc: rientjes@google.com, nickpiggin@yahoo.com.au, a.p.zijlstra@chello.nl, balbir@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, clg@fr.ibm.com, ebiederm@xmission.com, containers@lists.osdl.org, serue@us.ibm.com, svaidy@linux.vnet.ibm.com, akpm@linux-foundation.org, xemul@openvz.org
List-Id: containers.vger.kernel.org

> Will do - I justed wanted to get this quickly out to show the idea
> that I was working on.

Ok - good.

In the final analysis, I'll take whatever works ;).

I'll lobby for keeping the code "simple" (a subjective metric) and poke
what holes I can in things, and propose what alternatives I can muster.

But so long as setting a cpusets 'cpus' in 2.6.24 leads, whether by my
historical "rewrite the pid to its own 'tasks' file" hack, or by a
proper solution such as you have advocated, or by some other scheme
or hack, to updating the cpus_allowed of each task in that cpuset, then
I'm ok.

Right now, that goal is not met, with the cgroup patches lined up in
*-mm for what will become 2.6.24.

We're getting short of time to fix this.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401
