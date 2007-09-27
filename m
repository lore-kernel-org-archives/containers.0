From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 3/5] Switch caches notification dynamically
Date: Thu, 27 Sep 2007 12:24:09 +0400
Message-ID: <46FB68A9.2070100@openvz.org>
References: <46F91841.9070708@openvz.org> <46F919BB.2000701@openvz.org>
	<Pine.LNX.4.64.0709251447560.5072@schroedinger.engr.sgi.com>
	<46FA28C9.9060101@openvz.org>
	<Pine.LNX.4.64.0709261029300.15435@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0709261029300.15435-RYO/mD75kfhx2SFC9UQUAuF7EQX82lMiAL8bYrjMMd8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Christoph Lameter <clameter-sJ/iWh9BUns@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Christoph Lameter wrote:
> On Wed, 26 Sep 2007, Pavel Emelyanov wrote:
> 
>>> Is it necessary to mark all the existing slabs with SLAB_DEBUG? Would it 
>> Yup. Otherwise we can never receive a single event e.g. if we make 
>> alloc/free in a loop, or similar, so that new slabs simply are not 
>> created.
> 
> Right but on the other hand: If objects in these slabs are freed then your 
> counters get decremented and may go negative.

Nope :) I store a pointer on each accounted object, so if I have
a notification about freeing of not-accounted object I will not
decrement my counter ;)

I think it's too hard (if possible at all) to handle at generic level
whether we have notified this particular object allocation to some
listener or not, so I'd better leave this for the listener to handle
such a case.

Thanks,
Pavel
