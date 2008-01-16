From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 1/2] Extend sys_clone and sys_unshare system calls API
Date: Wed, 16 Jan 2008 18:05:30 +0300
Message-ID: <478E1D3A.1060904@openvz.org>
References: <9803.1200493420@vena.lwn.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <9803.1200493420-k5ufJzZ057zk1uMJSBkQmQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>
Cc: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, drepper-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Jonathan Corbet wrote:
> Hi, Pavel,
> 
> [Adding Ulrich]
> 
>> I use the last bit in the clone_flags for CLONE_LONGARG. When set it
>> will denote that the child_tidptr is not a pointer to a tid storage,
>> but the pointer to the struct long_clone_struct which currently 
>> looks like this:
> 
> I'm probably just totally off the deep end, but something did occur to
> me: this looks an awful lot like a special version of the sys_indirect()
> idea.  Unless it has been somehow decided that sys_indirect() is the
> wrong idea, might it not be better to look at making that interface
> solve the extended clone() problem as well?

We has such an idea, but as far as I know sys_indirect idea is
not yet accomplished. So I risked to propose such an extension
for sys_clone.

If Andrew says that sys_indirect is on its way to -mm tree, then
we'll surely wait and use this one for namespaces.

> jon
> 

Thanks,
Pavel
