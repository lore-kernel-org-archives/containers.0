From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v5][PATCH 7/8] Infrastructure for shared objects
Date: Tue, 16 Sep 2008 17:36:45 -0400
Message-ID: <48D026ED.3080109@cs.columbia.edu>
References: <1221347167-9956-1-git-send-email-orenl@cs.columbia.edu>
	<1221347167-9956-8-git-send-email-orenl@cs.columbia.edu>
	<20080916205459.GA7644@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080916205459.GA7644-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
>> Infrastructure to handle objects that may be shared and referenced by
>> multiple tasks or other objects, e..g open files, memory address space
>> etc.
>>
>> The state of shared objects is saved once. On the first encounter, the
>> state is dumped and the object is assigned a unique identifier (objref)
>> and also stored in a hash table (indexed by its physical kenrel address).
>> >From then on the object will be found in the hash and only its identifier
>> is saved.
>>
>> On restart the identifier is looked up in the hash table; if not found
>> then the state is read, the object is created, and added to the hash
>> table (this time indexed by its identifier). Otherwise, the object in
>> the hash table is used.
>>
>> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
> 
> Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> 
> Thanks, Oren, I actually think this is quite nice and readable.
> 
> Though three questions below.  First one is, since you've mentioned
> having multiple threads doing checkpoint, won't you need some locking?

yes.

> I assume that's coming in later patches if/when needed?

yes.

[...]

>> +++ b/checkpoint/objhash.c
>> @@ -0,0 +1,237 @@
>> +/*
>> + *  Checkpoint-restart - object hash infrastructure to manage shared objects
>> + *
>> + *  Copyright (C) 2008 Oren Laadan
>> + *
>> + *  This file is subject to the terms and conditions of the GNU General Public
>> + *  License.  See the file COPYING in the main directory of the Linux
>> + *  distribution for more details.
>> + */
>> +
>> +#include <linux/kernel.h>
>> +#include <linux/file.h>
>> +#include <linux/hash.h>
>> +#include <linux/checkpoint.h>
>> +
>> +struct cr_objref {
>> +	int objref;
>> +	void *ptr;
>> +	unsigned short type;
> 
> What is the point of the 'type'?
> 
> By that I mean: is it meant to catch bugs in the implementation, or bad
> checkpoint images?

The hash table is maintained in the kernel during checkpoint/restart,
adding shared objects to the hash table when they are first seen. An
object can be a 'struct file', 'struct mm_struct', etc.

When an object is added, it's reference count is incremented to ensure
that the pointer is still valid for as long as it's in the hash table.
Similarly, when we remove an object from the hash, we need to decrement
the reference count. This is done in cr_obj_ref_grab(), cr_obj_ref_drop().

There are different functions to inc/dec the reference count of objects
of different types. '->type' keeps track of the type of the object, so
we know which function to call. (At this point, we only track shared
'struct file' so it isn't that clear from the code).

> 
>> +	unsigned short flags;
>> +	struct hlist_node hash;
>> +};
>> +
>> +struct cr_objhash {
>> +	struct hlist_head *head;
>> +	int objref_index;
> 
> What exactly will objref_index be used for?  I don't see any real
> usage here or in your later patches.
> 

'objref_index' is a counter used to assign unique identifiers (objref)
to objects as they are added to the hash table. It is incremented with
every object that joins the hash table (and the old value is used as
the objref of that object). It is used in cr_obj_new().

>> +};
>> +
>> +#define CR_OBJHASH_NBITS  10
>> +#define CR_OBJHASH_TOTAL  (1UL << CR_OBJHASH_NBITS)
>> +
>> +static void cr_obj_ref_drop(struct cr_objref *obj)
>> +{
>> +	switch (obj->type) {
>> +	case CR_OBJ_FILE:
>> +		fput((struct file *) obj->ptr);
>> +		break;
>> +	default:
>> +		BUG();
>> +	}
>> +}
>> +
>> +static void cr_obj_ref_grab(struct cr_objref *obj)
>> +{
>> +	switch (obj->type) {
>> +	case CR_OBJ_FILE:
>> +		get_file((struct file *) obj->ptr);
>> +		break;
>> +	default:
>> +		BUG();
>> +	}
>> +}
>> +

[...]

>> +static struct cr_objref *cr_obj_new(struct cr_ctx *ctx, void *ptr, int objref,
>> +				    unsigned short type, unsigned short flags)
>> +{
>> +	struct cr_objref *obj;
>> +
>> +	obj = kmalloc(sizeof(*obj), GFP_KERNEL);
>> +	if (obj) {
>> +		int i;
>> +
>> +		obj->ptr = ptr;
>> +		obj->type = type;
>> +		obj->flags = flags;
>> +
>> +		if (objref) {
>> +			/* use 'objref' to index (restart) */
>> +			obj->objref = objref;
>> +			i = hash_ptr((void *) objref, CR_OBJHASH_NBITS);
>> +		} else {
>> +			/* use 'ptr' to index, assign objref (checkpoint) */
>> +			obj->objref = ctx->objhash->objref_index++;;
>> +			i = hash_ptr(ptr, CR_OBJHASH_NBITS);
>> +		}
>> +
>> +		hlist_add_head(&obj->hash, &ctx->objhash->head[i]);
>> +		cr_obj_ref_grab(obj);
>> +	}
>> +	return obj;
>> +}

[...]

Oren.
