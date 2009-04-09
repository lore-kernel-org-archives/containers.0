From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v14-rc3][PATCH 33/36] Support for share memory address	spaces
Date: Thu, 09 Apr 2009 18:13:11 -0400
Message-ID: <49DE72F7.9040001@cs.columbia.edu>
References: <1239107264-21775-1-git-send-email-orenl@cs.columbia.edu>
	<1239107264-21775-34-git-send-email-orenl@cs.columbia.edu>
	<20090409210302.GA5115@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090409210302.GA5115-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
>> The task address space (task->mm) may be shared between processes if
>> CLONE_VM is used, and particularly among threads. Accordingly, treat
>> 'task->mm' as a shared object: during checkpoint check against the
>> objhash and only dump the contents if seen for the first time. During
>> restart, likewise, only restore if it's a new instance, otherwise use
>> the one already registered in the objhash.
>>
>> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
> 
> Cool.
> 
> Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> 
> Although:
> 
>> +	/* if the mm's objref is in the objhash, use that instance */
>> +	mm = cr_obj_get_by_ref(ctx, hh->objref, CR_OBJ_MM);
>> +	if (IS_ERR(mm)) {
>> +		ret = PTR_ERR(mm);
>> +		goto out;
>> +	}
>>
>> +	if (mm) {
>> +		if (mm != current->mm) {
> 
> In what twisted world could mm == current->mm at restart?

Tasks are re-created in user space, and so are threads. So threads will
already have their 'mm' set correctly.

Oren.

> 
>> +			ret = exec_mmap(mm);
>> +			if (ret < 0)
>> +				goto out;
>> +			atomic_inc(&mm->mm_users);
>> +		}
>> +		ret = 0;
>> +		goto out;
>> +	}
>> +
>> +	/* otherwise, add our mm to the objhash for future generations */
>>  	mm = current->mm;
>> +	ret = cr_obj_add_ref(ctx, mm, hh->objref, CR_OBJ_MM, 0);
>> +	if (ret < 0)
>> +		goto out;
>>
>>  	/* point of no return -- destruct current mm */
>>  	down_write(&mm->mmap_sem);
>> diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
>> index 043535c..1bfe284 100644
>> --- a/include/linux/checkpoint.h
>> +++ b/include/linux/checkpoint.h
>> @@ -77,6 +77,7 @@ extern void cr_ctx_put(struct cr_ctx *ctx);
>>  enum {
>>  	CR_OBJ_FILE = 1,
>>  	CR_OBJ_INODE,
>> +	CR_OBJ_MM,
>>  	CR_OBJ_MAX
>>  };
>>
>> -- 
>> 1.5.4.3
> 
