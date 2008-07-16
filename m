From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: cryo and mm->arg_start
Date: Wed, 16 Jul 2008 10:23:05 -0500
Message-ID: <20080716152305.GA27200@us.ibm.com>
References: <20080711131345.GA18870@us.ibm.com>
	<1215794310.9139.6.camel@nimitz>
	<1215813673.5456.284.camel@localhost.localdomain>
	<20080713210846.GD8186@us.ibm.com>
	<20080715214050.GA29648@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080715214050.GA29648-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org (sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> Serge E. Hallyn [serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org] wrote:
> | Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> | > 
> | > On Fri, 2008-07-11 at 09:38 -0700, Dave Hansen wrote:
> | > > On Fri, 2008-07-11 at 08:13 -0500, Serge E. Hallyn wrote:
> | > > > 
> | > > > One thing we could do here is to start extending the cryo approach
> | > > > with Eric's checkpoint-as-a-coredump (caac?).  We generate the
> | > > > tiniest of coredumps which, at first, contains nothing but
> | > > > mm->arg_start and maybe a process id.  It would be simplest if
> | > > > it also contained a filename for the real executable,
> | > > 
> | > > The exec model sounds reasonable to me.
> | > >
> | > > But, I think the filename of the exe is going to have to be in the
> | > > checkpoint *already*.  It is mapped by at least one of the VMAs, and
> | > > will probably be dumped as a normal file-backed area.  
> | > 
> | > 	Yes, the file that backed the exec will be there. Note that thanks to
> | > "stacking" filesystems the path to the file backing the exe is not
> | > _always_ going to be the same as the path to the file which userspace
> | > exec'd in the first place. You can see this by comparing
> | > the /proc/<pid>/exe symlink with the file backing the VMA.
> | > 
> | > 	This is important to any program which checks the /proc/self/exe
> | > symlink to find out where it's installed (Java does this, for example).
> | > I think it's possible to do this with a binfmt -- it's just one more
> | > detail to remember.
> | > 
> | > Cheers,
> | > 	-Matt
> | 
> | Let's say that before starting my checkpointable job, I did
> | 
> | 	mount -t ecryptfs /home/hallyn /home/hallyn
> | 
> | Now if the checkpointable job is /home/hallyn/somelongjob, then I think
> | it's fair to say that restart can fail if /home/hallyn at the restart
> | machine isn't ecryptfs-mounted.
> | 
> | In that case, would you still think there is a problem?
> | 
> | On the other hand, if the checkpointable job did the ecryptfs mount
> | itself, then it would be expected that at restart the ecryptfs mount
> | would be remounted.  How that would be done I have no idea offhand.
> 
> Hmm, wonder if the new /proc/pid/mountinfo with its mount-ids would
> enable us to identify the filesystems that a given process expects.

Interesting point.  Yes, it *should*, that's sort of the idea.  I don't
remember whether some of the limitations in terms of hiding mount-ids
from other namespaces were implemented or not, if so I suspect they
could be a problem.

> Which brings up another question. If two processes in the same container
> have different mount namespaces and mount points, we would need to
> reestablish the mounts during restart right ?

Yes.

-serge
