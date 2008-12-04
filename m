From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 0/3] ftrace: updates for tip
Date: Thu, 4 Dec 2008 09:35:07 +0100
Message-ID: <20081204083507.GE32594@elte.hu>
References: <20081203203656.776893226@goodmis.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755959AbYLDIfj@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081203203656.776893226@goodmis.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Steven Rostedt <rostedt@goodmis.org>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Frederic Weisbecker <fweisbec@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Arjan van de Ven <arjan@infradead.org>, Dave Hansen <dave@linux.vnet.ibm.com>, containers@lists.osdl.org, Eric Biederman <ebiederm@xmission.com>, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>
List-Id: containers.vger.kernel.org


* Steven Rostedt <rostedt@goodmis.org> wrote:

> Ingo,
> 
> This series has three patches.
> 
> The first patch adds a new feature that I've been wanting to have for 
> some time and Arjan even requested. That is to pick a function and only 
> trace that function and its children. Dynamic ftrace and function graph 
> needs to be enabled for this.
> 
> To do the above, I added a "trace" flags field in the task structure. 
> The second patch uses this for the ftrace pid code. It searches for the 
> task based on the pid and sets the trace flag, then in the ftrace 
> function caller it only needs to check this flag.

Btw., i'd love to see this done via the regular regexp interface though, 
if possible - instead of the add-on interface you added.

( Also perhaps enable to toggle tracing via the /proc/<PID>/ hierarchy - 
  a /proc/<PID>/tracing_enabled switch or so. )

Regarding the filter functions, the basic principle should be 
mathematical set operations, like we have it now: add and remove, union, 
wildcards, etc.

I'd suggest a natural and intuitive extension of the current syntax. 
(while keeping all the current bits)

I already suggested a 'inverse' filter in a previous mail:

  echo "-schedule*" >> set_ftrace_filter

This rule operates on the current set of filter functions: it strikes out 
all existing filter functions that match this pattern.

To handle PIDs, we could do something like:

  echo "sshd-312:schedule" > set_ftrace_filter

This would restrict tracing to the sshd-pid:312 task.

Note: the PID portion of the filter rules still stay separate from the 
function names - we dont want per task function filter rules.

A natural variation would be:

  echo "312:schedule" > set_ftrace_filter

to only specify the PID, or:

  echo "312,313:schedule" > set_ftrace_filter

to specify two PIDs, or:

  echo "sshd:schedule" > set_ftrace_filter

to only specify the 'comm' part, which expands to all PIDs where 
task->comm matches sshd. Another variation would be:

  echo "loop*:schedule" > set_ftrace_filter

that matches all PIDs where task->comm matches loop*.

To specify recursive tracing, we could use something like:

  echo "loop*+schedule" > set_ftrace_filter

the '+' would signal that the 'schedule' function is 'expanded' and all 
its child functions are traced as well.

btw., maybe it makes sense to separate the regexp rule-set from the set 
of functions that we are tracing right now. For example:

  $ echo "schedule*" >  set_ftrace_filter
  $ echo "time*"     >> set_ftrace_filter
  $ echo "sys_*"     >> set_ftrace_filter

  $ cat set_ftrace_filter
  schedule*
  time*
  sys_*

We'd also have a separate, current_ftrace_functions file as well which 
shows all traced functions. (on a global basis - with possible PID filter 
rules added where applicable)

I know this will be hellishly hard to implement, but it would be _very_ 
elegant, and _very_ usable.

What do you think?

	Ingo
