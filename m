From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [PATCH 00/11 v5] cgroups: Task counter subsystem
Date: Tue, 13 Sep 2011 17:21:56 +0200
Message-ID: <20110913152153.GD23424@somewhere>
References: <1315869091-18933-1-git-send-email-fweisbec@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1315869091-18933-1-git-send-email-fweisbec@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Paul Menage <paul@paulmenage.org>, Li Zefan <lizf@cn.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Aditya Kali <adityakali@google.com>, Oleg Nesterov <oleg@redhat.com>, Kay Sievers <kay.sievers@vrfy.org>, Tim Hockin <thockin@hockin.org>, Tejun Heo <tj@kernel.org>, Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

On Tue, Sep 13, 2011 at 01:11:20AM +0200, Frederic Weisbecker wrote:
> No functional changes. Only documentation and comments added.
> Checkpatch.pl fixes, etc...
> 
> This mostly addresses Andrew's reviews on v4.
> 
> Changes in v5:
> 
> - commented res_counter_common_ancestor (patch 6)
> - commented res_counter_inherit (patch 2)
> - merged documentation and task counter subsystem patch (patch 9)
> - rename cgroup_task_counter_res in cgroup_task_res_counter (patch 9)
> - more comments/ fix comments in cgroup_task_counter.c (patch 9)
> - document res_counter_charge return value (patch 8)
> - document res_counter_charge_until (patch 5)
> - more comment in kconfig help (patch 9)
> - fix various checkpatch reported issues

There is a test tool that you can download there:

https://tglx.de/~fweisbec/task_counter_test.tar.gz

It tests various things to ensure the subsystem behaves
as expected:

- correct tasks.usage value when tasks are moved around
- correct fork and cgroup migration rejects if limit
is reached
- correct propagation of limit to parents
- correct protection against forkbombs
- test killing of tasks in a cgroup
- ...
