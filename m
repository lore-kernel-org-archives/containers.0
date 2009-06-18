From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: cgroup attach/fork hooks consistency with the ns_cgroup
Date: Thu, 18 Jun 2009 09:21:24 +0800
Message-ID: <4A399694.601@cn.fujitsu.com>
References: <4A390D5D.5040702@free.fr> <20090617212614.GA26781@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090617212614.GA26781-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

> The ns cgroup is really only good for preventing root in a container
> from escaping its cgroup-imposed limits.  The same can be done today
> using smack or selinux, and eventually will be possible using user
> namespaces.  Would anyone object to removing ns_cgroup?
> 

I vote for removing it. :)

> It won't just remove kernel/ns_cgroup.c, but some subtle code in
> fork.c, nsproxy.c, and of course cgroup.c as well.
> 

Yeah, regarding to cgroup, cgroup_clone() and cgroup_is_descendant()
can be removed. cgroup_clone() is somewhat ugly I think.

> There admittedly is minute convenience gain in not having to
> manually create a new cgroup and attach a cloned child to it, but
> that wasn't the intent of the cgroup.
> 
