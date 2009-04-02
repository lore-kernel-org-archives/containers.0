From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 02/10] Common flat fair queuing code in elevaotor layer
Date: Thu, 2 Apr 2009 09:52:02 -0400
Message-ID: <20090402135202.GB12851__21850.6304584027$1238680711$gmane$org@redhat.com>
References: <1236823015-4183-1-git-send-email-vgoyal@redhat.com>
	<1236823015-4183-3-git-send-email-vgoyal@redhat.com>
	<af41c7c40904012106h41d3cb50i2eeab2a02277a4c9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <af41c7c40904012106h41d3cb50i2eeab2a02277a4c9-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Divyesh Shah <dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: oz-kernel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, fernando-w0OK63jvRlAuJ+9fw/WgBHgSJqDPrsil@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Apr 01, 2009 at 09:06:40PM -0700, Divyesh Shah wrote:
> On Wed, Mar 11, 2009 at 6:56 PM, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > +/*
> > + * elv_exit_fq_data is called before we call elevator_exit_fn. Before
> > + * we ask elevator to cleanup its queues, we do the cleanup here so
> > + * that all the group and idle tree references to ioq are dropped. Later
> > + * during elevator cleanup, ioc reference will be dropped which will lead
> > + * to removal of ioscheduler queue as well as associated ioq object.
> > + */
> > +void elv_exit_fq_data(struct elevator_queue *e)
> > +{
> > +       struct elv_fq_data *efqd = &e->efqd;
> > +       struct request_queue *q = efqd->queue;
> > +
> > +       if (!elv_iosched_fair_queuing_enabled(e))
> > +               return;
> > +
> > +       elv_shutdown_timer_wq(e);
> > +
> > +       spin_lock_irq(q->queue_lock);
> > +       /* This should drop all the idle tree references of ioq */
> > +       elv_free_idle_ioq_list(e);
> > +       spin_unlock_irq(q->queue_lock);
> > +
> > +       elv_shutdown_timer_wq(e);
> > +
> > +       BUG_ON(timer_pending(&efqd->idle_slice_timer));
> > +       io_free_root_group(e);
> > +}
> >
> 
> Hi Vivek,
>         When cleaning up the elv_fq_data and ioqs for the iogs
> associated with a device on elv_exit(), I don't see any iogs except
> the root group being freed. In io_disconnect_groups() you remove the
> ioqs from each of the iog and move them to the root iog and then
> delete the root iog. Am I missing something here or are there leftover
> iogs at elv_exit?

Hi Divyesh,

io_groups are linked in two lists. One list is maintained by io_cgroup
to keep track of how many io_groups are there associated with this
cgroup and other list is maintained in elv_fq_data to keep track of
how many io_groups are actually doing IO to this device.

Upon elevator exit, we remove the io_groups (io_disconnect_groups())from the
list maintained by elv_fq_data but we don't free them up. Freeing up is
finally done when cgroup is being deleted (iocg_destroy()).

Thanks
Vivek
