From: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Subject: Re: [PATCH 07/12] cgroup: unify cgroup_write_X64() and
	cgroup_write_string()
Date: Mon, 2 Dec 2013 11:44:06 -0500
Message-ID: <20131202164406.GP3556__47740.6389349655$1386005910$gmane$org@cmpxchg.org>
References: <1385595759-17656-1-git-send-email-tj@kernel.org>
	<1385595759-17656-8-git-send-email-tj@kernel.org>
	<20131128111818.GG2761@dhcp22.suse.cz>
	<20131129200525.GC21755@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20131129200525.GC21755-9pTldWuhBndy/B6EtB590w@public.gmane.org>
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
Cc: nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Nov 29, 2013 at 03:05:25PM -0500, Tejun Heo wrote:
> Hello, Michal.
> 
> On Thu, Nov 28, 2013 at 12:18:18PM +0100, Michal Hocko wrote:
> > > Unify the two into cgroup_file_write() which always allocates dynamic
> > > buffer for simplicity
> > 
> > It's true that this is simpler but the allocation might cause some
> > issues with memcg. Although it is not common that userspace oom handler
> > is a part of the target memcg there are users (e.g. Google) who do that.
> > 
> > Why is that a problem? Consider that a memcg is under OOM, handler gets
> > notified and tries to solve the situation by enlarging the hard limit.
> > This worked before this patch because cgroup_write_X64 used an on stack
> > buffer but now it would use kmalloc which might be accounted and trip
> > over the same OOM situation.
> >
> > This is not limited to the OOM handling. The group might be close to OOM
> > and the last thing user expects is to trigger OOM when he tries to
> > enlarge the limit.
> > 
> > Is the additional simplicity worth breaking those usecases?
> 
> Whoa, so we support oom handler inside the memcg that it handles?
> Does that work reliably?  Changing the above detail in this patch
> isn't difficult (and we'll later need to update kernfs too) but
> supporting such setup properly would be a *lot* of commitment and I'm
> very doubtful we'd be able to achieve that by just carefully avoiding
> memory allocation in the operations that usreland oom handler uses -
> that set is destined to expand over time, extremely fragile and will
> be hellish to maintain.
> 
> So, I'm not at all excited about commiting to this guarantee.  This
> one is an easy one but it looks like the first step onto dizzying
> slippery slope.
> 
> Am I misunderstanding something here?  Are you and Johannes firm on
> supporting this?

Handling a memcg OOM from userspace running inside that OOM memcg is
completely crazy.  I mean, think about this for just two seconds...
Really?

I get that people are doing it right now, and if you can get away with
it for now, good for you.  But you have to be aware how crazy this is
and if it breaks you get to keep the pieces and we are not going to
accomodate this in the kernel.  Fix your crazy userspace.
