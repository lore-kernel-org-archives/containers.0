From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 1/1] cr: fix compilation with CONFIG_UTS_NS=n
Date: Fri, 19 Jun 2009 00:06:19 -0400
Message-ID: <4A3B0EBB.3020408@cs.columbia.edu>
References: <20090617001723.GA9452@us.ibm.com>
	<4A3A6F61.5030401@cs.columbia.edu> <m3ws79h01p.fsf@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m3ws79h01p.fsf-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org



Nathan Lynch wrote:
> Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> writes:
> 
>> I think it's useful to be able to
>>
>> 1) checkpoint on a system with !CONFIG_UTS_NS,  and -
>> 2) checkpoint on a system with CONFIG_UTS_NS and restart on a
>> system with !CONFIG_UTS_NS (as long as all tasks in the image
>> share a single uts-ns)
> 
> In principle I agree, but what confidence can we have that meaningful
> testing of such configurations (especially #2) will occur?
> 

Given that the code works well with namespaces configured, what
does it take to allow #1 and #2 ?

#1 - Nothing. It can come for free in terms of extra code; Only
ensure that the code compiles (e.g. placing elsewhere).

#2 - It means that:
  (a) Fail if original checkpoint had more than one instance of
      a given namespace (i.e. not all tasks share the same namespace).
  (b) In restore_xxxx_ns(), don't create new namespace, but return
      a reference to the current one.
  (c) Don't restore "global" settings of the namespace (like UTS
      data, IPC knobs) - just consume that data from the input.


> Flexibility is good, but the complexity involved in properly supporting
> checkpoint with all possible combinations of CONFIG_*_NS seems daunting.
> Just consider the build matrix (assuming CONFIG_CHECKPOINT=y):
> 
> +------ CONFIG_CGROUP_NS

This option seems to be under extinction...

> |+----- CONFIG_UTS_NS
> ||+---- CONFIG_IPC_NS
> |||+--- CONFIG_NET_NS

These three options are entirely independent in meaning and in code.
Testing CONFIG_UTS_NS and !CONFIG_UTS_NS is self-sufficient, and
should not(*) affect or be affected by the others.

(*) "Should" - this very statement may require validation.

> ||||+-- CONFIG_USER_NS

I'm tempted to argue that this, too, can be tested independently
of the others.

> |||||+- CONFIG_PID_NS

Need not be tested: no special action for #1, and #2 will simply
fail in user space attempting to create the tasks hierarchy.

> nnnnnn
> ynnnnn
> yynnnn
> yyynnn
> yyyynn
> yyyyyn
> ....
> nynnnn
> nyynnn
> nyyynn
> nyyyyn
> nyyyyy
> ...
> 
> You get the idea, I'm sure: at least 64 distinct build configurations
> that are salient to checkpoint.  Is anybody building even a fraction of
> those?
> 
> Add actual runtime testing of C/R to that workload and it quickly
> becomes impractical to achieve decent test coverage.  And accommodating
> C/R between kernels with different CONFIG_*_NS settings introduces a
> combinatorial explosion of scenarios to test.
> 
> CONFIG_CHECKPOINT should just depend on all of CONFIG_*_NS.  Otherwise
> we're going to have an abundance of corner cases at build time and (more
> importantly) run time that never get exercised.
> 

IMHO testing N cases (N is number of namespaces) - each test will
"checkpoint on CONFIG_xxx_NS and restart on !CONFIG_xxx_NS" will
suffice to provide a high level of confidence (see * above).

The alleviate the complexity and cost of testing, we can add a knob
that will tell the c/r code to run as if !CONFIG_xxx_NS, so for a
runtime test no need to compile x2 and then repeat "boot -> checkpoint
-> boot -> restart", but instead compile x1 and boot, and then repeat
"unset knob -> checkpoint -> set knob -> restart".

Oren.
