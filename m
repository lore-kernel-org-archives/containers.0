From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC cr-pipe-v13][PATCH 2/3] Checkpoint open pipes
Date: Fri, 06 Feb 2009 14:05:16 +0100
Message-ID: <498C358C.30902@fr.ibm.com>
References: <1233091395-24582-1-git-send-email-orenl@cs.columbia.edu>
	<1233091395-24582-4-git-send-email-orenl@cs.columbia.edu>
	<498AB553.3090902@fr.ibm.com>
	<20090205202637.4d4f4a29@thinkcentre.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090205202637.4d4f4a29-4v5LP+xe+1byhTdZtsIeww@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Nathan Lynch wrote:
> On Thu, 05 Feb 2009 10:45:55 +0100
> Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> wrote:
> 
>>>  
>>> +/* cr_write_pipebuf - dump contents of a pipe/fifo (assume i_mutex taken) */
>>> +static int cr_write_pipebuf(struct cr_ctx *ctx, struct pipe_inode_info *pipe)
>>> +{
>>> +	struct cr_hdr h;
>>> +	void *kbuf, *addr;
>>> +	int i, ret = 0;
>>> +
>>> +	kbuf = (void *) __get_free_page(GFP_KERNEL);
>> this can sleep and inode->i_mutex is locked.
> 
> Generally, it is okay to perform operations that may sleep while
> holding a mutex (not so with spinlocks, though).  Unless the page
> allocator could try to acquire the same inode->i_mutex, this code
> should be fine, no?

indeed. sorry for the noise.   

C.
