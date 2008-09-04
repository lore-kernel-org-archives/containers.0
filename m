From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v3][PATCH 7/9] Infrastructure for shared objects
Date: Thu, 04 Sep 2008 10:23:57 -0400
Message-ID: <48BFEF7D.7050809__45053.2240015038$1220538656$gmane$org@cs.columbia.edu>
References: <Pine.LNX.4.64.0809040354440.460@takamine.ncl.cs.columbia.edu>
	<Pine.LNX.4.64.0809040404550.5982@takamine.ncl.cs.columbia.edu>
	<20080904093803.GX14473@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080904093803.GX14473-Hu8+6S1rdjywhHL9vcZdMVaTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org



Louis Rilling wrote:
> On Thu, Sep 04, 2008 at 04:05:22AM -0400, Oren Laadan wrote:
>> Infrastructure to handle objects that may be shared and referenced by
>> multiple tasks or other objects, e..g open files, memory address space
>> etc.
>>
>> The state of shared objects is saved once. On the first encounter, the
>> state is dumped and the object is assigned a unique identifier and also
>> stored in a hash table (indexed by its physical kenrel address). From
>> then on the object will be found in the hash and only its identifier is
>> saved.
>>
>> On restart the identifier is looked up in the hash table; if not found
>> then the state is read, the object is created, and added to the hash
>> table (this time indexed by its identifier). Otherwise, the object in
>> the hash table is used.
>>
> 
> [...]
> 
>> diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
>> new file mode 100644
>> index 0000000..442b08c
>> --- /dev/null
>> +++ b/checkpoint/objhash.c
>> @@ -0,0 +1,205 @@
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
>> +#include <linux/ckpt.h>
>> +
>> +struct cr_objref {
>> +	int objref;
>> +	void *ptr;
>> +	unsigned short type;
>> +	unsigned short flags;
>> +	struct hlist_node hash;
>> +};
>> +
>> +struct cr_objhash {
>> +	struct hlist_head *head;
>> +	int objref_index;
>> +};
>> +
>> +#define CR_OBJHASH_NBITS  10
>> +#define CR_OBJHASH_TOTAL  (1UL << CR_OBJHASH_NBITS - 1)
> 
> Why -1? This makes a total number of 512 entries, which will break below with
> hashes in range 0..1023.

Ugh !!!  Was fixed and tested, but sneaked back in :(
Thanks for spotting, will resend the patchset.

Oren.

> 
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
>> +static void cr_objhash_clear(struct cr_objhash *objhash)
>> +{
>> +	struct hlist_head *h = objhash->head;
>> +	struct hlist_node *n, *t;
>> +	struct cr_objref *obj;
>> +	int i;
>> +
>> +	for (i = 0; i < CR_OBJHASH_TOTAL; i++) {
>> +		hlist_for_each_entry_safe(obj, n, t, &h[i], hash) {
>> +			cr_obj_ref_drop(obj);
>> +			kfree(obj);
>> +		}
>> +	}
>> +}
>> +
>> +void cr_objhash_free(struct cr_ctx *ctx)
>> +{
>> +	struct cr_objhash *objhash = ctx->objhash;
>> +
>> +	if (objhash) {
>> +		cr_objhash_clear(objhash);
>> +		kfree(objhash->head);
>> +		kfree(ctx->objhash);
>> +		ctx->objhash = NULL;
>> +	}
>> +}
>> +
>> +int cr_objhash_alloc(struct cr_ctx *ctx)
>> +{
>> +	struct cr_objhash *objhash;
>> +	struct hlist_head *head;
>> +
>> +	objhash = kzalloc(sizeof(*objhash), GFP_KERNEL);
>> +	if (!objhash)
>> +		return -ENOMEM;
>> +	head = kzalloc(CR_OBJHASH_TOTAL * sizeof(*head), GFP_KERNEL);
> 
> 512 entries allocated
> 
>> +	if (!head) {
>> +		kfree(objhash);
>> +		return -ENOMEM;
>> +	}
>> +
>> +	objhash->head = head;
>> +	objhash->objref_index = 1;
>> +
>> +	ctx->objhash = objhash;
>> +	return 0;
>> +}
>> +
>> +static struct cr_objref *cr_obj_find_by_ptr(struct cr_ctx *ctx, void *ptr)
>> +{
>> +	struct hlist_head *h;
>> +	struct hlist_node *n;
>> +	struct cr_objref *obj;
>> +
>> +	h = &ctx->objhash->head[hash_ptr(ptr, CR_OBJHASH_NBITS)];
> 
> access to entries 0..1023
> 
> Louis
> 
