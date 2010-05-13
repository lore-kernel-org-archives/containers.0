From: Andreas Dilger <andreas.dilger-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/9] mm: generic adaptive large memory allocation APIs
Date: Thu, 13 May 2010 15:56:43 -0600
Message-ID: <7280ADBE-F4BF-43B4-8BAC-5BF129C9DDB3__22485.2437539541$1273788109$gmane$org@oracle.com>
References: <1273744147-7594-1-git-send-email-xiaosuo@gmail.com>
	<1273763055.4353.136.camel@mulgrave.site>
Mime-Version: 1.0 (Apple Message framework v1078)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1273763055.4353.136.camel-0iu6Cu4xQGLYCGPCin2YbQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: James Bottomley <James.Bottomley-l3A5Bk7waGM@public.gmane.org>
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, "linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org development" <linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org Mailinglist" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Christoph Raisch <raisch-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, Hoang-Nam Nguyen <hnguyen-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Changli Gao <xiaosuo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Roland Dreier <rolandd-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Divy Le Ray <divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
List-Id: containers.vger.kernel.org

On 2010-05-13, at 09:04, James Bottomley wrote:
> This isn't necessarily true ... most drivers and filesystems have to
> know what type they're getting.  Often they have to do extra tricks to
> process vmalloc areas.  Conversely, large kmalloc areas are a very
> precious commodity: if a driver or filesystem can handle vmalloc for
> large allocations, it should: it's easier for us to expand the vmalloc
> area than to try to make page reclaim keep large contiguous areas ... I
> notice your proposed API does the exact opposite of this ... tries
> kmalloc first and then does vmalloc.
> 
> Given this policy problem, isn't it easier simply to hand craft the
> vmalloc fall back to kmalloc (or vice versa) in the driver than add this
> whole massive raft of APIs for it?

I know we wouldn't mind using large vmalloc allocations for e.g. per-group arrays in ext4 (allocated once per mount), but I'd always understood that using vmalloc for general purpose uses can have a significant impact because the vmalloc() engine has (had?) serious performance problems.  That means it is better performance-wise to have a wrapper function like this to switch between kmalloc() and vmalloc() based on the allocation size, but it makes the code ugly.  Having the wrapper in the kernel would at least identify the different places that are using this kind of workaround.

If the performance of vmalloc() has been improved in the last few years, then I'd be happy to just use vmalloc() all the time.  That said, vmalloc still isn't suitable for sub-page allocations, so if you have a variable-sized allocation that may be very small or very large the small allocations will waste a whole page and a wrapper is still needed, or vmalloc should be changed to call kmalloc/kfree for the sub-page allocations.

Cheers, Andreas
--
Andreas Dilger
Lustre Technical Lead
Oracle Corporation Canada Inc.
