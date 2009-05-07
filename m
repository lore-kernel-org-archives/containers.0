From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: IO scheduler based IO Controller V2
Date: Thu, 7 May 2009 10:45:01 -0400
Message-ID: <20090507144501.GB9463@redhat.com>
References: <1241553525-28095-1-git-send-email-vgoyal@redhat.com>
	<20090505132441.1705bfad.akpm@linux-foundation.org>
	<20090506023332.GA1212@redhat.com>
	<20090506203228.GH8180@redhat.com> <20090506213453.GC4282@linux>
	<20090506215235.GJ8180@redhat.com> <20090507090450.GA4613@linux>
	<20090507141126.GA9463@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090507141126.GA9463-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, May 07, 2009 at 10:11:26AM -0400, Vivek Goyal wrote:

[..]
> [root@chilli io-throttle-tests]# ./andrea-test-script.sh 
> RT: 223+1 records in
> RT: 223+1 records out
> RT: 234179072 bytes (234 MB) copied, 0.988448 s, 237 MB/s
> BE: 223+1 records in
> BE: 223+1 records out
> BE: 234179072 bytes (234 MB) copied, 1.93885 s, 121 MB/s
> 
> So I am still seeing the issue with differnt kind of disks also. At this point
> of time I am really not sure why I am seeing such results.

Hold on. I think I found the culprit here. I was thinking that what is
the difference between two setups and realized that with vanilla kernels
I had done "make defconfig" and with io-throttle kernels I had used an
old config of my and did "make oldconfig". So basically config files
were differnt.

I now used the same config file and issues seems to have gone away. I
will look into why an old config file can force such kind of issues.

So now we are left with the issue of loosing the notion of priority and
class with-in cgroup. In fact on bigger systems we will probably run into
issues of kiothrottled scalability as single thread is trying to cater to
all the disks.

If we do max bw control at IO scheduler level, then I think we should be able
to control max bw while maintaining the notion of priority and class with-in
cgroup. Also there are multiple pdflush threads and jens seems to be pushing
flusher threads per bdi which will help us achieve greater scalability and
don't have to replicate that infrastructure for kiothrottled also.

Thanks
Vivek
