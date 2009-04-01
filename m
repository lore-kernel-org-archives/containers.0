From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 4/7] [RFC] Allow cgroup hierarchies to be created with
	no 	bound subsystems
Date: Wed, 01 Apr 2009 14:40:04 +0800
Message-ID: <49D30C44.8050802@cn.fujitsu.com>
References: <20090312104507.24154.71691.stgit@menage.corp.google.com>	
	<20090312105137.24154.34890.stgit@menage.corp.google.com>	
	<49BF470D.8080600@cn.fujitsu.com>
	<6599ad830903310145l7b24ad0vb4462f94390ac264@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830903310145l7b24ad0vb4462f94390ac264-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> On Mon, Mar 16, 2009 at 11:45 PM, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
>>> +static void init_root_id(struct cgroupfs_root *root)
>>> +{
>>> +     BUG_ON(!ida_pre_get(&hierarchy_ida, GFP_KERNEL));
>> we should return -errno, BUG_ON() on this is wrong
> 
> Hmm. Fair enough in the new root case, since it's possible we'd not
> get the memory then - I've changed init_root_id() to return false on
> failure. But I think that in cgroup_init(), we need to
> BUG_ON(!init_root_id()) - we shouldn't be able to fail that early in
> boot and there's no sensible way to handle it if it happens.
> 

agreed

>>> +     spin_lock(&hierarchy_id_lock);
>>> +     if (ida_get_new_above(&hierarchy_ida, next_hierarchy_id,
>>> +                           &root->hierarchy_id)) {
>>> +             BUG_ON(ida_get_new(&hierarchy_ida, &root->hierarchy_id));
>>> +     }
>> next_hierarchy_id is redundant, just use ida_get_new() instead of
>> ida_get_new_above()
> 
>>From the idr.c code it looks as though ida_get_new() always returns
> the smallest unused ID. I want to cycle through increasing IDs until
> we hit the end of the range, and then start again at 0.
> 

Makes sense, but it would be better to add a comment.

>> and I think we should check EAGAIN:
> 
> OK, I've changed this to handle EAGAIN. I don't see any value in
> handling ENOSPC though - we're not going to fill up a 31-bit IDR.
> 
>>> -     if (!opts->subsys_bits)
>>> +     if (!opts->subsys_bits && !opts->none)
>>>               return ERR_PTR(-EINVAL);
>>>
>> Shouldn't we check this in parse_cgroupfs_options() instead?
> 
> No, becase at that point it's valid - we can request the root named X
> without specifying what subsystems X is already mounted with. But if
> we don't find a root named X, then we're creating a new root, and we
> have to have specified a set of subsystems, or else explicitly "none".
> 

I see your poing. Again, better to have a comment in the code.

>> and what's the concern to not print out all the tasks? the buffer
>> limit of seqfile?
> 
> Yes.
> 

Hmm, I just had a try, and I found we don't need to worry about this,
seqfile can handle output that larger than PAGE_SIZE well.
