From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC] cgroup: deprecate clone_children
Date: Mon, 5 Nov 2012 11:26:36 -0800
Message-ID: <20121105192636.GG19354@mtj.dyndns.org>
References: <1351931915-1701-1-git-send-email-tj@kernel.org>
	<1351931915-1701-2-git-send-email-tj@kernel.org>
	<5097C23B.3040808@parallels.com>
	<20121105180213.GB19354@mtj.dyndns.org>
	<20121105191714.GA24560@sergelap>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121105191714.GA24560@sergelap>
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
Cc: mhocko-AlSwsSmVLrQ@public.gmane.org, linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello, Serge.

On Mon, Nov 05, 2012 at 01:17:14PM -0600, Serge Hallyn wrote:
> > As this is unnecessary feature with very limited use and awkward in
> 
> clone_children is currently required by lxc.  Of course lxc could
> manually set the .cpus and .mems in the newly created child, but if
> those interfaces or others like it ever change (i.e. any new ones which
> must be set before a task can join a cgroup) we'll get into yet more of
> a rats nets of code to support different kernel versions.

If lxc is using it, this will have to stay then.  I'll try to make it
a cpuset specific thing.

> (Just as an idea, if there was a way to generically tell from the list
> of files in my cgroups dir which files need to be initialized before a
> task can join, I think that would suffice.  Maybe a cgroups.needssetup
> file which right now contains 'cpuset.mems\ncpuset.cpus'. Then if we
> find a file we don't recognize in there we can throw an intelligent
> error, or guess at duplicating the parent value.)

Hmmm... I think the root problem is that different controllers don't
agree on the way they inherit configurations from parents.  cgroup
really is a trainwreck.  :(

I don't know whether "needssetup" is the right way to deal with it.
I'll think more about it.

> > co-mounted use cases, let's try to deprecate it.  Whine on the mount
> > option and accesses to cgroupfs knobs.
> > 
> > Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> > Cc: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
> > Cc: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
> > ---
> > Glauber, I think this is more befitting change for .post_clone().  If
> 
> What do you mean by that?  That he is working on a patch-set which will
> remove post_clone and this belongs there, or that there is a proposed
> alternative?

The former.  There was a patchset from Glauber updating ->post_clone()
(which didn't change the behavior).

Thanks.

-- 
tejun
