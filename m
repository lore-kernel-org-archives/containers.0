From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] namespaces: introduce sys_hijack (v11)
Date: Fri, 1 Aug 2008 09:22:06 -0500
Message-ID: <20080801142206.GB11553@us.ibm.com>
References: <20080731183213.GA12033@us.ibm.com>
	<20080801172811.FEC3.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080801172811.FEC3.KOSAKI.MOTOHIRO-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting KOSAKI Motohiro (kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org):
> Hi
> 
> fork() is very important for system performance.
> I worry about performance regression if this feature isn't used.
> 
> Could you mesure spawn benchmark in unixbench?

Yes, I will do that.  I'll send the results next week.

Some context and history about this patch:

	1. Originally the 'enter a namespace' functionality was
	   implemented (in vserver and in -lxc, maybe also in
	   openvz) by specifying an integer id for a container
	   to enter.  See for instance the patches under
	   http://lxc.sourceforge.net/patches/2.6.25/2.6.25-rc8-mm2-lxc1/broken-out/bind_ns/

	2. At one point I started extending the ns_cgroup to
	   allow namespace entering by attaching to an ns_cgroup.
	   So 'echo $$ > /containers/5487/tasks' would switch
	   your nsproxy.  People didn't like that much in part
	   because switching the namespaces while a task is
	   executing seems frought with potential dangers,
	   though those remain unexplored.

	3. Eric suggested that namespace entering should just
	   be done by ptracing a process in a container and
	   bending it to our will.  The hijack patchset was
	   sort of a response to that.  Strictly using ptrace
	   seemed to me to leave to leave us too much at the
	   mercy of the target's context.
	   For instance, if using selinux, when you ptrace a
	   target you are subject to the target's permissions.
	   With hijack, you'll continue with your own,
	   presumably administrator-level, privilege level.

	4. We stopped posting this patch some time ago because
	   it seems worth seeing just how far we can go in
	   terms of analyzing and configuring containers by
	   properly setting up namespaces (i.e. hierarchical
	   pid and user namespaces) and using filesystems
	   (in conjunction with mounts propagation) to do the
	   configuration.
	   But at the mini-summit last week it was mentioned
	   that OpenVZ still wants namespace entering, and
	   there seemed to be no real opposition, so we told
	   Pavel we would repost this patchset.

thanks,
-serge
