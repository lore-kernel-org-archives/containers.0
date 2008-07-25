From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: memrlimit controller merge to mainline
Date: Fri, 25 Jul 2008 08:30:55 -0400
Message-ID: <4889C77F.5090909@linux.vnet.ibm.com>
References: <6599ad830807250114h7ab0fdb1u98c0968961647642@mail.gmail.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830807250114h7ab0fdb1u98c0968961647642-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: "hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org" <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> Hi Balbir,
> 
> Andrew included the memrlimit controller in his latest set of patches
> to Linus for mainline.
> 
> Although the memrlimit controller basically works as intended, my
> impression from the mini-summit on Tuesday is that our consensus is
> that this still doesn't have concrete practical use-cases yet:
> 
> - avoiding swap over-use is better handled by the forthcoming swap controller
> 
> - applications that can usefully handle mmap() returning NULL don't
> really exist yet (and since the system as a whole allows address space
> overcommit limits, if it was practical/useful to write such apps then
> presumably they would already exist)
> 

There are applications that can/need to handle overcommit, just that we are not
aware of them fully. Immediately after our meeting, I was pointed to
http://www.linuxfoundation.org/en/Carrier_Grade_Linux/Requirements_Alpha1#AVL.4.1_VM_Strict_Over-Commit

> So I think we'd be complicating some of the vm paths in mainline with
> a feature that isn't likely to get a lot of real use.
> 

I did disagree in the meeting and there is also the use case of the feature
forming the infrastructure for other rlimit controllers.

> What do you (and others on the containers list) think? Should we ask
> Andrew/Linus to hold off on this for now? My preference would be to do
> that until we have someone who can stand up with a concrete scenario
> where they want to use this in a real environment.

While we can argue about use cases, the feature needs more testing and I am OK
holding off/reverting the merge to make it more stable and that would give us
more time to argue on its usefulness. To say that overcommit handling is not
useful is wrong. Meanwhile, I'll go back and look at the bug report that Hugh
has posted and also look at building an mlock controller on top of memrlimits.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
