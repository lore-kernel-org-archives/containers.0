From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/2] Extend sys_clone and sys_unshare system calls API
Date: Thu, 24 Jan 2008 18:09:56 +0100
Message-ID: <4798C664.1040409@fr.ibm.com>
References: <478DFF8F.9030006@openvz.org> <20080123205930.GA5233@ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080123205930.GA5233-+ZI9xUNit7I@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Pavel Machek wrote:
> On Wed 2008-01-16 15:58:55, Pavel Emelyanov wrote:
>> There's only one bit in the clone_flags left, so we won't be able 
>> to create more namespaces after we make it busy. Besides, for 
>> checkpoint/restart jobs we might want to create tasks with given
>> pids (virtual of course). And nobody knows for sure what else might 
>> be required from clone() in the future.
>>
>> This is an attempt to create a extendable API for clone and unshare.
>> Actually this patch is a request for comment about the overall
>> design. If it will turn out to "look good", then we'll select some
>> better names for new flag and data types.
>>
>> I use the last bit in the clone_flags for CLONE_LONGARG. When set it
>> will denote that the child_tidptr is not a pointer to a tid storage,
>> but the pointer to the struct long_clone_struct which currently 
>> looks like this:
>>
>> struct long_clone_arg {
>> 	int size;
>> };
> 
> Ugly as night, I'd say. (Al said it better). What about just adding
> clone2 syscall, that takes u64?

yes but we would need more something like  : 

 long sys_clone64(unsigned long flags_high, unsigned long flag_low)

if we want the syscall to be supported on 32bit arch. clone2 is also 
being used on ia64 already.

C.
