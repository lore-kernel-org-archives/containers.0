From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH -mmotm 0/5] memcg: per cgroup dirty limit (v7)
Date: Thu, 18 Mar 2010 00:47:43 +0530
Message-ID: <20100317191743.GY18054__29921.1916084916$1268853580$gmane$org@balbir.in.ibm.com>
References: <1268609202-15581-1-git-send-email-arighi@develer.com>
	<20100315171209.GI21127@redhat.com>
	<20100315171921.GJ21127@redhat.com>
	<20100317115427.GR18054@balbir.in.ibm.com>
	<20100317133407.GA9198@redhat.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100317133407.GA9198-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

* Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> [2010-03-17 09:34:07]:

> On Wed, Mar 17, 2010 at 05:24:28PM +0530, Balbir Singh wrote:
> > * Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> [2010-03-15 13:19:21]:
> > 
> > > On Mon, Mar 15, 2010 at 01:12:09PM -0400, Vivek Goyal wrote:
> > > > On Mon, Mar 15, 2010 at 12:26:37AM +0100, Andrea Righi wrote:
> > > > > Control the maximum amount of dirty pages a cgroup can have at any given time.
> > > > > 
> > > > > Per cgroup dirty limit is like fixing the max amount of dirty (hard to reclaim)
> > > > > page cache used by any cgroup. So, in case of multiple cgroup writers, they
> > > > > will not be able to consume more than their designated share of dirty pages and
> > > > > will be forced to perform write-out if they cross that limit.
> > > > > 
> > > > 
> > > > For me even with this version I see that group with 100M limit is getting
> > > > much more BW.
> > > > 
> > > > root cgroup
> > > > ==========
> > > > #time dd if=/dev/zero of=/root/zerofile bs=4K count=1M
> > > > 4294967296 bytes (4.3 GB) copied, 55.7979 s, 77.0 MB/s
> > > > 
> > > > real	0m56.209s
> > > > 
> > > > test1 cgroup with memory limit of 100M
> > > > ======================================
> > > > # time dd if=/dev/zero of=/root/zerofile1 bs=4K count=1M
> > > > 4294967296 bytes (4.3 GB) copied, 20.9252 s, 205 MB/s
> > > > 
> > > > real	0m21.096s
> > > > 
> > > > Note, these two jobs are not running in parallel. These are running one
> > > > after the other.
> > > > 
> > > 

The data is not always repeatable at my end. Are you able to modify
the order and get repeatable results?

In fact, I saw

for cgroup != root
------------------
4294967296 bytes (4.3 GB) copied, 120.359 s, 35.7 MB/s

for cgroup = root
-----------------
4294967296 bytes (4.3 GB) copied, 84.504 s, 50.8 MB/s

This is without the patches applied.


-- 
	Three Cheers,
	Balbir
