From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: memcg creates an unkillable task in 3.11-rc2
Date: Mon, 9 Sep 2013 10:31:47 +0200
Message-ID: <20130909083147.GA18056__30904.5164184228$1378715528$gmane$org@dhcp22.suse.cz>
References: <87r4eh70yg.fsf@xmission.com> <51F71DE2.4020102@huawei.com>
	<87ppu0a298.fsf_-_@tw-ebiederman.twitter.com>
	<20130730123120.GA15847@dhcp22.suse.cz>
	<874nbc3sx1.fsf@tw-ebiederman.twitter.com>
	<20130731073726.GC30514@dhcp22.suse.cz>
	<87zjt2tm9f.fsf@xmission.com>
	<20130801090620.GA5198@dhcp22.suse.cz>
	<20130905095653.GB9702@dhcp22.suse.cz>
	<87ob85kejy.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87ob85kejy.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Glauber Costa <glommer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, kent.overstreet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri 06-09-13 11:09:21, Eric W. Biederman wrote:
> Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org> writes:
> 
> > It seems that this one fell though the cracks?
> 
> Not completely, but it happened just as I was doing my initial triage of
> memcg problems and I haven't quite made it back to this.

OK. I am primarily asking because I am not sure I understood whether the
proposed patch helped or not. It should as per my last email but it is
possible that I have missed something...

> I have an even nastier memcg hang (without yet an easy reproducer).
> During mkdir ext3 can add a page to the page cache with the ext3 journal
> transaction lock held.  Normally that isn't a problem but freezing there
> stops all writes to that filesystem, and the world stops.
> 
> It looks like the only way to avoid that kind of scenario is to move the
> the memcg sleep to the edge of userspace, like we do with signals and a
> few other things so we can be guaranteed not to increase lock hold
> times, when it is avoidable.  I think I saw some similar comments about
> the slab limiting.

Johannes has patches that move memcg oom out of any locks already: 
https://lkml.org/lkml/2013/8/3/81. There is some development going on
there and I guess he will post v3 soon but that sounds it might help
with what you describe above.

Thanks!
-- 
Michal Hocko
SUSE Labs
