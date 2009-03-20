From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 1/1] introduce user_ns inheritance in user-sched
Date: Fri, 20 Mar 2009 09:24:20 +0100
Message-ID: <1237537460.24626.32.camel@twins>
References: <20090319211615.GA18383@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755593AbZCTIZj@vger.kernel.org>
In-Reply-To: <20090319211615.GA18383@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: lkml <linux-kernel@vger.kernel.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, mingo@elte.hu, Bharata B Rao <bharata@linux.vnet.ibm.com>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

On Thu, 2009-03-19 at 16:16 -0500, Serge E. Hallyn wrote:
> In a kernel compiled with CONFIG_USER_SCHED=y, cpu shares are
> allocated according to uid.  Shares are specifiable under
> /sys/kernel/uids/<uid>/
> 
> In a kernel compiled with CONFIG_USER_NS=y, clone(2) with the
> CLONE_NEWUSER flag creates a new user namespace, and the newly
> cloned task will belong to uid 0 in the new user namespace.

We seem to be adding more and more stuff for USER_SCHED, is anybody
actually using that cruft?

How far along with cgroups are we to fully simulate that behaviour?

I think if we have a capable cgroup based replacement for USER_SCHED we
should axe it from the kernel, would save lots of code...
