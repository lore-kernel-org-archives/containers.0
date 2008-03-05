From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] libcg: design and plans
Date: Tue, 4 Mar 2008 22:15:20 -0800
Message-ID: <6599ad830803042215n6aedb3eeub0c037e6a4e7bb34__19137.9508040429$1204697862$gmane$org@mail.gmail.com>
References: <20080304152341.GB5659@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080304152341.GB5659-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: fedora-devel-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, opensuse-packaging-stAJ6ESoqRxg9hUCZPvPmw@public.gmane.org, Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Srivatsa Vaddagiri <vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Sudhir Kumar <skumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi Dhaval,

On Tue, Mar 4, 2008 at 7:23 AM, Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> Hi,
>
>  We have been working on a library for control groups which would provide
>  simple APIs for programmers to utilize from userspace and make use of
>  control groups.
>
>  We are still designing the library and the APIs. I've attached the
>  design (as of now) to get some feedback from the community whether we
>  are heading in the correct direction and what else should be addressed.

There are a few things that it would be nice to include in such a
library, if you're going to develop one:

- the ability to create abstract groups of processes, and resource
groups, and have the ability to tie these together arbitrarily. E.g
you might create abstract groups A, B and C, and be able to say that A
and B share memory with each other but not with C, and all three
groups are isolated from each other for CPU. Then libcg would mount
different resource types in different cgroup hierarchies (you would
probably tell it ahead of time which combinations of sharing you would
want, in order that it could minimize the number of mounted
hierarchies). When you tell libcg to move a process into abstract
group A, it would move it into the appropriate resource group in each
hierarchy.

- an interface for gathering usage stats from cgroups.

- support for dynamically migrating processes between groups based on
process connector events (i.e. a finished version of the daemon that
you were working on last year)

Paul
