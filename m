From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/9] exec_path 1/9: introduce ->exec_path and switch
	/proc/*/exe
Date: Thu, 4 Jun 2009 01:10:46 -0700
Message-ID: <20090604081046.GV9285__3511.22208307988$1244103294$gmane$org@us.ibm.com>
References: <20090526113618.GJ28083@us.ibm.com>
	<20090526162415.fb9cefef.akpm@linux-foundation.org>
	<20090531215427.GA29534@x200.localdomain>
	<20090531151953.8f8b14b5.akpm@linux-foundation.org>
	<20090603230422.GB853@x200.localdomain>
	<20090604075532.GU9285@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090604075532.GU9285-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Jun 04, 2009 at 12:55:32AM -0700, Matt Helsley wrote:
> On Thu, Jun 04, 2009 at 03:04:22AM +0400, Alexey Dobriyan wrote:
> > On Sun, May 31, 2009 at 03:19:53PM -0700, Andrew Morton wrote:
> > > On Mon, 1 Jun 2009 01:54:27 +0400 Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> > > 
> > > > And BTW, there is something unnatural when executable path is attached
> > > > to mm_struct(!) not task_struct,
> > > 
> > > mm_struct is the central object for a heavyweight process.  All threads
> > > within that process share the same executable path (don't they?) so
> > > attaching the executable path to the mm seems OK to me.
> > 
> > OK, let's try this:
> > 
> > 
> > [PATCH 1/9] exec_path 1/9: introduce ->exec_path and switch /proc/*/exe
> > 
> > ->exec_path marks executable which is associated with running task.
> > Binfmt loader decides which executable is such and can, in theory,
> > assign anything. Unlike current status quo when first VM_EXECUTABLE mapping is
> > sort of marks running executable.
> > 
> > If executable unmaps its all VM_EXECUTABLE mappings, /proc/*/exe ceases
> > to exists, ick! And userpsace can't even use MAP_EXECUTABLE.
> 
> Suprising but intentional and unavoidable. More below..
> 
> > 
> > Tasks which aren't created by running clone(2) and execve(2)
> > (read: kernel threads) get empty ->exec_path and
> > 
> > ->exec_path is copied on clone(2) and put at do_exit() time.
> 
> Doesn't this pin the vfs mount of the executable for the lifetime of
> the task?
> 
> That was one of Al Viro's objections to early revisions of the exe_file
> patches. It's the reason the exe_file patches kept track of the number of
> VM_EXECUTABLE mappings with num_exe_file_vmas.
> 
> I've cc'd Al so he can confirm/deny my recollection of this. Basically
> some programs need to be able to umount the filesystem that back their
> executables. Being able to unmap these regions was effectively a
> userspace API for unpinning these mounts. I needed to preserve that API,
> hence the VMA ugliness of exe_file that you object to with the exe_file
> patches.
> 
> I think patches 2-7 look great and could be adapted to use exe_file instead
> of ->exec_path.

Well, except 5 and 6.

Alternately, I think you could use the same VMA code with ->exec_path to avoid
pinning the vfs mount. However, then it would probably be best to move
it into the mm just like exe_file...

> 
> Cheers,
> 	-Matt Helsley
