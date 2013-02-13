From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: nfs-ganesha with Linux containers
Date: Wed, 13 Feb 2013 11:14:40 -0800
Message-ID: <87liasuiu7.fsf@xmission.com>
References: <20130213074747.GA19635@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130213074747.GA19635-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Sukadev Bhattiprolu's
	message of "Tue, 12 Feb 2013 23:47:47 -0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, nfs-ganesha-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> writes:

> I have nfs-ganesha [1.5.1] with FSAL_VFS running on Linux 3.7.0-rc8 on
> an x86_64 RHEL6.2 system (the "host"). I can export the filesystems and
> mount from another system.
>
> I am trying to use nfs-Ganesha from within a Linux container on the same
> system.
>
> My container setup:
>
> 	On the REHL6.2 host, I have a directory, /export/vm1-root.
>
> 	The root of my linux container is bind mounted to that directory 
> 	So a file '/export/vm1-root/foobar' is known to the container as
> 	'/foobar' and other files/directories in '/export' are not visible
> 	from the container.
>
> 	[ie it is as if the processes inside the containers have run 'chroot'
> 	into /export/vm1-root and can't escape out of this]. 

Have you run pivot_root so you can throw away your old mounts?  I don't
know a thing about the nfs ganesha user space daemon but /proc/mounts
should be the only way it could detect your mounts are in a container
and do something odd or confusing.


Eric
