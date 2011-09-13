From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 00/11 v5] cgroups: Task counter subsystem
Date: Tue, 13 Sep 2011 16:49:20 +0200
Message-ID: <1315925360.5977.17.camel@twins>
References: <1315869091-18933-1-git-send-email-fweisbec@gmail.com>
	 <1315924371.5977.16.camel@twins> <20110913143749.GA23424@somewhere>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110913143749.GA23424@somewhere>
Sender: linux-kernel-owner@vger.kernel.org
To: Frederic Weisbecker <fweisbec@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Paul Menage <paul@paulmenage.org>, Li Zefan <lizf@cn.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Aditya Kali <adityakali@google.com>, Oleg Nesterov <oleg@redhat.com>, Kay Sievers <kay.sievers@vrfy.org>, Tim Hockin <thockin@hockin.org>, Tejun Heo <tj@kernel.org>, Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

On Tue, 2011-09-13 at 16:37 +0200, Frederic Weisbecker wrote:
> Because cgroup_task_limit.c sounds way too much generic to be
> self-explanatory.

Uhm, why? That's exactly what it does, no? It limits the number of
tasks.
