From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC PATCH 1/2] devices cgroup: allow can_attach() if ns_capable
Date: Tue, 23 Jul 2013 15:12:45 -0400
Message-ID: <20130723191245.GI21100@mtj.dyndns.org>
References: <20130723181606.GA6342@sergelap>
	<20130723183018.GF21100@mtj.dyndns.org> <20130723183841.GA9021@tp>
	<CAOS58YPynQ-QBx5nZEnYrP5kGTVvv9VAj0cV0aYeikTitvTQbA@mail.gmail.com>
	<20130723190426.GA9577@tp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130723190426.GA9577@tp>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello,

On Tue, Jul 23, 2013 at 02:04:26PM -0500, Serge Hallyn wrote:
> If task A is uid 1000 on the host, and creates task B as uid X in a new
> user namespace, then task A, still being uid 1000 on the host, is
> privileged with respect to B and his namespace - i.e.
> ns_capable(B->userns, CAP_SYS_ADMIN) is true.

Well, that also is the exact type of priv delegation we're moving away
from, so....

> > Besides, I find the whole check rather bogus and would actually much
> > prefer just nuking the check and just follow the standard permission
> > checks.
> 
> I'd be ok with that - but there's one case I'm not sure about:  If PAM
> sets me up with /sys/fs/cgroup/devices/serge owned by me, then if I'm
> thinking right, removing can_attach would mean I could move init into
> /sys/fs/cgroup/devices/serge...
> 
> Is there something else stopping that from happening?

If PAM is giving out perms on cgroup directory, the whole system is
prone to DoS in various ways anyway.  It's already utterly broken, so
kinda moot point.  If there are people actually doing that in the
wild, we can conditionalize it on cgroup_sane_behavior().

Thanks.

-- 
tejun
