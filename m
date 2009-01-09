From: Guenter Roeck <groeck-gvzKVTG1yJJBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC][PATCH] IP address restricting cgroup subsystem
Date: Fri, 9 Jan 2009 15:37:25 -0800
Message-ID: <20090109233725.GA3659@redback.com>
References: <20090106230554.GB25228@eskarina.localdomain.pl>
	<20090107180752.GA19153@us.ibm.com>
	<20090107191536.GA15159@megiteam.pl>
	<20090107193234.GA22625@us.ibm.com>
	<87priwifnu.fsf@caffeine.danplanet.com>
	<20090109174334.GA4526@redback.com>
	<87ljtkic1j.fsf@caffeine.danplanet.com>
	<20090109223756.GA22738@redback.com>
	<20090109224742.GA15227@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090109224742.GA15227-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: "containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org" <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Jan 09, 2009 at 02:47:42PM -0800, Serge E. Hallyn wrote:
> Quoting Guenter Roeck (groeck-gvzKVTG1yJJBDgjK7y7TUQ@public.gmane.org):
> > On Fri, Jan 09, 2009 at 10:12:24AM -0800, Dan Smith wrote:
> > > GR> I have tried something similar, only with
> > > GR> CLONE_FILES|CLONE_FS|CLONE_VM|CLONE_NEWNET, and actually creating
> > > GR> a virtual interface and controlling socket or thread in each new
> > > GR> network namespace.
> > >
> > > My initial test was to create a veth pair and move one end into the
> > > namespace during create.  That failed in the same way, so I took the
> > > veth's out of the equation with the posted test.
> > >
> > > GR> This scales to a couple of thousand interfaces, though interface
> > > GR> creation takes a long time if more than 1,000 interfaces or so are
> > > GR> created.
> > >
> > This is at least to some degree due to the problems I mentioned earlier.
> > Enhancing the kernel name hash and the sysfs implementation improves
> > performance a lot.
> 
> Is this something you've had a chance to start addressing?  (Just wondering)
> 
Yes - I have code for the name hash change (just one line, really), and two variants
of code for sysfs - one that uses a hash result as 1st step of comparison before
doing a strcmp, and another which uses a hash table per directory in sysfs.
The latter is of course more efficient, but also more expensive in terms of memory usage. 

If there is interest, I can submit a patchset once I find out how exactly to do it ;-).

Guenter
