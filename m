From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Cgroup in a single hierarchy (Was: Re: [RFD] Merge task counter into
	memcg)
Date: Thu, 12 Apr 2012 14:04:24 -0300
Message-ID: <4F870B18.5060703@parallels.com>
References: <20120411185715.GA4317@somewhere.redhat.com>
	<4F862851.3040208@jp.fujitsu.com>
	<20120412113217.GB11455@somewhere.redhat.com>
	<4F86BFC6.2050400@parallels.com>
	<20120412123256.GI1787@cmpxchg.org>
	<4F86D4BD.1040305@parallels.com>
	<20120412153055.GL1787@cmpxchg.org>
	<20120412163825.GB13069@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120412163825.GB13069-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
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
Cc: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Daniel Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On 04/12/2012 01:38 PM, Tejun Heo wrote:
> Hello, Johannes.
>
> On Thu, Apr 12, 2012 at 05:30:55PM +0200, Johannes Weiner wrote:
>>> But also, I believe this has been widely discussed in person by
>>> people, in separate groups. Maybe Tejun can do a small writeup of
>>> where we stand?
>
> I'm still mulling over it.  What I want is single hierarchy with more
> unified rules regarding how different controllers handle the hierarchy
> in such way that different controllers may interact - ie. memcg and
> blkio can share the same page tags, or cgroup-freezer can provide
> freezing service to other controllers.  I want if a task belongs to
> cgroup, it belongs to _the_ cgroup and you can figure out all cgroup
> related stuff from there.

Agreed.
If you would allow me to side track (I'll answer the rest of the e-mail 
separately to avoid confusion)

One of the things I attempted in cpu/cpuacct, is to patch in code with 
static_branches when they are comounted. I so far temporarily failed 
because some locking order rules, and could not yet go back to that.

But we could do something more general, that could work at least until
we actually finally finish whatever rework we're doing.

1) Right now, the controllers work independently, and that code will 
have to live for at least some years anyway. So leave it there.

2) But also, insert optimization code that can be enabled/disabled when 
companion cgroups are in the same hierarchy.

3) After we mount the cgroup, apply those optimization to all of them 
from the cgroup core (the current bind stuff is just way to weird for 
that, IMHO)

4) Then we start telling userspace people to favor co-mounts as much as 
they can

5) Pray.

Of course this is a sketch, but what do you think?
