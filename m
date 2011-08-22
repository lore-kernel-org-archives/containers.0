From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: cpuset.sched_relax_domain_level problem
Date: Mon, 22 Aug 2011 09:08:41 +0800
Message-ID: <4E51AC19.4010208__38166.0617691979$1313975342$gmane$org@cn.fujitsu.com>
References: <CABcS5h13R0omxkZW_aJaza9FynbKSc=CVaYDkHMvJ64nAnWPvw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CABcS5h13R0omxkZW_aJaza9FynbKSc=CVaYDkHMvJ64nAnWPvw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: rolando.martins-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Hidetoshi Seto <seto.hidetoshi-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Add Cc's

Rolando Martins wrote:
> Hi,
> I am testing kernel 3.0.3 and I am unable to "echo 3 >
> cpuset.sched_relax_domain_level".
> I was able to do it in 2.6.39.
> 
> Any clues?
> 

I think it's because your machine doesn't support level 3.

This commit made the change:

commit 60495e7760d8ee364695006af37309b0755e0e17
Author: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
Date:   Thu Apr 7 14:10:04 2011 +0200

    sched: Dynamic sched_domain::level
    
    Remove the SD_LV_ enum and use dynamic level assignments.
