From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: memcg creates an unkillable task in 3.2-rc2
Date: Mon, 29 Jul 2013 12:10:26 -0400
Message-ID: <20130729161026.GD22605__21135.9695102603$1375114246$gmane$org@mtj.dyndns.org>
References: <20130723174711.GE21100@mtj.dyndns.org>
	<8761vui4cr.fsf@xmission.com>
	<20130729075939.GA4678@dhcp22.suse.cz>
	<87ehahg312.fsf@xmission.com>
	<20130729095109.GB4678@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130729095109.GB4678-2MMpYkNvuYDjFM9bn6wA6Q@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Cc: Glauber Costa <glommer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, kent.overstreet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

Hello,

On Mon, Jul 29, 2013 at 11:51:09AM +0200, Michal Hocko wrote:
> Isn't this a bug in freezer then? I am not familiar with the freezer
> much but memcg oom handling seems correct to me. The task is sleeping
> KILLABLE and fatal_signal_pending in mem_cgroup_handle_oom will tell us
> to bypass the charge and let the taks go away.

Is the problem a frozen task not being killed even when SIGKILL is
received?  If so, it is a known problem and a side-effect of
cgroup_freezer (ab)using and making the existing power management
freezer visible to userland without really thinking about the
implications.  :(

So, yeah, if you use cgroup_freezer now, the tasks will get stuck in
states which aren't well defined when visible from userland and will
just stay there until unfrozen no matter what.  Yet another reason
I'll be screaming like a banshee at anyone who says that cgroup is
built to delegate subtree access rights to !root users.

It's on the to-do list but a very long term one.  Right now, if you
combine userland OOM handling with freezer and whatnot, it'd be pretty
easy to get into trouble.

Thanks.

-- 
tejun
