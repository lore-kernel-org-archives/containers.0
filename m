From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 1/1] cr: fix ckpt_obj_fetch return values (v2)
Date: Thu, 14 May 2009 11:34:38 -0400
Message-ID: <4A0C3A0E.3080008@cs.columbia.edu>
References: <20090513210641.GA22784@us.ibm.com>
	<4A0BF2AD.8030304@cs.columbia.edu>
	<20090514141449.GA4972@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090514141449.GA4972-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
>>> @@ -1246,9 +1244,7 @@ int restore_mm_obj(struct ckpt_ctx *ctx, int mm_objref)
>>>  	int ret;
>>>  
>>>  	mm = ckpt_obj_fetch(ctx, mm_objref, CKPT_OBJ_MM);
>>> -	if (!mm)
>>> -		return -EINVAL;
>>> -	else if (IS_ERR(mm))
>>> +	if (IS_ERR(mm))
>>>  		return -EINVAL;
>> 			^^^^^^
>> should be:		PTR_ERR(mm);
> 
> Oops, right.
> 
>>> diff --git a/fs/pipe.c b/fs/pipe.c
>>> index ab2de3c..b284dcb 100644
>>> --- a/fs/pipe.c
>>> +++ b/fs/pipe.c
>>> @@ -982,14 +982,12 @@ struct file *pipe_file_restore(struct ckpt_ctx *ctx, struct ckpt_hdr_file *ptr)
>>>  		return ERR_PTR(-EINVAL);
>>>  
>>>  	file = ckpt_obj_fetch(ctx, h->pipe_objref, CKPT_OBJ_FILE);
>>> -	if (IS_ERR(file))
>>> -		return file;
>>>  	/*
>>> -	 * If ckpt_obj_fetch() returned NULL, then this is the first
>>> +	 * If ckpt_obj_fetch() returned -EINVAL, then this is the first
>>>  	 * time we see this pipe so need to restore the contents.
>>>  	 * Otherwise, use the file pointer skip forward.
>>>  	 */
>>> -	if (!file) {
>>> +	if (PTR_ERR(file) == -EINVAL) {
>> ckpt_obj_fetch() will also fail with -EINVAL if the type of the object
>> found doesn't match the type that was requested. Hence why originally
>> the two return values. So I changed that latter to report -ENOMSG (that
>> is:  /* No message of desired type */)
> 
> Hmm, yes I was thinking of the checkpoint case where mismatched types
> would be strictly an objhash bug.  You're right, this case can just
> be a bad checkpoint image!

Actually, there was also a bit of logic change required for uts_ns
and ipc_ns. Fixed that too.

Oren.
