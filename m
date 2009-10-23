From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 2/3] epoll: Add support for checkpointing large numbers
	of epoll items
Date: Fri, 23 Oct 2009 19:58:56 -0400
Message-ID: <4AE24340.9030203@librato.com>
References: <ce2e15faf44e254b80578c6c62e71d8685516896.1255971848.git.matthltc@us.ibm.com>
	<d0fd1f3eb4eaa326488f59955e5b4790080f3073.1255971848.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <d0fd1f3eb4eaa326488f59955e5b4790080f3073.1255971848.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
> Currently we allocate memory to output all of the epoll items in one
> big chunk. At 20 bytes per item, and since epoll was designed to
> support on the order of 10,000 items, we may find ourselves kmalloc'ing
> 200,000 bytes. That's an order 7 allocation whereas the heuristic for
> difficult allocations, PAGE_ALLOC_COST_ORDER, is 3.
> 
> Instead, output the epoll header and items separately. Chunk the output
> much like the pid array gets chunked. This ensures that even sub-order 0
> allocations will enable checkpoint of large epoll sets. A subsequent
> patch will do something similar for the restore path.
> 
> Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Acked-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

BTW, In the future, please use checkpatch.pl before sending;
Otherwise eventually I get yelled at ... :p

I'll fix this patchset as I pull.

I'll also change the auto-tune-magic to fixed chunk, unless
somebody screams.

Oren.
