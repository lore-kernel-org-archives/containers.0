From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 1/3] export generic checkpoint headers to user space
Date: Fri, 29 May 2009 06:22:29 -0400
Message-ID: <4A1FB765.3000909@cs.columbia.edu>
References: <1243552253-7221-1-git-send-email-ntl@pobox.com>
	<20090529010217.GD17402@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090529010217.GD17402-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org


Applied all three to ckpt-v16-dev, thanks.

Oren.

Matt Helsley wrote:
> On Thu, May 28, 2009 at 06:10:51PM -0500, Nathan Lynch wrote:
>> Checkpoint-related headers are not properly exported, resulting in
>>
>> $ make ARCH=i386 headers_check -s
>> /home/nathanl/devel/linux-2.6.git/usr/include/linux/fs.h:11: included file 'linux/checkpoint_types.h' is not exported
>>
>> Export checkpoint_types.h and checkpoint_hdr.h.
>>
>> After this and arch-specific exports to follow, user-cr can be built
>> against the result of 'make headers_install'.
>>
>> Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
>> ---
> 
> You can apply this to all 3:
> 
> Acked-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> 
> Thanks for posting these.
> 
> Cheers,
> 	-Matt
> 
