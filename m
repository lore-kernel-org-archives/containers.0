From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 00/11 v5] cgroups: Task counter subsystem
Date: Tue, 13 Sep 2011 16:32:51 +0200
Message-ID: <1315924371.5977.16.camel@twins>
References: <1315869091-18933-1-git-send-email-fweisbec@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1315869091-18933-1-git-send-email-fweisbec@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Frederic Weisbecker <fweisbec@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Paul Menage <paul@paulmenage.org>, Li Zefan <lizf@cn.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Aditya Kali <adityakali@google.com>, Oleg Nesterov <oleg@redhat.com>, Kay Sievers <kay.sievers@vrfy.org>, Tim Hockin <thockin@hockin.org>, Tejun Heo <tj@kernel.org>, Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

On Tue, 2011-09-13 at 01:11 +0200, Frederic Weisbecker wrote:
>  kernel/cgroup_task_counter.c               |  239 ++++++++++++++++++++++++++++

Horrible name, since it does more than just count, it also limits the
number of tasks.
