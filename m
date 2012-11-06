From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: Why does devices cgroup check for CAP_SYS_ADMIN explicitly?
Date: Tue, 6 Nov 2012 10:16:23 -0800
Message-ID: <20121106181623.GO30069__4468.8920178034$1352225805$gmane$org@mtj.dyndns.org>
References: <877gpzrlir.fsf@xmission.com> <20121106150131.GA14640@sergelap>
	<20121106150639.GB30069@mtj.dyndns.org>
	<871ug6rbio.fsf@xmission.com>
	<20121106154320.GE30069@mtj.dyndns.org>
	<87sj8mogpp.fsf@xmission.com>
	<20121106165246.GF30069@mtj.dyndns.org>
	<20121106173104.GA27990@sergelap>
	<20121106173823.GK30069@mtj.dyndns.org>
	<20121106181214.GB31008@sergelap>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121106181214.GB31008@sergelap>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Aristeu Rozanski <aris-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello, Serge.

On Tue, Nov 06, 2012 at 12:12:14PM -0600, Serge Hallyn wrote:
> Quoting Tejun Heo (tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org):
> > On Tue, Nov 06, 2012 at 11:31:04AM -0600, Serge Hallyn wrote:
> > > We can't generally require a capability to move tasks between cgroups,
> > > as that will break currently intended uses.  I can create two cgroups,
> > > chown them to serge, and let serge move between them.
> > 
> > Sure, then just live with the cgroupfs based permission check.  What
> > next?  Should we add CAP_SYS_RESOURCE check to all resource related
> 
> That would be the next step, yes.

Hmmm... I don't know.  What does that buy us?  Fine grained CAP_* is
to be able to give away privliedges in smaller pieces, right?  If
we're gonna be requiring root to modify cgroup, what difference does
it make to have finer grained CAPs specified?

> > controllers?  Moreover, We're headed to unified hierarchy, so in the
> > end that means only the user with almost all CAP_* can manipulate
> > cgroups at all making the whole thing meaningless.
> 
> Why meaningless?  Many caps needed to "do everything", but moving
> a task into the freezer and freezing it, or reducing its allowed
> memory, would only requiring uid equiv or some limited bit of
> privilege.

All controllers will be co-mounted and you'll need all CAPs needed by
all controllers to move tasks between cgroups and there won't be an
easy way to tell which CAP is missing.  Doesn't sound too useful to
me.

> > I don't think applying fine-grained CAP_* to cgroup controllers makes
> > sense or would be useful in any real sense.  We can introduce, say,
> > CAP_CGROUP to control access cgroupfs but I think we already have
> > enough access control to cgroupfs, don't we?
> 
> That's the question :)
> 
> I feel like we need a list of the various uses people have in mind,
> so we can figure out which ones are supportable...  but I know there
> is the whole long thread I've not had time to keep up with, and
> many answers are probably there.

Care to give a pointer?

Thanks.

-- 
tejun
