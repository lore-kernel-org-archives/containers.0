From: Balaji Rao <balajirrao@gmail.com>
Subject: Re: [RFC][-mm] Simple stats for cpu resource controller v3
Date: Sat, 3 May 2008 01:10:28 +0530
Message-ID: <200805030110.29511.balajirrao@gmail.com>
References: <200804052339.46632.balajirrao@gmail.com> <200805012311.06797.balajirrao@gmail.com> <20080501140026.6188065e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S936065AbYEBTkv@vger.kernel.org>
In-Reply-To: <20080501140026.6188065e.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: dhaval@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, containers@lists.osdl.org, menage@google.com, balbir@in.ibm.com, vatsa@linux.vnet.ibm.com, a.p.zijlstra@chello.nl
List-Id: containers.vger.kernel.org

On Friday 02 May 2008 02:30:26 am Andrew Morton wrote:
<snip>

Hi Andrew,

Thank you for the review.
>
> Did you consider using include/linux/percpu_counter.h?
>
> If so, what was wrong with it?
>
> Because it would be much better to fix per-cpu counters than to invent new
> stuff.
No, I hadn't consider using the percpu_counters infrastructure. But today when 
I tried using it, I got an early exception.I guess its because I tried 
calling percpu_counter_init from within sched_init, which I perhaps shouldn't 
do, because percpu_counter_init expects cpu hotplug code to be initialized by 
then. Right ? Correct me if I'm wrong.

How about we start collecting statistics at a later stage i.e, after 
percpu_counter becomes usable ?

-- 
Warm Regards,

Balaji Rao
Dept. of Mechanical Engineering
NITK
