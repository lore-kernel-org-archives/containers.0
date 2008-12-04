From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 3/3] ftrace: add ability to only trace swapper tasks
Date: Thu, 4 Dec 2008 09:06:29 +0100
Message-ID: <20081204080629.GB32594@elte.hu>
References: <20081204052638.425740534@goodmis.org> <20081204052735.362609481@goodmis.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754464AbYLDIHI@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081204052735.362609481@goodmis.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Steven Rostedt <rostedt@goodmis.org>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Frederic Weisbecker <fweisbec@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave@linux.vnet.ibm.com>, containers@lists.osdl.org, Eric Biederman <ebiederm@xmission.com>, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>, Steven Rostedt <srostedt@redhat.com>
List-Id: containers.vger.kernel.org


* Steven Rostedt <rostedt@goodmis.org> wrote:

> From: Steven Rostedt <srostedt@redhat.com>
> 
> Impact: New feature
> 
> This patch lets the swapper tasks of all CPUS be filtered by the
> set_ftrace_pid file.
> 
> If '0' is echoed into this file, then all the idle tasks (aka swapper)
> is flagged to be traced.  This affects all CPU idle tasks.
> 
> Signed-off-by: Steven Rostedt <srostedt@redhat.com>
> ---
>  kernel/trace/ftrace.c |   74 +++++++++++++++++++++++++++++++++++++++++-------
>  1 files changed, 63 insertions(+), 11 deletions(-)

okay, i've applied it - but i dont like the extra complexity of +50 lines 
at all.

This is an area where the 'PID namespaces via struct pid pointers' model 
breaks down and forces collateral complexity into other subsystems, and 
where a simple integer based filter is so intuitive.

Eric, can you see any way to simplify this? It looks horrible.

	Ingo
