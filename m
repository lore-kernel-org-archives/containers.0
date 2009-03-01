From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: How much of a mess does OpenVZ make? ;) Was: What can OpenVZ do?
Date: Sun, 1 Mar 2009 14:02:31 -0600
Message-ID: <20090301200231.GA25276__41665.0620325983$1235937885$gmane$org@us.ibm.com>
References: <1234462282.30155.171.camel@nimitz>
	<1234467035.3243.538.camel@calx>
	<20090212114207.e1c2de82.akpm@linux-foundation.org>
	<1234475483.30155.194.camel@nimitz>
	<20090212141014.2cd3d54d.akpm@linux-foundation.org>
	<1234479845.30155.220.camel@nimitz>
	<20090226162755.GB1456@x200.localdomain>
	<20090226173302.GB29439@elte.hu>
	<20090226223112.GA2939@x200.localdomain>
	<20090301013304.GA2428@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090301013304.GA2428-2ev+ksY9ol182hYKe6nXyg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Alexey Dobriyan (adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> On Fri, Feb 27, 2009 at 01:31:12AM +0300, Alexey Dobriyan wrote:
> > This is collecting and start of dumping part of cleaned up OpenVZ C/R
> > implementation, FYI.
> 
> OK, here is second version which shows what to do with shared objects
> (cr_dump_nsproxy(), cr_dump_task_struct()), introduced more checks
> (still no unlinked files) and dumps some more information including
> structures connections (cr_pos_*)
> 
> Dumping pids in under thinking because in OpenVZ pids are saved as
> numbers due to CLONE_NEWPID is not allowed in container. In presense
> of multiple CLONE_NEWPID levels this must present a big problem. Looks
> like there is now way to not dump pids as separate object.
> 
> As result, struct cr_image_pid is variable-sized, don't know how this will
> play later.
> 
> Also, pid refcount check for external pointers is busted right now,
> because /proc inode pins struct pid, so there is almost always refcount
> vs ->o_count mismatch.
> 
> No restore yet. ;-)

Hi Alexey,

thanks for posting this.  Of course there are some predictable responses
(I like the simplicity of pure in-kernel, Dave will not :) but this
needs to be posted to make us talk about it.

A few more comments that came to me while looking it over:

1. cap_sys_admin check is unfortunate.  In discussions about Oren's
patchset we've agreed that not having that check from the outset forces
us to consider security with each new patch and feature, which is a good
thing.

2. if any tasks being checkpointed are frozen, checkpoint has the
side effect of thawing them, right?

3. wrt pids, i guess what you really want is to store the pids from
init_tsk's level down to the task's lowest pid, right?  Then you
manually set each of those on restart?  Any higher pids of course
don't matter.

4. do you have any thoughts on what to do with the mntns info at
restart?  Will you try to detect mounts which need to be re-created?
How?

5. Since you're always setting f_pos, this won't work straight over
a pipe?  Do you figure that's just not a worthwhile feature?

Were you saying (in response to Dave) that you're having private
discussions about whether to pursue posting this as an alternative
to Oren's patchset?  If so, any updates on those discussions?

thanks,
-serge
