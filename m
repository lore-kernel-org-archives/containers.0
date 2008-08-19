From: Fernando Luis =?ISO-8859-1?Q?V=E1zquez?= Cao <fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>
Subject: Re: RFC: Attaching threads to cgroups is OK?
Date: Tue, 19 Aug 2008 21:52:14 +0900
Message-ID: <1219150334.14590.12.camel@sebastian.kern.oss.ntt.co.jp>
References: <48AAA296.8050802@oss.ntt.co.jp>
	<20080819202237.edd75933.kamezawa.hiroyu@jp.fujitsu.com>
	<48AABC31.7070207@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48AABC31.7070207-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: "menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Balbir, Kamezawa-san!

On Tue, 2008-08-19 at 17:57 +0530, Balbir Singh wrote:
> >> Tsuruta-san, how about your bio-cgroup's tracking concerning this?
> >> If we want to use your tracking functions for each threads seperately, 
> >> there seems to be a problem.
> >> ===cf. mm_get_bio_cgroup()===================
> >>            owner
> >> mm_struct ----> task_struct ----> bio_cgroup
> >> =============================================
> >> In my understanding, the mm_struct of a thread is same as its parent's.
> >> So, even if we attach the TIDs of some threads to different cgroups the 
> >> tracking always returns the same bio_cgroup -- its parent's group.
> >> Do you have some policy about in which case we can use your tracking?
> >>
> > It's will be resitriction when io-controller reuse information of the owner
> > of memory. But if it's very clear who issues I/O (by tracking read/write
> > syscall), we may have chance to record the issuer of I/O to page_cgroup
> > struct. 
> 
> We already do some tracking (at dirty time, IIRC) for task IO accounting. For
> the memory controller, tasks are virtually grouped by the mm_struct.
Thank you for your comments and the links.

When it comes to io-tracking such mm_struct-based grouping might not
desirable. If everyone agrees, we could try to decouple bio cgroup from
that memory controller-specific bits.

 - Fernando
