From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: namespaces compatibility list
Date: Wed, 07 Nov 2007 14:49:03 +0100
Message-ID: <4731C24F.1040408@fr.ibm.com>
References: <47304729.8000309@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47304729.8000309-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

There's also a Documentation/unshare.txt. Should we update it also ?

> --- /dev/null
> +++ b/Documentation/namespaces/compatibility-list.txt
> @@ -0,0 +1,32 @@
> +	Namespaces compatibility list
> +
> +This document contains the information about the problems user
> +may have when creating tasks living in different namespaces.
> +
> +Here's the summary. This matrix shows the known problems, that
> +occur when tasks share some namespace (the columns) while living
> +in different other namespaces (the raws):

s/raws/rows/

> +
> +	UTS	IPC	VFS	PID	User	Net
> +UTS
> +IPC			 1
> +VFS
> +PID		 1	 1
> +User			 2
> +Net

This is dense but I can't think of a better representation.

> +1. Both the IPC and the PID namespaces provide IDs to address
> +   object inside the kernel. E.g. semaphore with ipcid or
> +   process group with pid.
> +
> +   In both cases, tasks shouldn't try telling this id to some

s/telling/exposing/ ?

> +   other task living in different namespace vid shared filesystem

 .. in a different namespace via a shared filesystem  

> +   or IPC shmem/message. The fact is that this ID is only valid
> +   within the namespace it was obtained in and may refer to some
> +   other object in another namespace.
> +
> +2. Intentionnaly, two equal user ids in different user namespaces
> +   should not be equal from the VFS point of view. In other
> +   words, user 10 in one user namespace shouldn't have the same
> +   access permissions to files, beloging to user 10 in another
> +   namespace. But currently this is not so.
> 
> 

Thanks Pavel,

C.
