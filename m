From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 2/4] cr: add generic LSM c/r support (v6)
Date: Tue, 20 Oct 2009 21:03:38 -0400
Message-ID: <4ADE5DEA.2000606@librato.com>
References: <20091019144315.GA30535@us.ibm.com>
	<20091019144341.GA30566@us.ibm.com> <4ADCAC5B.9080205@librato.com>
	<20091019190227.GA7201@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091019190227.GA7201-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
> Quoting Oren Laadan (orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org):
>>> 	oct 19: At checkpoint, we insert the void* security into the
>>> 		objhash.  The first time that we do so, we next write out
>>> 		the string representation of the context to the checkpoint
>>> 		image, along with the value of the objref for the void*
>>> 		security, and insert that into the objhash.  Then at
>>> 		restart, when we read a LSM context, we read the objref
>>> 		which the void* security had at checkpoint, and we then
>>> 		insert the string context with that objref as well.
>> I hoped to see similar comment inlined in the code.
> 
> If we're happy with this approach, then I will add good comments above
> security_checkpoint_obj and security_restore_obj, and above the objhash
> entries.

[...]

>>> +/**
>>> + * security_checkpoint_obj - if first checkpoint of this void* security,
>>> + * then 1. ask the LSM for a string representing the context, 2. checkpoint
>>> + * that string
>>> + * @ctx: the checkpoint context
>>> + * @security: the void* security being checkpointed
>>> + * @sectype: indicates the type of object, because LSMs can (and do) store
>>> + * @secref: We return the objref here
>>> + * different types of data for different types of objects.
>>> + *
>>> + * Returns the objref of the checkpointed ckpt_lsm_string representing the
>>> + * context, or -error on error.
>>> + *
>>> + * This is only used at checkpoint of course.
>>> + */
>>> +int security_checkpoint_obj(struct ckpt_ctx *ctx, void *security,
>>> +				int sectype, int *secref)
>> This function returns 0 for success or a negative error. It should
>> return the @secref instead of passing it by reference (see your
>> description of the return value above !)
>>
>> [...]
> 
> Yes the comment is out of date but the API is imo an improvement.
> Note that SECURITY_CTX_NONE, -1, is a meaningful secref, and at
> the sametime -EPERM, -1, is conceivably a valid error code (though
> at the moment no lsm will return it).
> 
> So I think overloading the secref with error codes is wrong here.

How about #define SECURITY_CTX_NONE 0 ?
it isn't a valid objref anyway.

[...]

Oren.
