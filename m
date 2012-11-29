From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCHSET cgroup/for-3.8] cpuset: decouple cpuset locking from
	cgroup core
Date: Thu, 29 Nov 2012 06:36:50 -0800
Message-ID: <20121129143650.GE24683@htj.dyndns.org>
References: <1354138460-19286-1-git-send-email-tj@kernel.org>
	<50B743A1.4040405@parallels.com>
	<20121129142646.GD24683@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121129142646.GD24683-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Nov 29, 2012 at 06:26:46AM -0800, Tejun Heo wrote:
> > What I'll try to do, is to come with another specialized lock in cgroup
> > just for this case. So after taking the cgroup lock, we would also take
> > an extra lock if we are adding another entry - be it task or children -
> > to the cgroup.
> 
> No, please don't do that.  Just don't invoke cgroup operation inside
> any subsystem lock.

To add a bit, you won't be solving any problem by adding more locks
here.  cpuset wants to initiate task cgroup migration.  It doesn't
matter how many locks cgroup uses internally.  You'll have to grab
them all anyway to do that.  It's not a problem caused by granularity
of cgroup_lock at all, so there just isn't any logic in dividing locks
for this.  So, again, please don't go that direction.  What we need to
do is isolating subsystem locking and implementation from cgroup
internals, not complicating cgroup internals even more, and now we
have good enoug API to achieve such isolation.

Thanks.

-- 
tejun
