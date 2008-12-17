From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] ipc namespaces: implement support for posix msqueues
Date: Wed, 17 Dec 2008 13:08:26 -0600
Message-ID: <20081217190826.GA25890@us.ibm.com>
References: <20081217175513.GA23291@us.ibm.com>
	<20081217175549.GB23331@us.ibm.com>
	<1229540099.17206.426.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1229540099.17206.426.camel@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Dave Hansen (dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> On Wed, 2008-12-17 at 11:55 -0600, Serge E. Hallyn wrote:
> > -void free_ipc_ns(struct kref *kref)
> > +void put_ipc_ns(struct ipc_namespace *ns)
> >  {
> > -       struct ipc_namespace *ns;
> > +       if (ns && atomic_dec_and_lock(&ns->count, &mq_lock)) {
> > +               mq_clear_sbinfo(ns);
> > +               spin_unlock(&mq_lock);
> > +               mq_put_mnt(ns);
> > +               free_ipc_ns(ns);
> > +       }
> > +}
> 
> OK, I see now why you wanted to remove the kref and add an atomic_t.
> That's probably worth a sentence in the patch description.

Good point, will do.

> I know that atomic_dec_and_lock() can be a nice logical thing to do, but
> is it necessary here?  Basically, is there something that happens under
> mq_lock that can re-raise the ns->count?

A racing task from another ipc namespace can open a mq file through
the VFS and thereby bump the ipc's refcount.  Will comment that here and
in the patch description.

thanks,
-serge
