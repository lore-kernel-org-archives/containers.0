From: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/2] namespaces: give each namespace a serial number
Date: Fri, 2 May 2014 20:50:00 +0000
Message-ID: <20140502204959.GE2631@ubuntumail>
References: <cover.1398176489.git.rgb@redhat.com>
	<be1358c6da51252cd79c51a51bb30bf157624ccd.1398176489.git.rgb@redhat.com>
	<20140501225116.GB25669@mail.hallyn.com>
	<20140502141530.GB24111@madcap2.tricolour.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140502141530.GB24111-bcJWsdo4jJjeVoXN4CMphl7TgLCtbB0G@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Richard Guy Briggs (rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org):
> On 14/05/02, Serge E. Hallyn wrote:
> > Quoting Richard Guy Briggs (rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org):
> > 
> > Most of this looks reasonable, but I'm curious about something,
> > 
> > > +/**
> > > + * ns_serial - compute a serial number for the namespace
> > > + *
> > > + * Compute a serial number for the namespace to uniquely identify it in
> > > + * audit records.
> > > + */
> > > +unsigned int ns_serial(void)
> > > +{
> > > +	static DEFINE_SPINLOCK(serial_lock);
> > > +	static unsigned int serial = 4; /* reserved for IPC, UTS, user, PID */
> > > +
> > > +	unsigned long flags;
> > > +	unsigned int ret;
> > > +
> > > +	spin_lock_irqsave(&serial_lock, flags);
> > > +	do {
> > > +		ret = ++serial;
> > > +	} while (unlikely(!ret));
> > 
> > Why exactly are you doing this?  Surely if serial is going to
> > wrap around we've got a bigger problem than just wanting go
> > bump one more time?
> 
> Thanks for catching this.
> The code was templated off audit_serial() which tries to solve a
> different problem and rolling it is much more likely.  I hadn't noticed
> that rollover protection.  However, I *had* thought of making it a long
> (which would be the same size on 32-bit arches, but larger on 64-bit)
> since a 64-bit system is more likely to roll it out of sheer speed and
> resource availability.  But perhaps a long long would be safer.

Sounds good, and perhaps a BUG_ON(!serial) for good measure.
