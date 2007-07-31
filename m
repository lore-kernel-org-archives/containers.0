From: Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
Subject: Re: [PATCH 15/15] Hooks over the code to show correct values to user
Date: Tue, 31 Jul 2007 14:04:20 +0400
Message-ID: <20070731100420.GA142@tv-sign.ru>
References: <46A8B37B.6050108@openvz.org> <46A8B6AD.4000307@openvz.org>
	<20070729143136.GH120@tv-sign.ru> <46AD89E6.1030607@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <46AD89E6.1030607-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On 07/30, Pavel Emelyanov wrote:
>
> Oleg Nesterov wrote:
> >On 07/26, Pavel Emelyanov wrote:
> >>int
> >>kill_proc(pid_t pid, int sig, int priv)
> >>{
> >>-	return kill_proc_info(sig, __si_special(priv), pid);
> >>+	int ret;
> >>+
> >>+	rcu_read_lock();
> >>+	ret = kill_pid_info(sig, __si_special(priv), find_pid(pid));
> >>+	rcu_read_unlock();
> >>+	return ret;
> >>}
> >
> >I think this is wrong. kill_proc() should behave the same as 
> >kill_proc_info(),
> >so this change is not needed. With this patch they use different namespaces
> >to find the task, this is not consistent.
> 
> Actually, callers of this use tsk->pid (global pid) as an argument, so
> find_vpid() might return wrong value.

Yes I see. But still I don't agree on this issue.

kill_proc() is a simple wrapper on top of kill_proc_info(), not good
to break this. And with this patch they use different namespaces to
search the pid. Imho, not consistent.

Probably we can ignore this for now, but suppose we have some out-of-tree
driver which does kill_proc(pid_number), and the application from non-init
namespace does ioctl(SET_PID_NUMBER, getpid()).

And this is why btw I think find_pid/pid_nr should use active namespace, not
init_pid_ns. That driver can save "struct task_struct*" or "struct pid*".

OK, I understand it is a pain to "fix" the in-tree callers of kill_proc()
(say, we can introduce kill_pid_t() or something), so let's forget this.
In fact, we'd better remove kill_proc(), we should avoid using pid_t, the
callers should be converted to use struct pid.

Oleg.
