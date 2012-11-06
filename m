From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: Why does devices cgroup check for CAP_SYS_ADMIN explicitly?
Date: Tue, 6 Nov 2012 12:02:33 -0600
Message-ID: <20121106180233.GA31008__1775.77389772541$1352224985$gmane$org@sergelap>
References: <877gpzrlir.fsf@xmission.com> <20121106150131.GA14640@sergelap>
	<20121106150639.GB30069@mtj.dyndns.org>
	<871ug6rbio.fsf@xmission.com>
	<20121106154320.GE30069@mtj.dyndns.org>
	<87sj8mogpp.fsf@xmission.com>
	<20121106165246.GF30069@mtj.dyndns.org>
	<20121106173104.GA27990@sergelap>
	<20121106173823.GK30069@mtj.dyndns.org>
	<20121106174130.GL30069@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121106174130.GL30069-9pTldWuhBndy/B6EtB590w@public.gmane.org>
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
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Aristeu Rozanski <aris-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Tejun Heo (tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org):
> Just one more thing.
> 
> On Tue, Nov 06, 2012 at 09:38:23AM -0800, Tejun Heo wrote:
> > Hello,
> > 
> > On Tue, Nov 06, 2012 at 11:31:04AM -0600, Serge Hallyn wrote:
> > > We can't generally require a capability to move tasks between cgroups,
> > > as that will break currently intended uses.  I can create two cgroups,
> > > chown them to serge, and let serge move between them.
> > 
> > Sure, then just live with the cgroupfs based permission check.  What
> > next?  Should we add CAP_SYS_RESOURCE check to all resource related
> > controllers?  Moreover, We're headed to unified hierarchy, so in the
> > end that means only the user with almost all CAP_* can manipulate
> > cgroups at all making the whole thing meaningless.
> 
> As for using cgroup as !root user, I would advise not doing that.
> Again, we're moving toward a unified cgroup hierarchy.  You wouldn't
> be creating multiple cgroup hierarchies and assigning different user
> accesses to them.  Also, I would strongly discourage chowning sub
> directories in cgroupfs and letting non-priviledged users modify them
> directly.

So to be clear, if I want a user to be able to confine his own
compute-intensive tasks and freeze them, the recommended route will be
with privileged (setuid-root) helpers?

-serge
