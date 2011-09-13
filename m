From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [PATCH 00/11 v5] cgroups: Task counter subsystem
Date: Tue, 13 Sep 2011 16:37:54 +0200
Message-ID: <20110913143749.GA23424@somewhere>
References: <1315869091-18933-1-git-send-email-fweisbec@gmail.com>
 <1315924371.5977.16.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1315924371.5977.16.camel@twins>
Sender: linux-kernel-owner@vger.kernel.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Paul Menage <paul@paulmenage.org>, Li Zefan <lizf@cn.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Aditya Kali <adityakali@google.com>, Oleg Nesterov <oleg@redhat.com>, Kay Sievers <kay.sievers@vrfy.org>, Tim Hockin <thockin@hockin.org>, Tejun Heo <tj@kernel.org>, Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

On Tue, Sep 13, 2011 at 04:32:51PM +0200, Peter Zijlstra wrote:
> On Tue, 2011-09-13 at 01:11 +0200, Frederic Weisbecker wrote:
> >  kernel/cgroup_task_counter.c               |  239 ++++++++++++++++++++++++++++
> 
> Horrible name, since it does more than just count, it also limits the
> number of tasks.

cgroup_task_count_limit.c ? ;)

Because cgroup_task_limit.c sounds way too much generic to be self-explanatory.

I believe a better thing would be to create kernel/cgroup/ and move things like
cgroup.c, cgroup_freezer.c (renamed into freezer.c in that directory)
and have task_count_limit.c inside.
