From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH] Priority heap infrastructure enhancements
Date: Tue, 1 Jul 2008 01:14:14 -0700
Message-ID: <20080701011414.2f0cccb5.akpm@linux-foundation.org>
References: <1213796886-24863-1-git-send-email-balbir@linux.vnet.ibm.com>
	<6599ad830806210029x2a020e1ava6b646be9913fcdf@mail.gmail.com>
	<485CB652.90801@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <485CB652.90801-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
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
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Sat, 21 Jun 2008 13:35:38 +0530 Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:

> Paul Menage wrote:
> > On Wed, Jun 18, 2008 at 6:48 AM, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> >> Some of the common code has been factored into heap_adjust() a.k.a heapify
> >> in data structures terminology.
> >>
> >> I am sending out this  patch indepedent of the memory controller changes as
> >> they deserve to be reviewed independently.
> >>
> >> One limitation of the current heap_insert() routine is that it does not
> >> insert an element which is greater than the root, when the heap slots
> >> are fully used. I'll work on and review that interface and find a suitable
> >> way to address that issue
> > 
> > How else would you want it to behave? If you have a fixed size heap
> > and it's full, then you have to drop the largest value. (Well, you
> > could in theory drop the smallest value, but there's no quick way to
> > find that.)
> > 
> 
> I would like to be able to drop the smallest value. Since we cannot drop the
> smallest value, dropping a leaf (heap->size) should be sufficiently good enough.
> I want a max heap and losing the root of the heap does not work for me.
> 
> 
> >> Comments, Flames? Please do review closely!
> >>
> >> Signed-off-by: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> > 
> > Looks fine.
> > 
> > Reviewed-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> 
> Thanks for the review!
> 

yup, thanks.

I'll duck the patch until we have some code which uses it.  Please
retain Paul's Reviewed-by: for that occasion.
