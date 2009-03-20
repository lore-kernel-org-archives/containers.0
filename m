From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v14-rc][PATCH 17/23] Record 'struct file' object instead
	of the file name for VMAs
Date: Fri, 20 Mar 2009 17:20:19 -0400
Message-ID: <49C40893.1060602@cs.columbia.edu>
References: <1237574868-3371-1-git-send-email-orenl@cs.columbia.edu>	
	<1237574868-3371-18-git-send-email-orenl@cs.columbia.edu>
	<1237582675.8286.281.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1237582675.8286.281.camel@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org



Dave Hansen wrote:
> On Fri, 2009-03-20 at 14:47 -0400, Oren Laadan wrote:
>> +       /* if file-backed, add 'file' to the hash (will keep a reference) */
>> +       if (vma->vm_file) {
>> +               new = cr_obj_add_ptr(ctx, vma->vm_file,
>> +                                    &objref, CR_OBJ_FILE, 0);
>> +               cr_debug("vma %p objref %d file %p)\n",
>> +                        vma, objref, vma->vm_file);
>> +               if (new < 0) {
>> +                       ret  = new;
>> +                       goto out;
>> +               }
>> +       }
> 
> This is a very, very common pattern in these patches now.
> 
> Can't we do better than this?  The objhash already has intimate
> knowledge of the files with which it deals.  So, why not also teach it
> how to write those into the checkpoint stream?  
>  
> int cr_obj_add_ptr(struct cr_ctx *ctx, void *ptr, int *objref,
>                    unsigned short type, unsigned short flags)
> {
>         struct cr_objref *obj;
>         int ret = 0;
> 
>         obj = cr_obj_find_by_ptr(ctx, ptr);
>         if (!obj) {
>                 obj = cr_obj_new(ctx, ptr, 0, type, flags);
>                 if (IS_ERR(obj))
>                         return PTR_ERR(obj);
>                 else
>                         ret = 1;
> 
>         } else if (obj->type != type)   /* sanity check */
>                 return -EINVAL;
>         *objref = obj->objref;
> -       return ret;
> +	return cr_write_object(ctx, ptr, type);
> }
> 
> int cr_write_object(ctx, ptr, type)
> {
> 	switch(type) {
> 		...
> 		case CR_OBJ_FILE:
> 			return cr_write_file(ctx, (file *)ptr);
> 		...
> 	}
> }
> 
> Why not?  It fits in with the rest of the objhash.
> 

Hmmm... interesting...

We need to first write the "parent" header -- the one that contains the
@objref _before_ the actual state of the shared object. I.e.:

	cr_hdr_vma  (type, file_objref, vma fields)
followed by (if applicable)
	cr_hdr_file (file object state)

so that during restart we read the vma, look at the objref value and
then decide if we need to read the file object next.

What you suggest will reverse the order ... so while we expect to find
a vma, we'll find a file object. I'm wonder if it's worth changing the
format and logic for this.

Oren.
