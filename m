From: Rob Landley <rob-VoJi6FS/r0vR7s880joybQ@public.gmane.org>
Subject: Re: [PATCH 11/11] pidns: Support unsharing the pid namespace.
Date: Fri, 21 Dec 2012 13:24:14 -0600
Message-ID: <1356117854.21178.2@driftwood>
References: <87fw2zmgzc.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="Flowed"; DelSp="Yes"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87fw2zmgzc.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> (from ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org on
	Fri Dec 21 11:51:03 2012)
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 12/21/2012 11:51:03 AM, Eric W. Biederman wrote:
> Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:
> 
> > Eric. I understand that it is too late to discuss this. And yes, I  
> simply
> > do not understand the problem space, I never used containers.
> >
> > But, stupid question. Let's ignore the pid_ns-specific oddities.
> >
> > 1. Ignoring setns(), why do we need /proc/pid/ns/ ?
> >
> > 2. Why setns() requires /proc/pid/ns/ ? IOW, why it can't be
> >
> > 	sys_setns(pid_t pid, int clone_flags)
> > 	{
> > 		truct task_struct *tsk = find_task_by_vpid(pid);
> > 		struct nsproxy *target = get_nsproxy(tsk->nsproxy);
> >
> > 		new_nsproxy = create_new_namespaces(...);
> >
> > 		if (clone_flags & CLONE_NEWNS)
> > 			mntns_install(...);
> > 		if (clone_flags & CLONE_NEWIPC)
> > 			ipcns_install(...);
> > 		...
> > 	}
> >
> > I feel I missed something trivial, but what?
> 
> It is a question of naming.
> 
> The problem I set out to solve when all of this was introduced was how
> to name namespaces without introducing yet another namespace.
> 
> The solution to the naming problem that I finally found was to  
> introduce
> something I could mount.

Where might I find documentation on this? I'm aware of  
Documentation/namespaces but it's only got one file in it (about  
conflicts between namespace types). I'm aware of  
http://lxc.sourceforge.net/index.php/about/kernel-namespaces/ and  
http://lxc.sourceforge.net/man/ but that's mixed in with the  
implementation details of a particular userspace tool, and tends to lag  
the kernel significantly. (Those man pages were last updated in 2010,  
which if I recall was the last time I poked them about it.)

Rob
