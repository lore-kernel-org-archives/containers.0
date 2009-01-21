From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/7][v7] Container-init signal semantics
Date: Tue, 20 Jan 2009 22:05:30 -0600
Message-ID: <20090121040530.GA17373@us.ibm.com>
References: <20090117202638.GA11825@us.ibm.com>
	<20090119110906.58ccbcbd.kamezawa.hiroyu@jp.fujitsu.com>
	<20090121030500.GA32138@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090121030500.GA32138-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Sukadev Bhattiprolu (sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> KAMEZAWA Hiroyuki [kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org] wrote:
> | On Sat, 17 Jan 2009 12:26:38 -0800
> | Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> | 
> | > 
> | > Container-init must behave like global-init to processes within the
> | > container and hence it must be immune to unhandled fatal signals from
> | > within the container (i.e SIG_DFL signals that terminate the process).
> | > 
> | > But the same container-init must behave like a normal process to 
> | > processes in ancestor namespaces and so if it receives the same fatal
> | > signal from a process in ancestor namespace, the signal must be
> | > processed.
> | > 
> | > Implementing these semantics requires that send_signal() determine pid
> | > namespace of the sender but since signals can originate from workqueues/
> | > interrupt-handlers, determining pid namespace of sender may not always
> | > be possible or safe.
> | > 
> | 
> | Is this feature is for blocking signals from children to name-space
> | creator(owner) ?  And automatically used when namespace/cgroup is created ?
> | IOW, Container-init is Namespace-Cgroup-init ? 
> 
> I am not sure what "Namespace-cgroup-init refers" to.

It sounds like he means the first task in a newly created
ns cgroup.  In which case he would mean any task which has
done an unshare with any of CLONE_NEWNS, CLONE_NEWIPC, etc,
or is the result of clone with the same.

> But, yes, this patchset applies to the first process in a pid namespace
> i.e the child of clone(NEWPID) call.
> 
> | 
> | I'm glad if you add some documentation updates about how-it-works to patch set.
> 
> Yes,  when the patchset is accepted, I am planning to add some notes to
> /sbin/init man page. 
> 
> Thanks,
> 
> Sukadev
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
