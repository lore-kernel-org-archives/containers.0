From: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH v2] locks: Filter /proc/locks output on proc pid ns
Date: Wed, 3 Aug 2016 10:28:50 -0400
Message-ID: <20160803142850.GA27072__2593.18892281062$1470234648$gmane$org@fieldses.org>
References: <1470148943-21835-1-git-send-email-kernel@kyup.com>
	<1470209710-30022-1-git-send-email-kernel@kyup.com>
	<1470232012.18285.4.camel@poochiereds.net>
	<57A1FCE5.3040206@kyup.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <57A1FCE5.3040206-6AxghH7DbtA@public.gmane.org>
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
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>, xemul-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Aug 03, 2016 at 05:17:09PM +0300, Nikolay Borisov wrote:
> 
> 
> On 08/03/2016 04:46 PM, Jeff Layton wrote:
> > On Wed, 2016-08-03 at 10:35 +0300, Nikolay Borisov wrote:
> >> On busy container servers reading /proc/locks shows all the locks
> >> created by all clients. This can cause large latency spikes. In my
> >> case I observed lsof taking up to 5-10 seconds while processing around
> >> 50k locks. Fix this by limiting the locks shown only to those created
> >> in the same pidns as the one the proc was mounted in. When reading
> >> /proc/locks from the init_pid_ns show everything.
> >>
> >>> Signed-off-by: Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>
> >> ---
> >>  fs/locks.c | 6 ++++++
> >>  1 file changed, 6 insertions(+)
> >>
> >> diff --git a/fs/locks.c b/fs/locks.c
> >> index ee1b15f6fc13..751673d7f7fc 100644
> >> --- a/fs/locks.c
> >> +++ b/fs/locks.c
> >> @@ -2648,9 +2648,15 @@ static int locks_show(struct seq_file *f, void *v)
> >>  {
> >>>  	struct locks_iterator *iter = f->private;
> >>>  	struct file_lock *fl, *bfl;
> >>> +	struct pid_namespace *proc_pidns = file_inode(f->file)->i_sb->s_fs_info;
> >>> +	struct pid_namespace *current_pidns = task_active_pid_ns(current);
> >>  
> >>>  	fl = hlist_entry(v, struct file_lock, fl_link);
> >>  
> >>>> +	if ((current_pidns != &init_pid_ns) && fl->fl_nspid
> > 
> > Ok, so when you read from a process that's in the init_pid_ns
> > namespace, then you'll get the whole pile of locks, even when reading
> > this from a filesystem that was mounted in a different pid_ns?
> > 
> > That seems odd to me if so. Any reason not to just uniformly use the
> > proc_pidns here?
> 
> [CCing some people from openvz/CRIU]
> 
> My train of thought was "we should have means which would be the one
> universal truth about everything and this would be a process in the
> init_pid_ns".

OK, but why not make that means be "mount proc from the init_pid_ns and
read /proc/locks there".  So just replace current_pidns with proc_pidns
in the above.  I think that's all Jeff was suggesting.

--b.

> I don't have strong preference as long as I'm not breaking
> userspace. As I said before - I think the CRIU guys might be using that
> interface.
> 
> > 
> >>>> +	    && (proc_pidns != ns_of_pid(fl->fl_nspid)))
> >>> +		return 0;
> >> +
> >>>  	lock_get_status(f, fl, iter->li_pos, "");
> >>  
> >>>  	list_for_each_entry(bfl, &fl->fl_block, fl_block)
> > 
