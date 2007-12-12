From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 5/9] pid: Update pid_vnr to use task_active_pid_ns
Date: Wed, 12 Dec 2007 07:20:19 -0700
Message-ID: <m17ijkuh98.fsf@ebiederm.dsl.xmission.com>
References: <m13au8ytos.fsf@ebiederm.dsl.xmission.com>
	<m1y7c0xezt.fsf@ebiederm.dsl.xmission.com>
	<m1tzmoxexb.fsf_-_@ebiederm.dsl.xmission.com>
	<m1prxcxeum.fsf_-_@ebiederm.dsl.xmission.com>
	<m1lk80xeps.fsf_-_@ebiederm.dsl.xmission.com>
	<m1hcioxenh.fsf_-_@ebiederm.dsl.xmission.com>
	<475FE201.7060104@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <475FE201.7060104-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> (Pavel Emelyanov's message of "Wed,
	12 Dec 2007 16:28:33 +0300")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
List-Id: containers.vger.kernel.org

> NAK. Your version will make more dereferences and one
> condition check (if (pid != NULL)). Besides, dead process
> can never call this thing - it is even never scheduled 
> for execution.

Andrew please disregard this patch, it should not affect
the rest of the patch series.



Well EXIT_ZOMBIE is enough to cause us problems, not EXIT_DEAD,
so we can be scheduled.

Still we don't have any users currently and I actually don't expect us
to develop any, so this patch was just overkill right now. 

I was thinking that there was a path to send_signal when
we were zombie with SEND_SIG_NOINFO, but that doesn't seem
to exist, and if there isn't one now we aren't likely
to grow one, and my signal patches remove the possibility
of that path being a problem.

Hmm.  As to the cost argument.
Both pid->level and pid->numbers[pid->level].ns should be
on the same cache line so it should not be any real
extra memory reads.  The branch should be predicted not
to happen so again it should not have a cost except a small
bit of code size.

So while I don't expect any real world cost this is the
common case so we don't want to put to many hoops in our
way either.

Eric
