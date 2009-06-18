From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/1] cr: fix compilation with CONFIG_UTS_NS=n
Date: Thu, 18 Jun 2009 13:25:06 -0500
Message-ID: <m3ws79h01p.fsf@pobox.com>
References: <20090617001723.GA9452@us.ibm.com>
	<4A3A6F61.5030401@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A3A6F61.5030401-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> (Oren Laadan's message of
	"Thu\, 18 Jun 2009 12\:46\:25 -0400")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> writes:

> I think it's useful to be able to
>
> 1) checkpoint on a system with !CONFIG_UTS_NS,  and -
> 2) checkpoint on a system with CONFIG_UTS_NS and restart on a
> system with !CONFIG_UTS_NS (as long as all tasks in the image
> share a single uts-ns)

In principle I agree, but what confidence can we have that meaningful
testing of such configurations (especially #2) will occur?

Flexibility is good, but the complexity involved in properly supporting
checkpoint with all possible combinations of CONFIG_*_NS seems daunting.
Just consider the build matrix (assuming CONFIG_CHECKPOINT=y):

+------ CONFIG_CGROUP_NS
|+----- CONFIG_UTS_NS
||+---- CONFIG_IPC_NS
|||+--- CONFIG_NET_NS
||||+-- CONFIG_USER_NS
|||||+- CONFIG_PID_NS
nnnnnn
ynnnnn
yynnnn
yyynnn
yyyynn
yyyyyn
....
nynnnn
nyynnn
nyyynn
nyyyyn
nyyyyy
...

You get the idea, I'm sure: at least 64 distinct build configurations
that are salient to checkpoint.  Is anybody building even a fraction of
those?

Add actual runtime testing of C/R to that workload and it quickly
becomes impractical to achieve decent test coverage.  And accommodating
C/R between kernels with different CONFIG_*_NS settings introduces a
combinatorial explosion of scenarios to test.

CONFIG_CHECKPOINT should just depend on all of CONFIG_*_NS.  Otherwise
we're going to have an abundance of corner cases at build time and (more
importantly) run time that never get exercised.
