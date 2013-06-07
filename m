From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH cgroup/for-3.11 1/3] cgroup: mark "tasks" cgroup file as
	insane
Date: Fri, 7 Jun 2013 13:32:55 -0700
Message-ID: <20130607203255.GD14781@mtj.dyndns.org>
References: <20130604021302.GH29989@mtj.dyndns.org>
	<20130604111556.GA4963@redhat.com>
	<20130604201947.GE14916@htj.dyndns.org>
	<20130606092055.GF30217@redhat.com>
	<20130606211410.GF5045@htj.dyndns.org>
	<20130607101220.GE10742@redhat.com>
	<51B1B6C2.7000304@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <51B1B6C2.7000304-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kay.sievers-tD+1rO4QERM@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello, Glauber.

On Fri, Jun 07, 2013 at 02:32:34PM +0400, Glauber Costa wrote:
> It seems quite valid for me to split priority threads in a process and
> give them a 80 % timeslice guarantee, while leaving only 20 % for
> low-prio threads (for instance).
> 
> In general, I don't think that it would hurt to allow separation at
> thread level *for the leaves*, specifically at the cpu related controllers.

But if you look at the larger picture, it actually is deterimental,
because allowing different threads of the same process almost implies
that the program binary itself would be involved in interacting with -
accessing and tuning - cgroups.  Back to sysctl analogy, it's one
thing to expose them to base system tools which are tightly coupled
with the kernel so that they can configure it, but allowing lay
programs to embed sysctl tuning inside their binaries is a completely
different thing and something which must not happen.

While not strictly designated explicitly, things exposed from the
kernel have differing levels of exposedness and we do definitely want
to avoid exposing too much implementation details for the sake of both
the kernel and userland.  Such levels are in some cases determined as
the use cases develop.  If you ask me, cgroup is a good example of
things going horribly wrong.

So, yeah, while I agree that per-thread usages could make sense for
scheduler related controllers, I'd very much like to avoid that if at
all possible.  It's not a good road to be on.

Thanks.

-- 
tejun
