From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH][cr-tests] pthread2: Test additional pthread attributes
Date: Mon, 11 Jan 2010 11:23:12 -0600
Message-ID: <20100111172312.GA16117@us.ibm.com>
References: <20100109012924.GA21607@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100109012924.GA21607-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Sukadev Bhattiprolu (sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> This test case currently fails with following errors in dmesg:
> Looks like the VM_NORESERVE flag on some maps triggers the error
> (CKPT_VMA_NOT_SUPPORTED includes the VM_NORESERVE flag)
> 
> 	[4999:4999:c/r:checkpoint_vmas:625] vma 0xb7200000-0xb7221000 flags
> 	0x200073
> 	[err -38][pos 102940][E @ checkpoint_vmas:629][pid 4976 tsk pthread2]
> 	vma: bad flags (0x200073)
> 	[4999:4999:c/r:checkpoint_task_objs:264] mm: objref -38
> 	[4999:4999:c/r:ckpt_write_obj_type:66] type 9999 len 8
> 	[4999:4999:c/r:ckpt_write_obj_type:66] type 5 len 93
> 	[err -38][pos 102940][E @ checkpoint_task_objs:266][pid 4976 tsk
> 	pthread2]mm_struct
> 	[4999:4999:c/r:checkpoint_task:450] objs -38
> 	[4999:4999:c/r:pgarr_release_pages:101] total pages 0
> ---
> 
> From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> Date: Sat, 26 Dec 2009 13:08:32 +0530
> Subject: [PATCH 1/3] pthread2: Test additional pthread attributes
> 
> Extend the test case to test all (most) pthread attributes in a single
> test.
> 
> Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>

All pass on my cr-next tree.  Applied and pushed.  thanks

-serge
