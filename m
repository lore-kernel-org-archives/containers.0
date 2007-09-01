From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: containers - bug
Date: Fri, 31 Aug 2007 17:44:41 -0700
Message-ID: <6599ad830708311744s5fcf03acib5cbcbf3c4849460@mail.gmail.com>
References: <46D841D8.6000100@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <46D841D8.6000100-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
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
To: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On 8/31/07, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> wrote:
> Hi Paul,
>
> I was playing with the container filesystem (very nice) and I fall
> inside a kbug.
>
> I did the following:
>
>         mkdir /dev/container
>         mount -t container -o cpuset cpuset /dev/container
>         cd /dev/container/
>         mkdir Charlie
>         cd Charlie
>         echo $$ > tasks

FYI, this bit didn't have any effect, since the cpuset has no
mems/cpus by default.

>       bash
>       cd ..
>       rmdir Charlie
>       exit
>       ls => bang !

The basic problem appears to be that the reference count on a
containerfs directory is one too low. The root cause is a change that
I made when adapting the cpuset filesystem to create the container
filesystem - in order to implement container_clone() I rearranged the
way that a dentry was passed down to the directory creation code, and
managed to lose a call to lookup_one_len() (since I was getting the
dentry directly from a container structure).

Normally this didn't seem to cause a problem, since dput() doesn't
appear to care if you dput() on something with a refcount of 0. (It
should probably BUG() in that case, I suspect).

But in your case, by making the dead directory some process' cwd, when
you tried to do an ls, the dget(current->fs->pwd) blew up since
current->fs->pwd had a d_count of 0.

I have a fix for this that I'm testing and should be able to send out soon.

Paul
