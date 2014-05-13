From: Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH V2 1/6] namespaces: assign each namespace instance a
	serial number
Date: Tue, 13 May 2014 11:30:45 -0400
Message-ID: <1399995045.5967.3.camel@flatline.rdu.redhat.com>
References: <cover.1399681022.git.rgb@redhat.com>
	<f34b584ffed2538176f9a366e25bb98c531fb70f.1399681022.git.rgb@redhat.com>
	<1399734119.3558.16.camel@localhost>
	<20140513143925.GD27560@madcap2.tricolour.ca>
	<20140513151316.GE27560@madcap2.tricolour.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140513151316.GE27560-bcJWsdo4jJjeVoXN4CMphl7TgLCtbB0G@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 2014-05-13 at 11:13 -0400, Richard Guy Briggs wrote:
> On 14/05/13, Richard Guy Briggs wrote:
> > On 14/05/10, Eric Paris wrote:
> > > On Fri, 2014-05-09 at 20:27 -0400, Richard Guy Briggs wrote:
> > > > Generate and assign a serial number per namespace instance since boot.
> > > > 
> > > > Use a serial number per namespace (unique across one boot of one kernel)
> > > > instead of the inode number (which is claimed to have had the right to change
> > > > reserved and is not necessarily unique if there is more than one proc fs) to
> > > > uniquely identify it per kernel boot.
> > > > 
> > > > Signed-off-by: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> > > > ---
> > > 
> > > > +/**
> > > > + * ns_serial - compute a serial number for the namespace
> > > > + *
> > > > + * Compute a serial number for the namespace to uniquely identify it in
> > > > + * audit records.
> > > > + */
> > > > +unsigned long long ns_serial(void)
> > > > +{
> > > > +	static DEFINE_SPINLOCK(serial_lock);
> > > > +	static unsigned long long serial = 4; /* reserved for IPC, UTS, user, PID */
> > > > +	unsigned long flags;
> > > > +
> > > > +	spin_lock_irqsave(&serial_lock, flags);
> > > > +	++serial;
> > > > +	spin_unlock_irqrestore(&serial_lock, flags);
> > > > +	BUG_ON(!serial);
> > > > +
> > > > +	return serial;
> > > > +}
> > > > +
> > > >  static inline struct nsproxy *create_nsproxy(void)
> > > >  {
> > > >  	struct nsproxy *nsproxy;
> > > 
> > > atomic64_t instead of doing it yourself?
> > 
> > I'm willing to switch to atomic64_*.  Thanks for pointing out its
> > existence.
> 
> Same would then go for using atomic_t in audit_serial().

Yup, moving to an atomic in audit_serial() looks like a good idea to me.
