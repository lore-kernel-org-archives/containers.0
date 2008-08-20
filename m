From: Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: RFC: Attaching threads to cgroups is OK?
Date: Wed, 20 Aug 2008 16:12:47 +0900 (JST)
Message-ID: <20080820.161247.64324924.taka@valinux.co.jp>
References: <20080819202237.edd75933.kamezawa.hiroyu@jp.fujitsu.com>
	<48AABC31.7070207@linux.vnet.ibm.com>
	<1219150334.14590.12.camel@sebastian.kern.oss.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1219150334.14590.12.camel-xpvPi5bcW5X5OjGIXfuPlhrrLbDL3r4M6qtp775pBPw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Fernando!

> Hi Balbir, Kamezawa-san!
> 
> On Tue, 2008-08-19 at 17:57 +0530, Balbir Singh wrote:
> > >> Tsuruta-san, how about your bio-cgroup's tracking concerning this?
> > >> If we want to use your tracking functions for each threads seperately, 
> > >> there seems to be a problem.
> > >> ===cf. mm_get_bio_cgroup()===================
> > >>            owner
> > >> mm_struct ----> task_struct ----> bio_cgroup
> > >> =============================================
> > >> In my understanding, the mm_struct of a thread is same as its parent's.
> > >> So, even if we attach the TIDs of some threads to different cgroups the 
> > >> tracking always returns the same bio_cgroup -- its parent's group.
> > >> Do you have some policy about in which case we can use your tracking?
> > >>
> > > It's will be resitriction when io-controller reuse information of the owner
> > > of memory. But if it's very clear who issues I/O (by tracking read/write
> > > syscall), we may have chance to record the issuer of I/O to page_cgroup
> > > struct. 
> > 
> > We already do some tracking (at dirty time, IIRC) for task IO accounting. For
> > the memory controller, tasks are virtually grouped by the mm_struct.
> Thank you for your comments and the links.
> 
> When it comes to io-tracking such mm_struct-based grouping might not
> desirable. If everyone agrees, we could try to decouple bio cgroup from
> that memory controller-specific bits.

From the technical point of view, it will be possible, but I'm not sure
if it is so useful. I guess it might be overkill.

I have designed the io-tracking mechanism of bio-cgroup based on
the memory controller because:

 - I wanted reuse the existing code for the first step as far as I could.
   And I also think it's a good policy to make things generic so other
   functions can use it.

 - bio-cgroup should be used with the cgroup memory controller
   to controll delayed write requests. Without the memory controller,
   a bio-group may eat up lots of pages and turn them dirty.
   I don't want to imagine what would happens if this bio-group is
   assigned a low priority for I/O.
   If bio-cgroup may cause some trouble without the memory controller,
   I think it won't be so useful to design a new io-tracking mechanism.

 - I think this kind of thread application should control its I/O requests
   inside of the application. I guess it seems to quite difficult to
   determine which thread is doing what kind of job in the application.
   We can just leave this issue to these type of applications, can we?
   I guess most of this kind of applications must have been well designed
   already.

What do you think if we just leave it as it is and keep the code simple?


Thanks,
Hirokazu Takahashi.
