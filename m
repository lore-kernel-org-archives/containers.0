From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: Namespaces exhausted CLONE_XXX bits problem
Date: Mon, 14 Jan 2008 19:52:21 +0300
Message-ID: <478B9345.30004@openvz.org>
References: <478B6764.6050300@openvz.org> <478B7549.2020000@fr.ibm.com>
	<478B76C4.8050804@openvz.org> <478B7DB3.9050702@fr.ibm.com>
	<20080114163246.GA31663@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080114163246.GA31663-6s5zFf/epYLPQpwDFJZrxKsjOiXwFzmk@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Serge E. Hallyn wrote:
> Quoting Cedric Le Goater (clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org):
>> to be more precise :
>>
>> 	long sys_clone_something(struct clone_something_args args) 
>>
>> and 
>>
>> 	long sys_unshare_something(struct unshare_something_args args) 
>>
>> The arg passing will be slower bc of the copy_from_user() but we will 
>> still have the sys_clone syscall for the fast path.
>>
>> C.
> 
> I'm fine with the direction you're going, but just as one more option,
> we could follow more of the selinux/lsm approach of first requesting
> clone/unshare options, then doing the actual clone/unshare.  So
> something like
> 
> 	sys_clone_request(extended_64bit_clone_flags)

What if we someday hit the 64-bit limit? :)

> 	sys_clone(usual args)
> 
> or
> 
> 	echo pid,mqueue,user,ipc,uts,net > /proc/self/clone_unshare
> 	clone()

Well, this is how sys_indirect() was intended to work. Nobody
liked it, so I'm afraid this will also not be accepted.

> -serge
> 

Thanks,
Pavel
