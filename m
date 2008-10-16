From: Dmitry Mishin <dim-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [Devel] lxc userspace tools 0.3.0 released
Date: Thu, 16 Oct 2008 12:10:47 +0400
Message-ID: <200810161210.48149.dim@openvz.org>
References: <48F4AF2E.3000204@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48F4AF2E.3000204-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, igor-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Hi, Daniel!

I studied a bit lxc tools and have a couple of questions. Could you answer 
them?

1)  Why did you chose such way of a container's configuration storing? IMHO, 
configuration in one file is better, because this file will be small and 
could be easily mmap'ed for the following operations instead of multiple 
readdir() and filesystem lookups.
2) why did you chose cvs as VCS? Git is more common and convenient for 
distributed development...

-- 
Thanks,
Dmitry.
On Tuesday 14 October 2008 18:39:42 Daniel Lezcano wrote:
> Hi,
>
> a new version of lxc has been released.
>
> 	https://sourceforge.net/projects/lxc/
>
> This version takes into account the control group and provides the
> checkpoint / restart for external checkpoint.
>
> It includes a lot of small improvements and fixes, full details are in
> the ChangeLog file.
>
> Thanks.
>    -- Daniel
>
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
>
> _______________________________________________
> Devel mailing list
> Devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
> https://openvz.org/mailman/listinfo/devel
