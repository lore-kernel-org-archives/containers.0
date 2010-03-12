From: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH -mmotm 0/5] memcg: per cgroup dirty limit (v6)
Date: Fri, 12 Mar 2010 10:58:26 +0100
Message-ID: <20100312095826.GA4438__8534.53990207544$1268388071$gmane$org@linux>
References: <1268175636-4673-1-git-send-email-arighi@develer.com>
	<20100311180753.GE29246@redhat.com> <20100311235922.GA4569@linux>
	<20100312090326.ad07c05c.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100312090326.ad07c05c.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Mar 12, 2010 at 09:03:26AM +0900, KAMEZAWA Hiroyuki wrote:
> On Fri, 12 Mar 2010 00:59:22 +0100
> Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org> wrote:
> 
> > On Thu, Mar 11, 2010 at 01:07:53PM -0500, Vivek Goyal wrote:
> > > On Wed, Mar 10, 2010 at 12:00:31AM +0100, Andrea Righi wrote:
> 
> > mmmh.. strange, on my side I get something as expected:
> > 
> > <root cgroup>
> > $ dd if=/dev/zero of=test bs=1M count=500
> > 500+0 records in
> > 500+0 records out
> > 524288000 bytes (524 MB) copied, 6.28377 s, 83.4 MB/s
> > 
> > <child cgroup with 100M memory.limit_in_bytes>
> > $ dd if=/dev/zero of=test bs=1M count=500
> > 500+0 records in
> > 500+0 records out
> > 524288000 bytes (524 MB) copied, 11.8884 s, 44.1 MB/s
> > 
> > Did you change the global /proc/sys/vm/dirty_* or memcg dirty
> > parameters?
> > 
> what happens when bs=4k count=1000000 under 100M ? no changes ?

OK, I confirm the results found by Vivek. Repeating the tests 10 times:

        root cgroup  ~= 34.05 MB/s average
 child cgroup (100M) ~= 38.80 MB/s average

So, actually the child cgroup with the 100M limit seems to perform
better in terms of throughput.

IIUC, with the large write and the 100M memory limit it happens that
direct write-out is enforced more frequently and a single write chunk is
enough to meet the bdi_thresh or the global background_thresh +
dirty_thresh limits. This means the task is never (or less) throttled
with io_schedule_timeout() in the balance_dirty_pages() loop. And the
child cgroup gets better performance over the root cgroup.

-Andrea
