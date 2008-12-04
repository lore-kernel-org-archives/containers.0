From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 0/3] ftrace: clean ups for tip
Date: Thu, 4 Dec 2008 09:10:08 +0100
Message-ID: <20081204081008.GC32594@elte.hu>
References: <20081204052638.425740534@goodmis.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753532AbYLDIKn@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081204052638.425740534@goodmis.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Steven Rostedt <rostedt@goodmis.org>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Frederic Weisbecker <fweisbec@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave@linux.vnet.ibm.com>, containers@lists.osdl.org, Eric Biederman <ebiederm@xmission.com>, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>
List-Id: containers.vger.kernel.org


* Steven Rostedt <rostedt@goodmis.org> wrote:

> Ingo,
> 
> The following patches are to have ftrace use the pid struct
> for filtering on pids.
> 
> The following patches are in:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/rostedt/linux-2.6-trace.git
> 
>     branch: tip/devel
> 
> 
> Steven Rostedt (3):
>       fix the do_each_pid_task macro
>       ftrace: use struct pid
>       ftrace: add ability to only trace swapper tasks
> 
> ----
>  include/linux/pid.h   |    4 +-
>  kernel/trace/ftrace.c |  128 ++++++++++++++++++++++++++++++++++++------------
>  kernel/trace/trace.h  |    4 +-
>  3 files changed, 100 insertions(+), 36 deletions(-)

pulled, thanks Steve!

	Ingo
