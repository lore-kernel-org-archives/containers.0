From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH -mmotm 0/5] memcg: per cgroup dirty limit (v7)
Date: Wed, 17 Mar 2010 15:15:14 -0400
Message-ID: <20100317191514.GC9198__7354.80563384971$1268853503$gmane$org@redhat.com>
References: <1268609202-15581-1-git-send-email-arighi@develer.com>
	<20100315171209.GI21127@redhat.com>
	<20100315171921.GJ21127@redhat.com>
	<20100317115427.GR18054@balbir.in.ibm.com>
	<20100317133407.GA9198@redhat.com>
	<20100317185327.GV18054@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100317185327.GV18054-SINUvgVNF2CyUtPGxGje5AC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Mar 18, 2010 at 12:23:27AM +0530, Balbir Singh wrote:
> * Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> [2010-03-17 09:34:07]:
> 
> > > > 
> > > > root cgroup
> > > > ==========
> > > > #time dd if=/dev/zero of=/root/zerofile bs=4K count=1M
> > > > 4294967296 bytes (4.3 GB) copied, 56.098 s, 76.6 MB/s
> > > > 
> > > > real	0m56.614s
> > > > 
> > > > test1 cgroup with memory limit 100M
> > > > ===================================
> > > > # time dd if=/dev/zero of=/root/zerofile1 bs=4K count=1M
> > > > 4294967296 bytes (4.3 GB) copied, 19.8097 s, 217 MB/s
> > > > 
> > > > real	0m19.992s
> > > > 
> > > 
> > > This is strange, did you flish the cache between the two runs?
> > > NOTE: Since the files are same, we reuse page cache from the
> > > other cgroup.
> > 
> > Files are different. Note suffix "1".
> >
> 
> Thanks, I'll get the perf output and see what I get. 

One more thing I noticed and that is, it happens only if we limit the
memory of cgroup to 100M. If same cgroup test1 is unlimited memory 
thing, then it did not happen.

I also did not notice this happening on other system where I have 4G of
memory. So it also seems to be related with only bigger configurations.

Thanks
Vivek

> 
> -- 
> 	Three Cheers,
> 	Balbir
