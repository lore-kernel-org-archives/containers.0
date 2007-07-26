From: Dave Hansen <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 10/15] Make each namespace has its own proc tree
Date: Thu, 26 Jul 2007 10:38:58 -0700
Message-ID: <1185471539.18414.106.camel@localhost>
References: <46A8B37B.6050108@openvz.org>  <46A8B59E.7050009@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <46A8B59E.7050009-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 2007-07-26 at 18:54 +0400, Pavel Emelyanov wrote:
> 
> +       if (flags & MS_KERNMOUNT)
> +               ns = (struct pid_namespace *)data;
> +       else
> +               ns = current->nsproxy->pid_ns; 

So, a current /proc mount doesn't use the data pointer at all?

Instead of having a brand spanking new mount flag that only one FS uses,
how about creating a new fs_type for the internal proc mounts?

We could have proc_fs_type and proc_fs_kernel_type each with a quick
stub ->get_sb function to find the correct pid_ns and pass it into the
real proc_get_sb().

But, the basic problem still boils down to the fact that we don't want
random people mounting random pid_ns's /procs.  If we set up rules for
that, like that you can mount childrens' /proc but not parents', I think
this might just fall out and work.  

-- Dave
