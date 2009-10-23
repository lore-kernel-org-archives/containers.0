From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 2/3] epoll: Add support for checkpointing large numbers
	of epoll items
Date: Fri, 23 Oct 2009 19:54:02 -0400
Message-ID: <4AE2421A.6060108@librato.com>
References: <ce2e15faf44e254b80578c6c62e71d8685516896.1255971848.git.matthltc@us.ibm.com>
	<d0fd1f3eb4eaa326488f59955e5b4790080f3073.1255971848.git.matthltc@us.ibm.com>
	<20091021145950.GA13327@us.ibm.com>
	<20091022064007.GG7757@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091022064007.GG7757-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org



Matt Helsley wrote:
> On Wed, Oct 21, 2009 at 09:59:50AM -0500, Serge E. Hallyn wrote:
>> Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
>>> Currently we allocate memory to output all of the epoll items in one
>>> big chunk. At 20 bytes per item, and since epoll was designed to
>>> support on the order of 10,000 items, we may find ourselves kmalloc'ing
>>> 200,000 bytes. That's an order 7 allocation whereas the heuristic for
>>> difficult allocations, PAGE_ALLOC_COST_ORDER, is 3.
>>>
>>> Instead, output the epoll header and items separately. Chunk the output
>>> much like the pid array gets chunked. This ensures that even sub-order 0
>>> allocations will enable checkpoint of large epoll sets. A subsequent
>>> patch will do something similar for the restore path.
>>>
>>> Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
>> Feels a bit auto-tune-magic-happy :) but looks good
> 
> Well it's not magic compared to guessing what a good number would be.
> There can be lots of these items and I figured that writing them in
> the biggest chunks possible could be useful.

What qualifies as a "good" number ?  Performance wise, I suspect
there isn't much difference between 4K, 8K and above buffers in
practice, compared to the total checkpoint time.

Oren.
