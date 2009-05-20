From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v14][PATCH 35/54] Support for share memory address spaces
Date: Wed, 20 May 2009 14:23:45 -0400
Message-ID: <4A144AB1.3050506@cs.columbia.edu>
References: <1240961064-13991-1-git-send-email-orenl@cs.columbia.edu>	
	<1240961064-13991-36-git-send-email-orenl@cs.columbia.edu>
	<1242842156.13972.79.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1242842156.13972.79.camel@nimitz>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org



Dave Hansen wrote:
> On Tue, 2009-04-28 at 19:24 -0400, Oren Laadan wrote:
>> +static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
>> +{
>> +       struct ckpt_hdr_task_objs *h;
>> +       int mm_objref;
>> +       int ret;
>> +
>> +       mm_objref = checkpoint_mm_obj(ctx, t);
>> +       ckpt_debug("memory: objref %d\n", mm_objref);
>> +       if (mm_objref < 0)
>> +               return mm_objref;
>> +
>> +       h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_TASK_OBJS);
>> +       if (!h)
>> +               return -ENOMEM;
>> +
>> +       h->mm_objref = mm_objref;
>> +
>> +       ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
>> +       ckpt_hdr_put(ctx, h);
>> +       return ret;
>> +}
> 
> I wonder if this gets easier or harder to parse if you do this instead:
> 
> 	ret = ckpt_write_obj(ctx, &h.h);
> 
> It is kinda what we already do for things that use container_of().  
> 

Fine with me.

Oren
