From: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Subject: Re: [RFC PATCH] locks: Show only file_locks created in the same
	pidns as current process
Date: Tue, 2 Aug 2016 11:43:30 -0400
Message-ID: <20160802154330.GC11767@fieldses.org>
References: <1470148943-21835-1-git-send-email-kernel@kyup.com>
	<20160802150521.GB11767@fieldses.org> <57A0BA40.5010406@kyup.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <57A0BA40.5010406-6AxghH7DbtA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>
Cc: serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Aug 02, 2016 at 06:20:32PM +0300, Nikolay Borisov wrote:
> On 08/02/2016 06:05 PM, J. Bruce Fields wrote:
> > (And what process was actually reading /proc/locks, out of curiosity?)
> 
> lsof in my case

Oh, thanks, and you said that at the start, and I overlooked
it--apologies.

> >> while the container
> >> itself had only a small number of relevant entries. Fix it by
> >> filtering the locks listed by the pidns of the current process
> >> and the process which created the lock.
> > 
> > Thanks, that's interesting.  So you show a lock if it was created by
> > someone in the current pid namespace.  With a special exception for the
> > init namespace so that 
> 
> I admit this is a rather naive approach. Something else I was pondering was 
> checking whether the user_ns of the lock's creator pidns is the same as the 
> reader's user_ns. That should potentially solve your concerns re. 
> shared filesystems, no? Or whether the reader's userns is an ancestor 
> of the user'ns of the creator's pidns? Maybe Eric can elaborate whether 
> this would make sense?

If I could just imagine myself king of the world for a moment--I wish I
could have an interface that took a path or a filehandle and gave back a
list of locks on the associated filesystem.  Then if lsof wanted a
global list, it would go through /proc/mounts and request the list of
locks for each filesystem.

For /proc/locks it might be nice if we could restrict to locks on
filesystem that are somehow visible to the current process, but I don't
know if there's a simple way to do that.

--b.

> 
> > 
> > If a filesystem is shared between containers that means you won't
> > necessarily be able to figure out from within a container which lock is
> > conflicting with your lock.  (I don't know if that's really a problem.
> > I'm unfortunately short on evidence aobut what people actually use
> > /proc/locks for....)
> > 
> > --b.
> > 
> >>
> >> Signed-off-by: Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>
> >> ---
> >>  fs/locks.c | 8 ++++++++
> >>  1 file changed, 8 insertions(+)
> >>
> >> diff --git a/fs/locks.c b/fs/locks.c
> >> index 6333263b7bc8..53e96df4c583 100644
> >> --- a/fs/locks.c
> >> +++ b/fs/locks.c
> >> @@ -2615,9 +2615,17 @@ static int locks_show(struct seq_file *f, void *v)
> >>  {
> >>  	struct locks_iterator *iter = f->private;
> >>  	struct file_lock *fl, *bfl;
> >> +	struct pid_namespace *pid_ns = task_active_pid_ns(current);
> >> +
> >>  
> >>  	fl = hlist_entry(v, struct file_lock, fl_link);
> >>  
> >> +	pr_info ("Current pid_ns: %p init_pid_ns: %p, fl->fl_nspid: %p nspidof:%p\n", pid_ns, &init_pid_ns,
> >> +		 fl->fl_nspid, ns_of_pid(fl->fl_nspid));
> >> +	if ((pid_ns != &init_pid_ns) && fl->fl_nspid &&
> >> +		(pid_ns != ns_of_pid(fl->fl_nspid)))
> >> +		    return 0;
> >> +
> >>  	lock_get_status(f, fl, iter->li_pos, "");
> >>  
> >>  	list_for_each_entry(bfl, &fl->fl_block, fl_block)
> >> -- 
> >> 2.5.0
