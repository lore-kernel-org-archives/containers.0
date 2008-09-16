From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC v5][PATCH 7/8] Infrastructure for shared objects
Date: Tue, 16 Sep 2008 09:48:19 -0700
Message-ID: <1221583699.20360.10.camel@nimitz>
References: <1221347167-9956-1-git-send-email-orenl@cs.columbia.edu>
	<1221347167-9956-8-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1221347167-9956-8-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org
List-Id: containers.vger.kernel.org

On Sat, 2008-09-13 at 19:06 -0400, Oren Laadan wrote:
> +=== Shared resources (objects)
> +
> +Many resources used by tasks may be shared by more than one task (e.g.
> +file descriptors, memory address space, etc), or even have multiple
> +references from other resources (e.g. a single inode that represents
> +two ends of a pipe).
> +
> +Clearly, the state of shared objects need only be saved once, even if
> +they occur multiple times. We use a hash table (ctx->objhash) to keep
> +track of shared objects in the following manner.
> +
> +On the first encounter, the state is dumped and the object is assigned
> +a unique identifier and also stored in the hash table (indexed by its
> +physical kenrel address). From then on the object will be found in the
> +hash and only its identifier is saved.

kernel?     ^^^^^^

> +On restart the identifier is looked up in the hash table; if not found
> +then the state is read, the object is created, and added to the hash
> +table (this time indexed by its identifier). Otherwise, the object in
> +the hash table is used.
> +
> +The interface for the hash table is the following:
> +
> +cr_obj_get_by_ptr - find the unique identifier - object reference (objref)
> +  of the object that is pointer to by ptr (or 0 if not found) [checkpoint]
> +
> +cr_obj_add_ptr - add the object pointed to by ptr to the hash table if
> +  it isn't already there, and fill its unique identifier (objref); will
> +  return 0 if already found in the has, or 1 otherwise [checkpoint]
> +
> +cr_obj_get_by_ref - return the pointer to the object whose unique identifier
> +  is equal to objref [restart]
> +
> +cr_obj_add_ref - add the object with unique identifier objref, pointed to by
> +  ptr to the hash table if it isn't already there; will return 0 if already
> +  found in the has, or 1 otherwise [restart]

I'd much rather see all this documentation put properly inline with the
source code.  I doubt anyone will actually find this stuff.

> +
>  === Changelog
> 
>  [2008-Sep-11] v5:
> diff --git a/checkpoint/Makefile b/checkpoint/Makefile
> index ac35033..9843fb9 100644
> --- a/checkpoint/Makefile
> +++ b/checkpoint/Makefile
> @@ -2,5 +2,5 @@
>  # Makefile for linux checkpoint/restart.
>  #
> 
> -obj-$(CONFIG_CHECKPOINT_RESTART) += sys.o checkpoint.o restart.o \
> +obj-$(CONFIG_CHECKPOINT_RESTART) += sys.o checkpoint.o restart.o objhash.o \
>  		ckpt_mem.o rstr_mem.o
> diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
> new file mode 100644
> index 0000000..0862086
> --- /dev/null
> +++ b/checkpoint/objhash.c
> @@ -0,0 +1,237 @@
> +/*
> + *  Checkpoint-restart - object hash infrastructure to manage shared objects
> + *
> + *  Copyright (C) 2008 Oren Laadan
> + *
> + *  This file is subject to the terms and conditions of the GNU General Public
> + *  License.  See the file COPYING in the main directory of the Linux
> + *  distribution for more details.
> + */
> +
> +#include <linux/kernel.h>
> +#include <linux/file.h>
> +#include <linux/hash.h>
> +#include <linux/checkpoint.h>
> +
> +struct cr_objref {
> +	int objref;
> +	void *ptr;
> +	unsigned short type;
> +	unsigned short flags;
> +	struct hlist_node hash;
> +};
> +
> +struct cr_objhash {
> +	struct hlist_head *head;
> +	int objref_index;
> +};
> +
> +#define CR_OBJHASH_NBITS  10
> +#define CR_OBJHASH_TOTAL  (1UL << CR_OBJHASH_NBITS)
> +
> +static void cr_obj_ref_drop(struct cr_objref *obj)
> +{
> +	switch (obj->type) {
> +	case CR_OBJ_FILE:
> +		fput((struct file *) obj->ptr);
> +		break;
> +	default:
> +		BUG();
> +	}
> +}
> +
> +static void cr_obj_ref_grab(struct cr_objref *obj)
> +{
> +	switch (obj->type) {
> +	case CR_OBJ_FILE:
> +		get_file((struct file *) obj->ptr);
> +		break;
> +	default:
> +		BUG();
> +	}
> +}
> +
> +static void cr_objhash_clear(struct cr_objhash *objhash)
> +{
> +	struct hlist_head *h = objhash->head;
> +	struct hlist_node *n, *t;
> +	struct cr_objref *obj;
> +	int i;
> +
> +	for (i = 0; i < CR_OBJHASH_TOTAL; i++) {
> +		hlist_for_each_entry_safe(obj, n, t, &h[i], hash) {
> +			cr_obj_ref_drop(obj);
> +			kfree(obj);
> +		}
> +	}
> +}
> +
> +void cr_objhash_free(struct cr_ctx *ctx)
> +{
> +	struct cr_objhash *objhash = ctx->objhash;
> +
> +	if (objhash) {
> +		cr_objhash_clear(objhash);
> +		kfree(objhash->head);
> +		kfree(ctx->objhash);
> +		ctx->objhash = NULL;
> +	}
> +}
> +int cr_objhash_alloc(struct cr_ctx *ctx)
> +{
> +	struct cr_objhash *objhash;
> +	struct hlist_head *head;
> +
> +	objhash = kzalloc(sizeof(*objhash), GFP_KERNEL);
> +	if (!objhash)
> +		return -ENOMEM;
> +	head = kzalloc(CR_OBJHASH_TOTAL * sizeof(*head), GFP_KERNEL);
> +	if (!head) {
> +		kfree(objhash);
> +		return -ENOMEM;
> +	}
> +
> +	objhash->head = head;
> +	objhash->objref_index = 1;
> +
> +	ctx->objhash = objhash;
> +	return 0;
> +}
> +
> +static struct cr_objref *cr_obj_find_by_ptr(struct cr_ctx *ctx, void *ptr)
> +{
> +	struct hlist_head *h;
> +	struct hlist_node *n;
> +	struct cr_objref *obj;
> +
> +	h = &ctx->objhash->head[hash_ptr(ptr, CR_OBJHASH_NBITS)];
> +	hlist_for_each_entry(obj, n, h, hash)
> +		if (obj->ptr == ptr)
> +			return obj;
> +	return NULL;
> +}
> +
> +static struct cr_objref *cr_obj_find_by_objref(struct cr_ctx *ctx, int objref)
> +{
> +	struct hlist_head *h;
> +	struct hlist_node *n;
> +	struct cr_objref *obj;
> +
> +	h = &ctx->objhash->head[hash_ptr((void *) objref, CR_OBJHASH_NBITS)];
> +	hlist_for_each_entry(obj, n, h, hash)
> +		if (obj->objref == objref)
> +			return obj;
> +	return NULL;
> +}
> +
> +static struct cr_objref *cr_obj_new(struct cr_ctx *ctx, void *ptr, int objref,
> +				    unsigned short type, unsigned short flags)
> +{
> +	struct cr_objref *obj;
> +
> +	obj = kmalloc(sizeof(*obj), GFP_KERNEL);
> +	if (obj) {
> +		int i;
> +
> +		obj->ptr = ptr;
> +		obj->type = type;
> +		obj->flags = flags;
> +
> +		if (objref) {
> +			/* use 'objref' to index (restart) */
> +			obj->objref = objref;
> +			i = hash_ptr((void *) objref, CR_OBJHASH_NBITS);
> +		} else {
> +			/* use 'ptr' to index, assign objref (checkpoint) */
> +			obj->objref = ctx->objhash->objref_index++;;
> +			i = hash_ptr(ptr, CR_OBJHASH_NBITS);
> +		}
> +
> +		hlist_add_head(&obj->hash, &ctx->objhash->head[i]);
> +		cr_obj_ref_grab(obj);
> +	}
> +	return obj;
> +}
> +
> +/**
> + * cr_obj_add_ptr - add an object to the hash table if not already there
> + * @ctx: checkpoint context
> + * @ptr: pointer to object
> + * @objref: unique identifier - object reference [output]
> + * @type: object type
> + * @flags: object flags
> + *
> + * Fills the unique identifier of the object into @objref
> + *
> + * returns 0 if found, 1 if added, < 0 on error
> + */
> +int cr_obj_add_ptr(struct cr_ctx *ctx, void *ptr, int *objref,
> +		   unsigned short type, unsigned short flags)
> +{
> +	struct cr_objref *obj;
> +	int ret = 0;
> +
> +	obj = cr_obj_find_by_ptr(ctx, ptr);
> +	if (!obj) {
> +		obj = cr_obj_new(ctx, ptr, 0, type, flags);
> +		if (!obj)
> +			return -ENOMEM;
> +		else
> +			ret = 1;
> +	} else if (obj->type != type)	/* sanity check */
> +		return -EINVAL;
> +	*objref = obj->objref;
> +	return ret;
> +}
> +
> +/**
> + * cr_obj_add_ref - add an object with unique identifer to the hash table
> + * @ctx: checkpoint context
> + * @ptr: pointer to object
> + * @objref: unique identifier - object reference
> + * @type: object type
> + * @flags: object flags
> + */
> +int cr_obj_add_ref(struct cr_ctx *ctx, void *ptr, int objref,
> +		   unsigned short type, unsigned short flags)
> +{
> +	struct cr_objref *obj;
> +
> +	obj = cr_obj_new(ctx, ptr, objref, type, flags);
> +	return obj ? 0 : -ENOMEM;
> +}
> +
> +/**
> + * cr_obj_get_by_ptr - find the unique identifier (objref) of an object
> + * @ctx: checkpoint context
> + * @ptr: pointer to object
> + * @type: object type
> + */
> +int cr_obj_get_by_ptr(struct cr_ctx *ctx, void *ptr, unsigned short type)
> +{
> +	struct cr_objref *obj;
> +
> +	obj = cr_obj_find_by_ptr(ctx, ptr);
> +	if (obj)
> +		return obj->type == type ? obj->objref : -EINVAL;
> +	else
> +		return -ESRCH;
> +}

I have some nits about some of that.  I'd prefer to see the main code
flow of the functions get taken out of the if(){} blocks and put at the
first indenting level (cr_obj_new() could use this).

One other nit would be to try and get rid of some of the '?:' use.  I
personally find those hard to read and we don't use them that heavily in
the core kernel.  For instance, the above can be written:

	obj = cr_obj_find_by_ptr(ctx, ptr);
	if (!obj)
		return -ESRCH;
	if (obj->type != type)
		return -EINVAL;
	return obj->objref;

Which make the error conditions and their results just pop out much
easier at the cost of a single added line of code.

-- Dave
