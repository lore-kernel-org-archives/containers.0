From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] namespaces: introduce sys_hijack (v7)
Date: Wed, 31 Oct 2007 18:13:59 -0500
Message-ID: <20071031231359.GA5141@sergelap.austin.ibm.com>
References: <20071024222125.GA8641@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20071024222125.GA8641-6s5zFf/epYLPQpwDFJZrxKsjOiXwFzmk@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Serge E. Hallyn (serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> This is just a first stab at doing hijack by cgroup files.  I force
> using the 'tasks' file just so that I can (a) predict and check
> the name of the file, (b) make sure it's a cgroup file, and then
> (c) trust that taking __d_cont(dentry parent) gives me a legitimate
> container.
> 
> Seems to work at least.
> 
> Paul, does this look reasonable?  task_from_cgroup_fd() in particular.

The patch I sent does 'hijack a cgroup' by taking a task in the cgroup
and hijacking it.

Paul would like to be able to 'enter a cgroup', even if it is empty.
Hijack takes more than just the nsproxy from the hijacked task, so
this would result in different behavior between hijacking a populated
cgroup and an empty cgroup.  So we might want to introduce a third
type of hijacking, so we have HIJACK_PID, HIJACK_CGROUP, and
HIJACK_EMPTY_CGROUP.

It also then acts like the nsproxy cgroup patchset I sent out months
ago for simply entering namespaces.  In fact this would need to be
restricted to ns cgroups, and ns cgroups would need to grab a reference
to the nsproxy.

So do we want to allow hijacking/entering an empty cgroup?


-serge
