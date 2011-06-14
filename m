From: Greg Kurz <gkurz-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] Introduce Vpid: in /proc/self/status
Date: Tue, 14 Jun 2011 18:38:46 +0200
Message-ID: <1308069526.3444.29.camel@bahia.local>
References: <20110610094646.29106.62700.stgit@bahia.local>
	<m139jf4yaf.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m139jf4yaf.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, legoater-GANU6spQydw@public.gmane.org
List-Id: containers.vger.kernel.org

On Sat, 2011-06-11 at 18:46 -0700, Eric W. Biederman wrote:
> Greg Kurz <gkurz-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> writes:
> 
> > Since pid namespaces were introduced, there's a recurring demand: how one
> > can correlate a pid from a child pid ns with a pid from a parent pid ns ?
> > The need arises in the LXC community when one wants to send a signal from
> > the host (aka. init_pid_ns context) to a container process for which one
> > only knows the pid inside the container.
> 

Eric,

Thanks for your comments.

> You are missing taking the sighand lock which is needed to make
> task_active_pid_ns safe when called on something other than current.
> 

Ohh... to prevent __exit_signal()->__unhash_process() to detach the pids
in our back, correct ? A comment in <linux/pid_namespace.h> would be
appreciated... 

> I really don't like the name VPid, perhaps Process Pid.  There is
> nothing more or less virtual about any pid, so calling any of the
> virtual is not clear, and misleading.
> 

Or 'Active Pid', since we're relying on task_active_pid_ns(). IOW the
output is what the process gets when calling getpid().

> I'm not exactly certain that /proc/self/status is the right place
> for this but this does seem reasonable.
> 

Well... I didn't want to add another file and status is the easier one
to patch without breaking anything. It seemed reasonable indeed.

> For what it's worth if you are communicating through anything except
> a pid file unix domain sockets will give you a race free to get the
> pid of the process on the other end.
> 

I'm in a pid file scenario for the moment... but this could change, so
I'll give a try to the SCM_CREDENTIALS stuff.

Cheers.

-- 
Gregory Kurz                                     gkurz-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org
Software Engineer @ IBM/Meiosys                  http://www.ibm.com
Tel +33 (0)534 638 479                           Fax +33 (0)561 400 420

"Anarchy is about taking complete responsibility for yourself."
        Alan Moore.
