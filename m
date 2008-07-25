From: "Joe MacDonald" <joe.macdonald-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: memrlimit controller merge to mainline
Date: Fri, 25 Jul 2008 09:47:34 -0400
Message-ID: <840404080807250647y3dd52178y6b34e3e28d1cd6d0@mail.gmail.com>
References: <6599ad830807250114h7ab0fdb1u98c0968961647642@mail.gmail.com>
	<4889C77F.5090909@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4889C77F.5090909-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
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
To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: "hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org" <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

2008/7/25 Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>:

> There are applications that can/need to handle overcommit, just that we are not
> aware of them fully. Immediately after our meeting, I was pointed to
> http://www.linuxfoundation.org/en/Carrier_Grade_Linux/Requirements_Alpha1#AVL.4.1_VM_Strict_Over-Commit

I need to get caught up on this thread, but I did promise Balbir at
the mini-summit that I would appear soon-ish with actual use-cases on
this from some of the CGL folks.  Specifically the case I was thinking
of, other than the CGL requirement for VM Strict Overcommit, was finer
grained rlimit accounting.  It started out in the Collaboration Summit
meeting in Austin as a discussion about the SCOPE gaps document and
CGOS-4.5 (curiously called Coarse Resource Enforcement, when it's
really trying to address per-thread limits).

The full document is here in PDF form:

http://www.scope-alliance.org/pr/SCOPE_CGOS_GAPS_PROFILE_v2.pdf

I'm suspecting now, though, that after re-reading the requirement from
SCOPE and the memrlimit discussion, they may in fact be disjoint sets
of functionality.

-J.
