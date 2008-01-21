From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] An attempt to have an unlimitedly extendable sys_clone
Date: Mon, 21 Jan 2008 11:36:38 +0100
Message-ID: <479475B6.1020308@fr.ibm.com>
References: <478CAC32.4080809@openvz.org> <478CB73E.30603@fr.ibm.com>
	<478CC7AD.7060908@fr.ibm.com> <478DB4CC.1090102@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <478DB4CC.1090102-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello Pavel !

Pavel Emelyanov wrote:
>> Here's the unshare part if you want to fold that with your patch.
> 
> Thanks, Cedric. I'll pick that up.
> 
>> Thanks,
> 
> OK, thanks everyone, I'll try to cook the final patch today
> and send it to Andrew as an RFC.

As Al said it, it's probably not the direction to follow to extend the 
clone flags :) But the problem being real, I think we need to insist. 

First, we could simplify the API by using child_tidptr to pass a 64bits 
array of flags. This would still be a brutal syscall argument hijack but 
we can't do better without a new syscall.

Next, we could send the same code using a new syscall.

I have time to work on that. 

C.
