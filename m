From: "Banerjee,
	Debabrata via Containers" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Subject: RE: [PATCH] Fix /proc/[pid]/ns permissions
Date: Mon, 9 Apr 2018 22:33:37 +0000
Message-ID: <84eac68c566948ce8939351b6c249343__30500.2087531195$1523313124$gmane$org@usma1ex-dag1mb2.msg.corp.akamai.com>
References: <20180405171502.14347-1-dbanerje@akamai.com>
	<31CF3F25-8A82-426B-BFA0-6225C39334F5@akamai.com>
	<87h8op79ac.fsf@xmission.com>
Reply-To: "Banerjee, Debabrata" <dbanerje-JqFfY2XvxFXQT0dZR+AlfA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87h8op79ac.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Content-Language: en-US
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "'Eric W. Biederman'" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
List-Id: containers.vger.kernel.org

> From: Eric W. Biederman [mailto:ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org]
>
> I agree there is an inconsistency on the directory permissions for the ns
> directory that could reasonably be fixed.

So you'd recommend taking this patch as-is?

> prctl(PR_SET_DUMPABLE, 0) is an interesting.  Fundamentally it is about not
> letting unprivileged tasks poke about with the process, and it is the
> mechanism used by setuid/setgid exec.   If you are root in the user
> namespace of the task or your uid created the user namespace or an
> ancestor user namespace you should be able to inspect the process.
> 
> What happens with dumpable is also going to vary a little bit depending on
> how recent your kernel is.  The dumpable status was not really namespaced
> until recently.
> 
> There might also be some issues from yama or other lsms that love to limit
> ptrace.  Though it sounds like your issue is the dumpability.
> 
> The check "ptrace_may_access(task, PTRACE_MODE_READ_FSCREDS)" is the
> standard check for accessing anything even a little bit sensitive of a process,
> and that seems appropriate here.

Why is the namespace inode # secret? If it is because it's an inode, perhaps there is a better way to represent the namespace that is not secret? What we are trying to do is check if link points to the same place as our namespace, the contents don't matter. On the other hand it would be very convenient if pid's not in your namespace, even from a parent namespace, did not appear. That would make user tools work properly without workarounds, i.e. killall, pgrep, ps, top.
