From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: [PATCH 18/24] blkio_cgroup patches from Ryo to track async bios.
Date: Wed, 19 Aug 2009 10:43:11 +0900 (JST)
Message-ID: <20090819.104311.71088788.ryov__34279.7952275307$1250646393$gmane$org@valinux.co.jp>
References: <1250451046-9966-19-git-send-email-vgoyal@redhat.com>
	<20090818.204212.59676649.ryov@valinux.co.jp>
	<20090818142636.GA7367@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090818142636.GA7367-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Vivek,

Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On Tue, Aug 18, 2009 at 08:42:12PM +0900, Ryo Tsuruta wrote:
> > Hi Vivek,
> > 
> > Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > > o blkio_cgroup patches from Ryo to track async bios.
> > > 
> > > o Fernando is also working on another IO tracking mechanism. We are not
> > >   particular about any IO tracking mechanism. This patchset can make use
> > >   of any mechanism which makes it to upstream. For the time being making
> > >   use of Ryo's posting.
> > 
> > The patch attached with your mail is obsolete and it may potentially
> > cause a deadlock when lock_page_cgroup() is called under radix_tree->lock.
> > http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=e767e0561d7fd2333df1921f1ab4176211f9036b
> > 
> > The latest blkio-cgroup fixes the above issue and reduces IO tracking
> > overhead since lock_page_cgroup() is no longer used. I would recommend
> > to update to the latest version.
> > 
> 
> Hi Ryo,
> 
> Thanks. In next posting I will move to latest version of io tracking
> patches.
> 
> > And I have a suggestion, how about moving get_cgroup_from_page() to
> > biotrack.c, I think this function would be useful for people who
> > want to make use of the IO tracking mechanism.
> > 
> > Please let me know your opinion.
> 
> Makes sense. In next posting, will move get_cgroup_from_page() to biotrack.c.

Thank you for your reply. I'll post the new blkio-cgroup reflected in
this change by the end of this week. Please use it if you would like to.

Thanks,
Ryo Tsuruta
