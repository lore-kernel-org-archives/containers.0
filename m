From: Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC] libcg: design and plans
Date: Wed, 5 Mar 2008 10:56:31 +0530
Message-ID: <20080305052631.GA26361__16386.5995048129$1204695047$gmane$org@linux.vnet.ibm.com>
References: <20080304152341.GB5659@linux.vnet.ibm.com>
	<47CD83C7.4020206@amln.net>
Reply-To: Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <47CD83C7.4020206-d4um4pvOpxY@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Xpl++ <xpl-d4um4pvOpxY@public.gmane.org>
Cc: fedora-devel-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, opensuse-packaging-stAJ6ESoqRxg9hUCZPvPmw@public.gmane.org, Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Srivatsa Vaddagiri <vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Sudhir Kumar <skumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Peter,

Thanks for your comments.

On Tue, Mar 04, 2008 at 07:15:51PM +0200, Xpl++ wrote:
> Hi,
>
> I was wonder if creating such library makes any sense at all, considering 
> the nature of cgroups, the way they work and their possible application?
> It seems to me that any attempt to create a 'simple' API would actualy 
> result in something that will be much harder to use that just making raw 
> mkdir/open/read/write/close operations.

These simple APIs are nothing but raw mkdir/open/read/write/close
operations.

>  Another thing is suggested config 
> for this lib would be more appropriate for a daemon rather than a library.
> In general - cgroup is a very flexible subsystem that can be used in a wide 
> variety of ways and modes and trying to create a universal simple API would 
> more likely result in something hard to manage and work with.
> The idea of having multiple container managers (applications that use 
> libcg) creates a lots of questions and possible issues. Containers are 
> supposed provide a flexible resource management and task grouping ability, 
> which somewhat implies that there cannot be two different resource managers 
> per node without one knowing well the desires/goals/methods of the other 
> and vice versa. And should there be only one manager per node - probably it 
> will be easier for it to use cgroup subsystem directly rather than using a 
> wrapper library?

I disagree. Allowing multiple resource managers allows more flexibility.
One thing the configuration subsystem aims to do is to allow permissions
to the groups. With this happening, a resource manager does not need to
about the existence of other groups, it can control only the resources
allotted to it. And since the top level is controlled by the
administrator, he is aware of the groups and their needs. (I've given an
example of such a scenario in the document as well).

Hope this helps answer your question.

Thanks,
-- 
regards,
Dhaval
