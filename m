From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Subject: Re: [RFC] [PATCH 2/2] cgroups: blkio subsystem as module
Date: Tue, 12 Jan 2010 18:34:53 -0500
Message-ID: <20100112233453.GB5098@unix37.andrew.cmu.edu>
References: <20091231051050.GA714@andrew.cmu.edu>
	<20100106160414.bd555474.akpm@linux-foundation.org>
	<20100107012606.GA25577@andrew.cmu.edu>
	<20100107120732.97d502bd.kamezawa.hiroyu@jp.fujitsu.com>
	<4B45824B.9030108@cn.fujitsu.com>
	<20100108163352.GB22219@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100108163352.GB22219-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Jan 08, 2010 at 11:33:52AM -0500, Vivek Goyal wrote:
> On Fri, Jan 08, 2010 at 12:30:21AM -0500, Ben Blum wrote:
> > Convert blk-cgroup to be buildable as a module
> > 
> > From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
> > 
> > This patch modifies the Block I/O cgroup subsystem to be able to be built as a
> > module. As the CFQ disk scheduler optionally depends on blk-cgroup, config
> > options in block/Kconfig, block/Kconfig.iosched, and block/blk-cgroup.h are
> > enhanced to support the new module dependency.
> > 
> > Signed-off-by: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
> 
> Two quick observations with testing.
> 
> You need to EXPORT cgroup_path.
> 
> Second, after loading the module, I mounted the blkio controller. But creating
> a cgroup directory crashed.
> 
> Vivek

argh, good catches on both of them. didn't test with DEBUG_CFQ_IOSCHED
(for cgroup_path) or with making a sub-cgroup (for the crash); shame on
me. turns out it crashed because I had init_idr before init_css_set, and
init_css_set sets css->id = NULL explicitly. fixed patches forthcoming.

-- bblum

---
 block/Kconfig             |    2 -
 block/Kconfig.iosched     |    2 -
 block/blk-cgroup.c        |   53 +++++++++++++++++++++++++++++++++++-----------
 block/blk-cgroup.h        |   10 ++++++--
 include/linux/iocontext.h |    2 -
 kernel/cgroup.c           |   34 ++++++++++++++++++++++++-----
 6 files changed, 80 insertions(+), 23 deletions(-)
