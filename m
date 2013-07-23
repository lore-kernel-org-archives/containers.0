From: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC PATCH 1/2] devices cgroup: allow can_attach() if ns_capable
Date: Tue, 23 Jul 2013 13:38:41 -0500
Message-ID: <20130723183841.GA9021@tp>
References: <20130723181606.GA6342@sergelap>
	<20130723183018.GF21100@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130723183018.GF21100-9pTldWuhBndy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Tejun Heo (tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org):
> On Tue, Jul 23, 2013 at 01:16:06PM -0500, Serge Hallyn wrote:
> > We allow a task to change its own devices cgroup, or to change other tasks'
> > cgroups if it has CAP_SYS_ADMIN.
> > 
> > Also allow task A to change task B's cgroup if task A has CAP_SYS_ADMIN
> > with respect to task B - meaning A is root in the same userns, or A
> > created B's userns.
> 
> As discussed multpile times, cgroup isn't gonna support delegating
> cgroup management directly into containers, so this doesn't really
> jive with where we're heading.

This doesn't delegate it into the container.  It allows me, on the host,
to set the cgroup for a container.

thanks,
-serge
