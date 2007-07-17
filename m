From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: Containers: css_put() dilemma
Date: Tue, 17 Jul 2007 07:51:06 +0530
Message-ID: <469C2792.6050009@linux.vnet.ibm.com>
References: <469BBE00.8000709@linux.vnet.ibm.com>
	<6599ad830707161203o7f148c75p52e77d4be3ace487@mail.gmail.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830707161203o7f148c75p52e77d4be3ace487-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: =?windows-1252?Q?=22Paul_=28=3F=3F=29_Menage=22?= <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org>, Pavel Emelianov <xemul-3ImXcnM4P+0@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, linux kernel mailing list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Paul (??) Menage wrote:
> On 7/16/07, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
>> Hi, Paul,
>>
>> I've run into a strange problem with css_put(). After the changes for
>> notify_on_release(), the css_put() routine can now block and it blocks on
>> the container_mutex. This implies that css_put() cannot be called if
>>
>> 1. We cannot block
>> 2. We already hold the container_mutex
>>
>> The problem I have is that of preventing the destruction of my container
>> (when the user does rmdir). If the user migrates away all tasks and does
>> an rmdir, the only way to prevent the container from going away is
>> through
>> css_get() references. In my case, some pages have been allocated from the
>> container and hence I do not want it to go away, until all the pages
>> charged to it are freed. When I use css_get/put() to prevent destruction
>> I am blocked by the limitations of css_put() listed above.
>>
>> Do you have any recommendations for a cleaner solution? I suspect we'll
>> need can_destroy() callbacks (similar to can_attach()).
> 
> I think moving the release_list synchronization inside a separate
> spinlock, and thus not requiring container_mutex to be held for
> check_for_release(), is the simplest solution. I'll do that. I'm
> hoping to get a new set of patches to Andrew today or tomorrow.
> 

That sounds good to me. But I worry about having to do release synchronization
on every css_put(). The current patch I have, but does not work 100%
does the following (WARNING: white spaces ahead, do not use the patch
directly)

-       if (notify_on_release(cont)) {
+       if (atomic_dec_and_test(&css->refcnt) && notify_on_release(cont)) {
                mutex_lock(&container_mutex);
                set_bit(CONT_RELEASABLE, &cont->flags);
-               if (atomic_dec_and_test(&css->refcnt)) {
-                       check_for_release(cont);
-               }
+               check_for_release(cont);
                mutex_unlock(&container_mutex);

That way we set the CONT_RELEASABLE bit only when the ref count drops
to zero.


> Adding a can_destroy() callback is possible, but since I envisage that
> most subsystems that would want to implement it would basically be
> doing reference counting anyway, it seems worth having a generic
> reference counting mechanism in the framework. In particular, since
> once the container does become releasable due to all the
> subsystem-specific refcounts being released, we want to be able to
> invoke the release agent, we'll end up with the same synchronization
> problems that we have now if we just pushed everything into a
> can_destroy() method. (Unless the framework polled all can_destroy()
> methods for potentially-removable containers, which seems a bit
> nasty).
> 
> We can add can_destroy() if we encounter a situation that can't be
> handled by generic reference counting.
> 

Yes, that is correct, the advantage is that with can_destroy() we
don't need to go through release synchronization each time we do
a css_put(). May be the patch above will fix the problem along
with your release locking proposal.


> Paul
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
