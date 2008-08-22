From: Takuya Yoshikawa <yoshikawa.takuya-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>
Subject: Re: RFC: Attaching threads to cgroups is OK?
Date: Fri, 22 Aug 2008 10:03:29 +0900
Message-ID: <48AE1061.3060800@oss.ntt.co.jp>
References: <20080819202237.edd75933.kamezawa.hiroyu@jp.fujitsu.com>	<48AABC31.7070207@linux.vnet.ibm.com>	<1219150334.14590.12.camel@sebastian.kern.oss.ntt.co.jp>	<20080820.161247.64324924.taka@valinux.co.jp>
	<20080820174334.a566a775.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080820174334.a566a775.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Kamezawa-san,

KAMEZAWA Hiroyuki wrote:
> On Wed, 20 Aug 2008 16:12:47 +0900 (JST)
> Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org> wrote:
> 
>>  - I think this kind of thread application should control its I/O requests
>>    inside of the application. I guess it seems to quite difficult to
>>    determine which thread is doing what kind of job in the application.
>>    We can just leave this issue to these type of applications, can we?
>>    I guess most of this kind of applications must have been well designed
>>    already.
>>
> I agree. (it's better to postpone this.)
> 
> But maybe cpuset (HPC) applications uses per-thread cgroup attachment.
> So, I can't say there is no trouble even if we ignore threads.
> 

Thank you for details.

I feel that we are near a consensus on this problem. To make clear this 
not only for developers but also for users what do you think about 
making documentation and implementing can_attach() to avoid not presumed 
attachments?

For example,
1. reject attachments of threads by can_attach(),
2. explain about what will and will not happen if we attach threads,
...

Thanks,
Yoshikawa
