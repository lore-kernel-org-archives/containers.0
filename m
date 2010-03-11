From: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH -mmotm 0/5] memcg: per cgroup dirty limit (v6)
Date: Fri, 12 Mar 2010 00:59:22 +0100
Message-ID: <20100311235922.GA4569__2984.5324963846$1268352052$gmane$org@linux>
References: <1268175636-4673-1-git-send-email-arighi@develer.com>
	<20100311180753.GE29246@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100311180753.GE29246-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Mar 11, 2010 at 01:07:53PM -0500, Vivek Goyal wrote:
> On Wed, Mar 10, 2010 at 12:00:31AM +0100, Andrea Righi wrote:
> > Control the maximum amount of dirty pages a cgroup can have at any given time.
> > 
> > Per cgroup dirty limit is like fixing the max amount of dirty (hard to reclaim)
> > page cache used by any cgroup. So, in case of multiple cgroup writers, they
> > will not be able to consume more than their designated share of dirty pages and
> > will be forced to perform write-out if they cross that limit.
> > 
> > The overall design is the following:
> > 
> >  - account dirty pages per cgroup
> >  - limit the number of dirty pages via memory.dirty_ratio / memory.dirty_bytes
> >    and memory.dirty_background_ratio / memory.dirty_background_bytes in
> >    cgroupfs
> >  - start to write-out (background or actively) when the cgroup limits are
> >    exceeded
> > 
> > This feature is supposed to be strictly connected to any underlying IO
> > controller implementation, so we can stop increasing dirty pages in VM layer
> > and enforce a write-out before any cgroup will consume the global amount of
> > dirty pages defined by the /proc/sys/vm/dirty_ratio|dirty_bytes and
> > /proc/sys/vm/dirty_background_ratio|dirty_background_bytes limits.
> > 
> 
> Hi Andrea,
> 
> I am doing a simple dd test of writting a 4G file. This machine has got
> 64G of memory and I have created one cgroup with 100M as limit_in_bytes.
> 
> I run following dd program both in root cgroup as well as test1/
> cgroup(100M limit) one after the other.
> 
> In root cgroup
> ==============
> dd if=/dev/zero of=/root/zerofile bs=4K count=1000000
> 1000000+0 records in
> 1000000+0 records out
> 4096000000 bytes (4.1 GB) copied, 59.5571 s, 68.8 MB/s
> 
> In test1/ cgroup
> ===============
> dd if=/dev/zero of=/root/zerofile bs=4K count=1000000
> 1000000+0 records in
> 1000000+0 records out
> 4096000000 bytes (4.1 GB) copied, 20.6683 s, 198 MB/s
> 
> It is strange that we are throttling process in root group much more than
> process in test1/ cgroup?

mmmh.. strange, on my side I get something as expected:

<root cgroup>
$ dd if=/dev/zero of=test bs=1M count=500
500+0 records in
500+0 records out
524288000 bytes (524 MB) copied, 6.28377 s, 83.4 MB/s

<child cgroup with 100M memory.limit_in_bytes>
$ dd if=/dev/zero of=test bs=1M count=500
500+0 records in
500+0 records out
524288000 bytes (524 MB) copied, 11.8884 s, 44.1 MB/s

Did you change the global /proc/sys/vm/dirty_* or memcg dirty
parameters?

-Andrea
