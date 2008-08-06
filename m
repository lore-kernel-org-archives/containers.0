From: Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [Libcg-devel] Control groups and Resource Management notes
	(part I)
Date: Wed, 6 Aug 2008 23:08:49 +0530
Message-ID: <20080806173849.GE14984@linux.vnet.ibm.com>
References: <489315B2.2080506@linux.vnet.ibm.com>
Reply-To: Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <489315B2.2080506-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Balaji Rao <balajirrao-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Aug 01, 2008 at 07:24:58PM +0530, Balbir Singh wrote:

> 4. Binary statistics - The question about binary statistics was raised. Since
> control groups don't enforce any particular kind of API, is there a way to
> generically handle control files and their parameters in the library? Paul
> suggested his binary API approach, where every control group and it's API is
> documented in an api file. Eric suggested using an ASCII interface (since that
> is very generic) and using one file per API. Balbir mentioned that this will
> lead to too many dentries and issues related to having extensive number of dentries.

So where are we heading with respect to this issue? Was any consensus
reached? I plan to look at enabling statistics in libcgroup soon. Also I
believe Balaji is also looking at cgroupstats.

Thanks,
-- 
regards,
Dhaval
